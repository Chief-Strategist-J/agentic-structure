#!/usr/bin/env bash
# DB-MIGRATION-001 / 002 — additive-only, ADR-referenced destructive migrations. Exit 0 = pass.
set -euo pipefail
fail=0
for f in $(find . -path '*/migrations/*' \( -name '*.sql' -o -name '*.up.sql' \) 2>/dev/null); do
  if grep -qiE 'ADD COLUMN.*NOT NULL' "$f" && ! grep -qiE 'DEFAULT' "$f"; then
    echo "VIOLATION DB-MIGRATION-001 in $f: NOT NULL column added without a default"
    fail=1
  fi
  if grep -qiE 'DROP COLUMN|RENAME COLUMN|ALTER COLUMN .* TYPE' "$f" && ! grep -qiE '\-\- ADR:' "$f"; then
    echo "VIOLATION DB-MIGRATION-002 in $f: destructive migration with no '-- ADR:' reference comment"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS DB-MIGRATION-001/002"
exit $fail
