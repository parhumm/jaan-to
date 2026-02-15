#!/bin/bash
# validate-release-readiness.sh — Git state, docs sync, and version detection
#
# Validates that the repository is ready for release preparation:
# - Working tree clean
# - On correct branch
# - Documentation in sync
# - Version detection and suggestion
#
# Usage: bash .claude/scripts/validate-release-readiness.sh
# Exit 0 if ready, exit 1 if not ready

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ERRORS=0
WARNINGS=0

echo "═══════════════════════════════════════════════════════════"
echo "  Release Readiness Validation"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# Git State Validation
# ─────────────────────────────────────────────────────────────

echo "Git State"
echo "────────────────────────────────────────────────────────"

# Check working tree is clean
UNTRACKED=$(git status --porcelain 2>/dev/null || echo "ERROR")

if [ "$UNTRACKED" == "ERROR" ]; then
  echo "  ::error::Not a git repository"
  ((ERRORS++))
elif [ -z "$UNTRACKED" ]; then
  echo "  ✓ Working tree clean (0 uncommitted changes)"
else
  CHANGE_COUNT=$(echo "$UNTRACKED" | wc -l | tr -d ' ')
  echo "  ::error::Working tree not clean ($CHANGE_COUNT uncommitted changes)"
  echo ""
  echo "  Uncommitted changes:"
  echo "$UNTRACKED" | head -10
  echo ""
  echo "  Fix: Commit or stash changes before running release workflow"
  echo "       git add . && git commit -m \"...\""
  echo "       # OR"
  echo "       git stash push -m \"WIP before release\""
  ((ERRORS++))
fi

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "  Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "dev" ] && [ "$CURRENT_BRANCH" != "main" ]; then
  echo "  ::warning::Not on dev or main branch"
  echo "           Releases typically prepare from 'dev' branch"
  ((WARNINGS++))
fi

# Check remotes up to date
git fetch --quiet 2>/dev/null || echo "  ::warning::Could not fetch from remote"

BEHIND=$(git rev-list HEAD..origin/"$CURRENT_BRANCH" --count 2>/dev/null || echo "0")
AHEAD=$(git rev-list origin/"$CURRENT_BRANCH"..HEAD --count 2>/dev/null || echo "0")

if [ "$BEHIND" -gt 0 ]; then
  echo "  ::warning::Branch is $BEHIND commits behind origin/$CURRENT_BRANCH"
  echo "           Run: git pull origin $CURRENT_BRANCH"
  ((WARNINGS++))
fi

if [ "$AHEAD" -gt 0 ]; then
  echo "  ℹ Branch is $AHEAD commits ahead of origin/$CURRENT_BRANCH"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# Documentation Sync Check
# ─────────────────────────────────────────────────────────────

echo "Documentation Sync"
echo "────────────────────────────────────────────────────────"

# Check if docs-sync-check.sh exists and run it
if [ -f "$PLUGIN_ROOT/scripts/docs-sync-check.sh" ]; then
  if bash "$PLUGIN_ROOT/scripts/docs-sync-check.sh" > /dev/null 2>&1; then
    echo "  ✓ Documentation in sync (0 stale files)"
  else
    echo "  ::warning::Documentation may be stale"
    echo "           Run: /jaan-to:docs-update --fix"
    ((WARNINGS++))
  fi
else
  echo "  ℹ No docs-sync-check.sh (skipping doc validation)"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# Version Detection & CHANGELOG Validation
# ─────────────────────────────────────────────────────────────

echo "Version & CHANGELOG"
echo "────────────────────────────────────────────────────────"

# Parse current version from plugin.json
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")
echo "  Current version: $CURRENT_VERSION"

# Check if CHANGELOG.md exists
if [ ! -f "$PLUGIN_ROOT/CHANGELOG.md" ]; then
  echo "  ::error::CHANGELOG.md not found"
  ((ERRORS++))
else
  # Count [Unreleased] entries
  UNRELEASED_COUNT=$(sed -n '/^## \[Unreleased\]/,/^## \[/p' "$PLUGIN_ROOT/CHANGELOG.md" | grep -c '^- ' || echo "0")

  if [ "$UNRELEASED_COUNT" -eq 0 ]; then
    echo "  ::warning::[Unreleased] section is empty"
    echo "           Add changelog entries or run: /jaan-to:release-iterate-changelog auto-generate"
    ((WARNINGS++))
  else
    echo "  ✓ [Unreleased] section: $UNRELEASED_COUNT entries"
  fi

  # Check changelog format (Keep a Changelog style)
  if grep -q "^## \[Unreleased\]" "$PLUGIN_ROOT/CHANGELOG.md"; then
    echo "  ✓ Keep a Changelog format"
  else
    echo "  ::warning::CHANGELOG.md doesn't follow Keep a Changelog format"
    ((WARNINGS++))
  fi
fi

# Suggest next version based on conventional commits
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
COMMITS_SINCE=$(git log --oneline --no-merges "$LAST_TAG..HEAD" 2>/dev/null || echo "")

if [ -z "$COMMITS_SINCE" ]; then
  echo "  ℹ No commits since $LAST_TAG"
  SUGGESTED_BUMP="patch"
else
  COMMIT_COUNT=$(echo "$COMMITS_SINCE" | wc -l | tr -d ' ')
  echo "  ℹ $COMMIT_COUNT commits since $LAST_TAG"

  # Determine bump type from conventional commit prefixes
  if echo "$COMMITS_SINCE" | grep -qi "BREAKING\|breaking:"; then
    SUGGESTED_BUMP="major"
  elif echo "$COMMITS_SINCE" | grep -qi "^feat"; then
    SUGGESTED_BUMP="minor"
  else
    SUGGESTED_BUMP="patch"
  fi
fi

# Calculate suggested version
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
CURRENT_PATCH=$(echo "$CURRENT_VERSION" | cut -d. -f3)

case "$SUGGESTED_BUMP" in
  major)
    SUGGESTED_VERSION="$((CURRENT_MAJOR + 1)).0.0"
    ;;
  minor)
    SUGGESTED_VERSION="$CURRENT_MAJOR.$((CURRENT_MINOR + 1)).0"
    ;;
  patch)
    SUGGESTED_VERSION="$CURRENT_MAJOR.$CURRENT_MINOR.$((CURRENT_PATCH + 1))"
    ;;
esac

echo "  → Suggested next version: $SUGGESTED_VERSION ($SUGGESTED_BUMP bump)"

# Check if suggested version tag already exists
if git tag -l "v$SUGGESTED_VERSION" | grep -q "v$SUGGESTED_VERSION"; then
  echo "  ::error::Tag v$SUGGESTED_VERSION already exists"
  echo "           Use a different version or delete tag: git tag -d v$SUGGESTED_VERSION"
  ((ERRORS++))
fi

echo ""

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════"
echo "  Release Readiness Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Current:   $CURRENT_VERSION"
echo "  Suggested: $SUGGESTED_VERSION ($SUGGESTED_BUMP bump)"
echo ""
echo "  Warnings: $WARNINGS"
echo "  Errors:   $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo "✗ NOT READY: $ERRORS blocking errors found"
  echo ""
  echo "Fix errors before proceeding with release preparation."
  exit 1
fi

if [ $WARNINGS -gt 0 ]; then
  echo "⚠ READY with warnings: $WARNINGS advisory issues"
  echo ""
  echo "Consider addressing warnings before release."
else
  echo "✓ READY: All checks passed"
  echo ""
fi

exit 0