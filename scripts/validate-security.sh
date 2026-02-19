#!/bin/bash
# validate-security.sh — Security standards enforcement for jaan-to plugin
#
# Codifies security rules from docs/security-strategy.md
# Used by: CI (release-check.yml), /jaan-release, /jaan-issue-review
#
# Exit 0 if pass, exit 1 if blocking errors found
# Usage: bash scripts/validate-security.sh [--strict]
#   --strict: treat advisory warnings as blocking errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STRICT_MODE="${1:-}"

ERRORS=0
WARNINGS=0

echo "═══════════════════════════════════════════════════════════"
echo "  Security Standards Validation"
echo "  Reference: docs/security-strategy.md"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ── Helper: extract allowed-tools from YAML frontmatter ──
extract_allowed_tools() {
  local file=$1
  local tools=""
  local in_frontmatter=false
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        break
      fi
      in_frontmatter=true
      continue
    fi
    if $in_frontmatter; then
      if [[ "$line" =~ ^allowed-tools:\ *(.+)$ ]]; then
        tools="${BASH_REMATCH[1]}"
        break
      fi
    fi
  done < "$file"
  echo "$tools"
}

# ═════════════════════════════════════════════════════════════
# Section A: Skill Permission Safety
# ═════════════════════════════════════════════════════════════

echo "Section A: Skill Permission Safety"
echo "────────────────────────────────────────────────────────"

