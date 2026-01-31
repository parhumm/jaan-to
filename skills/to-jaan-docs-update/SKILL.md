---
name: to-jaan-docs-update
description: |
  Audit and maintain documentation quality.
  Default: Smart staleness check using git history.
  Maps to: to-jaan-docs-update
allowed-tools: Read, Glob, Grep, Write(docs/**), Write(.jaan-to/**), Edit, Bash(git add:*), Bash(git commit:*), Bash(git log:*), Bash(git mv:*)
argument-hint: "[path] [--full] [--fix] [--check-only] [--quick]"
---

# to-jaan-docs-update

> Smart documentation auditing with git-based staleness detection.

## Context Files

- `.jaan-to/docs/STYLE.md` - Documentation standards
- `.jaan-to/learn/to-jaan-docs-update.learn.md` - Past lessons (loaded in Pre-Execution)

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`.jaan-to/learn/to-jaan-docs-update.learn.md`

If the file exists, apply its lessons throughout this execution:
- Note common issues to check
- Apply workflow improvements
- Avoid known mistakes

If the file does not exist, continue without it.

---

## File Mapping (Code → Docs)

| Code Path | Related Doc |
|-----------|-------------|
| `skills/{name}/SKILL.md` | `docs/skills/{role}/{slug}.md` |
| `.jaan-to/learn/{name}.learn.md` | (referenced in skill doc) |
| `.jaan-to/context/hooks/{name}.sh` | `docs/hooks/{name}.md` |
| `.jaan-to/context/config.md` | `docs/config/README.md` |
| `.jaan-to/context/*.md` | `docs/config/context.md` |
| `.jaan-to/context/boundaries.md` | `docs/config/boundaries.md` |

**Slug extraction:** `jaan-to-pm-prd-write` → `prd-write` (remove role prefix)

---

# PHASE 0: Smart Default - Staleness Detection

**Goal:** Find docs that are out of sync with their source code.

**Trigger:** Run with NO arguments or just `--fix`

## Step 0.1: Parse Arguments

**Arguments**: $ARGUMENTS

| Argument | Effect |
|----------|--------|
| (none) | Smart default: staleness check |
| `[path]` | Check specific path only |
| `--full` | Skip staleness, do full audit |
| `--fix` | Auto-fix issues |
| `--check-only` | Report only, no changes |
| `--quick` | Inventory only |

**If `--full` or `[path]` provided:** Skip to PHASE 1 (Quick Inventory)

## Step 0.2: Get Recent Code Changes

```bash
git log --since="30 days ago" --name-only --pretty=format: -- skills/ .jaan-to/context/hooks/ .jaan-to/context/config.md .jaan-to/context/ | sort -u | grep -v '^$'
```

Extract unique changed files.

## Step 0.3: Map Code Files to Docs

For each changed code file, find related doc:

**Skills:**
```
skills/{name}/SKILL.md → docs/skills/{role}/{slug}.md

# Extract slug: remove brand prefix and role
# jaan-to-pm-prd-write → prd-write
# to-jaan-learn-add → learn-add (core role)
```

**Hooks:**
```
.jaan-to/context/hooks/{name}.sh → docs/hooks/{name}.md
```

**Config:**
```
.jaan-to/context/config.md → docs/config/README.md
.jaan-to/context/*.md → docs/config/context.md
.jaan-to/context/boundaries.md → docs/config/boundaries.md
```

## Step 0.4: Compare Timestamps

For each code→doc pair:
```bash
# Get code last modified
git log -1 --format=%ai -- {code_path}

# Get doc last modified
git log -1 --format=%ai -- {doc_path}
```

**Staleness threshold:** 7 days
- If code_date > doc_date + 7 days → Flag as STALE

## Step 0.5: Check for Missing Docs

```bash
# Check if expected doc exists
git ls-files -- {expected_doc_path}
```

If code exists but doc doesn't → Flag as MISSING

## Step 0.6: Generate Staleness Report

```markdown
# Documentation Staleness Report
**Date:** {date} | **Code changes:** {n} files | **Docs checked:** {n}

## Potentially Outdated

| Doc | Related Code | Code Changed | Doc Updated | Delta |
|-----|--------------|--------------|-------------|-------|
| docs/skills/pm/prd-write.md | skills/pm-prd-write/SKILL.md | 2026-01-25 | 2026-01-10 | 15d stale |

## Missing Documentation

| Code File | Expected Doc | Action |
|-----------|--------------|--------|
| skills/new-skill/SKILL.md | docs/skills/?/new-skill.md | Create |

## Up to Date

✅ {n} docs are current (code and doc in sync)

---

What would you like to do?
[1] Review stale docs one by one
[2] Full audit (check everything)
[3] Quick fix (update dates only)
[4] Exit
```

**HARD STOP:** Wait for user choice.

**Option 1:** For each stale doc, show side-by-side what changed in code, ask what to update.
**Option 2:** Continue to PHASE 1 (full audit).
**Option 3:** Just update `updated_date` in stale docs.
**Option 4:** Stop.

---

# PHASE 1: Quick Inventory

**Goal:** Understand documentation state without reading everything.

**Trigger:** `--full`, `[path]` argument, or user chose Option 2 from staleness report

## Step 1.1: Inventory Files

Use Glob to count docs (don't read all):
```
Glob: docs/**/*.md
```

Exclude: `.jaan-to/`, `node_modules/`

## Step 1.2: Check Recent Doc Changes

```bash
git log --since="30 days ago" --oneline --name-only -- docs/ | head -30
```

## Step 1.3: Quick Scan for Issues

Use Grep to detect problems without reading files:

**Missing frontmatter:**
```
Grep: "^---$" in docs/**/*.md (check first line)
```

**Missing tagline:**
```
Grep: "^>" in docs/**/*.md
```

## Step 1.4: Generate Audit Proposal

```markdown
## Documentation Audit Proposal

**Files found:** X docs
**Recent changes:** X files in last 30 days

### Quick Scan Results
- Missing frontmatter: X files
- Missing tagline: X files
- Potential issues: X files

Proceed with full audit? [yes/no/quick-fixes-only]
```

**If `--quick`:** Stop here.
**If "no":** Stop here.
**If "quick-fixes-only":** Only fix frontmatter/dates.
**If "yes":** Continue to full audit.

---

# PHASE 2: Full Analysis

## Step 2.1: Progressive File Loading

Load files one at a time to save tokens.
For each file, check:

### Frontmatter Validation

```yaml
---
title: Required
doc_type: Required (skill|hook|config|guide|concept|index)
created_date: Required (YYYY-MM-DD)
updated_date: Required (YYYY-MM-DD)
tags: Required (array)
---
```

### Structure Validation

- [ ] Has H1 title (only one)
- [ ] Has tagline (`> description`)
- [ ] Sections separated with `---`
- [ ] No H4+ headings
- [ ] Under line limit for type

### Link Validation

Check all internal links:
- `[text](path.md)` - file exists?
- `[text](../path.md)` - relative path valid?

### Duplication Detection

Compare similar docs for overlap:

| Overlap | Action |
|---------|--------|
| >80% | Flag for consolidation |
| 50-80% | Suggest differentiation |
| <50% | Keep separate |

### Location Check

Verify docs are in correct folders:

| Content Type | Correct Location |
|--------------|------------------|
| Skill docs | `docs/skills/{role}/` |
| Hook docs | `docs/hooks/` |
| Config docs | `docs/config/` |
| Guides | `docs/extending/` |

## Step 2.2: Compile Issues

Categorize findings:

| Category | Icon | Description |
|----------|------|-------------|
| Healthy | ✅ | No issues |
| Need Updates | ⚠️ | Minor fixes needed |
| Deprecated | 🔴 | Archive candidate |
| Duplicates | 📦 | Consolidation needed |
| Misplaced | 📁 | Wrong location |

---

# HARD STOP - Audit Report

Show audit report:

```markdown
# Documentation Audit Report
**Date:** {date} | **Files:** {count} | **Issues:** {count}

## Summary
| Category | Count | Action |
|----------|-------|--------|
| ✅ Healthy | X | None |
| ⚠️ Need Updates | X | Update |
| 🔴 Deprecated | X | Archive |
| 📦 Duplicates | X | Consolidate |
| 📁 Misplaced | X | Move |

## Priority Actions

### High Priority
1. **{file}** - {issue} - {action}

### Medium Priority
2. **{file}** - {issue} - {action}

### Low Priority
3. **{file}** - {issue} - {action}

---

Apply fixes? [yes/no/selective]
```

**If `--check-only`:** Stop here.
**Do NOT proceed without explicit approval.**

---

# PHASE 3: Apply Fixes

## Step 3.1: Archive Deprecated Docs

```bash
mkdir -p docs/archive
git mv docs/deprecated-file.md docs/archive/
```

Add note at top: "ARCHIVED: See [new-doc.md] for current information."

## Step 3.2: Consolidate Duplicates

1. Read both documents
2. Merge best content into primary
3. Archive the duplicate
4. Update cross-references

## Step 3.3: Fix Frontmatter

Add missing frontmatter:
```yaml
---
title: [Inferred from H1]
doc_type: [Inferred from path]
created_date: [From git log or today]
updated_date: [Today]
tags: [Inferred from content]
---
```

## Step 3.4: Fix Structure

- Add missing `---` separators
- Convert H4+ to H3 or bullets
- Add missing tagline (ask user)

## Step 3.5: Fix Links

- Report broken links with suggestions
- Update paths for moved files

## Step 3.6: Update Dates

For any modified file:
```yaml
updated_date: {today}
```

## Step 3.7: Move Misplaced Files

```bash
git mv docs/wrong-location/file.md docs/correct-location/
```

Update any references to moved file.

---

# PHASE 4: Commit & Report

## Step 4.1: Commit Changes

Ask: "Commit documentation updates? [y/n]"

If yes:
```bash
git add docs/
git commit -m "docs: Audit and update documentation

- Fixed: X files
- Archived: X files
- Moved: X files

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 4.2: Final Report

```markdown
✅ Documentation audit complete!

## Changes Applied
- Fixed frontmatter: X files
- Fixed structure: X files
- Archived: X files
- Moved: X files
- Updated dates: X files

## Documentation Health: [EXCELLENT/GOOD/NEEDS WORK]

Commit: {hash}
```

---

## Error Handling

### No Docs Found
> "No documentation files found in `{path}`."

### Permission Denied
> "Cannot modify `{file}`. Check permissions."

### Git Not Available
> "Git not available. Changes saved but not committed."

---

## Trust Rules

1. **NEVER** delete without approval (archive instead)
2. **ALWAYS** preserve content when consolidating
3. **ASK** before major changes
4. **SKIP** generated files (.jaan-to/)
5. **BACKUP** before bulk operations
6. **PREVIEW** all changes before applying
