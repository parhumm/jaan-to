#!/bin/bash
# install-codex-skills.sh — Configure jaan.to skills for Codex discovery.
# Usage: bash scripts/install-codex-skills.sh [project_dir] [plugin_root] [auto|global|local] [pack_root]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${2:-$(cd "$SCRIPT_DIR/.." && pwd)}"
PROJECT_DIR="${1:-${CODEX_PROJECT_DIR:-${CODEX_WORKSPACE_ROOT:-$PWD}}}"
REQUESTED_MODE="${3:-${JAAN_CODEX_SKILL_MODE:-auto}}"
PACK_ROOT_INPUT="${4:-${JAAN_CODEX_PACK_ROOT:-}}"
DEFAULT_PACK_ROOT="$HOME/.agents/skills/jaan-to-codex-pack"
PACK_ROOT="${PACK_ROOT_INPUT:-$DEFAULT_PACK_ROOT}"
LOCAL_SKILLS_SRC="$PLUGIN_ROOT/skills"
LOCAL_SKILLS_DEST="$PROJECT_DIR/.agents/skills"
BLOCK_START="# >>> JAAN-TO CODEX CONTRACT >>>"
BLOCK_END="# <<< JAAN-TO CODEX CONTRACT <<<"

expand_home_path() {
  local path="$1"
  case "$path" in
    "~")
      echo "$HOME"
      ;;
    "~/"*)
      echo "$HOME/${path#~/}"
      ;;
    *)
      echo "$path"
      ;;
  esac
}

PACK_ROOT="$(expand_home_path "$PACK_ROOT")"
GLOBAL_SKILLS_DIR="$PACK_ROOT/skills"
GLOBAL_RUNTIME_DIR="$PACK_ROOT/runtime"

GLOBAL_SKILL_COUNT=0
INSTALLED=0
SKIPPED=0
CONFLICTS=0

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

if [ ! -d "$LOCAL_SKILLS_SRC" ]; then
  echo "ERROR: Skills source not found: $LOCAL_SKILLS_SRC" >&2
  exit 1
fi

if [ -d "$GLOBAL_SKILLS_DIR" ]; then
  GLOBAL_SKILL_COUNT="$(find "$GLOBAL_SKILLS_DIR" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
fi

has_global_pack() {
  [ "$GLOBAL_SKILL_COUNT" -gt 0 ]
}

list_local_duplicates_with_global() {
  local duplicates=()
  local skill_dir

  if [ ! -d "$LOCAL_SKILLS_DEST" ]; then
    echo ""
    return 0
  fi

  for skill_dir in "$GLOBAL_SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [ -e "$LOCAL_SKILLS_DEST/$skill_name" ]; then
      duplicates+=("$skill_name")
    fi
  done

  if [ "${#duplicates[@]}" -eq 0 ]; then
    echo ""
    return 0
  fi

  printf '%s\n' "${duplicates[@]}" | LC_ALL=C sort | uniq
}

strip_managed_block() {
  local file="$1"
  local tmp="$2"

  if [ ! -f "$file" ]; then
    : > "$tmp"
    return 0
  fi

  awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$file" > "$tmp"
}

