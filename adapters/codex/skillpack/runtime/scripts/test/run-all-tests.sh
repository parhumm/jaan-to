#!/bin/bash
# Run legacy E2E and integration tests.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$(mktemp /tmp/jaan-to-test-output-XXXXXX)"
PASSED=0
FAILED=0
WARNINGS=0
TOTAL=5

cleanup() {
  rm -f "$LOG_FILE"
}
trap cleanup EXIT

run_test() {
  local test_name="$1"
  local test_script="$2"

  echo ""
  echo "=================================================="
  echo "  Running: $test_name"
  echo "=================================================="

  if bash "$test_script" 2>&1 | tee "$LOG_FILE"; then
    echo "✓ $test_name PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "✗ $test_name FAILED"
    FAILED=$((FAILED + 1))
    return 1
  fi

  warning_count="$(grep -c "⚠" "$LOG_FILE" 2>/dev/null || true)"
  warning_count="${warning_count:-0}"
  WARNINGS=$((WARNINGS + warning_count))
}

echo "=============================================="
echo "  jaan.to Plugin v3.0.0 - Legacy Test Suite"
echo "=============================================="

run_test "Phase 1 E2E" "$SCRIPT_DIR/phase1-e2e.sh"
run_test "Phase 2 E2E" "$SCRIPT_DIR/phase2-e2e.sh"
run_test "Phases 3-5 E2E" "$SCRIPT_DIR/phase3-5-e2e.sh"
run_test "Unified Integration" "$SCRIPT_DIR/integration-all-phases.sh"

echo ""
echo "=============================================="
echo "  LEGACY TEST SUITE SUMMARY"
echo "=============================================="
echo "  Passed:   $PASSED/$TOTAL"
echo "  Failed:   $FAILED/$TOTAL"
echo "  Warnings: $WARNINGS"
echo "=============================================="
echo "  ✓ ALL LEGACY TESTS PASSED"
