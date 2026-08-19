#!/usr/bin/env bash
# KT-NULL-001 — no `!!` outside test source sets. Exit 0 = pass.
set -euo pipefail
hits=$(grep -RnE '!!' --include='*.kt' . 2>/dev/null | grep -vE '(/test/|/androidTest/|Test\.kt:)' || true)
if [ -n "$hits" ]; then
  echo "VIOLATION KT-NULL-001: found '!!' outside test sources:"
  echo "$hits"
  exit 1
fi
echo "PASS KT-NULL-001"
