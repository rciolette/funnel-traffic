# Roteiro de construção — Funnel Traffic

O que existe, o que falta e em que ordem construir um app tipo Funnelytics, white label e multi-cliente. Atualizado em 14/10/2026, branch `preview` (commit `6170d72` + docs desta sessão).

Leia junto: `CLAUDE.md` (regras), `docs/MOTOR.md` (como os números são calculados), `docs/WHITE_LABEL.md` (marcas e clientes), `docs/USO.md` (passo a passo de uso), `docs/FERRAMENTAS.md` (skills, conectores e repositórios), `docs/conectores/CATALOGO.md`, `docs/benchmark-funnelytics.md` e `docs/benchmark/caso-funnelytics.md`.

## 1. Arquitetura alvo

```
Sites do cliente ──(track.js em t.cliente.com.br)──┐
Plataformas (Hotmart, HighLevel, …) ──(webhook)────┤
n8n (qualquer API) ──(evento canônico)─────────────┤
                                                   ▼
             Cloudflare Worker (domínios de cliente, SPA, pixel, /c coleta)
                                                   │
                                   Edge Function `ingest` (grava bruto, 202)
                                                   │
                         ingest_bruto ──► fila (pgmq) ──► worker
                                   (mapper, dedupe, identidade, sombra)
                                                   │
                     pessoas · identidades · pessoa_fusoes · eventos (partição/mês)
                                                   │
       Motor SQL: jornada_calcular · próximos passos · explorer · monitor · metas
                                                   │
        Painel React (Canvas, Explorer, Pessoas, Monitor, Integrações, Superadmin)
                 + link de leitura + API pública + webhooks de saída + MCP
```

## 2. O que já existe

| Área | Estado | Onde |
| --- | --- | --- |
| Pesquisa de mercado e benchmark | Feito | `docs/benchmark-funnelytics.md`, `docs/benchmark/caso-funnelytics.md` |
| Decisões e regras de trabalho | Feito | `CLAUDE.md`, `docs/DECISOES.md` |
| PRD | Feito (vivo no Claude Docs) | `docs/PRD.md` aponta para o documento |
| Protótipo visual do canvas | Feito | `docs/prototipo/funnel-traffic-canvas.html` |
| Catálogo de conectores (lista + formato do mapper) | Feito como lista; nenhum template escrito | `docs/conectores/CATALOGO.md` |
| Scaffold (Vite, React 19, Tailwind v4, shadcn, React Query, router, Supabase, CI, Worker, Playwright) | Feito | raiz do repo, `docs/MODELO.md` |
| Login, AppShell, ErrorBoundary em 3 níveis, contexto de workspace | Feito (modo demo sem `.env.local`) | `src/contexts`, `src/components` |
| Páginas | **Esqueleto**: Canvas com 3 nós fixos, Integrações com 3 cartões, Pessoas e Configurações vazias | `src/pages` |
| Regras de número | Parcial: `taxaConversao`, `formatarPercentual`, `formatarCentavos`, `statusMeta`, com teste | `src/lib/regras/conversao.ts` |
| Banco: 24 tabelas com RLS, papéis, partição de eventos, dedupe, sombra, auditoria, configuração | Feito no repo, testado em Postgres 17 local e no CI. **Não aplicado** em nenhum Supabase | `supabase/migrations/20261005041500_fundacao.sql`, `supabase/testes` |
| Supabase remoto | Falta (instância ROI decidida em 05/10, ainda não criada) | `docs/PENDENTE_BANCO.md` |
| Worker | Esqueleto (`/saude` + assets) | `worker/index.ts` |

**Resumo:** fundação, banco e documentação estão prontos. Nenhuma das peças que geram número existe ainda: ingestão, worker, motor, pixel, conectores e canvas real.

## 3. O que falta, em blocos

Cada bloco termina com teste passando no CI e com `CONTEXTO_ATUAL.md` atualizado. Os blocos 1 a 9 formam o MVP (Fases 0 e 1 do `CLAUDE.md`).

