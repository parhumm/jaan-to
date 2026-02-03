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

| Aspect | Pattern (v3.0.0) |
|--------|------------------|
| Name | `{name}` |
| Command | `/{name}` |
| Directory | `skills/{name}/` (plugin) |
| Logical Name | `{role}:{domain-action}` |
| Output | `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/` (project) |
| Templates | `$JAAN_TEMPLATES_DIR/{name}.template.md` (project) |
| Learning | `$JAAN_LEARN_DIR/{name}.learn.md` (project) |
| Context | `$JAAN_CONTEXT_DIR/*.md` (project) |

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

### Tool Permission Patterns (v3.0.0)

**Always use environment variables** for path-based permissions:

| Pattern | Use Case |
|---------|----------|
| `Read` | Read any file |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents |
| `WebSearch` | Research best practices |
| `Task` | Launch specialized agents |
| `Write($JAAN_OUTPUTS_DIR/{role}/**)` | Write outputs only |
| `Write($JAAN_TEMPLATES_DIR/**)` | Update templates |
| `Write($JAAN_LEARN_DIR/**)` | Update learning files |
| `Read($JAAN_CONTEXT_DIR/**)` | Read project context |
| `Write(docs/**)` | Documentation skills |
| `Write(skills/**)` | Skill development |
| `Edit` | Modify existing files |
| `Bash(git add:*)` | Stage changes |
| `Bash(git commit:*)` | Commit changes |
| `Bash(git push:*)` | Push changes |
| `Bash(gh pr create:*)` | Create pull requests |

**v3.0.0 Best Practices**:
- ✓ Use `$JAAN_*` environment variables (supports path customization)
- ✗ Never use hardcoded `jaan-to/` paths (breaks customization)
- ✓ Be specific: `Write($JAAN_OUTPUTS_DIR/pm/**)` not `Write($JAAN_OUTPUTS_DIR/**)`
- ✗ Never use `Write(**)` (too broad, security risk)

### Markdown Body Structure (v3.0.0)

After frontmatter, SKILL.md follows this structure:

```markdown
# {role}:{domain-action}

> {One-line purpose}

## Context Files

Read these before execution:
- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_TEMPLATES_DIR/{name}.template.md` - Output template
- `$JAAN_LEARN_DIR/{name}.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (if skill is tech-aware)

## Input

**{Input Name}**: $ARGUMENTS

{Instructions for interpreting input}

---

# PHASE 1: Analysis (Read-Only)

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/{name}.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

## Step 1: Gather Information
{Questions to ask user}

## Step 2: Plan Structure
{How to organize the output}

---

# HARD STOP - Human Review Gate

{Preview what will be done}

Use AskUserQuestion to ask the user:
- Question: "Ready to proceed with generation?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the output
  - "No" — Cancel and start over
  - "Edit" — Let me revise the inputs first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Content

Use template from: `$JAAN_TEMPLATES_DIR/{name}.template.md`

{How to create the output}

## Step 4: Quality Check

Before preview, verify:
- [ ] {Check 1}
- [ ] {Check 2}
- [ ] {Check 3}

If any check fails, revise before preview.

## Step 5: Preview & Approval

Show complete output, then use AskUserQuestion:
- Question: "Write to `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/{filename}`?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "No" — Cancel

## Step 6: Write Output

If approved:
1. Generate slug from input: lowercase, hyphens, no special chars
2. Create path: `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/`
3. Write file: `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/{filename}`
4. Confirm: "Written to {path}"

## Step 7: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the output?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update this output
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update output, re-preview, re-write
- **Learn**: Run `/to-jaan-learn-add {skill-name} "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] User has approved final result
```

### User Interaction Patterns

Skills interact with users via two patterns. Choose the right one for each interaction:

| Pattern | When to Use | Limit |
|---------|-------------|-------|
| `AskUserQuestion` | 2-4 fixed options, confirmations, mode selection | 1-4 questions per call, 2-4 options each |
| Text prompt | Open-ended input, 5+ options, multi-line, key-value pairs | No limit |

**Rules:**
- **Use AskUserQuestion for:** HARD STOP confirmations, preview approvals, feedback handling, mode/type selection with 2-4 choices
- **Use text prompts for:** Open-ended questions, menus with 5+ options, multi-line input, free-form parameters
- **Grouping:** Batch related questions into a single AskUserQuestion call (max 4 questions)
- **"Other" option:** Always include on non-binary choices for free-text escape hatch
- **Descriptions required:** Every option needs a short description (not just a label)
- **Header limit:** Max 12 characters

**AskUserQuestion JSON schema:**
```json
{
  "questions": [{
    "question": "Full question text",
    "header": "Short",
    "options": [
      { "label": "Yes", "description": "Proceed with generation" },
      { "label": "No", "description": "Cancel and start over" }
    ],
    "multiSelect": false
  }]
}
```

**Instruction syntax in SKILL.md:**

For single questions:
```markdown
Use AskUserQuestion to ask the user:
- Question: "Ready to proceed with generation?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the output
  - "No" — Cancel and start over
  - "Edit" — Let me revise the inputs first
