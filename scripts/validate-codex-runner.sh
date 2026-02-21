#!/bin/bash
# validate-codex-runner.sh — Codex runner contract validation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/lib/runtime-contract.sh
source "$PLUGIN_ROOT/scripts/lib/runtime-contract.sh"

CODEX_DIST="$(runtime_dist_dir codex)"
RUNNER="$CODEX_DIST/jaan-to"
ERRORS=0

assert_true() {
  local condition="$1"
  local label="$2"
  if [ "$condition" = "true" ]; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== Codex Runner Validation ==="

if [ "${SKIP_BUILD:-0}" != "1" ]; then
  echo "Building Codex distribution..."
  bash "$PLUGIN_ROOT/scripts/build-target.sh" codex
fi

echo ""
echo "1) Runner presence"
assert_true "$([ -f "$RUNNER" ] && echo true || echo false)" "Runner file exists"
assert_true "$([ -x "$RUNNER" ] && echo true || echo false)" "Runner is executable"

echo ""
echo "2) Skill listing parity"
SOURCE_COUNT="$(find "$PLUGIN_ROOT/skills" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
LIST_COUNT="$(cd "$CODEX_DIST" && ./jaan-to list --count)"
echo "  Source SKILL.md count: $SOURCE_COUNT"
echo "  Runner command count: $LIST_COUNT"
assert_true "$([ "$SOURCE_COUNT" -eq "$LIST_COUNT" ] && echo true || echo false)" "Runner list count matches source"

echo ""
echo "3) Dry-run smoke"
TMP_PROJECT="$(mktemp -d /tmp/jaan-to-codex-validate-XXXXXX)"
if cd "$CODEX_DIST" \
  && ./jaan-to setup "$TMP_PROJECT" >/dev/null \
  && CODEX_PROJECT_DIR="$TMP_PROJECT" ./jaan-to run /jaan-to:pm-prd-write "smoke" --dry-run >/dev/null; then
  echo "  ✓ Dry-run command succeeds"
else
  echo "  ✗ Dry-run command failed"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "4) Codex native skills installation"
INSTALLED_COUNT="$(find -L "$TMP_PROJECT/.agents/skills" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
echo "  Installed SKILL.md count: $INSTALLED_COUNT"
assert_true "$([ "$INSTALLED_COUNT" -eq "$SOURCE_COUNT" ] && echo true || echo false)" "Installed .agents/skills count matches source"
assert_true "$([ -f "$TMP_PROJECT/AGENTS.md" ] && echo true || echo false)" "Project AGENTS.md exists after setup"

echo ""
echo "5) Invalid skill handling"
if cd "$CODEX_DIST" && ./jaan-to run /jaan-to:not-real "smoke" --dry-run >/tmp/jaan-to-invalid-skill.log 2>&1; then
  echo "  ✗ Invalid skill unexpectedly succeeded"
  ERRORS=$((ERRORS + 1))
else
  if grep -q "Did you mean" /tmp/jaan-to-invalid-skill.log; then
    echo "  ✓ Invalid skill returns suggestions"
  else
    echo "  ✗ Invalid skill did not return suggestions"
    ERRORS=$((ERRORS + 1))
  fi
fi

rm -f /tmp/jaan-to-invalid-skill.log
rm -rf "$TMP_PROJECT"

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "✗ Codex runner validation failed ($ERRORS issues)"
  exit 1
fi

echo "✓ Codex runner validation passed"
