---
name: to-jaan-roadmap-update
description: |
  [Internal] Maintain and sync the jaan.to development roadmap.
  Syncs git history, marks tasks done, creates version sections, validates links.
  Auto-triggers on: update roadmap, sync roadmap, release version, roadmap maintenance.
  Maps to: to-jaan-roadmap-update
allowed-tools: Read, Glob, Grep, Edit, Bash(git log:*), Bash(git tag:*), Bash(git diff:*), Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(git describe:*), Bash(git branch:*), Write(roadmaps/**)
argument-hint: "[mark \"<task>\" done <hash>] [release vX.Y.Z \"<summary>\"] [sync] [validate] [(no args)]"
---

# to-jaan-roadmap-update

> Automate roadmap maintenance: sync with git history, mark tasks done, manage releases, validate structure.

## Context Files

- `roadmaps/jaan-to/roadmap.md` - Current roadmap
- `CHANGELOG.md` - Release history
- `.claude-plugin/plugin.json` - Plugin version
- `.claude-plugin/marketplace.json` - Marketplace version
- `$JAAN_LEARN_DIR/to-jaan-roadmap-update.learn.md` - Past lessons (loaded in Pre-Execution)

## Input

**Command**: $ARGUMENTS

### Input Mode Detection

| Pattern | Mode | Description |
|---------|------|-------------|
| (no args) | `smart-default` | Scan git log since last tag, compare with roadmap, report gaps |
| `mark "<task>" done <hash>` | `mark` | Mark a specific task as complete with commit hash |
| `release vX.Y.Z "<summary>"` | `release` | Create version section + CHANGELOG entry + full atomic release |
| `sync` | `sync` | Full cross-reference: git history vs roadmap |
| `validate` | `validate` | Check all links, task file refs, version section completeness |

If no input provided, default to `smart-default` mode.
If input doesn't match any pattern, ask: "Which mode? [smart-default / mark / release / sync / validate]"

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/to-jaan-roadmap-update.learn.md`

If the file exists, apply its lessons throughout this execution.
If the file does not exist, continue without it.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for comparing git history with roadmap entries, fuzzy-matching commit messages to task descriptions, and determining phase boundaries.

## Step 1: Read Current State

Read all context files:
1. `roadmaps/jaan-to/roadmap.md` — Parse phases, overview table, all tasks
2. `CHANGELOG.md` — Parse all version entries
3. `.claude-plugin/plugin.json` — Current version
4. `.claude-plugin/marketplace.json` — Marketplace version

Extract:
- Overview table (phase → status mapping)
- All tasks with checked/unchecked status and any commit hashes
- All version section headings with their commit hashes
- All CHANGELOG entries with dates
- Current plugin version

## Step 2: Read Git State

```bash
git tag -l --sort=-version:refname
git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~20)..HEAD
git status --short
git branch --show-current
```

Extract:
- Latest tag (last released version)
- All commits since last tag
- Whether working tree is clean
- Current branch name (warn if not main for release mode)

## Step 3: Mode-Specific Analysis

### Mode: smart-default

1. Get commits since last tag
2. For each commit, search roadmap for matching task (keyword extraction + fuzzy match)
3. Identify:
   - **Unrecorded work**: commits matching unchecked roadmap tasks but not linked
   - **Orphan commits**: significant work (feat/fix/refactor) not in any roadmap task
   - **Stale tasks**: tasks marked done without commit hashes
4. Check overview table accuracy

Present report:
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

### Mode: mark

1. Search roadmap for the task text (fuzzy match: extract keywords, case-insensitive)
2. If exact match: prepare change
3. If multiple matches: list them, ask which one
4. If no match: "Task not found. Create it first with `/to-jaan-roadmap-add`?"
5. Validate commit hash exists: `git log --oneline -1 {hash}`
6. Prepare: `- [ ] {task}` → `- [x] {task} (\`{hash}\`)`

### Mode: release

1. Validate version format: `vN.N.N` (semver)
2. Validate version > current version in plugin.json
3. Check working tree is clean
4. Check current branch (warn if not main)
5. Scan commits since last tag:
   ```bash
   git log --oneline --no-merges $(git describe --tags --abbrev=0)..HEAD
   ```
6. Categorize by conventional commit type:
   - `feat:` → Added
   - `fix:` → Fixed
   - `docs:` → Documentation
   - `refactor:` → Changed
   - `test:` → Testing
7. Draft CHANGELOG entry (Keep a Changelog format)
8. Draft roadmap version section
9. Check if overview table needs status update
10. Prepare full atomic operation list:
    - CHANGELOG.md — new version entry
    - roadmaps/jaan-to/roadmap.md — version section + overview table
    - .claude-plugin/plugin.json — version bump
    - .claude-plugin/marketplace.json — version bump
    - Git commit: `release: {version} — {summary}`
    - Git tag: `{version}`

### Mode: sync

1. Get ALL tags with dates
2. For each version range (tag-to-tag), get commits
3. Cross-reference every commit against roadmap entries
4. Cross-reference every roadmap task against git history
5. Build comprehensive report:
   - Tasks marked done but commit hash doesn't exist
   - Tasks marked done without any commit hash
   - Commits not referenced in any task
   - Phase status mismatches in overview table
   - Missing version sections (tags without corresponding roadmap sections)

### Mode: validate

1. Parse all internal links in roadmap:
   - `[text](path)` — check file exists
   - `[text](tasks/file.md)` — check tasks/ files exist
   - `[text](../../docs/path.md)` — check relative paths resolve
2. Check CHANGELOG version reference links
3. Check overview table consistency (phase status vs actual task completion)
4. Check version section completeness (commit hash, bullet points, chronological order)
5. Check for orphan task files (in `tasks/` but not referenced from roadmap)

Present validation report:
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

# HARD STOP - Human Review Gate

### For smart-default:
Show sync report. Then use AskUserQuestion:
- Question: "Found {n} items to update. Apply changes?"
- Header: "Apply"
- Options:
  - "Yes" — Apply all changes
  - "No" — Cancel
  - "Selective" — Choose which changes to apply

### For mark:
```
Ready to Mark Task Done

Task:   {task text}
Phase:  {phase}
Commit: {hash} — {commit message}

Change: - [ ] {task} → - [x] {task} (`{hash}`)
```

Use AskUserQuestion:
- Question: "Mark this task as done?"
- Header: "Mark"
- Options:
  - "Yes" — Mark task done with commit hash
  - "No" — Cancel

### For release:
```
Release Preparation: {version}

CHANGELOG Entry (draft):
{changelog_draft}

Roadmap Version Section (draft):
{roadmap_section_draft}

Overview Table Changes:
{table_changes}

Full Atomic Operation:
1. Write CHANGELOG entry
2. Write roadmap version section + overview table
3. Update .claude-plugin/plugin.json version
4. Update .claude-plugin/marketplace.json version
5. Commit: release: {version} — {summary}
6. Tag: git tag {version}
7. (Optional) Push: git push origin main --tags
```

Use AskUserQuestion:
- Question: "Proceed with release {version}?"
- Header: "Release"
- Options:
  - "Yes" — Execute full atomic release
  - "No" — Cancel release
  - "Edit" — Let me revise the drafts first

### For sync:
Show comprehensive sync report. Then use AskUserQuestion:
- Question: "Apply {n} fixes?"
- Header: "Apply"
- Options:
  - "Yes" — Apply all fixes
  - "No" — Cancel
  - "Selective" — Choose which fixes to apply

### For validate:
Show validation report. If issues found, use AskUserQuestion:
- Question: "Fix {n} issues?"
- Header: "Fix"
- Options:
  - "Yes" — Fix all issues
  - "No" — Report only
  - "Selective" — Choose which issues to fix

If clean: "All checks passed."

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Update (Write Phase)

## Step 4: Apply Changes

### For smart-default / sync:

For each approved change:

**Mark tasks done:**
1. Read roadmap for exact line
2. Replace `- [ ] {task}` with `- [x] {task} (\`{hash}\`)`
3. Use Edit tool for precise changes

**Update overview table:**
1. Find overview table
2. Update phase status cells as needed

**Add missing version sections:**
1. Find correct insertion point (chronological within phase)
2. Insert using template

### For mark:

1. Read roadmap for exact line containing the task
2. Replace: `- [ ] {task}` → `- [x] {task} (\`{hash}\`)`
3. Check if all tasks in that phase are now done
4. If so, suggest updating overview table status

### For release:

Execute atomic operation in order:

**4.1: Write CHANGELOG entry**
- Insert new version entry after latest version
- Add link reference at bottom

**4.2: Write roadmap version section**
- Insert H3 version subsection in correct phase
- Add bullet points for changes
- Update overview table

**4.3: Update plugin.json**
- Update `"version"` field

**4.4: Update marketplace.json**
- Update version fields

**4.5: Commit**
```bash
git add CHANGELOG.md roadmaps/jaan-to/roadmap.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "release: {version} — {summary}"
```

**4.6: Tag**
```bash
git tag {version}
```

**4.7: Offer push**
Use AskUserQuestion:
- Question: "Push to remote with tags?"
- Header: "Push"
- Options:
  - "Yes" — Push commit and tags to origin
  - "No" — Skip push (local only)

### For validate (with fixes):

Apply fixes for each approved issue:
- Broken links: suggest correction, apply with Edit
- Overview table mismatches: update status cells
- Missing commit hashes: search git log for matching commit
- Orphan task files: suggest removal or adding reference

## Step 5: Post-Update Verification

After all writes:
1. Re-read modified files to verify changes
2. For release mode: verify plugin.json and marketplace.json versions match

## Step 6: Commit (non-release modes)

```bash
git add roadmaps/jaan-to/roadmap.md CHANGELOG.md
git commit -m "docs(roadmap): {mode-specific message}"
```

Commit messages by mode:
- smart-default: `docs(roadmap): Sync roadmap with git history ({n} tasks updated)`
- mark: `docs(roadmap): Mark "{task}" as done ({hash})`
- sync: `docs(roadmap): Full roadmap sync ({n} changes)`
- validate: `docs(roadmap): Fix roadmap validation issues ({n} fixes)`

## Step 7: Confirm

```
Roadmap Updated

Mode:    {mode}
Changes: {change_count}
Commit:  {hash}
```

---

## Error Handling

| Error | Message |
|-------|---------|
| No git repo | "Not a git repository. Roadmap update requires git history." |
| No tags | "No git tags found. Create first tag with `git tag v1.0.0` before syncing." |
| Dirty tree (release) | "Uncommitted changes detected. Commit or stash before releasing." |
| Version exists (release) | "Tag {version} already exists. Use a higher version number." |
| Task not found (mark) | "Task not found. Did you mean: {fuzzy matches}" |

## Trust Rules

1. **NEVER** modify files without user confirmation at HARD STOP
2. **ALWAYS** read current state before any writes
3. **PRESERVE** existing formatting and structure
4. **VALIDATE** commit hashes actually exist in git history
5. **ATOMIC** release operations: all-or-nothing
6. **PREVIEW** all changes before applying

## Definition of Done

- [ ] Current roadmap and git state analyzed
- [ ] Mode-specific analysis completed
- [ ] Changes previewed at HARD STOP
- [ ] User approved changes
- [ ] All modifications applied correctly
- [ ] Post-update verification passed
- [ ] Changes committed (if approved)
- [ ] User approved final result