```

For grouped questions (max 4):
```markdown
Use a single AskUserQuestion call with these questions:

1. Header: "Goal" | Question: "What's your primary goal?"
   - "Learning" — Understand concepts and theory
   - "Implementation" — Ready-to-use code and patterns
   - "Comparison" — Evaluate alternatives

2. Header: "Depth" | Question: "How deep should it go?"
   - "Overview" — High-level summary
   - "Detailed" — Balanced depth
   - "Expert" — Expert-level detail
```

For questions that must stay as text:
```markdown
Ask the user (text response expected):
> "What problem does this solve for users?"
```

**Edge case — too many options (5+):**
- Split into 2-step interaction: broader category first (AskUserQuestion), then narrower choice
- Or reduce to 3 options + "Other" for free-text escape
- Or keep as numbered text menu if options can't be meaningfully grouped

### Required Sections

| Section | Level | Purpose |
|---------|-------|---------|
| `# {role}:{domain-action}` | H1 | Title with logical name |
| `> {tagline}` | blockquote | One-line description |
| `## Context Files` | H2 | Files to read before execution |
| `## Input` | H2 | How to interpret $ARGUMENTS |
| `# PHASE 1: Analysis` | H1 | Read-only operations |
| `## Step 0: Apply Past Lessons` | H2 | LEARN.md integration |
| `# HARD STOP` | H1 | Human approval gate (uses AskUserQuestion) |
| `# PHASE 2: Generation` | H1 | Write operations |
| `## Definition of Done` | H2 | Completion checklist |

---

## v3.0.0 Configuration System

### Overview

v3.0.0 introduces a multi-layer configuration system that allows path customization while maintaining backward compatibility.

### Environment Variables

Skills use environment variables for all paths:

| Variable | Default | Purpose |
|----------|---------|---------|
| `$JAAN_OUTPUTS_DIR` | `jaan-to/outputs` | Generated files |
| `$JAAN_TEMPLATES_DIR` | `jaan-to/templates` | Output templates |
| `$JAAN_LEARN_DIR` | `jaan-to/learn` | Learning files |
| `$JAAN_CONTEXT_DIR` | `jaan-to/context` | Project context |

**Key Benefits**:
- Users can customize paths via `jaan-to/config/settings.yaml`
- Skills work in any project structure (monorepos, custom layouts)
- Paths resolve automatically at runtime

### Configuration Layers

1. **Plugin Defaults** (`config/defaults.yaml`):
   ```yaml
   version: "3.0"
   paths_templates: "jaan-to/templates"
   paths_learning: "jaan-to/learn"
   paths_context: "jaan-to/context"
   paths_outputs: "jaan-to/outputs"
   ```

