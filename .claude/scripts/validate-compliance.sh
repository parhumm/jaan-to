#!/bin/bash
# validate-compliance.sh — Advisory compliance checks for jaan-to plugin standards
#
# Checks 1-10 from the compliance checklist. These are advisory checks that guide
# quality improvements but don't block releases. Warnings are acceptable.
#
# Usage: bash .claude/scripts/validate-compliance.sh
# Exit 0 if pass (warnings OK), exit 1 if critical errors found

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

WARNINGS=0
ERRORS=0

echo "═══════════════════════════════════════════════════════════"
echo "  Compliance Validation (Checks 1-10)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# Check 1: Skill Alignment (Two-Phase + HARD STOP)
# ─────────────────────────────────────────────────────────────

echo "Check 1: Skill Alignment (two-phase workflow + HARD STOP)"
echo "────────────────────────────────────────────────────────"

PHASE_ERRORS=0
for skill in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  skill_name=$(basename "$(dirname "$skill")")

  if ! grep -q "# PHASE 1:" "$skill"; then
    echo "  ⚠ Missing 'PHASE 1:' in $skill_name"
    ((WARNINGS++))
  fi

  if ! grep -q "# HARD STOP" "$skill"; then
    echo "  ⚠ Missing 'HARD STOP' in $skill_name"
    ((WARNINGS++))
  fi

  if ! grep -q "# PHASE 2:" "$skill"; then
    echo "  ⚠ Missing 'PHASE 2:' in $skill_name"
    ((WARNINGS++))
  fi

  if ! grep -q "Pre-Execution Protocol" "$skill"; then
    echo "  ⚠ Missing 'Pre-Execution Protocol' in $skill_name"
    ((WARNINGS++))
  fi

  if ! grep -q "## Definition of Done" "$skill"; then
    echo "  ⚠ Missing 'Definition of Done' in $skill_name"
    ((WARNINGS++))
  fi
done

if [ $WARNINGS -eq 0 ]; then
  echo "  ✓ All skills follow two-phase workflow pattern"
else
  echo "  ⚠ $WARNINGS skill alignment warnings (advisory)"
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 2: Generic Applicability (No User-Specific References)
# ─────────────────────────────────────────────────────────────

echo "Check 2: Generic Applicability"
echo "────────────────────────────────────────────────────────"

PROJECT_REFS=$(grep -rn "Jaanify\|MyApp\|Acme\|Example Corp" "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/docs/" 2>/dev/null | grep -v "Example:" | wc -l | tr -d ' ')

if [ "$PROJECT_REFS" -eq 0 ]; then
  echo "  ✓ No user-specific project references found"
else
  echo "  ⚠ Found $PROJECT_REFS potential user-specific references (check manually)"
  grep -rn "Jaanify\|MyApp\|Acme\|Example Corp" "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/docs/" 2>/dev/null | grep -v "Example:" | head -5
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 3: Multi-Stack Coverage (Node.js, PHP, Go)
# ─────────────────────────────────────────────────────────────

echo "Check 3: Multi-Stack Coverage"
echo "────────────────────────────────────────────────────────"

INCOMPLETE_COVERAGE=0
for skill in "$PLUGIN_ROOT"/skills/{backend,frontend,qa,devops}*/SKILL.md; do
  [ -f "$skill" ] || continue
  skill_name=$(basename "$(dirname "$skill")")

  HAS_NODE=$(grep -c "Node\.js\|TypeScript\|npm\|pnpm" "$skill" || echo 0)
  HAS_PHP=$(grep -c "PHP\|Laravel\|Symfony\|Composer" "$skill" || echo 0)
  HAS_GO=$(grep -c "\bGo\b\|Golang" "$skill" || echo 0)

  if [ "$HAS_NODE" -eq 0 ] || [ "$HAS_PHP" -eq 0 ] || [ "$HAS_GO" -eq 0 ]; then
    echo "  ⚠ Incomplete stack coverage: $skill_name (Node:$HAS_NODE PHP:$HAS_PHP Go:$HAS_GO)"
    ((INCOMPLETE_COVERAGE++))
  fi
