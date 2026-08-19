#!/usr/bin/env bash
# TS-ASSERT-001 — no `as T` on external data outside schema.ts/generated. Exit 0 = pass.
set -euo pipefail
hits=$(grep -RnE '\bas\s+[A-Z][A-Za-z0-9_]*\b' --include='*.ts' --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=generated --exclude='schema.ts' . 2>/dev/null | grep -v '// justified:' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION TS-ASSERT-001: found 'as <Type>' cast — use zod .parse()/.safeParse() at the boundary instead:"
  echo "$hits"
  exit 1
fi
echo "PASS TS-ASSERT-001"
