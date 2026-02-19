#!/bin/bash
# jaan.to Version Bump Script
# Usage: ./scripts/bump-version.sh 3.15.0
# Updates version in all 3 required locations

set -euo pipefail

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 3.15.0"
  exit 1
fi

# Determine script location and plugin root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Updating version to: $VERSION"
echo "Plugin root: $PLUGIN_ROOT"

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed."
  echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi

# Update plugin.json
echo "Updating .claude-plugin/plugin.json..."
jq --arg v "$VERSION" '.version = $v' "$PLUGIN_ROOT/.claude-plugin/plugin.json" > tmp.$$.json \
  && mv tmp.$$.json "$PLUGIN_ROOT/.claude-plugin/plugin.json"

# Update marketplace.json (both top-level and plugins[0])
echo "Updating .claude-plugin/marketplace.json..."
jq --arg v "$VERSION" '.version = $v | .plugins[0].version = $v' "$PLUGIN_ROOT/.claude-plugin/marketplace.json" > tmp.$$.json \
  && mv tmp.$$.json "$PLUGIN_ROOT/.claude-plugin/marketplace.json"

echo ""
echo "Updated:"
echo "  .claude-plugin/plugin.json → $VERSION"
echo "  .claude-plugin/marketplace.json → $VERSION (2 places)"

# Verify all versions match
V1=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/plugin.json")
V2=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/marketplace.json")
V3=$(jq -r '.plugins[0].version' "$PLUGIN_ROOT/.claude-plugin/marketplace.json")

echo ""
echo "Verification:"
echo "  plugin.json:                  $V1"
echo "  marketplace.json (top):       $V2"
echo "  marketplace.json (plugins[0]): $V3"

if [[ "$V1" == "$VERSION" ]] && [[ "$V2" == "$VERSION" ]] && [[ "$V3" == "$VERSION" ]]; then
  echo ""
  echo "✓ All versions updated successfully to $VERSION"
  exit 0
else
  echo ""
  echo "✗ Version mismatch detected!"
  exit 1
fi
