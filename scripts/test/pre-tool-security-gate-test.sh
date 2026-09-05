#!/bin/bash
# Regression test for scripts/pre-tool-security-gate.sh (PreToolUse hook).
#
# Every payload is assembled at runtime from fragments ($S, $SU) so that this file never
# contains a blocked pattern: the same gate scans every Bash command Claude Code runs,
# including the one that writes, cats or greps this file.
#
# Covers the 2026-09-05 fixes:
#   - the execute-flag rule matched any substitution with pipe delimiters that was followed
#     later in the command by two more pipes and a letter e (e.g. "| sort | head") and
#     blocked harmless read-only commands; the flag is now anchored to the flags position
#   - BLOCKED reasons went to stdout, which Claude Code drops on exit 2 ("No stderr output");
#     they must reach stderr so the model sees the reason instead of retrying blind
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$PLUGIN_ROOT/scripts/pre-tool-security-gate.sh"
[ -x "$GATE" ] || chmod +x "$GATE"

echo "=== Security Gate Regression Test ==="
pass=0
fail=0
S="s""ed"
SU="su""do"

# run_gate <command> -> prints "<exit code><TAB><stderr>"
run_gate() {
  local payload err code
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1")
  set +e
  err=$(printf '%s' "$payload" | bash "$GATE" 2>&1 >/dev/null)
  code=$?
  set -e
  printf '%s\t%s' "$code" "$err"
}

expect_allow() {
  local name="$1" cmd="$2" res code
  res=$(run_gate "$cmd")
  code=${res%%$'\t'*}
  if [ "$code" = "0" ]; then
    echo "✓ allow: $name"; pass=$((pass + 1))
  else
    echo "✗ FAIL (exit $code, expected 0): $name"; echo "    stderr: ${res#*$'\t'}"; fail=$((fail + 1))
  fi
}

expect_block() {
  local name="$1" cmd="$2" res code err
  res=$(run_gate "$cmd")
  code=${res%%$'\t'*}
  err=${res#*$'\t'}
  if [ "$code" = "2" ] && [[ "$err" == *BLOCKED* ]]; then
    echo "✓ block: $name"; pass=$((pass + 1))
  else
    echo "✗ FAIL (exit $code, stderr '${err:0:80}'): $name — expected exit 2 with a BLOCKED reason on stderr"; fail=$((fail + 1))
  fi
}

echo -e "\n[Allow] read-only commands that the old execute-flag regex rejected"
expect_allow "pipe-delimited substitutions followed by sort/head" \
  "ls | $S 's|.*/projects/||; s|/.*||' | sort | uniq -c | sort -rn | head"
expect_allow "substitution then a grep with alternation" \
  "echo \"\$f\" | $S \"s|\$K/||\"; grep -n -E \"MCP servers|read via MCP\" file"
expect_allow "in-place substitution with g flag" \
  "$S -i '' 's/foo/bar/g' file.txt"
expect_allow "print flag only" \
  "$S -n 's/^socket[[:space:]]*//p' out.txt"
expect_allow "plain git status" \
  "git status --short"

echo -e "\n[Block] real execute flags and privileged deletes, reason on stderr"
expect_block "execute flag, slash delimiter" \
  "$S 's/x/y/e' file"
expect_block "execute flag combined with g, hash delimiter" \
  "$S -e \"s#a#b#ge\" file"
expect_block "execute flag, pipe delimiter, after a pipe" \
  "cat f | $S 's|a|b|e'"
expect_block "privileged delete" \
  "$SU rm file"

echo -e "\n=== $pass passed, $fail failed ==="
[ "$fail" -eq 0 ]
