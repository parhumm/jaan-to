#!/bin/bash
# e2e-dual-runtime-full.sh — Full dual-runtime test suite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

run_step() {
  local label="$1"
  local cmd="$2"

  echo ""
  echo "=================================================="
  echo "  $label"
  echo "=================================================="

  # shellcheck disable=SC2086
  eval "$cmd"
}

echo "=== Full Dual-Runtime E2E Suite ==="

run_step "Integrated Smoke E2E" "bash \"$SCRIPT_DIR/e2e-dual-runtime-smoke.sh\""
run_step "Legacy E2E Suite" "bash \"$SCRIPT_DIR/run-all-tests.sh\""

echo ""
echo "✓ Full dual-runtime E2E suite passed"
