# Pendente no banco — Funnel Traffic

O que o front finge enquanto o banco não existe, com o SQL pronto para aplicar.

## Projeto Supabase

Ainda não criado. Criar na conta RC Digitais, região `sa-east-1`, e registrar o project id em `docs/DECISOES.md`.

## Migration 0001 (a escrever)

Tabelas: `contas`, `workspaces`, `workspace_membros`, `conectores`, `conector_templates`, `conector_pedidos`, `ingest_bruto`, `pessoas`, `identidades`, `pessoa_fusoes`, `eventos` (particionada por mês), `canvases`, `etapas`, `conexoes`, `metas`, `auditoria`.

Regras: `workspace_id` em toda tabela de dados; RLS em todas desde a primeira migration; papel conferido por função `papel_no_workspace(workspace_id)`; `eventos` com unique (workspace_id, conector_id, id_externo, evento) e índices (workspace_id, pessoa_id, ocorrido_em) e (workspace_id, evento, ocorrido_em); `atributos jsonb` com GIN.

## Funções (a escrever)

`jornada_calcular(canvas_id, de, ate, filtros jsonb)` · `jornada_proximos_passos(etapa_id, de, ate)` · `jornada_passos_anteriores(...)` · `explorer_top(workspace_id, tipo, de, ate)` · `monitor_kpis(workspace_id, de, ate)` · `meta_status(meta_id)`.

## Dados de teste

Os eventos sintéticos do protótipo (`docs/prototipo/funnel-traffic-canvas.html`, constantes `NODES` e `EDGES`) são a base do teste de contrato do motor.
