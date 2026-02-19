#!/bin/bash
# Fired by PostToolUse:Write hook
# Checks docs files have Docusaurus frontmatter

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

# Only act on repo-level docs/ files (not website/docs/)
case "$FILE_PATH" in
  */website/docs/*) exit 0 ;;
  */docs/*.md) ;;
  *) exit 0 ;;
esac

# Skip excluded files
case "$FILE_PATH" in
  */STYLE.md|*/QUICKSTART-VIDEO.md|*/LESSON-TEMPLATE.md|*/development/*) exit 0 ;;
esac

# Check for frontmatter (file starts with ---)
if ! head -1 "$FILE_PATH" 2>/dev/null | grep -q '^---$'; then
  echo "" >&2
  echo "---" >&2
  echo "Doc updated: $(basename "$FILE_PATH")" >&2
  echo "" >&2
  echo "Missing Docusaurus frontmatter. Add to top of file:" >&2
  echo "  ---" >&2
  echo "  title: \"Page Title\"" >&2
  echo "  sidebar_position: 1" >&2
  echo "  ---" >&2
  echo "" >&2
  echo "Verify locally: cd website/docs && npm start" >&2
  echo "---" >&2
fi

exit 0
