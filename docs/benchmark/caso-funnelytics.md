# Caso Funnelytics — como o canvas calcula e mostra os números

Engenharia reversa parcial, 14/10/2026. Objetivo: o motor do Funnel Traffic (`jornada_calcular`) chegar aos mesmos números que o Funnelytics com os mesmos dados.

> **Estado: incompleto.** Não havia conta para logar, então os quatro passos ao vivo (canvas, período e filtro, painel da etapa e Explorer, pixel) não foram feitos. Este documento traz só o que dá para afirmar sem login, cada ponto com o nível de evidência. A seção 6 lista o que falta e como conseguir.

Níveis de evidência usados:

- **[REA]** observado pelo REA no navegador ou na análise estática que ele fez.
- **[Leitura]** li nos arquivos que o REA exportou.
- **[Doc]** documentação pública do Funnelytics, já resumida em `docs/benchmark-funnelytics.md` (03/10/2026). É o que eles dizem, não o que observamos.
- **[Não verificado]** hipótese, sem evidência ainda.

Nenhum dado de conta aparece aqui: não houve login. Chaves públicas que estão no bundle (PostHog, reCAPTCHA, IDs de cliente OAuth) foram omitidas de propósito.

## 1. Como foi feito

| Item | Valor |
| --- | --- |
| Navegador | Chrome 155.0.8059.79, perfil temporário, `--remote-debugging-port=9222` só em 127.0.0.1 |
| Ferramenta | REA `rea-agents` 6.5.0 (npm oficial, mesma versão do repositório local `rea-main`), pela linha de comando, uma análise por vez, saída em JSON |
| Página observada | `https://app.funnelytics.io/login` (só a tela pública) |
| Tráfego gerado contra o Funnelytics | Só o que a própria página de login carregou. Nenhuma chamada à API deles |

Comandos, na ordem:

1. `rea list-browser-targets` → um alvo `page`, `https://app.funnelytics.io/login`.
2. `rea analyze-web-bundle --fetch-source-maps --observation-ms 3000` → `01-bundle-login.json`.
3. `rea inspect-web-page --include-script-sources --include-storage-keys --observation-ms 2000` → `02-inspect-login.json`.
4. `rea export-web-scripts` → 12 arquivos `.js` + `manifest.json`.
5. `rea analyze-javascript-application` sobre os scripts exportados → `04-js-app.json`.

Os arquivos ficaram na pasta temporária da sessão e não foram versionados (contêm código do Funnelytics, que não copiamos para o repositório).

### O que foi bloqueado no caminho

- **Pedaços do app carregados sob demanda.** O app principal só carrega o código do canvas depois do login. Baixar esses arquivos direto de `/assets/` foi bloqueado pela política de permissões desta sessão. A leitura mais funda do código exportado também foi bloqueada. Parei nos dois pontos.
- **Pixel `track-v3.js`.** Sem workspace não há página de teste com o pixel instalado, e não baixei o arquivo à parte.

## 2. Evidência do REA

### 2.1 Bundle da tela de login [REA]

`analyze-web-bundle`, evidência `01-bundle-login.json`:

- 14 scripts observados e 14 analisados, 0 falhas de parse, 981.353 nós de AST.
- `source_maps.status = "unavailable"`, `requested = 0`: **nenhum script declara mapa de código-fonte.** Não há código original para ler, só código minificado.
- Inferências: `vendor_fingerprint = React` (média), `bundle_runtime = Vite` (média).
- Grafo de pedaços: 14 nós e 72 arestas.

Rotas do app principal (mecanismo `property:path`, script `scr_91e1c502…`, linha 10, colunas 139152–142277):

`/dashboard`, `/canvases`, `/$canvasId`, `/share/$canvasId`, `/monitor`, `/targets`, `/create-kpi`, `/edit-kpi/$kpiId`, `/integrations`, `/integrations/connect/hubspot`, `/insights-log`, `/collaborate`, `/settings`, `/workspaces/overview`, `/workspaces/create`, `/workspaces/$workspaceId`, `/library`, `/import`, `/users`, `/permission-managment`, `/oauth/{hubspot,highlevel,google_ads,facebook_ads}`, além de login, cadastro e planos.

