#!/bin/bash
# Phase 1 E2E Test - Configuration System Foundation
set -euo pipefail

echo "=== Phase 1 E2E Test: Configuration System ==="

# Setup test directory
TEST_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$TEST_DIR"
export PROJECT_DIR="$TEST_DIR"
export CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Test directory: $TEST_DIR"

# Test 1: Config loader loads defaults
echo -e "\n[Test 1] Config loader loads plugin defaults"
source "$CLAUDE_PLUGIN_ROOT/scripts/lib/config-loader.sh"
load_config

paths_templates=$(get_config 'paths_templates' 'FAIL')
[ "$paths_templates" = "jaan-to/templates" ] && echo "✓ Plugin defaults loaded" || (echo "✗ FAIL: $paths_templates"; exit 1)

# Test 2: Bootstrap creates settings.yaml
echo -e "\n[Test 2] Bootstrap creates settings.yaml"
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
[ -f "$TEST_DIR/jaan-to/config/settings.yaml" ] && echo "✓ settings.yaml created" || (echo "✗ FAIL"; exit 1)

# Test 3: Bootstrap creates all directories
echo -e "\n[Test 3] Bootstrap creates all directories"
[ -d "$TEST_DIR/jaan-to/templates" ] && echo "✓ templates/ created" || (echo "✗ FAIL"; exit 1)
[ -d "$TEST_DIR/jaan-to/learn" ] && echo "✓ learn/ created" || (echo "✗ FAIL"; exit 1)
[ -d "$TEST_DIR/jaan-to/context" ] && echo "✓ context/ created" || (echo "✗ FAIL"; exit 1)
[ -d "$TEST_DIR/jaan-to/outputs" ] && echo "✓ outputs/ created" || (echo "✗ FAIL"; exit 1)

# Test 4: Bootstrap copies context files
echo -e "\n[Test 4] Bootstrap copies context files"
context_count=$(ls -1 "$TEST_DIR/jaan-to/context"/*.md 2>/dev/null | wc -l | xargs)
[ "$context_count" -ge 3 ] && echo "✓ Context files copied ($context_count files)" || (echo "✗ FAIL: only $context_count files"; exit 1)

# Test 5: Project config overrides plugin defaults
echo -e "\n[Test 5] Project config overrides plugin defaults"
cat > "$TEST_DIR/jaan-to/config/settings.yaml" <<EOF
version: "3.0"
paths_outputs: "custom/output"
EOF

unset CONFIG_CACHE_FILE
load_config
custom_output=$(get_config 'paths_outputs' 'FAIL')
[ "$custom_output" = "custom/output" ] && echo "✓ Project override works" || (echo "✗ FAIL: $custom_output"; exit 1)

# Test 6: Path resolution with environment variables
echo -e "\n[Test 6] Path resolution"
resolved=$(resolve_path "\${PLUGIN_ROOT}/test")
[[ "$resolved" == *"/test" ]] && echo "✓ Path resolution works" || (echo "✗ FAIL: $resolved"; exit 1)

# Test 7: Path validation (security)
echo -e "\n[Test 7] Path validation rejects dangerous paths"
validate_path "/absolute/path" && (echo "✗ FAIL: accepted absolute path"; exit 1) || echo "✓ Rejected absolute path"
validate_path "../traversal" && (echo "✗ FAIL: accepted traversal"; exit 1) || echo "✓ Rejected traversal"
validate_path "safe/relative" && echo "✓ Accepted safe path" || (echo "✗ FAIL"; exit 1)

# Test 8: Bootstrap is idempotent
echo -e "\n[Test 8] Bootstrap is idempotent (safe to run twice)"
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
bash "$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh" > /dev/null 2>&1
[ -f "$TEST_DIR/jaan-to/config/settings.yaml" ] && echo "✓ Idempotent (no errors)" || (echo "✗ FAIL"; exit 1)

# Cleanup
rm -rf "$TEST_DIR"

echo -e "\n=== Phase 1 E2E Test: ✓ PASSED ==="
