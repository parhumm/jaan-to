#!/bin/bash
# jaan.to PRD Validation Hook
# Called by PreToolUse hook before Write operations
# Exit codes: 0 = proceed, 1 = warning, 2 = block

# Get the content being written (passed via stdin as JSON)
INPUT=$(cat)

# Extract the content from JSON (tool_input.content)
CONTENT=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('content', ''))" 2>/dev/null)

# If we can't parse, allow (don't block on parsing errors)
if [ -z "$CONTENT" ]; then
    exit 0
fi

# Only validate PRD files (check file path)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

if [[ ! "$FILE_PATH" =~ \jaan-to/outputs/pm/.*/prd\.md$ ]]; then
    # Not a PRD file, allow
    exit 0
fi

# Validate required sections
MISSING_SECTIONS=""

if ! echo "$CONTENT" | grep -q "## Problem Statement"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Problem Statement"
fi

if ! echo "$CONTENT" | grep -q "## Success Metrics"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Success Metrics"
fi

if ! echo "$CONTENT" | grep -q "## Scope"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Scope"
fi

if ! echo "$CONTENT" | grep -q "## User Stories"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- User Stories"
fi

# If sections are missing, block with explanation
if [ -n "$MISSING_SECTIONS" ]; then
    echo "PRD validation failed. Missing required sections:$MISSING_SECTIONS" >&2
    exit 2
fi

# All checks passed
echo "PRD validation passed"
exit 0