done

if [ $INCOMPLETE_COVERAGE -eq 0 ]; then
  echo "  ✓ All code-gen skills mention all 3 stacks"
else
  echo "  ⚠ $INCOMPLETE_COVERAGE skills have incomplete stack coverage (advisory)"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 4: No User-Specific References (Paths, Emails)
# ─────────────────────────────────────────────────────────────

echo "Check 4: No User-Specific References (paths/emails)"
echo "────────────────────────────────────────────────────────"

USER_PATHS=$(grep -rn "/Users/[a-z]\|/home/[a-z]\|C:\\\\Users\\\\" "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/docs/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$USER_PATHS" -eq 0 ]; then
  echo "  ✓ No hardcoded user paths found"
else
  echo "  ⚠ Found $USER_PATHS hardcoded paths (sanitize examples)"
  grep -rn "/Users/[a-z]\|/home/[a-z]\|C:\\\\Users\\\\" "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/docs/" 2>/dev/null | head -3
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 5: Skill Alignment Section (Clear Purpose)
# ─────────────────────────────────────────────────────────────

echo "Check 5: Skill Alignment Section"
echo "────────────────────────────────────────────────────────"

MISSING_ALIGNMENT=0
for skill in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  skill_name=$(basename "$(dirname "$skill")")

  if ! grep -q "## Skill Alignment\|# Skill Alignment" "$skill"; then
    echo "  ⚠ Missing 'Skill Alignment' section in $skill_name"
    ((MISSING_ALIGNMENT++))
  fi
done

if [ $MISSING_ALIGNMENT -eq 0 ]; then
  echo "  ✓ All skills have Skill Alignment section"
else
  echo "  ⚠ $MISSING_ALIGNMENT skills missing alignment section (advisory)"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 6: Generic Language (Language Protocol Compliance)
# ─────────────────────────────────────────────────────────────

echo "Check 6: Generic Language (language protocol)"
echo "────────────────────────────────────────────────────────"

# Check if language protocol doc exists
if [ -f "$PLUGIN_ROOT/docs/extending/language-protocol.md" ]; then
  echo "  ✓ Language protocol documentation exists"
else
  echo "  ⚠ Missing docs/extending/language-protocol.md"
  ((WARNINGS++))
fi

# Check for hardcoded language-specific greetings/phrases
LANG_SPECIFIC=$(grep -rn "Bonjour\|Hola\|Namaste\|こんにちは" "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$LANG_SPECIFIC" -eq 0 ]; then
  echo "  ✓ No hardcoded language-specific greetings"
else
  echo "  ⚠ Found $LANG_SPECIFIC language-specific phrases (should use i18n)"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 7: Generic Error Categories (Actionable Messages)
# ─────────────────────────────────────────────────────────────

echo "Check 7: Generic Error Categories"
echo "────────────────────────────────────────────────────────"

# Check for vague error messages
VAGUE_ERRORS=$(grep -rn "Error occurred\|Something went wrong\|Failed\." "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$VAGUE_ERRORS" -eq 0 ]; then
  echo "  ✓ No vague error messages detected"
else
  echo "  ⚠ Found $VAGUE_ERRORS potentially vague error messages"
  echo "    Prefer: 'Missing required field: name' over 'Validation failed'"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 8: tech.md-First Architecture (Stack Detection)
# ─────────────────────────────────────────────────────────────

echo "Check 8: tech.md-First Architecture"
echo "────────────────────────────────────────────────────────"

TECH_MD_REFS=0
for skill in "$PLUGIN_ROOT"/skills/{backend,frontend,devops}*/SKILL.md; do
  [ -f "$skill" ] || continue

  if grep -q "tech\.md\|context/tech\|Current Stack" "$skill"; then
    ((TECH_MD_REFS++))
  fi
done

if [ $TECH_MD_REFS -gt 0 ]; then
  echo "  ✓ Code-gen skills reference tech.md for stack detection"
