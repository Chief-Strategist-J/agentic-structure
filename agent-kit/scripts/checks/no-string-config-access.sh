#!/usr/bin/env bash
# CONFIG-ACCESS-001 — no string-indexed config access in features/. Exit 0 = pass.
# Config must be accessed via typed struct/class/interface/dataclass, never config["key"] or config.get("key").
set -euo pipefail
fail=0

# TypeScript: config["key"] or config['key'] or process.env["KEY"] or process.env.KEY in features
ts_hits=$(perl -ne '
  if (/(config|conf|settings|env)\[["\x27](.*?)["\x27]\]|process\.env\./) {
    my $line = $_;
    unless ($line =~ /(\/\/|\/\*)/) {
      print "$ARGV:$.: $line";
    }
  }
' $(find . \( -name '*.ts' -o -name '*.tsx' \) -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null) 2>/dev/null \
  | grep -E '(features/|\(features\)/)' \
  | grep -vE '(lib/config|platform/config|config/index|_test\.|test\.|spec\.)' || true)

if [ -n "$ts_hits" ]; then
  echo "VIOLATION CONFIG-ACCESS-001 [TypeScript]: string-indexed config access in feature code:"
  echo "$ts_hits"
  fail=1
fi

# Go: os.Getenv("KEY") or viper.GetString("key") in features
go_hits=$(grep -RnE '(os\.Getenv|viper\.(Get|GetString|GetInt|GetBool))\(' \
  --include='*.go' . 2>/dev/null \
  | grep -E 'features/' \
  | grep -vE '(platform/config|_test\.go)' || true)
if [ -n "$go_hits" ]; then
  echo "VIOLATION CONFIG-ACCESS-001 [Go]: direct env/config access in feature code:"
  echo "$go_hits"
  fail=1
fi

# Kotlin: System.getenv("KEY") or config.getString("key") in features
kt_hits=$(grep -RnE '(System\.getenv|config\.(getString|getInt|getBoolean|property))\(' \
  --include='*.kt' . 2>/dev/null \
  | grep -E 'features/' \
  | grep -vE '(platform/config|test/|Test\.kt)' || true)
if [ -n "$kt_hits" ]; then
  echo "VIOLATION CONFIG-ACCESS-001 [Kotlin]: direct config/env access in feature code:"
  echo "$kt_hits"
  fail=1
fi

# Python: os.environ["KEY"] or os.getenv("KEY") in features
py_hits=$(grep -RnE '(os\.environ\[|os\.getenv\()' \
  --include='*.py' . 2>/dev/null \
  | grep -E 'features/' \
  | grep -vE '(platform/config|test_|tests/)' || true)
if [ -n "$py_hits" ]; then
  echo "VIOLATION CONFIG-ACCESS-001 [Python]: direct os.environ/os.getenv in feature code:"
  echo "$py_hits"
  fail=1
fi

# Java: System.getenv("KEY") in features
java_hits=$(grep -RnE 'System\.getenv\(' \
  --include='*.java' . 2>/dev/null \
  | grep -E 'features/' \
  | grep -vE '(platform/config|Test\.java|test/)' || true)
if [ -n "$java_hits" ]; then
  echo "VIOLATION CONFIG-ACCESS-001 [Java]: direct System.getenv in feature code:"
  echo "$java_hits"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS CONFIG-ACCESS-001"
exit $fail
