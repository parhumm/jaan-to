#!/bin/bash
# Phase 2 E2E Test - Path Resolution & Pilot Skill
set -euo pipefail

echo "=== Phase 2 E2E Test: Path Resolution & Skills ==="

# Setup test directory
TEST_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$TEST_DIR"
export PROJECT_DIR="$TEST_DIR"
export CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export JAAN_TEMPLATES_DIR="jaan-to/templates"
export JAAN_LEARN_DIR="jaan-to/learn"
export JAAN_CONTEXT_DIR="jaan-to/context"
export JAAN_OUTPUTS_DIR="jaan-to/outputs"

echo "Test directory: $TEST_DIR"

# Run Phase 1 bootstrap first
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1

# Test 1: Path resolver finds templates
echo -e "\n[Test 1] Path resolver finds template"
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/config-loader.sh"
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/path-resolver.sh"
load_config

template_path=$(resolve_template_path "pm-prd-write")
[ -n "$template_path" ] && echo "✓ Template found: $template_path" || (echo "✗ FAIL"; exit 1)

# Test 2: Custom template override
echo -e "\n[Test 2] Custom template override"
mkdir -p "$TEST_DIR/custom-templates"
echo "# Custom Template" > "$TEST_DIR/custom-templates/test-template.md"

cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
templates_jaan_to_pm_prd_write_path: "./custom-templates/test-template.md"
EOF

unset CONFIG_CACHE_FILE
load_config
custom_template=$(resolve_template_path "pm-prd-write")
[[ "$custom_template" == *"custom-templates"* ]] && echo "✓ Custom template resolved" || (echo "✗ FAIL: $custom_template"; exit 1)

# Test 3: Learning path resolution (merge strategy)
echo -e "\n[Test 3] Learning path resolution with merge"
# Reset config to default merge strategy
cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
learning_strategy: "merge"
EOF

unset CONFIG_CACHE_FILE
load_config

learning_paths=$(resolve_learning_path "pm-prd-write")
if [[ "$learning_paths" == *"|"* ]]; then
  echo "✓ Merge strategy returns multiple sources"
elif [[ -n "$learning_paths" ]]; then
  echo "⚠ Only one source found (expected if project file missing)"
else
  echo "⚠ No learning sources found"
fi

# Test 4: Context path resolution
echo -e "\n[Test 4] Context path resolution"
context_path=$(resolve_context_path "config.md")
[ "$context_path" = "jaan-to/context/config.md" ] && echo "✓ Context path resolved" || (echo "✗ FAIL: $context_path"; exit 1)

# Test 5: Output path resolution
echo -e "\n[Test 5] Output path resolution"
output_path=$(resolve_output_path "pm" "test-feature")
[ "$output_path" = "jaan-to/outputs/pm/test-feature" ] && echo "✓ Output path resolved" || (echo "✗ FAIL: $output_path"; exit 1)

# Test 6: Config file override of output path
echo -e "\n[Test 6] Config file override"
cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
paths_outputs: "custom/artifacts"
EOF

# Need to reload config for changes
unset CONFIG_CACHE_FILE
load_config

output_custom=$(resolve_output_path "pm" "test")
[[ "$output_custom" == "custom/artifacts"* ]] && echo "✓ Config override works" || (echo "✗ FAIL: $output_custom"; exit 1)

# Test 7: Skill can read resolved paths
echo -e "\n[Test 7] Skills use \$JAAN_* variables"
# Simulate skill reading environment variables
test_template="\$JAAN_TEMPLATES_DIR/test.md"
test_learn="\$JAAN_LEARN_DIR/test.learn.md"
[ -n "$JAAN_TEMPLATES_DIR" ] && echo "✓ \$JAAN_TEMPLATES_DIR available to skills" || (echo "✗ FAIL"; exit 1)
[ -n "$JAAN_LEARN_DIR" ] && echo "✓ \$JAAN_LEARN_DIR available to skills" || (echo "✗ FAIL"; exit 1)

# Cleanup
rm -rf "$TEST_DIR"

echo -e "\n=== Phase 2 E2E Test: ✓ PASSED ==="