Chamadas de API candidatas (61, por `call:x.get/post/...`, mesmo script). As que importam para o motor:

| Endpoint | Método | O que sugere |
| --- | --- | --- |
| `/projects`, `/projects/update-workspaces`, `/projects/lock-selected` | GET/POST | "project" é o nome interno de workspace |
| `/project-domains` | GET/POST/DELETE | domínios permitidos para o pixel entre domínios |
| `/project-ips`, `/project-ips/my-ip` | GET/POST/DELETE | lista de IPs bloqueados |
| `/monitoring-reports` | GET/POST/DELETE | relatórios do Monitor |
| `/usage-tracking` | GET | consumo do plano (pessoas rastreadas) |
| `/email-notification/script-install` | POST | aviso de instalação do pixel |
| `/hubspot-integration/*`, `/highlevel-integration/*`, `/facebook-ads-integration/*`, `/integrations/google-ads/*` | vários | conectores nativos |

**Nenhum endpoint de cálculo do canvas aparece no código da tela de login.** Eles ficam nos pedaços carregados depois do login.

### 2.2 Análise estática da aplicação [REA]

`analyze-javascript-application`, evidência `04-js-app.json`: 12 arquivos, 14 módulos, 756 nós e 1.322 arestas no grafo da aplicação, 1.282 achados, 0 falhas de parse.

Os nomes dos pedaços que o índice referencia (110 no total) mostram onde a lógica mora. Esses arquivos não foram lidos:

- `Canvas-*.js`, `_canvasId-*.js` (×2), `canvases-*.js`, `useCreateCanvas-*.js`
- `useTrafficExplorerPayload-*.js`: monta o pedido do Explorer
- `share-canvas.api-*.js`, `useFetchCanvasShareLink-*.js`
- `monitor-*.js`, `monitoring-api-*.js`
- `TrackingScript-*.js`, `MonitoringScriptInstall-*.js`: tela de instalação do pixel

## 3. Leitura por conta própria nos arquivos exportados [Leitura]

Arquivo `assets/index-zdbpg-G0.js` (263 KB), exportado pelo REA.

**Quatro APIs separadas**, cada uma com um cliente axios próprio e `Authorization: Bearer <access_token>` injetado num interceptor:

| Variável de build | Host | Papel provável |
| --- | --- | --- |
| `VITE_DASHBOARD_API_URL` | `dashboard-api.funnelytics.io` | contas, workspaces, integrações (os endpoints da seção 2.1) |
| `VITE_MODERN_DASHBOARD_API_URL` | `new-dashboard-api.funnelytics.io/api/v1` | versão nova da mesma API |
| `VITE_ANALYTICS_API_URL` | `analytics-api.funnelytics.io` | **números: pessoas, conversões, Explorer** |
| `VITE_AI_AGENT_API` | `qa-ai-agent-api.funnelytics.io` | Vision AI |

**O canvas é outro app.** `VITE_NEW_CANVAS_URL = https://canvas.funnelytics.io`, e há um link para `canvas.funnelytics.io/tutorial`. O editor de canvas roda num front separado do painel.

Outros pontos: PostHog e Intercom no app (`VITE_POSTHOG_*`, `VITE_INTERCOM_APP_ID`); erros da API vêm no formato `{ detail }` (o interceptor copia `detail` para `message`), padrão de FastAPI/DRF. O backend ser Python é **[Não verificado]**.

**Consequência para nós:** o cálculo acontece no servidor (`analytics-api`), não no navegador. Mesmo com o código do canvas em mãos, veríamos o **pedido** (canvas, período, filtros) e a **resposta** (contagens), não a consulta. A regra de contagem só se confirma pelo comportamento: montar um caso de teste, mandar eventos conhecidos e comparar os números.

