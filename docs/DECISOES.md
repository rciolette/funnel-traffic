# Decisões — Funnel Traffic

Formato: data · decisão · motivo. Nunca apagar; uma decisão revertida ganha nova linha.

- 2026-10-04 · Nome do produto: Funnel Traffic · Escolha do dono; domínio será comprado depois.
- 2026-10-04 · Produto da RC Digitais com infra própria (repo e Supabase novos); ROI Ventures, Dose Saudável e demais são workspaces clientes · Isolamento de dados e contas é regra do dono.
- 2026-10-04 · Versão gratuita de testes, sem cobrança · Billing fica para versão futura; nada no código depende de plano.
- 2026-10-04 · Um único dono cria contas e workspaces, um por projeto; primeiro workspace "My Workspace" · Operação solo no início; papéis ficam no banco para o futuro.
- 2026-10-04 · Nomes de workspace, canvas, conector, etapa e evento são do usuário; só nomes reservados `__x__` são fixos · Produto genérico, sem nome de empresa embutido.
- 2026-10-04 · Multi-tenant e papéis (dono, admin, editor, visualizador, link de leitura) desde a migration 0001, via RLS · Refazer RLS depois custa mais.
- 2026-10-04 · Conector = configuração (mapper JSON declarativo); n8n é o conector universal; webhook genérico para plataforma sem template · Amplitude sem deploy.
- 2026-10-04 · Catálogo completo de conectores e pixel `track.js` já na Fase 1, self-service pela tela de Integrações · O dono conecta cada projeto sozinho.
- 2026-10-04 · Integração nativa OAuth (HubSpot, HighLevel) só na Fase 3; na Fase 1 entram por webhook de workflow · Webhook cobre o MVP.
- 2026-10-04 · Meta/Google Ads fora de escopo até atribuição de custo entrar · Não são eventos de pessoa.
- 2026-10-04 · GitHub e Miro não são conectores · Não geram eventos de jornada; Miro pode receber exportação do canvas na Fase 3.
- 2026-10-04 · Contagem por pessoa única; dinheiro em centavos inteiros com moeda; um evento por item; `idExterno` obrigatório para dedupe · Convenções validadas no benchmark Funnelytics.
- 2026-10-04 · Postgres puro no motor até 10 M eventos/mês por workspace; ClickHouse só se p95 > 2 s · Volume atual cabe.
- 2026-10-04 · Stack padrão Fábrica de Apps: Vite + React 18 + TS + shadcn/ui + Tailwind + React Query + react-router, React Flow, Supabase, Cloudflare Workers, vitest + Playwright · Padrão do dono; trocar só com motivo aqui.
- 2026-10-05 · Scaffold com React 19, Tailwind v4 e componentes shadcn/ui escritos no repo (sem CLI) · Versões atuais do Vite; o CLI do shadcn não era alcançável no ambiente, então os componentes vivem em src/components/ui e são editáveis.
- 2026-10-05 · Este repositório é também o modelo de app da RC Digitais (`docs/MODELO.md`, `scripts/novo-app.sh`) · Um só lugar para evoluir o padrão.
- 2026-10-05 · Dedupe de eventos em `eventos_chaves` (PK workspace + conector + idExterno + evento), fora da tabela particionada · Unique em tabela particionada exigiria incluir `ocorrido_em` e deixaria passar reenvio com outra data.
- 2026-10-05 · Partição mensal de `eventos` criada sob demanda (`eventos_garantir_particao`), sem partição default; 2026–2027 já criadas · Importação de histórico antigo não falha nem cai num balde default que trava novas partições.
- 2026-10-05 · Conector em modo sombra grava em `eventos_sombra`, nunca em `eventos` · O motor não precisa filtrar sombra; ativar não arrasta eventos de teste para o canvas.
- 2026-10-05 · Sem policy de DELETE em tabela de dados; remoção é `removida_em`/`arquivado_em` · Regra "nada de histórico apagado" garantida no banco.
- 2026-10-05 · Dado pessoal (pessoas, identidades, eventos, ingest_bruto) só para admin+ via RLS; editor e visualizador leem por funções do motor (agregado ou mascarado) · Papel conferido no banco, nunca no front.
- 2026-10-05 · Cadastro público desligado no Auth (`enable_signup = false`); workspace nasce por `workspace_criar()` · Só o dono cria contas.
- 2026-10-05 · Testes de banco rodam em Postgres puro com esqueleto do Supabase (`supabase/testes/00_stub_supabase.sql`, `npm run test:banco`) e no CI · Máquina do dono não tem Docker; o mesmo script roda no GitHub Actions.
