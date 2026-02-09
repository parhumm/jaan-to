#!/bin/bash
# validate-skills.sh — Check total skill description character budget
#
# Claude Code allocates a fixed budget (default 15,000 chars) for all skill
# descriptions in the system prompt. Each skill costs ~109 chars of XML
# overhead plus the description length. If total exceeds budget, skills
# get silently dropped.
#
# Usage: bash scripts/validate-skills.sh [budget]
# Exit 0 if under budget, exit 1 if over.

set -euo pipefail

BUDGET="${1:-${SLASH_COMMAND_TOOL_CHAR_BUDGET:-15000}}"
OVERHEAD_PER_SKILL=109  # approximate XML wrapper chars per skill

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PLUGIN_ROOT/skills"

TOTAL=0
COUNT=0
DETAILS=""

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  skill_name="$(basename "$skill_dir")"

  # Extract description from YAML frontmatter
  # Handles both single-line and multi-line (block scalar) descriptions
  desc=""
  in_frontmatter=false
  in_desc=false
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        break  # end of frontmatter
      fi
      in_frontmatter=true
      continue
    fi

    if $in_frontmatter; then
      if [[ "$line" =~ ^description:\ *\|[[:space:]]*$ ]]; then
        # Multi-line block scalar
        in_desc=true
        continue
      elif [[ "$line" =~ ^description:\ *\"(.*)\"$ ]]; then
        # Quoted single-line: description: "text"
        desc="${BASH_REMATCH[1]}"
        break
      elif [[ "$line" =~ ^description:\ *(.+)$ ]]; then
        # Unquoted single-line: description: text
        desc="${BASH_REMATCH[1]}"
        break
      fi

      if $in_desc; then
        # Multi-line continuation: indented lines
        if [[ "$line" =~ ^[[:space:]]+ ]]; then
          desc+="${line#"${line%%[![:space:]]*}"}"$'\n'
        else
          break
        fi
      fi
    fi
  done < "$skill_file"

  desc_len=${#desc}
  skill_cost=$((desc_len + OVERHEAD_PER_SKILL))
  TOTAL=$((TOTAL + skill_cost))
  COUNT=$((COUNT + 1))

  DETAILS+="$(printf "  %-35s %4d chars  (desc: %d + overhead: %d)\n" "$skill_name" "$skill_cost" "$desc_len" "$OVERHEAD_PER_SKILL")"$'\n'
done

echo "═══════════════════════════════════════"
echo "  Skill Description Budget Check"
echo "═══════════════════════════════════════"
echo ""
echo "Skills found: $COUNT"
echo ""
echo "$DETAILS"
echo "───────────────────────────────────────"
printf "  %-35s %4d chars\n" "TOTAL" "$TOTAL"
printf "  %-35s %4d chars\n" "BUDGET" "$BUDGET"
printf "  %-35s %4d chars\n" "REMAINING" "$((BUDGET - TOTAL))"
echo ""

if [ "$TOTAL" -gt "$BUDGET" ]; then
  OVER=$((TOTAL - BUDGET))
  echo "::error::Skill descriptions exceed budget by $OVER chars ($TOTAL / $BUDGET)"
  echo ""
  echo "Fix: Shorten descriptions in skills/*/SKILL.md"
  echo "     Keep each description under 120 chars (1-2 sentences)"
  echo "     Override budget: SLASH_COMMAND_TOOL_CHAR_BUDGET=20000 bash $0"
  exit 1
fi

echo "✓ Under budget ($TOTAL / $BUDGET)"
echo ""

# Check for YAML-unsafe colons in descriptions
COLON_ISSUES=""
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill_file")
  if echo "$desc" | grep -q ':'; then
    COLON_ISSUES+="  $skill_name: $desc"$'\n'
  fi
done
if [ -n "$COLON_ISSUES" ]; then
  echo "::error::Descriptions with colons (causes YAML parsing issues in Claude Code):"
  echo "$COLON_ISSUES"
  echo "Fix: Remove colons from description or quote the value"
  exit 1
fi

echo "✓ No YAML-unsafe colons in descriptions"
