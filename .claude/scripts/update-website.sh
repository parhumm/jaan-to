#!/bin/bash
# update-website.sh — Intelligent website/index.html updater
#
# Automatically updates website/index.html with:
# - Version badge
# - Skill and role counts (4 locations)
# - New/removed skills in catalog
# - New role sections
#
# Parses CHANGELOG for changes and suggests additional updates.
#
# Usage: bash .claude/scripts/update-website.sh [--dry-run]
# Exit 0 if successful, exit 1 if errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DRY_RUN=false
if [ "${1:-}" == "--dry-run" ]; then
  DRY_RUN=true
  echo "DRY RUN MODE - No changes will be written"
  echo ""
fi

echo "═══════════════════════════════════════════════════════════"
echo "  Intelligent Website Update"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. DETECT VERSION & COUNTS
# ─────────────────────────────────────────────────────────────

echo "Detection Phase"
echo "────────────────────────────────────────────────────────"

NEW_VERSION=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")
SKILL_COUNT=$(find "$PLUGIN_ROOT/skills" -mindepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
ROLE_COUNT=$(find "$PLUGIN_ROOT/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

echo "  Version:      v$NEW_VERSION"
echo "  Skills:       $SKILL_COUNT"
echo "  Roles:        $ROLE_COUNT"
echo ""

# ─────────────────────────────────────────────────────────────
# 2. PARSE CHANGELOG FOR NEW/REMOVED/CHANGED SKILLS
# ─────────────────────────────────────────────────────────────

echo "CHANGELOG Analysis"
echo "────────────────────────────────────────────────────────"

# Extract [Unreleased] section from CHANGELOG.md
UNRELEASED_SECTION=""
if [ -f "$PLUGIN_ROOT/CHANGELOG.md" ]; then
  UNRELEASED_SECTION=$(sed -n '/^## \[Unreleased\]/,/^## \[/p' "$PLUGIN_ROOT/CHANGELOG.md" | head -n -1 || echo "")
fi

# Detect new skills (look for "Add /skill-name" or "- /skill-name")
NEW_SKILLS=$(echo "$UNRELEASED_SECTION" | grep -E '^\- .*/(jaan-to:)?[a-z-]+' | grep -oE '/(jaan-to:)?[a-z-]+' | sed 's|/jaan-to:||g; s|^/||g' | sort -u || echo "")

# Detect removed skills
REMOVED_SKILLS=$(echo "$UNRELEASED_SECTION" | grep -i "remove" | grep -oE '/(jaan-to:)?[a-z-]+' | sed 's|/jaan-to:||g; s|^/||g' | sort -u || echo "")

# Detect new roles
NEW_ROLES=$(echo "$UNRELEASED_SECTION" | grep -oE 'Add [A-Z][a-z]+ role' | sed 's/Add \([A-Z][a-z]*\) role/\1/' | sort -u || echo "")

if [ -n "$NEW_SKILLS" ]; then
  echo "  New skills detected:"
  echo "$NEW_SKILLS" | sed 's/^/    - /'
else
  echo "  No new skills detected"
fi

if [ -n "$REMOVED_SKILLS" ]; then
  echo "  Removed skills detected:"
  echo "$REMOVED_SKILLS" | sed 's/^/    - /'
fi

if [ -n "$NEW_ROLES" ]; then
  echo "  New roles detected:"
  echo "$NEW_ROLES" | sed 's/^/    - /'
fi

echo ""

# ─────────────────────────────────────────────────────────────
# 3. UPDATE VERSION BADGE (Element 1)
# ─────────────────────────────────────────────────────────────

echo "Element 1: Version Badge"
echo "────────────────────────────────────────────────────────"

WEBSITE_FILE="$PLUGIN_ROOT/website/index.html"

if [ ! -f "$WEBSITE_FILE" ]; then
  echo "  ::error::website/index.html not found"
  exit 1
fi

CURRENT_WEB_VERSION=$(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' "$WEBSITE_FILE" | head -1 || echo "unknown")
echo "  Current: $CURRENT_WEB_VERSION"
echo "  New:     v$NEW_VERSION"

if [ "$DRY_RUN" == "false" ]; then
  # Update version badge (around line 1098)
  sed -i.bak "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v$NEW_VERSION/g" "$WEBSITE_FILE"
  echo "  ✓ Updated version badge"
else
  echo "  [DRY RUN] Would update version badge"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# 4. UPDATE SKILL & ROLE COUNTS (Elements 2, 3, 4)
# ─────────────────────────────────────────────────────────────

echo "Elements 2-4: Skill & Role Counts"
echo "────────────────────────────────────────────────────────"

# Extract current counts from website
CURRENT_COUNTS=$(grep -o '[0-9]\+ structured commands across [0-9]\+ roles' "$WEBSITE_FILE" | head -1 || echo "unknown")
echo "  Current: $CURRENT_COUNTS"
echo "  New:     $SKILL_COUNT structured commands across $ROLE_COUNT roles"

if [ "$DRY_RUN" == "false" ]; then
  # Element 2: System Card (line 1231)
  sed -i.bak "s/[0-9]\+ structured commands across [0-9]\+ roles/$SKILL_COUNT structured commands across $ROLE_COUNT roles/g" "$WEBSITE_FILE"

  # Element 3: System Stats (line 1250)
  sed -i.bak "s/[0-9]\+ skills available now\. [0-9]\+ active roles/$SKILL_COUNT skills available now. $ROLE_COUNT active roles/g" "$WEBSITE_FILE"

  # Element 4: Vision Section (line 1694)
  sed -i.bak "s/[0-9]\+ production skills/$SKILL_COUNT production skills/g" "$WEBSITE_FILE"

  echo "  ✓ Updated all 3 count locations"
else
  echo "  [DRY RUN] Would update skill/role counts"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# 5. CATALOG UPDATES (Elements 5, 6) - MANUAL REVIEW NEEDED
# ─────────────────────────────────────────────────────────────

echo "Elements 5-6: Skill Catalog Updates"
echo "────────────────────────────────────────────────────────"

if [ -n "$NEW_SKILLS" ] || [ -n "$REMOVED_SKILLS" ]; then
  echo "  ⚠ Manual catalog updates required:"
  echo ""

  if [ -n "$NEW_SKILLS" ]; then
    echo "  NEW SKILLS - Add these to catalog:"
    echo "$NEW_SKILLS" | while IFS= read -r skill; do
      [ -z "$skill" ] && continue

      # Try to find skill description from CHANGELOG
      DESC=$(echo "$UNRELEASED_SECTION" | grep "/$skill" | sed -E 's/.*— (.*)/\1/' | sed 's/\.$//' || echo "Description needed")

      # Detect role from skill directory name
      ROLE_DIR=$(find "$PLUGIN_ROOT/skills" -name "SKILL.md" | grep "/$skill/SKILL.md" | xargs dirname | xargs basename || echo "unknown")

      echo ""
      echo "    Skill: $skill"
      echo "    Role:  $ROLE_DIR"
      echo "    Desc:  $DESC"
      echo ""
      echo "    HTML to add:"
      cat <<EOF
                        <li class="catalog-skill">
                            <span class="catalog-skill-dot"></span>
                            <code class="catalog-skill-command">/$skill</code>
                            <span class="catalog-skill-sep">&mdash;</span>
                            <span class="catalog-skill-desc">$DESC</span>
                        </li>
EOF
      echo ""
    done
  fi

  if [ -n "$REMOVED_SKILLS" ]; then
    echo "  REMOVED SKILLS - Delete these from catalog:"
    echo "$REMOVED_SKILLS" | while IFS= read -r skill; do
      [ -z "$skill" ] && continue
      echo "    - Search for: <code class=\"catalog-skill-command\">/$skill</code>"
      echo "      Delete entire <li class=\"catalog-skill\">...</li> block"
      echo ""
    done
  fi

  echo "  Location: website/index.html lines 1267-1625 (catalog sections)"
  echo ""
else
  echo "  ✓ No catalog changes needed"
  echo ""
fi

# ─────────────────────────────────────────────────────────────
# 6. SMART SUGGESTIONS
# ─────────────────────────────────────────────────────────────

echo "Smart Suggestions"
echo "────────────────────────────────────────────────────────"

SUGGESTIONS=0

# Suggestion 7: New Role Sections
if [ -n "$NEW_ROLES" ]; then
  echo "  ⚠ New roles detected - add role sections:"
  echo "$NEW_ROLES" | while IFS= read -r role; do
    [ -z "$role" ] && continue
    echo ""
    echo "    Role: $role"
    echo "    Location: Insert before 'Coming Soon' placeholder (around line 1618)"
    echo ""
    echo "    HTML template:"
    cat <<EOF
                <!-- $role -->
                <div class="catalog-role reveal">
                    <div class="catalog-role-header">
                        <span class="catalog-role-name">$role</span>
                        <span class="catalog-badge available">Available</span>
                    </div>
                    <ul class="catalog-skills">
                        <!-- Add skills here -->
                    </ul>
                </div>
EOF
    echo ""
  done
  SUGGESTIONS=$((SUGGESTIONS + 1))
fi

# Suggestion 8: Efficiency Metrics
if echo "$UNRELEASED_SECTION" | grep -qi "token\|optimization\|efficiency\|reduce.*chars"; then
  echo "  ⚠ Token/optimization changes mentioned in CHANGELOG"
  echo "    Consider updating efficiency metrics (lines 1643-1653)"
  echo "    Location: website/index.html - Token Intelligence section"
  echo ""
  SUGGESTIONS=$((SUGGESTIONS + 1))
fi

# Suggestion 9: Vision Horizon Updates
if echo "$UNRELEASED_SECTION" | grep -qi "milestone\|roadmap\|vision\|horizon"; then
  echo "  ⚠ Milestone/vision keywords in CHANGELOG"
  echo "    Consider updating vision horizons (lines 1692-1704)"
  echo "    Location: website/index.html - Vision section"
  echo ""
  SUGGESTIONS=$((SUGGESTIONS + 1))
fi

# Check if backup file was created
if [ -f "$WEBSITE_FILE.bak" ] && [ "$DRY_RUN" == "false" ]; then
  rm "$WEBSITE_FILE.bak"
fi

if [ $SUGGESTIONS -eq 0 ]; then
  echo "  ✓ No additional suggestions"
else
  echo "  Total: $SUGGESTIONS smart suggestions"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════"
echo "  Website Update Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ "$DRY_RUN" == "true" ]; then
  echo "  DRY RUN - No changes written"
else
  echo "  ✓ Version badge:   v$NEW_VERSION"
  echo "  ✓ Skill counts:    $SKILL_COUNT skills (3 locations)"
  echo "  ✓ Role count:      $ROLE_COUNT roles (2 locations)"
fi

echo ""

if [ -n "$NEW_SKILLS" ] || [ -n "$REMOVED_SKILLS" ] || [ $SUGGESTIONS -gt 0 ]; then
  echo "  ⚠ MANUAL REVIEW REQUIRED"
  echo ""
  echo "  Next steps:"
  echo "  1. Review catalog changes above"
  echo "  2. Edit website/index.html to add/remove skills"
  echo "  3. Address smart suggestions if applicable"
  echo "  4. Preview: open website/index.html in browser"
  echo "  5. Commit changes: git add website/index.html"
  echo ""
else
  echo "  ✓ COMPLETE - All automated updates applied"
  echo ""
fi

exit 0