#!/bin/bash
# jaan.to Configuration Loader
# Loads and merges configuration from plugin defaults and project settings
# Compatible with bash 3.2+ (macOS default)

# Use simple variables instead of associative arrays for bash 3 compatibility
set -euo pipefail

CONFIG_CACHE_FILE=$(mktemp /tmp/jaan-to-config-XXXXXX)

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

  # Re-initialize CONFIG_CACHE_FILE if unset (for test scenarios)
  if [ -z "${CONFIG_CACHE_FILE:-}" ]; then
    CONFIG_CACHE_FILE=$(mktemp /tmp/jaan-to-config-XXXXXX)
  fi

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

  if [ -n "${CONFIG_CACHE_FILE:-}" ] && [ -f "$CONFIG_CACHE_FILE" ]; then
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

  # Reject path traversal (CVE-2025-54794 mitigation)
  [[ "$path" =~ \.\. ]] && {
    echo "ERROR: Path traversal not allowed: $path" >&2
    return 1
  }

  return 0
}

# Canonical path resolution helper (portable macOS/Linux)
# Returns the canonical absolute path, resolving symlinks
_canonical_path() {
  local path=$1
  # Try realpath first (Linux, macOS with coreutils)
  if command -v realpath >/dev/null 2>&1; then
    realpath -m "$path" 2>/dev/null && return 0
  fi
  # Fallback: python3 (available on macOS by default)
  python3 -c "import os; print(os.path.realpath('$path'))" 2>/dev/null && return 0
  # Last resort: echo the path as-is
  echo "$path"
}

# Get a config path value with full security validation
# Validates raw value (rejects .. and absolute), then verifies
# the resolved canonical path stays within PROJECT_DIR
get_validated_path() {
  local key=$1
  local default=$2
  local project_dir="${PROJECT_DIR:-.}"

  local raw_value
  raw_value=$(get_config "$key" "$default")

  # Step 1: Validate raw config value before resolution
  validate_path "$raw_value" || {
    echo "SECURITY: Rejected config path '$key' = '$raw_value'" >&2
    return 1
  }

  # Step 2: Resolve environment variables
  local resolved
  resolved=$(resolve_path "$raw_value")

  # Step 3: Canonical path check — verify resolved path stays within project
  local canonical
  canonical=$(_canonical_path "$project_dir/$resolved")
  local project_canonical
  project_canonical=$(_canonical_path "$project_dir")

  if [[ "$canonical" != "$project_canonical"* ]]; then
    echo "SECURITY: Path escapes project boundary: $resolved -> $canonical" >&2
    return 1
  fi

  echo "$resolved"
}

# Cleanup temp file on exit
cleanup_config() {
  [ -n "${CONFIG_CACHE_FILE:-}" ] && [ -f "$CONFIG_CACHE_FILE" ] && rm -f "$CONFIG_CACHE_FILE"
}

trap cleanup_config EXIT

# Export functions for use in other scripts
export -f load_yaml
export -f load_config
export -f get_config
export -f resolve_path
export -f validate_path
export -f _canonical_path
export -f get_validated_path
