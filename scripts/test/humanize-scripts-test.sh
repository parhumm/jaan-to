#!/bin/bash
# Deterministic checks for skills/humanize/scripts (no model calls).
# Semantic eval cases live in scripts/test/eval/humanize/.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
S="$PLUGIN_ROOT/skills/humanize/scripts"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
FAIL=0

check() { # name expected-exit cmd...
  local name="$1" want="$2"; shift 2
  local got=0
  "$@" >/dev/null 2>&1 || got=$?
  if [ "$got" -eq "$want" ]; then echo "  ✓ $name"; else echo "  ✗ $name (exit $got, want $want)"; FAIL=1; fi
}

echo "=== humanize scripts ==="
command -v python3 >/dev/null || { echo "  - python3 not found, skipping"; exit 0; }

check "check_tells self-test" 0 python3 -B "$S/check_tells.py" --self-test
check "persian_cleanup self-test" 0 python3 -B "$S/persian_cleanup.py" --self-test

printf 'این متن خوب است.\n' > "$T/fa-clean.md"
printf 'این متن — بسیار مهم است!!\n' > "$T/fa-dirty.md"
check "fa_lint passes clean Persian" 0 python3 -B "$S/fa_lint.py" --check "$T/fa-clean.md"
check "fa_lint flags em dash and !!" 1 python3 -B "$S/fa_lint.py" --check "$T/fa-dirty.md"

printf 'Revenue grew 12%% in Q3 to $4.1M.\n' > "$T/src.md"
printf 'Revenue grew in Q3.\n' > "$T/dropped.md"
check "check_tells passes an unchanged copy" 0 python3 -B "$S/check_tells.py" "$T/src.md" --source "$T/src.md" --lang en
check "check_tells fails on dropped numbers" 1 python3 -B "$S/check_tells.py" "$T/dropped.md" --source "$T/src.md" --lang en

[ "$FAIL" -eq 0 ] && echo "PASS" || { echo "FAIL"; exit 1; }
