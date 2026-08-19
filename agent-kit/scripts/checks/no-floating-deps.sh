#!/usr/bin/env bash
# DEP-PIN-001 — no ^ or ~ ranges in package.json dependencies; go.mod/build.gradle checked for lockfile presence.
set -euo pipefail
fail=0
if [ -f package.json ]; then
  hits=$(grep -E '"\^|"~' package.json || true)
  if [ -n "$hits" ]; then
    echo "VIOLATION DEP-PIN-001: floating version range in package.json:"
    echo "$hits"
    fail=1
  fi
  [ -f package-lock.json ] || { echo "VIOLATION DEP-PIN-001: package-lock.json missing"; fail=1; }
fi
if [ -f go.mod ] && [ ! -f go.sum ]; then
  echo "VIOLATION DEP-PIN-001: go.sum missing"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS DEP-PIN-001"
exit $fail
