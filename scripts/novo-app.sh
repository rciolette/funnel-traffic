#!/usr/bin/env bash
# Cria um novo app a partir deste modelo.
# Uso: scripts/novo-app.sh <slug> "<Nome do App>" "<Empresa>" [pasta-destino]
set -euo pipefail
SLUG="${1:?slug (ex.: meu-app)}"; NOME="${2:?nome}"; EMPRESA="${3:-RC Digitais}"; DEST="${4:-../$SLUG}"
ORIGEM="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$DEST"
tar -C "$ORIGEM" --exclude=node_modules --exclude=dist --exclude=.git --exclude=".env*" --exclude=docs/benchmark-funnelytics.md --exclude=docs/prototipo --exclude=docs/conectores --exclude=test-results -cf - . | tar -C "$DEST" -xf -
cd "$DEST"
# Troca identidade
sed -i.bak -e "s/Funnel Traffic/$NOME/g" -e "s/funnel-traffic/$SLUG/g" -e "s/RC Digitais/$EMPRESA/g" \
  app.config.ts package.json index.html wrangler.jsonc README.md CLAUDE.md CONTEXTO_ATUAL.md docs/DECISOES.md docs/PENDENTE_BANCO.md 2>/dev/null || true
find . -name '*.bak' -delete
# Limpa o que é específico do Funnel Traffic no doc de contexto
cat > CONTEXTO_ATUAL.md <<EOT
# Contexto atual — $NOME

Projeto criado a partir do modelo Fábrica de Apps em $(date +%Y-%m-%d). Atualizar ao fim de cada sessão.

## Estado
- Scaffold pronto (modo demo). Sem Supabase, sem migrations.

## Próximo passo
1. Definir papéis, fontes de dados e integrações (Passo 0 da Fábrica de Apps).
2. Criar projeto Supabase próprio e registrar em docs/DECISOES.md.
3. Migration 0001 com RLS.
EOT
cat > docs/DECISOES.md <<EOT
# Decisões — $NOME

Formato: data · decisão · motivo. Nunca apagar.

- $(date +%Y-%m-%d) · App criado a partir do modelo Fábrica de Apps (funnel-traffic) · Mesma stack e regras; trocar só com motivo aqui.
EOT
git init -q -b main && git add -A && git commit -q -m "chore(scaffold): $NOME a partir do modelo Fábrica de Apps" && git branch preview && git checkout -q preview
echo "Pronto em $DEST (branch preview). Próximo: npm install && npm run dev"