else
  echo "  ⚠ No skills reference tech.md (should detect stack before generation)"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 9: Token Strategy Compliance (Delegate to validate-skills.sh)
# ─────────────────────────────────────────────────────────────

echo "Check 9: Token Strategy Compliance"
echo "────────────────────────────────────────────────────────"

if bash "$PLUGIN_ROOT/scripts/validate-skills.sh" > /dev/null 2>&1; then
  echo "  ✓ Skill description budget OK (see validate-skills.sh for details)"
else
  echo "  ✗ Skill description budget exceeded"
  echo "    Run: bash scripts/validate-skills.sh"
  ((ERRORS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 10: Security Review (Basic — see scripts/validate-security.sh for full check)
# ─────────────────────────────────────────────────────────────

echo "Check 10: Security Review"
echo "────────────────────────────────────────────────────────"

DANGEROUS_PATTERNS=$(grep -rn "rm -rf \|curl.*| sh\|eval \|exec(" "$PLUGIN_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$DANGEROUS_PATTERNS" -eq 0 ]; then
  echo "  ✓ No dangerous bash patterns found in skills"
else
  echo "  ⚠ Found $DANGEROUS_PATTERNS potentially dangerous patterns"
  grep -rn "rm -rf \|curl.*| sh\|eval \|exec(" "$PLUGIN_ROOT/skills/" 2>/dev/null | head -3
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Check 11: Agent Skills Standard Compliance
# ─────────────────────────────────────────────────────────────

echo "Check 11: Agent Skills Standard Compliance"
echo "────────────────────────────────────────────────────────"

INVALID_NAMES=0
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if [[ ! "$skill_name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$skill_name" =~ -- ]] || [ ${#skill_name} -gt 64 ]; then
    echo "  ⚠ Invalid Agent Skills name: $skill_name"
    ((INVALID_NAMES++))
  fi
done
if [ $INVALID_NAMES -eq 0 ]; then
  echo "  ✓ All skill names comply with Agent Skills naming spec"
else
  echo "  ⚠ $INVALID_NAMES names violate naming spec (advisory)"
  ((WARNINGS++))
fi

MARKETPLACE="$PLUGIN_ROOT/.claude-plugin/marketplace.json"
if [ -f "$MARKETPLACE" ]; then
  MANIFEST_COUNT=$(jq '.plugins[0].skills | length' "$MARKETPLACE" 2>/dev/null || echo 0)
  ACTUAL_COUNT=$(find "$PLUGIN_ROOT/skills" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$MANIFEST_COUNT" -eq "$ACTUAL_COUNT" ]; then
    echo "  ✓ marketplace.json skills[] synced ($ACTUAL_COUNT skills)"
  else
    echo "  ⚠ marketplace.json skills[] ($MANIFEST_COUNT) != actual ($ACTUAL_COUNT)"
    ((WARNINGS++))
  fi
else
  echo "  ⚠ No marketplace.json found"
  ((WARNINGS++))
fi

MISSING_FIELDS=0
for skill in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  grep -q '^license:' "$skill" || MISSING_FIELDS=$((MISSING_FIELDS + 1))
  grep -q '^compatibility:' "$skill" || MISSING_FIELDS=$((MISSING_FIELDS + 1))
done
if [ $MISSING_FIELDS -eq 0 ]; then
  echo "  ✓ All skills have license and compatibility fields"
else
  echo "  ⚠ $MISSING_FIELDS missing Agent Skills fields (advisory)"
  ((WARNINGS++))
fi
echo ""

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════"
echo "  Compliance Check Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Warnings (advisory): $WARNINGS"
echo "  Errors (blocking):   $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo "✗ FAIL: $ERRORS critical compliance errors found"
  echo ""
  echo "Fix errors before proceeding."
  exit 1
fi

if [ $WARNINGS -gt 0 ]; then
  echo "⚠ PASS with warnings: $WARNINGS advisory issues"
  echo ""
  echo "Consider addressing warnings to improve quality."
else
  echo "✓ PASS: All 11 compliance checks passed"
  echo ""
fi

exit 0