## 4. Respostas às perguntas

| Pergunta | Resposta | Evidência |
| --- | --- | --- |
| Como conta pessoas por etapa | Pessoa única, não sessão nem visita. O "ID de sessão" do pixel (`_fs`) é na prática o ID da pessoa (cookie de 1ª parte até 2038) | [Doc] |
| Como calcula conversão | Pessoas na etapa de destino ÷ pessoas na de origem, por conexão. No **Funnel Mode** só conta quem percorreu a cadeia inteira | [Doc]. Fórmula exata e arredondamento: [Não verificado] |
| Direta x pular | Direta: B é a **próxima** ação da pessoa depois de A. Pular: B acontece em algum momento depois de A | [Doc] |
| Janela de tempo | Pular usa o **período selecionado**, sem janela própria. A *Contribution Window* (X dias antes ou depois) só existe com filtro de etapa | [Doc]. Se B precisa cair dentro do período ou só A: [Não verificado] |
| O que conta como "próxima ação" | Qualquer passo rastreado (página, clique, scroll?) ou só os do canvas | [Não verificado]. É o ponto que mais muda o número da linha direta |
| Identidade | Cookie `_fs` + parâmetro `?_fs=` entre domínios + campo oculto em formulários + e-mail. Webhook casa por `session` ou `email`; sem os dois, cada evento vira uma pessoa nova. Telefone e ID externo não aparecem | [Doc] |
| Junção anônimo → lead | Evento com `email` amarra o histórico anônimo do mesmo `_fs`. Pixel captura e-mail digitado cerca de 1 s depois (com hash SHA-256 opcional). Se a fusão reescreve números passados: [Não verificado] | [Doc] |
| O que o pixel envia | `track-v3.funnelytics.io`: `/sessions`, `/steps`, `/events/trigger`. Eventos automáticos: Link Click, Button Click, Scroll (10/25/50/75/90 %), Form Completed, Video View. Campos e frequência exatos | [Doc] / [Não verificado] |
| Consentimento | Nenhuma integração com gestor de consentimento. Anonimização de formulários ligada por padrão | [Doc] |
| Como o canvas é salvo | Em outro app (`canvas.funnelytics.io`). Formato do JSON | [Leitura] / [Não verificado] |
| Chamadas que buscam os números | Vão para `analytics-api.funnelytics.io` com Bearer. Pedido e resposta | [Leitura] / [Não verificado] |
| Atraso evento → canvas | Atualização manual ("Refresh Analytics"). Webhook e Zapier: cerca de 10–11 min | [Doc] |

## 5. Comparação com o Funnel Traffic e o que muda em `jornada_calcular`

