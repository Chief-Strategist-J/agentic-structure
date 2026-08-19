#!/usr/bin/env bash
# STRUCTURE-001 — validates vertical-slice folder structure for Go, Kotlin, Next.js services.
# Rejects layered-architecture anti-patterns (flat controllers/, services/, models/ dirs).
# Exit 0 = pass, 1 = violation, 2 = no services found yet (skip).
set -euo pipefail
fail=0
found_any=0

# --- Anti-pattern detection (applies everywhere) ---
# These flat top-level dirs are the layered-architecture smell we reject
LAYERED_ANTI='(^|/)src/(controllers|services|models|repositories|handlers)/$'
for d in $(find . -maxdepth 4 -type d 2>/dev/null | grep -E '(^|/)(controllers|services|models|repositories|handlers)$' | grep -vE '(node_modules|vendor|.git|__tests__|test|generated|platform)' || true); do
  # Only flag if it's a top-level structural dir (not inside features/)
  if echo "$d" | grep -qvE '(features/|adapters/|internal/)'; then
    echo "VIOLATION STRUCTURE-001: layered-architecture anti-pattern detected: $d"
    echo "  → Use vertical-slice: internal/features/<feature>/ (Go), features/<feature>/ (Kotlin/TS)"
    fail=1
    found_any=1
  fi
done

# --- Go services (dirs containing go.mod) ---
while IFS= read -r -d '' gomod; do
  svc_root=$(dirname "$gomod")
  found_any=1
  echo "Checking Go service: $svc_root"

  # Required dirs
  for required in "cmd" "internal/features" "internal/domain" "internal/ports" "internal/adapters" "internal/platform"; do
    if [ ! -d "$svc_root/$required" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: missing required directory: $required"
      fail=1
    fi
  done

  # Banned flat dirs at service root
  for banned in "handlers" "controllers" "services" "models" "repositories"; do
    if [ -d "$svc_root/$banned" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: banned flat directory: $banned/ (use internal/features/<feature>/ instead)"
      fail=1
    fi
  done
done < <(find . -name 'go.mod' -not -path '*/vendor/*' -not -path '*/.git/*' -print0 2>/dev/null)

# --- Kotlin services (dirs containing build.gradle.kts or build.gradle) ---
while IFS= read -r -d '' gradle; do
  svc_root=$(dirname "$gradle")
  # Skip sub-project build files (only check root build files)
  if [ -f "$svc_root/settings.gradle.kts" ] || [ -f "$svc_root/settings.gradle" ] || [ "$svc_root" = "." ]; then
    found_any=1
    echo "Checking Kotlin service: $svc_root"

    # Check for vertical-slice dirs (at least features/ and domain/ should exist)
    has_features=$(find "$svc_root" -maxdepth 3 -type d -name 'features' 2>/dev/null | head -1)
    has_domain=$(find "$svc_root" -maxdepth 3 -type d -name 'domain' 2>/dev/null | head -1)
    has_ports=$(find "$svc_root" -maxdepth 3 -type d -name 'ports' 2>/dev/null | head -1)

    if [ -z "$has_features" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'features/' directory for vertical slices"
      fail=1
    fi
    if [ -z "$has_domain" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'domain/' directory for pure entities"
      fail=1
    fi
    if [ -z "$has_ports" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'ports/' directory for interfaces"
      fail=1
    fi

    # Banned flat dirs
    for banned in "controller" "service" "repository" "model"; do
      if find "$svc_root/src" -maxdepth 4 -type d -name "$banned" 2>/dev/null | grep -q .; then
        echo "VIOLATION STRUCTURE-001 [$svc_root]: banned flat directory: $banned/ (use features/<feature>/ instead)"
        fail=1
      fi
    done
  fi
done < <(find . \( -name 'build.gradle.kts' -o -name 'build.gradle' \) -not -path '*/vendor/*' -not -path '*/.git/*' -not -path '*/node_modules/*' -print0 2>/dev/null)

# --- Next.js web (dirs containing next.config.*) ---
while IFS= read -r -d '' nextcfg; do
  svc_root=$(dirname "$nextcfg")
  found_any=1
  echo "Checking Next.js service: $svc_root"

  # Required: app/ directory
  if [ ! -d "$svc_root/app" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'app/' directory"
    fail=1
  fi

  # Required: lib/ directory
  if [ ! -d "$svc_root/lib" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: missing 'lib/' directory (data fetching, rules, transforms go here)"
    fail=1
  fi

  # Banned: pages/api/ (old Next.js pattern)
  if [ -d "$svc_root/pages/api" ]; then
    echo "VIOLATION STRUCTURE-001 [$svc_root]: banned 'pages/api/' directory (use app/ router with route handlers)"
    fail=1
  fi

  # Banned: flat utils/, helpers/ (should be lib/transforms/)
  for banned in "utils" "helpers"; do
    if [ -d "$svc_root/$banned" ]; then
      echo "VIOLATION STRUCTURE-001 [$svc_root]: banned flat '$banned/' directory (use lib/transforms/ instead)"
      fail=1
    fi
  done
done < <(find . \( -name 'next.config.ts' -o -name 'next.config.js' -o -name 'next.config.mjs' \) -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 2>/dev/null)

if [ "$found_any" -eq 0 ]; then
  echo "SKIP STRUCTURE-001: no Go/Kotlin/Next.js service roots found yet"
  exit 2
fi

[ "$fail" -eq 0 ] && echo "PASS STRUCTURE-001"
exit $fail
