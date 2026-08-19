#!/usr/bin/env bash
# TS-ANY-001 — no `any` outside a commented justification. Exit 0 = pass.
set -euo pipefail
hits=$(grep -RnE ':\s*any\b|<any>|as any\b' --include='*.ts' --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=generated . 2>/dev/null | grep -v '// justified:' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION TS-ANY-001: found unjustified 'any' usage:"
  echo "$hits"
  exit 1
fi
echo "PASS TS-ANY-001"
