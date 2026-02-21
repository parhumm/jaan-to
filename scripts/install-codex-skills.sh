#!/bin/bash
# install-codex-skills.sh — Install/sync jaan.to skills into Codex discovery path.
# Usage: bash scripts/install-codex-skills.sh [/path/to/project] [/path/to/plugin-root]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${2:-$(cd "$SCRIPT_DIR/.." && pwd)}"
PROJECT_DIR="${1:-${CODEX_PROJECT_DIR:-${CODEX_WORKSPACE_ROOT:-$PWD}}}"
SKILLS_SRC="$PLUGIN_ROOT/skills"
SKILLS_DEST="$PROJECT_DIR/.agents/skills"
INSTALLED=0
SKIPPED=0
CONFLICTS=0

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

if [ ! -d "$SKILLS_SRC" ]; then
  echo "ERROR: Skills source not found: $SKILLS_SRC" >&2
  exit 1
fi

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue

  skill_name="$(basename "$skill_dir")"
  dest="$SKILLS_DEST/$skill_name"

  if [ -L "$dest" ]; then
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

if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
  cat > "$PROJECT_DIR/AGENTS.md" <<'EOF'
# AGENTS.md

This project uses jaan.to skills installed via .agents/skills.

## Skill Invocation

- Use `/skills` to open available skills.
- Type `$` in the composer to mention a skill (for example: `$pm-prd-write`).
- If someone writes `/jaan-to:{skill}`, treat it as an alias for `$<skill>` without the `jaan-to:` prefix.

## Installed Skill Source

- Skill symlinks in this project point to:
EOF
  printf '  %s\n' "$SKILLS_SRC" >> "$PROJECT_DIR/AGENTS.md"
fi

echo "=== Codex Skill Install ==="
echo "Project: $PROJECT_DIR"
echo "Installed: $INSTALLED"
echo "Unchanged: $SKIPPED"
echo "Conflicts: $CONFLICTS"
echo "Skill path: $SKILLS_DEST"
echo "Use in Codex: /skills or \$<skill-name>"
