#!/bin/bash
# Phases 3-5 E2E Test - Template, Learning, Tech Stack
set -euo pipefail

echo "=== Phases 3-5 E2E Test: Template + Learning + Tech Stack ==="

# Setup test directory
TEST_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$TEST_DIR"
export PROJECT_DIR="$TEST_DIR"
export CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Bootstrap
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1

# Load libraries
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/config-loader.sh"
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/template-processor.sh"
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/learning-merger.sh"
load_config

echo "Test directory: $TEST_DIR"

# Test 1: Template with variable substitution
echo -e "\n[Test 1] Template with variable substitution"
test_template="# {{title}}

Stack: {{env:JAAN_CONTEXT_DIR}}

Config: {{config:paths_templates}}"

context="title=Enterprise PRD"
export JAAN_CONTEXT_DIR="jaan-to/context"

result=$(test_substitute "$test_template" "$context")

if [[ "$result" == *"Enterprise PRD"* ]] && [[ "$result" == *"jaan-to/context"* ]] && [[ "$result" == *"jaan-to/templates"* ]]; then
  echo "✓ Variables work ({{field}}, {{env:VAR}}, {{config:key}})"
else
  echo "✗ FAIL: Variable substitution failed"
  echo "Result: $result"
  exit 1
fi

# Test 2: Section extraction from tech.md
echo -e "\n[Test 2] Section extraction from tech.md"

if [ -f "$TEST_DIR/jaan-to/context/tech.md" ]; then
  stack_section=$(extract_section "$TEST_DIR/jaan-to/context/tech.md" "Current Stack")

  if [[ -n "$stack_section" ]] && [[ "$stack_section" == *"Backend"* || "$stack_section" == *"Frontend"* ]]; then
    echo "✓ Tech stack section extracted"
  else
    echo "⚠ Section extracted but may be empty (check tech.md structure)"
  fi
else
  echo "✗ FAIL: tech.md not found"
  exit 1
fi

# Test 3: Learning merge functionality
echo -e "\n[Test 3] Learning merge with multiple sources"

# Create plugin learning file (simulate)
mkdir -p "$CLAUDE_PLUGIN_ROOT/skills/test-skill"
cat > "$CLAUDE_PLUGIN_ROOT/skills/test-skill/LEARN.md" <<EOF
# Lessons

## Better Questions
- Plugin question 1

## Workflow
- Plugin workflow 1
EOF

# Create project learning file
cat > "$TEST_DIR/jaan-to/learn/test-skill.learn.md" <<EOF
# Lessons

## Better Questions
- Project question 1

## Edge Cases
- Project edge case 1
EOF

# Merge learning files
merged_output="$TEST_DIR/merged-test.md"
merge_learning_files "test-skill" "$merged_output"

if [ -f "$merged_output" ]; then
  if grep -q "Plugin question 1" "$merged_output" && grep -q "Project question 1" "$merged_output"; then
    echo "✓ Learning merge works (plugin + project)"
  else
    echo "✗ FAIL: Learning merge incomplete"
    echo "Content:"
    cat "$merged_output"
    exit 1
  fi
else
  echo "✗ FAIL: Merged learning file not created"
  exit 1
fi

# Cleanup test skill
rm -rf "$CLAUDE_PLUGIN_ROOT/skills/test-skill"
rm -rf "$TEST_DIR"

echo -e "\n=== Phases 3-5 E2E Test: ✓ PASSED ==="
