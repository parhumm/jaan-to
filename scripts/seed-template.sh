#!/bin/bash
# jaan.to Template Seeder
# Copies a skill's plugin template into the project templates directory
# Usage: seed-template.sh <skill-name>
# Called by pre-execution protocol Step C
set -euo pipefail

SKILL_NAME="${1:?Usage: seed-template.sh <skill-name>}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Load config to resolve paths
source "${PLUGIN_DIR}/scripts/lib/config-loader.sh"
load_config

TEMPLATES_DIR=$(get_config "paths_templates" "jaan-to/templates")
SOURCE="${PLUGIN_DIR}/skills/${SKILL_NAME}/template.md"
DEST="${PROJECT_DIR}/${TEMPLATES_DIR}/jaan-to-${SKILL_NAME}.template.md"
LEGACY_DEST="${PROJECT_DIR}/${TEMPLATES_DIR}/jaan-to:${SKILL_NAME}.template.md"

if [ ! -f "$SOURCE" ]; then
  echo "{\"status\": \"error\", \"message\": \"Plugin template not found for skill: ${SKILL_NAME}\"}"
  exit 1
fi

# Migrate legacy colon-prefixed file if it exists
if [ -f "$LEGACY_DEST" ]; then
  if [ ! -f "$DEST" ]; then
    mv "$LEGACY_DEST" "$DEST"
  elif diff -q "$LEGACY_DEST" "$DEST" >/dev/null 2>&1; then
    rm "$LEGACY_DEST"
  else
    CONFLICT_NAME="jaan-to-${SKILL_NAME}.template.legacy-colon.md"
    mv "$LEGACY_DEST" "${PROJECT_DIR}/${TEMPLATES_DIR}/${CONFLICT_NAME}"
    echo "WARNING: conflicting template files for ${SKILL_NAME}. Legacy preserved as ${CONFLICT_NAME}." >&2
  fi
fi

if [ -f "$DEST" ]; then
  echo "{\"status\": \"skipped\", \"message\": \"Project template already exists\", \"path\": \"${TEMPLATES_DIR}/jaan-to-${SKILL_NAME}.template.md\"}"
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
cp "$SOURCE" "$DEST"
echo "{\"status\": \"seeded\", \"path\": \"${TEMPLATES_DIR}/jaan-to-${SKILL_NAME}.template.md\"}"
