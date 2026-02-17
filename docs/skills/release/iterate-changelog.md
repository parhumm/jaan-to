---
title: "release-iterate-changelog"
sidebar_position: 2
doc_type: skill
created_date: 2026-02-09
updated_date: 2026-02-09
tags: [release, changelog, semver, conventional-commits, keep-a-changelog]
related: [roadmap-update]
---

# /jaan-to:release-iterate-changelog

> Generate user-facing changelogs with impact notes and support guidance from git history.

---

## What It Does

Analyzes git commits since the last tag, classifies them using Conventional Commits parsing and freeform heuristics, and generates a Keep a Changelog-formatted file with user impact assessment and support guidance.

The skill writes a single living `CHANGELOG.md` file that gets updated on each run — not versioned snapshots. It supports 5 input modes for different workflows.

---

## Quick Start

```bash
# Auto-generate from git history (most common)
/jaan-to:release-iterate-changelog

# Create a new changelog from scratch
/jaan-to:release-iterate-changelog create

# Promote Unreleased to a version
/jaan-to:release-iterate-changelog release v1.2.0

# Add a single entry manually
/jaan-to:release-iterate-changelog add "New dark mode toggle"

# Parse a list of changes
/jaan-to:release-iterate-changelog "Added export feature, fixed login timeout, removed legacy API"
```

---

## Input Modes

| Mode | Format | Description |
|------|--------|-------------|
| Auto-generate | (no args) | Analyze git commits since last tag |
| Create | `create` | Create a new CHANGELOG.md from scratch |
| Release | `release vX.Y.Z` | Promote [Unreleased] to versioned section |
| Add | `add "<description>"` | Add entry to [Unreleased] manually |
| From input | Free text | Parse provided text into changelog format |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Project name | `create` mode | Header for new changelog |
| Repository URL | `create` mode | Comparison links in footer |
| Initial version | `create` mode | First version entry |

In `auto-generate` mode, the skill works without questions — it reads git history directly.

---

## How It Classifies Changes

### Conventional Commits (tried first)

Commits matching `type(scope): description` are mapped automatically:

| Commit Type | Changelog Category |
|-------------|-------------------|
| `feat` | Added |
| `fix` | Fixed |
| `feat!` / BREAKING CHANGE | Changed or Removed |
| `perf` | Changed |
| `security` | Security |
| `deprecate` | Deprecated |

Commits like `docs`, `test`, `ci`, `chore` are filtered as non-user-facing.

### Freeform Commits (fallback)

For non-conventional commits, the skill uses:
1. Keyword matching ("add", "fix", "remove", etc.)
2. File path analysis (new files → Added, deleted → Removed)
3. Diff statistics (small patch → Fixed, large change → Changed)
4. LLM classification for ambiguous cases

---

## Output

**Path**: `$JAAN_OUTPUTS_DIR/CHANGELOG.md`

Follows [Keep a Changelog](https://keepachangelog.com/) format with 6 standard change types: Added, Changed, Deprecated, Removed, Fixed, Security.

The output also includes:

- **User Impact Notes** — High/Medium/Low impact classification per change
- **Support Guidance** — FAQ entries, migration steps, known issues
- **Skipped Commits** — Filtered non-user-facing commits with rationale

---

## Example

**Input**:
```
/jaan-to:release-iterate-changelog
```

**Git history analyzed** (5 commits since `v1.1.0`):
```
feat(auth): add OAuth2 login support
fix(api): prevent race condition in request handler
docs: update README with new API endpoints
chore: bump dependencies
perf: optimize dashboard query by 40%
```

**Draft presented at HARD STOP**:
```
Suggested Version: 1.2.0 (MINOR — new feature added)

### Added
- OAuth2 login support for third-party authentication

### Changed
- Dashboard query optimized, reducing load time by 40%

### Fixed
- Race condition in API request handler that caused intermittent failures

Skipped: 2 commits (docs-only, chore)
```

**Written to**: `$JAAN_OUTPUTS_DIR/CHANGELOG.md`

---

## Tips

- Run with no arguments for the most common workflow — auto-generate from git
- Use `release vX.Y.Z` after accumulating entries in [Unreleased]
- The skill suggests a SemVer bump based on change types — review it before accepting
- Skipped commits are tracked transparently so nothing is silently lost
- Feed the output into `/jaan-to:support-help-article` for user documentation

---

## Chain Context

This skill sits in the release iteration chain:

```
release-iterate-top-fixes → release-iterate-changelog → roadmap-update → support-help-article
```

After writing the changelog, the skill triggers `/jaan-to:roadmap-update` to sync the roadmap. The changelog output also feeds support documentation downstream.

---

## Learning

This skill reads from:
```
$JAAN_LEARN_DIR/jaan-to:release-iterate-changelog.learn.md
```

Add feedback:
```
/jaan-to:learn-add release-iterate-changelog "Always include migration steps for breaking changes"
```

---

## Related Skills

- [/jaan-to:roadmap-update](../core/roadmap-update.md) — Manages roadmap and releases with atomic version bumps

---

## Technical Details

- **Logical Name**: release-iterate-changelog
- **Command**: `/jaan-to:release-iterate-changelog`
- **Role**: release
- **Output**: `$JAAN_OUTPUTS_DIR/CHANGELOG.md` (single living file)
- **Standards**: Keep a Changelog 1.1.0, SemVer 2.0.0, Conventional Commits 1.0.0
- **Research**: `$JAAN_OUTPUTS_DIR/research/66-release-iterate-changelog.md`
