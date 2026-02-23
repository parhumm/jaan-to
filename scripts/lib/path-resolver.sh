#!/bin/bash
# jaan.to Path Resolution
# Resolves paths for templates, learning files, context, and outputs
# Supports customization via project config

# Load configuration system
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config-loader.sh"

resolve_template_path() {
  local skill_name=$1
  local template_file="${skill_name}.template.md"

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  # Check project custom template first (explicit override in config)
  local project_config=$(get_config "templates_${skill_name//-/_}_path" "")
  if [ -n "$project_config" ]; then
    # Security: validate custom path before resolution
    validate_path "$project_config" || {
      echo "SECURITY: Rejected template path override for ${skill_name}: ${project_config}" >&2
      return 1
    }
    local resolved=$(resolve_path "$project_config")
    # Security: canonical check — ensure resolved path stays within project
    local _canonical=$(_canonical_path "${PROJECT_DIR:-.}/$resolved")
    local _project_canonical=$(_canonical_path "${PROJECT_DIR:-.}")
    if [[ "$_canonical" != "$_project_canonical"* ]]; then
      echo "SECURITY: Template path escapes project: $resolved" >&2
      return 1
    fi
    if [ -f "${PROJECT_DIR:-.}/$resolved" ]; then
      echo "$resolved"
      return 0
    fi
  fi

  # Check standard project location (three-tier: dash → colon legacy → unprefixed)
  local templates_dir=$(get_config "paths_templates" "jaan-to/templates")
  local dash_file="jaan-to-${template_file}"
  local colon_file="jaan-to:${template_file}"
  if [ -f "${PROJECT_DIR:-.}/${templates_dir}/${dash_file}" ]; then
    echo "${templates_dir}/${dash_file}"
    return 0
  fi
  if [ -f "${PROJECT_DIR:-.}/${templates_dir}/${colon_file}" ]; then
    echo "${templates_dir}/${colon_file}"
    return 0
  fi
  if [ -f "${PROJECT_DIR:-.}/${templates_dir}/${template_file}" ]; then
    echo "${templates_dir}/${template_file}"
    return 0
  fi

  # Fall back to plugin default
  local plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
  if [ -f "${plugin_root}/skills/${skill_name}/template.md" ]; then
    echo "${plugin_root}/skills/${skill_name}/template.md"
    return 0
  fi

  # Not found
  echo "ERROR: Template not found for skill: ${skill_name}" >&2
  return 1
}

resolve_learning_path() {
  local skill_name=$1
  local learn_file="${skill_name}.learn.md"

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  # Get merge strategy
  local strategy=$(get_config "learning_strategy" "merge")

  if [ "$strategy" = "merge" ]; then
    # Return all sources (plugin + project), pipe-delimited
    local sources=""
    local plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

    # Plugin source
    if [ -f "${plugin_root}/skills/${skill_name}/LEARN.md" ]; then
      sources="${plugin_root}/skills/${skill_name}/LEARN.md"
    fi

    # Project source (three-tier: dash → colon legacy → unprefixed)
    local learn_dir=$(get_config "paths_learning" "jaan-to/learn")
    local dash_learn="jaan-to-${learn_file}"
    local colon_learn="jaan-to:${learn_file}"
    local project_learn=""
    if [ -f "${PROJECT_DIR:-.}/${learn_dir}/${dash_learn}" ]; then
      project_learn="${PROJECT_DIR:-.}/${learn_dir}/${dash_learn}"
    elif [ -f "${PROJECT_DIR:-.}/${learn_dir}/${colon_learn}" ]; then
      project_learn="${PROJECT_DIR:-.}/${learn_dir}/${colon_learn}"
    elif [ -f "${PROJECT_DIR:-.}/${learn_dir}/${learn_file}" ]; then
      project_learn="${PROJECT_DIR:-.}/${learn_dir}/${learn_file}"
    fi
    if [ -n "$project_learn" ]; then
      if [ -n "$sources" ]; then
        sources="${sources}|${project_learn}"
      else
        sources="${project_learn}"
      fi
    fi

    echo "$sources"
    return 0
  else
    # Override strategy: project only, or plugin if project doesn't exist
    # Three-tier: dash → colon legacy → unprefixed
    local learn_dir=$(get_config "paths_learning" "jaan-to/learn")
    local dash_learn="jaan-to-${learn_file}"
    local colon_learn="jaan-to:${learn_file}"
    if [ -f "${PROJECT_DIR:-.}/${learn_dir}/${dash_learn}" ]; then
      echo "${PROJECT_DIR:-.}/${learn_dir}/${dash_learn}"
      return 0
    fi
    if [ -f "${PROJECT_DIR:-.}/${learn_dir}/${colon_learn}" ]; then
      echo "${PROJECT_DIR:-.}/${learn_dir}/${colon_learn}"
      return 0
    fi
    if [ -f "${PROJECT_DIR:-.}/${learn_dir}/${learn_file}" ]; then
      echo "${PROJECT_DIR:-.}/${learn_dir}/${learn_file}"
      return 0
    fi

    # Fall back to plugin
    local plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
    if [ -f "${plugin_root}/skills/${skill_name}/LEARN.md" ]; then
      echo "${plugin_root}/skills/${skill_name}/LEARN.md"
      return 0
    fi

    # Not found (non-fatal for learning files)
    echo ""
    return 0
  fi
}

resolve_context_path() {
  local filename=$1

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  local context_dir=$(get_config "paths_context" "jaan-to/context")
  echo "${context_dir}/${filename}"
}

resolve_output_path() {
  local role=$1
  local domain=$2

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  local outputs_dir=$(get_config "paths_outputs" "jaan-to/outputs")
  echo "${outputs_dir}/${role}/${domain}"
}

# Export functions for use in other scripts
export -f resolve_template_path
export -f resolve_learning_path
export -f resolve_context_path
export -f resolve_output_path
