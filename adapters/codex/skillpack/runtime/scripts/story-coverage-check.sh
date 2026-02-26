#!/usr/bin/env bash
# story-coverage-check.sh — Read-only advisory PostToolUse hook
# Prints a suggestion when a component is written without a sibling story file.
# NEVER writes files. Always exits 0.
set -euo pipefail

# Read tool input from stdin (JSON with file_path)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')

# Exit if we couldn't extract a file path
[ -z "${FILE_PATH:-}" ] && exit 0

# Only check .tsx and .jsx files
case "$FILE_PATH" in
  *.tsx|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip if the file IS a story file
case "$FILE_PATH" in
  *.stories.tsx|*.stories.jsx) exit 0 ;;
esac

# Skip if not in a components directory
case "$FILE_PATH" in
  */components/*) ;;
  *) exit 0 ;;
esac

# Check if a sibling story file exists
DIR=$(dirname "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH" | sed 's/\.\(tsx\|jsx\)$//')
STORY_FILE="${DIR}/${BASENAME}.stories.tsx"
STORY_FILE_JSX="${DIR}/${BASENAME}.stories.jsx"

if [ ! -f "$STORY_FILE" ] && [ ! -f "$STORY_FILE_JSX" ]; then
  echo "Component written without story file. Consider: /jaan-to:frontend-story-generate \"${FILE_PATH}\""
fi

exit 0