2. **Project Settings** (`jaan-to/config/settings.yaml`):
   ```yaml
   version: "3.0"

   # Path customization (optional)
   paths_outputs: "artifacts/generated"
   paths_templates: "docs/templates"

   # Template customization (optional)
   templates_pm-prd-write_path: "./custom/enterprise-prd.md"

   # Learning strategy (optional)
   learning_strategy: "merge"  # Options: merge, override
   ```

3. **Runtime Resolution**:
   - Project settings override plugin defaults
   - Environment variables reflect final resolved paths
   - Skills use variables, never hardcoded paths

### Path Customization Example

**Default behavior** (zero config):
```bash
# Skill writes to:
$JAAN_OUTPUTS_DIR/pm/feature-name/prd.md
# Resolves to:
jaan-to/outputs/pm/feature-name/prd.md
```

**Custom paths** (via settings.yaml):
```yaml
paths_outputs: "build/artifacts"
```

```bash
# Same skill command
# Now writes to:
build/artifacts/pm/feature-name/prd.md
```

### Migration from v2.x

**v2.x pattern** (deprecated):
```yaml
allowed-tools: Write(jaan-to/outputs/**)
```

```markdown
Create path: `jaan-to/outputs/pm/{slug}/`
```

**v3.0.0 pattern** (current):
```yaml
allowed-tools: Write($JAAN_OUTPUTS_DIR/pm/**)
```

```markdown
Create path: `$JAAN_OUTPUTS_DIR/pm/{slug}/`
```

**Auto-migration**:
```bash
# Use auto-fix script
bash scripts/lib/v3-autofix.sh {skill-name}

# Or use skill validator
/to-jaan-skill-update {skill-name}
# → Select option [8] Migrate to v3.0.0
```

---

## Template Variables (v3.0.0)

### Overview

Templates support four types of variables for dynamic content generation.

### 1. Field Variables

Basic placeholder substitution:

```markdown
# {{title}}

> Generated by jaan.to | {{date}}
> Author: {{author}}

## Problem Statement

{{problem}}

## Solution Overview

{{solution}}
```

**Usage in SKILL.md**:
```markdown
## Step 3: Generate Content

Fill template variables:
- `{{title}}` - Feature name from input
- `{{date}}` - Current date (YYYY-MM-DD)
- `{{author}}` - User's git name or "jaan.to"
- `{{problem}}` - Problem statement from Step 1
- `{{solution}}` - Solution overview from Step 1
```

### 2. Environment Variables

Access runtime paths:

```markdown
## Output Location

This file was generated at:
{{env:JAAN_OUTPUTS_DIR}}/{{role}}/{{domain}}/

Customizable via `jaan-to/config/settings.yaml`.
```

**Supported variables**:
- `{{env:JAAN_OUTPUTS_DIR}}`
- `{{env:JAAN_TEMPLATES_DIR}}`
- `{{env:JAAN_CONTEXT_DIR}}`
- `{{env:JAAN_LEARN_DIR}}`
- `{{env:CUSTOM_VAR}}` - Any shell environment variable

### 3. Configuration Variables

Access project configuration:

```markdown
## Configuration

Template source: {{config:paths_templates}}
Learning strategy: {{config:learning_strategy}}
```

**Usage**:
- `{{config:paths_templates}}` - From settings.yaml
- `{{config:paths_outputs}}` - From settings.yaml
- `{{config:custom_field}}` - Any key from settings.yaml

### 4. Section Imports

Import markdown sections from context files:

```markdown
## Technical Context

**Stack**:
{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

**Constraints**:
{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}

**Common Patterns**:
{{import:$JAAN_CONTEXT_DIR/tech.md#patterns}}
```

**Syntax**:
```
{{import:$JAAN_CONTEXT_DIR/{file}#{anchor}}}
```

**Standard Anchors** (tech.md):
- `#current-stack` - Languages, frameworks, databases
- `#frameworks` - Framework-specific details
- `#constraints` - Technical constraints and requirements
- `#versioning` - API versioning, deprecation policies
- `#patterns` - Common patterns (auth, errors, data access)
- `#tech-debt` - Known technical debt items

