#!/usr/bin/env bash
# DB-RLS-001 — every table with a tenant_id column must enforce Row-Level Security (RLS). Exit 0 = pass.
# Reference §12: Application-layer filtering ALONE is forbidden; DB engine RLS is mandatory.
set -euo pipefail
fail=0
found=0

while IFS= read -r -d '' f; do
  found=1
  # Find table creations with tenant_id
  tables_with_tenant=$(perl -0777 -ne '
    while (/CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_]+)\s*\([^;]*tenant_id[^;]*\);/gis) {
      print "$1\n";
    }
  ' "$f" 2>/dev/null || true)

  for tbl in $tables_with_tenant; do
    # Check if this file or any migration enables RLS on this table
    has_rls=$(grep -iE "ALTER\s+TABLE\s+(?:ONLY\s+)?$tbl\s+ENABLE\s+ROW\s+LEVEL\s+SECURITY" "$f" 2>/dev/null || true)
    if [ -z "$has_rls" ]; then
      # Also check across all migrations in same directory
      mig_dir=$(dirname "$f")
      has_rls_global=$(grep -rnhiE "ALTER\s+TABLE\s+(?:ONLY\s+)?$tbl\s+ENABLE\s+ROW\s+LEVEL\s+SECURITY" "$mig_dir" 2>/dev/null || true)
      if [ -z "$has_rls_global" ]; then
        echo "VIOLATION DB-RLS-001 in $f: Table '$tbl' has tenant_id column but lacks 'ENABLE ROW LEVEL SECURITY':"
        echo "  → See §12: Multi-tenancy requires RLS at the DB engine; application WHERE filtering alone is banned."
        fail=1
      fi
    fi
  done
done < <(find . -path '*/migrations/*' \( -name '*.sql' -o -name '*.up.sql' \) -print0 2>/dev/null)

if [ "$found" -eq 0 ]; then
  echo "SKIP DB-RLS-001: no migration files found yet"
  exit 2
fi

[ "$fail" -eq 0 ] && echo "PASS DB-RLS-001"
exit $fail
