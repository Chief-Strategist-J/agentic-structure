#!/usr/bin/env bash
# RESOURCE-TIMEOUT-001 — every outbound HTTP/DB/broker client must have an explicit timeout.
# Heuristic: checks for common client construction patterns without timeout configuration.
set -euo pipefail
fail=0

# Go: http.Client{} without Timeout, sql.Open without SetConnMaxLifetime, etc.
go_hits=$(grep -RnE '(http\.Client\{|&http\.Client\{)' --include='*.go' . 2>/dev/null \
  | grep -vE 'Timeout|_test\.go' || true)
if [ -n "$go_hits" ]; then
  echo "FINDING RESOURCE-TIMEOUT-001 [Go]: http.Client without explicit Timeout:"
  echo "$go_hits"
  fail=1
fi

# Go: net.Dial / net.DialContext without deadline
go_dial=$(grep -RnE '\bnet\.Dial\(' --include='*.go' . 2>/dev/null \
  | grep -vE 'DialContext|Timeout|Deadline|_test\.go' || true)
if [ -n "$go_dial" ]; then
  echo "FINDING RESOURCE-TIMEOUT-001 [Go]: net.Dial without DialContext/timeout:"
  echo "$go_dial"
  fail=1
fi

# TypeScript: fetch() without AbortSignal/timeout
ts_hits=$(grep -RnE '\bfetch\(' --include='*.ts' --include='*.tsx' \
  --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null \
  | grep -iE '(lib/data|adapters?/|client\.ts|http)' \
  | grep -vE '(signal|AbortSignal|timeout|AbortController|_test\.|test\.)' || true)
if [ -n "$ts_hits" ]; then
  echo "FINDING RESOURCE-TIMEOUT-001 [TypeScript]: fetch() call in data layer without AbortSignal/timeout:"
  echo "$ts_hits"
  fail=1
fi

# Kotlin: HttpClient without timeout config
kt_hits=$(grep -RnE '(HttpClient\(|OkHttpClient\(|OkHttpClient\.Builder)' --include='*.kt' . 2>/dev/null \
  | grep -vE '(timeout|connectTimeout|readTimeout|writeTimeout|callTimeout|test/|Test\.kt)' || true)
if [ -n "$kt_hits" ]; then
  echo "FINDING RESOURCE-TIMEOUT-001 [Kotlin]: HTTP client without timeout configuration:"
  echo "$kt_hits"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS RESOURCE-TIMEOUT-001"
exit $fail
