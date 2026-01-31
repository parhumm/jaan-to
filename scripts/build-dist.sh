#!/bin/bash
# Build a clean jaan.to plugin distribution
# Excludes: docs (except bootstrap deps), roadmaps, deepresearches, website, changelog, etc.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST="$PLUGIN_ROOT/dist/jaan-to"

rm -rf "$PLUGIN_ROOT/dist"
mkdir -p "$DIST"

# Essential plugin directories
for dir in .claude-plugin skills hooks scripts agents; do
  if [ -d "$PLUGIN_ROOT/$dir" ]; then
    cp -r "$PLUGIN_ROOT/$dir" "$DIST/$dir"
  fi
done

# Copy .claude/settings.json only (not old standalone skills in .claude/skills/)
mkdir -p "$DIST/.claude"
cp "$PLUGIN_ROOT/.claude/settings.json" "$DIST/.claude/settings.json"

# Essential root files
cp "$PLUGIN_ROOT/CLAUDE.md" "$DIST/CLAUDE.md"

# Docs needed by bootstrap (copied to jaan-to/ on install)
mkdir -p "$DIST/docs/extending"
cp "$PLUGIN_ROOT/docs/STYLE.md" "$DIST/docs/STYLE.md"
cp "$PLUGIN_ROOT/docs/extending/create-skill.md" "$DIST/docs/extending/create-skill.md"

# Remove dev-only settings
rm -f "$DIST/.claude/settings.local.json"

# Count what was shipped
FILE_COUNT=$(find "$DIST" -type f | wc -l | tr -d ' ')
DIR_COUNT=$(find "$DIST" -type d | wc -l | tr -d ' ')

echo "=== jaan.to Plugin Distribution ==="
echo "Output: $DIST"
echo "Files: $FILE_COUNT"
echo "Directories: $DIR_COUNT"
echo ""
echo "Install with:"
echo "  claude --plugin-dir $DIST"
