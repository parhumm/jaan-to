#!/bin/bash
# Agent Skills Standard Compliance E2E Tests
# Tests both success (current codebase passes) and failure (synthetic rejects) scenarios
set -euo pipefail

echo "=== Agent Skills Compliance E2E Test ==="

TEST_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$TEST_DIR"
export CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

PASS=0
FAIL=0

assert_pass() {
  PASS=$((PASS + 1))
  echo "✓ $1"
}

assert_fail() {
  FAIL=$((FAIL + 1))
  echo "✗ FAIL: $1"
}

# ─── SUCCESS TESTS (current codebase must pass) ─────

# Test 1: All skill names are spec-compliant
echo -e "\n[Test 1] Skill names comply with Agent Skills spec"
NAME_FAIL=0
for skill_dir in "$CLAUDE_PLUGIN_ROOT"/skills/*/; do
  name="$(basename "$skill_dir")"
  if [[ ! "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$name" =~ -- ]] || [ ${#name} -gt 64 ]; then
    echo "  ✗ Invalid name: $name"; NAME_FAIL=1
  fi
done
[ $NAME_FAIL -eq 0 ] && assert_pass "All names spec-compliant" || assert_fail "Some names invalid"

# Test 2: All skills have license field
echo -e "\n[Test 2] All SKILL.md have license field"
MISSING=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  if ! grep -q '^license:' "$skill"; then
    echo "  ✗ Missing license: $(basename "$(dirname "$skill")")"
    MISSING=$((MISSING+1))
  fi
done
[ $MISSING -eq 0 ] && assert_pass "All skills have license" || assert_fail "$MISSING missing license"

# Test 3: All skills have compatibility field
echo -e "\n[Test 3] All SKILL.md have compatibility field"
MISSING=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  if ! grep -q '^compatibility:' "$skill"; then
    echo "  ✗ Missing compatibility: $(basename "$(dirname "$skill")")"
    MISSING=$((MISSING+1))
  fi
done
[ $MISSING -eq 0 ] && assert_pass "All skills have compatibility" || assert_fail "$MISSING missing compatibility"

# Test 4: All descriptions have "Use when" trigger phrase
echo -e "\n[Test 4] Descriptions include trigger phrases"
MISSING=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill")
  if ! echo "$desc" | grep -qi "Use when\|Use to\|Use for"; then
    echo "  ✗ No trigger: $(basename "$(dirname "$skill")")"
    MISSING=$((MISSING+1))
  fi
done
[ $MISSING -eq 0 ] && assert_pass "All descriptions have trigger phrases" || assert_fail "$MISSING missing triggers"

# Test 5: No [Internal] prefix in descriptions
echo -e "\n[Test 5] No [Internal] prefix in descriptions"
FOUND=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill")
  if echo "$desc" | grep -q '\[Internal\]'; then
    echo "  ✗ Has [Internal]: $(basename "$(dirname "$skill")")"
    FOUND=$((FOUND+1))
  fi
done
[ $FOUND -eq 0 ] && assert_pass "No [Internal] prefixes" || assert_fail "$FOUND found"

# Test 6: marketplace.json skills[] count matches disk
echo -e "\n[Test 6] marketplace.json skills[] synced with disk"
MANIFEST_COUNT=$(jq '.plugins[0].skills | length' "$CLAUDE_PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null || echo 0)
DISK_COUNT=$(ls -d "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
[ "$MANIFEST_COUNT" -eq "$DISK_COUNT" ] && assert_pass "Synced ($DISK_COUNT skills)" || assert_fail "manifest=$MANIFEST_COUNT disk=$DISK_COUNT"

# Test 7: marketplace.json skills[] paths all start with ./
echo -e "\n[Test 7] marketplace.json skills[] paths start with ./"
BAD=0
while IFS= read -r path; do
  if [[ ! "$path" =~ ^\.\/ ]]; then
    echo "  ✗ Bad path: $path"; BAD=$((BAD+1))
  fi
done < <(jq -r '.plugins[0].skills[]?' "$CLAUDE_PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null)
[ $BAD -eq 0 ] && assert_pass "All paths start with ./" || assert_fail "$BAD bad paths"

# Test 8: marketplace.json has metadata.pluginRoot
echo -e "\n[Test 8] marketplace.json has metadata.pluginRoot"
ROOT=$(jq -r '.metadata.pluginRoot // "MISSING"' "$CLAUDE_PLUGIN_ROOT/.claude-plugin/marketplace.json" 2>/dev/null)
[ "$ROOT" != "MISSING" ] && assert_pass "pluginRoot present: $ROOT" || assert_fail "missing pluginRoot"

# Test 9: Description budget within limits
echo -e "\n[Test 9] Description budget under 15,000 chars"
bash "$CLAUDE_PLUGIN_ROOT/scripts/validate-skills.sh" > /dev/null 2>&1 && assert_pass "Budget check passed" || assert_fail "budget exceeded"

# Test 10: No descriptions contain colons
echo -e "\n[Test 10] No colons in descriptions"
COLON=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  desc=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$skill")
  if echo "$desc" | grep -q ':'; then
    echo "  ✗ Has colon: $(basename "$(dirname "$skill")")"
    COLON=$((COLON+1))
  fi
done
[ $COLON -eq 0 ] && assert_pass "No colons in descriptions" || assert_fail "$COLON found"

# Test 11: All SKILL.md under 600-line hard cap
echo -e "\n[Test 11] All SKILL.md under 600-line hard cap"
OVER=0
for skill in "$CLAUDE_PLUGIN_ROOT"/skills/*/SKILL.md; do
  lines=$(wc -l < "$skill" | tr -d ' ')
  if [ "$lines" -gt 600 ]; then
    echo "  ✗ Over 600: $(basename "$(dirname "$skill")") ($lines lines)"
    OVER=$((OVER+1))
  fi
