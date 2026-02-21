#!/bin/bash
# Build all runtime distributions (Claude + Codex).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/build-target.sh" claude
echo ""
"$SCRIPT_DIR/build-target.sh" codex
