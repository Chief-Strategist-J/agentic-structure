#!/usr/bin/env bash
# UI-LOGIC-001 — flags JSX with a multi-condition inline expression. Heuristic, review flagged lines manually.
set -euo pipefail
hits=$(grep -RnE '\{[^}]*&&[^}]*&&[^}]*\}|\{[^}]*\?[^}]*:[^}]*\?[^}]*:' \
  --include='*.tsx' --exclude-dir=node_modules . 2>/dev/null || true)
if [ -n "$hits" ]; then
  echo "VIOLATION UI-LOGIC-001: multi-condition logic found inline in JSX — move to lib/rules or a viewmodel:"
  echo "$hits"
  exit 1
fi
echo "PASS UI-LOGIC-001"
