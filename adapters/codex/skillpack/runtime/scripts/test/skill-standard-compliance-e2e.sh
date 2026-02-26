#!/bin/bash
# skill-standard-compliance-e2e.sh — E2E tests for skill standard compliance.
# Validates license, naming, trigger phrases, and marketplace sync with
# both positive (real repo) and negative (synthetic) test cases.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$PLUGIN_ROOT/skills"
MARKETPLACE="$PLUGIN_ROOT/.claude-plugin/marketplace.json"

PASS=0
FAIL=0

assert_pass() {
  echo "  ✓ $1"
  PASS=$((PASS + 1))
}

assert_fail() {
  echo "  ✗ $1"
  FAIL=$((FAIL + 1))
}

echo "═══════════════════════════════════════"
echo "  Skill Standard Compliance E2E Tests"
echo "═══════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────
# Positive tests — real repo state
# ─────────────────────────────────────────────────────

echo "── Positive Tests (real repo) ──"

# 1. All skills have license field
MISSING=0
for skill in "$SKILLS_DIR"/*/SKILL.md; do
  grep -q '^license:' "$skill" || MISSING=$((MISSING + 1))
done
[ "$MISSING" -eq 0 ] && assert_pass "All skills have license field" || assert_fail "Missing license in $MISSING skills"

# 2. All descriptions have trigger phrases
MISSING=0
for skill in "$SKILLS_DIR"/*/SKILL.md; do
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill")
  echo "$desc" | grep -qi "Use when\|Use to\|Use for" || MISSING=$((MISSING + 1))
done
[ "$MISSING" -eq 0 ] && assert_pass "All descriptions have trigger phrases" || assert_fail "Missing trigger phrase in $MISSING skills"

# 3. All skill names are spec-compliant
INVALID=0
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  if [[ ! "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$name" =~ -- ]] || [ ${#name} -gt 64 ]; then
    INVALID=$((INVALID + 1))
  fi
done
[ "$INVALID" -eq 0 ] && assert_pass "All skill names are spec-compliant" || assert_fail "$INVALID invalid skill names"

# 4. marketplace.json skills[] count matches actual
MANIFEST_COUNT=$(jq '.plugins[0].skills | length' "$MARKETPLACE" 2>/dev/null || echo 0)
ACTUAL_COUNT=$(ls -d "$SKILLS_DIR"/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
[ "$MANIFEST_COUNT" -eq "$ACTUAL_COUNT" ] && assert_pass "Marketplace sync ($ACTUAL_COUNT skills)" || assert_fail "Marketplace mismatch: manifest=$MANIFEST_COUNT actual=$ACTUAL_COUNT"

echo ""

# ─────────────────────────────────────────────────────
# Negative tests — synthetic failures
# ─────────────────────────────────────────────────────

echo "── Negative Tests (synthetic) ──"

TMP_DIR="$(mktemp -d /tmp/jaan-to-compliance-test-XXXXXX)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# 5. Missing license field is detected
mkdir -p "$TMP_DIR/no-license"
cat > "$TMP_DIR/no-license/SKILL.md" << 'SKILL'
---
name: no-license
description: Test skill without license. Use when testing.
allowed-tools: Read
argument-hint: [input]
---
# no-license
SKILL
if ! grep -q '^license:' "$TMP_DIR/no-license/SKILL.md"; then
  assert_pass "Detect missing license field"
else
  assert_fail "Failed to detect missing license"
fi

# 6. Invalid skill name is detected
BADNAME="My--skill"
if [[ ! "$BADNAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$BADNAME" =~ -- ]]; then
  assert_pass "Detect invalid skill name (consecutive hyphens/uppercase)"
else
  assert_fail "Failed to detect invalid name"
fi

# 7. Missing trigger phrase is detected
DESC_NO_TRIGGER="Generate something from input"
if ! echo "$DESC_NO_TRIGGER" | grep -qi "Use when\|Use to\|Use for"; then
  assert_pass "Detect missing trigger phrase"
else
  assert_fail "Failed to detect missing trigger phrase"
fi

# 8. Marketplace count mismatch is detected
FAKE_COUNT=999
[ "$FAKE_COUNT" -ne "$ACTUAL_COUNT" ] && assert_pass "Detect marketplace count mismatch" || assert_fail "Failed to detect count mismatch"

echo ""
echo "═══════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
