#!/bin/bash
# codex-bootstrap.sh — Initialize project files for Codex runtime.
# Usage: bash scripts/codex-bootstrap.sh [/path/to/project] [--mode auto|global|local] [--pack-root /path/to/jaan-to-codex-pack]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: bash scripts/codex-bootstrap.sh [/path/to/project] [--mode auto|global|local] [--pack-root /path]
EOF
}

PROJECT_DIR=""
MODE="${JAAN_CODEX_SKILL_MODE:-auto}"
PACK_ROOT="${JAAN_CODEX_PACK_ROOT:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --mode requires a value (auto|global|local)" >&2
        exit 1
      fi
      MODE="$2"
      shift 2
      ;;
    --pack-root)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --pack-root requires a path" >&2
        exit 1
      fi
      PACK_ROOT="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -n "$PROJECT_DIR" ]; then
        echo "ERROR: Multiple project directories provided: $PROJECT_DIR and $1" >&2
        exit 1
      fi
      PROJECT_DIR="$1"
      shift
      ;;
  esac
done

if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR="${CODEX_PROJECT_DIR:-${CODEX_WORKSPACE_ROOT:-$PWD}}"
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

# bootstrap.sh is opt-in and expects this directory to exist.
mkdir -p "$PROJECT_DIR/jaan-to"

CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" \
CLAUDE_PROJECT_DIR="$PROJECT_DIR" \
  bash "$PLUGIN_ROOT/scripts/bootstrap.sh"

INSTALL_ARGS=("$PROJECT_DIR" "$PLUGIN_ROOT" "$MODE")
if [ -n "$PACK_ROOT" ]; then
  INSTALL_ARGS+=("$PACK_ROOT")
fi

bash "$PLUGIN_ROOT/scripts/install-codex-skills.sh" "${INSTALL_ARGS[@]}"
