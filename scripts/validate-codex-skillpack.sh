#!/bin/bash
# validate-codex-skillpack.sh — Verify committed Codex skillpack is in sync with source.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMITTED_SKILLPACK="$PLUGIN_ROOT/adapters/codex/skillpack"

if [ ! -d "$COMMITTED_SKILLPACK" ]; then
  echo "ERROR: Missing committed skillpack at $COMMITTED_SKILLPACK" >&2
  echo "Run: bash scripts/build-codex-skillpack.sh" >&2
  exit 1
fi

TMP_ROOT="$(mktemp -d /tmp/jaan-to-skillpack-validate-XXXXXX)"
TMP_SKILLPACK="$TMP_ROOT/skillpack"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

bash "$PLUGIN_ROOT/scripts/build-codex-skillpack.sh" --out "$TMP_SKILLPACK" >/dev/null

if diff -qr "$TMP_SKILLPACK" "$COMMITTED_SKILLPACK" >/tmp/jaan-to-skillpack-diff.log 2>&1; then
  echo "✓ Codex skillpack is in sync"
  rm -f /tmp/jaan-to-skillpack-diff.log
  exit 0
fi

echo "✗ Codex skillpack drift detected"
echo "Run: bash scripts/build-codex-skillpack.sh"
echo ""
cat /tmp/jaan-to-skillpack-diff.log
rm -f /tmp/jaan-to-skillpack-diff.log
exit 1
