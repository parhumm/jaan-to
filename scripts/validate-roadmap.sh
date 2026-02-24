#!/bin/bash
# jaan.to Roadmap Validation Hook
# Called by PreToolUse hook before Write operations
# Exit codes: 0 = proceed, 1 = warning, 2 = block

# Get the content being written (passed via stdin as JSON)
set -euo pipefail

INPUT=$(cat)

# Extract the content from JSON (tool_input.content)
CONTENT=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('content', ''))" 2>/dev/null)

# If we can't parse, allow (don't block on parsing errors)
if [ -z "$CONTENT" ]; then
    exit 0
fi

# Only validate roadmap files (check file path)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

if [[ ! "$FILE_PATH" =~ jaan-to/outputs/pm/.*/roadmap.*\.md$ ]]; then
    # Not a roadmap file, allow
    exit 0
fi

ISSUES=""

# ── Security checks ────────────────────────────────────────────────

# Check for secret patterns in content
SECRET_PATTERNS='(token=|password=|Bearer |ghp_[a-zA-Z0-9]|sk-[a-zA-Z0-9]|api_key=|AWS_SECRET|PRIVATE_KEY)'
if echo "$CONTENT" | grep -qEi "$SECRET_PATTERNS"; then
    echo "BLOCKED: Roadmap content contains potential secret/credential patterns. Remove sensitive data before writing." >&2
    exit 2
fi

# Check for path traversal attempts
if echo "$CONTENT" | grep -q '\.\./' ; then
    echo "BLOCKED: Roadmap content contains path traversal patterns (../). Remove before writing." >&2
    exit 2
fi

# ── Structure validation ───────────────────────────────────────────

# Check for required sections
if ! echo "$CONTENT" | grep -q "## Roadmap Items\|## Review Report\|## Validation Report\|## Reprioritization Report"; then
    ISSUES="${ISSUES}\n- Missing required section: 'Roadmap Items' or report section"
fi

if ! echo "$CONTENT" | grep -q "## Prioritization System\|## Summary\|## Results"; then
    ISSUES="${ISSUES}\n- Missing required section: 'Prioritization System' or report summary"
fi

# ── Content quality checks ─────────────────────────────────────────

# Warn if any item description exceeds 500 characters (check table rows)
LONG_LINES=$(echo "$CONTENT" | grep -n '^|' | awk -F'|' '{for(i=1;i<=NF;i++) if(length($i)>500) print NR": field "i" exceeds 500 chars"}')
if [ -n "$LONG_LINES" ]; then
    ISSUES="${ISSUES}\n- Warning: Some table fields exceed 500 characters"
fi

# ── Report results ─────────────────────────────────────────────────

if [ -n "$ISSUES" ]; then
    echo "Roadmap validation warnings:$ISSUES" >&2
    exit 1
fi

# All checks passed
echo "Roadmap validation passed"
exit 0
