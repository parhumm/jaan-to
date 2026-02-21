#!/bin/bash
# marketplace-sync-check.sh — Detect new skill directories not in marketplace.json skills[]
#
# PostToolUse hook (Write matcher): checks if a SKILL.md was written in a directory
# not yet listed in .claude-plugin/marketplace.json plugins[0].skills[].
#
# Outputs advisory message to stdout (injected into conversation context).
# Exit 0 always (advisory, never blocks).

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
MARKETPLACE="$PLUGIN_ROOT/.claude-plugin/marketplace.json"

# Only check if marketplace.json exists and has skills[]
[ -f "$MARKETPLACE" ] || exit 0
jq -e '.plugins[0].skills' "$MARKETPLACE" > /dev/null 2>&1 || exit 0

# Get the file that was written (from hook input)
TOOL_INPUT="${TOOL_INPUT:-}"
if [ -z "$TOOL_INPUT" ]; then
  exit 0
fi

# Extract file_path from tool input JSON
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[ -n "$FILE_PATH" ] || exit 0

# Only care about SKILL.md writes
[[ "$FILE_PATH" == */SKILL.md ]] || exit 0
[[ "$FILE_PATH" == */skills/*/SKILL.md ]] || exit 0

# Extract skill directory name
SKILL_NAME=$(basename "$(dirname "$FILE_PATH")")
SKILL_PATH="./skills/$SKILL_NAME"

# Check if this skill is in marketplace.json
if ! jq -e --arg p "$SKILL_PATH" '.plugins[0].skills | index($p)' "$MARKETPLACE" > /dev/null 2>&1; then
  echo "⚠ New skill '$SKILL_NAME' not in marketplace.json skills[] array."
  echo "  Add \"$SKILL_PATH\" to .claude-plugin/marketplace.json plugins[0].skills[]"
fi

exit 0
