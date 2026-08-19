#!/usr/bin/env bash
# GO-ASSERT-001 — every x.(T) must use the ", ok" form. Heuristic grep. Exit 0 = pass.
set -euo pipefail
# flags a bare type assertion NOT immediately assigned as "v, ok :="
hits=$(grep -RnE '\.\([A-Za-z_][A-Za-z0-9_]*\)' --include='*.go' . 2>/dev/null \
  | grep -vE ', ok[[:space:]]*:?=' \
  | grep -vE '\.\(type\)' \
  | grep -vE '_test\.go' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION GO-ASSERT-001: possible unchecked type assertion (verify manually, heuristic only):"
  echo "$hits"
  exit 1
fi
echo "PASS GO-ASSERT-001"