### Complete Template Example

```markdown
# {{title}}

> Generated by jaan.to | {{date}}
> Author: {{author}}

---

## Problem Statement

{{problem}}

## Solution Overview

{{solution}}

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
{{metrics_table}}

## Technical Context

**Stack**:
{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

**Constraints**:
{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}

## Scope

### In Scope
{{in_scope}}

### Out of Scope
{{out_of_scope}}

## User Stories

{{user_stories}}

---

## Metadata

| Field | Value |
|-------|-------|
| Generated | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/{{role}}/{{domain}}/ |
| Skill | {{skill_name}} |
| Version | 3.0 |
| Status | Draft |
```

---

## Tech Stack Integration

### When to Use

Skills should be "tech-aware" when they:
- Generate code or technical specifications
- Reference frameworks or languages
- Need to comply with technical constraints
- Create implementation plans

### Implementation Pattern

**1. Declare in Context Files**:

```markdown
## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (if exists)
```

**2. Read in Pre-Execution or Step 1**:

```markdown
## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Read:
1. `$JAAN_LEARN_DIR/{name}.learn.md`
2. `$JAAN_CONTEXT_DIR/tech.md` (if exists)
```

**3. Use in Generation**:

```markdown
## Step 3: Generate PRD

If tech.md exists:
1. Reference appropriate tech stack in User Stories:
   - Backend: "API endpoint in {{backend_framework}}"
   - Frontend: "UI component in {{frontend_framework}}"
   - Mobile: "{{mobile_platform}} screen"

2. Include Technical Constraints section:
   - Import: `{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}`

3. Mention relevant frameworks from tech.md in Implementation Notes
```

**4. Update Template**:

```markdown
## Technical Context

**Stack**:
{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

**Constraints**:
{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}

**Relevant Patterns**:
{{import:$JAAN_CONTEXT_DIR/tech.md#patterns}}
```

### tech.md Structure

Skills expect this structure:

```markdown
# Technology Stack

## Current Stack {#current-stack}

### Backend
- **Language**: Python 3.11
- **Framework**: FastAPI 0.104
- **Database**: PostgreSQL 15

### Frontend
- **Language**: TypeScript 5.2
- **Framework**: React 18 + Next.js 14

### Mobile
- **iOS**: Swift 5.9 + SwiftUI
- **Android**: Kotlin 1.9 + Jetpack Compose

## Frameworks {#frameworks}

### API Development
- FastAPI (REST endpoints)
- Pydantic (validation)
- SQLAlchemy (ORM)

## Technical Constraints {#constraints}

1. **All APIs must return JSON:API format**
2. **Mobile apps must work offline**
3. **Sub-200ms p95 latency**

## Common Patterns {#patterns}

### Authentication
- OAuth2 + JWT (15min access, 7d refresh)

### Error Handling
- Structured errors with error codes

## Tech Debt {#tech-debt}

- [ ] Migrate Python 3.11 → 3.12 (Q3 2024)
- [ ] Split monolith → microservices (Q4 2024)
```

### Benefits

**Without tech integration**:
```markdown
## User Stories

1. User can search for products
2. User can add products to cart
3. User can checkout
```

**With tech integration**:
```markdown
## User Stories

1. **Search Products**
   - Frontend: Search UI in React with debounced input
   - Backend: GET /v1/products?q= endpoint in FastAPI
   - Constraint: Sub-200ms response time

2. **Add to Cart**
   - Frontend: Redux cart state management
   - Backend: POST /v1/cart/items in FastAPI
   - Mobile: Offline-first with sync on reconnect

3. **Checkout**
   - Frontend: Next.js server components for SSR
   - Backend: OAuth2 authentication required
   - Constraint: JSON:API format response
```

---

## Learning Merge Strategy

### Overview

v3.0.0 supports two learning strategies: **merge** (default) and **override**.

### Merge Strategy (Default)

Combines lessons from plugin defaults + project customizations:

