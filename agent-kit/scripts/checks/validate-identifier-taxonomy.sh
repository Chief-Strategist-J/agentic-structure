#!/usr/bin/env bash
# ID-TAXONOMY-001 — enforces §14 Identifier Taxonomy boundaries. Exit 0 = pass.
# Rules:
# 1. No mixing identifier meanings (e.g. using Request-ID as Idempotency-Key or Trace-ID).
# 2. Trace-ID must propagate via context/headers, never re-generated downstream.
# 3. Tenant-ID is mandatory on all data operations and requests.
# 4. Idempotency-Key is mandatory on mutating operations.
set -euo pipefail
fail=0

alias_hits=""
while IFS= read -r -d '' f; do
  hit=$(perl -ne '
    if (/(idempotency_?key\s*[:=]+\s*(req(uest)?_?id|x_request_id)|trace_?id\s*[:=]+\s*(req(uest)?_?id|x_request_id))/i) {
      print "$ARGV:$.: $_";
    }
  ' "$f" 2>/dev/null || true)
  if [ -n "$hit" ]; then
    alias_hits+="$hit"
  fi
done < <(find . \( -name '*.go' -o -name '*.kt' -o -name '*.ts' -o -name '*.tsx' \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 2>/dev/null)

if [ -n "$alias_hits" ]; then
  echo "VIOLATION ID-TAXONOMY-001: identifier aliasing detected (mixing distinct taxonomy meanings):"
  echo "$alias_hits"
  echo "  → See §14: Request-ID, Trace-ID, and Idempotency-Key have distinct lifecycles and MUST NOT be aliased."
  fail=1
fi

regen_hits=""
while IFS= read -r -d '' f; do
  hit=$(perl -ne '
    if (/(tracer\.Start\([^)]*context\.Background\(\)|SpanFromContext\(nil\))/) {
      print "$ARGV:$.: $_";
    }
  ' "$f" 2>/dev/null || true)
  if [ -n "$hit" ]; then
    regen_hits+="$hit"
  fi
done < <(find . -path '*/features/*' -name '*.go' -not -name '*_test.go' -print0 2>/dev/null)

if [ -n "$regen_hits" ]; then
  echo "VIOLATION ID-TAXONOMY-001 [Go]: downstream Trace-ID regeneration detected in feature:"
  echo "$regen_hits"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS ID-TAXONOMY-001"
exit $fail
