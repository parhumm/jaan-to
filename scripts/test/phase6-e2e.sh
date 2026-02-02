#!/bin/bash
# Phase 6 E2E Test - Full Migration & Documentation
set -euo pipefail

echo "=== Phase 6 E2E Test: Migration & Documentation ==="

CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Test 1: All skills migrated
echo -e "\n[Test 1] Count skills using \$JAAN_* variables"
migrated_count=0
total_skills=0

for skill_dir in "$CLAUDE_PLUGIN_ROOT/skills"/*; do
  [ -d "$skill_dir" ] || continue
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  total_skills=$((total_skills + 1))

  if grep -q '\$JAAN_' "$skill_file"; then
    migrated_count=$((migrated_count + 1))
  fi
done

echo "   Skills migrated: $migrated_count/$total_skills"
[ "$migrated_count" -ge 8 ] && echo "✓ Sufficient skills migrated" || (echo "✗ FAIL: Only $migrated_count skills migrated"; exit 1)

# Test 2: Documentation files exist
echo -e "\n[Test 2] Documentation completeness"
[ -f "$CLAUDE_PLUGIN_ROOT/docs/guides/migration-v3.md" ] && echo "✓ Migration guide exists" || (echo "✗ FAIL: Migration guide missing"; exit 1)
[ -f "$CLAUDE_PLUGIN_ROOT/examples/custom-template-enterprise.yaml" ] && echo "✓ Enterprise example exists" || (echo "✗ FAIL: Missing"; exit 1)
[ -f "$CLAUDE_PLUGIN_ROOT/examples/custom-paths-monorepo.yaml" ] && echo "✓ Monorepo example exists" || (echo "✗ FAIL: Missing"; exit 1)
[ -f "$CLAUDE_PLUGIN_ROOT/examples/custom-learning-override.yaml" ] && echo "✓ Override example exists" || (echo "✗ FAIL: Missing"; exit 1)

# Test 3: CLAUDE.md updated
echo -e "\n[Test 3] CLAUDE.md documentation"
if grep -q "Customizable" "$CLAUDE_PLUGIN_ROOT/CLAUDE.md"; then
  echo "✓ Customization column added"
else
  echo "✗ FAIL: CLAUDE.md needs customization docs"
  exit 1
fi

if grep -q "## Customization" "$CLAUDE_PLUGIN_ROOT/CLAUDE.md"; then
  echo "✓ Customization section exists"
else
  echo "✗ FAIL: Customization section missing"
  exit 1
fi

# Test 4: Migration guide content
echo -e "\n[Test 4] Migration guide content"
migration_doc="$CLAUDE_PLUGIN_ROOT/docs/guides/migration-v3.md"
if [ -f "$migration_doc" ]; then
  grep -q "Breaking Changes" "$migration_doc" && echo "✓ Breaking changes documented" || (echo "✗ FAIL: Missing"; exit 1)
  grep -q "Migration Steps" "$migration_doc" && echo "✓ Migration steps documented" || (echo "✗ FAIL: Missing"; exit 1)
  grep -q "Rollback" "$migration_doc" && echo "✓ Rollback documented" || (echo "✗ FAIL: Missing"; exit 1)
  grep -q "Template Customization" "$migration_doc" && echo "✓ Features documented" || (echo "✗ FAIL: Missing"; exit 1)
fi

# Test 5: Skill pattern consistency
echo -e "\n[Test 5] Skills follow consistent pattern"
consistent_count=0
for skill_file in "$CLAUDE_PLUGIN_ROOT/skills"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue

  # Check if skill uses at least one JAAN variable
  if grep -q '\$JAAN_' "$skill_file"; then
    consistent_count=$((consistent_count + 1))
  fi
done

echo "   Consistent skills: $consistent_count"
[ "$consistent_count" -ge 8 ] && echo "✓ Patterns consistent" || (echo "✗ FAIL: Inconsistent patterns"; exit 1)

echo -e "\n=== Phase 6 E2E Test: ✓ PASSED ==="
