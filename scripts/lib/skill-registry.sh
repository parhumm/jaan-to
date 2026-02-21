#!/bin/bash
# skill-registry.sh — Single source of truth for skill/command mapping.

set -euo pipefail

SKILL_REGISTRY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_REGISTRY_PLUGIN_ROOT="$(cd "$SKILL_REGISTRY_SCRIPT_DIR/../.." && pwd)"
SKILL_REGISTRY_DIR="$SKILL_REGISTRY_PLUGIN_ROOT/skills"

skill_registry_list_names() {
  find "$SKILL_REGISTRY_DIR" -mindepth 1 -maxdepth 1 -type d -print |
    while IFS= read -r dir; do
      local name
      name="$(basename "$dir")"
      if [ -f "$SKILL_REGISTRY_DIR/$name/SKILL.md" ]; then
        echo "$name"
      fi
    done | LC_ALL=C sort
}

skill_registry_count() {
  skill_registry_list_names | wc -l | tr -d ' '
}

skill_registry_is_valid() {
  local skill_name="$1"
  [ -n "$skill_name" ] || return 1
  [ -f "$SKILL_REGISTRY_DIR/$skill_name/SKILL.md" ]
}

skill_registry_to_slash() {
  local skill_name="$1"
  if [ "$skill_name" = "jaan-init" ]; then
    echo "/jaan-init"
  else
    echo "/jaan-to:$skill_name"
  fi
}

skill_registry_normalize_skill_name() {
  local raw="${1:-}"

  case "$raw" in
    /jaan-init|jaan-init|/jaan-to:jaan-init|jaan-to:jaan-init)
      echo "jaan-init"
      return 0
      ;;
  esac

  raw="${raw#/}"
  raw="${raw#jaan-to:}"

  if skill_registry_is_valid "$raw"; then
    echo "$raw"
    return 0
  fi

  return 1
}

skill_registry_suggest() {
  local query="${1:-}"
  local suggestions

  suggestions="$(skill_registry_list_names | grep -F "$query" | head -n 5 || true)"
  if [ -n "$suggestions" ]; then
    printf '%s\n' "$suggestions"
    return 0
  fi

  skill_registry_list_names | head -n 5
}

skill_registry_print_commands() {
  echo "/jaan-init"
  skill_registry_list_names |
    while IFS= read -r skill_name; do
      [ "$skill_name" = "jaan-init" ] && continue
      echo "/jaan-to:$skill_name"
    done
}
