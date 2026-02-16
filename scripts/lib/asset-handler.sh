#!/usr/bin/env bash
# Asset Handler Utility for jaan.to Claude Code Plugin
# Handles image/asset path resolution and embedding for skill outputs

# Check if a path is inside any $JAAN_* directory
# Args: $1 = absolute path to check
# Returns: 0 (true) if inside $JAAN_*, 1 (false) if external
is_jaan_path() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "ERROR: path required" >&2
    return 1
  fi

  # Resolve to absolute path
  local abs_path
  abs_path=$(cd "$(dirname "$path")" 2>/dev/null && echo "$(pwd)/$(basename "$path")") || abs_path="$path"

  # Check against all $JAAN_* directories
  local jaan_dirs=("$JAAN_OUTPUTS_DIR" "$JAAN_TEMPLATES_DIR" "$JAAN_CONTEXT_DIR" "$JAAN_LEARN_DIR")

  for dir in "${jaan_dirs[@]}"; do
    if [[ -n "$dir" && "$abs_path" == "$dir"* ]]; then
      return 0
    fi
  done

  return 1
}

# Resolve the correct markdown-relative path for an asset
# Args: $1 = source asset path, $2 = output file path (the .md file that will reference it)
# Returns: Relative path string for use in markdown ![alt](path)
resolve_asset_path() {
  local source="$1"
  local output_file="$2"

  if [[ -z "$source" || -z "$output_file" ]]; then
    echo "ERROR: source and output_file required" >&2
    return 1
  fi

  if is_jaan_path "$source"; then
    # Asset is inside $JAAN_* — compute relative path from output file to source
    local output_dir
    output_dir=$(dirname "$output_file")
    python3 -c "import os; print(os.path.relpath('$source', '$output_dir'))" 2>/dev/null \
      || echo "$source"
  else
    # Asset is external — will be copied to ./assets/
    echo "./assets/$(basename "$source")"
  fi
}

# Copy external (non-$JAAN_*) assets into the output folder
# Args: $1 = source file or directory, $2 = output folder path
# Creates $output_folder/assets/ if needed
copy_external_assets() {
  local source="$1"
  local output_folder="$2"

  if [[ -z "$source" || -z "$output_folder" ]]; then
    echo "ERROR: source and output_folder required" >&2
    return 1
  fi

  local assets_dir="${output_folder}/assets"
  mkdir -p "$assets_dir"

  if [[ -d "$source" ]]; then
    # Copy directory contents
    cp -R "$source"/* "$assets_dir/" 2>/dev/null
  elif [[ -f "$source" ]]; then
    # Copy single file
    cp "$source" "$assets_dir/" 2>/dev/null
  else
    echo "ERROR: source not found: $source" >&2
    return 1
  fi
}

# URL-encode spaces and special characters in a path for markdown links
# Args: $1 = path string
# Returns: URL-encoded path
url_encode_path() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "ERROR: path required" >&2
    return 1
  fi

  # Encode spaces and common special characters that break markdown links
  echo "$path" | sed -e 's/ /%20/g' -e 's/(/%28/g' -e 's/)/%29/g'
}
