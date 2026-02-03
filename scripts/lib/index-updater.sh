#!/usr/bin/env bash
# Index Updater Utility for jaan.to Claude Code Plugin
# Manages README.md indexes for output subdirectories

# Add entry to subdomain index
# Args: $1 = README path, $2 = id, $3 = folder_name, $4 = title, $5 = summary
add_to_index() {
  local readme_path="$1"
  local id="$2"
  local folder_name="$3"
  local title="$4"
  local summary="$5"
  local date=$(date +%Y-%m-%d)

  # Validate inputs
  if [[ -z "$readme_path" || -z "$id" || -z "$folder_name" || -z "$title" || -z "$summary" ]]; then
    echo "ERROR: All parameters required (readme_path, id, folder_name, title, summary)" >&2
    return 1
  fi

  # Create README if doesn't exist
  if [[ ! -f "$readme_path" ]]; then
    create_index_template "$readme_path"
  fi

  # Escape special characters for sed
  local escaped_title=$(echo "$title" | sed 's/[&/\]/\\&/g')
  local escaped_summary=$(echo "$summary" | sed 's/[&/\]/\\&/g')

  # Add entry to table (after header, which is line 3)
  local entry="| [$id]($folder_name/) | $escaped_title | $escaped_summary | $date |"

  # macOS vs Linux sed compatibility
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "3a\\
$entry" "$readme_path"
  else
    sed -i "3a\\$entry" "$readme_path"
  fi
}

# Create index template file
# Args: $1 = README path
create_index_template() {
  local readme_path="$1"

  # Validate input
  if [[ -z "$readme_path" ]]; then
    echo "ERROR: readme_path required" >&2
    return 1
  fi

  # Ensure parent directory exists
  local parent_dir=$(dirname "$readme_path")
  mkdir -p "$parent_dir"

  # Extract subdomain name from path
  local subdomain=$(basename "$parent_dir")

  # Capitalize first letter
  local capitalized=$(echo "$subdomain" | sed 's/.*/\u&/')

  cat > "$readme_path" <<EOF
# $capitalized Outputs

| # | Title | Summary | Date |
|---|-------|---------|------|
EOF
}

# Update index counts (for master index)
# Args: $1 = subdomain directory path
# Returns: Count of outputs in subdomain
count_outputs() {
  local subdomain_dir="$1"

  if [[ ! -d "$subdomain_dir" ]]; then
    echo "0"
    return 0
  fi

  find "$subdomain_dir" -maxdepth 1 -type d -name "[0-9][0-9]-*" 2>/dev/null | wc -l | tr -d ' '
}

# Get latest outputs from subdomain
# Args: $1 = subdomain directory path, $2 = limit (default 5)
# Returns: List of latest folder names, sorted by ID descending
get_latest_outputs() {
  local subdomain_dir="$1"
  local limit="${2:-5}"

  if [[ ! -d "$subdomain_dir" ]]; then
    return 0
  fi

  find "$subdomain_dir" -maxdepth 1 -type d -name "[0-9][0-9]-*" 2>/dev/null \
    | xargs -n1 basename \
    | sort -rn \
    | head -n "$limit"
}

# Validate index integrity (check all folders are in index)
# Args: $1 = subdomain directory path
# Returns: 0 if valid, 1 if missing entries
validate_index() {
  local subdomain_dir="$1"
  local readme_path="${subdomain_dir}/README.md"

  if [[ ! -f "$readme_path" ]]; then
    echo "WARNING: Index not found: $readme_path" >&2
    return 1
  fi

  local errors=0

  # Check each folder is in index
  for folder in $(find "$subdomain_dir" -maxdepth 1 -type d -name "[0-9][0-9]-*" 2>/dev/null); do
    local folder_name=$(basename "$folder")
    local id=$(echo "$folder_name" | cut -d'-' -f1)

    if ! grep -q "\[$id\]" "$readme_path"; then
      echo "ERROR: Missing index entry for $folder_name" >&2
      ((errors++))
    fi
  done

  if [[ $errors -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}
