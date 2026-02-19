---
name: release-iterate-changelog
description: "Generate changelog with user impact notes and support guidance from git history or changes."
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git tag:*), Bash(git diff:*), Bash(git describe:*), Bash(git status:*), Bash(git rev-list:*), Bash(git remote:*), Write($JAAN_OUTPUTS_DIR/CHANGELOG.md), Edit($JAAN_OUTPUTS_DIR/CHANGELOG.md), Edit(jaan-to/config/settings.yaml)
argument-hint: "[(no args) | create | release vX.Y.Z | add \"<description>\"]"
disable-model-invocation: true
---

# release-iterate-changelog

> Generate user-facing changelogs with impact notes and support guidance using git history analysis and the Keep a Changelog standard.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:release-iterate-changelog.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_OUTPUTS_DIR/CHANGELOG.md` - Existing changelog (if present)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech context (if exists)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Command**: $ARGUMENTS

### Input Mode Detection

| Pattern | Mode | Description |
|---------|------|-------------|
| (no args) | `auto-generate` | Analyze git commits since last tag, generate changelog draft |
| `create` | `create` | Create a new CHANGELOG.md from scratch |
| `release vX.Y.Z` | `release` | Promote [Unreleased] to versioned section |
| `add "<description>"` | `add` | Add entry to [Unreleased] section manually |
| Other text | `from-input` | Parse provided changes list into changelog format |

If no input provided, default to `auto-generate` mode.
If input doesn't match any pattern, treat as `from-input` mode.

---

# PHASE 1: Analysis (Read-Only)

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `release-iterate-changelog`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for context

If the file does not exist, continue without it.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_release-iterate-changelog`

---

## Step 1: Detect Mode

Parse `$ARGUMENTS` to determine mode using the Input Mode Detection table above.

## Step 2: Gather Context

Gather data based on detected mode:

### Mode: `auto-generate`

1. Find the reference point (last tag or root commit):
```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
    REF=$(git rev-list --max-parents=0 HEAD)
else
    REF="$LAST_TAG"
fi
```

2. Collect commits since reference:
```bash
git log ${REF}..HEAD --oneline --no-merges
git log ${REF}..HEAD --format="%H %s" --no-merges
```

3. Get file change details per commit:
```bash
git diff ${REF}..HEAD --stat
git diff ${REF}..HEAD --diff-filter=A --name-only   # New files
git diff ${REF}..HEAD --diff-filter=D --name-only   # Deleted files
git diff ${REF}..HEAD --diff-filter=M --name-only   # Modified files
```

4. Read existing `$JAAN_OUTPUTS_DIR/CHANGELOG.md` if it exists.

### Mode: `create`

Ask the user:
1. "What is the project name?"
2. "What is the repository URL? (optional, for comparison links)"
3. "What is the initial version? (default: 0.1.0)"

### Mode: `release`

1. Parse version from arguments (e.g., `release v1.2.0` → `1.2.0`)
2. Read existing `$JAAN_OUTPUTS_DIR/CHANGELOG.md` — **REQUIRED** (fail if not found)
3. Validate version against SemVer regex:
```
^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
```
4. Validate new version > previous latest version
5. Extract `[Unreleased]` entries

### Mode: `add`

1. Parse description from arguments (e.g., `add "New dark mode toggle"`)
2. Read existing `$JAAN_OUTPUTS_DIR/CHANGELOG.md` — create if not found
3. Classify change type using keyword analysis:
   - Added: add, new, create, introduce, implement, support
   - Fixed: fix, bug, patch, resolve, correct, repair, hotfix
   - Changed: update, modify, refactor, improve, optimize, enhance, upgrade, redesign
   - Removed: remove, delete, drop, discard, clean up
   - Deprecated: deprecate, obsolete, phase out, sunset
   - Security: secure, vulnerability, CVE, XSS, SQL inject, CSRF

### Mode: `from-input`

1. Parse the provided text
2. Classify each entry into change types using keyword analysis + LLM classification
3. Read existing `$JAAN_OUTPUTS_DIR/CHANGELOG.md` if it exists

## Step 3: Classify & Group

For each commit or change entry:

### 3a: Conventional Commits Parsing (try first)

Apply regex to each commit message:
```
^(?<type>\w+)(?:\((?<scope>[^)]+)\))?(?<breaking>!)?:\s*(?<description>.+)$
```