done
[ $OVER -eq 0 ] && assert_pass "All under 600-line cap" || assert_fail "$OVER over"

# Test 12: plugin.json does NOT have skills[] (must stay clean)
echo -e "\n[Test 12] plugin.json has no skills[] field"
SKILLS_IN_PLUGIN=$(jq -r '.skills // "null"' "$CLAUDE_PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null)
[ "$SKILLS_IN_PLUGIN" = "null" ] && assert_pass "plugin.json clean (no skills[])" || assert_fail "plugin.json has skills[]"

# ─── FAILURE TESTS (validate rejection) ──────────────

# Test 13: Reject name with uppercase
echo -e "\n[Test 13] Reject uppercase skill name"
INVALID_NAME="My-Skill"
if [[ "$INVALID_NAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
  assert_fail "accepted uppercase"
else
  assert_pass "Rejected uppercase name"
fi

# Test 14: Reject name with consecutive hyphens
echo -e "\n[Test 14] Reject consecutive hyphens in name"
INVALID_NAME="my--skill"
if [[ "$INVALID_NAME" =~ -- ]]; then
  assert_pass "Rejected consecutive hyphens"
else
  assert_fail "accepted consecutive hyphens"
fi

# Test 15: Reject name starting with hyphen
echo -e "\n[Test 15] Reject name starting with hyphen"
INVALID_NAME="-my-skill"
if [[ "$INVALID_NAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
  assert_fail "accepted leading hyphen"
else
  assert_pass "Rejected leading hyphen"
fi

# Test 16: Reject name over 64 chars
echo -e "\n[Test 16] Reject name over 64 characters"
LONG_NAME="abcdefghijklmnopqrstuvwxyz-abcdefghijklmnopqrstuvwxyz-abcdefghijk"
if [ ${#LONG_NAME} -gt 64 ]; then
  assert_pass "Rejected name over 64 chars (${#LONG_NAME} chars)"
else
  assert_fail "didn't reject"
fi

# Test 17: Reject SKILL.md without license (synthetic)
echo -e "\n[Test 17] Detect missing license in synthetic SKILL.md"
mkdir -p "$TEST_DIR/skills/test-skill"
cat > "$TEST_DIR/skills/test-skill/SKILL.md" <<'EOF'
---
name: test-skill
description: Test skill without license. Use when testing.
---
# test-skill
EOF
if grep -q '^license:' "$TEST_DIR/skills/test-skill/SKILL.md"; then
  assert_fail "found license that shouldn't exist"
else
  assert_pass "Correctly detected missing license"
fi

# Test 18: Reject description without trigger phrase (synthetic)
echo -e "\n[Test 18] Detect missing trigger phrase in description"
desc="Generate a document from input"
if echo "$desc" | grep -qi "Use when\|Use to\|Use for"; then
  assert_fail "found trigger that shouldn't exist"
else
  assert_pass "Correctly detected missing trigger phrase"
fi

# Test 19: Reject description with colon (synthetic)
echo -e "\n[Test 19] Detect colon in description"
desc="Generate output: from input. Use when testing."
if echo "$desc" | grep -q ':'; then
  assert_pass "Correctly detected colon in description"
else
  assert_fail "missed colon"
fi

# Test 20: Detect marketplace.json skills[] drift (synthetic)
echo -e "\n[Test 20] Detect skills[] count mismatch"
mkdir -p "$TEST_DIR/.claude-plugin"
echo '{"plugins":[{"skills":["./skills/a","./skills/b"]}]}' > "$TEST_DIR/.claude-plugin/marketplace.json"
mkdir -p "$TEST_DIR/skills/a" "$TEST_DIR/skills/b" "$TEST_DIR/skills/c"
touch "$TEST_DIR/skills/a/SKILL.md" "$TEST_DIR/skills/b/SKILL.md" "$TEST_DIR/skills/c/SKILL.md"
MANIFEST_COUNT=$(jq '.plugins[0].skills | length' "$TEST_DIR/.claude-plugin/marketplace.json")
DISK_COUNT=$(ls -d "$TEST_DIR"/skills/*/SKILL.md | wc -l | tr -d ' ')
if [ "$MANIFEST_COUNT" -ne "$DISK_COUNT" ]; then
  assert_pass "Correctly detected drift (manifest=$MANIFEST_COUNT disk=$DISK_COUNT)"
else
  assert_fail "didn't detect drift"
fi

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "=== Agent Skills Compliance E2E Results ==="
TOTAL=$((PASS + FAIL))
echo "  Passed: $PASS/$TOTAL"
echo "  Failed: $FAIL/$TOTAL"

if [ "$FAIL" -eq 0 ]; then
  echo "  ✓ ALL TESTS PASSED"
  exit 0
else
  echo "  ✗ SOME TESTS FAILED"
  exit 1
fi
