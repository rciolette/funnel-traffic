# Pendente no banco — Funnel Traffic

O que existe no repositório e ainda não foi aplicado em nenhum projeto Supabase remoto.

## Projeto Supabase

Ainda não criado. Ver pergunta aberta em `CONTEXTO_ATUAL.md` (organização e região). Ao criar: registrar id em `docs/DECISOES.md`, desligar cadastro público no Auth, rodar advisors.

## Migrations prontas (testadas em Postgres 17 local e no CI)

| Arquivo | O que faz |
| --- | --- |
| `20261005041500_fundacao.sql` | 24 tabelas com RLS, `papel_no_workspace`, `tem_papel`, `workspace_criar`, partição mensal de `eventos`, auditoria por trigger, configuração (papéis, operadores, nomes reservados), `funnel_traffic_erros_front` |

Seed local (`supabase/seed.sql`): dono de teste, "My Workspace" e "ROI Ventures · Lançamentos". Em produção o seed não roda: o dono entra pelo Auth e chama `workspace_criar()`.

## A escrever (próximos blocos)

- Motor: `jornada_calcular`, `jornada_proximos_passos`, `jornada_passos_anteriores`, `explorer_top`, `monitor_kpis`, `meta_status` + `etapa_dia`.
- Ingestão: `evento_registrar` (dedupe + identidade), retenção de 30 dias do bruto, cron do worker (pg_cron + pg_net).
- `conector_templates` com o catálogo da Fase 1.
- Motor (detalhe): `config_eventos_ruido`, `jornada_cache` (`docs/MOTOR.md`).
- Feito no repo (14/10): fundação no schema `funnel_traffic` e tipo `documento` em `identidades`. Falta o worker calcular o HMAC (`DOCUMENTO_PEPPER` em secret).
- Instância ROI no `roi-apps` (`opzuindwpwxevwlhoaaw`): aplicar a fundação quando o MCP estiver conectado e o dono der o "pode"; expor `funnel_traffic` na API; advisors (passo a passo em `docs/instancias/roi/README.md` §5). Versão de testes local: `npm run instancia:local -- roi`.
- White label: `conta_marcas`, `conta_dominios`, `conta_limites`, `plataforma_admins`, `acessos_suporte`, `contas.dpa_aceito_em`, `contas.suspensa_em`; funções `marca_por_dominio`, `eh_superadmin`, `conta_criar` (`docs/WHITE_LABEL.md` §8).

## Dados de teste

Os eventos sintéticos do protótipo (`docs/prototipo/funnel-traffic-canvas.html`, constantes `NODES` e `EDGES`) são a base do teste de contrato do motor.
