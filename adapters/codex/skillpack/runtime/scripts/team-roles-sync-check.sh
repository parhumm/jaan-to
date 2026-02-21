#!/bin/bash
# jaan.to Agent Teams — Roles.md Drift Detection
# PostToolUse hook: runs after Write to skills/*/SKILL.md
# Warns if a skill with a known role prefix is not registered in team-ship/roles.md
# Exit codes: 0 = proceed (always non-blocking)
# Stdout cap: ≤1,200 chars (~300 tokens)

set -euo pipefail

INPUT=$(cat)

# Extract file path from hook input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null)

# Guard: Must have a file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Guard: Only check writes to skills/*/SKILL.md
if [[ ! "$FILE_PATH" =~ skills/[^/]+/SKILL\.md$ ]]; then
  exit 0
fi

PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
ROLES_FILE="$PLUGIN_DIR/skills/team-ship/roles.md"

# Guard: roles.md must exist
if [ ! -f "$ROLES_FILE" ]; then
  exit 0
fi

# Extract skill name from path: skills/{name}/SKILL.md or full path
SKILL_NAME=$(echo "$FILE_PATH" | sed -E 's|.*/skills/([^/]+)/SKILL\.md$|\1|')

# Guard: Don't check team-ship itself or internal skills
if [ "$SKILL_NAME" = "team-ship" ] || [ "$SKILL_NAME" = "skill-create" ] || [ "$SKILL_NAME" = "skill-update" ]; then
  exit 0
fi

# Extract role prefix (known roles only)
ROLE_PREFIX=$(echo "$SKILL_NAME" | grep -oE '^(pm|ux|backend|frontend|qa|devops|sec|data|growth|delivery|sre|support|release|detect)-' | sed 's/-$//')

# Guard: Must have a recognized role prefix
if [ -z "$ROLE_PREFIX" ]; then
  exit 0
fi

# Check if this skill appears in roles.md
if ! grep -q "$SKILL_NAME" "$ROLES_FILE" 2>/dev/null; then
  echo "NOTE: Skill '$SKILL_NAME' (role: $ROLE_PREFIX) is not in team-ship/roles.md. Add it to enable agent team orchestration."
fi

exit 0
