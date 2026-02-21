# Lessons: release-iterate-changelog

> Last updated: 2026-02-09

Accumulated lessons from past executions. Read this before generating changelogs to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during changelog generation:

### Audience & Conventions (2026-02-09)

**Context**: Seeded from research — different projects have different changelog audiences and conventions.

**What to ask**:
- Who is the primary audience? (end-users vs developers vs both)
- What is the release cadence? (weekly, bi-weekly, per-feature)
- Are there existing changelog conventions to follow?
- Should internal/refactoring changes be included or filtered?

## Edge Cases

Special cases to check and handle:

### No Tags Exist (2026-02-09)

**Context**: Seeded from research — new projects may have no git tags yet.

**What to do**:
- Fall back to analyzing all commits from the initial commit
- Suggest creating a first tag: `git tag v0.1.0`
- Warn that the changelog may be very long without a tag boundary

### Mixed Commit Styles (2026-02-09)

**Context**: Seeded from research — repos may mix Conventional Commits with freeform messages.

**What to do**:
- Try Conventional Commits regex first on each commit
- Fall back to keyword heuristics + file path analysis for non-matching commits
- Use LLM classification as final fallback for ambiguous commits
- Never skip a commit silently — classify or explicitly list as skipped

### Merge & Squash Commits (2026-02-09)

**Context**: Seeded from research — merge commits and squash merges need special handling.

**What to do**:
- Use `--no-merges` flag to skip merge commits by default
- For squash merges, the squashed message often contains the real description
- If a merge commit has a meaningful message, include it

### Monorepo with Multiple Packages (2026-02-09)

**Context**: Seeded from research — monorepos may need per-package changelogs.

**What to do**:
- Detect monorepo structure (multiple package.json, go.mod, etc.)
- Ask if changelog should be project-wide or package-scoped
- Use file paths to group changes by package if scoped

## Workflow

Process improvements learned from past runs:

### Classification Pipeline Order (2026-02-09)

**Context**: Seeded from research — the order of classification signals matters for accuracy.

**What to do**:
1. Try Conventional Commits regex first (fastest, most reliable)
2. Apply keyword pattern matching second
3. Use file path heuristics third
4. Use LLM classification as final fallback
5. Filter noise commits (docs-only, test-only, CI) before classification

**What NOT to do**:
- Don't skip the regex step even if most commits are freeform
- Don't rely solely on keywords — combine multiple signals

## Common Mistakes

Things to avoid based on research:

### Never Dump Raw Commit Logs (2026-02-09)

**Context**: Seeded from research — the #1 anti-pattern in changelogs.

**What NOT to do**:
- Don't copy commit messages verbatim into the changelog
- Don't include commit hashes in user-facing entries
- Don't include merge commit boilerplate

**What to do**:
- Rewrite every entry in user-friendly language
- Start entries with action verbs
- Focus on what changed for the user, not how it was implemented

### Always Preserve [Unreleased] Section (2026-02-09)

**Context**: Seeded from research — the [Unreleased] section must always exist.

**What NOT to do**:
- Don't delete the [Unreleased] section when releasing
- Don't forget to clear entries from [Unreleased] after promoting to a version

**What to do**:
- After release mode, keep `## [Unreleased]` header with empty content
- Move entries to the new versioned section, don't copy (avoid duplicates)
