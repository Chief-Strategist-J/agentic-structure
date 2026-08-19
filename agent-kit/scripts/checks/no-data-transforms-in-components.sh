#!/usr/bin/env bash
# UI-TRANSFORM-001 — no raw data transformation inside UI components (.tsx). Exit 0 = pass.
# Reference §11: .map/.filter/.reduce on raw API data INSIDE a component is banned.
# Raw -> view-model transformation lives in lib/transforms/<feature>.viewmodel.ts.
set -euo pipefail
fail=0

# Detect data transformation chains (.map().filter() / reduce / sort) inside .tsx components
# Exclude JSX child mapping (e.g. items.map((item) => <Item key={item.id} />) is rendering markup, but heavy data shaping is not)
transform_hits=$(grep -RnE '\.(filter|reduce|sort|flatMap)\([^)]*\)\s*\.(map|filter|reduce)' \
  --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=__tests__ . 2>/dev/null || true)

if [ -n "$transform_hits" ]; then
  echo "VIOLATION UI-TRANSFORM-001: complex data transformation pipeline found in UI component:"
  echo "$transform_hits"
  echo "  → See §11: Move data shaping to lib/transforms/<feature>.viewmodel.ts — components only render already-shaped viewmodels."
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS UI-TRANSFORM-001"
exit $fail
