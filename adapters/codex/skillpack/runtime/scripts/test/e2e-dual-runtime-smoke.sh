#!/bin/bash
# e2e-dual-runtime-smoke.sh — Integrated dual-runtime smoke validation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=scripts/lib/runtime-contract.sh
source "$PLUGIN_ROOT/scripts/lib/runtime-contract.sh"

CLAUDE_DIST="$(runtime_dist_dir claude)"
CODEX_DIST="$(runtime_dist_dir codex)"
TMP_ROOT="$(mktemp -d /tmp/jaan-to-e2e-smoke-XXXXXX)"
TMP_CLAUDE_PROJECT="$TMP_ROOT/claude-project"
TMP_CODEX_PROJECT="$TMP_ROOT/codex-project"
TMP_CODEX_GLOBAL_PROJECT="$TMP_ROOT/codex-project-global"
TMP_GLOBAL_PACK="$TMP_ROOT/global-pack"
ERRORS=0

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

pass() {
  echo "  ✓ $1"
}

fail() {
  echo "  ✗ $1"
  ERRORS=$((ERRORS + 1))
}

assert_exists() {
  local path="$1"
  local label="$2"
  if [ -e "$path" ]; then
    pass "$label"
  else
    fail "$label (missing: $path)"
  fi
}

assert_not_exists() {
  local path="$1"
  local label="$2"
  if [ -e "$path" ]; then
    fail "$label (unexpected: $path)"
  else
    pass "$label"
  fi
}

assert_equals() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [ "$expected" = "$actual" ]; then
    pass "$label"
  else
    fail "$label (expected=$expected actual=$actual)"
  fi
}

echo "=== Integrated Dual-Runtime Smoke E2E ==="

if [ "${SKIP_BUILD:-0}" != "1" ]; then
  echo "Building runtime distributions..."
  bash "$PLUGIN_ROOT/scripts/build-all-targets.sh" >/dev/null
else
  echo "Skipping build (SKIP_BUILD=1)"
fi

echo ""
echo "1) Dist contracts"
while IFS= read -r required; do
  [ -n "$required" ] || continue
  assert_exists "$required" "Claude required path exists: ${required#$PLUGIN_ROOT/}"
done < <(runtime_required_paths claude)

while IFS= read -r required; do
  [ -n "$required" ] || continue
  assert_exists "$required" "Codex required path exists: ${required#$PLUGIN_ROOT/}"
done < <(runtime_required_paths codex)

if [ -x "$CODEX_DIST/jaan-to" ]; then
  pass "Codex runner is executable"
else
  fail "Codex runner is executable"
fi

echo ""
echo "2) Claude non-regression flow"
mkdir -p "$TMP_CLAUDE_PROJECT/jaan-to"
if CLAUDE_PLUGIN_ROOT="$CLAUDE_DIST" CLAUDE_PROJECT_DIR="$TMP_CLAUDE_PROJECT" bash "$CLAUDE_DIST/scripts/bootstrap.sh" >/dev/null; then
  pass "Claude bootstrap succeeds with Claude dist"
else
  fail "Claude bootstrap succeeds with Claude dist"
fi

assert_exists "$TMP_CLAUDE_PROJECT/jaan-to/config/settings.yaml" "Claude bootstrap created settings.yaml"
assert_exists "$TMP_CLAUDE_PROJECT/jaan-to/context" "Claude bootstrap created context directory"
assert_exists "$TMP_CLAUDE_PROJECT/jaan-to/outputs" "Claude bootstrap created outputs directory"

while IFS= read -r forbidden; do
  [ -n "$forbidden" ] || continue
  assert_not_exists "$forbidden" "Claude dist excludes Codex artifact: ${forbidden#$PLUGIN_ROOT/}"
done < <(runtime_forbidden_in_claude_dist)

