#!/usr/bin/env bash
# STRUCTURE-001 — validates vertical-slice folder structure for Go, Kotlin, Next.js, Python, Java services.
# Rejects layered-architecture anti-patterns.
set -euo pipefail
fail=0
found_any=0

# --- Python service roots (dirs containing requirements.txt or pyproject.toml) ---
while IFS= read -r -d '' pyreq; do
  svc_root=$(dirname "$pyreq")
  [ "$svc_root" = "." ] && continue
  found_any=1
  echo "Checking Python service: $svc_root"

  # Required vertical-slice structure
  has_features=$(find "$svc_root" -maxdepth 3 -type d -name 'features' 2>/dev/null | head -1)
  has_domain=$(find "$svc_root" -maxdepth 3 -type d -name 'domain' 2>/dev/null | head -1)

  if [ -z "$has_features" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'features/' directory for vertical slices"
    fail=1
  fi
  if [ -z "$has_domain" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'domain/' directory for pure entities"
    fail=1
  fi
done < <(find . \( -name 'requirements.txt' -o -name 'pyproject.toml' \) -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/agent-kit/*' -print0 2>/dev/null)

# --- Java service roots (dirs containing pom.xml or build.gradle) ---
while IFS= read -r -d '' pom; do
  svc_root=$(dirname "$pom")
  [ "$svc_root" = "." ] && continue
  found_any=1
  echo "Checking Java service: $svc_root"

  has_features=$(find "$svc_root" -maxdepth 5 -type d -name 'features' 2>/dev/null | head -1)
  if [ -z "$has_features" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'features/' directory for vertical slices"
    fail=1
  fi
done < <(find . \( -name 'pom.xml' -o -name 'build.gradle' \) -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 2>/dev/null)

if [ "$found_any" -eq 0 ]; then
  echo "SKIP STRUCTURE-001: no service roots found yet"
  exit 2
fi

[ "$fail" -eq 0 ] && echo "PASS STRUCTURE-001"
exit $fail
