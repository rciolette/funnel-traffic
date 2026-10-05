# Modelo de app (Fábrica de Apps)

Este repositório é, ao mesmo tempo, o Funnel Traffic e o **modelo** para qualquer app novo da RC Digitais. Tudo que é genérico vive no scaffold; tudo que é do Funnel Traffic vive em `app.config.ts`, `docs/` e nas páginas.

## Criar um app novo a partir daqui

```bash
scripts/novo-app.sh meu-app "Meu App" "RC Digitais" ../meu-app
cd ../meu-app && npm install && npm run dev
```

O script copia o scaffold (sem node_modules, .git, .env e docs específicos), troca nome/slug/empresa, zera `CONTEXTO_ATUAL.md` e `docs/DECISOES.md`, cria o git com branches `main` e `preview`. Depois, siga o Passo 0 da skill Fábrica de Apps (papéis, fontes, MCPs, banco) antes de escrever código.

## O que o modelo já traz

| Peça | Onde | Regra |
| --- | --- | --- |
| Identidade do app | `app.config.ts` | Único lugar com nome, slug, empresa e menu |
| Stack | Vite + React + TypeScript + Tailwind v4 + shadcn/ui (componentes em `src/components/ui`) + React Query + react-router + react-hook-form/zod | Trocar só com motivo em `docs/DECISOES.md` |
| Supabase | `src/lib/supabase.ts`, `src/lib/env.ts` | Sem `VITE_SUPABASE_*` o app roda em **modo demo** (sem login, dados de exemplo) |
| Auth e workspace | `src/contexts/AuthContext.tsx`, `WorkspaceContext.tsx`, `src/hooks/use-workspaces.ts` | Papel é conferido pelo RLS, nunca pelo front |
| Erros | `src/components/erros/ErrorBoundary.tsx` (tela, conteúdo, silencioso) + `registrarErro.ts` | Todo erro vai para `<app>_erros_front`; nenhum componente derruba o app |
| Regras de número | `src/lib/regras/*.ts` + `*.test.ts` | Função pura com teste; componentes só chamam |
| Layout | `src/components/layout/AppShell.tsx`, `Pagina.tsx` | Menu lateral vem de `app.config.ts`; conteúdo dentro de ErrorBoundary |
| Páginas | `src/pages/*` + `src/routes.tsx` | Nova página = arquivo + rota + item no menu |
| Testes | vitest (`src/**/*.test.tsx`), Playwright (`e2e/`) | `npm test`, `npm run test:e2e` |
| CI | `.github/workflows/ci.yml` | typecheck, testes, build em push para `main` e `preview` |
| Deploy | `worker/index.ts`, `wrangler.jsonc` | Cloudflare Workers com assets; Workers Builds ligado ao GitHub |
| Banco | `supabase/migrations`, `supabase/functions` | Migration com timestamp real; RLS desde a primeira |
| Docs | `CLAUDE.md`, `CONTEXTO_ATUAL.md`, `docs/DECISOES.md`, `docs/PENDENTE_BANCO.md` | Em português; atualizar a cada sessão |

## Comandos

```bash
npm run dev          # desenvolvimento
npm run typecheck    # tsc
npm test             # vitest (watch); npm test -- --run no CI
npm run test:e2e     # Playwright (sobe build + preview)
npm run build        # tsc + vite build → dist/
npm run lint         # oxlint
```

## Fluxo de trabalho

1. `git fetch && git status -sb` na `preview`.
2. Escrever só na `preview`; `main` existe só no GitHub e recebe merge aprovado pelo dono.
3. `npm run typecheck && npm test -- --run && npm run build` antes de commitar.
4. Commit `tipo(área): o que mudou para quem usa` e push na `preview`.
5. Pedir aprovação explícita → `git push origin preview:main`.

Banco, migrations, Edge Functions, CRM, automações e webhooks não têm preview: pedir antes de escrever.

## Camadas 2 e 3 (painel público e painel legado)

Não fazem parte do scaffold. Quando um app precisar de tela para grupo ou TV, seguir a skill Fábrica de Apps: função pública de agregados `<app>-tv-data`, rota pública com token, e HTML ES5 servido pelo Worker.
