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
  && JAAN_ALLOW_LOCAL_WITH_GLOBAL=1 ./jaan-to setup "$TMP_PROJECT" --mode local >/dev/null \
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
echo "5) Duplicate guard and global mode"
TMP_PACK="$(mktemp -d /tmp/jaan-to-codex-pack-XXXXXX)"
mkdir -p "$TMP_PACK/skills/pm-prd-write"
cp "$PLUGIN_ROOT/skills/pm-prd-write/SKILL.md" "$TMP_PACK/skills/pm-prd-write/SKILL.md"

if cd "$CODEX_DIST" && ./jaan-to setup "$TMP_PROJECT" --mode global --pack-root "$TMP_PACK" >/tmp/jaan-to-global-dup.log 2>&1; then
  echo "  ✗ Duplicate guard unexpectedly allowed mixed local/global skills"
  ERRORS=$((ERRORS + 1))
else
  if grep -q "Duplicate jaan.to skill names detected" /tmp/jaan-to-global-dup.log; then
    echo "  ✓ Duplicate guard blocks ambiguous local/global mix"
  else
    echo "  ✗ Duplicate guard did not report expected message"
    ERRORS=$((ERRORS + 1))
  fi
fi

TMP_PROJECT_GLOBAL="$(mktemp -d /tmp/jaan-to-codex-validate-global-XXXXXX)"
if cd "$CODEX_DIST" && ./jaan-to setup "$TMP_PROJECT_GLOBAL" --mode global --pack-root "$TMP_PACK" >/dev/null; then
  echo "  ✓ Global mode setup succeeds on clean project"
else
  echo "  ✗ Global mode setup failed on clean project"
  ERRORS=$((ERRORS + 1))
fi
assert_true "$([ ! -d "$TMP_PROJECT_GLOBAL/.agents/skills" ] && echo true || echo false)" "Global mode avoids project-local skill symlinks"

echo ""
echo "6) Invalid skill handling"
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
rm -f /tmp/jaan-to-global-dup.log
rm -rf "$TMP_PROJECT"
rm -rf "$TMP_PROJECT_GLOBAL"
rm -rf "$TMP_PACK"

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "✗ Codex runner validation failed ($ERRORS issues)"
  exit 1
fi

echo "✓ Codex runner validation passed"
