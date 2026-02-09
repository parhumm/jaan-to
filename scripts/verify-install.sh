#!/bin/bash
# Verify jaan.to plugin installation
# Run after installing the plugin and starting a Claude session (triggers bootstrap)
# Usage: ./scripts/verify-install.sh [/path/to/test-project] [--plugin-dir /path/to/plugin]
set -euo pipefail

PROJECT_DIR="${1:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-}"
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# Parse optional --plugin-dir argument
if [ "${2:-}" = "--plugin-dir" ] && [ -n "${3:-}" ]; then
  PLUGIN_DIR="$3"
fi

check() {
  if [ "$1" = "true" ]; then
    echo "  ✓ $2"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
  else
    echo "  ✗ $2"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
  fi
}

warn() {
  echo "  ⚠ $1"
  WARNINGS=$((WARNINGS + 1))
}

echo "=== jaan.to Plugin Install Verification ==="
echo "Project: $PROJECT_DIR"
echo ""

# 1. Bootstrap artifacts
echo "1. Bootstrap artifacts (jaan-to/):"
check "$([ -d "$PROJECT_DIR/jaan-to" ] && echo true || echo false)" "jaan-to/ directory exists"
check "$([ -d "$PROJECT_DIR/jaan-to/context" ] && echo true || echo false)" "jaan-to/context/ exists"
check "$([ -d "$PROJECT_DIR/jaan-to/templates" ] && echo true || echo false)" "jaan-to/templates/ exists"
check "$([ -d "$PROJECT_DIR/jaan-to/learn" ] && echo true || echo false)" "jaan-to/learn/ exists"
check "$([ -d "$PROJECT_DIR/jaan-to/outputs" ] && echo true || echo false)" "jaan-to/outputs/ exists"
check "$([ -d "$PROJECT_DIR/jaan-to/docs" ] && echo true || echo false)" "jaan-to/docs/ exists"
check "$([ -d "$PROJECT_DIR/jaan-to/outputs/research" ] && echo true || echo false)" "jaan-to/outputs/research/ exists"

# 2. Context files
echo ""
echo "2. Context files:"
for f in config.md boundaries.md tech.md team.md integrations.md; do
  check "$([ -f "$PROJECT_DIR/jaan-to/context/$f" ] && echo true || echo false)" "context/$f"
done

# 3. Templates
echo ""
echo "3. Templates:"
for skill in pm-prd-write data-gtm-datalayer docs-create skill-create pm-research-about roadmap-add; do
  check "$([ -f "$PROJECT_DIR/jaan-to/templates/${skill}.template.md" ] && echo true || echo false)" "templates/${skill}.template.md"
done

# 4. Learning seeds
echo ""
echo "4. Learning seeds:"
for skill in pm-prd-write data-gtm-datalayer docs-create docs-update skill-create skill-update pm-research-about learn-add roadmap-add; do
  check "$([ -f "$PROJECT_DIR/jaan-to/learn/${skill}.learn.md" ] && echo true || echo false)" "learn/${skill}.learn.md"
done

# 5. Docs for skills
echo ""
echo "5. Reference docs:"
check "$([ -f "$PROJECT_DIR/jaan-to/docs/STYLE.md" ] && echo true || echo false)" "docs/STYLE.md"
check "$([ -f "$PROJECT_DIR/jaan-to/docs/create-skill.md" ] && echo true || echo false)" "docs/create-skill.md"

# 6. Research scaffold
echo ""
echo "6. Research scaffold:"
check "$([ -f "$PROJECT_DIR/jaan-to/outputs/research/README.md" ] && echo true || echo false)" "outputs/research/README.md"

# 7. .gitignore
echo ""
echo "7. .gitignore:"
check "$(grep -q 'jaan-to/' "$PROJECT_DIR/.gitignore" 2>/dev/null && echo true || echo false)" "jaan-to in .gitignore"

# 8. Plugin manifest validation (if plugin dir available)
if [ -n "$PLUGIN_DIR" ] && [ -d "$PLUGIN_DIR" ]; then
  echo ""
  echo "8. Plugin manifest:"
  check "$([ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ] && echo true || echo false)" "plugin.json exists"
  check "$([ -f "$PLUGIN_DIR/.claude-plugin/marketplace.json" ] && echo true || echo false)" "marketplace.json exists"

  # Validate JSON syntax with jq if available
  if command -v jq >/dev/null 2>&1; then
    if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
      check "$(jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null && echo true || echo false)" "plugin.json is valid JSON"
    fi
    if [ -f "$PLUGIN_DIR/.claude-plugin/marketplace.json" ]; then
      check "$(jq empty "$PLUGIN_DIR/.claude-plugin/marketplace.json" 2>/dev/null && echo true || echo false)" "marketplace.json is valid JSON"
    fi
  else
    warn "jq not installed, skipping JSON validation"
  fi
