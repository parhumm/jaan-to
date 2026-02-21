#!/bin/bash
# Backward-compatible wrapper for Claude target build.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/build-target.sh" claude
