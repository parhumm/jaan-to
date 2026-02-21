#!/bin/bash
# prepare-skill-pr.sh — Sync and stage Codex skillpack before skill PR commits.
# Usage: bash scripts/prepare-skill-pr.sh [--check|--no-stage]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK_ONLY=0
STAGE=1

usage() {
  cat <<'USAGE'
Usage: bash scripts/prepare-skill-pr.sh [options]

Options:
  --check      Validate skillpack drift only (no build, no staging)
  --no-stage   Build + validate but do not stage adapters/codex/skillpack
  -h, --help   Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      CHECK_ONLY=1
      STAGE=0
      shift
      ;;
    --no-stage)
      STAGE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

cd "$PLUGIN_ROOT"

if [ "$CHECK_ONLY" -eq 1 ]; then
  echo "Checking Codex skillpack drift..."
  bash "$PLUGIN_ROOT/scripts/validate-codex-skillpack.sh"
  echo "Skillpack drift check passed."
  exit 0
fi

echo "Building Codex skillpack..."
bash "$PLUGIN_ROOT/scripts/build-codex-skillpack.sh"

echo "Validating Codex skillpack..."
bash "$PLUGIN_ROOT/scripts/validate-codex-skillpack.sh"

if [ "$STAGE" -eq 1 ]; then
  if ! git -C "$PLUGIN_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Not inside a git worktree. Cannot stage adapters/codex/skillpack." >&2
    exit 1
  fi

  git -C "$PLUGIN_ROOT" add adapters/codex/skillpack
  echo "Staged: adapters/codex/skillpack"
else
  echo "Skipped staging adapters/codex/skillpack (--no-stage)."
fi

echo "Done. Codex skillpack is synced for PR."
