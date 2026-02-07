#!/bin/bash
# jaan.to Post-Commit Roadmap Reminder Hook
# Called by PostToolUse hook after Bash operations
# Suggests roadmap sync after significant git commits
# Exit codes: 0 = proceed (never blocks)

INPUT=$(cat)

# Extract command from JSON
COMMAND=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('command', ''))" 2>/dev/null)

# Only act on git commit commands
if [[ "$COMMAND" != *"git commit"* ]]; then
    exit 0
fi

# Skip roadmap/changelog commits (already doing roadmap work)
if [[ "$COMMAND" == *"docs(roadmap)"* ]] || [[ "$COMMAND" == *"docs(changelog)"* ]]; then
    exit 0
fi

# Skip release commits (handled by /roadmap-update release)
if [[ "$COMMAND" == *"release:"* ]]; then
    exit 0
fi

# Extract commit message prefix to check significance
MSG=$(echo "$COMMAND" | grep -oE '(feat|fix|refactor)\(' | head -1)
if [[ -z "$MSG" ]]; then
    MSG=$(echo "$COMMAND" | grep -oE '(feat|fix|refactor):' | head -1)
fi

# Only suggest for significant commits (feat/fix/refactor)
if [[ -z "$MSG" ]]; then
    exit 0
fi

# Get the latest commit hash
HASH=$(git log --oneline -1 --format='%h' 2>/dev/null)
SUBJECT=$(git log --oneline -1 --format='%s' 2>/dev/null)

# Output reminder to stderr
echo "" >&2
echo "---" >&2
echo "Commit: $HASH — $SUBJECT" >&2
echo "" >&2
echo "Consider syncing the roadmap:" >&2
echo "  /roadmap-update" >&2
echo "  /roadmap-update mark \"<task>\" done $HASH" >&2
echo "---" >&2

exit 0
