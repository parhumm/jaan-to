#!/bin/bash
# learning-summary.sh — Generate learning insights report
# Scans all jaan-to/learn/*.learn.md files and creates summary with stats
# Usage: ./scripts/learning-summary.sh [--format=markdown|json]

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"

# Load configuration system
if [ -f "${PLUGIN_DIR}/scripts/lib/config-loader.sh" ]; then
  source "${PLUGIN_DIR}/scripts/lib/config-loader.sh"
  load_config
fi

# Resolve learning directory from config
LEARN_DIR=$(resolve_path "$(get_config 'paths_learning' 'jaan-to/learn')")

# Parse arguments
FORMAT="${1:-markdown}"
if [[ "$FORMAT" == --format=* ]]; then
  FORMAT="${FORMAT#--format=}"
fi

# Validate format
if [[ "$FORMAT" != "markdown" && "$FORMAT" != "json" ]]; then
  echo "Error: Invalid format '$FORMAT'. Use 'markdown' or 'json'." >&2
  exit 1
fi

# Check if learning directory exists
if [ ! -d "$PROJECT_DIR/$LEARN_DIR" ]; then
  echo "No learning directory found at $PROJECT_DIR/$LEARN_DIR" >&2
  exit 0
fi

# Initialize counters
declare -A SKILL_COUNTS
declare -A COMMON_MISTAKES
declare -A EDGE_CASES
TOTAL_FILES=0
TOTAL_LESSONS=0

# Scan all .learn.md files
while IFS= read -r -d '' file; do
  TOTAL_FILES=$((TOTAL_FILES + 1))

  # Extract skill name from filename (e.g., pm-prd-write.learn.md -> pm-prd-write)
  filename=$(basename "$file")
  skillname="${filename%.learn.md}"

  # Count lessons (sections starting with ##)
  lesson_count=$(grep -c "^## " "$file" || true)
  SKILL_COUNTS["$skillname"]=$lesson_count
  ((TOTAL_LESSONS += lesson_count))

  # Extract Common Mistakes section
  if grep -q "^### Common Mistakes" "$file"; then
    mistakes=$(sed -n '/^### Common Mistakes/,/^###/p' "$file" | grep -c "^- " || true)
    if [ "$mistakes" -gt 0 ]; then
      COMMON_MISTAKES["$skillname"]=$mistakes
    fi
  fi

  # Extract Edge Cases section
  if grep -q "^### Edge Cases" "$file"; then
    edges=$(sed -n '/^### Edge Cases/,/^###/p' "$file" | grep -c "^- " || true)
    if [ "$edges" -gt 0 ]; then
      EDGE_CASES["$skillname"]=$edges
    fi
  fi
done < <(find "$PROJECT_DIR/$LEARN_DIR" -name "*.learn.md" -type f -print0 2>/dev/null)

# Generate output based on format
if [ "$FORMAT" = "json" ]; then
  # JSON output
  echo "{"
  echo "  \"summary\": {"
  echo "    \"total_files\": $TOTAL_FILES,"
  echo "    \"total_lessons\": $TOTAL_LESSONS"
  echo "  },"
  echo "  \"skills\": {"

  first=true
  for skill in "${!SKILL_COUNTS[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      echo ","
    fi
    echo -n "    \"$skill\": {"
    echo -n "\"lessons\": ${SKILL_COUNTS[$skill]}"

    if [ -n "${COMMON_MISTAKES[$skill]:-}" ]; then
      echo -n ", \"common_mistakes\": ${COMMON_MISTAKES[$skill]}"
    fi

    if [ -n "${EDGE_CASES[$skill]:-}" ]; then
      echo -n ", \"edge_cases\": ${EDGE_CASES[$skill]}"
    fi

    echo -n "}"
  done

  echo ""
  echo "  }"
  echo "}"
