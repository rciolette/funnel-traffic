#!/usr/bin/env bash
# Versão de testes LOCAL de uma instância: banco do zero → migrations → seed padrão → seed da instância → testes.
# Não toca em nenhum banco remoto. Uso:
#   PGURL=postgres://postgres@127.0.0.1:5432 scripts/instancia-local.sh roi
set -euo pipefail

SLUG="${1:?informe a instância, ex.: roi}"
PGURL="${PGURL:-postgres://postgres@127.0.0.1:5432}"
BANCO="funnel_traffic_${SLUG}_teste"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)

node "$RAIZ/scripts/seed-instancia.mjs" "$SLUG"

"${PSQL[@]}" "$PGURL/postgres" -c "drop database if exists $BANCO" -c "create database $BANCO"
URL="$PGURL/$BANCO"
"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/testes/00_stub_supabase.sql"
for m in "$RAIZ"/supabase/migrations/*.sql; do "${PSQL[@]}" "$URL" -f "$m"; done
"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/seed.sql"
"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/instancias/$SLUG/seed.sql"
"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/instancias/$SLUG/teste.sql"

echo "instância $SLUG pronta no banco $BANCO"
"${PSQL[@]}" "$URL" -c "select w.nome as workspace, count(c.*) as conectores, string_agg(c.slug, ', ' order by c.slug) as quais
  from funnel_traffic.workspaces w left join funnel_traffic.conectores c on c.workspace_id = w.id
 where w.slug like '${SLUG}-%' and w.conta_id <> '22222222-2222-4222-8222-222222222222' -- fora a conta do seed padrão
 group by w.nome order by w.nome;"
