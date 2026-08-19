#!/usr/bin/env bash
# GO-ASSERT-001 — every x.(T) must use the ", ok" form. Heuristic grep. Exit 0 = pass.
set -euo pipefail
# Match any type assertion pattern: .(T), .(pkg.T), .(*T), .([]byte), .(map[...]), .(interface{})
# Exclude: .(type) (type switch), lines with ', ok', test files
hits=$(grep -RnE '\.\(([A-Za-z_*\[\]{}]|[A-Za-z0-9_.]+)+(\)| )' --include='*.go' . 2>/dev/null \
  | grep -E '\.\([^)]+\)' \
  | grep -vE '\.\(type\)' \
  | grep -vE ',\s*(ok|exists|found|valid)\s*:?=' \
  | grep -vE '_test\.go' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION GO-ASSERT-001: possible unchecked type assertion (verify manually, heuristic only):"
  echo "$hits"
  exit 1
fi
echo "PASS GO-ASSERT-001"