fi

# 9. Hooks validation (if plugin dir available)
if [ -n "$PLUGIN_DIR" ] && [ -d "$PLUGIN_DIR" ]; then
  echo ""
  echo "9. Hooks:"
  check "$([ -f "$PLUGIN_DIR/hooks/hooks.json" ] && echo true || echo false)" "hooks/hooks.json exists"

  if command -v jq >/dev/null 2>&1 && [ -f "$PLUGIN_DIR/hooks/hooks.json" ]; then
    check "$(jq empty "$PLUGIN_DIR/hooks/hooks.json" 2>/dev/null && echo true || echo false)" "hooks.json is valid JSON"

    # Check for required hook types
    if jq -e '.hooks' "$PLUGIN_DIR/hooks/hooks.json" >/dev/null 2>&1; then
      check "$(jq -e '.hooks | length > 0' "$PLUGIN_DIR/hooks/hooks.json" 2>/dev/null && echo true || echo false)" "At least one hook defined"
    fi
  fi
fi

# 10. Skills validation (if plugin dir available)
if [ -n "$PLUGIN_DIR" ] && [ -d "$PLUGIN_DIR/skills" ]; then
  echo ""
  echo "10. Skills (plugin directory):"

  skill_count=0
  skill_with_frontmatter=0

  while IFS= read -r -d '' skill_file; do
    ((skill_count++))

    # Check if SKILL.md has YAML frontmatter
    if head -n 1 "$skill_file" | grep -q '^---$'; then
      ((skill_with_frontmatter++))
    fi
  done < <(find "$PLUGIN_DIR/skills" -name "SKILL.md" -type f -print0 2>/dev/null)

  check "$([ $skill_count -gt 0 ] && echo true || echo false)" "Skills found: $skill_count"

  if [ $skill_count -gt 0 ]; then
    check "$([ $skill_with_frontmatter -eq $skill_count ] && echo true || echo false)" "All skills have YAML frontmatter: $skill_with_frontmatter/$skill_count"
  fi
fi

# 11. Configuration loading test
echo ""
echo "11. Configuration files (markdown syntax):"

config_files=(
  "jaan-to/context/config.md"
  "jaan-to/context/tech.md"
  "jaan-to/context/team.md"
  "jaan-to/context/integrations.md"
)

for config_file in "${config_files[@]}"; do
  if [ -f "$PROJECT_DIR/$config_file" ]; then
    # Basic check: file is readable and has markdown headers
    has_headers=$(grep -c '^#' "$PROJECT_DIR/$config_file" 2>/dev/null || echo 0)
    check "$([ $has_headers -gt 0 ] && echo true || echo false)" "$config_file has headers ($has_headers found)"
  fi
done

# 12. Installation report
echo ""
echo "12. Installation Summary:"

# Count files created
total_files=$(find "$PROJECT_DIR/jaan-to" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  → Total files in jaan-to/: $total_files"

# Count learning files
learn_files=$(find "$PROJECT_DIR/jaan-to/learn" -name "*.learn.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  → Learning files: $learn_files"

# Count templates
template_files=$(find "$PROJECT_DIR/jaan-to/templates" -name "*.template.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  → Template files: $template_files"

# Check disk usage
if command -v du >/dev/null 2>&1; then
  disk_usage=$(du -sh "$PROJECT_DIR/jaan-to" 2>/dev/null | cut -f1)
  echo "  → Disk usage: $disk_usage"
fi

# Summary
echo ""
echo "=== Results ==="
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"
echo "Warnings: $WARNINGS"
echo ""

if [ "$CHECKS_FAILED" -eq 0 ]; then
  echo "✅ All checks passed! Plugin is installed correctly."
  echo ""
  echo "Next steps:"
  echo "  1. Try a skill: /jaan-to:pm-prd-write 'user authentication'"
  echo "  2. Customize context: vim jaan-to/context/tech.md"
  echo "  3. Run repo analysis: /jaan-to:detect-pack"
else
  echo "❌ Some checks failed. See details above."
  echo ""
  echo "Common issues:"
  echo "  - Bootstrap hasn't run yet: Start a Claude session first"
  echo "  - Wrong directory: Specify --plugin-dir if testing locally"
  echo "  - Missing files: Check plugin installation"
fi

exit "$CHECKS_FAILED"
