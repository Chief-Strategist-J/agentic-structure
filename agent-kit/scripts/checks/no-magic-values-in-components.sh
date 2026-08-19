#!/usr/bin/env bash
# UI-MAGIC-VALUES-001 — no inline magic threshold numbers or status strings in components. Exit 0 = pass.
# Reference §11: Thresholds, status strings, enum-like literals sourced from lib/config or generated types.
set -euo pipefail
fail=0

# Detect business threshold comparisons in .tsx (e.g. total > 500, count > 10, status === "ACTIVE")
magic_hits=$(grep -RnE '(===|!==|>|<|>=|<=)\s*([0-9]{2,}|"[A-Z0-9_]{3,}")' \
  --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=__tests__ --exclude='*.test.*' --exclude='*.stories.*' . 2>/dev/null \
  | grep -vE '(statusCode|200|404|500|0|1|100|px|rem|em|width|height|opacity|zIndex|flex|grid|gap|columns|rows)' \
  | grep -vE '(//|/\*)' || true)

if [ -n "$magic_hits" ]; then
  echo "FINDING UI-MAGIC-VALUES-001: potential hardcoded business magic value in component:"
  echo "$magic_hits"
  echo "  → See §11: Source thresholds and status literals from lib/config or contract enums."
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS UI-MAGIC-VALUES-001"
exit $fail
