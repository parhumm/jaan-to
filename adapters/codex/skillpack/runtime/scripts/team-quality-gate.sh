#!/bin/bash
# jaan.to Agent Teams — TaskCompleted Quality Gate
# Runs when a task is being marked complete in agent teams.
# Exit code 2 = block completion + send feedback message.
# Exit code 0 = allow completion.
# Stdout cap: ≤1,200 chars (~300 tokens)

set -euo pipefail

INPUT=$(cat)

# Extract task description from hook input
TASK_DESC=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('task_description', data.get('description', '')))
" 2>/dev/null)

if [ -z "$TASK_DESC" ]; then
  exit 0
fi

# Load configuration
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

if [ -f "${PLUGIN_DIR}/scripts/lib/config-loader.sh" ]; then
  source "${PLUGIN_DIR}/scripts/lib/config-loader.sh"
  load_config
else
  exit 0
fi

# Check if quality gate is enabled
QUALITY_GATE=$(get_config "agent_teams_quality_gate" "true")
if [ "$QUALITY_GATE" != "true" ]; then
  exit 0
fi

# Check if this is a jaan-to skill output task
# Look for skill output patterns in task description
if echo "$TASK_DESC" | grep -qE '(prd-write|scaffold|test-generate|api-contract|data-model)'; then
  # Key output tasks — check if output file exists and has content
  OUTPUT_PATH=$(echo "$TASK_DESC" | grep -oE 'jaan-to/outputs/[^ ]+' | head -1)

  if [ -n "$OUTPUT_PATH" ] && [ -d "$PROJECT_DIR/$OUTPUT_PATH" ]; then
    # Check for empty output directory
    FILE_COUNT=$(find "$PROJECT_DIR/$OUTPUT_PATH" -type f 2>/dev/null | wc -l)
    if [ "$FILE_COUNT" -eq 0 ]; then
      echo "Quality gate: Output directory is empty ($OUTPUT_PATH). Ensure the skill completed successfully before marking done."
      exit 2
    fi
  fi
fi

# Allow completion
exit 0
