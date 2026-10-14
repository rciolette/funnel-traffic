# Ferramentas para construir e operar o Funnel Traffic

O que usar em cada parte do trabalho: skills do Claude, conectores (MCP), ferramentas de linha de comando e repositórios abertos de referência. Atualizado em 14/10/2026.

Regra do `CLAUDE.md`: nenhum MCP ou credencial de outra empresa entra no produto. Os conectores marcados **ROI** servem só para a instância ROI Ventures, e só para leitura sem pedido explícito.

## 1. Skills do Claude

| Skill | Para que serve aqui | Quando |
| --- | --- | --- |
| `fabrica-de-apps` | Padrão de stack, estrutura, regras e fluxo preview → main. Este repo já segue | Sempre; fonte das regras de trabalho |
| `integracoes-kit` | Motor de conectores por modelo JSON (receber, mapear, enviar), testado no Gerador de Links. Traz `core/` (entrada, template, segurança, testar), adaptador Supabase (Edge Functions + Vault + pg_cron) e modelos Assiny, Shopify, HubSpot, Meta CAPI, Meta Lead Ads, Slack | Bloco de ingestão e conectores; webhooks de saída na Fase 3 |
| `product-tracking-skills:*` | Plano de rastreamento (nomes de evento e atributo), guia de implementação, auditoria | Definir os eventos padrão do pixel e os templates |
| `hotwebinar`, `anthropic-skills:webinario-operacao` | Eventos de webinário (inscrição, presença, % assistido, clique na oferta) | Template HotWebinar e primeiro canvas real |
| `anthropic-skills:conciliacao-comercial-roi` | Cruzar Assiny, Gerador de Links e HubSpot | Validar números do motor contra vendas reais (instância ROI) |
| `ui-ux-pro-max`, `ui-styling`, `design-system`, `brand` | Tokens de tema, componentes shadcn, telas | Canvas, Integrações, tema white label |
| `dataviz` | Gráficos de tendência, widgets e Monitor | Painel da etapa, Monitor |
| `artifact-design` | Protótipos clicáveis para aprovar tela antes de codar | Telas novas (Integrações, superadmin) |
| `engineering:system-design`, `engineering:architecture`, `engineering:testing-strategy` | Revisão de arquitetura e plano de testes | Antes do motor e do white label |
| `data:sql-queries`, `data:validate-data` | SQL do motor e checagem de números | `jornada_calcular` e teste de contrato |
| `security-review`, `code-review` | Revisão de RLS, segredos e correção | Antes de cada merge em `main` |
| `run` | Subir o app e ver a mudança funcionando (Playwright) | Validação de tela |
| `skill-creator` | Criar a skill `funnel-traffic-conector`: payload real → mapper → teste → template | Depois do 3º template, para padronizar |
| `anthropic-skills:docs` | PRD vivo no Claude Docs | Atualizar o PRD |
| `customer-support:kb-article`, `operations:runbook` | Central de ajuda por conector e runbook de operação | Fase 2 |

## 2. Conectores (MCP) desta conta

| Conector | Dono | Uso | Estado |
| --- | --- | --- | --- |
| Supabase (`supabase-link-generator`) | **ROI** | Migrations, SQL, logs e advisors da instância ROI | Conectado. Escrever só com pedido |
| Supabase da RC Digitais | RC | Instância compartilhada | **Falta conectar** (projeto ainda não criado) |
| n8n RoiVentures | **ROI** | Workflows que enviam evento canônico na instância ROI | Conectado |
| n8n RC (`mecp-n8n-rc-teste`) | RC | Conector universal da instância RC | Precisa autorizar |
| GitHub (claude.ai) | RC | PRs, issues | Precisa autorizar; até lá, `gh` CLI |
| Claude Docs | RC | PRD vivo | Conectado |
| Claude in Chrome | — | Testar a tela e o pixel no navegador | Disponível |
| HubSpot | **ROI** | Ler propriedades e eventos reais para o template HubSpot | Conectado, só leitura |
| SendPulse (`sendpulse-rc`) | RC | Envio de e-mail de login com marca (Send Email Hook) e alertas | Conectado |
| Slack | **ROI** | Saída de alertas (Fase 2) | Conectado |
| Hostinger (DNS, domínios) | RC | Comprar o domínio da plataforma, criar CNAMEs | Conectado |
| MemberKit | **ROI** | Payload real do template MemberKit | Conectado |
| Miro | — | Exportar canvas (Fase 3) | Conectado |
| Cloudflare | RC | Workers, KV, Custom Hostnames | **Sem MCP**; usar `wrangler` |

