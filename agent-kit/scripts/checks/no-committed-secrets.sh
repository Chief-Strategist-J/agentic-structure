#!/usr/bin/env bash
# SECURITY-SECRET-001 — crude pattern scan. For real coverage, wire in gitleaks/trufflehog instead.
set -euo pipefail
PATTERN='AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC )?PRIVATE KEY-----|xox[baprs]-[0-9A-Za-z-]{10,}|AIza[0-9A-Za-z\-_]{35}'
hits=$(grep -RnE "$PATTERN" --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null || true)
if [ -n "$hits" ]; then
  echo "VIOLATION SECURITY-SECRET-001: possible committed secret found:"
  echo "$hits"
  exit 1
fi
echo "PASS SECURITY-SECRET-001 (crude scan only — wire in gitleaks/trufflehog for real coverage)"
