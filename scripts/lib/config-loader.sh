#!/bin/bash
# jaan.to Configuration Loader
# Loads and merges configuration from plugin defaults and project settings

declare -A CONFIG_CACHE

load_yaml() {
  local file=$1
  local prefix=$2

  # Skip if file doesn't exist
  [ ! -f "$file" ] && return 0

  # Parse YAML (flattened key: value format)
  while IFS=: read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue

    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    # Remove quotes from value if present
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"

    # Cache the config value with prefix
    CONFIG_CACHE["${prefix}.${key}"]="$value"
  done < "$file"
}

load_config() {
  local plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local project_dir="${PROJECT_DIR:-.}"

  # Layer 1: Plugin defaults
  if [ -f "${plugin_root}/config/defaults.yaml" ]; then
    load_yaml "${plugin_root}/config/defaults.yaml" "plugin"
  fi

  # Layer 2: Project settings
  if [ -f "${project_dir}/jaan-to/config/settings.yaml" ]; then
    load_yaml "${project_dir}/jaan-to/config/settings.yaml" "project"
  fi
}

get_config() {
  local key=$1
  local default=$2

  # Replace dots with underscores for flattened keys
  key="${key//./_}"

  # Check project first, then plugin, then default
  if [ -n "${CONFIG_CACHE[project.${key}]}" ]; then
    echo "${CONFIG_CACHE[project.${key}]}"
  elif [ -n "${CONFIG_CACHE[plugin.${key}]}" ]; then
    echo "${CONFIG_CACHE[plugin.${key}]}"
  else
    echo "$default"
  fi
}

resolve_path() {
  local path=$1

  # Resolve environment variables
  path="${path//\$\{PLUGIN_ROOT\}/${CLAUDE_PLUGIN_ROOT}}"
  path="${path//\$\{PROJECT_DIR\}/${PROJECT_DIR}}"
  path="${path//\$CLAUDE_PLUGIN_ROOT/${CLAUDE_PLUGIN_ROOT}}"
  path="${path//\$PROJECT_DIR/${PROJECT_DIR}}"

  # Expand tilde
  path="${path/#\~/$HOME}"

  echo "$path"
}

validate_path() {
  local path=$1

  # Security checks
  # Reject absolute paths
  [[ "$path" =~ ^/ ]] && {
    echo "ERROR: Absolute paths not allowed: $path" >&2
    return 1
  }

  # Reject path traversal
  [[ "$path" =~ \.\. ]] && {
    echo "ERROR: Path traversal not allowed: $path" >&2
    return 1
  }

  return 0
}

# Export functions for use in other scripts
export -f load_yaml
export -f load_config
export -f get_config
export -f resolve_path
export -f validate_path
