#!/bin/bash
# validate-claude-compat.sh — Claude runtime compatibility guardrail.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/lib/runtime-contract.sh
source "$PLUGIN_ROOT/scripts/lib/runtime-contract.sh"

CLAUDE_DIST="$(runtime_dist_dir claude)"
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

assert_not_exists() {
  local path="$1"
  local label="$2"
  if [ -e "$path" ]; then
    echo "  ✗ $label (unexpected: $path)"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✓ $label"
  fi
}

echo "=== Claude Compatibility Validation ==="

if [ "${SKIP_BUILD:-0}" != "1" ]; then
  echo "Building Claude distribution..."
  bash "$PLUGIN_ROOT/scripts/build-target.sh" claude
fi

echo ""
echo "1) Required Claude artifacts"
while IFS= read -r required_path; do
  [ -n "$required_path" ] || continue
  assert_exists "$required_path" "$(basename "$required_path") present"
done < <(runtime_required_paths claude)

assert_exists "$CLAUDE_DIST/.claude-plugin/marketplace.json" "Claude marketplace manifest present"

echo ""
echo "2) No Codex-only router artifacts in Claude dist"
while IFS= read -r forbidden_path; do
  [ -n "$forbidden_path" ] || continue
  assert_not_exists "$forbidden_path" "$(basename "$forbidden_path") not present"
done < <(runtime_forbidden_in_claude_dist)

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "✗ Claude compatibility validation failed ($ERRORS issues)"
  exit 1
fi

echo "✓ Claude compatibility validation passed"
