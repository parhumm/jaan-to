#!/bin/bash
# jaan.to Template Processing
# Handles template variables, section imports, and composition
# Compatible with bash 3.2+ (macOS default)

# Load configuration system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config-loader.sh"
source "${SCRIPT_DIR}/path-resolver.sh"

process_template() {
  local skill_name=$1
  local output_file=$2

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  # Check if template uses inheritance (future feature)
  local extends=$(get_config "templates_${skill_name//-/_}_extends" "")

  if [ -z "$extends" ]; then
    # Simple template - just resolve path and copy
    local template_path=$(resolve_template_path "$skill_name")
    if [ $? -eq 0 ] && [ -f "$template_path" ]; then
      cp "$template_path" "$output_file"
      return 0
    else
      echo "ERROR: Template not found for skill: ${skill_name}" >&2
      return 1
    fi
  fi

  # Template inheritance (v3.1+ feature)
  # For v3.0, we only support simple templates
  echo "INFO: Template inheritance not yet implemented" >&2
  return 1
}

substitute_template_vars() {
  local content="$1"
  local context="$2"  # key=value pairs, one per line

  # Substitute {{field}} variables from context
  if [ -n "$context" ]; then
    while IFS='=' read -r key value; do
      # Skip empty lines
      [ -z "$key" ] && continue

      # Escape special characters in value for sed
      value=$(echo "$value" | sed 's/[&/\]/\\&/g')

      # Substitute {{key}} with value
      content=$(echo "$content" | sed "s/{{${key}}}/${value}/g")
    done <<< "$context"
  fi

  # Substitute {{env:VAR}} variables
  while [[ "$content" =~ \{\{env:([A-Z_]+)\}\} ]]; do
    local var_name="${BASH_REMATCH[1]}"
    local var_value="${!var_name:-}"

    # Escape special characters
    var_value=$(echo "$var_value" | sed 's/[&/\]/\\&/g')

    # Replace first occurrence
    content=$(echo "$content" | sed "s/{{env:${var_name}}}/${var_value}/")
  done

  # Substitute {{config:key}} variables
  while [[ "$content" =~ \{\{config:([a-zA-Z_]+)\}\} ]]; do
    local config_key="${BASH_REMATCH[1]}"

    # Ensure config is loaded
    if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
      load_config
    fi

    local config_value=$(get_config "$config_key" "")

    # Escape special characters
    config_value=$(echo "$config_value" | sed 's/[&/\]/\\&/g')

    # Replace first occurrence
    content=$(echo "$content" | sed "s/{{config:${config_key}}}/${config_value}/")
  done

  # Substitute {{import:path#section}} directives
  # For v3.0, we support basic section extraction
  while [[ "$content" =~ \{\{import:([^}]+)\}\} ]]; do
    local import_spec="${BASH_REMATCH[1]}"
    local file_path="${import_spec%#*}"
    local section="${import_spec#*#}"

    # Read section from file
    local project_dir="${PROJECT_DIR:-.}"
    local imported=""

    if [ -f "${project_dir}/${file_path}" ]; then
      imported=$(extract_section "${project_dir}/${file_path}" "$section")
    fi

    # Escape special characters
    imported=$(echo "$imported" | sed 's/[&/\]/\\&/g')

    # Replace first occurrence (one at a time to handle multiple imports)
    content=$(echo "$content" | sed "s/{{import:${import_spec}}}/${imported}/")
  done

  echo "$content"
}

extract_section() {
  local file=$1
  local section=$2

  # Extract markdown section by heading
  # Matches both "## Section" and "## Section {#anchor}"
  awk -v section="$section" '
    BEGIN { printing=0; found=0 }

    # Match heading with section name (with or without anchor)
    /^## / {
      # Check if this line contains our section
      if ($0 ~ section) {
        printing=1
        found=1
        next
      }
      # If we were printing and hit another ## heading, stop
      else if (printing) {
        exit
      }
    }

    # Stop at next ## heading
    /^## / && printing {
      exit
    }

    # Print lines while in section (skip the heading itself)
    printing {
      print
    }

    END {
      if (!found) {
        # Section not found - print nothing
      }
    }
  ' "$file"
}

# Test helper for template variable substitution
test_substitute() {
  local template="$1"
  local context="$2"
  substitute_template_vars "$template" "$context"
}

# Export functions for use in other scripts
export -f process_template
export -f substitute_template_vars
export -f extract_section
export -f test_substitute
