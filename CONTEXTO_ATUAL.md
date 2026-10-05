# Contexto atual — Funnel Traffic

Atualizar ao fim de cada sessão. Quem abre um chat lê isto primeiro, depois `CLAUDE.md`.

## Estado (05/10/2026)

- Em andamento: construção do MVP (Fase 0 + Fase 1) em 9 blocos, alvo instância ROI Ventures em `funnel-traffic.roiventures.com.br`.
- **Bloco 1 — Banco: feito no repositório.** Migration `supabase/migrations/20261005041500_fundacao.sql` (24 tabelas, RLS em todas, papéis, partição de eventos, auditoria), seed local, testes de RLS em `supabase/testes/`, job `banco` no CI. `npm run test:banco` passa em Postgres 17 local.
- Não aplicado em nenhum Supabase remoto (projeto ainda não existe).
- Scaffold do front segue em modo demo.

## Próximo passo

1. Resposta do dono sobre onde criar o projeto Supabase (ver Pendências).
2. Bloco 2 — Motor SQL + teste de contrato com `NODES`/`EDGES` do protótipo.

## Pendências do dono

- Infra da instância: o pedido de 05/10 manda criar o Supabase na organização ROI e publicar em roiventures.com.br; `docs/DECISOES.md` (04/10) diz infra própria da RC Digitais. Confirmar e registrar a decisão.
- Advisors de segurança só rodam com o projeto remoto criado.
- Docker não está instalado: `supabase db reset` local não roda; os testes usam Postgres puro (`npm run test:banco`).
- Fluxo n8n do lançamento vigente para o Bloco 9 (`docs/lancamentos/` não existe).
