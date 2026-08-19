#!/usr/bin/env bash
# RULE-ENGINE-LEVELS-001 — bans if-else branching for business decisions in features across Go, Kotlin, TS, Python, Java.
set -euo pipefail
fail=0

hits=$(perl -ne '
  if (/\b(if|elif)\b.*[:{]/ && !/\b(err|ctx|ok|exists|found|valid|None|self)\b/i) {
    my $file = $ARGV;
    my $line_num = $.;
    my $code = $_;
    if ($code =~ /\b(if|elif)\b.*(status|price|amount|tier|score|eligible|role|type|permission|rule|plan|quota|limit|discount|tax|fee)/i) {
      unless ($code =~ /(\/\/ justified:|\/\* justified:|# justified:)/) {
        print "$file:$line_num: $code";
      }
    }
  }
' $(find . -path '*/features/*' \( -name '*.go' -o -name '*.kt' -o -name '*.ts' -o -name '*.py' -o -name '*.java' \) -not -name '*_test.*' -not -name 'test_*' 2>/dev/null) 2>/dev/null || true)

if [ -n "$hits" ]; then
  echo "VIOLATION RULE-ENGINE-LEVELS-001: raw if-else decision branching found in feature code:"
  echo "$hits"
  echo "  → See §2 & §6: Business decision logic MUST use the 3-level Rules Engine:"
  echo "      - Level 1: Atomic rule (single condition -> single result)"
  echo "      - Level 2: Compound rule (AND / OR / NOT combination of Level 1 rules)"
  echo "      - Level 3: Policy (composed of Level 1 & Level 2 with custom resolver)"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS RULE-ENGINE-LEVELS-001"
exit $fail
