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
echo ""

# Check SKILL.md body line limits
BODY_HARD_CAP=600
BODY_SOFT_CAP=500
OVER_HARD=""
OVER_SOFT=""
DOCS_DIR="$PLUGIN_ROOT/docs/extending"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  lines=$(wc -l < "$skill_file" | tr -d ' ')

  if [ "$lines" -gt "$BODY_HARD_CAP" ]; then
    OVER_HARD+="  $skill_name: $lines lines (hard cap: $BODY_HARD_CAP)"$'\n'
  elif [ "$lines" -gt "$BODY_SOFT_CAP" ]; then
    # Check if reference file exists
    has_ref=false
    for ref in "$DOCS_DIR/${skill_name}-reference.md" "$DOCS_DIR/detect-shared-reference.md"; do
      [ -f "$ref" ] && has_ref=true && break
    done
    if ! $has_ref; then
      OVER_SOFT+="  $skill_name: $lines lines (no reference file found)"$'\n'
    fi
  fi
done

if [ -n "$OVER_HARD" ]; then
  echo "::error::SKILL.md files exceeding $BODY_HARD_CAP line hard cap:"
  echo "$OVER_HARD"
  echo "Fix: Extract lookup tables, templates, and rubrics to docs/extending/{name}-reference.md"
  exit 1
fi
echo "✓ All SKILL.md files under $BODY_HARD_CAP line hard cap"

if [ -n "$OVER_SOFT" ]; then
  echo "::warning::SKILL.md files over $BODY_SOFT_CAP lines without reference files:"
  echo "$OVER_SOFT"
  echo "Consider extracting content to docs/extending/{name}-reference.md"
fi
echo ""

# Check auto-invocable skill count
AUTO_INVOKE_CAP=35
AUTO_COUNT=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  if ! grep -q 'disable-model-invocation: true' "$skill_file"; then
    AUTO_COUNT=$((AUTO_COUNT + 1))
  fi
done

if [ "$AUTO_COUNT" -gt "$AUTO_INVOKE_CAP" ]; then
  echo "::warning::Auto-invocable skill count ($AUTO_COUNT) exceeds $AUTO_INVOKE_CAP"
  echo "Consider setting disable-model-invocation: true on narrow-domain skills"
else
  echo "✓ Auto-invocable skills: $AUTO_COUNT / $AUTO_INVOKE_CAP cap"
fi
echo ""

# ─────────────────────────────────────────────────────
# Agent Skills Standard Compliance
# ─────────────────────────────────────────────────────

echo "═══════════════════════════════════════"
echo "  Agent Skills Standard Compliance"
echo "═══════════════════════════════════════"
echo ""

AS_ERRORS=0

# Check license field in all SKILL.md
MISSING_LICENSE=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  if ! grep -q '^license:' "$skill_file"; then
    echo "  ⚠ Missing 'license:' field in $skill_name"
    MISSING_LICENSE=$((MISSING_LICENSE + 1))
  fi
done
if [ "$MISSING_LICENSE" -eq 0 ]; then
  echo "✓ All skills have license field"
else
  echo "::warning::$MISSING_LICENSE skills missing license field"
fi

# Check compatibility field in all SKILL.md
MISSING_COMPAT=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  if ! grep -q '^compatibility:' "$skill_file"; then
    echo "  ⚠ Missing 'compatibility:' field in $skill_name"
    MISSING_COMPAT=$((MISSING_COMPAT + 1))
  fi
done
if [ "$MISSING_COMPAT" -eq 0 ]; then
  echo "✓ All skills have compatibility field"
else
  echo "::warning::$MISSING_COMPAT skills missing compatibility field"
fi

# Check "Use when" or "Use to" trigger phrases in descriptions
MISSING_TRIGGER=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill_file")
  if ! echo "$desc" | grep -qi "Use when\|Use to\|Use for"; then
    echo "  ⚠ Description missing trigger phrase in $skill_name"
    MISSING_TRIGGER=$((MISSING_TRIGGER + 1))
  fi
done
if [ "$MISSING_TRIGGER" -eq 0 ]; then
  echo "✓ All descriptions have trigger phrases"
else
  echo "::warning::$MISSING_TRIGGER descriptions missing 'Use when/to/for' trigger phrase"
fi

# Check no [Internal] prefix in descriptions
INTERNAL_PREFIX=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$skill_dir")"
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill_file")
  if echo "$desc" | grep -q '\[Internal\]'; then
    echo "  ⚠ [Internal] prefix in description of $skill_name"
    INTERNAL_PREFIX=$((INTERNAL_PREFIX + 1))
  fi
done
if [ "$INTERNAL_PREFIX" -eq 0 ]; then
  echo "✓ No [Internal] prefixes in descriptions"
else
  echo "::warning::$INTERNAL_PREFIX descriptions have [Internal] prefix"
fi

# Check skill name compliance (lowercase, hyphens only, no consecutive hyphens, 1-64 chars)
INVALID_NAMES=0
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if [[ ! "$skill_name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$skill_name" =~ -- ]] || [ ${#skill_name} -gt 64 ]; then
    echo "  ✗ Invalid skill name: $skill_name"
    INVALID_NAMES=$((INVALID_NAMES + 1))
  fi
done
if [ "$INVALID_NAMES" -eq 0 ]; then
  echo "✓ All skill names are spec-compliant"
else
  echo "::error::$INVALID_NAMES skill names violate Agent Skills naming spec"
  AS_ERRORS=$((AS_ERRORS + INVALID_NAMES))
fi

# Check marketplace.json skills[] sync
MARKETPLACE="$PLUGIN_ROOT/.claude-plugin/marketplace.json"
if [ -f "$MARKETPLACE" ]; then
  MANIFEST_COUNT=$(jq '.plugins[0].skills | length' "$MARKETPLACE" 2>/dev/null || echo 0)
  ACTUAL_COUNT=$(ls -d "$SKILLS_DIR"/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$MANIFEST_COUNT" -eq "$ACTUAL_COUNT" ]; then
    echo "✓ marketplace.json skills[] synced ($ACTUAL_COUNT skills)"
  else
    echo "::warning::marketplace.json skills[] ($MANIFEST_COUNT) != actual ($ACTUAL_COUNT)"
    echo "  Update .claude-plugin/marketplace.json skills[] array"
  fi
else
  echo "  ⚠ No marketplace.json found"
fi

echo ""
if [ "$AS_ERRORS" -gt 0 ]; then
  echo "::error::$AS_ERRORS Agent Skills standard errors (blocking)"
  exit 1
fi
