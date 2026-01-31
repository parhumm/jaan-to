#!/usr/bin/env bash
# session-end.sh — Log session metrics
# Triggered by Stop hook

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
METRICS_DIR="$PROJECT_DIR/.jaan-to/metrics"

# Create metrics directory if it doesn't exist
mkdir -p "$METRICS_DIR"

# Log session end timestamp
echo "{\"event\":\"session_end\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$METRICS_DIR/sessions.jsonl"

exit 0
