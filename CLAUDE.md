# Funnel Traffic — CLAUDE.md

> Arquivo de entrada para qualquer chat, projeto ou conta Claude que trabalhe neste app.
> Copie para a raiz do repositório como `CLAUDE.md` e para a pasta de contexto do projeto Claude.
> Não contém MCP, credencial, conta ou empresa específica: vale em qualquer conta.

## O que é

Funnel Traffic é um SaaS da RC Digitais (projeto pessoal do Raphael, fora da ROI Ventures) que desenha funis e jornadas como um mapa e liga cada etapa a eventos reais de qualquer sistema (CRM, checkout, WhatsApp, webinário, site). Mostra pessoas únicas por etapa e conversão entre etapas, com latência de até 60 s. Referência visual: canvas do Funnelytics. Diferenciais: conectores abertos (webhook + mapper JSON, n8n como conector universal), API de leitura, papéis por workspace, consentimento LGPD no pixel.

Documentos-fonte: PRD Funnel Traffic (Claude Docs) · Benchmark Funnelytics (03/10/2026) · Protótipo "Funnel Traffic Canvas" (artifact HTML).

## Decisões fechadas (não reabrir sem registrar em docs/DECISOES.md)

- Nome: Funnel Traffic. Domínio será comprado depois.
- Versão gratuita de testes, sem cobrança. Nada no código depende de plano.
- Um único dono cria contas e workspaces, um por projeto. Primeiro workspace: "My Workspace".
- Multi-tenant e papéis (dono, admin, editor, visualizador, link de leitura) desde a migration 0001, conferidos no banco via RLS.
- Todo nome de workspace, canvas, conector, etapa e evento é definido pelo usuário. Só nomes reservados entre dois sublinhados (`__compra__`, `__contato__`) são fixos.
- Produto tem infra própria (repo e Supabase novos). Nenhum banco, n8n ou credencial de outra empresa entra no produto; empresas são workspaces clientes.
- Conector = configuração (mapper JSON), nunca código específico de plataforma. Para plataforma sem template, o caminho é um workflow n8n que envia o evento canônico.
- Contagem sempre por pessoa única, nunca sessão. Dinheiro em centavos inteiros com moeda; um evento por item de pedido; `idExterno` obrigatório para dedupe.
- Postgres puro no motor até 10 M eventos/mês por workspace. ClickHouse só com critério numérico (> 2 s em 95 % das consultas).
- Pixel `track.js` e o catálogo completo de conectores entram já na Fase 1, self-service: o dono conecta cada projeto sozinho pela tela de Integrações (URL + chave → payload de teste → editor de mapper → modo sombra → ativar).

## Modelo (seis objetos)

Workspace → Conector → Evento (de uma Pessoa) ← Etapa (regra sobre eventos) — Conexão (direta: próximo evento; pular: algum evento depois, na janela) → Canvas.

Evento canônico:

```json
{ "evento": "Compra Aprovada", "ocorridoEm": "2026-10-04T21:18:04-03:00", "idExterno": "HP123456-1",
  "pessoa": { "email": "", "telefone": "", "cookie": "", "idExterno": "" },
  "atributos": { "origem": "hotmart", "valorCentavos": 29700, "moeda": "BRL" } }
```

Identidade em cascata: idExterno conhecido → e-mail normalizado → telefone E.164 → cookie → pessoa anônima. Fusões em `pessoa_fusoes`, reversíveis, nunca apagam história.

## Stack (padrão Fábrica de Apps — trocar só com motivo em docs/DECISOES.md)

Vite + React 19 + TypeScript + shadcn/ui + Tailwind + React Query + react-router + react-hook-form/zod · React Flow (canvas) · Supabase (Auth, Postgres + RLS, Edge Functions Deno, pg_cron/pgmq para o worker) · Cloudflare Workers com assets (SPA e `track.js`) · vitest + Testing Library + Playwright · CI com typecheck, testes e build.

Estrutura: `CLAUDE.md` · `CONTEXTO_ATUAL.md` · `docs/DECISOES.md` · `docs/PENDENTE_BANCO.md` · `src/pages` · `src/components/<area>` · `src/hooks/use-<assunto>.ts` · `src/lib` (regras puras + teste) · `supabase/migrations/AAAAMMDDHHMMSS_<assunto>.sql` · `supabase/functions/<nome>` · `worker/index.ts` · `wrangler.jsonc`.

Toda conta que decide um número (conversão, ritmo de meta, status) é função pura em `src/lib` com teste. O motor SQL (`jornada_calcular`, `jornada_proximos_passos`) tem teste de contrato com os dados do protótipo.

## Comandos

`npm run dev` · `npm run typecheck` · `npm test -- --run` · `npm run test:e2e` · `npm run build` · `npm run lint`. Sem `.env.local` o app roda em modo demo. Como reusar este scaffold em outro app: `docs/MODELO.md` e `scripts/novo-app.sh`.

## Regras de trabalho

- Tudo em português: docs, comentários, commits (`tipo(área): o que mudou para quem usa`).
- Receber ≠ processar: ingestão grava bruto e responde 202; worker processa. Nunca descartar payload. Idempotência em todo evento. Retry só em 429/5xx/rede.
- Escrita nova em sistema externo nasce em modo sombra até comparar e aprovar.
- Segredo em env/Vault; tabela guarda só nome ou hash. Nunca inventar campo, endpoint ou versão de API: confirmar na doc oficial.
- Mapas (status de plataforma, operadores, nomes reservados) em tabela de configuração, nunca repetidos no código.
- Antes de mudança em massa: `bkp_<assunto>_<AAAAMMDD>`. Nada de histórico é apagado (`*_removidas`). Toda ação administrativa vai para `auditoria`.
- Escrever só na branch `preview`; `main` só recebe merge aprovado pelo dono. Banco, migrations, funções e webhooks não têm preview: pedir antes.
- Dado pessoal só para dono e admin; editor vê mascarado; visualizador e link de leitura só agregados.

## Fases e portões

0. Fundação (2 sem): repo, Supabase, CI, migration 0001 + RLS, ingestão + worker, motor SQL + teste. Portão: motor passa o teste de contrato; evento visível em < 60 s.
1. MVP (6 sem): tela de Integrações self-service com catálogo completo (vendas, CRM, captura, engajamento, entrega, assinatura, e-mail, reunião), conector n8n universal, webhook genérico, pixel track.js + plugin WordPress, canvas React Flow, painel Etapa + Explorer. Portão: My Workspace com conectores reais, canvas usado por 2 semanas.
2. Beta (4 sem): consentimento + LGPD, Monitor/metas/alertas, papéis + link de leitura, pedido de conector. Portão: 3 workspaces ativos, 1 conector pedido e publicado.
3. SaaS (6 sem): API pública + webhooks de saída, HubSpot e HighLevel nativos, onboarding de contas, servidor MCP.

Fora de escopo agora: custo de anúncio, forecast, Report Frames, app mobile, billing.

## Como começar um chat neste projeto

1. Dizer qual fase e qual entrega estão em andamento (ler `CONTEXTO_ATUAL.md`).
2. Confirmar quais MCPs estão disponíveis nesta conta (Supabase do produto, n8n do produto, GitHub). Nunca usar MCP de outra empresa.
3. Trabalhar em `preview`; validar; pedir aprovação antes de `main`, banco ou webhook.
4. Encerrar atualizando `CONTEXTO_ATUAL.md` e, se houve decisão, `docs/DECISOES.md`.
