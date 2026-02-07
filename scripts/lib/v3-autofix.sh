#!/bin/bash
# v3-autofix.sh - Automated v2.x → v3.0.0 Migration Script
# Usage: bash scripts/lib/v3-autofix.sh <skill-name>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -eq 0 ]; then
  echo -e "${RED}ERROR: Skill name required${NC}"
  echo "Usage: bash scripts/lib/v3-autofix.sh <skill-name>"
  echo "Example: bash scripts/lib/v3-autofix.sh pm-prd-write"
  exit 1
fi

SKILL_NAME=$1
SKILL_DIR="skills/${SKILL_NAME}"
SKILL_FILE="${SKILL_DIR}/SKILL.md"
TEMPLATE_FILE="${SKILL_DIR}/template.md"

# Validate skill exists
if [ ! -d "$SKILL_DIR" ]; then
  echo -e "${RED}ERROR: Skill directory not found: $SKILL_DIR${NC}"
  exit 1
fi

if [ ! -f "$SKILL_FILE" ]; then
  echo -e "${RED}ERROR: SKILL.md not found: $SKILL_FILE${NC}"
  exit 1
fi

echo "=========================================="
echo "  v3.0.0 Auto-Migration: ${SKILL_NAME}"
echo "=========================================="

# Backup original files
echo -e "\n${YELLOW}Creating backups...${NC}"
cp "$SKILL_FILE" "${SKILL_FILE}.v2.backup"
echo "  ✓ Backed up: ${SKILL_FILE}.v2.backup"

if [ -f "$TEMPLATE_FILE" ]; then
  cp "$TEMPLATE_FILE" "${TEMPLATE_FILE}.v2.backup"
  echo "  ✓ Backed up: ${TEMPLATE_FILE}.v2.backup"
fi

# Counter for changes
CHANGES=0

# Function to apply transformation
apply_transform() {
  local file=$1
  local pattern=$2
  local replacement=$3
  local description=$4

  if grep -q "$pattern" "$file" 2>/dev/null; then
    sed -i '' "s|${pattern}|${replacement}|g" "$file"
    echo -e "  ${GREEN}✓${NC} $description"
    CHANGES=$((CHANGES + 1))
  fi
}

# ===========================================
# SKILL.md Transformations
# ===========================================
echo -e "\n${YELLOW}Transforming SKILL.md...${NC}"

# Frontmatter permissions
apply_transform "$SKILL_FILE" "Write(jaan-to/outputs/\*\*)" "Write(\$JAAN_OUTPUTS_DIR/**)" "Frontmatter: outputs permission"
apply_transform "$SKILL_FILE" "Read(jaan-to/context/\*\*)" "Read(\$JAAN_CONTEXT_DIR/**)" "Frontmatter: context permission"
apply_transform "$SKILL_FILE" "Edit(jaan-to/templates/\*\*)" "Edit(\$JAAN_TEMPLATES_DIR/**)" "Frontmatter: templates permission"
apply_transform "$SKILL_FILE" "Write(jaan-to/learn/\*\*)" "Write(\$JAAN_LEARN_DIR/**)" "Frontmatter: learning permission"
apply_transform "$SKILL_FILE" "Read(jaan-to/learn/\*\*)" "Read(\$JAAN_LEARN_DIR/**)" "Frontmatter: learning read permission"
apply_transform "$SKILL_FILE" "Edit(jaan-to/\*\*)" "Edit(\$JAAN_TEMPLATES_DIR/**), Edit(\$JAAN_LEARN_DIR/**)" "Frontmatter: generic jaan-to permission"

# Context files section (inline references)
apply_transform "$SKILL_FILE" "\`jaan-to/context/" "\`\$JAAN_CONTEXT_DIR/" "Context files: context paths"
apply_transform "$SKILL_FILE" "\`jaan-to/learn/" "\`\$JAAN_LEARN_DIR/" "Context files: learning paths"
apply_transform "$SKILL_FILE" "\`jaan-to/templates/" "\`\$JAAN_TEMPLATES_DIR/" "Context files: template paths"
apply_transform "$SKILL_FILE" "\`skills/${SKILL_NAME}/template.md\`" "\`\$JAAN_TEMPLATES_DIR/${SKILL_NAME}.template.md\`" "Context files: skill template path"

# Pre-Execution / Step 0 learning references
apply_transform "$SKILL_FILE" "Read: \`jaan-to/learn/" "Read: \`\$JAAN_LEARN_DIR/" "Pre-Execution: learning path"
apply_transform "$SKILL_FILE" "read:\`jaan-to/learn/" "read:\`\$JAAN_LEARN_DIR/" "Pre-Execution: learning path (lowercase)"

