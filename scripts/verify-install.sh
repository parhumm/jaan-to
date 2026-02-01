#!/bin/bash
# Verify jaan.to plugin installation
# Run after installing the plugin and starting a Claude session (triggers bootstrap)
# Usage: ./scripts/verify-install.sh /path/to/test-project
set -euo pipefail

PROJECT_DIR="${1:-.}"
CHECKS_PASSED=0
CHECKS_FAILED=0

check() {
  if [ "$1" = "true" ]; then
    echo "  ✓ $2"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
  else
    echo "  ✗ $2"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
  fi
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
for skill in jaan-to-pm-prd-write jaan-to-data-gtm-datalayer to-jaan-docs-create to-jaan-skill-create jaan-to-pm-research-about to-jaan-roadmap-add; do
  check "$([ -f "$PROJECT_DIR/jaan-to/templates/${skill}.template.md" ] && echo true || echo false)" "templates/${skill}.template.md"
done

# 4. Learning seeds
echo ""
echo "4. Learning seeds:"
for skill in jaan-to-pm-prd-write jaan-to-data-gtm-datalayer to-jaan-docs-create to-jaan-docs-update to-jaan-skill-create to-jaan-skill-update jaan-to-pm-research-about to-jaan-learn-add to-jaan-roadmap-add; do
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

# Summary
echo ""
echo "=== Results: $CHECKS_PASSED passed, $CHECKS_FAILED failed ==="
[ "$CHECKS_FAILED" -eq 0 ] && echo "All checks passed!" || echo "Some checks failed."
exit "$CHECKS_FAILED"
