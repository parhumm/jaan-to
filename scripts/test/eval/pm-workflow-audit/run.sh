#!/usr/bin/env bash
# run.sh — pm-workflow-audit eval harness runner (Tier 2, deterministic).
# Tier 3 (semantic, model calls) is opt-in and documented in README.md.
#
# Run: bash scripts/test/eval/pm-workflow-audit/run.sh

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RC=0
echo "═══════════════════════════════════════"
echo "  pm-workflow-audit eval harness (Tier 2)"
echo "═══════════════════════════════════════"

echo; echo "▶ session-reader contract test"
bash "$SCRIPT_DIR/session-reader.test.sh" || RC=1

# Grade any real generated plans that exist (non-fatal if none yet).
OUT_GLOB="${JAAN_OUTPUTS_DIR:-jaan-to/outputs}/pm/workflow-audit"/*/*.md
shopt -s nullglob
plans=( $OUT_GLOB )
shopt -u nullglob
if [ "${#plans[@]}" -gt 0 ]; then
  echo; echo "▶ grading ${#plans[@]} existing plan(s)"
  for p in "${plans[@]}"; do bash "$SCRIPT_DIR/grade-plan.sh" "$p" || RC=1; done
else
  echo; echo "▶ grade-plan: no generated plans found yet (skip) — run /jaan-to:pm-workflow-audit first"
fi

echo; [ "$RC" -eq 0 ] && echo "✓ eval harness passed" || echo "✗ eval harness had failures"
exit "$RC"