# Template references (various formats)
apply_transform "$SKILL_FILE" "template from \`skills/" "template from \`\$JAAN_TEMPLATES_DIR/" "Template reference: skills/ path"
apply_transform "$SKILL_FILE" "template: \`skills/" "template: \`\$JAAN_TEMPLATES_DIR/" "Template reference: skills/ path"
apply_transform "$SKILL_FILE" "Use the template from: \`jaan-to/templates/" "Use the template from: \`\$JAAN_TEMPLATES_DIR/" "Template reference: jaan-to/templates path"

# Output paths (various formats)
apply_transform "$SKILL_FILE" "Write to \`jaan-to/outputs/" "Write to \`\$JAAN_OUTPUTS_DIR/" "Output path: write instruction"
apply_transform "$SKILL_FILE" "Create path: \`jaan-to/outputs/" "Create path: \`\$JAAN_OUTPUTS_DIR/" "Output path: create instruction"
apply_transform "$SKILL_FILE" "Output: \`jaan-to/outputs/" "Output: \`\$JAAN_OUTPUTS_DIR/" "Output path: output instruction"
apply_transform "$SKILL_FILE" "to \`jaan-to/outputs/" "to \`\$JAAN_OUTPUTS_DIR/" "Output path: generic 'to' reference"

# ===========================================
# template.md Transformations (if exists)
# ===========================================
if [ -f "$TEMPLATE_FILE" ]; then
  echo -e "\n${YELLOW}Transforming template.md...${NC}"

  # Learning path references
  apply_transform "$TEMPLATE_FILE" "jaan-to/learn/" "\$JAAN_LEARN_DIR/" "Learning path"

  # Output path references
  apply_transform "$TEMPLATE_FILE" "jaan-to/outputs/" "\$JAAN_OUTPUTS_DIR/" "Output path"

  # Context path references
  apply_transform "$TEMPLATE_FILE" "jaan-to/context/" "\$JAAN_CONTEXT_DIR/" "Context path"

  # Template path references
  apply_transform "$TEMPLATE_FILE" "jaan-to/templates/" "\$JAAN_TEMPLATES_DIR/" "Template path"

  # Check if template already has variables
  if ! grep -q "{{title}}" "$TEMPLATE_FILE"; then
    echo -e "  ${YELLOW}⚠${NC}  template.md doesn't use template variables yet"
    echo "      Add field variables manually: {{title}}, {{date}}, {{author}}"
  else
    echo -e "  ${GREEN}✓${NC} template.md already uses template variables"
  fi
fi

# ===========================================
# Validation
# ===========================================
echo -e "\n${YELLOW}Validating migration...${NC}"

REMAINING_V2=0

# Check SKILL.md for remaining v2.x patterns
if grep -q "jaan-to/" "$SKILL_FILE"; then
  echo -e "  ${YELLOW}⚠${NC}  Some hardcoded 'jaan-to/' paths remain in SKILL.md"
  echo "      Run: grep -n 'jaan-to/' $SKILL_FILE"
  REMAINING_V2=1
else
  echo -e "  ${GREEN}✓${NC} No hardcoded paths in SKILL.md"
fi

# Check template.md for remaining v2.x patterns
if [ -f "$TEMPLATE_FILE" ] && grep -q "jaan-to/" "$TEMPLATE_FILE"; then
  echo -e "  ${YELLOW}⚠${NC}  Some hardcoded 'jaan-to/' paths remain in template.md"
  echo "      Run: grep -n 'jaan-to/' $TEMPLATE_FILE"
  REMAINING_V2=1
elif [ -f "$TEMPLATE_FILE" ]; then
  echo -e "  ${GREEN}✓${NC} No hardcoded paths in template.md"
fi

# ===========================================
# Summary
# ===========================================
echo ""
echo "=========================================="
echo "  Migration Summary"
echo "=========================================="
echo "  Skill: ${SKILL_NAME}"
echo "  Changes applied: ${CHANGES}"

if [ $REMAINING_V2 -eq 0 ]; then
  echo -e "  Status: ${GREEN}✓ Migration complete${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review changes: git diff ${SKILL_FILE}"
  echo "  2. Test the skill in a new session"
  echo "  3. Validate: /jaan-to:skill-update ${SKILL_NAME}"
  echo "  4. Commit if working correctly"
else
  echo -e "  Status: ${YELLOW}⚠ Manual review needed${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Find remaining patterns: grep -n 'jaan-to/' ${SKILL_FILE}"
  echo "  2. Update manually (may be in code examples or comments)"
  echo "  3. Re-run this script to verify"
fi

echo ""
echo "Backups created:"
echo "  - ${SKILL_FILE}.v2.backup"
[ -f "$TEMPLATE_FILE" ] && echo "  - ${TEMPLATE_FILE}.v2.backup"

echo ""
echo "To restore backups:"
echo "  mv ${SKILL_FILE}.v2.backup ${SKILL_FILE}"
[ -f "$TEMPLATE_FILE" ] && echo "  mv ${TEMPLATE_FILE}.v2.backup ${TEMPLATE_FILE}"

echo "=========================================="
