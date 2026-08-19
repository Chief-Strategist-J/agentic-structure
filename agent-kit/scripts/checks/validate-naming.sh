#!/usr/bin/env bash
# NAMING-001 — no leftover doc/template example nouns in structural code.
# Edit BANNED_NOUNS below to match your actual doc's example nouns, never your real domain nouns.
set -euo pipefail
BANNED_NOUNS='OrderRepository|PricingRules|order_create|OrderCreateHandler'
hits=$(grep -RnE "$BANNED_NOUNS" --include='*.go' --include='*.kt' --include='*.ts' --include='*.tsx' \
  --exclude-dir=node_modules . 2>/dev/null || true)
if [ -n "$hits" ]; then
  echo "VIOLATION NAMING-001: found a doc/template example noun copied into real code:"
  echo "$hits"
  exit 1
fi
echo "PASS NAMING-001"
