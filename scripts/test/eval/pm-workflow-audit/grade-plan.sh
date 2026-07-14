#!/usr/bin/env bash
# grade-plan.sh — deterministic (Tier 2) grader for a generated pm-workflow-audit
# conversion plan. Grades OUTCOME STRUCTURE (not the path the skill took), per
# EVAL-02. Use inside the eval harness or ad hoc on a real output.
#
# Run: bash grade-plan.sh <path-to-plan.md>
# Exit 0 if all required checks pass, 1 otherwise.

set -uo pipefail

PLAN="${1:-}"
[ -f "$PLAN" ] || { echo "usage: grade-plan.sh <plan.md>  (file not found: '$PLAN')" >&2; exit 2; }

PASS=0; FAIL=0
check() { # desc, test-cmd...
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "  ✓ $desc"; PASS=$((PASS+1)); else echo "  ✗ $desc"; FAIL=$((FAIL+1)); fi
}
has() { grep -qiE "$1" "$PLAN"; }

echo "Grading: $PLAN"
echo "── Required sections (reference §7) ──"
check "Verdict / maturity"              has '(^|\s)verdict|maturity'
check "Workflow understanding + graph"  has 'workflow understanding|execution graph'
check "Knowledge map"                   has 'knowledge map'
check "Existing-workflow inventory"     has 'inventory'
check "Reliability / autonomy contract" has 'autonomy|pass\^k|reliability'
check "Injection-defense checklist"     has 'injection|trifecta|rule of two'
check "Phased plan"                     has 'phase(d)? plan|phase 1|phase 2'
check "First implementation slice"      has 'first .*slice|implementation slice'
check "Anti-over-engineering pass"      has 'anti-over-engineering|over-engineering'

echo "── Quality gates ──"
# Evidence: at least 3 audit-ID citations OR file refs OR explicit [ASSUMPTION] markers.
EVID=$(grep -oE '\[(SEC|TOK|EVAL|LOOP|MULTI|OBS|GATE|PERM|CTX|RULE|TOOL|REC)-[0-9]+\]|\[ASSUMPTION\]' "$PLAN" 2>/dev/null | wc -l | tr -d ' ')
check "≥3 evidence/ID citations (found: $EVID)" test "$EVID" -ge 3
# Trifecta legs mapped.
check "Trifecta legs mapped per stage"  has 'trifecta|leg (a|b|c)|untrusted.*private.*(action|external)'
# No unresolved template placeholders left in a real plan.
check "No unfilled {{placeholders}}"    test -z "$(grep -oE '\{\{[a-z_]+\}\}' "$PLAN" 2>/dev/null | head -1)"

echo
echo "  grade-plan: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