**Plugin LEARN.md** (`skills/{name}/LEARN.md`):
```markdown
## Better Questions

- Plugin question 1
- Plugin question 2

## Workflow

- Plugin workflow step 1
```

**Project LEARN.md** (`$JAAN_LEARN_DIR/{name}.learn.md`):
```markdown
## Better Questions

- Project-specific question 1

## Edge Cases

- Project edge case 1
```

**Runtime merged view**:
```markdown
## Better Questions

<!-- source: plugin -->
- Plugin question 1
- Plugin question 2

<!-- source: project -->
- Project-specific question 1

## Edge Cases

<!-- source: project -->
- Project edge case 1

## Workflow

<!-- source: plugin -->
- Plugin workflow step 1
```

### Override Strategy

Project lessons completely replace plugin defaults:

```yaml
# jaan-to/config/settings.yaml
learning_strategy: "override"
```

- If `$JAAN_LEARN_DIR/{name}.learn.md` exists: use project only
- If not: fall back to plugin `LEARN.md`

### Configuration

**Enable merge** (default):
```yaml
# jaan-to/config/settings.yaml
learning_strategy: "merge"
```

**Enable override**:
```yaml
learning_strategy: "override"
```

### Use Cases

**Merge**: Teams want to keep plugin best practices + add company-specific lessons
**Override**: Teams want full control over all lessons (replace plugin defaults)

---

## template.md Specification (v3.0.0)

Templates define output format with variable placeholders.

### Variable Syntax

v3.0.0 uses `{{double-brace}}` syntax for all variables:

```markdown
# {{title}}

> Generated by jaan.to | {{date}}
> Author: {{author}}

---

## Section Name

{{section_content}}

## Technical Context

**Stack**:
{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

---

## Metadata

| Field | Value |
|-------|-------|
| Created | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/{{role}}/{{domain}}/ |
| Skill | {{skill_name}} |
| Status | {{status}} |
| Version | 3.0 |
```

### Required Metadata

All templates should include a Metadata table with:

| Field | Variable | Purpose |
|-------|----------|---------|
| Created | `{{date}}` | Generation date (YYYY-MM-DD) |
| Output Path | `{{env:JAAN_OUTPUTS_DIR}}/...` | Where file was written |
| Skill | `{{skill_name}}` | Which skill generated this |
| Status | `{{status}}` | Draft/Review/Final |
| Version | `3.0` | Template version |

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
- [ ] HARD STOP uses AskUserQuestion (not text prompt)
- [ ] Preview approval uses AskUserQuestion (not text prompt)
- [ ] Feedback section uses AskUserQuestion with 3-4 options
- [ ] Structured choices (2-4 options) use AskUserQuestion
- [ ] Open-ended questions use text prompts

### Trust Rules

- Write paths must be sandboxed (`jaan-to/**`, `docs/**`, etc.)
- Never allow `Write(*)` or unrestricted write
- Git operations must be pattern-restricted
- Always require human approval before writes

---

## Integration Patterns (v3.0.0)

### Stack Context

Skills should read context files when relevant:

```markdown
## Context Files

Read these before execution:
- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_CONTEXT_DIR/tech.md` - Technology context
- `$JAAN_CONTEXT_DIR/team.md` - Team structure and norms
- `$JAAN_CONTEXT_DIR/integrations.md` - External tool config
- `$JAAN_TEMPLATES_DIR/{name}.template.md` - Output template
- `$JAAN_LEARN_DIR/{name}.learn.md` - Past lessons
```

### Hook Integration

Skills can trigger validation hooks:

| Hook Type | When | Use For |
|-----------|------|---------|
| `PreToolUse` | Before write | Validate content |
| `PostToolUse` | After write | Trigger feedback |

### Feedback Capture

End every skill with feedback option using AskUserQuestion:

```markdown
## Step 7: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the output?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update this output
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update output, re-preview, re-write
- **Learn**: Run `/to-jaan-learn-add {skill-name} "{feedback}"`
- **Both**: Do both
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

