#!/bin/bash
# runtime-context.sh — Shared runtime env/path resolver for Claude + Codex.

set -euo pipefail

RUNTIME_CONTEXT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_CONTEXT_PLUGIN_ROOT="$(cd "$RUNTIME_CONTEXT_SCRIPT_DIR/../.." && pwd)"

# shellcheck source=scripts/lib/config-loader.sh
source "$RUNTIME_CONTEXT_SCRIPT_DIR/config-loader.sh"

runtime_context_default_project_dir() {
  echo "${CLAUDE_PROJECT_DIR:-${CODEX_PROJECT_DIR:-${CODEX_WORKSPACE_ROOT:-$PWD}}}"
}

runtime_context_is_project_initialized() {
  local project_dir="${1:-$(runtime_context_default_project_dir)}"
  [ -d "$project_dir/jaan-to" ]
}

runtime_context_init() {
  local project_dir="${1:-$(runtime_context_default_project_dir)}"
  local plugin_root="${2:-${CLAUDE_PLUGIN_ROOT:-$RUNTIME_CONTEXT_PLUGIN_ROOT}}"

  if [ ! -d "$project_dir" ]; then
    echo "ERROR: Project directory does not exist: $project_dir" >&2
    return 1
  fi

  export PROJECT_DIR="$project_dir"
  export CLAUDE_PROJECT_DIR="$project_dir"
  export CLAUDE_PLUGIN_ROOT="$plugin_root"

  load_config

  export JAAN_TEMPLATES_DIR="$(get_validated_path 'paths_templates' 'jaan-to/templates')"
  export JAAN_LEARN_DIR="$(get_validated_path 'paths_learning' 'jaan-to/learn')"
  export JAAN_CONTEXT_DIR="$(get_validated_path 'paths_context' 'jaan-to/context')"
  export JAAN_OUTPUTS_DIR="$(get_validated_path 'paths_outputs' 'jaan-to/outputs')"
  export JAAN_DOCS_DIR="$(get_validated_path 'paths_docs' 'jaan-to/docs')"
}

runtime_context_print() {
  cat <<EOL
CLAUDE_PLUGIN_ROOT=$CLAUDE_PLUGIN_ROOT
CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR
JAAN_CONTEXT_DIR=$JAAN_CONTEXT_DIR
JAAN_TEMPLATES_DIR=$JAAN_TEMPLATES_DIR
JAAN_LEARN_DIR=$JAAN_LEARN_DIR
JAAN_OUTPUTS_DIR=$JAAN_OUTPUTS_DIR
JAAN_DOCS_DIR=$JAAN_DOCS_DIR
EOL
}
