# Contexto atual — Funnel Traffic

Atualizar ao fim de cada sessão. Quem abre um chat lê isto primeiro, depois `CLAUDE.md`.

## Estado (14/10/2026)

- Em andamento: construção do MVP (Fase 0 + Fase 1) em 9 blocos, alvo instância ROI Ventures em `funnel-traffic.roiventures.com.br`.
- **Bloco 1 — Banco: feito no repositório.** Migration `supabase/migrations/20261005041500_fundacao.sql` (24 tabelas, RLS em todas, papéis, partição de eventos, auditoria), seed local, testes de RLS em `supabase/testes/`, job `banco` no CI. `npm run test:banco` passa em Postgres 17 local.
- Não aplicado em nenhum Supabase remoto (projeto ainda não existe).
- Scaffold do front segue em modo demo.
- 14/10/2026: roteiro completo (`docs/ROTEIRO.md`), especificação do motor (`docs/MOTOR.md`), white label multi-cliente (`docs/WHITE_LABEL.md`), guia de uso (`docs/USO.md`) e ferramentas (`docs/FERRAMENTAS.md`).
- 14/10/2026: engenharia reversa parcial do Funnelytics em `docs/benchmark/caso-funnelytics.md` (sem login; seção 5 lista o que muda em `jornada_calcular`, seção 6 o que falta).

## Próximo passo

1. Resposta do dono sobre onde criar o projeto Supabase (ver Pendências).
2. Ordem dos blocos 2 a 9 em `docs/ROTEIRO.md` §3–4. Bloco 2 — Motor SQL + teste de contrato com `NODES`/`EDGES` do protótipo. Antes, decidir em `docs/DECISOES.md`: o que é "próximo evento" na conexão direta, regra de período para A e B, e se haverá modo funil (ver `docs/benchmark/caso-funnelytics.md`, seção 5).

## Pendências do dono

- Infra da instância: o pedido de 05/10 manda criar o Supabase na organização ROI e publicar em roiventures.com.br; `docs/DECISOES.md` (04/10) diz infra própria da RC Digitais. Confirmar e registrar a decisão.
- Advisors de segurança só rodam com o projeto remoto criado.
- Docker não está instalado: `supabase db reset` local não roda; os testes usam Postgres puro (`npm run test:banco`).
- Escolher o motor de mapper: `integracoes-kit` + JSONata (recomendado) ou só JSONata (`docs/FERRAMENTAS.md` §5).
- Comprar o domínio da plataforma (Hostinger) e apontar para a Cloudflare: requisito do white label.
- Autorizar os MCPs da RC (n8n RC, GitHub) para a instância compartilhada.
- Conta de teste do Funnelytics (teste de 14 dias) se quiser fechar as lacunas da engenharia reversa com observação ao vivo.
- Fluxo n8n do lançamento vigente para o Bloco 9 (`docs/lancamentos/` não existe).
