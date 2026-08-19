#!/usr/bin/env bash
# UI-FETCH-001 — no fetch/axios inside components or page files. Exit 0 = pass.
set -euo pipefail
hits=$(grep -RnE '\bfetch\(|axios\.' --include='*.tsx' --include='*.ts' \
  --exclude-dir=node_modules --exclude-dir=lib . 2>/dev/null | grep -E '(components/|page\.tsx|actions\.ts)' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION UI-FETCH-001: direct fetch/axios call outside lib/data:"
  echo "$hits"
  exit 1
fi
echo "PASS UI-FETCH-001"
