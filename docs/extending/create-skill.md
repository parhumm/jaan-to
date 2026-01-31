# Skill Creation Specification

> Complete reference for creating jaan.to skills—for humans and AI.

---

## Overview

A skill is a reusable command that AI executes to produce outputs. This specification defines the structure, files, and patterns required for valid skills.

### Audience

| Reader | Focus |
|--------|-------|
| Humans | Step-by-step creation guide, examples |
| AI | Machine-parseable schemas, validation rules |

### Principles

- **Two-Phase Workflow** — Read-only analysis, then write with approval
- **Human-in-the-Loop** — Hard stop before any file writes
- **Continuous Learning** — Every skill reads and contributes to LEARN.md
- **Safety First** — Tool permissions restrict write paths

---

## Quick Reference

| Aspect | Pattern |
|--------|---------|
| Name | `{name}` |
| Command | `/{name}` |
| Directory | `skills/{name}/` |
| Logical Name | `{role}:{domain-action}` |
| Output | `jaan-to/outputs/{role}/{domain}/{slug}/` |

---

## Naming Conventions

### Pattern

Role-based skills (for team use):
```
jaan-to-{role}-{domain}-{action}
```

Internal skills (for plugin maintenance):
```
to-jaan-{domain}-{action}
```

| Part | Description | Examples |
|------|-------------|----------|
| role | Team function | pm, dev, qa, ux, data, growth |
| domain | Area of work | prd, plan, test, docs, learn |
| action | What it does | write, add, review, create, update |

### Examples

| Skill Name | Command | Logical Name |
|------------|---------|--------------|
| `jaan-to-pm-prd-write` | `/jaan-to-pm-prd-write` | `pm:prd-write` |
| `jaan-to-qa-plan-test-matrix` | `/jaan-to-qa-plan-test-matrix` | `qa:plan-test-matrix` |
| `to-jaan-docs-create` | `/to-jaan-docs-create` | `docs:create` |
| `jaan-to-dev-api-contract` | `/jaan-to-dev-api-contract` | `dev:api-contract` |

---

## Required Files

Every skill needs these files in `skills/{name}/`:

| File | Required | Purpose |
|------|----------|---------|
| `SKILL.md` | Yes | Execution instructions |
| `template.md` | No | Output format template |

Learning lessons are stored in `jaan-to/learn/{name}.learn.md` (managed by the system).

---

## SKILL.md Specification

### YAML Frontmatter Schema

Every SKILL.md must begin with YAML frontmatter:

