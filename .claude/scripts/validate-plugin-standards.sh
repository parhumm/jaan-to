#!/bin/bash
# validate-plugin-standards.sh — Critical plugin infrastructure standards
#
# Checks 11-16 from the validation checklist. These are blocking checks that
# prevent plugin installation/runtime failures. All must pass.
#
# Usage: bash .claude/scripts/validate-plugin-standards.sh
# Exit 0 if pass, exit 1 if any check fails

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ERRORS=0

echo "═══════════════════════════════════════════════════════════"
echo "  Plugin Standards Validation (Checks 11-16)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# Check 11: Plugin Manifest Validation
# ─────────────────────────────────────────────────────────────

echo "Check 11: Plugin Manifest Validation"
echo "────────────────────────────────────────────────────────"

# Validate plugin.json syntax
if jq empty "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null; then
  echo "  ✓ plugin.json is valid JSON"
else
  echo "  ::error::.claude-plugin/plugin.json is invalid JSON"
  ((ERRORS++))
fi

# Validate marketplace.json syntax
if jq empty "$PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null; then
  echo "  ✓ marketplace.json is valid JSON"
else
  echo "  ::error::.claude-plugin/marketplace.json is invalid JSON"
  ((ERRORS++))
fi

# Check for component path declarations (should use auto-discovery)
for field in skills agents hooks commands; do
  VALUE=$(jq -r ".$field // \"null\"" "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null)
  if [ "$VALUE" != "null" ]; then
    echo "  ::error::plugin.json declares '$field' field (causes validation failure)"
    echo "           Claude Code uses auto-discovery. Remove this field."
    ((ERRORS++))
  fi
done

if [ $ERRORS -eq 0 ]; then
  echo "  ✓ No component path declarations (using auto-discovery)"
fi

# Check version consistency across 3 locations
V1=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "MISSING")
V2=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null || echo "MISSING")
V3=$(jq -r '.plugins[0].version' "$PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null || echo "MISSING")

if [[ "$V1" == "$V2" ]] && [[ "$V1" == "$V3" ]] && [[ "$V1" != "MISSING" ]]; then
  echo "  ✓ Version consistent across all 3 locations: $V1"
else
  echo "  ::error::Version mismatch:"
  echo "           plugin.json: $V1"
  echo "           marketplace.json (top): $V2"
  echo "           marketplace.json (plugins[0]): $V3"
  echo "  Fix: Run bash scripts/bump-version.sh X.Y.Z"
  ((ERRORS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 12: Hooks Validation
# ─────────────────────────────────────────────────────────────

echo "Check 12: Hooks Validation"
echo "────────────────────────────────────────────────────────"

# Validate hooks.json syntax
if jq empty "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null; then
  echo "  ✓ hooks.json is valid JSON"
else
  echo "  ::error::hooks/hooks.json is invalid JSON"
  ((ERRORS++))
fi

# Check at least one hook defined
HOOK_COUNT=$(jq '.hooks | length' "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)

if [ "$HOOK_COUNT" -gt 0 ]; then
  echo "  ✓ $HOOK_COUNT hooks defined"
else
  echo "  ::error::No hooks defined in hooks/hooks.json"
  echo "  Fix: Add at least one hook (user-prompt-submit-hook, etc.)"
  ((ERRORS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 13: Skills Structure
# ─────────────────────────────────────────────────────────────

echo "Check 13: Skills Structure"
echo "────────────────────────────────────────────────────────"

SKILL_COUNT=0
FRONTMATTER_COUNT=0
MISSING_FIELDS=0

for skill in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  ((SKILL_COUNT++))

  skill_name=$(basename "$(dirname "$skill")")

  # Check first line is ---
  if head -n 1 "$skill" | grep -q '^---$'; then
    ((FRONTMATTER_COUNT++))

    # Check required fields
    if ! grep -q '^name:' "$skill"; then
      echo "  ::error::Missing 'name:' field in $skill_name"
      ((MISSING_FIELDS++))
    fi

    if ! grep -q '^description:' "$skill"; then
      echo "  ::error::Missing 'description:' field in $skill_name"
      ((MISSING_FIELDS++))
    fi
  else
    echo "  ::error::No YAML frontmatter in $skill_name"
    ((FRONTMATTER_COUNT--))
  fi
done

if [ $SKILL_COUNT -eq $FRONTMATTER_COUNT ] && [ $MISSING_FIELDS -eq 0 ]; then
  echo "  ✓ $SKILL_COUNT skills, all have valid YAML frontmatter"
else
  echo "  ::error::$((SKILL_COUNT - FRONTMATTER_COUNT)) skills missing frontmatter"
  echo "  ::error::$MISSING_FIELDS required fields missing"
  ((ERRORS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 14: Context Files
# ─────────────────────────────────────────────────────────────

echo "Check 14: Context Files"
echo "────────────────────────────────────────────────────────"

CONTEXT_ERRORS=0

# Check if context directory exists
if [ ! -d "$PLUGIN_ROOT/jaan-to/context" ]; then
  echo "  ::warning::No jaan-to/context/ directory (bootstrap creates it)"
else
  # All context markdown files must have headers
  for ctx in "$PLUGIN_ROOT"/jaan-to/context/*.md 2>/dev/null; do
    [ -f "$ctx" ] || continue

    if ! grep -q '^#' "$ctx" 2>/dev/null; then
      echo "  ::error::No markdown headers in $(basename "$ctx")"
      ((CONTEXT_ERRORS++))
    fi
  done

  if [ $CONTEXT_ERRORS -eq 0 ]; then
    CONTEXT_COUNT=$(find "$PLUGIN_ROOT/jaan-to/context" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✓ $CONTEXT_COUNT context files, all have markdown headers"
  else
    echo "  ::error::$CONTEXT_ERRORS context files missing headers"
    ((ERRORS++))
  fi
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 15: Output Structure (Delegate to validate-outputs.sh)
# ─────────────────────────────────────────────────────────────

echo "Check 15: Output Structure"
echo "────────────────────────────────────────────────────────"

if [ ! -d "$PLUGIN_ROOT/jaan-to/outputs" ]; then
  echo "  ::warning::No jaan-to/outputs/ directory (created on first skill run)"
else
  if bash "$PLUGIN_ROOT/scripts/validate-outputs.sh" "$PLUGIN_ROOT/jaan-to/outputs" > /dev/null 2>&1; then
    echo "  ✓ Output structure validates (see validate-outputs.sh)"
  else
    echo "  ::error::Output structure validation failed"
    echo "  Run: bash scripts/validate-outputs.sh jaan-to/outputs"
    ((ERRORS++))
  fi
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 16: Permission Safety
# ─────────────────────────────────────────────────────────────

echo "Check 16: Permission Safety"
echo "────────────────────────────────────────────────────────"

# Search for dangerous patterns in skills
DANGEROUS=$(grep -rn 'rm -rf\|curl.*| *sh\|eval \|exec(' "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$DANGEROUS" -gt 0 ]; then
  echo "  ::warning::Found $DANGEROUS dangerous bash patterns in skills"
  grep -rn 'rm -rf\|curl.*| *sh\|eval \|exec(' "$PLUGIN_ROOT/skills/" 2>/dev/null | head -3
fi

# Check for overly broad permissions in allowed-tools
BROAD=$(grep -rn 'Write(\*\*)\|Bash(\*:\*)' "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$BROAD" -gt 0 ]; then
  echo "  ::warning::Found $BROAD overly broad permissions (Write(**) or Bash(*:*))"
  grep -rn 'Write(\*\*)\|Bash(\*:\*)' "$PLUGIN_ROOT/skills/" 2>/dev/null | head -3
fi

# Check for secret access patterns
SECRETS=$(grep -rn '\.env\|credentials\|secrets/\|\.pem\|\.key' "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SECRETS" -gt 0 ]; then
  echo "  ::warning::Found $SECRETS potential secret file access patterns"
  grep -rn '\.env\|credentials\|secrets/\|\.pem\|\.key' "$PLUGIN_ROOT/skills/" 2>/dev/null | head -3
fi

if [ "$DANGEROUS" -eq 0 ] && [ "$BROAD" -eq 0 ] && [ "$SECRETS" -eq 0 ]; then
  echo "  ✓ No dangerous patterns, broad permissions, or secret access"
else
  echo "  ⚠ $((DANGEROUS + BROAD + SECRETS)) potential permission safety issues (advisory)"
fi
echo ""

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════"
echo "  Plugin Standards Check Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo "✗ FAIL: $ERRORS critical plugin standard errors found"
  echo ""
  echo "Fix errors before proceeding. These will cause plugin"
  echo "installation or runtime failures."
  exit 1
else
  echo "✓ PASS: All 6 plugin standards checks passed"
  echo ""
fi

exit 0
