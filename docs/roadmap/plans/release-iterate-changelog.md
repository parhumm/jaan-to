# Plan: Create `release-iterate-changelog` Skill

## Context

The `release-iterate-changelog` skill is a planned Quick Win in Phase 6 of the jaan.to roadmap. It sits in the release iteration chain: `release-iterate-top-fixes → release-iterate-changelog → support-help-article`. The skill generates user-facing changelogs with impact notes and support guidance, using git history analysis and the Keep a Changelog standard.

Comprehensive research already exists at `jaan-to/outputs/research/66-release-iterate-changelog.md` covering Keep a Changelog, SemVer, Conventional Commits, commit analysis pipeline, and 6 skill scenarios.

**No duplicate skills exist** — this is the first release-related skill being implemented.

---

## Files to Create

| File | Location | Purpose |
|------|----------|---------|
| SKILL.md | `skills/release-iterate-changelog/SKILL.md` | Main skill definition |
| LEARN.md | `skills/release-iterate-changelog/LEARN.md` | Plugin-side learning seed |
| template.md | `skills/release-iterate-changelog/template.md` | Output template |

## Files to Modify

| File | Change |
|------|--------|
| `scripts/seeds/config.md` | Add skill to Available Skills table |

---

## SKILL.md Design

### Frontmatter

```yaml
---
name: release-iterate-changelog
description: "Generate changelog with user impact notes and support guidance from git history or changes."
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git tag:*), Bash(git diff:*), Bash(git describe:*), Bash(git status:*), Write($JAAN_OUTPUTS_DIR/CHANGELOG.md), Edit($JAAN_OUTPUTS_DIR/CHANGELOG.md), Edit(jaan-to/config/settings.yaml)
argument-hint: "[(no args) | create | release vX.Y.Z | add \"<description>\"]"
---
```

**Output**: Single file at `$JAAN_OUTPUTS_DIR/CHANGELOG.md` (not ID-based folders).
This is a living document that gets updated on each run — not a versioned report snapshot.

### Input Mode Detection

| Pattern | Mode | Description |
|---------|------|-------------|
| (no args) | `auto-generate` | Analyze git commits since last tag, generate changelog draft |
| `create` | `create` | Create a new CHANGELOG.md from scratch |
| `release vX.Y.Z` | `release` | Promote [Unreleased] to versioned section, create report |
| `add "<description>"` | `add` | Add entry to [Unreleased] section manually |
| Other text | `from-input` | Parse provided changes list into changelog format |

### Phase 1 Workflow (Analysis)

1. **Pre-Execution**: Read LEARN.md + Language Settings (standard block)
2. **Step 1: Detect Mode** — Parse `$ARGUMENTS` to determine mode
3. **Step 2: Gather Context** — Per mode:
   - `auto-generate`: Run git commands to collect commits since last tag, parse with commit analysis pipeline (Conventional Commits regex first, then freeform heuristics)
   - `create`: Ask project name, repo URL, initial version
   - `release`: Read existing CHANGELOG.md, validate version against SemVer
   - `add`: Classify change type (Added/Changed/Fixed/etc.)
   - `from-input`: Parse provided text, classify entries
4. **Step 3: Classify & Group** — For each commit/change:
   - Apply Conventional Commits type mapping
   - For freeform: use keyword patterns + file path heuristics + LLM classification
   - Group into 6 categories: Added, Changed, Deprecated, Removed, Fixed, Security
   - Filter noise (docs-only, test-only, CI, chores)
5. **Step 4: Generate Draft** — Create human-friendly entries, suggest SemVer bump
6. **Step 5: User Impact Analysis** — For each change category, assess:
   - User-facing impact (high/medium/low/none)
   - Who is affected (all users, segment, internal)
   - Support implications (FAQ updates, known issues, migration steps)

### HARD STOP

Present draft changelog with:
- Categorized changes
- Suggested version number
- User impact summary
- Support guidance preview

### Phase 2 Workflow (Generation)

1. **Step 6: Write/Update `$JAAN_OUTPUTS_DIR/CHANGELOG.md`** — Using template.md
   - `create` mode: Write new file from template
   - `auto-generate` / `from-input`: Edit existing file — insert entries into [Unreleased] section
   - `release` mode: Promote [Unreleased] to versioned section, update comparison links
   - `add` mode: Append entry under correct change type in [Unreleased]