```yaml
---
name: {skill-name}
description: |
  {1-2 sentence purpose}
  Auto-triggers on: {context clues}
  Maps to: {logical-name}
allowed-tools: {tool-list}
argument-hint: {expected-format}
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Matches directory name |
| `description` | multiline | Yes | Purpose + triggers + mapping |
| `allowed-tools` | string | Yes | Comma-separated tool permissions |
| `argument-hint` | string | Yes | Shows expected input format |

### Tool Permission Patterns

| Pattern | Use Case |
|---------|----------|
| `Read` | Read any file |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents |
| `Write(jaan-to/**)` | Write outputs only |
| `Write(docs/**)` | Documentation skills |
| `Write(skills/**)` | Skill development |
| `Edit` | Modify existing files |
| `Bash(git add:*)` | Stage changes |
| `Bash(git commit:*)` | Commit changes |

### Markdown Body Structure

After frontmatter, SKILL.md follows this structure:

```markdown
# {role}:{domain-action}

> {One-line purpose}

## Context Files
Read these before execution:
- {file1} - {why}
- {file2} - {why}

## Input

**{Input Name}**: $ARGUMENTS

{Instructions for interpreting input}

---

# PHASE 1: Analysis (Read-Only)

## Step 0: Apply Past Lessons
Read `jaan-to/learn/{name}.learn.md` if it exists:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

## Step 1: Gather Information
{Questions to ask user}

## Step 2: Plan Structure
{How to organize the output}

---

# HARD STOP - Human Review Gate

{Preview what will be done}

> "Ready to proceed? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Content
{How to create the output}

## Step 4: Quality Check
Before preview, verify:
- [ ] {Check 1}
- [ ] {Check 2}
- [ ] {Check 3}

## Step 5: Preview & Approval
Show complete output and ask:
> "Write to `{path}`? [y/n]"

## Step 6: Write Output
If approved:
1. Generate slug from input
2. Create path: `jaan-to/outputs/{role}/{domain}/{slug}/`
3. Write file
4. Confirm: "Written to {path}"

## Step 7: Capture Feedback
After writing:
> "Any feedback? [y/n]"

If yes, use `/to-jaan-learn-add {skill-name} "{feedback}"` to capture lessons.

---

## Definition of Done
- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] User has approved
```

### Required Sections

| Section | Level | Purpose |
|---------|-------|---------|
| `# {role}:{domain-action}` | H1 | Title with logical name |
| `> {tagline}` | blockquote | One-line description |
| `## Context Files` | H2 | Files to read before execution |
| `## Input` | H2 | How to interpret $ARGUMENTS |
| `# PHASE 1: Analysis` | H1 | Read-only operations |
| `## Step 0: Apply Past Lessons` | H2 | LEARN.md integration |
| `# HARD STOP` | H1 | Human approval gate |
| `# PHASE 2: Generation` | H1 | Write operations |
| `## Definition of Done` | H2 | Completion checklist |

---

## template.md Specification

Templates define output format with placeholders.

### Placeholder Syntax

Use `{field_name}` for dynamic content:

```markdown
# {title}

> Generated by jaan.to | {date}

---

## Section Name

{section_content}

---

## Metadata

- **Created**: {date}
- **Skill**: {skill_name}
```

### Required Metadata

All templates should include an Appendix or Metadata section with:

| Field | Purpose |
|-------|---------|
| `{date}` | Creation date |
| `{skill_name}` | Which skill generated this |
| `{status}` | Draft/Review/Final |

### Line Limits

| Output Type | Target | Max |
|-------------|--------|-----|
| PRD | 150-200 | 300 |
| Test Plan | 100-150 | 200 |
| API Contract | 80-120 | 150 |
| Short Report | 50-80 | 100 |

---

## LEARN.md Specification

Every skill accumulates lessons in LEARN.md.

### Structure

```markdown
# Lessons: {skill-name}

> Last updated: {YYYY-MM-DD}

Accumulated lessons from past executions.

---

## Better Questions

Questions to ask during information gathering:

- {lesson}

## Edge Cases

Special cases to check and handle:

- {lesson}

## Workflow

Process improvements:

- {lesson}

## Common Mistakes

Things to avoid:

- {lesson}
```

### Auto-Categorization Keywords

When adding lessons via `/to-jaan-learn-add`, category is detected by keywords:

| Category | Trigger Keywords |
|----------|------------------|
| Better Questions | ask, question, clarify, confirm, inquire |
| Edge Cases | edge, special, case, handle, scenario |
| Workflow | workflow, process, step, order, sequence |
| Common Mistakes | avoid, mistake, wrong, don't, never |

### Empty Starter

New skills start with empty sections:

```markdown
# Lessons: {skill-name}

> Last updated: {date}

Accumulated lessons from past executions.

---

## Better Questions

(none yet)

## Edge Cases

(none yet)

## Workflow

(none yet)

## Common Mistakes

(none yet)
```

---

## Validation Rules

### Frontmatter Checklist

- [ ] Has `name` matching directory
- [ ] Has `description` with purpose and mapping
- [ ] Has `allowed-tools` with valid tool patterns
- [ ] Has `argument-hint` showing expected format

### Body Checklist

- [ ] Has H1 title with logical name (`role:domain-action`)
- [ ] Has tagline blockquote
- [ ] Has `## Context Files` section
- [ ] Has `## Input` section
- [ ] Has `# PHASE 1: Analysis` section
- [ ] Has `## Step 0: Apply Past Lessons` section
- [ ] Has `# HARD STOP` section
- [ ] Has `# PHASE 2: Generation` section
- [ ] Has `## Definition of Done` section

### Trust Rules

- Write paths must be sandboxed (`jaan-to/**`, `docs/**`, etc.)
- Never allow `Write(*)` or unrestricted write
- Git operations must be pattern-restricted
- Always require human approval before writes

---

## Integration Patterns

### Stack Context

Skills should read stack files when relevant:

```markdown
## Context Files
Read these before execution:
- `jaan-to/context/tech.md` - Technology context
- `jaan-to/context/team.md` - Team structure and norms
- `jaan-to/context/integrations.md` - External tool config
```

### Hook Integration

Skills can trigger validation hooks:

| Hook Type | When | Use For |
|-----------|------|---------|
| `PreToolUse` | Before write | Validate content |
| `PostToolUse` | After write | Trigger feedback |

### Feedback Capture

End every skill with feedback option:

```markdown
## Step 7: Capture Feedback
After writing:
> "Any feedback? [y/n]"

If yes:
- Run `/to-jaan-learn-add {skill-name} "{feedback}"`
```

### Config Registration

Register new skills in `jaan-to/context/config.md`:

```markdown
## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| `pm:prd-write` | `/jaan-to-pm-prd-write` | Generate PRD |
| `your:new-skill` | `/your-new-skill` | Your description |
```

---

## Examples

### Minimal Skill

Simplest valid skill structure:

**`skills/example-minimal-demo/SKILL.md`**:

```markdown
---
name: example-minimal-demo
description: |
  Demonstrate minimal skill structure.
  Maps to: example:minimal-demo
allowed-tools: Read, Write(jaan-to/**)
argument-hint: [topic]
---

# example:minimal-demo

> Demonstrate minimal skill structure.

## Context Files
- `jaan-to/learn/example-minimal-demo.learn.md` - Past lessons

## Input

**Topic**: $ARGUMENTS

---

# PHASE 1: Analysis (Read-Only)

## Step 0: Apply Past Lessons
Read `jaan-to/learn/example-minimal-demo.learn.md` if it exists.

## Step 1: Gather Information
Ask: "What should the demo cover?"

---

# HARD STOP - Human Review Gate

> "Ready to generate demo for '{topic}'? [y/n]"

**Do NOT proceed without approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Content
Create simple markdown output.

## Step 4: Quality Check
- [ ] Has title
- [ ] Has content

## Step 5: Preview & Approval
> "Write to `jaan-to/outputs/example/minimal/{slug}/demo.md`? [y/n]"

## Step 6: Write Output
Write file if approved.

---

## Definition of Done
- [ ] Demo file written
- [ ] User approved
```

### Full-Featured Skill

Complete skill with all patterns:

**`skills/qa-test-matrix/SKILL.md`**:

```markdown
---
name: qa-test-matrix
description: |
  Generate a test matrix from feature requirements.
  Auto-triggers on: test planning, QA coverage, test matrix requests.
  Maps to: qa:test-matrix
allowed-tools: Read, Glob, Grep, Write(jaan-to/**)
argument-hint: [feature-name-or-prd-path]
---

# qa:test-matrix

> Generate comprehensive test matrix from feature requirements.

## Context Files
Read these before execution:
- `jaan-to/context/config.md` - Configuration
- `jaan-to/context/boundaries.md` - Safety rules
- `jaan-to/templates/qa-test-matrix.template.md` - Output template
- `jaan-to/learn/qa-test-matrix.learn.md` - Past lessons
- `jaan-to/context/tech.md` - Test tools and frameworks
- `jaan-to/context/team.md` - QA capacity and norms

## Input

**Feature**: $ARGUMENTS

If path to PRD provided, read it. Otherwise, ask for requirements.

---

# PHASE 1: Analysis (Read-Only)

## Step 0: Apply Past Lessons
Read `jaan-to/learn/qa-test-matrix.learn.md`:
- Add questions from "Better Questions"
- Check scenarios from "Edge Cases"
- Follow process from "Workflow"
- Avoid items in "Common Mistakes"

## Step 1: Gather Information
Ask these questions:
1. "What are the critical user journeys?"
2. "What browsers/devices need coverage?"
3. "What's the priority order for test cases?"
4. "Are there any known edge cases?"

## Step 2: Plan Matrix Structure
Organize by:
- Test categories (functional, integration, edge cases)
- Priority levels (P0, P1, P2)
- Coverage areas (happy path, error handling, edge cases)

---

# HARD STOP - Human Review Gate

Show planned structure:
> "Test matrix will cover:
> - {n} functional tests
> - {n} integration tests
> - {n} edge case tests
>
> Proceed with generation? [y/n]"

**Do NOT proceed without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Test Matrix
Use template from `jaan-to/templates/qa-test-matrix.template.md`:
- Fill all test categories
- Add priority levels
- Include pass/fail criteria
- Add browser/device matrix if applicable

## Step 4: Quality Check
Before preview, verify:
- [ ] Has at least 3 test categories
- [ ] Has priority levels assigned
- [ ] Has clear pass/fail criteria
- [ ] Has coverage for happy path AND error cases

If any check fails, revise before preview.

## Step 5: Preview & Approval
Show complete matrix and ask:
> "Write to `jaan-to/outputs/qa/test-matrix/{slug}/matrix.md`? [y/n]"

## Step 6: Write Output
If approved:
1. Generate slug: lowercase, hyphens, max 50 chars
2. Create path: `jaan-to/outputs/qa/test-matrix/{slug}/matrix.md`
3. Write the test matrix
4. Confirm: "Test matrix written to {path}"

## Step 7: Capture Feedback
> "Any feedback on the test matrix? [y/n]"

If yes:
> "What should be improved?"
> "[1] Fix now  [2] Learn for future  [3] Both"

- **Option 1**: Update matrix, re-preview, re-write
- **Option 2**: Run `/to-jaan-learn-add qa-test-matrix "{feedback}"`
- **Option 3**: Do both

---

## Definition of Done
- [ ] Test matrix file exists
- [ ] All quality checks pass
- [ ] User approved content
```

---

## Creation Checklist

### Before Creating

- [ ] Check if similar skill exists
- [ ] Determine role and domain
- [ ] Identify required tool permissions
- [ ] Plan the output format

### After Creating

- [ ] SKILL.md passes validation checklist
- [ ] Template exists (if skill has structured output)
- [ ] Skill registered in `context/config.md`
- [ ] Documentation added to `docs/skills/{role}/`

---

## Tips

- Start with fewer questions—add more via `/to-jaan-learn-add`
- Match output format to team expectations
- Read stack context instead of asking redundant questions
- Test with real scenarios before committing
- Keep SKILL.md focused on execution, not explanation

---

[Back to Extending](README.md) | [Create a Hook](create-hook.md)