echo ""
echo "3) Codex integrated flow"
mkdir -p "$TMP_CODEX_PROJECT"
if JAAN_ALLOW_LOCAL_WITH_GLOBAL=1 "$CODEX_DIST/jaan-to" setup "$TMP_CODEX_PROJECT" --mode local >/dev/null; then
  pass "Codex setup succeeds"
else
  fail "Codex setup succeeds"
fi

SOURCE_SKILLS="$(find "$PLUGIN_ROOT/skills" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
INSTALLED_SKILLS="$(find -L "$TMP_CODEX_PROJECT/.agents/skills" -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
assert_equals "$SOURCE_SKILLS" "$INSTALLED_SKILLS" "Installed skill count matches source"
assert_exists "$TMP_CODEX_PROJECT/AGENTS.md" "Project AGENTS.md exists after setup"

if CODEX_PROJECT_DIR="$TMP_CODEX_PROJECT" "$CODEX_DIST/jaan-to" run /jaan-to:pm-prd-write "smoke" --dry-run >/dev/null; then
  pass "Runner supports /jaan-to:* command form"
else
  fail "Runner supports /jaan-to:* command form"
fi

if CODEX_PROJECT_DIR="$TMP_CODEX_PROJECT" "$CODEX_DIST/jaan-to" run /pm-prd-write "smoke" --dry-run >/dev/null; then
  pass "Runner supports /<skill> command form"
else
  fail "Runner supports /<skill> command form"
fi

if CODEX_PROJECT_DIR="$TMP_CODEX_PROJECT" "$CODEX_DIST/jaan-to" run pm-prd-write "smoke" --dry-run >/dev/null; then
  pass "Runner supports plain <skill> command form"
else
  fail "Runner supports plain <skill> command form"
fi

INVALID_LOG="$TMP_ROOT/invalid-skill.log"
if CODEX_PROJECT_DIR="$TMP_CODEX_PROJECT" "$CODEX_DIST/jaan-to" run /jaan-to:not-real "smoke" --dry-run >"$INVALID_LOG" 2>&1; then
  fail "Unknown skill exits non-zero"
else
  pass "Unknown skill exits non-zero"
fi

if grep -q "Did you mean" "$INVALID_LOG"; then
  pass "Unknown skill output includes suggestions"
else
  fail "Unknown skill output includes suggestions"
fi

mkdir -p "$TMP_GLOBAL_PACK/skills/pm-prd-write"
cp "$PLUGIN_ROOT/skills/pm-prd-write/SKILL.md" "$TMP_GLOBAL_PACK/skills/pm-prd-write/SKILL.md"

if "$CODEX_DIST/jaan-to" setup "$TMP_CODEX_PROJECT" --mode global --pack-root "$TMP_GLOBAL_PACK" >/tmp/jaan-to-e2e-global-dup.log 2>&1; then
  fail "Global mode duplicate guard should fail when local links already exist"
else
  if grep -q "Duplicate jaan.to skill names detected" /tmp/jaan-to-e2e-global-dup.log; then
    pass "Global mode duplicate guard blocks mixed local/global setup"
  else
    fail "Global mode duplicate guard reported expected message"
  fi
fi

mkdir -p "$TMP_CODEX_GLOBAL_PROJECT"
if "$CODEX_DIST/jaan-to" setup "$TMP_CODEX_GLOBAL_PROJECT" --mode global --pack-root "$TMP_GLOBAL_PACK" >/dev/null; then
  pass "Global mode setup succeeds on clean project"
else
  fail "Global mode setup succeeds on clean project"
fi

if [ -d "$TMP_CODEX_GLOBAL_PROJECT/.agents/skills" ]; then
  fail "Global mode avoids project-local skill symlinks"
else
  pass "Global mode avoids project-local skill symlinks"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "✗ Integrated dual-runtime smoke failed ($ERRORS issues)"
  exit 1
fi

rm -f /tmp/jaan-to-e2e-global-dup.log
echo "✓ Integrated dual-runtime smoke passed"
