#!/bin/bash
# build-codex-skillpack.sh — Build installable Codex skillpack source tree.
# Usage: bash scripts/build-codex-skillpack.sh [--out /path/to/skillpack]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$PLUGIN_ROOT/adapters/codex/skillpack"

usage() {
  cat <<'EOF'
Usage: bash scripts/build-codex-skillpack.sh [--out /path/to/skillpack]
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --out)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --out requires a destination path" >&2
        exit 1
      fi
      OUT_DIR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

RUNTIME_DIR="$OUT_DIR/runtime"

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

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
mkdir -p "$RUNTIME_DIR"

cat > "$OUT_DIR/SKILL.md" <<'EOF'
---
name: jaan-to-codex-pack
description: Root installer anchor for the jaan.to Codex skill pack. Use when installing jaan.to skills in Codex.
metadata:
  short-description: Root installer anchor for jaan.to Codex skill pack
---

# jaan-to Codex Skill Pack

This root skill is an installer anchor.
Use the nested skills in `skills/` for actual task execution.
EOF

copy_dir "$PLUGIN_ROOT/skills" "$OUT_DIR/skills"
copy_dir "$PLUGIN_ROOT/scripts" "$RUNTIME_DIR/scripts"
copy_dir "$PLUGIN_ROOT/agents" "$RUNTIME_DIR/agents"

mkdir -p "$RUNTIME_DIR/config"
copy_file "$PLUGIN_ROOT/config/defaults.yaml" "$RUNTIME_DIR/config/defaults.yaml"

mkdir -p "$RUNTIME_DIR/docs"
copy_file "$PLUGIN_ROOT/docs/STYLE.md" "$RUNTIME_DIR/docs/STYLE.md"
copy_dir "$PLUGIN_ROOT/docs/extending" "$RUNTIME_DIR/docs/extending"

copy_file "$PLUGIN_ROOT/adapters/codex/jaan-to" "$RUNTIME_DIR/jaan-to"
chmod +x "$RUNTIME_DIR/jaan-to"
copy_file "$PLUGIN_ROOT/adapters/codex/AGENTS.md" "$RUNTIME_DIR/AGENTS.md"
copy_file "$PLUGIN_ROOT/adapters/codex/README.md" "$OUT_DIR/README.md"
copy_file "$PLUGIN_ROOT/.mcp.json" "$RUNTIME_DIR/.mcp.json.reference"

SKILL_COUNT="$(find "$OUT_DIR/skills" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
RUNTIME_SCRIPT_COUNT="$(find "$RUNTIME_DIR/scripts" -type f | wc -l | tr -d ' ')"

echo "=== Codex Skillpack Build ==="
echo "Output: $OUT_DIR"
echo "Skill count: $SKILL_COUNT"
echo "Runtime scripts: $RUNTIME_SCRIPT_COUNT"
