#!/usr/bin/env bash
# ADR-COVERAGE-001 — requires a PR description/commit message file passed as $1 containing "ADR:" when
# the diff touches a structural path. Intended to be invoked from CI with the PR body piped in.
set -euo pipefail
PR_BODY_FILE="${1:-}"
STRUCTURAL_PATTERN='platform/|/ports/|/adapters/|/engine/'
CHANGED_FILES="${CHANGED_FILES:-$(git diff --name-only origin/main... 2>/dev/null || true)}"
touches_structural=$(echo "$CHANGED_FILES" | grep -E "$STRUCTURAL_PATTERN" || true)
if [ -z "$touches_structural" ]; then
  echo "PASS ADR-COVERAGE-001 (no structural paths touched)"
  exit 0
fi
if [ -z "$PR_BODY_FILE" ] || ! grep -qiE 'ADR[- ]?[0-9]+|adr:' "$PR_BODY_FILE" 2>/dev/null; then
  echo "VIOLATION ADR-COVERAGE-001: structural change with no linked ADR in the PR/commit description:"
  echo "$touches_structural"
  exit 1
fi
echo "PASS ADR-COVERAGE-001"
