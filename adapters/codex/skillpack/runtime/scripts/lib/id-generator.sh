#!/usr/bin/env bash
# ID Generator Utility for jaan.to Claude Code Plugin
# Generates sequential IDs for output folders

# Generate next sequential ID in a subdomain directory
# Args: $1 = subdomain directory path
# Returns: Two-digit ID (e.g., "01", "16", "99")
set -euo pipefail

generate_next_id() {
  local subdomain_dir="$1"

  # Ensure directory path is provided
  if [[ -z "$subdomain_dir" ]]; then
    echo "ERROR: subdomain_dir required" >&2
    return 1
  fi

  # Count folders matching {NN}-* pattern
  local count=0
  if [[ -d "$subdomain_dir" ]]; then
    count=$(find "$subdomain_dir" -maxdepth 1 -type d -name "[0-9][0-9]-*" 2>/dev/null | wc -l | tr -d ' ')
  fi

  # Next ID = count + 1, padded to 2 digits
  local next_id=$((count + 1))
  printf "%02d" "$next_id"
}

# Generate folder path for output
# Args: $1 = subdomain directory path, $2 = slug
# Returns: Full folder path (e.g., "path/to/subdomain/01-my-slug")
generate_output_folder() {
  local subdomain_dir="$1"
  local slug="$2"

  # Validate inputs
  if [[ -z "$subdomain_dir" || -z "$slug" ]]; then
    echo "ERROR: subdomain_dir and slug required" >&2
    return 1
  fi

  local id=$(generate_next_id "$subdomain_dir")
  echo "${subdomain_dir}/${id}-${slug}"
}

# Generate main file path
# Args: $1 = folder path, $2 = report type (e.g., "prd", "story"), $3 = slug
# Returns: Full file path (e.g., "path/to/folder/01-prd-my-slug.md")
generate_main_file() {
  local folder="$1"
  local report_type="$2"
  local slug="$3"

  # Validate inputs
  if [[ -z "$folder" || -z "$report_type" || -z "$slug" ]]; then
    echo "ERROR: folder, report_type, and slug required" >&2
    return 1
  fi

  # Extract ID from folder name
  local id=$(basename "$folder" | cut -d'-' -f1)

  echo "${folder}/${id}-${report_type}-${slug}.md"
}

# List all existing IDs in a directory (for debugging/validation)
# Args: $1 = subdomain directory path
# Returns: Newline-separated list of IDs
list_existing_ids() {
  local subdomain_dir="$1"

  if [[ ! -d "$subdomain_dir" ]]; then
    return 0
  fi

  find "$subdomain_dir" -maxdepth 1 -type d -name "[0-9][0-9]-*" 2>/dev/null \
    | sed -E 's/.*\/([0-9]{2})-.*/\1/' \
    | sort -n
}

# Check if ID exists in directory
# Args: $1 = subdomain directory path, $2 = ID to check
# Returns: 0 if exists, 1 if not
id_exists() {
  local subdomain_dir="$1"
  local id="$2"

  if [[ ! -d "$subdomain_dir" ]]; then
    return 1
  fi

  [[ -n $(find "$subdomain_dir" -maxdepth 1 -type d -name "${id}-*" 2>/dev/null) ]]
}
