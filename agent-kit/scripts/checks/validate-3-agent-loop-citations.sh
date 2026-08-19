#!/usr/bin/env bash
# AGENT-LOOP-001 — enforces §10 3-Agent Loop ADR & Architecture Citation Protocol. Exit 0 = pass.
# Reference §10: Agent 1 must cite which ADR(s) and doc section(s) it followed in PR / commit.
set -euo pipefail

PR_BODY_FILE="${1:-}"

# In CI: check PR body file
if [ -n "$PR_BODY_FILE" ] && [ -f "$PR_BODY_FILE" ]; then
  if grep -qiE 'ADR[- ]?[0-9]+|adr:' "$PR_BODY_FILE" 2>/dev/null; then
    echo "PASS AGENT-LOOP-001 (ADR and architecture cited in PR description)"
    exit 0
  fi
fi

# Locally: check recent commit messages
recent_commits=$(git log --oneline -5 --format='%s %b' 2>/dev/null || true)
if echo "$recent_commits" | grep -qiE 'ADR[- ]?[0-9]+|adr:'; then
  echo "PASS AGENT-LOOP-001 (ADR cited in recent commit messages)"
  exit 0
fi

echo "VIOLATION AGENT-LOOP-001: commit message or PR description lacks citation of followed ADR(s):"
echo "  → See §10: Every code change proposal must cite which ADR(s) (e.g. 'ADR-0001') and doc section(s) it followed."
exit 1
