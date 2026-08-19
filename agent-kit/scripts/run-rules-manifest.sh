#!/usr/bin/env bash
# Reads platform/rules-manifest.yaml and runs every rule's check script.
# Exit code: 0 if no `blocking` rule failed. Non-zero otherwise.
# `required-with-justification` failures print but never flip the exit code —
# they must be surfaced to a human, not silently gated.
#
# Usage:
#   scripts/run-rules-manifest.sh              # run everything
#   scripts/run-rules-manifest.sh --changed    # only checks relevant to git-changed files (best effort)

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if ! python3 -c "import yaml" 2>/dev/null; then
  echo "Installing pyyaml (one-time)..."
  pip install pyyaml --break-system-packages --quiet 2>/dev/null || pip3 install pyyaml --quiet
fi

python3 - "$@" << 'PYEOF'
import subprocess, sys, yaml, os

with open("platform/rules-manifest.yaml") as f:
    manifest = yaml.safe_load(f)

blocking_failed = []
justification_needed = []
skipped = []
passed = []

for rule in manifest.get("rules", []):
    rid = rule["id"]
    severity = rule["severity"]
    check = rule.get("check")
    if not check:
        continue
    if not os.path.exists(check):
        print(f"SKIP  {rid}: check script not found at {check}")
        skipped.append(rid)
        continue
    result = subprocess.run(["bash", check], capture_output=True, text=True)
    out = (result.stdout + result.stderr).strip()
    if result.returncode == 0:
        print(f"PASS  {rid}")
        passed.append(rid)
    elif result.returncode == 2:
        print(f"SKIP  {rid} (unverified — tool/spec not available in this environment)")
        print("      " + out.replace("\n", "\n      "))
        skipped.append(rid)
    else:
        if severity == "blocking":
            print(f"FAIL  {rid}  [blocking]")
            blocking_failed.append(rid)
        elif severity == "required-with-justification":
            print(f"FLAG  {rid}  [required-with-justification — needs explicit human sign-off, not a silent pass]")
            justification_needed.append(rid)
        else:
            print(f"WARN  {rid}  [advisory]")
        print("      " + out.replace("\n", "\n      "))

print()
print(f"Summary: {len(passed)} passed, {len(blocking_failed)} blocking failures, "
      f"{len(justification_needed)} need justification, {len(skipped)} skipped/unverified.")

if blocking_failed:
    print()
    print("BLOCKING rules failed — this change is NOT ready:")
    for rid in blocking_failed:
        print(f"  - {rid}")
    sys.exit(1)

if justification_needed:
    print()
    print("required-with-justification findings exist — surface these explicitly, do not proceed silently:")
    for rid in justification_needed:
        print(f"  - {rid}")

sys.exit(0)
PYEOF
