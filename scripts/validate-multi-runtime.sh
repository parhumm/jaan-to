#!/bin/bash
# validate-multi-runtime.sh — Build and validate both runtime distributions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_ROOT="$PLUGIN_ROOT/dist"
CLAUDE_DIST="$DIST_ROOT/jaan-to-claude"
CODEX_DIST="$DIST_ROOT/jaan-to-codex"
ERRORS=0

assert_exists() {
  local path="$1"
  local label="$2"
  if [ -e "$path" ]; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label (missing: $path)"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== Multi-Runtime Distribution Validation ==="
echo "Building both targets..."
bash "$PLUGIN_ROOT/scripts/build-all-targets.sh"
echo ""

echo "1) Dist directories"
assert_exists "$CLAUDE_DIST" "Claude dist directory exists"
assert_exists "$CODEX_DIST" "Codex dist directory exists"
if find "$DIST_ROOT" -mindepth 1 -maxdepth 1 -type d -name "jaan-to" | grep -q .; then
  echo "  ✗ Legacy Claude dist directory name detected"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ Legacy Claude dist path not present"
fi
echo ""

echo "2) Claude package essentials"
assert_exists "$CLAUDE_DIST/.claude-plugin/plugin.json" "Claude plugin manifest exists"
assert_exists "$CLAUDE_DIST/hooks/hooks.json" "Claude hooks manifest exists"
assert_exists "$CLAUDE_DIST/CLAUDE.md" "Claude context file exists"
echo ""

echo "3) Codex package essentials"
assert_exists "$CODEX_DIST/AGENTS.md" "Codex AGENTS.md exists"
assert_exists "$CODEX_DIST/scripts/codex-bootstrap.sh" "Codex bootstrap script exists"
echo ""

echo "4) Shared-source parity checks"
assert_exists "$CLAUDE_DIST/skills" "Claude dist skills directory exists"
assert_exists "$CODEX_DIST/skills" "Codex dist skills directory exists"

SOURCE_SKILL_COUNT=$(find "$PLUGIN_ROOT/skills" -type f -name "SKILL.md" | wc -l | tr -d ' ')
CLAUDE_SKILL_COUNT=$(find "$CLAUDE_DIST/skills" -type f -name "SKILL.md" | wc -l | tr -d ' ')
CODEX_SKILL_COUNT=$(find "$CODEX_DIST/skills" -type f -name "SKILL.md" | wc -l | tr -d ' ')

echo "  Source SKILL.md count: $SOURCE_SKILL_COUNT"
echo "  Claude dist SKILL.md count: $CLAUDE_SKILL_COUNT"
echo "  Codex dist SKILL.md count: $CODEX_SKILL_COUNT"

if [ "$CLAUDE_SKILL_COUNT" -ne "$SOURCE_SKILL_COUNT" ]; then
  echo "  ✗ Claude skill count mismatch"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ Claude skill count matches source"
fi

if [ "$CODEX_SKILL_COUNT" -ne "$SOURCE_SKILL_COUNT" ]; then
  echo "  ✗ Codex skill count mismatch"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ Codex skill count matches source"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "✗ Multi-runtime validation failed ($ERRORS issues)"
  exit 1
fi

echo "✓ Multi-runtime validation passed"