update_project_agents() {
  local mode="$1"
  local agents_file="$PROJECT_DIR/AGENTS.md"
  local stripped_file
  stripped_file="$(mktemp)"
  strip_managed_block "$agents_file" "$stripped_file"

  local block_file
  block_file="$(mktemp)"

  if [ "$mode" = "local" ]; then
    cat > "$block_file" <<EOF
$BLOCK_START
This project uses local jaan.to skill links.

## Skill Invocation Contract

- Use \`/skills\` to open available skills.
- If someone writes \`/jaan-to:{skill}\`, treat it as an alias for \`\$<skill>\`.
- If someone writes \`/jaan-init\`, treat it as an alias for \`\$jaan-init\`.

## Installation Mode

- Mode: local
- Skill source: $LOCAL_SKILLS_SRC
- Skill path: $LOCAL_SKILLS_DEST
- Do not mix local jaan.to links with global \`jaan-to-codex-pack\` unless \`JAAN_ALLOW_LOCAL_WITH_GLOBAL=1\`.
$BLOCK_END
EOF
  else
    cat > "$block_file" <<EOF
$BLOCK_START
This project uses the global jaan.to Codex skill pack.

## Skill Invocation Contract

- Use \`/skills\` to open available skills.
- If someone writes \`/jaan-to:{skill}\`, treat it as an alias for \`\$<skill>\`.
- If someone writes \`/jaan-init\`, treat it as an alias for \`\$jaan-init\`.

## Runtime Defaults

- \`CLAUDE_PLUGIN_ROOT=$GLOBAL_RUNTIME_DIR\`
- \`CLAUDE_PROJECT_DIR=<current workspace root>\`
- \`JAAN_CONTEXT_DIR=jaan-to/context\`
- \`JAAN_TEMPLATES_DIR=jaan-to/templates\`
- \`JAAN_LEARN_DIR=jaan-to/learn\`
- \`JAAN_OUTPUTS_DIR=jaan-to/outputs\`
- \`JAAN_DOCS_DIR=jaan-to/docs\`

## Installation Mode

- Mode: global
- Global pack root: $PACK_ROOT
- Avoid adding duplicate jaan.to entries under project \`.agents/skills\`.
$BLOCK_END
EOF
  fi

  if [ -s "$stripped_file" ]; then
    cat "$stripped_file" > "$agents_file"
    printf '\n\n' >> "$agents_file"
    cat "$block_file" >> "$agents_file"
  else
    cat "$block_file" > "$agents_file"
  fi

  rm -f "$stripped_file" "$block_file"
}

install_local_skills() {
  mkdir -p "$LOCAL_SKILLS_DEST"

  local skill_dir
  for skill_dir in "$LOCAL_SKILLS_SRC"/*; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue

    local skill_name
    skill_name="$(basename "$skill_dir")"
    local dest="$LOCAL_SKILLS_DEST/$skill_name"

    if [ -L "$dest" ]; then
      local target
      target="$(readlink "$dest" || true)"
      if [ "$target" = "$skill_dir" ]; then
        SKIPPED=$((SKIPPED + 1))
        continue
      fi
      rm -f "$dest"
    fi

    if [ -e "$dest" ]; then
      echo "WARNING: Skill path already exists, not overwritten: $dest" >&2
      CONFLICTS=$((CONFLICTS + 1))
      continue
    fi

    ln -s "$skill_dir" "$dest"
    INSTALLED=$((INSTALLED + 1))
  done
}

case "$REQUESTED_MODE" in
  auto|global|local)
    ;;
  *)
    echo "ERROR: Invalid mode: $REQUESTED_MODE (expected auto|global|local)" >&2
    exit 1
    ;;
esac

RESOLVED_MODE="$REQUESTED_MODE"
if [ "$REQUESTED_MODE" = "auto" ]; then
  if has_global_pack; then
    RESOLVED_MODE="global"
  else
    RESOLVED_MODE="local"
  fi
fi

if [ "$RESOLVED_MODE" = "global" ] && ! has_global_pack; then
  echo "ERROR: Global mode selected but no global skill pack found at: $GLOBAL_SKILLS_DIR" >&2
  echo "Run: bash scripts/install-codex-skillpack.sh" >&2
  echo "Or rerun with local mode: ./jaan-to setup \"$PROJECT_DIR\" --mode local" >&2
  exit 1
fi

if [ "$RESOLVED_MODE" = "local" ] && has_global_pack && [ "${JAAN_ALLOW_LOCAL_WITH_GLOBAL:-0}" != "1" ]; then
  echo "ERROR: Global jaan.to skill pack already installed at: $PACK_ROOT" >&2
  echo "Local mode would create duplicate skill names and break plain \$skill invocation." >&2
  echo "Use global mode (recommended): ./jaan-to setup \"$PROJECT_DIR\" --mode global" >&2
  echo "If you intentionally need local mode for development, set JAAN_ALLOW_LOCAL_WITH_GLOBAL=1." >&2
  exit 1
fi

DUPLICATES="$(list_local_duplicates_with_global || true)"
if [ "$RESOLVED_MODE" = "global" ] && [ -n "$DUPLICATES" ]; then
  echo "ERROR: Duplicate jaan.to skill names detected in project local skills and global pack." >&2
  echo "This causes ambiguous plain \$skill mentions in Codex." >&2
  echo "Conflicting skills:" >&2
  printf '%s\n' "$DUPLICATES" | sed 's/^/  - /' >&2
  echo "Remediation:" >&2
  echo "  1) Remove project-local duplicates from $LOCAL_SKILLS_DEST" >&2
  echo "  2) Re-run setup with --mode global" >&2
  exit 1
fi

if [ "$RESOLVED_MODE" = "local" ]; then
  install_local_skills
  update_project_agents local
else
  update_project_agents global
fi

echo "=== Codex Skill Install ==="
echo "Project: $PROJECT_DIR"
echo "Requested mode: $REQUESTED_MODE"
echo "Resolved mode: $RESOLVED_MODE"
echo "Global pack root: $PACK_ROOT"
echo "Global skill count: $GLOBAL_SKILL_COUNT"
if [ "$RESOLVED_MODE" = "local" ]; then
  echo "Installed: $INSTALLED"
  echo "Unchanged: $SKIPPED"
  echo "Conflicts: $CONFLICTS"
  echo "Skill path: $LOCAL_SKILLS_DEST"
else
  echo "Installed: 0 (global mode)"
  echo "Unchanged: 0 (global mode)"
  echo "Conflicts: 0 (global mode)"
  echo "Skill path: $GLOBAL_SKILLS_DIR"
fi
echo "Use in Codex: /skills, /jaan-to:{skill}, or \$<skill-name>"