## 3. Ferramentas de linha de comando

| Ferramenta | Uso |
| --- | --- |
| `supabase` CLI | Migrations, Edge Functions e tipos. Docker não está instalado: testes de banco rodam em Postgres puro (`npm run test:banco`) |
| `wrangler` | Deploy do Worker (SPA + `track.js` + domínios de cliente), KV, secrets |
| `gh` | Branch `preview`, PR, CI |
| Playwright | e2e (`npm run test:e2e`) e teste do pixel numa página de exemplo |
| REA (`rea-agents`) | Engenharia reversa passiva (bundle, rede) de produtos de referência. Usado no caso Funnelytics |
| `psql` / Postgres 17 local | Teste de contrato do motor |

## 4. Repositórios abertos de referência

Para estudar a solução, não para copiar código para dentro do produto sem checar a licença.

| Repositório | O que aproveitar |
| --- | --- |
| [xyflow/xyflow](https://github.com/xyflow/xyflow) (React Flow) | O canvas. Já está na stack |
| [jsonata-js/jsonata](https://github.com/jsonata-js/jsonata) | Expressões do mapper (`docs/conectores/CATALOGO.md`). Alternativa: o motor de template do `integracoes-kit` (ver seção 5) |
| [PostHog/posthog](https://github.com/PostHog/posthog) | Semântica de funil (strict, sequential, janela), `identify`/`alias` e fusão de pessoas, ingestão em lote |
| [segmentio/analytics-next](https://github.com/segmentio/analytics-next) e a especificação Segment (track, identify, page) | Formato do pixel e nomes de método conhecidos pelo mercado |
| [jitsucom/jitsu](https://github.com/jitsucom/jitsu) e [rudderlabs/rudder-server](https://github.com/rudderlabs/rudder-server) | Coleta de eventos, fila e roteamento |
| [plausible/analytics](https://github.com/plausible/analytics) e [umami-software/umami](https://github.com/umami-software/umami) | Pixel leve; coleta com e sem cookie |
| [orestbida/cookieconsent](https://github.com/orestbida/cookieconsent) | Banner de consentimento (LGPD) no pixel |
| [tembo-io/pgmq](https://github.com/tembo-io/pgmq) | Fila do worker em Postgres (Supabase Queues usa pgmq) |
| [usebasejump/basejump](https://github.com/usebasejump/basejump) | Contas e equipes multi-tenant no Supabase: convites e papéis por conta |
| [n8n-io/n8n-nodes-starter](https://github.com/n8n-io/n8n-nodes-starter) | Nó oficial "Funnel Traffic" para n8n (enviar evento canônico sem montar HTTP) |
| [DevinVinson/WordPress-Plugin-Boilerplate](https://github.com/DevinVinson/WordPress-Plugin-Boilerplate) | Plugin WordPress do pixel |

## 5. Escolha em aberto: motor de mapper

| Opção | A favor | Contra |
| --- | --- | --- |
| JSONata (como no `CATALOGO.md`) | Linguagem pública e documentada; o usuário escreve expressões | Mais uma dependência na Edge Function; expressões livres pedem limite de tempo |
| Template do `integracoes-kit` | Já roda em produção; vem com testes, segurança (token hash, Vault) e modo sombra | Formato próprio; precisa adaptar ao evento canônico (`evento`, `pessoa`, `atributos`) |

Recomendação: **reusar o `integracoes-kit`** para recepção, segurança, sombra e testes, e aceitar JSONata só no campo de transformação. Decidir e registrar em `docs/DECISOES.md` antes do bloco de ingestão.
