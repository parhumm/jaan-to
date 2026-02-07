# Contributing to jaan.to

Thank you for your interest in contributing to jaan.to! This document outlines how to contribute effectively to the project.

---

## Table of Contents

- [Branching Strategy](#branching-strategy)
- [Code of Conduct](#code-of-conduct)
- [Ways to Contribute](#ways-to-contribute)
- [Adding New Skills](#adding-new-skills)
- [Improving Learning Files](#improving-learning-files)
- [Code Style & Conventions](#code-style--conventions)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

---

## Branching Strategy

jaan.to uses a two-branch development model:

### Branches

| Branch | Purpose | Version Format | Install Command |
|--------|---------|----------------|-----------------|
| `main` | Stable releases | `3.15.0` | `/plugin marketplace add parhumm/jaan-to` |
| `dev` | Development/preview | `3.15.0-dev` | `/plugin marketplace add parhumm/jaan-to#dev` |

### Workflow

```
feature/* ───> dev ───> main
                │         │
                │    (PR + review)
                │         │
                │    (release tag)
                │         │
                └─────────┘
              auto-bump dev
```

1. **Daily development**: Work on `dev` branch (direct pushes allowed)
2. **Feature work**: Create feature branches from `dev`, merge back to `dev`
3. **Releases**: Create PR from `dev` → `main` (requires review + CI checks)
4. **After release**: Bump `dev` to next version (e.g., `3.15.0` → `3.16.0-dev`)

### Contributing to dev

```bash
# Clone and switch to dev
git clone https://github.com/parhumm/jaan-to.git
cd jaan-to
git checkout dev

# Make changes, test locally
claude --plugin-dir .

# Push to dev (no PR required for small changes)
git push origin dev
```

### Hotfixes

All fixes go through `dev` first:
1. Fix on `dev`
2. Test
3. Create expedited PR: `dev` → `main`

---

## Code of Conduct

- **Be respectful:** Treat everyone with respect and kindness
- **Be collaborative:** Work together to improve the project
- **Be constructive:** Provide helpful feedback and suggestions
- **Be inclusive:** Welcome contributors of all backgrounds and experience levels

---

## Ways to Contribute

### 1. Report Bugs

Found a bug? [Open an issue](https://github.com/parhumm/jaan-to/issues/new) with:
- **Description:** What happened vs what you expected
- **Steps to reproduce:** Exact commands and inputs
- **Environment:** OS, Claude Code version, plugin version
- **Logs:** Error messages or relevant output

### 2. Suggest Features

Have an idea? [Open an issue](https://github.com/parhumm/jaan-to/issues/new) with:
- **Use case:** What problem does this solve?
- **Proposed solution:** How should it work?
- **Alternatives:** Other ways to solve the problem
- **Impact:** Who benefits and how?

### 3. Improve Documentation

Documentation improvements are always welcome:
- Fix typos or unclear explanations
- Add examples or use cases
- Update outdated information
- Improve README or skill descriptions

### 4. Add Skills

See [Adding New Skills](#adding-new-skills) below.

### 5. Capture Lessons

After using a skill, share what you learned:
- Common mistakes you encountered
- Edge cases you discovered
- Improvements you'd suggest

See [Improving Learning Files](#improving-learning-files) below.

---

## Adding New Skills

### Quick Start

The easiest way to create a new skill:

```bash
# From Claude Code
/to-jaan-skill-create
```

This wizard will guide you through:
1. Choosing a role and domain
2. Defining inputs and outputs
3. Describing the skill behavior
4. Creating the skill structure

### Manual Process

If you prefer to create skills manually, follow the [Creating Skills Guide](docs/extending/create-skill.md).

**Key Requirements:**

1. **SKILL.md file** with YAML frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Brief description in third-person voice
   ---
   ```

2. **Naming convention:**
   - Public skills: `jaan-to-{role}-{domain}-{action}`
   - Internal skills: `to-jaan-{domain}-{action}`

3. **Two-phase workflow:**
   - Phase 1: Read-only analysis (context, requirements, planning)
   - HARD STOP: Confirm with user before proceeding
   - Phase 2: Generation (write files, validate, preview)

4. **LEARN.md file** (optional but recommended):
   - Location: `skills/{name}/LEARN.md`
   - Format: See [docs/learning/LESSON-TEMPLATE.md](docs/learning/LESSON-TEMPLATE.md)

5. **template.md file** (if skill generates structured output):
   - Location: `skills/{name}/template.md`
   - Format: Markdown with `{{placeholders}}`

### Skill Categories

| Role | Domain Examples | Action Examples |
|------|-----------------|-----------------|
| `pm` | prd, story, research | write, update, analyze |
| `dev` | fe, be, stack | breakdown, detect, generate |
| `data` | gtm, analytics | datalayer, track, analyze |
| `ux` | research, heatmap, microcopy | synthesize, analyze, write |
| `qa` | test-cases, automation | generate, validate |

### Testing Your Skill

1. **Install plugin locally:**
   ```bash
   claude --plugin-dir /path/to/jaan-to
   ```

2. **Verify skill appears:**
   ```bash
   /help | grep your-skill-name
   ```

3. **Test execution:**
   ```bash
   /jaan-to-your-skill-name "test input"
   ```

4. **Run verification:**
   ```bash
   ./scripts/verify-install.sh /path/to/test-project --plugin-dir /path/to/jaan-to
   ```

---

## Improving Learning Files

Learning files (`LEARN.md`) capture accumulated wisdom from skill usage. These files make skills smarter over time.

### Adding Lessons

**Via Command (Recommended):**
```bash
/to-jaan-learn-add "lesson content here"
```

**Manual Edit:**
1. Edit `jaan-to/learn/{skill-name}.learn.md` in your project
2. Follow format from [docs/learning/LESSON-TEMPLATE.md](docs/learning/LESSON-TEMPLATE.md)

### Lesson Structure

```markdown
## [Brief Title of Lesson]

**Date:** 2026-02-03
**Skill:** skill-name
**Severity:** [Low | Medium | High | Critical]

### Context
[What were you trying to do?]

### What Happened
[What went wrong or what was learned?]

### Root Cause
[Why did it happen?]

### Fix
[How was it resolved?]

### Prevention
[How to avoid this in the future?]
```

### What Makes a Good Lesson

✅ **Good:**
- Specific: "PRD missing Security section for OAuth flows"
- Actionable: "Add validation: check for Security section when OAuth mentioned"
- Contextual: "User requested OAuth integration but PRD had no security considerations"

❌ **Bad:**
- Vague: "PRD was incomplete"
- Not actionable: "Should be better"
- No context: "It didn't work"

---

## Code Style & Conventions

### Naming

**Skills:**
- Directory: `skills/jaan-to-pm-prd-write/`
- File: `SKILL.md` (uppercase)
- Command: `/jaan-to-pm-prd-write`
- Logical name: `jaan-to:pm:prd-write`

**Files:**
- Markdown: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md` (uppercase for root docs)
- Scripts: `bootstrap.sh`, `learning-summary.sh` (lowercase, kebab-case)
- Templates: `template.md` (lowercase)

### Shell Scripts

- Use `#!/bin/bash` or `#!/usr/bin/env bash`
- Always include `set -euo pipefail` for safety
- Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths
- Use `${CLAUDE_PROJECT_DIR}` for project-relative paths
- Exit 0 on success, non-zero on error

**Example:**
```bash
#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"

# Your code here

exit 0
```

### Markdown

- Use ATX headers (`#`, `##`, not underlines)
- Max line length: 120 characters (soft limit)
- Code blocks: Always specify language (```bash, ```json, ```yaml)
- Links: Use reference-style for repeated URLs

### YAML Frontmatter

- Always use `---` delimiters
- Required fields first (name, description)
- Optional fields after
- No custom fields without documentation

**Example:**
```yaml
---
name: skill-name
description: Brief description
---
```

---

## Testing Guidelines

### Automated Tests

Currently, jaan.to uses manual testing. Automated tests coming in Phase 6 (see [roadmap](roadmaps/jaan-to/roadmap-jaan-to.md)).

### Manual Testing Checklist

Before submitting a PR with a new skill:

- [ ] Skill appears in `/help` output
- [ ] Skill executes without errors
- [ ] Two-phase workflow works (HARD STOP between phases)
- [ ] Output written to correct location (`jaan-to/outputs/`)
- [ ] LEARN.md seed file exists
- [ ] Template file exists (if applicable)
- [ ] Context files are read correctly (`tech.md`, `team.md`, etc.)
- [ ] Quality checks pass (if applicable)
- [ ] Skill description uses third-person voice
- [ ] Command naming follows convention

### Integration Testing

Test skills work together:

```bash
# Example: PRD → Stories → Tasks workflow
/jaan-to-pm-prd-write "user authentication"
/jaan-to-pm-story-write from prd
/jaan-to-dev-fe-task-breakdown from prd
```

Verify:
- [ ] Stories reference PRD correctly
- [ ] Tasks reference PRD and Stories correctly
- [ ] No broken file paths
- [ ] Cross-skill suggestions work

---

## Submitting Changes

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/jaan-to.git
cd jaan-to
git remote add upstream https://github.com/parhumm/jaan-to.git
```

### 2. Create a Branch from dev

```bash
# Always branch from dev, not main
git checkout dev
git pull upstream dev
git checkout -b feature/your-skill-name
# or
git checkout -b fix/issue-description
```

**Branch naming:**
- Features: `feature/skill-name` or `feature/description`
- Fixes: `fix/issue-description`
- Docs: `docs/what-changed`
- Refactor: `refactor/what-changed`

### 3. Make Changes

Follow guidelines above for code style, testing, and documentation.

### 4. Commit

**Commit message format:**
```
type(scope): brief description

Longer explanation if needed.

- Bullet points for details
- More details

Co-authored-by: Name <email@example.com>
```

**Types:**
- `feat`: New feature (skill, command, hook)
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring (no behavior change)
- `test`: Adding tests
- `chore`: Maintenance (dependencies, build)

**Examples:**
```
feat(skill): Add /jaan-to-qa-test-cases skill

Generate BDD test cases from PRD acceptance criteria.

- Given/When/Then format
- Happy path + edge cases + errors
- Output to jaan-to/outputs/qa/
```

### 5. Push and Create PR

```bash
git push origin feature/your-skill-name
```

Then create a PR on GitHub with:
- **Title:** Same as commit message first line
- **Description:**
  - What changed?
  - Why was this change needed?
  - How was it tested?
- **Screenshots:** If UI/output changes
- **Related Issues:** Link to issues this PR addresses

---

## Release Process

Releases are managed by maintainers. If you're interested in the process:

### Versioning

jaan.to follows [Semantic Versioning](https://semver.org/):
- **Major (v2.0.0):** Breaking changes
- **Minor (v1.1.0):** New features (backward compatible)
- **Patch (v1.0.1):** Bug fixes

**Branch versions:**
- `main`: `X.Y.Z` (e.g., `3.15.0`)
- `dev`: `X.Y.Z-dev` (e.g., `3.15.0-dev`)

### Release Checklist (Maintainers Only)

1. **Prepare release branch from dev:**
   ```bash
   git checkout dev
   git checkout -b release/3.15.0
   ```

2. **Update version in 3 places** (remove `-dev` suffix):
   ```bash
   ./scripts/bump-version.sh 3.15.0
   ```
   This updates:
   - `.claude-plugin/plugin.json` → `"version": "3.15.0"`
   - `.claude-plugin/marketplace.json` → `"version": "3.15.0"` (top-level)
   - `.claude-plugin/marketplace.json` → `"plugins[0].version": "3.15.0"`

3. **Add entry to [CHANGELOG.md](CHANGELOG.md)** following [Keep a Changelog](https://keepachangelog.com/)

4. **Create PR: `release/3.15.0` → `main`**
   - CI checks: no `-dev` suffix, all 3 versions match, CHANGELOG entry exists
   - Requires review and approval

5. **After merge, tag and push:**
   ```bash
   git checkout main
   git pull origin main
   git tag v3.15.0
   git push origin main --tags
   ```

6. **Bump dev to next version:**
   ```bash
   git checkout dev
   git merge main
   ./scripts/bump-version.sh 3.16.0-dev
   git commit -m "chore: bump dev to 3.16.0-dev"
   git push origin dev
   ```

**IMPORTANT:** Version bump, CHANGELOG entry, and git tag are inseparable. Never do one without the others.

---

## Questions?

- **Documentation:** [docs/README.md](docs/README.md)
- **Skills Reference:** [docs/skills/README.md](docs/skills/README.md)
- **Creating Skills:** [docs/extending/create-skill.md](docs/extending/create-skill.md)
- **GitHub Issues:** [github.com/parhumm/jaan-to/issues](https://github.com/parhumm/jaan-to/issues)

---

**Thank you for contributing!**

*Give soul to your workflow.*
