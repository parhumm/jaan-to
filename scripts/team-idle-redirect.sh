#!/bin/bash
# jaan.to Agent Teams — TeammateIdle Hook
# Runs when a teammate is about to go idle.
# Exit code 2 = send feedback to keep teammate working.
# Exit code 0 = allow idle.
# Stdout cap: ≤1,200 chars (~300 tokens)

INPUT=$(cat)

# Extract teammate info from hook input
TEAMMATE_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('teammate_name', data.get('name', '')))
" 2>/dev/null)

if [ -z "$TEAMMATE_NAME" ]; then
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

# Check if agent teams is enabled
TEAMS_ENABLED=$(get_config "agent_teams_enabled" "false")
if [ "$TEAMS_ENABLED" != "true" ]; then
  exit 0
fi

# Extract role from teammate name (e.g., "backend" from "backend-engineer")
ROLE=$(echo "$TEAMMATE_NAME" | grep -oE '^(pm|ux|backend|frontend|qa|devops|sec|detect-[a-z]+)' || true)

if [ -z "$ROLE" ]; then
  exit 0
fi

# Check for pending messages this teammate should relay
# This is a lightweight check — the lead handles complex coordination
echo "Teammate '$TEAMMATE_NAME' ($ROLE) is idle. Check if there are unclaimed tasks for this role, or shut down to free context."
exit 2
