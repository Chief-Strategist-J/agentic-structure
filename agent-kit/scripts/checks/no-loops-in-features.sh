#!/usr/bin/env bash
# LOOP-001 — no for/while loops in features/, domain/, components. Exit 0 = pass.
set -euo pipefail
TARGET_DIRS='(features/|domain/|components/|\(features\)/)'

# Go loops: 'for ' at start of line (covers 'for i :=', 'for _, v := range', 'for {', bare 'for')
# Kotlin/TS loops: 'for (' or 'for(', 'while (' or 'while(', 'for await'
hits=$( (grep -RnE '^\s*(for\s|for\(|for\s+await|while\s*\()' \
  --include='*.go' --include='*.kt' --include='*.ts' --include='*.tsx' . 2>/dev/null || true) \
  | grep -E "$TARGET_DIRS" \
  | grep -vE '(platform/fp/|_test\.|_test_|\.test\.|Test\.kt:)' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION LOOP-001: raw loop found in a feature/domain/UI file — use map/filter/fold/reduce/pipe:"
  echo "$hits"
  exit 1
fi
echo "PASS LOOP-001"
