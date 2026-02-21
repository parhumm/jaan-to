#!/bin/bash
# Build runtime-specific jaan.to distributions from one shared source tree.
# Usage: ./scripts/build-target.sh [claude|codex]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_ROOT="$PLUGIN_ROOT/dist"
# shellcheck source=scripts/lib/runtime-contract.sh
source "$PLUGIN_ROOT/scripts/lib/runtime-contract.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/build-target.sh [claude|codex]

Targets:
  claude   Build Claude Code plugin package at dist/jaan-to-claude
  codex    Build Codex package at dist/jaan-to-codex
EOF
}

copy_dir() {
  local src="$1"
  local dest="$2"
  [ -d "$src" ] || return 0
  cp -R "$src" "$dest"
}

copy_file() {
  local src="$1"
  local dest="$2"
  [ -f "$src" ] || return 0
  cp "$src" "$dest"
}

copy_shared_assets() {
  local out_dir="$1"

  for dir in skills scripts agents config; do
    copy_dir "$PLUGIN_ROOT/$dir" "$out_dir/$dir"
  done

  mkdir -p "$out_dir/docs"
  copy_file "$PLUGIN_ROOT/docs/STYLE.md" "$out_dir/docs/STYLE.md"
  copy_dir "$PLUGIN_ROOT/docs/extending" "$out_dir/docs/extending"

  for file in README.md LICENSE.md CHANGELOG.md; do
    copy_file "$PLUGIN_ROOT/$file" "$out_dir/$file"
  done
}

print_summary() {
  local target="$1"
  local out_dir="$2"
  local file_count
  local dir_count

  file_count=$(find "$out_dir" -type f | wc -l | tr -d ' ')
  dir_count=$(find "$out_dir" -type d | wc -l | tr -d ' ')

  echo "=== jaan.to ${target} distribution ==="
  echo "Output: $out_dir"
  echo "Files: $file_count"
  echo "Directories: $dir_count"
  echo ""
}

build_claude_target() {
  local out_dir
  out_dir="$(runtime_dist_dir claude)"
  # Enforce strict rename: remove legacy Claude dist directory name if present.
  find "$DIST_ROOT" -mindepth 1 -maxdepth 1 -type d -name "$(basename "$(runtime_legacy_claude_dist_path)")" -exec rm -rf {} + 2>/dev/null || true
  rm -rf "$out_dir"
  mkdir -p "$out_dir"

  copy_shared_assets "$out_dir"
  copy_dir "$PLUGIN_ROOT/.claude-plugin" "$out_dir/.claude-plugin"
  copy_dir "$PLUGIN_ROOT/hooks" "$out_dir/hooks"
  copy_file "$PLUGIN_ROOT/CLAUDE.md" "$out_dir/CLAUDE.md"

  print_summary "Claude" "$out_dir"
  echo "Install with:"
  echo "  claude --plugin-dir $out_dir"
}

build_codex_target() {
  local out_dir
  out_dir="$(runtime_dist_dir codex)"
  rm -rf "$out_dir"
  mkdir -p "$out_dir"

  copy_shared_assets "$out_dir"
  copy_file "$PLUGIN_ROOT/adapters/codex/AGENTS.md" "$out_dir/AGENTS.md"
  copy_file "$PLUGIN_ROOT/adapters/codex/README.md" "$out_dir/README-CODEX.md"
  copy_file "$PLUGIN_ROOT/adapters/codex/jaan-to" "$out_dir/jaan-to"
  chmod +x "$out_dir/jaan-to"

  print_summary "Codex" "$out_dir"
  echo "Use in Codex by opening the package root as your workspace."
  echo "Then run:"
  echo "  ./jaan-to setup /path/to/your-project --mode auto"
  echo "  # or force local legacy mode:"
  echo "  ./jaan-to setup /path/to/your-project --mode local"
  echo "  ./jaan-to list"
  echo "  ./jaan-to run /jaan-to:pm-prd-write \"feature\""
}

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  usage
  exit 1
fi

mkdir -p "$DIST_ROOT"

case "$TARGET" in
  claude)
    build_claude_target
    ;;
  codex)
    build_codex_target
    ;;
  *)
    usage
    exit 1
    ;;
esac