Map types to changelog categories:

| Conventional Commit Type | Changelog Category | SemVer Impact | Include? |
|--------------------------|-------------------|---------------|----------|
| `feat` | **Added** | MINOR | Always |
| `fix` | **Fixed** | PATCH | Always |
| `feat!` / `BREAKING CHANGE` | **Changed** or **Removed** | MAJOR | Always |
| `perf` | **Changed** | PATCH | Usually |
| `refactor` | **Changed** | — | Optional |
| `revert` | **Removed** or **Fixed** | varies | Usually |
| `deprecate` (custom) | **Deprecated** | MINOR | Always |
| `security` (custom) | **Security** | PATCH | Always |
| `docs`, `style`, `test`, `build`, `ci`, `chore` | (skip) | — | No |

### 3b: Freeform Heuristics (fallback)

For commits that don't match Conventional Commits regex:

1. **Keyword patterns**: Match commit message against keyword lists (Added, Fixed, Changed, Removed, Deprecated, Security patterns)
2. **File path heuristics**: Analyze changed files — new files suggest "Added", deleted files suggest "Removed", changes in security/auth paths suggest "Security"
3. **Diff statistics**: Small patches → "Fixed", large changes → "Changed", high deletion ratio → "Removed"
4. **LLM classification**: For ambiguous commits, classify using context from message + files changed

### 3c: Filter Noise

Skip commits that are:
- Docs-only changes (only files in `docs/`, `*.md`)
- Test-only changes (only files in `test/`, `spec/`, `__tests__/`)
- CI/build-only changes (`.github/`, `.gitlab-ci`, `Dockerfile`, `Makefile`)
- Chore/config changes (`.gitignore`, lock files, config-only YAML/JSON)

Track skipped commits with rationale for the "Skipped Commits" section.

### 3d: Group

Group classified entries into 6 categories:
- **Added** — New features
- **Changed** — Modifications to existing functionality
- **Deprecated** — Features marked for future removal
- **Removed** — Features that have been removed
- **Fixed** — Bug fixes
- **Security** — Vulnerability fixes

