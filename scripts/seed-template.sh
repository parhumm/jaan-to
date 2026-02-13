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
DEST="${PROJECT_DIR}/${TEMPLATES_DIR}/jaan-to:${SKILL_NAME}.template.md"

if [ ! -f "$SOURCE" ]; then
  echo "{\"status\": \"error\", \"message\": \"Plugin template not found for skill: ${SKILL_NAME}\"}"
  exit 1
fi

if [ -f "$DEST" ]; then
  echo "{\"status\": \"skipped\", \"message\": \"Project template already exists\", \"path\": \"${TEMPLATES_DIR}/jaan-to:${SKILL_NAME}.template.md\"}"
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
cp "$SOURCE" "$DEST"
echo "{\"status\": \"seeded\", \"path\": \"${TEMPLATES_DIR}/jaan-to:${SKILL_NAME}.template.md\"}"
