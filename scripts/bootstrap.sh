#!/bin/bash
# jaan.to plugin — first-run bootstrap
# Usage: Runs via SessionStart hook on every session start
# Idempotent — safe to run multiple times

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"

# Opt-in: skip if project not initialized (jaan-to/ doesn't exist)
if [ ! -d "$PROJECT_DIR/jaan-to" ]; then
  cat <<RESULT
JAAN-TO: Project not initialized.
Before running any /jaan-to:* skill, recommend running /jaan-init first.
Without initialization, context files (tech.md, team.md, boundaries.md, settings.yaml) are missing and skill output quality will be degraded.
RESULT
  exit 0
fi

# Load configuration system
if [ -f "${PLUGIN_DIR}/scripts/lib/config-loader.sh" ]; then
  source "${PLUGIN_DIR}/scripts/lib/config-loader.sh"
  load_config
else
  echo "WARNING: config-loader.sh not found, using defaults" >&2
fi

# Resolve paths from config (with fallback defaults)
TEMPLATES_DIR=$(resolve_path "$(get_config 'paths_templates' 'jaan-to/templates')")
LEARN_DIR=$(resolve_path "$(get_config 'paths_learning' 'jaan-to/learn')")
CONTEXT_DIR=$(resolve_path "$(get_config 'paths_context' 'jaan-to/context')")
OUTPUTS_DIR=$(resolve_path "$(get_config 'paths_outputs' 'jaan-to/outputs')")
DOCS_DIR=$(resolve_path "$(get_config 'paths_docs' 'jaan-to/docs')")
CONFIG_DIR="jaan-to/config"

# Counters for reporting
CONTEXT_COPIED=0
TEMPLATES_COPIED=0
DOCS_COPIED=0
LEARN_COPIED=0
CONFIG_COPIED=0

# 1. Create all necessary directories (using resolved paths)
mkdir -p "$PROJECT_DIR/$OUTPUTS_DIR"
mkdir -p "$PROJECT_DIR/$LEARN_DIR"
mkdir -p "$PROJECT_DIR/$CONTEXT_DIR"
mkdir -p "$PROJECT_DIR/$TEMPLATES_DIR"
mkdir -p "$PROJECT_DIR/$CONFIG_DIR"
mkdir -p "$PROJECT_DIR/$DOCS_DIR"

# 2. Initialize project config if not exists
if [ ! -f "$PROJECT_DIR/$CONFIG_DIR/settings.yaml" ]; then
  if [ -f "$PLUGIN_DIR/scripts/seeds/settings.yaml" ]; then
    cp "$PLUGIN_DIR/scripts/seeds/settings.yaml" "$PROJECT_DIR/$CONFIG_DIR/settings.yaml"
    CONFIG_COPIED=1
  fi
fi

# 3.5. Migration: fix wrong default path examples in settings.yaml (issue #64)
if [ -f "$PROJECT_DIR/$CONFIG_DIR/settings.yaml" ] && grep -q 'artifacts/jaan-to' "$PROJECT_DIR/$CONFIG_DIR/settings.yaml" 2>/dev/null; then
  sed -i.bak \
    -e 's|# paths_templates: "docs/templates"|# paths_templates: "jaan-to/templates"|' \
    -e 's|# paths_learning: "docs/learning"|# paths_learning: "jaan-to/learn"|' \
    -e 's|# paths_context: "docs/context"|# paths_context: "jaan-to/context"|' \
    -e 's|# paths_outputs: "artifacts/jaan-to"|# paths_outputs: "jaan-to/outputs"|' \
    -e 's|# Uncomment and modify to change default locations|# These are the defaults — uncomment and modify to change locations|' \
    "$PROJECT_DIR/$CONFIG_DIR/settings.yaml" && rm -f "$PROJECT_DIR/$CONFIG_DIR/settings.yaml.bak"
fi

# 4. Copy context files (skip if exists)
if [ -d "$PLUGIN_DIR/scripts/seeds" ]; then
  for context_file in "$PLUGIN_DIR/scripts/seeds"/*.md; do
    [ -f "$context_file" ] || continue
    filename=$(basename "$context_file")
    dest="$PROJECT_DIR/$CONTEXT_DIR/$filename"
    if [ ! -f "$dest" ]; then
      cp "$context_file" "$dest"
      CONTEXT_COPIED=$((CONTEXT_COPIED + 1))
    fi
  done
fi

# 5. Templates — loaded from plugin at runtime (lazy loading)
# On first use, pre-execution protocol Step C offers to seed into $TEMPLATES_DIR
# Users can also manually copy templates for customization
# See: docs/guides/customization.md

# 6. Docs — skills read STYLE.md and create-skill.md from plugin source at runtime
# (${CLAUDE_PLUGIN_ROOT}/docs/STYLE.md, ${CLAUDE_PLUGIN_ROOT}/docs/extending/create-skill.md)
# No project copy needed. Research dir created on demand by pm-research-about.

# 7. Learning — loaded from plugin at runtime, project files created via /jaan-to:learn-add
# Plugin LEARN.md files used as seed data when creating new project learn files

# 9. Check context files
MISSING_CONTEXT=()
for f in tech.md team.md integrations.md config.md boundaries.md; do
  if [ ! -f "$PLUGIN_DIR/scripts/seeds/$f" ]; then
    MISSING_CONTEXT+=("scripts/seeds/$f")
  fi
done

# 10. Check if detect skills should be suggested (context files still have placeholders)
SUGGEST_DETECT="false"
if [ -f "$PROJECT_DIR/$CONTEXT_DIR/tech.md" ]; then
  if grep -q '{project-name}' "$PROJECT_DIR/$CONTEXT_DIR/tech.md" 2>/dev/null; then
    SUGGEST_DETECT="true"
  fi
fi

# 11. Output structured result
# Token budget: target ≤ 300 tokens (~1,200 chars) stdout

# Compact mode: if nothing was copied and no context missing, emit minimal payload
if [ "$CONFIG_COPIED" -eq 0 ] && [ "$CONTEXT_COPIED" -eq 0 ] && [ ${#MISSING_CONTEXT[@]} -eq 0 ]; then
  cat <<RESULT
{"status":"complete","config_loaded":true,"output_dir":"${OUTPUTS_DIR}","learn_dir":"${LEARN_DIR}","context_dir":"${CONTEXT_DIR}","templates_dir":"${TEMPLATES_DIR}","suggest_detect":${SUGGEST_DETECT}}
RESULT
  exit 0
fi

if [ ${#MISSING_CONTEXT[@]} -gt 0 ]; then
  MISSING_LIST=$(printf '"%s",' "${MISSING_CONTEXT[@]}" | sed 's/,$//')
else
  MISSING_LIST=""
fi

cat <<RESULT
{
  "status": "complete",
  "config_loaded": true,
  "output_dir": "${OUTPUTS_DIR}",
  "learn_dir": "${LEARN_DIR}",
  "context_dir": "${CONTEXT_DIR}",
  "templates_dir": "${TEMPLATES_DIR}",
  "docs_dir": "${DOCS_DIR}",
  "config_dir": "${CONFIG_DIR}",
  "paths_customized": $([ "$TEMPLATES_DIR" != "jaan-to/templates" ] && echo "true" || echo "false"),
  "files_copied": {
    "config": ${CONFIG_COPIED},
    "context": ${CONTEXT_COPIED},
    "templates": ${TEMPLATES_COPIED},
    "docs": ${DOCS_COPIED},
    "learn": ${LEARN_COPIED}
  },
  "missing_context": [${MISSING_LIST}],
  "suggest_detect": ${SUGGEST_DETECT}
}
RESULT
