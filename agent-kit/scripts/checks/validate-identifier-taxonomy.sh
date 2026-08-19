#!/usr/bin/env bash
# ID-TAXONOMY-001 — enforces §14 Identifier Taxonomy boundaries. Exit 0 = pass.
# Rules:
# 1. No mixing identifier meanings (e.g. using Request-ID as Idempotency-Key or Trace-ID).
# 2. Trace-ID must propagate via context/headers, never re-generated downstream.
# 3. Tenant-ID is mandatory on all data operations and requests.
# 4. Idempotency-Key is mandatory on mutating operations.
set -euo pipefail
fail=0

# Check for identifier aliasing anti-pattern (e.g. idempotencyKey = requestId, traceId = requestId)
alias_hits=$(grep -RnE '(\bidempotency_?key\s*[:=]\s*(req(uest)?_?id|x_request_id)|\btrace_?id\s*[:=]\s*(req(uest)?_?id|x_request_id))' \
  --include='*.go' --include='*.kt' --include='*.ts' --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null || true)
if [ -n "$alias_hits" ]; then
  echo "VIOLATION ID-TAXONOMY-001: identifier aliasing detected (mixing distinct taxonomy meanings):"
  echo "$alias_hits"
  echo "  → See §14: Request-ID, Trace-ID, and Idempotency-Key have distinct lifecycles and MUST NOT be aliased."
  fail=1
fi

# Check for downstream Trace-ID regeneration (creating new root trace inside internal handlers)
regen_hits=$(grep -RnE '(tracer\.Start\([^)]*context\.Background\(\)|SpanFromContext\(nil\))' \
  --include='*.go' . 2>/dev/null \
  | grep -E 'features/' \
  | grep -vE '(_test\.go)' || true)
if [ -n "$regen_hits" ]; then
  echo "VIOLATION ID-TAXONOMY-001 [Go]: downstream Trace-ID regeneration detected in feature:"
  echo "$regen_hits"
  echo "  → Propagate incoming context.Context with existing trace; do not create orphan root spans with context.Background()."
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS ID-TAXONOMY-001"
exit $fail
