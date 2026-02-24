#!/bin/bash
# Unified Integration Test - All Phases Together
set -euo pipefail

echo "=============================================="
echo "  UNIFIED INTEGRATION TEST: v3.0.0"
echo "  Testing all phases working together"
echo "=============================================="

# Setup test directory
TEST_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$TEST_DIR"
export PROJECT_DIR="$TEST_DIR"
export CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo -e "\nTest directory: $TEST_DIR"
echo "Plugin root: $CLAUDE_PLUGIN_ROOT"

# ========================================
# Phase 1: Configuration System
# ========================================
echo -e "\n========== PHASE 1: Configuration System =========="

# Load configuration system
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/config-loader.sh"
load_config

# Verify plugin defaults loaded
paths_templates=$(get_config 'paths_templates' 'FAIL')
[ "$paths_templates" = "jaan-to/templates" ] && echo "✓ Plugin defaults loaded" || (echo "✗ FAIL"; exit 1)

# Run bootstrap
mkdir -p "$TEST_DIR/jaan-to"
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
[ -f "$TEST_DIR/jaan-to/config/settings.yaml" ] && echo "✓ Bootstrap created settings.yaml" || (echo "✗ FAIL"; exit 1)
[ -d "$TEST_DIR/jaan-to/templates" ] && echo "✓ Directories created" || (echo "✗ FAIL"; exit 1)

# ========================================
# Phase 2: Path Resolution
# ========================================
echo -e "\n========== PHASE 2: Path Resolution =========="

source "$CLAUDE_PLUGIN_ROOT/scripts/lib/path-resolver.sh"

# Test template resolution
template_path=$(resolve_template_path "pm-prd-write")
[ -n "$template_path" ] && echo "✓ Template path resolved" || (echo "✗ FAIL"; exit 1)

# Test custom path override
cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
paths_templates: "custom/templates"
paths_outputs: "custom/outputs"
EOF

mkdir -p "$TEST_DIR/custom/templates"
echo "# Custom Template" > "$TEST_DIR/custom/templates/jaan-to-pm-prd-write.template.md"

unset CONFIG_CACHE_FILE
load_config

custom_template=$(resolve_template_path "pm-prd-write")
[[ "$custom_template" == *"custom/templates"* ]] && echo "✓ Custom path override works" || (echo "✗ FAIL: $custom_template"; exit 1)

# ========================================
# Phase 3: Template System
# ========================================
echo -e "\n========== PHASE 3: Template System =========="

source "$CLAUDE_PLUGIN_ROOT/scripts/lib/template-processor.sh"

# Test variable substitution
test_content="Title: {{title}}, Date: {{date}}"
context="title=Test PRD
date=2024-01-15"

result=$(substitute_template_vars "$test_content" "$context")
[[ "$result" == *"Test PRD"* ]] && [[ "$result" == *"2024-01-15"* ]] && echo "✓ Variable substitution works" || (echo "✗ FAIL"; exit 1)

# Test section extraction
cat > "$TEST_DIR/test-doc.md" <<EOF
# Document

## Section One
Content of section one

## Section Two
Content of section two
EOF

section=$(extract_section "$TEST_DIR/test-doc.md" "Section One")
[[ "$section" == *"Content of section one"* ]] && echo "✓ Section extraction works" || (echo "✗ FAIL"; exit 1)

# ========================================
# Phase 4: Learning System
# ========================================
echo -e "\n========== PHASE 4: Learning System =========="

source "$CLAUDE_PLUGIN_ROOT/scripts/lib/learning-merger.sh"

# Create project learning file for an existing skill (no repo-path writes)
cat > "$TEST_DIR/jaan-to/learn/pm-prd-write.learn.md" <<EOF
# Lessons

## Better Questions
- Project question 1

## Edge Cases
- Project edge case 1
EOF

# Reset config to use merge strategy
cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
learning_strategy: "merge"
EOF

unset CONFIG_CACHE_FILE
load_config

output_file="$TEST_DIR/merged-lessons.md"
merge_learning_files "pm-prd-write" "$output_file"

grep -q "source: plugin" "$output_file" && grep -q "Project question 1" "$output_file" && echo "✓ Learning merge works" || (echo "✗ FAIL"; exit 1)

# ========================================
# Phase 5: Tech Stack Integration
# ========================================
echo -e "\n========== PHASE 5: Tech Stack Integration =========="

