#!/bin/bash
# jaan.to Learning File Merger
# Merges learning files from plugin and project sources
# Supports merge strategy (combine) or override strategy (replace)
# Compatible with bash 3.2+ (macOS default)

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config-loader.sh"
source "${SCRIPT_DIR}/path-resolver.sh"
source "${SCRIPT_DIR}/template-processor.sh"

merge_learning_files() {
  local skill_name=$1
  local output_file=$2

  # Ensure config is loaded
  if [ -z "${CONFIG_CACHE_FILE:-}" ] || [ ! -f "${CONFIG_CACHE_FILE:-}" ]; then
    load_config
  fi

  # Get learning strategy
  local strategy=$(get_config "learning_strategy" "merge")

  if [ "$strategy" != "merge" ]; then
    # Override strategy - just use project or plugin
    local learning_path=$(resolve_learning_path "$skill_name")

    # If learning_path has pipe delimiter, take first one
    learning_path="${learning_path%%|*}"

    if [ -f "$learning_path" ]; then
      cp "$learning_path" "$output_file"
    else
      # Create empty learning file
      cat > "$output_file" <<EOF
# Lessons: ${skill_name}

> No lessons yet

---

## Better Questions

(No lessons yet)

## Edge Cases

(No lessons yet)

## Workflow

(No lessons yet)

## Common Mistakes

(No lessons yet)
EOF
    fi
    return 0
  fi

  # Merge strategy - combine plugin + project
  local sources=$(resolve_learning_path "$skill_name")

  # Split sources by pipe delimiter
  IFS='|' read -ra SOURCE_ARRAY <<< "$sources"

  # If no sources, create empty file
  if [ ${#SOURCE_ARRAY[@]} -eq 0 ] || [ -z "${sources}" ]; then
    cat > "$output_file" <<EOF
# Lessons: ${skill_name}

> No lessons yet

---

## Better Questions

(No lessons yet)

## Edge Cases

(No lessons yet)

## Workflow

(No lessons yet)

## Common Mistakes

(No lessons yet)
EOF
    return 0
  fi

  # Initialize output with header
  cat > "$output_file" <<EOF
# Lessons: ${skill_name}

> Combined from ${#SOURCE_ARRAY[@]} source(s)
> Last updated: $(date +%Y-%m-%d)

---

EOF

  # Merge each section
  for section in "Better Questions" "Edge Cases" "Workflow" "Common Mistakes"; do
    echo "## ${section}" >> "$output_file"
    echo "" >> "$output_file"

    local has_content=0

    for source_file in "${SOURCE_ARRAY[@]}"; do
      if [ -f "$source_file" ]; then
        # Determine source label
        local source_label="plugin"
        if [[ "$source_file" == *"/jaan-to/learn/"* ]]; then
          source_label="project"
        fi

        # Extract section content
        local section_content=$(extract_section "$source_file" "$section")

        if [ -n "$section_content" ]; then
          # Trim leading/trailing whitespace
          section_content=$(echo "$section_content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

          if [ -n "$section_content" ]; then
            echo "<!-- source: ${source_label} -->" >> "$output_file"
            echo "$section_content" >> "$output_file"
            echo "" >> "$output_file"
            has_content=1
          fi
        fi
      fi
    done

    # If no content was added, note it
    if [ $has_content -eq 0 ]; then
      echo "(No lessons yet)" >> "$output_file"
      echo "" >> "$output_file"
    fi

    echo "---" >> "$output_file"
    echo "" >> "$output_file"
  done
}

# Export functions for use in other scripts
export -f merge_learning_files
