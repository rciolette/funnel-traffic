#!/usr/bin/env bash
# Recria um banco de teste do zero e roda: esqueleto Supabase → migrations → seed → testes SQL.
# Funciona em qualquer Postgres 15+ (CI usa o service postgres:17; local, qualquer Postgres sem Docker).
# Uso: PGURL=postgres://postgres@127.0.0.1:5432 scripts/testar-banco.sh
set -euo pipefail

PGURL="${PGURL:-postgres://postgres@127.0.0.1:5432}"
BANCO="${BANCO_TESTE:-funnel_traffic_teste}"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)

"${PSQL[@]}" "$PGURL/postgres" -c "drop database if exists $BANCO" -c "create database $BANCO"
URL="$PGURL/$BANCO"

"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/testes/00_stub_supabase.sql"
for m in "$RAIZ"/supabase/migrations/*.sql; do
  echo "migration: $(basename "$m")"
  "${PSQL[@]}" "$URL" -f "$m"
done
"${PSQL[@]}" "$URL" -f "$RAIZ/supabase/seed.sql"
for t in "$RAIZ"/supabase/testes/[1-9]*.sql; do
  echo "teste: $(basename "$t")"
  "${PSQL[@]}" "$URL" -f "$t"
done
echo "banco: todos os testes passaram"
