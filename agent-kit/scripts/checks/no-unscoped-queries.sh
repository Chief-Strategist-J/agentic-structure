#!/usr/bin/env bash
# DB-TENANT-001 — heuristic: repository functions must take a tenant/scope param.
# Customize the FUNC_PATTERN and TENANT_PARAM to your actual naming convention before relying on this.
set -euo pipefail
FUNC_PATTERN='func \([A-Za-z]+ \*?[A-Za-z]+Repository\) [A-Z][A-Za-z]*\('
hits=$(grep -RnE "$FUNC_PATTERN" --include='*.go' . 2>/dev/null | grep -viE 'tenant|scope|ctx context\.Context' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION DB-TENANT-001: repository method with no visible tenant/scope/context parameter (heuristic — verify manually):"
  echo "$hits"
  exit 1
fi
echo "PASS DB-TENANT-001"
