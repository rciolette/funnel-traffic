# Contexto atual — Funnel Traffic

Atualizar ao fim de cada sessão. Quem abre um chat lê isto primeiro, depois `CLAUDE.md`.

## Estado (05/10/2026)

- Fase 0 — Fundação. Scaffold completo (modo demo): login, shell, 5 páginas, canvas React Flow de exemplo, ErrorBoundary 3 níveis, regras puras com teste, CI, Worker. `npm run typecheck`, `npm test` e `npm run test:e2e` passam.
- PRD aprovado pelo dono em 04/10/2026 (Claude Docs). Protótipo visual em `docs/prototipo/`.
- Decisões fechadas em `docs/DECISOES.md`. Catálogo de conectores em `docs/conectores/CATALOGO.md`.

## Próximo passo

1. Configurar remoto GitHub e subir `main` e `preview`.
2. Projeto Supabase próprio do produto (criar na conta RC Digitais; registrar id em `docs/DECISOES.md`).
3. Migration 0001: contas, workspaces, workspace_membros, conectores, conector_templates, ingest_bruto, pessoas, identidades, eventos — com RLS.
4. Edge Function `ingest` (grava bruto, responde 202) + worker (mapper, dedupe, identidade).
5. Função `jornada_calcular` + teste de contrato com os dados do protótipo.

## Pendências do dono

- URL do remoto GitHub (`git remote add origin ...`).
- Criar projeto Supabase do produto.
- Ordem dos projetos a conectar (define a ordem dos templates de mapper).
- Comprar domínio.