| Ponto | Funnelytics | Funnel Traffic hoje (`CLAUDE.md` + migration `fundacao`) | Ação no motor |
| --- | --- | --- | --- |
| Unidade de contagem | Pessoa única | Pessoa única (`pessoa_id`) | Igual. Contar `pessoa_id` já resolvido pela fusão (`fundida_em`) |
| Conversão por conexão | Destino ÷ origem, cada linha independente | `taxaConversao` em `src/lib/regras/conversao.ts` | Igual. Ver o arredondamento quando houver dado real |
| Modo funil (cadeia inteira) | Existe (Funnel Mode), avisa sobre loops | Não previsto | **Adicionar** parâmetro `modo` (`mapa` \| `funil`) em `jornada_calcular`; no modo funil, a contagem de cada etapa exige ter passado por todas as anteriores conectadas, com proteção contra ciclo |
| Direta | Próxima ação da pessoa | `conexoes.tipo = 'direta'` = "próximo evento" | **Definir** em `docs/DECISOES.md` o que é "próximo evento": todos os eventos da pessoa ou só os que casam com alguma etapa do canvas. Escolha provisória: todos os eventos, exceto ruído automático (scroll, clique), listado em tabela de configuração |
| Pular | Qualquer momento depois, dentro do período | `tipo = 'pular'` + `janela_dias` (1–365, opcional) | `janela_dias` nulo = período selecionado, igual ao Funnelytics. Preenchido = janela extra, como a Contribution Window |
| Período | Filtra pelo momento da etapa | Não definido | **Decidir e testar:** A dentro do período, e B dentro do período ou da janela. Escrever no teste de contrato |
| Identidade | Cookie + e-mail | idExterno → e-mail → telefone E.164 → cookie → anônimo | Nosso modelo cobre mais. Para comparar números, rodar o teste também só com cookie + e-mail |
| Fusão anônimo → lead | Amarra o histórico do mesmo cookie | `pessoa_fusoes` reversível | Igual na ideia. O motor deve recalcular com a fusão aplicada ao passado, não só dali em diante |
| Evento sem identificador | Vira pessoa nova | Pessoa anônima | Igual |
| Dedupe | Rejeita requisição duplicada; `dateTime` torna o reenvio único | `idExterno` obrigatório + `eventos_chaves` | Nosso é mais forte. Manter |
| Compra | `__commerce_action__`, um evento por item, centavos | `__compra__`, um evento por item, centavos | Igual |
| Atualização | Manual; servidor ~11 min | ≤ 60 s | Manter a meta de 60 s. O atraso deles parece ser espera para casar identidade; o nosso worker deve reprocessar etapas quando chega uma fusão tardia |
| Onde calcula | API própria de analytics, separada do painel | Função SQL no Postgres | Igual no conceito. `jornada_calcular` é a "analytics-api" |
| Consentimento | Não tem | Previsto na Fase 2 | Diferencial nosso. O motor não conta eventos de pixel sem consentimento quando o workspace exigir |

### Casos que o teste de contrato precisa cobrir (com os dados do protótipo)

1. Pessoa faz A → C → B: conta em A→B **pular**, não em A→B **direta**.
2. Pessoa faz A → scroll → B: direta conta ou não, conforme a decisão sobre ruído.
3. Pessoa faz A duas vezes e B uma: conta 1 em A, 1 em B, conversão 100 %.
4. A no último dia do período e B no dia seguinte: comportamento definido pela regra de período.
5. Visitante anônimo faz A; depois o e-mail aparece e faz B: conta 1 pessoa em A e B, depois da fusão.
6. Funil com loop (B → A): o modo funil não trava e avisa.

## 6. O que falta e como conseguir

| Lacuna | Como fechar |
| --- | --- |
| Pedido e resposta da `analytics-api`, formato do canvas salvo, latência real | Conta com acesso ao canvas. Raphael assina o teste de 14 dias do Performance Pro (cobrança mensal, cancelar antes do fim), loga no Chrome de depuração e refazemos os 4 passos com o REA `inspect-web-page --include-json-body-shapes` (só formatos, sem valores) |
| Código do canvas (`canvas.funnelytics.io`) e do Explorer | Os pedaços carregam sozinhos quando a tela é usada logada. O REA captura do navegador |
| Pixel: campos, frequência, consentimento | Com o workspace de teste, instalar o pixel numa página nossa, disparar eventos e observar com o REA |
| Regra de "próxima ação" e de período | Só por comportamento: mandar eventos conhecidos por webhook e comparar com o canvas |
| Alternativa sem conta | Um link público de canvas somente leitura (`/share/$canvasId`). Não achei nenhum indexado; se alguém do seu círculo usa Funnelytics, um link desses permite observar a tela de números sem login |

## Fontes

- Evidências do REA (arquivos locais da sessão): `00-targets.json`, `01-bundle-login.json`, `02-inspect-login.json`, `03-export.json`, `04-js-app.json`.
- `docs/benchmark-funnelytics.md` (central de ajuda e hub do Funnelytics, 03/10/2026).
- Central de ajuda: [Share links](https://help.funnelytics.io/en/articles/15826799-share-links), [Canvas overview](https://help.funnelytics.io/en/articles/15805638-canvas-overview).