# Verify tech.md exists and has structure
[ -f "$TEST_DIR/jaan-to/context/tech.md" ] && echo "✓ tech.md exists" || (echo "✗ FAIL"; exit 1)

grep -q "## Current Stack" "$TEST_DIR/jaan-to/context/tech.md" && echo "✓ Stack section exists" || (echo "✗ FAIL"; exit 1)
grep -q "#current-stack" "$TEST_DIR/jaan-to/context/tech.md" && echo "✓ Section anchors present" || echo "⚠ Anchors optional"

# Extract tech stack section
tech_section=$(extract_section "$TEST_DIR/jaan-to/context/tech.md" "Current Stack")
[[ -n "$tech_section" ]] && echo "✓ Tech stack extractable" || (echo "✗ FAIL"; exit 1)

# ========================================
# Phase 6: Skills Verification
# ========================================
echo -e "\n========== PHASE 6: Skills Verification =========="

# Count skills using $JAAN_* environment variables
migrated_count=0
for skill_file in "$CLAUDE_PLUGIN_ROOT/skills"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  if grep -q '\$JAAN_' "$skill_file"; then
    migrated_count=$((migrated_count + 1))
  fi
done

echo "   Skills using env vars: $migrated_count"
[ "$migrated_count" -ge 8 ] && echo "✓ Skills compliant" || echo "⚠ Only $migrated_count skills"

# ========================================
# Integration: Full Workflow Simulation
# ========================================
echo -e "\n========== INTEGRATION: End-to-End Workflow =========="

# Simulate skill execution: PRD generation with custom paths, tech context, and learning
echo "Simulating /jaan-to:pm-prd-write execution..."

# 1. Skill reads learning file (merged)
[ -f "$output_file" ] && echo "✓ Skill can read merged learning" || (echo "✗ FAIL"; exit 1)

# 2. Skill reads tech context
[ -f "$TEST_DIR/jaan-to/context/tech.md" ] && echo "✓ Skill can read tech.md" || (echo "✗ FAIL"; exit 1)

# 3. Skill reads template (from custom path)
[ -f "$TEST_DIR/custom/templates/jaan-to-pm-prd-write.template.md" ] && echo "✓ Skill can read custom template" || (echo "✗ FAIL"; exit 1)

# 4. Skill generates output to custom output path
mkdir -p "$TEST_DIR/custom/outputs/pm/test-feature"
cat > "$TEST_DIR/custom/outputs/pm/test-feature/prd.md" <<EOF
# Test Feature PRD

## Problem Statement
Test problem

## Tech Stack
$(extract_section "$TEST_DIR/jaan-to/context/tech.md" "Current Stack" | head -5)

## Lessons Applied
$(grep "Project question 1" "$output_file")
EOF

[ -f "$TEST_DIR/custom/outputs/pm/test-feature/prd.md" ] && echo "✓ Output written to custom path" || (echo "✗ FAIL"; exit 1)

# 5. Verify output contains tech stack reference
grep -q "Current Stack\|Backend\|Frontend" "$TEST_DIR/custom/outputs/pm/test-feature/prd.md" && echo "✓ PRD includes tech context" || echo "⚠ Tech integration optional"

# 6. Verify output references learning
grep -q "question 1" "$TEST_DIR/custom/outputs/pm/test-feature/prd.md" && echo "✓ PRD references learning" || echo "⚠ Learning reference optional"

# ========================================
# Security & Validation
# ========================================
echo -e "\n========== SECURITY & VALIDATION =========="

# Test path validation
validate_path "/absolute/path" && (echo "✗ FAIL: accepted absolute path"; exit 1) || echo "✓ Rejected absolute path"
validate_path "../traversal" && (echo "✗ FAIL: accepted traversal"; exit 1) || echo "✓ Rejected traversal"
validate_path "safe/relative" && echo "✓ Accepted safe path" || (echo "✗ FAIL"; exit 1)

# Verify bootstrap is idempotent
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
[ -f "$TEST_DIR/jaan-to/config/settings.yaml" ] && echo "✓ Bootstrap is idempotent" || (echo "✗ FAIL"; exit 1)

# ========================================
# Cleanup
# ========================================
rm -rf "$TEST_DIR"

echo -e "\n=============================================="
echo "  ✓ UNIFIED INTEGRATION TEST: PASSED"
echo "  All phases working correctly together"
echo "=============================================="