| # | Bloco | Entregas | Portão | Depende de |
| --- | --- | --- | --- | --- |
| 1 | Banco | Migration de fundação | Feito | — |
| 1b | Supabase remoto | Criar projeto, aplicar migration, desligar cadastro, advisors, registrar id | Advisors sem erro | Dono |
| 2 | Motor | `jornada_calcular` e funções irmãs (`docs/MOTOR.md`), `config_eventos_ruido`, `jornada_cache`, teste de contrato com os 12 casos | Teste de contrato verde | 1 |
| 3 | Ingestão e identidade | Edge Function `ingest` (chave por conector, 202, bruto), worker (pgmq + pg_cron), mapper, dedupe em `eventos_chaves`, identidade em cascata, fusões reversíveis, modo sombra | Evento visível no banco em < 60 s; reenvio não duplica | 1b, decisão do mapper (`FERRAMENTAS.md` §5) |
| 4 | Integrações self-service | Tela em 5 passos (URL + chave → payload de teste → editor de mapper com prévia → sombra → ativar), templates n8n, webhook, Hotmart, Braip, Assiny, HighLevel, HubSpot, Typeform, HotWebinar, SendFlow, MemberKit, com payload real, guia e teste; pedido de conector | Dono liga um conector sozinho | 3 |
| 5 | Pixel | `track.js` (page view, clique, scroll, formulário, vídeo, `identify`, `track`), cookie de 1ª parte, `?ft=` entre domínios, captura de e-mail opcional com hash, consentimento, fila local com reenvio, servido pelo Worker; plugin WordPress; snippet GTM | Pessoa anônima vira lead identificada no teste e2e | 3 |
| 6 | Canvas | Nós Fonte/Página/Ação/Offline com editor de regra (frases), conexões direta/pular com janela, números e pílulas de conversão, período, filtros, comparação, modo funil, histórico de versões, exportar PNG | Canvas do protótipo reproduzido com dados reais | 2 |
| 7 | Etapa, Explorer e Pessoas | Painel da etapa (pessoas, tendência, lista mascarada por papel), Step Explorer (próximos e anteriores), aba Explorer (top fontes, páginas, ações; adicionar ao canvas), linha do tempo da pessoa | Montar um funil de trás para frente pelo Explorer | 2, 6 |
| 8 | White label e contas | `conta_marcas`, `conta_dominios`, `conta_limites`, superadmin, tema por domínio no Worker, Cloudflare for SaaS, e-mail de Auth com marca (Send Email Hook), pixel no domínio do cliente (`docs/WHITE_LABEL.md`) | Duas contas com marcas diferentes, cada uma no próprio domínio, sem ver os dados da outra | 1b |
| 8b | Instância ROI | Versão de testes local feita (`docs/instancias/roi`); falta schema `funnel_traffic` no `roi-apps` e carga inicial do histórico do Supabase do Gerador | Pendências R-01 a R-07 respondidas | 2, 3 |
| 9 | Primeiro projeto real | My Workspace e o lançamento vigente ligados (pixel + vendas + n8n); comparar com Assiny e HubSpot (`conciliacao-comercial-roi`) | Portão da Fase 1: canvas usado por 2 semanas | 4, 5, 6, 7 |

### Depois do MVP

| Fase | Entregas |
| --- | --- |
| 2 — Beta | Consentimento e LGPD completos (anonimização a pedido do titular, DPA), Monitor com KPIs, metas com ritmo e alertas (e-mail, Slack), papéis e convites na tela, link de leitura com senha, fluxo de pedido → publicação de conector, central de ajuda por conector |
| 3 — SaaS | API pública de leitura (chave por workspace), webhooks de saída, HubSpot e HighLevel nativos (OAuth), onboarding de contas pelo superadmin, servidor MCP (perguntar ao Claude sobre o funil), nó n8n oficial, exportação para Miro |
| Fora de escopo agora | Custo de anúncio (Meta/Google Ads), forecast, Report Frames, app mobile, cobrança |

## 4. Ordem recomendada para as próximas sessões

1. **Dono:** confirmar onde nasce o Supabase da instância compartilhada (RC Digitais) e criar o da ROI; comprar o domínio da plataforma (Hostinger) e apontar para a Cloudflare.
2. **Bloco 2 (motor)** antes de qualquer tela: é o coração e só depende do banco local. Começar decidindo e registrando as três regras abertas (`docs/MOTOR.md` §4 e §5).
3. **Bloco 3** com o `integracoes-kit` como base.
4. **Blocos 5 e 4** em paralelo (pixel e templates), cada template a partir de um payload real.
5. **Blocos 6 e 7** sobre o motor pronto.
6. **Bloco 8** antes de ligar o primeiro cliente que não seja do dono.
7. **Bloco 9** e o portão da Fase 1.

## 5. Riscos

| Risco | Mitigação |
| --- | --- |
| A semântica da conexão direta muda muito o número | Lista de eventos de ruído configurável e teste de contrato; comparar com o Funnelytics quando houver conta |
| Volume do pixel (page view, scroll) estoura o Postgres | Scroll e vídeo agregados no cliente (um evento por limiar), partição mensal, cache do motor, critério numérico para ClickHouse |
| Bloqueadores de anúncio e restrições de cookie | Pixel em domínio próprio do cliente (`docs/WHITE_LABEL.md` §4.3) e eventos de servidor por webhook |
| Mistura de dados entre clientes | RLS por workspace testada no CI; teste e2e com duas contas no Bloco 8 |
| Template de conector com campo inventado | Só publicar com payload real (`rascunho = true` até lá) e teste |
| Dependência de MCP de outra empresa | Instância ROI usa os MCPs ROI; a instância RC usa só os da RC (`docs/FERRAMENTAS.md` §2) |
