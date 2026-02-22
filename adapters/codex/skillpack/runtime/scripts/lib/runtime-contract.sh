#!/bin/bash
# runtime-contract.sh — Central runtime paths/contracts for all distributions.

set -euo pipefail

RUNTIME_CONTRACT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_PLUGIN_ROOT="$(cd "$RUNTIME_CONTRACT_SCRIPT_DIR/../.." && pwd)"
RUNTIME_DIST_ROOT="$RUNTIME_PLUGIN_ROOT/dist"

runtime_dist_dir() {
  local target="$1"
  case "$target" in
    claude)
      echo "$RUNTIME_DIST_ROOT/jaan-to-claude"
      ;;
    codex)
      echo "$RUNTIME_DIST_ROOT/jaan-to-codex"
      ;;
    *)
      echo "ERROR: Unknown runtime target: $target" >&2
      return 1
      ;;
  esac
}

runtime_required_paths() {
  local target="$1"
  local dist_dir
  dist_dir="$(runtime_dist_dir "$target")"

  case "$target" in
    claude)
      cat <<EOL
$dist_dir/.claude-plugin/plugin.json
$dist_dir/hooks/hooks.json
$dist_dir/CLAUDE.md
$dist_dir/.mcp.json
EOL
      ;;
    codex)
      cat <<EOL
$dist_dir/AGENTS.md
$dist_dir/scripts/codex-bootstrap.sh
$dist_dir/jaan-to
EOL
      ;;
    *)
      echo "ERROR: Unknown runtime target: $target" >&2
      return 1
      ;;
  esac
}

runtime_shared_core_paths() {
  cat <<'EOL'
skills
scripts
agents
config
docs/extending
docs/STYLE.md
EOL
}

runtime_adapter_paths() {
  local target="$1"
  case "$target" in
    claude)
      cat <<'EOL'
.claude-plugin
hooks
CLAUDE.md
.mcp.json
EOL
      ;;
    codex)
      cat <<'EOL'
adapters/codex/AGENTS.md
adapters/codex/jaan-to
scripts/codex-bootstrap.sh
EOL
      ;;
    *)
      echo "ERROR: Unknown runtime target: $target" >&2
      return 1
      ;;
  esac
}

runtime_forbidden_in_claude_dist() {
  local claude_dist
  claude_dist="$(runtime_dist_dir claude)"
  cat <<EOL
$claude_dist/AGENTS.md
$claude_dist/README-CODEX.md
$claude_dist/jaan-to
$claude_dist/adapters/codex
EOL
}

runtime_legacy_claude_dist_path() {
  echo "$RUNTIME_DIST_ROOT/jaan-to"
}
