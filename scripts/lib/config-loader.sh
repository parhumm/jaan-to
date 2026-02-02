#!/bin/bash
# jaan.to Configuration Loader
# Loads and merges configuration from plugin defaults and project settings
# Compatible with bash 3.2+ (macOS default)

# Use simple variables instead of associative arrays for bash 3 compatibility
CONFIG_CACHE_FILE="/tmp/jaan-to-config-$$"

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
    key=$(echo "$key" | xargs 2>/dev/null || echo "$key")
    value=$(echo "$value" | xargs 2>/dev/null || echo "$value")

    # Remove quotes from value if present
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"

    # Write to temp cache file: prefix.key=value
    echo "${prefix}.${key}=${value}" >> "$CONFIG_CACHE_FILE"
  done < "$file"
}

load_config() {
  local plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local project_dir="${PROJECT_DIR:-.}"

  # Initialize cache file
  : > "$CONFIG_CACHE_FILE"

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
  local result=""

  if [ -f "$CONFIG_CACHE_FILE" ]; then
    # Try project value first
    result=$(grep "^project\.${key}=" "$CONFIG_CACHE_FILE" 2>/dev/null | tail -1 | cut -d= -f2-)

    # Fall back to plugin value
    if [ -z "$result" ]; then
      result=$(grep "^plugin\.${key}=" "$CONFIG_CACHE_FILE" 2>/dev/null | tail -1 | cut -d= -f2-)
    fi
  fi

  # Return result or default
  if [ -n "$result" ]; then
    echo "$result"
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

# Cleanup temp file on exit
cleanup_config() {
  [ -f "$CONFIG_CACHE_FILE" ] && rm -f "$CONFIG_CACHE_FILE"
}

trap cleanup_config EXIT

# Export functions for use in other scripts
export -f load_yaml
export -f load_config
export -f get_config
export -f resolve_path
export -f validate_path
