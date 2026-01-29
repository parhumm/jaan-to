#!/bin/bash
# jaan.to plugin — first-run bootstrap
# Usage: Runs via SessionStart hook on every session start
# Idempotent — safe to run multiple times

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"

# 1. Create output and learn directories
if [ ! -d "$PROJECT_DIR/.jaan-to" ]; then
  mkdir -p "$PROJECT_DIR/.jaan-to/outputs"
  mkdir -p "$PROJECT_DIR/.jaan-to/learn"
  echo '{"status": "created", "path": ".jaan-to/"}'
fi

# Ensure subdirectories exist even if .jaan-to/ already exists
mkdir -p "$PROJECT_DIR/.jaan-to/outputs"
mkdir -p "$PROJECT_DIR/.jaan-to/learn"

# 2. Add to .gitignore if not present
if [ -f "$PROJECT_DIR/.gitignore" ]; then
  if ! grep -q "\.jaan-to" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    echo ".jaan-to/" >> "$PROJECT_DIR/.gitignore"
  fi
else
  echo ".jaan-to/" > "$PROJECT_DIR/.gitignore"
fi

# 3. Copy LEARN.md seed data (skip if project copy exists)
if [ -d "$PLUGIN_DIR/skills" ]; then
  for skill_learn in "$PLUGIN_DIR/skills"/*/LEARN.md; do
    [ -f "$skill_learn" ] || continue
    skill_name=$(basename "$(dirname "$skill_learn")")
    project_learn="$PROJECT_DIR/.jaan-to/learn/${skill_name}.learn.md"
    if [ ! -f "$project_learn" ]; then
      cp "$skill_learn" "$project_learn"
    fi
  done
fi

# 4. Detect old standalone skills
OLD_SKILLS=()
for pattern in "jaan-to-*" "to-jaan-*"; do
  if ls "$PROJECT_DIR/.claude/skills/"$pattern 1>/dev/null 2>&1; then
    for d in "$PROJECT_DIR/.claude/skills/"$pattern; do
      [ -d "$d" ] && OLD_SKILLS+=("$(basename "$d")")
    done
  fi
done

# 5. Check context files
MISSING_CONTEXT=()
for f in tech.md team.md integrations.md; do
  if [ ! -f "$PLUGIN_DIR/context/$f" ]; then
    MISSING_CONTEXT+=("context/$f")
  fi
done

# 6. Output structured result
if [ ${#OLD_SKILLS[@]} -gt 0 ]; then
  OLD_LIST=$(printf '"%s",' "${OLD_SKILLS[@]}" | sed 's/,$//')
else
  OLD_LIST=""
fi

if [ ${#MISSING_CONTEXT[@]} -gt 0 ]; then
  MISSING_LIST=$(printf '"%s",' "${MISSING_CONTEXT[@]}" | sed 's/,$//')
else
  MISSING_LIST=""
fi

cat <<RESULT
{
  "status": "complete",
  "output_dir": ".jaan-to/outputs",
  "learn_dir": ".jaan-to/learn",
  "missing_context": [${MISSING_LIST}],
  "old_standalone_skills": [${OLD_LIST}],
  "migration_needed": $([ ${#OLD_SKILLS[@]} -gt 0 ] && echo "true" || echo "false")
}
RESULT
