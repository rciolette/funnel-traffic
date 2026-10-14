# Motor de jornada — especificação

Como o Funnel Traffic transforma eventos em números no canvas. Esta é a referência para escrever `jornada_calcular` e o teste de contrato. Toda regra aqui tem um caso de teste na seção 7.

Fontes: benchmark Funnelytics (`docs/benchmark-funnelytics.md`, `docs/benchmark/caso-funnelytics.md`), [funis do PostHog](https://posthog.com/docs/features/funnels) (mesma semântica de ordem e janela, publicada em detalhe) e as decisões em `docs/DECISOES.md`.

## 1. Entradas

```
jornada_calcular(
  p_canvas      uuid,
  p_de          timestamptz,      -- início do período (fuso do workspace já aplicado)
  p_ate         timestamptz,      -- fim do período, exclusivo
  p_filtros     jsonb default '{}',   -- país, dispositivo, origem, pessoa, "pessoas que fizeram"
  p_modo        text default 'mapa',  -- 'mapa' | 'funil'
  p_comparar    jsonb default null    -- segunda coorte (período ou filtro), mesma forma de saída
) returns jsonb
```

Saída:

```json
{
  "etapas":   [{ "id": "…", "pessoas": 1234, "valorCentavos": 0, "moeda": "BRL" }],
  "conexoes": [{ "id": "…", "pessoas": 456, "taxa": 0.3695 }],
  "calculadoEm": "2026-10-14T13:00:00Z",
  "eventosAte": "2026-10-14T12:59:31Z",
  "avisos": ["ciclo_no_funil"]
}
```

`eventosAte` é o `recebido_em` do evento mais novo considerado. A tela mostra "dados até HH:MM:SS", que é a prova do atraso de até 60 s.

## 2. Unidade de contagem

- **Pessoa única**, nunca sessão nem visita. A pessoa é `coalesce(pessoas.fundida_em, pessoas.id)`, resolvida no momento do cálculo. Uma fusão nova muda números passados (igual ao Funnelytics e ao PostHog), e desfazer a fusão volta os números.
- Uma pessoa que faz a etapa 5 vezes conta 1.
- Dinheiro de uma etapa = soma de `valor_centavos` dos eventos que casaram, por moeda. Nunca somar moedas diferentes.

## 3. Etapa = regra sobre eventos

| Tipo | Casa com |
| --- | --- |
| `fonte` | evento de entrada (page view) com `utm_*`, `fl_*` ou referência que bate o filtro |
| `pagina` | `evento = 'Page View'` e URL com curinga (`*` um segmento, `**` qualquer coisa) e parâmetros (vários pares = E) |
| `acao` | `evento = <nome>` (ou nome reservado `__compra__`, `__contato__`) + filtros de atributo |
| `offline` | igual a `acao`; só muda o ícone |

O filtro é JSON com os operadores de `config_operadores`. Comparação de texto sem diferenciar maiúsculas. Um nome reservado expande para a lista de eventos mapeados para ele em configuração, nunca no código.

## 4. Período

- **A pessoa entra na etapa se tem pelo menos um evento que casa dentro de [p_de, p_ate).**
- **Conexão A → B:** a pessoa precisa ter A dentro do período, e B depois de A (regra da seção 5) até `p_ate`, ou até `A + janela_dias` quando a conexão tem janela. B pode cair depois de `p_ate` só quando há janela. É a *Contribution Window* do Funnelytics.
- Para cada pessoa usa-se o **primeiro A do período** como âncora e o **primeiro B válido depois dele**. Isso evita contar a mesma pessoa duas vezes e dá números estáveis.

> A regra exata do Funnelytics sobre B fora do período não foi verificada (sem conta). A acima é a do PostHog e é a que vamos testar. Quando houver conta, comparar e registrar a diferença em `docs/DECISOES.md`.

## 5. Conexões

| Tipo | Regra | Equivalente |
| --- | --- | --- |
| `direta` | B é o **próximo evento relevante** da pessoa depois de A | PostHog *strict*; linha sólida do Funnelytics |
| `pular` | B acontece em **qualquer momento depois** de A, dentro do período ou da janela | PostHog *sequential*; linha pontilhada do Funnelytics |

**Próximo evento relevante.** Todos os eventos da pessoa entram na sequência, **menos** os marcados como ruído em `config_eventos_ruido` (a criar), por exemplo `Scroll`, `Video Progress` e `Heartbeat`. Sem essa lista, um scroll entre a página e o clique zera a linha direta. A lista é por workspace, com padrão global.

Empate de horário (mesmo `ocorrido_em`): ordem por `ocorrido_em`, depois `recebido_em`, depois `id`. A ordem é determinística, e o teste cobre o caso.

## 6. Modos

- **`mapa`** (padrão): cada etapa e cada conexão são calculadas sozinhas. Uma etapa pode ter mais pessoas que a anterior.
- **`funil`**: a etapa só conta quem passou por todas as etapas anteriores conectadas, na ordem e com as regras de cada conexão. A primeira etapa sem entrada é a raiz. Se o grafo tem ciclo, o motor quebra o ciclo na aresta que volta e devolve o aviso `ciclo_no_funil`.

Filtros:

- **"Pessoas que fizeram"** (lista de etapas com E/OU) restringe o universo antes da contagem.
- **Pessoa** isola um indivíduo (exige admin, por causa do dado pessoal).
- **Comparação** roda o cálculo duas vezes e devolve as duas saídas lado a lado.

## 7. Casos do teste de contrato

Base: `NODES` e `EDGES` do protótipo (`docs/prototipo/funnel-traffic-canvas.html`) mais estes casos fixos:

| # | Eventos da pessoa | Esperado |
| --- | --- | --- |
| 1 | A, C, B | A→B pular = 1; A→B direta = 0 |
| 2 | A, Scroll, B | A→B direta = 1 (scroll é ruído) |
| 3 | A, A, B | A = 1, B = 1, taxa 100 % |
| 4 | A no último dia; B no dia seguinte, sem janela | A→B = 0 |
| 5 | Igual ao 4, com `janela_dias = 7` | A→B = 1 |
| 6 | Anônimo faz A; depois se identifica por e-mail e faz B | 1 pessoa; A→B = 1 |
| 7 | Fusão do caso 6 revertida | 2 pessoas; A→B = 0 |
| 8 | B antes de A | A→B = 0 nos dois tipos |
| 9 | A e B no mesmo segundo | segue a ordem por `recebido_em` |
| 10 | Canvas com ciclo B→A, modo funil | não trava; aviso `ciclo_no_funil` |
| 11 | Compra de 2 itens (2 eventos `__compra__`) | etapa compra = 1 pessoa; valor = soma dos 2 |
| 12 | Evento em conector `sombra` | não aparece |

## 8. Desempenho

- Índices já criados: `eventos (workspace_id, pessoa_id, ocorrido_em)` e `(workspace_id, evento, ocorrido_em)`.
- Caminho: (1) filtrar os eventos do período que casam com alguma etapa, (2) `row_number()` por pessoa para a sequência, (3) agregar por etapa e conexão. Tudo numa CTE só, `security definer`, conferindo `tem_papel(ws, 'visualizador')` no começo.
- Cache: `jornada_cache (canvas_id, chave_parametros, resultado, eventos_ate)` com validade de 60 s. Abrir o canvas não recalcula se nada chegou.
- Meta: p95 < 2 s com 10 M eventos/mês por workspace. Acima disso, avaliar ClickHouse (decisão de 04/10).

## 9. Funções irmãs

| Função | Para quê |
| --- | --- |
| `jornada_proximos_passos(etapa, período)` | Step Explorer: top N eventos/páginas que vieram depois da etapa |
| `jornada_passos_anteriores(etapa, período)` | De onde as pessoas vieram |
| `explorer_top(workspace, tipo, período)` | Aba Explorer: fontes, páginas e ações mais frequentes |
| `etapa_pessoas(etapa, período)` | Lista de pessoas da etapa, mascarada conforme o papel |
| `pessoa_jornada(pessoa)` | Linha do tempo de uma pessoa (admin+) |
| `monitor_kpis(workspace, período)` / `meta_status(meta)` / `etapa_dia(etapa, período)` | Monitor, metas e tendência |
