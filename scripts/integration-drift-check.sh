#!/bin/bash
# jaan.to Integration Drift Detection Hook
# Called by PostToolUse hook after Write operations
# Detects outputs created after dev-output-integrate has run
# Exit codes: 0 = proceed (always non-blocking)

INPUT=$(cat)

# Extract file path from JSON
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

# Guard 1: Must have a file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Load configuration system
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

if [ -f "${PLUGIN_DIR}/scripts/lib/config-loader.sh" ]; then
  source "${PLUGIN_DIR}/scripts/lib/config-loader.sh"
  load_config
else
  exit 0
fi

# Guard 2: Check if drift detection is enabled
DRIFT_ENABLED=$(get_config "integration_drift_check" "true")
if [ "$DRIFT_ENABLED" != "true" ]; then
  exit 0
fi

# Guard 3: File must be inside the outputs directory
OUTPUTS_DIR=$(get_config "paths_outputs" "jaan-to/outputs")
if [[ "$FILE_PATH" != *"${OUTPUTS_DIR}/"* ]]; then
  exit 0
fi

# Guard 4: Skip files inside dev/output-integrate/ (integration logs)
if [[ "$FILE_PATH" == *"${OUTPUTS_DIR}/dev/output-integrate/"* ]]; then
  exit 0
fi

# Guard 5: Skip the manifest file itself
if [[ "$FILE_PATH" == *".last-integration-manifest" ]]; then
  exit 0
fi

# Guard 6: No manifest = no integration has ever run, exit silently
MANIFEST_PATH="${PROJECT_DIR}/${OUTPUTS_DIR}/.last-integration-manifest"
if [ ! -f "$MANIFEST_PATH" ]; then
  exit 0
fi

# Guard 7: Debounce — skip if warned within last 30 seconds
DEBOUNCE_KEY=$(echo "$PROJECT_DIR" | tr '/' '_')
DEBOUNCE_FILE="/tmp/jaan-to-drift-warned-${DEBOUNCE_KEY}"
if [ -f "$DEBOUNCE_FILE" ]; then
  LAST_WARN=$(stat -f %m "$DEBOUNCE_FILE" 2>/dev/null || stat -c %Y "$DEBOUNCE_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  ELAPSED=$((NOW - LAST_WARN))
  if [ "$ELAPSED" -lt 30 ]; then
    exit 0
  fi
fi

# Extract relative path from full path
REL_PATH="${FILE_PATH##*${PROJECT_DIR}/}"

# Core check: if file IS in manifest, no drift
if grep -qxF "$REL_PATH" "$MANIFEST_PATH" 2>/dev/null; then
  exit 0
fi

# Drift detected — print suggestion to stderr
FILENAME=$(basename "$FILE_PATH")
echo "" >&2
echo "---" >&2
echo "New output detected after integration: ${FILENAME}" >&2
echo "" >&2
echo "This file was created after the last dev-output-integrate run." >&2
echo "Re-run to integrate: /jaan-to:dev-output-integrate" >&2
echo "---" >&2

# Touch debounce file
touch "$DEBOUNCE_FILE"

exit 0
