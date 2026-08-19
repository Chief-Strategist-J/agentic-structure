#!/usr/bin/env bash
# CENTRAL-001 — enforces §9 Centralization Master List across Go, Kotlin, TS, Python, Java. Exit 0 = pass.
set -euo pipefail
fail=0

db_in_feat=$(grep -RnE '(sql\.Open|pgxpool\.New|pgx\.Connect|new\s+Pool\(|createPool\(|Database\.connect\(|asyncpg\.create_pool|psycopg2\.connect|DriverManager\.getConnection)'   --include='*.go' --include='*.kt' --include='*.ts' --include='*.py' --include='*.java'   --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null   | grep -E '(features/|\(features\)/)'   | grep -vE '(_test\.|test\.|test_|tests/)' || true)
if [ -n "$db_in_feat" ]; then
  echo "VIOLATION CENTRAL-001: database connection/pool constructed directly inside feature:"
  echo "$db_in_feat"
  fail=1
fi

http_in_feat=$(grep -RnE '(axios\.create|new\s+HttpClient\(|OkHttpClient\.Builder\(|http\.Client\{|&http\.Client\{|httpx\.Client\(|requests\.Session\(|HttpClient\.newHttpClient\()'   --include='*.go' --include='*.kt' --include='*.ts' --include='*.py' --include='*.java'   --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null   | grep -E '(features/|\(features\)/)'   | grep -vE '(_test\.|test\.|test_|tests/)' || true)
if [ -n "$http_in_feat" ]; then
  echo "VIOLATION CENTRAL-001: HTTP client constructed directly inside feature:"
  echo "$http_in_feat"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS CENTRAL-001"
exit $fail
