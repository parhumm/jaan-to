---
name: roadmap-update
description: "[Internal] Maintain and sync the jaan.to development roadmap."
allowed-tools: Read, Glob, Grep, Edit, Bash(git log:*), Bash(git tag:*), Bash(git diff:*), Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(git describe:*), Bash(git branch:*), Bash(git push:*), Bash(git checkout:*), Bash(git merge:*), Write(docs/roadmap/**)
argument-hint: "[mark \"<task>\" done <hash>] [release vX.Y.Z \"<summary>\"] [sync] [validate] [(no args)]"
disable-model-invocation: true
---

# roadmap-update

> Automate roadmap maintenance: sync with git history, mark tasks done, manage releases, validate structure.

## Context Files

- `docs/roadmap/roadmap.md` - Current roadmap
- `CHANGELOG.md` - Release history
- `.claude-plugin/plugin.json` - Plugin version
- `.claude-plugin/marketplace.json` - Marketplace version
- `$JAAN_LEARN_DIR/jaan-to:roadmap-update.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

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

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `roadmap-update`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_roadmap-update`

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for comparing git history with roadmap entries, fuzzy-matching commit messages to task descriptions, and determining phase boundaries.

## Step 1: Read Current State

Read all context files:
1. `docs/roadmap/roadmap.md` — Parse phases, overview table, all tasks
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

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Smart-Default Report Template" for the sync report format.

Present the sync report.

### Mode: mark

1. Search roadmap for the task text (fuzzy match: extract keywords, case-insensitive)
2. If exact match: prepare change
3. If multiple matches: list them, ask which one
4. If no match: "Task not found. Create it first with `/jaan-to:roadmap-add`?"
5. Validate commit hash exists: `git log --oneline -1 {hash}`
6. Prepare: `- [ ] {task}` → `- [x] {task} (\`{hash}\`)`

### Mode: release

1. Validate version format: `vN.N.N` (semver)
2. Validate version:
   - New version semver >= current version
   - Example: `3.15.0` → `3.16.0` ✓
   - Example: `3.15.0` → `3.15.1` ✓ (patch release)
3. Check working tree is clean
4. Check current branch:
   - If on main: standard release flow
   - If on feature branch: note branch name for merge flow (Step 4.7)
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
7. Parse Unreleased sections:
   a. **Roadmap** (`## Unreleased`): Extract all bullet items with commit hashes
   b. **CHANGELOG** (`## [Unreleased]`): Extract all sub-sections (Added, Changed, Fixed, etc.)
   c. Cross-reference Unreleased items with commits since last tag — items matching this release go into the new version entry; `### Planned` items stay in Unreleased
8. Draft CHANGELOG entry (Keep a Changelog format):
   - Incorporate matching items from CHANGELOG `[Unreleased]` section
   - Incorporate categorized commits not already covered by Unreleased items
   - Draft cleared `[Unreleased]` section (keep `## [Unreleased]` header + `### Planned` sub-section, remove released items)
9. Draft roadmap version section:
   - Incorporate items from roadmap `## Unreleased` into the new `### {version}` subsection
   - Draft cleared `## Unreleased` section (keep header, remove released items)
10. Check if overview table needs status update
11. Prepare full atomic operation list:
    - CHANGELOG.md — new version entry + cleared Unreleased section
    - docs/roadmap/roadmap.md — version section + cleared Unreleased + overview table
    - .claude-plugin/plugin.json — version bump
    - .claude-plugin/marketplace.json — version bump
    - Git commit: `release: {version} — {summary}`
    - Git tag: `{version}`
    - (If on feature branch) Push branch, checkout main, merge, push main with tags

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

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Validate Report Template" for the validation report format.

Present the validation report.

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

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Release HARD STOP Preview Template" for the full preview format.

Present the release preparation preview.

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
- Insert new version entry after `## [Unreleased]` section (before the previous latest version)
- Add link reference at bottom of file
- Clear released items from `## [Unreleased]` section:
  - Keep `## [Unreleased]` header
  - Keep `### Planned` sub-section (forward-looking items)
  - Remove `### Added`, `### Changed`, `### Fixed` etc. sub-sections whose items are now in the new version entry

**4.2: Write roadmap version section**
- Insert H3 version subsection in correct phase section
- Add bullet points for changes
- Clear released items from `## Unreleased` section:
  - Keep `## Unreleased` header and `---` separator
  - Remove bullet items that were incorporated into the new version section
  - If all items were released, leave the section with just the header
- Update overview table if needed

**4.3: Update plugin.json**
- Update `"version"` field

**4.4: Update marketplace.json**
- Update top-level `"version"` field and `plugins[0].version` field

**4.5: Commit**
```bash
git add CHANGELOG.md docs/roadmap/roadmap.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "release: {version} — {summary}"
```

**4.6: Tag**
```bash
git tag {version}
```

**4.7: Push and merge**

Detect current branch:
```bash
git branch --show-current
```

**If on main:**

Use AskUserQuestion:
- Question: "Push to remote with tags?"
- Header: "Push"
- Options:
  - "Yes" — Push commit and tags to origin
  - "No" — Skip push (local only)

If "Yes":
```bash
git push origin main --tags
```

**If on feature branch:**

Use AskUserQuestion:
- Question: "Push {branch}, merge to main, and push with tags?"
- Header: "Merge & Push"
- Options:
  - "Yes" — Push branch, merge to main, push main with tags
  - "Push only" — Push current branch only (merge manually later)
  - "No" — Skip push (local only)

If "Yes":
```bash
git push origin {branch}
git checkout main
git merge {branch}
git push origin main --tags
```

If "Push only":
```bash
git push origin {branch} --tags
```

**4.8: Sync dev and bump to next version**

After successful release on main, sync dev and bump to next version:

```
Release Complete: {version}

Next: Sync dev branch and bump to {next_version}?

This will:
  git checkout dev
  git merge main
  ./scripts/bump-version.sh {next_version}
  git commit -m "chore: bump version to {next_version}"
  git push origin dev
```

Use AskUserQuestion:
- Question: "Sync dev and bump to {next_version}?"
- Header: "Bump Dev"
- Options:
  - "Yes" — Checkout dev, merge main, bump version, push
  - "No" — Skip (do manually later)

If "Yes":
```bash
git checkout dev
git merge main
./scripts/bump-version.sh {next_version}
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to {next_version}"
git push origin dev
```

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
git add docs/roadmap/roadmap.md CHANGELOG.md
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

Checking if release is warranted...
```

---

## Step 8: Check Release Need

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Step 8: Check Release Need (Post-Update)" for the full release detection logic (8.1), suggestion format (8.2), and guide creation flow (8.3).

**Skip this step entirely if in release mode** (prevents recursion).

---

## Error Handling

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Error Handling" for the error message table.

## Trust Rules

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/roadmap-update-reference.md` section "Trust Rules" for the 6 trust invariants.

## Definition of Done

- [ ] Current roadmap and git state analyzed
- [ ] Mode-specific analysis completed
- [ ] Changes previewed at HARD STOP
- [ ] User approved changes
- [ ] All modifications applied correctly
- [ ] Post-update verification passed
- [ ] Changes committed (if approved)
- [ ] Release need checked (if applicable)
- [ ] User approved final result