Only include categories that have entries (don't show empty sections).

## Step 4: Generate Draft

For each classified entry, write a **human-friendly** changelog entry:
- Start with an action verb
- Describe the user-facing impact, not the implementation detail
- Keep entries concise (1-2 lines)
- Reference issue/PR numbers if found in commit messages

**Anti-pattern**: Never dump raw commit messages. Always rewrite into user-friendly language.

### SemVer Suggestion

Based on classified changes, suggest next version:
- Any `BREAKING CHANGE` or `Removed` with breaking impact → suggest MAJOR bump
- Any `Added` or `Deprecated` → suggest at least MINOR bump
- Only `Fixed`, `Changed` (non-breaking), `Security` → suggest PATCH bump

## Step 5: User Impact Analysis

For each change category, assess:

| Dimension | Values |
|-----------|--------|
| User-facing impact | High / Medium / Low / None |
| Who is affected | All users / Segment / Internal only |
| Support implications | FAQ update / Known issue / Migration steps / None |

### Impact Classification

**High Impact**: Breaking changes, removed features, major workflow changes, security fixes requiring user action
**Medium Impact**: New features, significant improvements, deprecation notices
**Low Impact**: Bug fixes, performance improvements, minor UI changes

---

# HARD STOP - Human Review Gate

Present draft changelog with:

```
## Changelog Draft

**Mode**: {mode}
**Commits Analyzed**: {count}
**Suggested Version**: {version} ({rationale})

### Categorized Changes

#### Added
- {entries}

#### Changed
- {entries}

#### Fixed
- {entries}

(etc. — only non-empty categories)

### User Impact Summary

**High Impact**: {count} changes requiring user attention
**Medium Impact**: {count} notable changes
**Low Impact**: {count} minor improvements

### Support Guidance Preview
{FAQ entries, migration steps, known issues}

### Skipped Commits
{count} commits filtered as non-user-facing
```

> "Ready to write changelog to `$JAAN_OUTPUTS_DIR/CHANGELOG.md`? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Write/Update CHANGELOG.md

Write to `$JAAN_OUTPUTS_DIR/CHANGELOG.md` based on mode:

### Mode: `create`

Write new file using template from `skills/release-iterate-changelog/template.md`:
- Standard Keep a Changelog header boilerplate
- `[Unreleased]` section (empty or with initial entries)
- Optional initial version section
- Comparison links footer (if repo URL provided)

### Mode: `auto-generate` / `from-input`

If `$JAAN_OUTPUTS_DIR/CHANGELOG.md` exists:
- Read existing file
- Insert new entries into the `[Unreleased]` section under correct change type sub-headers
- Create missing sub-headers as needed
- Preserve all existing content

If `$JAAN_OUTPUTS_DIR/CHANGELOG.md` does not exist:
- Create new file with standard header
- Add entries under `[Unreleased]`

### Mode: `release`

1. Extract all entries from `[Unreleased]` section
2. Create new versioned section: `## [{version}] - {YYYY-MM-DD}`
3. Move entries from `[Unreleased]` to the new versioned section
4. Clear `[Unreleased]` (keep the header, remove entries)
5. Insert new version section between `[Unreleased]` and previous latest version
6. Update comparison links in footer:
   - `[unreleased]` link points to `{version}...HEAD`
   - New `[{version}]` link points to `{previous_version}...{version}`
7. Validate reverse chronological order

### Mode: `add`

1. Read existing `$JAAN_OUTPUTS_DIR/CHANGELOG.md`
2. Find the `[Unreleased]` section
3. Find or create the correct change type sub-header (e.g., `### Added`)
4. Append new entry under the sub-header
5. If file doesn't exist, create with standard header + `[Unreleased]` + entry

## Step 7: Quality Validation

Run validation checks on the written/updated file:

- [ ] Version number is valid SemVer (if applicable)
- [ ] Date is ISO 8601 (YYYY-MM-DD)
- [ ] Changes use only standard 6 types (Added, Changed, Deprecated, Removed, Fixed, Security)
- [ ] Breaking changes flagged for MAJOR bump
- [ ] Deprecations flagged for at least MINOR bump
- [ ] No duplicate version entries
- [ ] `[Unreleased]` section preserved at top
- [ ] Entries are user-facing (not raw commit dumps)
- [ ] User impact assessed for each category
- [ ] Support guidance included
- [ ] Versions in reverse chronological order

Report any validation warnings or errors.

## Step 8: Capture Feedback

After changelog is written, ask:
> "Any feedback or improvements needed? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "[1] Fix now - Update this changelog
   > [2] Learn - Save for future runs
   > [3] Both - Fix now AND save lesson"

**Option 1 - Fix now:**
- Apply the feedback to the changelog
- Re-run validation
- Write updated file

**Option 2 - Learn for future:**
- Run: `/jaan-to:learn-add release-iterate-changelog "{feedback}"`

**Option 3 - Both:**
- First: Apply fix (Option 1)
- Then: Run `/jaan-to:learn-add` (Option 2)

**If no:**
- Changelog workflow complete

---

## Error Handling

| Error | Message |
|-------|---------|
| No git repo | "Not a git repository. Auto-generate mode requires git history. Use `create` or provide changes as text." |
| No tags (auto-generate) | "No git tags found. Analyzing all commits from initial commit. Consider creating a tag with `git tag v0.1.0` for better results." |
| No CHANGELOG.md (release mode) | "No existing CHANGELOG.md found at `$JAAN_OUTPUTS_DIR/CHANGELOG.md`. Run `create` mode first or use `auto-generate`." |
| Invalid SemVer (release mode) | "Version '{input}' is not valid SemVer. Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.0)" |
| Version not greater (release mode) | "Version {new} must be greater than latest version {latest}." |
| No commits found (auto-generate) | "No commits found since {reference}. Nothing to generate." |
| Empty [Unreleased] (release mode) | "No entries in [Unreleased] section. Add entries first with `add` mode or `auto-generate`." |

## Trust Rules

1. **NEVER** write to files outside `$JAAN_OUTPUTS_DIR/CHANGELOG.md` without approval
2. **ALWAYS** read existing changelog before modifying
3. **PRESERVE** existing entries — never overwrite or delete previous versions
4. **VALIDATE** all version numbers and dates
5. **PREVIEW** all changes before writing
6. **HUMAN-FRIENDLY** entries only — never dump raw commit logs

## Definition of Done

- [ ] Changes collected and classified
- [ ] Changelog draft reviewed by user
- [ ] `$JAAN_OUTPUTS_DIR/CHANGELOG.md` written/updated
- [ ] Quality checks pass
- [ ] User approved final result
