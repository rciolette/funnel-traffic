# Instância ROI Ventures — mapa e versão de testes

O que a ROI Ventures já tem rodando, traduzido para o Funnel Traffic, e uma versão de testes local montada a partir disso. Levantamento de 14/10/2026, **só leitura** pelos MCPs da ROI. Nada foi escrito em n8n, Supabase ou HubSpot.

Decisões do dono (14/10): versão de testes **local agora**; depois, schema `funnel_traffic` no Supabase `roi-apps` (`opzuindwpwxevwlhoaaw`). A reescrita do banco com esse schema foi aprovada e já está feita e testada no repositório; aplicar no `roi-apps` espera o MCP do projeto e o "pode" final.

## 1. De onde veio cada dado

| Fonte | Como foi lida | O que entrou aqui |
| --- | --- | --- |
| n8n RoiVentures | MCP `search_workflows`, 2 chamadas (298 fluxos) | `dados/n8n-fluxos-2026-10-14.json`: id, nome, ativo, datas, tags. Sem descrição, credencial ou URL de webhook |
| Inventário de 29/09 | `~/GitHub/ROI/trackeamento-e-jornadas-roi/data/inventario-n8n.json` (112 fluxos) | Negócio, divergências e execuções de cada fluxo que já estava lá |
| Supabase `qevnfgopjupsmwvflcza` (Gerador de Links, Qualificador, Dash) | MCP `list_tables` e um `select` só de agregados | Tabelas, colunas e contagens por tipo de evento. Nenhuma linha de pessoa |
| Supabase `roi-apps` | **Não lido**: o MCP desse projeto não está conectado nesta sessão | — |

## 2. O que a ROI já tem

### 2.1 Fluxos n8n

| Sinal | Valor |
| --- | --- |
| Fluxos (total / ativos) | 298 / 152 (eram 289 / 144 em 29/09) |
| Ativos legíveis pelo MCP | 123 |
| Ativos que não estavam no inventário de 29/09 | 41 |
| Divergências de severidade alta nos ativos inventariados | 79 |

Papel de cada fluxo ativo no Funnel Traffic (`mapa-n8n.md` traz a lista inteira):

| Papel | Fluxos | O que vira |
| --- | --- | --- |
| Entrada | 70 | Evento de pessoa no canvas (compra, formulário, live, grupo) |
| Cadência | 32 | Evento de contato (Sellflux, Digisac, UnniChat) |
| Entrega | 29 | Evento pós-compra (acesso liberado, contrato assinado) |
| Saída | 13 | Nada: relatório, planilha, Slack |
| Infra | 7 | Nada: alerta, auditoria, teste |
| Sem classificação | 1 | `[LN] Recuperação` (pendente) |

### 2.2 Conectores que esses fluxos pedem

| Conector | Fluxos ativos | No catálogo | Observação |
| --- | --- | --- | --- |
| `sellflux` | 27 | **não** | Maior família. Cadência Inside e E-cont por tags |
| `assiny` | 26 | sim | 8 webhooks de produção já gravam em `public.assiny_events` |
| `typeform` | 17 | sim | Captação, levantada de mão, aplicação, onboarding |
| `memberclass` | 8 | sim | Entrega IniciAmazon e ROI Club |
| `docusign` | 7 | sim | Contratos E-cont e Mentoria |
| `n8n` | 7 | sim | Suporte, reembolso, CS |
| `memberkit` | 6 | sim | Entrega Mentoria |
| `webhook` | 5 | sim | Páginas de captura, Native Ads |
| `zoom` | 5 | sim | Lives E-cont e Importação |
| `digisac` | 4 | **não** | WhatsApp |
| `asaas` | 3 | **não** | Importação (Stock); grava em `public.asaas_events` |
| `gerador-links` | 3 | **não** | Venda registrada e concluída pelo Gerador |
| `cakto`, `hubla` | 2 cada | sim | Funil Nath |
| `manychat` | 2 | **não** | Direct do Instagram. **Adiado** por decisão do dono (14/10): não entra na versão de testes |
| `applyfy`, `clicksign`, `greatpages`, `yayforms`, `unnichat`, `wordpress` | 1 cada | **não** | |

**11 conectores não estão no catálogo** (`docs/conectores/CATALOGO.md`). Eles foram acrescentados como "pedidos pela instância ROI".

### 2.3 Histórico que já existe no Supabase e pode virar carga inicial

