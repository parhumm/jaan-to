#!/usr/bin/env bash
# session-reader contract test (Tier 2, deterministic).
# Builds a synthetic $HOME with fake Claude/Codex stores and asserts the
# reader's metadata-only JSON contract, including the exact behaviors the
# adversarial review cared about: FLAT Claude session layout (not sessions/),
# Codex SQLite-variant format detection, and graceful total-absence.
#
# Run: bash scripts/test/eval/pm-workflow-audit/session-reader.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
READER="$PLUGIN_ROOT/scripts/lib/session-reader.sh"

PASS=0; FAIL=0
ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
assert_eq() { # desc, expected, actual
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$2', got '$3')"; fi
}

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq not available"; exit 0; }

# ── Fixture: a synthetic HOME with a flat Claude session + plan, and a Codex SQLite store ──
FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT

SLUG="-tmp-fixture-proj"
mkdir -p "$FAKE_HOME/.claude/projects/$SLUG/deadbeef-session/subagents"
mkdir -p "$FAKE_HOME/.claude/plans"
# Flat session transcript (depth 2) — the layout pm-skill-discover's old glob missed.
cat > "$FAKE_HOME/.claude/projects/$SLUG/deadbeef-session.jsonl" <<'JSONL'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read"}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash"}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash"}]}}
JSONL
# A nested subagent transcript (deeper) that must NOT inflate the session count.
echo '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Grep"}]}}' \
  > "$FAKE_HOME/.claude/projects/$SLUG/deadbeef-session/subagents/agent-1.jsonl"
echo "# a plan" > "$FAKE_HOME/.claude/plans/some-plan.md"

# Codex SQLite variant (not the documented sessions/ layout).
if command -v sqlite3 >/dev/null 2>&1; then
  mkdir -p "$FAKE_HOME/.codex"
  sqlite3 "$FAKE_HOME/.codex/state_1.sqlite" "CREATE TABLE threads(id INTEGER);" 2>/dev/null
  HAVE_SQLITE=1
else
  HAVE_SQLITE=0
fi

echo "── Test 1: present stores (Claude flat + Codex sqlite) ──"
OUT="$(HOME="$FAKE_HOME" CLAUDE_CONFIG_DIR="$FAKE_HOME/.claude" CODEX_HOME="$FAKE_HOME/.codex" bash "$READER" discover --days=3650 --tools=claude,codex 2>/dev/null)"
if echo "$OUT" | jq -e . >/dev/null 2>&1; then ok "reader emits valid JSON"; else bad "reader emits valid JSON"; fi
assert_eq "os detected"            "true"  "$(echo "$OUT" | jq -r '(.os|length>0)')"
assert_eq "claude present"         "true"  "$(echo "$OUT" | jq -r '.tools.claude.present')"
assert_eq "claude layout flat"     "flat"  "$(echo "$OUT" | jq -r '.tools.claude.layout')"
assert_eq "claude session count=1 (subagent excluded)" "1" "$(echo "$OUT" | jq -r '.tools.claude.recent_sessions')"
assert_eq "claude plan count=1"    "1"     "$(echo "$OUT" | jq -r '.tools.claude.recent_plans')"
assert_eq "tool_freq Bash=2"       "2"     "$(echo "$OUT" | jq -r '.tools.claude.tool_frequency.Bash')"
# Paths must be hashed, never raw (privacy).
assert_eq "no raw slug leaked"     "false" "$(echo "$OUT" | jq -r 'tostring | contains("tmp-fixture-proj")')"
if [ "$HAVE_SQLITE" = "1" ]; then
  assert_eq "codex format sqlite"  "sqlite" "$(echo "$OUT" | jq -r '.tools.codex.format')"
  assert_eq "codex tables read-only-listed" "true" "$(echo "$OUT" | jq -r '[.tools.codex.sqlite_tables[].tables[]] | any(.=="threads")')"
fi

echo "── Test 2: total absence degrades gracefully ──"
EMPTY="$(mktemp -d)"; trap 'rm -rf "$FAKE_HOME" "$EMPTY"' EXIT
OUT2="$(HOME="$EMPTY" CLAUDE_CONFIG_DIR="$EMPTY/.claude" CODEX_HOME="$EMPTY/.codex" bash "$READER" discover 2>/dev/null)"
if echo "$OUT2" | jq -e . >/dev/null 2>&1; then ok "valid JSON when nothing present"; else bad "valid JSON when nothing present"; fi
assert_eq "claude absent"  "false" "$(echo "$OUT2" | jq -r '.tools.claude.present')"
assert_eq "codex absent"   "false" "$(echo "$OUT2" | jq -r '.tools.codex.present')"
assert_eq "cursor absent"  "false" "$(echo "$OUT2" | jq -r '.tools.cursor.present')"
rm -rf "$EMPTY"

echo "── Test 3: unknown subcommand is rejected ──"
HOME="$FAKE_HOME" bash "$READER" bogus >/dev/null 2>&1; assert_eq "exit 2 on bad subcommand" "2" "$?"

echo
echo "═══════════════════════════════════════"
echo "  session-reader: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"
[ "$FAIL" -eq 0 ]
