#!/bin/bash
# codex-bootstrap.sh — Initialize project files for Codex runtime.
# Usage: bash scripts/codex-bootstrap.sh [/path/to/project]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="${1:-${CODEX_PROJECT_DIR:-${CODEX_WORKSPACE_ROOT:-$PWD}}}"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

# bootstrap.sh is opt-in and expects this directory to exist.
mkdir -p "$PROJECT_DIR/jaan-to"

CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" \
CLAUDE_PROJECT_DIR="$PROJECT_DIR" \
  bash "$PLUGIN_ROOT/scripts/bootstrap.sh"

bash "$PLUGIN_ROOT/scripts/install-codex-skills.sh" "$PROJECT_DIR" "$PLUGIN_ROOT"