else
  # Markdown output
  echo "# Learning Insights Report"
  echo ""
  echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "---"
  echo ""
  echo "## Summary"
  echo ""
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Total Skills with Lessons | $TOTAL_FILES |"
  echo "| Total Lessons Captured | $TOTAL_LESSONS |"

  if [ ${#COMMON_MISTAKES[@]} -gt 0 ]; then
    mistakes_total=0
    for count in "${COMMON_MISTAKES[@]}"; do
      ((mistakes_total += count))
    done
    echo "| Common Mistakes Documented | $mistakes_total |"
  fi

  if [ ${#EDGE_CASES[@]} -gt 0 ]; then
    edges_total=0
    for count in "${EDGE_CASES[@]}"; do
      ((edges_total += count))
    done
    echo "| Edge Cases Documented | $edges_total |"
  fi

  echo ""
  echo "---"
  echo ""
  echo "## Lessons by Skill"
  echo ""
  echo "| Skill | Lessons | Common Mistakes | Edge Cases |"
  echo "|-------|---------|-----------------|------------|"

  # Sort skills by lesson count (descending)
  for skill in $(for s in "${!SKILL_COUNTS[@]}"; do echo "$s ${SKILL_COUNTS[$s]}"; done | sort -k2 -rn | cut -d' ' -f1); do
    lessons=${SKILL_COUNTS[$skill]}
    mistakes=${COMMON_MISTAKES[$skill]:-0}
    edges=${EDGE_CASES[$skill]:-0}
    echo "| \`$skill\` | $lessons | $mistakes | $edges |"
  done

  echo ""
  echo "---"
  echo ""

  # Top skills by lesson count
  if [ $TOTAL_FILES -gt 0 ]; then
    echo "## Top Skills by Learning Activity"
    echo ""

    top_count=0
    for skill in $(for s in "${!SKILL_COUNTS[@]}"; do echo "$s ${SKILL_COUNTS[$s]}"; done | sort -k2 -rn | cut -d' ' -f1 | head -5); do
      ((top_count++))
      lessons=${SKILL_COUNTS[$skill]}
      echo "${top_count}. **\`$skill\`** — $lessons lessons"
    done

    echo ""
  fi

  # Coverage gaps
  echo "## Coverage Gaps"
  echo ""

  if [ $TOTAL_FILES -eq 0 ]; then
    echo "⚠️  **No learning files found.** Start capturing lessons with \`/jaan-to:learn-add\`"
  elif [ $TOTAL_LESSONS -lt 10 ]; then
    echo "⚠️  **Low lesson count ($TOTAL_LESSONS total).** Consider capturing more insights as you use skills."
  else
    # Find skills with no common mistakes or edge cases
    gaps_found=false
    for skill in "${!SKILL_COUNTS[@]}"; do
      if [ -z "${COMMON_MISTAKES[$skill]:-}" ] || [ -z "${EDGE_CASES[$skill]:-}" ]; then
        if [ "$gaps_found" = false ]; then
          echo "Skills missing structured insights:"
          echo ""
          gaps_found=true
        fi

        missing=""
        if [ -z "${COMMON_MISTAKES[$skill]:-}" ]; then
          missing="Common Mistakes"
        fi
        if [ -z "${EDGE_CASES[$skill]:-}" ]; then
          if [ -n "$missing" ]; then
            missing="$missing, Edge Cases"
          else
            missing="Edge Cases"
          fi
        fi

        echo "- \`$skill\` — Missing: $missing"
      fi
    done

    if [ "$gaps_found" = false ]; then
      echo "✅ All skills have Common Mistakes and Edge Cases documented."
    fi
  fi

  echo ""
  echo "---"
  echo ""
  echo "## Next Steps"
  echo ""
  echo "1. **Capture lessons:** Use \`/jaan-to:learn-add\` after each skill execution"
  echo "2. **Fill gaps:** Add Common Mistakes and Edge Cases to skills with missing insights"
  echo "3. **Review regularly:** Run this report weekly to track learning growth"
  echo ""
  echo "---"
  echo ""
  echo "*Generated by jaan.to learning-summary.sh*"
fi

exit 0