check_skill_permissions() {
  local skill_dir=$1
  local level=$2  # "BLOCKING" or "ADVISORY"

  for skill in "$skill_dir"/*/SKILL.md; do
    [ -f "$skill" ] || continue
    local skill_name
    skill_name=$(basename "$(dirname "$skill")")
    local tools
    tools=$(extract_allowed_tools "$skill")

    [ -z "$tools" ] && continue

    # A1: Write(**) — bare wildcard writes
    if echo "$tools" | grep -qE 'Write\(\*\*\)'; then
      if [ "$level" = "BLOCKING" ]; then
        echo "  ::error::A1 [$skill_name] Write(**) — unrestricted file writes"
        ((ERRORS++))
      else
        echo "  ::warning::A1 [$skill_name] Write(**) — unrestricted file writes (local skill)"
        ((WARNINGS++))
      fi
    fi

    # A2: Bare Bash or Bash(*:*) — unrestricted shell
    # Check for bare "Bash" that is NOT followed by (
    if echo ",$tools," | grep -qE ',\s*Bash\s*[,]'; then
      if [ "$level" = "BLOCKING" ]; then
        echo "  ::error::A2 [$skill_name] Bare Bash — unrestricted shell access"
        ((ERRORS++))
      else
        echo "  ::warning::A2 [$skill_name] Bare Bash — unrestricted shell access (local skill)"
        ((WARNINGS++))
      fi
    fi

    # A3: Bare Edit (no path scope)
    if echo ",$tools," | grep -qE ',\s*Edit\s*[,]'; then
      if [ "$level" = "BLOCKING" ]; then
        echo "  ::error::A3 [$skill_name] Bare Edit — unrestricted file editing"
        ((ERRORS++))
      else
        echo "  ::warning::A3 [$skill_name] Bare Edit — unrestricted file editing (local skill)"
        ((WARNINGS++))
      fi
    fi

    # A4: Read(.env*) or Read(**/secrets/*)
    if echo "$tools" | grep -qE 'Read\(\.env|Read\(\*\*/secrets'; then
      if [ "$level" = "BLOCKING" ]; then
        echo "  ::error::A4 [$skill_name] Read(.env*/secrets) — credential file access"
        ((ERRORS++))
      else
        echo "  ::warning::A4 [$skill_name] Read(.env*/secrets) — credential file access (local skill)"
        ((WARNINGS++))
      fi
    fi

    # A5: Bash(node:*), Bash(npx:*), Bash(npm install:*) — broad but may be justified
    if echo "$tools" | grep -qE 'Bash\(node:\*\)|Bash\(npx:\*\)|Bash\(npm install:\*\)'; then
      echo "  ::warning::A5 [$skill_name] Broad Bash scope (node/npx/npm install) — verify justified"
      ((WARNINGS++))
    fi
  done

  # A6: Hardcoded credentials in skill bodies
  for skill in "$skill_dir"/*/SKILL.md; do
    [ -f "$skill" ] || continue
    local skill_name
    skill_name=$(basename "$(dirname "$skill")")

    if grep -qE 'ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|AKIA[0-9A-Z]{16}|BEGIN.*PRIVATE KEY' "$skill" 2>/dev/null; then
      echo "  ::error::A6 [$skill_name] Hardcoded credentials detected in skill body"
      ((ERRORS++))
    fi
  done
}

# Scan distributed skills (BLOCKING)
if [ -d "$PLUGIN_ROOT/skills" ]; then
  check_skill_permissions "$PLUGIN_ROOT/skills" "BLOCKING"
fi

# Scan local/maintainer skills (ADVISORY)
if [ -d "$PLUGIN_ROOT/.claude/skills" ]; then
  check_skill_permissions "$PLUGIN_ROOT/.claude/skills" "ADVISORY"
fi

A_ERRORS=$ERRORS
A_WARNINGS=$WARNINGS
if [ $A_ERRORS -eq 0 ] && [ $A_WARNINGS -eq 0 ]; then
  echo "  ✓ All skill permissions comply with security standards"
fi
echo ""

# ═════════════════════════════════════════════════════════════
# Section B: Shell Script Safety
# ═════════════════════════════════════════════════════════════

echo "Section B: Shell Script Safety"
echo "────────────────────────────────────────────────────────"

B_START_ERRORS=$ERRORS
B_START_WARNINGS=$WARNINGS

for script in "$PLUGIN_ROOT"/scripts/*.sh "$PLUGIN_ROOT"/scripts/lib/*.sh; do
  [ -f "$script" ] || continue
  local_name="${script#$PLUGIN_ROOT/}"

  # B1: Missing set -euo pipefail
  if ! head -n 15 "$script" | grep -q 'set -euo pipefail'; then
    echo "  ::error::B1 [$local_name] Missing 'set -euo pipefail'"
    ((ERRORS++))
  fi

  # B2: eval usage (excluding comments)
  if grep -nE '^\s*eval\s|[;&|]\s*eval\s' "$script" 2>/dev/null | grep -vE '^\s*#' | grep -q 'eval'; then
    echo "  ::error::B2 [$local_name] 'eval' usage detected — command injection risk"
    ((ERRORS++))
  fi

  # B3: curl|sh or wget|sh patterns
  if grep -qE '(curl|wget)\s.*\|\s*(bash|sh|zsh)' "$script" 2>/dev/null; then
    echo "  ::error::B3 [$local_name] curl/wget piped to shell — remote code execution"
    ((ERRORS++))
  fi

  # B4: source of non-plugin files
  # Allow: source with $SCRIPT_DIR, $PLUGIN_DIR, $CLAUDE_PLUGIN_ROOT, ${SCRIPT_DIR}, relative ./
  if grep -nE '^\s*(source|\.)\ ' "$script" 2>/dev/null | grep -vE '#' | grep -vE 'SCRIPT_DIR|PLUGIN_DIR|PLUGIN_ROOT|dirname' | grep -q 'source\|^\.\s'; then
    # Only flag if there are source lines that don't reference plugin paths
    SOURCE_LINES=$(grep -nE '^\s*(source|\.)\ ' "$script" 2>/dev/null | grep -vE '#|SCRIPT_DIR|PLUGIN_DIR|PLUGIN_ROOT|dirname' | wc -l | tr -d ' ')
    if [ "$SOURCE_LINES" -gt 0 ]; then
      echo "  ::error::B4 [$local_name] 'source' of potentially non-plugin files"
      ((ERRORS++))
    fi
  fi

  # B5: chmod 777 (exclude comments, grep patterns, and echo/print lines)
  if grep -E 'chmod.*777' "$script" 2>/dev/null | grep -vE '^\s*#|grep|echo|BLOCKED' | grep -q 'chmod'; then
    echo "  ::error::B5 [$local_name] chmod 777 — overly permissive"
    ((ERRORS++))
  fi

  # B6: $IFS manipulation (exclude comments, grep patterns, and echo/print lines)
  if grep -E '\$IFS|\$\{IFS\}' "$script" 2>/dev/null | grep -vE '^\s*#|grep|echo|BLOCKED' | grep -q 'IFS'; then
    echo "  ::error::B6 [$local_name] \$IFS manipulation — injection vector"
    ((ERRORS++))
  fi

  # B7: PID-based temp files (advisory)
  if grep -qE '/tmp/.*\$\$' "$script" 2>/dev/null; then
    echo "  ::warning::B7 [$local_name] PID-based temp file — use mktemp instead"
    ((WARNINGS++))
  fi
done

if [ $ERRORS -eq $B_START_ERRORS ] && [ $WARNINGS -eq $B_START_WARNINGS ]; then
  echo "  ✓ All shell scripts comply with security standards"
fi
echo ""

# ═════════════════════════════════════════════════════════════
# Section C: Hook Safety
# ═════════════════════════════════════════════════════════════

echo "Section C: Hook Safety"
echo "────────────────────────────────────────────────────────"

C_START_ERRORS=$ERRORS

HOOKS_FILE="$PLUGIN_ROOT/hooks/hooks.json"
if [ -f "$HOOKS_FILE" ]; then
  # C1 + C2: Validate hook commands using python3
  HOOK_ISSUES=$(python3 -c "
import json, sys

with open('$HOOKS_FILE') as f:
    data = json.load(f)

issues = []
for event, matchers in data.get('hooks', {}).items():
    for matcher_obj in matchers:
        for hook in matcher_obj.get('hooks', []):
            cmd = hook.get('command', '')
            # C1: Must use static plugin paths
            if '\${CLAUDE_PLUGIN_ROOT}/scripts/' not in cmd and '\$CLAUDE_PLUGIN_ROOT/scripts/' not in cmd:
                issues.append(f'C1 [{event}] Hook command not using plugin scripts path: {cmd}')
            # C2: No user input variables
            for var in ['\$ARGUMENTS', '\$1', '\$2', '\$USER_INPUT', '\$QUERY']:
                if var in cmd:
                    issues.append(f'C2 [{event}] User input variable {var} in hook command: {cmd}')

for issue in issues:
    print(issue)
" 2>/dev/null)

  if [ -n "$HOOK_ISSUES" ]; then
    while IFS= read -r issue; do
      echo "  ::error::$issue"
      ((ERRORS++))
    done <<< "$HOOK_ISSUES"
  fi

  if [ $ERRORS -eq $C_START_ERRORS ]; then
    echo "  ✓ All hooks use static plugin paths, no user input in commands"
  fi
else
  echo "  ::warning::hooks/hooks.json not found"
  ((WARNINGS++))
fi
echo ""

# ═════════════════════════════════════════════════════════════
# Section D: Dangerous Patterns in Skills
# ═════════════════════════════════════════════════════════════

echo "Section D: Dangerous Patterns in Skills"
echo "────────────────────────────────────────────────────────"

D_START_ERRORS=$ERRORS
D_START_WARNINGS=$WARNINGS

for skill in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  local_name=$(basename "$(dirname "$skill")")

  # D1: rm -rf / or rm -rf ~
  if grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f\s+/' "$skill" 2>/dev/null; then
    echo "  ::error::D1 [$local_name] 'rm -rf /' pattern in skill body"
    ((ERRORS++))
  fi

  # D2: exec( — process execution (skip detection lists with multiple dangerous functions)
  if grep -E 'exec\(' "$skill" 2>/dev/null | grep -vE '(eval|assert|system|passthru|unserialize|shell_exec)' | grep -q 'exec('; then
    echo "  ::error::D2 [$local_name] 'exec()' in skill body"
    ((ERRORS++))
  fi

  # D3: General rm -rf (advisory — may be legitimate)
  if grep -qE 'rm\s+-rf\s' "$skill" 2>/dev/null && ! grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f\s+/' "$skill" 2>/dev/null; then
    echo "  ::warning::D3 [$local_name] 'rm -rf' usage — verify it's safe"
    ((WARNINGS++))
  fi
done

if [ $ERRORS -eq $D_START_ERRORS ] && [ $WARNINGS -eq $D_START_WARNINGS ]; then
  echo "  ✓ No dangerous patterns in distributed skills"
fi
echo ""

# ═════════════════════════════════════════════════════════════
# SUMMARY
# ═════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════"
echo "  Security Validation Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Blocking errors:     $ERRORS"
echo "  Advisory warnings:   $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo "✗ FAIL: $ERRORS security standard violations found"
  echo ""
  echo "Fix all blocking errors before proceeding."
  echo "Reference: docs/security-strategy.md"
  exit 1
fi

if [ "$STRICT_MODE" = "--strict" ] && [ $WARNINGS -gt 0 ]; then
  echo "✗ FAIL (strict mode): $WARNINGS advisory warnings treated as errors"
  echo ""
  echo "In strict mode (CI), all warnings must also be resolved."
  echo "Reference: docs/security-strategy.md"
  exit 1
fi

echo "✓ PASS: All security standards met"
if [ $WARNINGS -gt 0 ]; then
  echo "  ($WARNINGS advisory warnings — review recommended)"
fi
echo ""

exit 0