| Tabela (projeto `qevnfgopjupsmwvflcza`) | Volume | Período | Evento no Funnel Traffic |
| --- | --- | --- | --- |
| `public.assiny_events` | 2.213 | mar–out/2026 | `approved_purchase` → Compra Aprovada (`__compra__`), `pix_generated` → PIX Gerado, `abandoned_checkout` → Carrinho Abandonado, `refused` → Compra Recusada, `refunded_purchase`/`request_refund` → Reembolso, `subscription_*` → Assinatura. Rótulos e sinal já estão em `public.assiny_evento_config` (18 eventos) |
| `public.asaas_events` | 677 | ago–out/2026 | `PAYMENT_CREATED` → Cobrança Criada, `PAYMENT_CONFIRMED`/`RECEIVED` → Pagamento Confirmado |
| `public.gerador_eventos_comerciais` | 434 | set–out/2026 | `oportunidade` → Oportunidade Criada, `agendamento` → Reunião Agendada |
| `public.gerador_hubspot_negocio_historico` | 27.717 | set–out/2026 | Mudança de `etapa` → Negócio Mudou de Etapa (atributo `etapa`); `owner_id`/`sdr_id` ficam como atributo, não como etapa |
| `public.gerador_hubspot_negocio` | 57.640 negócios em 3 pipelines (E-cont, Pré Vendas, Closer's) | nov/2025–out/2026 | Foto atual; serve para UTMs e etapa de entrada |
| `qualificador.engajamento` | 4.602 | foto | MemberClass (4.339) e MemberKit (263): aulas, último acesso |
| `qualificador.transacao` | 5.216 | import CSV Assiny | Compras com produto, oferta, funil e UTM |

### 2.4 Como a ROI identifica a pessoa

`qualificador.pessoa_identificador` usa: e-mail (4.602), telefone (4.777), **documento/CPF (4.585)**, `assiny_client_id` (4.602), `memberclass_id` (4.338) e o ID do contato no HubSpot.

Comparado com a nossa cascata (ID externo → e-mail → telefone → cookie):

- `assiny_client_id`, `memberclass_id` e o ID do HubSpot entram como **ID externo** por conector. Já cabe.
- **Documento (CPF) não existe na nossa cascata.** Proposta: novo tipo `documento` em `identidades`, gravado só como hash e nunca exibido. Precisa de decisão e de migration.
- A Sellflux traz e-mail vazio na maioria dos leads e casa por telefone, como a nota do Qualificador já registra. Isso confirma o telefone E.164 como segundo critério.

### 2.5 Pipelines do HubSpot usados pelo Gerador

| Pipeline | ID | Time | Ativo |
| --- | --- | --- | --- |
| Vendas \| E-cont | 717654561 | econt | sim |
| Pré Vendas | 932401505 | inside-sales | sim |
| Vendas \| Closer's | 932402477 | ae | sim |
| Vendas \| Importação | 894137220 | importacao | sim |
| Vendas \| Account Executives | 710485361 | ae | não |
| Vendas \| Inside Sales | 711246125 | inside-sales | não |

As etapas (por ID) estão em `public.gerador_hubspot_pipelines`. No Funnel Traffic, cada etapa de negócio vira uma etapa do canvas pelo atributo `etapa` do evento "Negócio Mudou de Etapa", sempre pelo ID, nunca pelo rótulo.

## 3. Versão de testes local

O que ela tem:

- conta "ROI Ventures (teste local)";
- **12 workspaces**:
  - um por negócio: E-cont, IniciAmazon · Perpétuo, Consultoria & Mentoria, ROI Club, Sessão Estratégica, Lançamentos, North, Importação · Stock e Loot;
  - **Comercial · Pré Vendas e Closer's**: leads de aquisição trabalhados pelo comercial para Mentoria, Consultoria, Loot, North, Método ROI e similares;
  - **Compras · todas as ofertas**: recebe os conectores de vendas de todos os negócios;
  - **Reembolsos e suporte**: os fluxos transversais de reembolso;
- **57 conectores em modo sombra** (cada um com a lista dos fluxos n8n que o originaram) e **22 templates em rascunho**. O HubSpot só entra onde há pipeline: E-cont (717654561), Importação (894137220) e Comercial (932401505 Pré Vendas e 932402477 Closer's), com o filtro de pipeline no conector;
- **3 canvases de exemplo**, com etapas do HubSpot sempre por ID:
  - Jornada E-cont: levantou a mão → Em Negociação → compra;
  - Perpétuo: PIX → compra → acesso, e compra → reembolso;
  - Comercial: novo lead → passagem de bastão → reunião realizada → proposta → ganho.

Em produção, o workspace Compras recebe uma cópia dos eventos de venda que também vão para o workspace do negócio (o mesmo webhook alimenta dois conectores). Isso dobra a ingestão de vendas, que é pouca (cerca de 800 compras/mês). Se crescer, a saída é uma visão entre workspaces da mesma conta, sem cópia.

**Nenhuma pessoa e nenhum evento:** nada de dado real sai da ROI.

Como rodar (qualquer Postgres 15+ local, sem Docker):

```bash
PGURL=postgres://postgres@127.0.0.1:5432 npm run instancia:local -- roi
```

O script recria o banco `funnel_traffic_roi_teste`, aplica as migrations, o seed padrão e o seed da instância (`supabase/instancias/roi/seed.sql`, gerado), e roda `supabase/instancias/roi/teste.sql`. O teste confere a estrutura (ManyChat ausente, HubSpot só com pipeline, Compras agregando todas as vendas) e o isolamento: o dono da ROI vê só os 12 workspaces dele, e a outra conta não vê nenhum. Tudo fica no schema `funnel_traffic`; `public` fica vazio.

Arquivos:

| Arquivo | Papel |
| --- | --- |
| `regras-mapa.json` | Regras fluxo → plataforma, conector, papel, eventos e negócio (configuração, editável) |
| `instancia.json` | Negócio → workspace, conectores que vêm do Supabase (HubSpot), canvases de exemplo |
| `mapa-n8n.json`, `mapa-n8n.md` | Resultado gerado; não editar à mão |
| `dados/n8n-fluxos-2026-10-14.json` | Exportação limpa do n8n |
| `scripts/mapa-instancia.mjs`, `scripts/seed-instancia.mjs`, `scripts/instancia-local.sh` | Genéricos: servem para qualquer cliente novo |

## 4. Como atualizar o mapa

1. Abrir o Claude com a conta `raphael@roiventures.com.br` (regra da ROI).
2. Pelo MCP n8n RoiVentures, `search_workflows` com `limit 200`, em `updatedAt:desc` e `updatedAt:asc`, até cobrir o total. Salvar em `dados/n8n-fluxos-<data>.json` só com id, nome, ativo, datas e tags.
3. Rodar:
   ```bash
   node scripts/mapa-instancia.mjs --fluxos docs/instancias/roi/dados/n8n-fluxos-<data>.json \
     --regras docs/instancias/roi/regras-mapa.json \
     --inventario ~/GitHub/ROI/trackeamento-e-jornadas-roi/data/inventario-n8n.json \
     --saida docs/instancias/roi
   npm run instancia:local -- roi
   ```
4. Fluxo novo sem classificação: acrescentar uma regra em `regras-mapa.json`, nunca no script.

## 5. Decisões e pendências

Respostas do dono em 14/10/2026:

| # | Pergunta | Resposta | Aplicado |
| --- | --- | --- | --- |
| R-01 | Workspaces | Cada negócio tem o próprio workspace (ou projeto dentro dele) | 9 workspaces de negócio mantidos |
| R-02 | Fluxos transversais | ManyChat fica para depois; um workspace de reembolso e um de compras (IniciAmazon, Mentoria, Método ROI e afins) | `roi-reembolsos` e `roi-compras`; ManyChat com papel `adiado` |
| R-03 | `[LN] Recuperação` | Ver depois | **Adiado** (continua sem classificação) |
| R-04 | Pré Vendas e Closer's | Atendem leads de aquisição e marketing; o comercial oferece Mentoria, Consultoria, Loot, North, Método ROI ou similar | Workspace `roi-comercial` com os dois pipelines e canvas próprio |
| R-05 | CPF | Aceito, com e-mail na frente | Cascata: ID externo → e-mail → **documento (CPF)** → telefone → cookie. CPF guardado como HMAC, nunca em claro |
| R-06 | Reescrita do banco | Aprovada | Tudo no schema `funnel_traffic` (migration, testes, seed, cliente do front, `config.toml`). Testes de banco, typecheck, testes do front e build verdes |
| R-07 | MCP do `roi-apps` | O dono vai conectar | Aguardando |

### Próximo passo: aplicar no `roi-apps`

Quando o MCP estiver conectado (sessão aberta em `~/GitHub/roi-apps`, conta `raphael@roiventures.com.br`):

1. Listar os schemas e tabelas do projeto e conferir que `funnel_traffic` não existe.
2. Pedir o "pode" final e aplicar `20261005041500_fundacao.sql` com `apply_migration`. É escrita em produção e não tem preview.
3. Pôr `funnel_traffic` em "Exposed schemas" da API do projeto (configuração do painel, não da migration).
4. Rodar os advisors de segurança e performance.
5. Registrar a migration no ledger da ROI e no `docs/PENDENTE_BANCO.md`.
6. A estrutura de teste (conta, workspaces, conectores) **não** vai para produção pelo seed: em produção, o dono cria tudo por `workspace_criar()`.

### Alertas encontrados no caminho (não corrigidos)

| Alerta | Onde | Sugestão |
| --- | --- | --- |
| **RLS desligada** em `dash.leadscore_faixas` (advisor crítico do Supabase) | `qevnfgopjupsmwvflcza` | `alter table dash.leadscore_faixas enable row level security;` + policy de leitura para quem usa o Dash. Não apliquei: sem policy, a tela para de ler |
| `public.integracoes_externas` tem colunas `push_token` e `pull_api_key` em texto (0 linhas hoje) | `qevnfgopjupsmwvflcza` | Guardar só hash ou nome de segredo, como `conectores.secret_name` já faz |
| `public.gerador_sale_events`: 2.893 eventos `reembolsada` entre 10/09 e 07/10, contra 301 `compra` no ano | `qevnfgopjupsmwvflcza` | Conferir se é carga retroativa ou sinal de problema antes de usar como fonte |
| 79 divergências altas nos fluxos ativos inventariados (inclui credencial em texto em nós HTTP) | n8n | Já registradas no `trackeamento-e-jornadas-roi` (doc 06); não repetir aqui |
