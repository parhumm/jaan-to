#!/bin/bash
# Run all E2E and integration tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASSED=0
FAILED=0
WARNINGS=0

run_test() {
  local test_name=$1
  local test_script=$2

  echo ""
  echo "=================================================="
  echo "  Running: $test_name"
  echo "=================================================="

  if bash "$test_script" 2>&1 | tee /tmp/test-output.log; then
    echo "✓ $test_name PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "✗ $test_name FAILED"
    FAILED=$((FAILED + 1))
    return 1
  fi

  # Count warnings
  if [ -f /tmp/test-output.log ]; then
    warning_count=$(grep -c "⚠" /tmp/test-output.log 2>/dev/null || echo 0)
    WARNINGS=$((WARNINGS + warning_count))
  fi
}

echo "=============================================="
echo "  jaan.to Plugin v3.0.0 - Test Suite"
echo "=============================================="

# Run tests in order
run_test "Phase 1 E2E" "$SCRIPT_DIR/phase1-e2e.sh" || true
run_test "Phase 2 E2E" "$SCRIPT_DIR/phase2-e2e.sh" || true
run_test "Phases 3-5 E2E" "$SCRIPT_DIR/phase3-5-e2e.sh" || true
run_test "Phase 6 E2E" "$SCRIPT_DIR/phase6-e2e.sh" || true
run_test "Unified Integration" "$SCRIPT_DIR/integration-all-phases.sh" || true

# Summary
echo ""
echo "=============================================="
echo "  TEST SUITE SUMMARY"
echo "=============================================="
echo "  Passed:   $PASSED/5"
echo "  Failed:   $FAILED/5"
echo "  Warnings: $WARNINGS"
echo "=============================================="

if [ "$FAILED" -eq 0 ]; then
  echo "  ✓ ALL TESTS PASSED"
  exit 0
else
  echo "  ✗ SOME TESTS FAILED"
  exit 1
fi