### Minimal Skill (v3.0.0)

Simplest valid skill structure:

**`skills/example-minimal-demo/SKILL.md`**:

```markdown
---
name: example-minimal-demo
description: |
  Demonstrate minimal skill structure.
  Auto-triggers on: demo, example, test skill.
  Maps to: example:minimal-demo
allowed-tools: Read, Write($JAAN_OUTPUTS_DIR/example/**)
argument-hint: [topic]
---

# example:minimal-demo

> Demonstrate minimal skill structure.

## Context Files

- `$JAAN_LEARN_DIR/example-minimal-demo.learn.md` - Past lessons (loaded in Pre-Execution)

## Input

**Topic**: $ARGUMENTS

---

# PHASE 1: Analysis (Read-Only)

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/example-minimal-demo.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

## Step 1: Gather Information

Ask: "What should the demo cover?"

---

# HARD STOP - Human Review Gate

Preview: "Will generate demo about '{topic}'"

Use AskUserQuestion to ask the user:
- Question: "Ready to generate demo for '{topic}'?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the demo
  - "No" — Cancel and start over
  - "Edit" — Let me revise the topic first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Content

Create simple markdown output with:
- Title based on topic
- Current date
- Demo content

## Step 4: Quality Check

- [ ] Has title
- [ ] Has content
- [ ] Has metadata section

If any check fails, revise before preview.

## Step 5: Preview & Approval

Show complete output, then use AskUserQuestion:
- Question: "Write to `$JAAN_OUTPUTS_DIR/example/minimal/{slug}/demo.md`?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "No" — Cancel

## Step 6: Write Output

If approved:
1. Generate slug from topic: lowercase, hyphens
2. Create path: `$JAAN_OUTPUTS_DIR/example/minimal/{slug}/`
3. Write file: `$JAAN_OUTPUTS_DIR/example/minimal/{slug}/demo.md`
4. Confirm: "Written to {path}"

## Step 7: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the demo?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update this output
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update output, re-preview, re-write
- **Learn**: Run `/to-jaan-learn-add example-minimal-demo "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] Demo file written to correct path
- [ ] All quality checks pass
- [ ] User approved final result
```

### Full-Featured Skill (v3.0.0)

Complete skill with all v3.0.0 patterns:

**`skills/jaan-to-qa-test-matrix/SKILL.md`**:

```markdown
---
name: jaan-to-qa-test-matrix
description: |
  Generate comprehensive test matrix from feature requirements.
  Auto-triggers on: test planning, QA coverage, test matrix requests.
  Maps to: qa:test-matrix
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write($JAAN_OUTPUTS_DIR/qa/**)
argument-hint: [feature-name-or-prd-path]
---

# qa:test-matrix

> Generate comprehensive test matrix from feature requirements.

## Context Files

Read these before execution:
- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_CONTEXT_DIR/boundaries.md` - Safety rules
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-test-matrix.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-qa-test-matrix.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Test frameworks and tools (if exists)
- `$JAAN_CONTEXT_DIR/team.md` - QA capacity and norms (if exists)

## Input

**Feature**: $ARGUMENTS

If path to PRD provided, read it. Otherwise, ask for requirements.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing test coverage gaps
- Planning comprehensive test scenarios
- Ensuring edge case coverage

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-qa-test-matrix.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know test frameworks and tooling

## Step 1: Gather Information

Ask these questions (+ any from LEARN.md):
1. "What are the critical user journeys?"
2. "What browsers/devices need coverage?"
3. "What's the priority order for test cases?"
4. "Are there any known edge cases?"
5. "What test automation frameworks are in use?" (if tech.md not available)

## Step 2: Plan Matrix Structure

Organize by:
- Test categories (functional, integration, edge cases, performance)
- Priority levels (P0-Critical, P1-High, P2-Medium)
- Coverage areas (happy path, error handling, edge cases, security)
- Test types (manual, automated, E2E)

If tech.md exists, include:
- Framework-specific test patterns
- Browser/device matrix from tech constraints
- Performance targets from tech.md

---

# HARD STOP - Human Review Gate

Show planned structure:
> Test matrix will cover:
> - {n} functional tests (P0: {x}, P1: {y}, P2: {z})
> - {n} integration tests
> - {n} edge case tests
> - {n} performance tests (if tech constraints exist)
>
> Test frameworks: {from tech.md or user input}
> Browsers/devices: {from tech.md or user input}

Use AskUserQuestion to ask the user:
- Question: "Proceed with test matrix generation?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the test matrix
  - "No" — Cancel and start over
  - "Edit" — Let me revise the plan first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Test Matrix

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to-qa-test-matrix.template.md`

Fill variables:
- `{{title}}` - Feature name
- `{{date}}` - Current date
- `{{test_categories}}` - Generated test categories
- `{{priority_breakdown}}` - P0/P1/P2 counts

If tech.md exists, include:
- `{{import:$JAAN_CONTEXT_DIR/tech.md#frameworks}}` in Test Tools section
- `{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}` in Constraints section

## Step 4: Quality Check

Before preview, verify:
- [ ] Has at least 3 test categories
- [ ] Has priority levels assigned (P0/P1/P2)
- [ ] Has clear pass/fail criteria for each test
- [ ] Has coverage for happy path AND error cases
- [ ] Has edge cases documented
- [ ] If tech.md exists: references correct test frameworks
- [ ] If tech.md exists: includes performance targets

If any check fails, revise before preview.

## Step 5: Preview & Approval

Show complete matrix, then use AskUserQuestion:
- Question: "Write to `$JAAN_OUTPUTS_DIR/qa/test-matrix/{slug}/matrix.md`?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "No" — Cancel

## Step 6: Write Output

If approved:
1. Generate slug from feature name: lowercase, hyphens, no special chars, max 50 chars
2. Create path: `$JAAN_OUTPUTS_DIR/qa/test-matrix/{slug}/`
3. Write file: `$JAAN_OUTPUTS_DIR/qa/test-matrix/{slug}/matrix.md`
4. Confirm: "Test matrix written to {path}"

## Step 7: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the test matrix?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update this output
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update matrix, re-preview, re-write
- **Learn**: Run `/to-jaan-learn-add jaan-to-qa-test-matrix "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] Test matrix file exists at correct path
- [ ] All quality checks pass
- [ ] Tech stack integrated (if tech.md available)
- [ ] Priority levels assigned to all tests
- [ ] Edge cases documented
- [ ] User approved final content
```

---

## v3.0.0 Migration Checklist

### Automated Migration

Use the auto-fix script for quick migration:

```bash
# Migrate a single skill
bash scripts/lib/v3-autofix.sh {skill-name}

# Or use the skill validator
/to-jaan-skill-update {skill-name}
# → Select option [8] Migrate to v3.0.0
# → Choose migration approach (auto-fix, interactive, script, guidance)
```

### Manual Migration Steps

If migrating manually:

#### 1. Update Frontmatter Permissions

```yaml
# Before (v2.x)
allowed-tools: Write(jaan-to/outputs/**), Read(jaan-to/context/**)

# After (v3.0.0)
allowed-tools: Write($JAAN_OUTPUTS_DIR/**), Read($JAAN_CONTEXT_DIR/**)
```

**Find & Replace**:
- `Write(jaan-to/outputs/**)` → `Write($JAAN_OUTPUTS_DIR/**)`
- `Read(jaan-to/context/**)` → `Read($JAAN_CONTEXT_DIR/**)`
- `Edit(jaan-to/templates/**)` → `Edit($JAAN_TEMPLATES_DIR/**)`
- `Write(jaan-to/learn/**)` → `Write($JAAN_LEARN_DIR/**)`
- `Edit(jaan-to/**)` → `Edit($JAAN_TEMPLATES_DIR/**), Edit($JAAN_LEARN_DIR/**)`

#### 2. Update Context Files Section

```markdown
# Before (v2.x)
## Context Files
- `jaan-to/context/config.md` - Configuration
- `jaan-to/learn/{name}.learn.md` - Past lessons
- `skills/{name}/template.md` - Template

# After (v3.0.0)
## Context Files
- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_LEARN_DIR/{name}.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/{name}.template.md` - Output template
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (if tech-aware)
```

**Find & Replace**:
- `` `jaan-to/context/ `` → `` `$JAAN_CONTEXT_DIR/ ``
- `` `jaan-to/learn/ `` → `` `$JAAN_LEARN_DIR/ ``
- `` `jaan-to/templates/ `` → `` `$JAAN_TEMPLATES_DIR/ ``
- `` `skills/{name}/template.md` `` → `` `$JAAN_TEMPLATES_DIR/{name}.template.md` ``

#### 3. Update Pre-Execution Section

```markdown
# Before (v2.x)
## Step 0: Apply Past Lessons
Read `jaan-to/learn/{name}.learn.md` if it exists:

# After (v3.0.0)
## Pre-Execution: Apply Past Lessons
**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/{name}.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
```

**Changes**:
- Rename "Step 0" → "Pre-Execution"
- Add MANDATORY FIRST ACTION emphasis
- Use `$JAAN_LEARN_DIR` variable
- Expand explanation of how to apply lessons

#### 4. Update Template References

```markdown
# Before (v2.x)
Use template from `skills/{name}/template.md`

# After (v3.0.0)
Use template from: `$JAAN_TEMPLATES_DIR/{name}.template.md`
```

#### 5. Update Output Paths

```markdown
# Before (v2.x)
Write to `jaan-to/outputs/{role}/{domain}/{slug}/`

# After (v3.0.0)
Write to `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/`
```

**Find & Replace**:
- `` `jaan-to/outputs/ `` → `` `$JAAN_OUTPUTS_DIR/ ``
- `Create path: jaan-to/outputs/` → `Create path: $JAAN_OUTPUTS_DIR/`

#### 6. Update template.md (if exists)

```markdown
# Before (v2.x)
## Metadata
- Created: {date}
- Skill: {skill_name}

# After (v3.0.0)
## Metadata
| Field | Value |
|-------|-------|
| Created | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/{{role}}/{{domain}}/ |
| Skill | {{skill_name}} |
| Version | 3.0 |
```

**Changes**:
- Replace `{field}` → `{{field}}` (double braces)
- Add environment variable: `{{env:JAAN_OUTPUTS_DIR}}`
- Add version field
- Convert to table format

#### 7. Validate Migration

After migration, run validation:

```bash
# Use skill validator
/to-jaan-skill-update {skill-name}
```

Check v3.0.0 compliance:
- [ ] ✓ V3.1: Frontmatter uses `$JAAN_*` variables
- [ ] ✓ V3.2: Context paths use `$JAAN_*`
- [ ] ✓ V3.3: Learning path uses `$JAAN_LEARN_DIR`
- [ ] ✓ V3.4: Template path uses `$JAAN_TEMPLATES_DIR`
- [ ] ✓ V3.5: Output paths use `$JAAN_OUTPUTS_DIR`
- [ ] ✓ V3.6: template.md uses `{{double-brace}}` syntax
- [ ] ✓ V3.7: Tech integration (if applicable)

If all checks pass: **v3.0.0 Compliant** ✓

### Rollback Plan

If issues occur after migration:

```bash
# Restore backups created by auto-fix script
mv skills/{name}/SKILL.md.v2.backup skills/{name}/SKILL.md
mv skills/{name}/template.md.v2.backup skills/{name}/template.md
```

### Testing Post-Migration

After migration, test the skill:

```bash
# Test with example input
/{skill-name} "{example-input}"

# Verify:
# 1. Skill runs without errors
# 2. Output written to correct path
# 3. Template variables resolved correctly
# 4. Tech integration works (if applicable)
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
