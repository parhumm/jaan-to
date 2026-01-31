#!/bin/bash
# jaan.to Feedback Capture Hook
# Called by PostToolUse hook after Write operations
# Exit codes: 0 = proceed

INPUT=$(cat)

# Extract file path from JSON
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

# Only act when the file path matches .jaan-to/
if [[ "$FILE_PATH" != *.jaan-to/* ]]; then
    exit 0
fi

# Only prompt for outputs (skip internal files)
if [[ ! "$FILE_PATH" =~ \.jaan-to/outputs/ ]]; then
    exit 0
fi

# Output feedback prompt to stderr (shown to user)
echo "" >&2
echo "---" >&2
echo "Output created: $FILE_PATH" >&2
echo "" >&2
echo "Have feedback to improve future outputs?" >&2
echo "Use: /jaan-to:jaan-learn-add \"skill-name\" \"lesson\"" >&2
echo "---" >&2

exit 0
