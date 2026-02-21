# roadmap-update — Reference Material

> Extracted from `skills/roadmap-update/SKILL.md` for token optimization.
> Contains report templates, error handling, and trust rules.

---

## Smart-Default Report Template

```
# Roadmap Sync Report
**Last tag:** {tag} | **Commits since:** {n} | **Date:** {today}

## Unrecorded Work (commits matching unchecked tasks)
| Commit | Message | Probable Task |
|--------|---------|---------------|

## Orphan Commits (no roadmap task)
| Commit | Message | Suggested Phase |
|--------|---------|-----------------|

## Tasks Without Commit Hashes
| Task | Phase | Status |
|------|-------|--------|

## Overview Table Accuracy
| Phase | Table Status | Actual Status |
|-------|-------------|---------------|
```

---

## Validate Report Template

```
# Roadmap Validation Report
**Date:** {today} | **Issues:** {count}

## Link Validation
| Link | Location | Status |
|------|----------|--------|

## Overview Table
| Phase | Table Status | Actual Status | Match |
|-------|-------------|---------------|-------|

## Version Sections
| Version | Has Hash | Has Content | In CHANGELOG |
|---------|----------|-------------|--------------|

## Task File Cross-References
| File | Referenced in Roadmap | Exists |
|------|----------------------|--------|
```

---

## Release HARD STOP Preview Template

```
Release Preparation: {version}
Branch: {current_branch}

CHANGELOG Entry (draft):
{changelog_draft}

Unreleased Section After Release (CHANGELOG):
{cleared_unreleased_changelog}

Roadmap Version Section (draft):
{roadmap_section_draft}

Unreleased Section After Release (Roadmap):
{cleared_unreleased_roadmap}

Overview Table Changes:
{table_changes}

Full Atomic Operation:
1. Write CHANGELOG entry + clear released items from [Unreleased]
2. Write roadmap version section + clear released items from Unreleased + overview table
3. Update .claude-plugin/plugin.json version
4. Update .claude-plugin/marketplace.json version
5. Commit: release: {version} — {summary}
6. Tag: git tag {version}
7. Push and merge:
   - (If on main) git push origin main --tags
   - (If on feature branch) Push branch → checkout main → merge → push main --tags
```

---

## Step 8: Check Release Need (Post-Update)

**For all non-release modes** (smart-default, mark, sync, validate):

After successful update, check if accumulated work warrants a release.

### 8.1: Detect Release-Worthy Changes

Read recent commits since last tag:
```bash
git log --oneline $(git describe --tags --abbrev=0)..HEAD
```

Count by type:
- `feat:` commits → Features added
- `fix:` commits → Bugs fixed
- `docs:` commits → Documentation only
- `refactor:` commits → Code changes

Based on commit types, suggest semver bump:
- `feat:` commits → Minor version bump (X.Y.0 → X.(Y+1).0)
- Only `fix:` commits → Patch version bump (X.Y.Z → X.Y.(Z+1))
- `BREAKING:` in commit body → Major version bump (X.Y.Z → (X+1).0.0)

### 8.2: Suggest Release

If **any** of these conditions are true:
- ≥ 1 `feat:` commit (new feature)
- ≥ 3 `fix:` commits (multiple bug fixes)
- ≥ 5 commits total since last tag
- User explicitly marked a "Release X.Y.Z" task as done

Show suggestion:
```
Release Suggestion

Since last tag ({{last_tag}}):
- Features: {{feat_count}} feat: commits
- Bug fixes: {{fix_count}} fix: commits
- Other: {{other_count}} commits
- Total: {{total_count}} commits

Suggested version: {{suggested_version}}
(Current: {{current_version}}, Reason: {{reason}})

This work may warrant a release.
```

> "Create a release now? [y/n]"

### 8.3: Guide Release Creation

If "y":
> "Invoke release mode with version {{suggested_version}}? [y/n/custom]"
> - **y** — Use suggested version
> - **n** — Skip release for now
> - **custom** — Enter different version

If "y" or "custom":
1. Get version (use suggested or ask for custom)
2. Ask for summary: "One-line release summary: "
3. Re-invoke: `/jaan-to:roadmap-update release {{version}} "{{summary}}"`

If "n":
> "Skipped release. Run this command when ready:"
> `/jaan-to:roadmap-update release vX.Y.Z "summary"`

**Skip this step entirely if in release mode** (prevents recursion).

---

## Error Handling

| Error | Message |
|-------|---------|
| No git repo | "Not a git repository. Roadmap update requires git history." |
| No tags | "No git tags found. Create first tag with `git tag v1.0.0` before syncing." |
| Dirty tree (release) | "Uncommitted changes detected. Commit or stash before releasing." |
| Version exists (release) | "Tag {version} already exists. Use a higher version number." |
| Task not found (mark) | "Task not found. Did you mean: {fuzzy matches}" |

---

## Trust Rules

1. **NEVER** modify files without user confirmation at HARD STOP
2. **ALWAYS** read current state before any writes
3. **PRESERVE** existing formatting and structure
4. **VALIDATE** commit hashes actually exist in git history
5. **ATOMIC** release operations: all-or-nothing
6. **PREVIEW** all changes before applying