2. **Step 7: Quality Validation** — Run validation rules
3. **Step 8: Capture Feedback**

### Quality Checks

From research validation rules:
- [ ] Version number is valid SemVer (if applicable)
- [ ] Date is ISO 8601 (YYYY-MM-DD)
- [ ] Changes use only standard 6 types
- [ ] Breaking changes flagged for MAJOR bump
- [ ] Deprecations flagged for at least MINOR bump
- [ ] No duplicate version entries
- [ ] [Unreleased] section preserved
- [ ] Entries are user-facing (not raw commit dumps)
- [ ] User impact assessed for each category
- [ ] Support guidance included

### Definition of Done

- [ ] Changes collected and classified
- [ ] Changelog draft reviewed by user
- [ ] `$JAAN_OUTPUTS_DIR/CHANGELOG.md` written/updated
- [ ] Quality checks pass
- [ ] User approved final result

---

## template.md Design

```markdown
# {{title}}

> Generated by jaan.to | {{date}}

---

## Executive Summary

{1-2 sentence summary of changes and their significance}

---

## Version Information

| Field | Value |
|-------|-------|
| Version | {{version}} |
| Date | {{date}} |
| Commits Analyzed | {{commit_count}} |
| SemVer Suggestion | {{semver_suggestion}} |
| SemVer Rationale | {{semver_rationale}} |

---

## Changelog

### Added
{new features list}

### Changed
{modifications list}

### Deprecated
{deprecations list}

### Removed
{removals list}

### Fixed
{bug fixes list}

### Security
{security fixes list}

---

## User Impact Notes

{For each change category: who is affected, severity, migration needs}

### High Impact
{changes requiring user attention or action}

### Medium Impact
{notable changes users should know about}

### Low Impact
{minor improvements, no action needed}

---

## Internal Notes (Optional)

{Technical details, refactoring notes, debt addressed — not for end users}

---

## Support Guidance

{FAQ entries, known issues, migration steps, suggested help article topics}
{This section feeds into support-help-article skill}

---

## Skipped Commits

{Commits filtered out as non-user-facing, with rationale}

---

## Metadata

| Field | Value |
|-------|-------|
| Generated | {{date}} |
| Skill | release-iterate-changelog |
| Source | {{source_mode}} |
| Status | Draft |
```

---

## LEARN.md Seed

Initial lessons from research:
- **Better Questions**: Ask about audience (end-users vs developers), release cadence, existing changelog conventions
- **Edge Cases**: No tags exist yet, merge commits, squash merges, monorepo with multiple packages, mixed conventional + freeform commits
- **Workflow**: Try Conventional Commits regex first before freeform heuristics; filter noise commits before classification
- **Common Mistakes**: Don't dump raw commit logs; always write human-friendly entries; don't skip [Unreleased] section

---

## Config Catalog Update

Add to `scripts/seeds/config.md` Available Skills table:

```
| release-iterate-changelog | `/release-iterate-changelog` | Generate changelog with user impact notes and support guidance |
```

---

## Implementation Steps

1. Create git branch: `skill/release-iterate-changelog` from `dev`
2. Write `skills/release-iterate-changelog/SKILL.md` (full v3.0.0-compliant skill)
3. Write `skills/release-iterate-changelog/LEARN.md` (seed from research)
4. Write `skills/release-iterate-changelog/template.md` (output template)
5. Edit `scripts/seeds/config.md` (add to catalog)
6. Validate against `docs/extending/create-skill.md` spec
7. Run automated path scan (no hardcoded `jaan-to/` paths)
8. Commit to branch
9. User testing
10. Create PR to `dev`

---

## Verification

1. **Manual test**: Run `/release-iterate-changelog` in a git repo with commits — verify it analyzes commits and writes to `$JAAN_OUTPUTS_DIR/CHANGELOG.md`
2. **Mode test**: Test each input mode (`create`, `release v1.0.0`, `add "New feature"`, no args)
3. **Output check**: Verify `$JAAN_OUTPUTS_DIR/CHANGELOG.md` follows Keep a Changelog format
4. **Validation**: Run `/skill-update release-iterate-changelog` for v3.0.0 compliance
