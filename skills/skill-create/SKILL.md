---
name: skill-create
description: Guide users through creating new jaan.to skills step-by-step.
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write(skills/**), Write(docs/**), Write($JAAN_OUTPUTS_DIR/**), Edit($JAAN_TEMPLATES_DIR/**), Edit($JAAN_LEARN_DIR/**), Edit(jaan-to/config/settings.yaml), Bash(git checkout:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [optional-skill-idea]
---

# skill-create

> Guide users through creating new jaan.to skills with web research and best practices.

## Context Files

- `docs/extending/create-skill.md` - Skill creation specification (v3.0.0)
- `$JAAN_LEARN_DIR/jaan-to:skill-create.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:skill-create.template.md` - Generation templates
- `$JAAN_CONTEXT_DIR/config.md` - Current skill catalog

## Input

**Skill Idea**: $ARGUMENTS

If provided, use as starting context. Otherwise, begin with identity questions.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:skill-create.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

**v3.0.0 Common Mistakes to Avoid** (regardless of LEARN.md):
- ✗ Using hardcoded `jaan-to/outputs/` instead of `$JAAN_OUTPUTS_DIR`
- ✗ Using hardcoded `jaan-to/templates/` instead of `$JAAN_TEMPLATES_DIR`
- ✗ Using hardcoded `jaan-to/learn/` instead of `$JAAN_LEARN_DIR`
- ✗ Using hardcoded `jaan-to/context/` instead of `$JAAN_CONTEXT_DIR`
- ✗ Forgetting `#anchor` syntax when importing tech.md sections
- ✗ Using too-broad permissions like `Write(jaan-to/**)`
- ✗ Not validating with `/jaan-to:skill-update` before user testing

If the file does not exist, continue without it (but still avoid mistakes above).

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_skill-create` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

# PHASE 0: Duplicate Detection (Single Source of Truth)

Before any creation, check for existing skills:

1. **Glob** `skills/*/SKILL.md` to get all skills
2. **For each skill**, compare:
   - Role + domain match
   - Purpose description similarity
   - Calculate overlap score (0-100%)

3. **Decision tree**:
   - **Exact match exists**: "Skill '{name}' already does this. Use: `/{command}` [show example]"
   - **>70% overlap**: "'{name}' is similar ({n}% overlap). Update it instead? [update/new]"
     - If update: Invoke `/jaan-to:skill-update {name}`
     - If new: Continue with creation
   - **<70% overlap**: Continue with creation

4. **Fast-track option** for simple skills:
   > "This seems straightforward. Create minimal skill directly? [y/wizard]"

   Skip wizard for:
   - Single-purpose skills with obvious structure
   - Skills that wrap an existing command
   - Internal/utility skills with <50 lines expected

---

# PHASE 1: Analysis (Interactive + Research)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing user requirements
- Planning skill structure
- Validating against specification
- Research synthesis

## Questioning Guidelines

Ask up to 7 clarifying questions across Phase 1 if needed.

**Skip questions when**:
- Information already provided in user input
- Research answered the question
- Context files contain the answer
- Question is redundant with previous answer

**Make questions smart**:
- Reference user's input: "You said '{X}' — does that mean...?"
- Build on research: "Best practices suggest Y — does that fit your case?"
- Probe specifics: "What should happen when Z?"

## Step 1: Basic Identity

Ask these questions one at a time:

| Question | Purpose | Validation |
|----------|---------|------------|
| "What role does this skill serve?" | Determine role prefix | Must be: pm, dev, qa, ux, data, growth, or custom |
| "What domain/area does it work in?" | Determine domain | 1-2 words, lowercase, hyphens allowed |
| "What action does it perform?" | Determine action verb | write, create, add, review, generate, update, analyze, etc. |

**After answers**, validate and show:
> "Skill name will be: `{role}-{domain}-{action}`"
> "Command: `/jaan-to:{role}-{domain}-{action}`"
> "Directory: `skills/{role}-{domain}-{action}/`"

## Step 1.5: Check Project Configuration (v3.0.0)

Before proceeding with design, understand the project's configuration:

1. **Check if configuration exists**:
   - Read `jaan-to/config/settings.yaml` (if exists)
   - Note any custom path configurations

2. **Path customization check**:
   - Are default paths customized?
   - If `settings.yaml` has `paths:` section, note custom locations
   - Skills should use `$JAAN_*` env vars (automatically resolve to correct paths)

3. **Learning strategy**:
   - Check `settings.yaml` for `learning.strategy: "merge"` or `"override"`
   - **merge**: Combine plugin + project lessons (default, recommended)
   - **override**: Use only project lessons (ignore plugin defaults)

4. **Template customization**:
   - Check if custom templates exist for similar skills
   - Pattern: `templates.{skill-name}.path: "./custom/path.md"`
   - If project has custom templates, new skill should follow same pattern

**Information helps generate skills that work correctly with the project's configuration.**

> "Configuration checked: [default paths / custom paths detected]"

## Step 2: Web Research (Token-Optimized)

Use **Task tool with Explore subagent** to isolate research tokens:

```
Task prompt: "Research best practices for {domain} {action}:
1. Search '{domain} best practices {year}'
2. Search '{domain} report template'
3. Search 'how to {action} {domain}'
4. Search '{domain} checklist'

Return:
- 3-5 key best practices
- Suggested questions the skill should ask
- Suggested quality checks
- Suggested output sections
- Sources used"
```

**Present research summary to user**:
> "Research findings for {domain}:
>
> **Best Practices Found:**
> 1. {practice1}
> 2. {practice2}
> ...
>
> **Suggested Questions for Skill:**
> - {question1}
> - {question2}
> ...
>
> **Suggested Quality Checks:**
> - [ ] {check1}
> - [ ] {check2}
> ...
>
> **Suggested Output Sections:**
> - {section1}
> - {section2}
> ..."

## Step 3: Purpose & Triggers

Show research-based suggestions, then ask:

1. "What does this skill do? (1-2 sentences)"
   - [Suggested from research]: "{suggested_description}"

2. "What phrases should auto-trigger this skill?"
   - [Suggested]: {action} {domain}, {domain} {action}, etc.

## Step 4: Input & Output

1. "What input does the skill need?"
   - Examples: file path, topic name, feature description
   - Will become `$ARGUMENTS` handling

2. "What files/outputs does it produce?"
   - [Suggested from templates]: {format} file with {sections}

3. "What format? (markdown/json/both)"
   - Determines template.md creation

## Step 5: Questions, Quality & Done

Present research-based suggestions, let user accept/modify/add:

1. "What questions should the skill ask users?"
   - [Pre-filled from research]:
     - {research_question1}
     - {research_question2}
   - "Add more or modify? [accept/edit]"

2. "What quality checks before writing?"
   - [Pre-filled from research]:
     - [ ] {research_check1}
     - [ ] {research_check2}
   - "Add more or modify? [accept/edit]"

3. "What defines 'done' for this skill?"
   - [Suggested]:
     - [ ] Output file written
     - [ ] Quality checks pass
     - [ ] User approved

---

# HARD STOP - Human Review Check

Present complete skill structure:

```
SKILL SUMMARY
─────────────
Name: {role}-{domain}-{action}
Command: /{role}-{domain}-{action}
Logical: {role}-{domain}-{action}
Description: {description}

RESEARCH USED
─────────────
Sources: {source_count} web sources consulted
Best practices incorporated: {practice_count}

FILES TO CREATE
───────────────
□ skills/{name}/SKILL.md
□ skills/{name}/LEARN.md
□ skills/{name}/template.md (if needed)

WILL ALSO
─────────
□ Register in scripts/seeds/config.md
□ Create docs/skills/{role}/{name}.md (via /jaan-to:docs-create)
□ Commit to branch skill/{name}
```

> "Create this skill? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Create Git Branch

```bash
git checkout dev
git pull origin dev
git checkout -b skill/{role}-{domain}-{action}
```

Confirm: "Created branch `skill/{name}` from `dev`. All work on this branch."

## Step 7: Generate SKILL.md

Use template from `$JAAN_TEMPLATES_DIR/jaan-to:skill-create.template.md`:

1. Fill YAML frontmatter:
   - name: {name}
   - description: from Step 3
   - allowed-tools: based on needs from Step 5
   - argument-hint: from Step 4
   - **DO NOT add `model:` field** (use inherited default)

2. Fill markdown body:
   - Context Files from gathered info
   - Input handling from Step 4
   - Phase 1 questions from Step 5
   - HARD STOP section
   - Phase 2 generation steps
   - Quality checks from Step 5
   - Definition of Done from Step 5

## Step 8: Generate LEARN.md (Plugin Source)

Create with research insights as initial lessons:

```markdown
# Lessons: {name}

> Last updated: {YYYY-MM-DD}

Accumulated lessons from past executions.

---

## Better Questions

Questions to ask during information gathering:

{If research found methodology insights, add as initial questions}

## Edge Cases

Special cases to check and handle:

{If research found edge cases, add here}

## Workflow

Process improvements:

{If research found process best practices, add here}

## Common Mistakes

Things to avoid:

{If research found common pitfalls, add here}
```

## Step 9: Generate template.md (Plugin Source, if needed)

Based on output format from Step 4:
- Use researched report structure
- Include required metadata section
- Add placeholders for dynamic content

## Step 10: Validate Against Specification

Check against `docs/extending/create-skill.md`:

**Frontmatter**:
- [ ] Has `name` matching directory
- [ ] Has `description` with purpose and mapping
- [ ] Has `allowed-tools` with valid patterns
- [ ] Has `argument-hint`
- [ ] Does NOT have `model:` field (causes API errors)

**Body**:
- [ ] Has H1 title matching skill name
- [ ] Has tagline blockquote
- [ ] Has `## Context Files`
- [ ] Has `## Input`
- [ ] Has `# PHASE 1: Analysis`
- [ ] Has `## Step 0: Apply Past Lessons`
- [ ] Has `# HARD STOP`
- [ ] Has `# PHASE 2: Generation`
- [ ] Has `## Definition of Done`

**Trust**:
- [ ] Tool permissions are sandboxed (not `Write(*)`)
- [ ] Has human approval checks

If any check fails, fix before preview.

## Step 11: Preview All Files

Show complete content of:
1. SKILL.md
2. LEARN.md
3. template.md (if created)

> "Write these files? [y/n]"

## Step 12: Write Files (v3.0.0-Compliant)

### 12.1: SKILL.md Frontmatter

Write to: `skills/{name}/SKILL.md`

**v3.0.0 Best Practices for Frontmatter**:

1. **Use Environment Variables in Permissions**:
   ```yaml
   # ✓ Correct (v3.0.0)
   allowed-tools: Write($JAAN_OUTPUTS_DIR/{role}/**), Read($JAAN_CONTEXT_DIR/**)

   # ✗ Deprecated (v2.x)
   allowed-tools: Write(jaan-to/outputs/{role}/**), Read(jaan-to/context/**)
   ```

2. **Standard Permission Patterns**:
   - Output writes: `Write($JAAN_OUTPUTS_DIR/{role}/**)`
   - Template edits: `Edit($JAAN_TEMPLATES_DIR/**)`
   - Learning writes: `Write($JAAN_LEARN_DIR/**)`
   - Context reads: `Read($JAAN_CONTEXT_DIR/**)`

3. **Anti-patterns to Avoid**:
   - ✗ `Write(jaan-to/**)` - Too broad, doesn't respect configuration
   - ✗ Hardcoded paths like `jaan-to/outputs/` - Not customizable
   - ✗ Mixed v2.x and v3.0.0 patterns

### 12.2: SKILL.md Context Files Section

**Always include with environment variables**:
```markdown
## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Project configuration (if applicable)
- `$JAAN_CONTEXT_DIR/boundaries.md` - Trust boundaries (if applicable)
- `$JAAN_TEMPLATES_DIR/{skill-name}.template.md` - Template for outputs
- `$JAAN_LEARN_DIR/{skill-name}.learn.md` - Past lessons (loaded in Pre-Execution)
```

**For tech-aware skills, add**:
```markdown
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
```

### 12.3: SKILL.md Pre-Execution Section

**Standard pattern for all skills**:
```markdown
## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/{skill-name}.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_{skill-name}` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.
```

**For skills that generate code, add after Language Settings**:
```markdown
> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.
```

**For tech-aware skills, add before Language Settings**:
```markdown
Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for relevant features
```

### 12.4: SKILL.md Template References

**In generation steps, always use environment variables**:

```markdown
## Step {N}: Generate Output

1. Read template: `$JAAN_TEMPLATES_DIR/{skill-name}.template.md`
2. Apply context from: `$JAAN_CONTEXT_DIR/config.md` (if needed)
```

**For tech-aware skills, add section imports**:
```markdown
3. If tech stack needed, extract sections from tech.md:
   - Current Stack: `#current-stack`
   - Frameworks: `#frameworks`
   - Constraints: `#constraints`

Standard tech.md anchors:
- `#current-stack`, `#frameworks`, `#constraints`
- `#versioning`, `#patterns`, `#tech-debt`
```

### 12.5: SKILL.md Output Path Instructions (ID-Based Folder Pattern)

**Standard output pattern with ID generation**:
```markdown
## Step 5.5: Generate ID and Folder Structure

1. Source ID generator utility:
\`\`\`bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
\`\`\`

2. Generate next ID and output paths:
\`\`\`bash
# Define your subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/{role}/{subdomain}"
mkdir -p "$SUBDOMAIN_DIR"

# Generate sequential ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Generate folder and file paths
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-{report-type}-${slug}.md"
\`\`\`

3. Preview for user:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{report-type}-{slug}.md

## Step {N}: Write Output

1. Create output folder:
\`\`\`bash
mkdir -p "$OUTPUT_FOLDER"
\`\`\`

2. Write main output file:
\`\`\`bash
cat > "$MAIN_FILE" <<'EOF'
# {Title}

## Executive Summary
{1-2 sentence summary}

{rest of output content}
EOF
\`\`\`

3. Update subdomain index:
\`\`\`bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Title}" \
  "{Executive summary text}"
\`\`\`

4. Confirm to user:
> ✓ Output written to: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/{NEXT_ID}-{report-type}-{slug}.md
> ✓ Index updated: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/README.md
```

**Key Components**:
- **ID**: Auto-generated sequential number per subdomain (01, 02, 03...)
- **Slug**: lowercase-kebab-case from title (max 50 chars)
- **Report-type**: Subdomain name (prd, story, gtm, tasks, etc.)
- **Index**: Automatic README.md updates with executive summaries

**Never hardcode** `jaan-to/outputs/` - always use `$JAAN_OUTPUTS_DIR`.

**Exception**: Research outputs use flat files (`$JAAN_OUTPUTS_DIR/research/{id}-{category}-{slug}.md`) instead of folders.

### 12.6: Write template.md (if needed)

Write to: `skills/{name}/template.md`

**v3.0.0 Template Variable Syntax**:

1. **Field Variables** (standard placeholders):
   ```markdown
   # {{title}}

   > Generated: {{date}}
   > Author: {{author}}
   ```

2. **Environment Variables** (shell environment):
   ```markdown
   Output Path: {{env:JAAN_OUTPUTS_DIR}}
   ```

3. **Configuration Variables** (from settings.yaml):
   ```markdown
   Custom Setting: {{config:custom_field}}
   ```

4. **Section Imports** (from context files):
   ```markdown
   ## Tech Stack
   {{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

   ## Constraints
   {{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}
   ```

**Standard tech.md section anchors**:
- `#current-stack` - Languages, frameworks, databases
- `#frameworks` - Framework-specific details
- `#constraints` - Technical constraints
- `#versioning` - API versioning policies
- `#patterns` - Common patterns (auth, errors)
- `#tech-debt` - Known technical debt

**Example template with all variable types**:
```markdown
# {{title}}

## Problem Statement
{{problem}}

## Technical Context

**Stack**: {{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

**Constraints**:
{{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}

## Implementation
{{implementation_details}}
```

### 12.7: Write LEARN.md Seed

Write to: `skills/{name}/LEARN.md` (plugin-side)

**Standard structure**:
```markdown
# Lessons: {skill-name}

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/{skill-name}.learn.md`

## Better Questions
<!-- Questions that improve input quality -->

## Edge Cases
<!-- Special cases to check -->

## Workflow
<!-- Process improvements -->

## Common Mistakes
<!-- Pitfalls to avoid -->
```

**Document learning merge strategy**:
- Plugin lessons (LEARN.md): Baseline best practices
- Project lessons (`$JAAN_LEARN_DIR/{skill}.learn.md`): Team-specific lessons
- Default strategy: **merge** (combine both sources)
- Skills see merged view at runtime

### 12.8: v3.0.0 Validation Checklist

Before completing Step 12, verify:

**v3.0.0 Compliance**:
- [ ] All paths use `$JAAN_*` environment variables
- [ ] No hardcoded `jaan-to/` paths in SKILL.md
- [ ] Frontmatter permissions use environment variables
- [ ] Context Files section references `$JAAN_CONTEXT_DIR`, `$JAAN_TEMPLATES_DIR`, `$JAAN_LEARN_DIR`
- [ ] Pre-Execution reads from `$JAAN_LEARN_DIR/{skill-name}.learn.md`
- [ ] Pre-Execution includes Language Settings block (reads `jaan-to/config/settings.yaml`)
- [ ] `allowed-tools` includes `Edit(jaan-to/config/settings.yaml)`
- [ ] If skill generates code, Language exception note is present
- [ ] Output paths use `$JAAN_OUTPUTS_DIR`
- [ ] template.md uses variable syntax: `{{field}}`, `{{env:VAR}}`, `{{import:path#section}}`

**Output Structure Compliance** (for output-generating skills):
- [ ] Uses `scripts/lib/id-generator.sh` for ID generation (Step 5.5)
- [ ] Creates folder: `{subdomain}/{id}-{slug}/`
- [ ] Main file named: `{id}-{report-type}-{slug}.md`
- [ ] Updates index using `scripts/lib/index-updater.sh`
- [ ] Includes Executive Summary section in template
- [ ] Preview shows ID, folder path, and file path to user
- [ ] Confirms index update after writing

**Tech Stack Integration** (if applicable):
- [ ] SKILL.md mentions reading `$JAAN_CONTEXT_DIR/tech.md`
- [ ] Template imports relevant sections with `#anchor` syntax
- [ ] Documentation explains which tech sections are used

**Learning System**:
- [ ] LEARN.md seed created in `skills/{name}/LEARN.md`
- [ ] SKILL.md documents merge strategy
- [ ] Pre-Execution step reads learning file

**Quality**:
- [ ] SKILL.md follows specification at `docs/extending/create-skill.md`
- [ ] All required sections present
- [ ] No TODOs or placeholders in generated files

Confirm: "Skill files written to `skills/{name}/` (v3.0.0-compliant)"

### Step 12.9: Automated Path Scan

Before writing the generated SKILL.md, scan its content for hardcoded paths:

**Search for violations:**
- `jaan-to/outputs/` (should be `$JAAN_OUTPUTS_DIR/`)
- `jaan-to/templates/` (should be `$JAAN_TEMPLATES_DIR/`)
- `jaan-to/learn/` (should be `$JAAN_LEARN_DIR/`)
- `jaan-to/context/` (should be `$JAAN_CONTEXT_DIR/`)

**Exclude**: Lines that are examples of what NOT to do (marked with ✗ or inside bad-example blocks)

If violations found:
> "Found {N} hardcoded path(s) in generated SKILL.md. Auto-fix? [y/n]"

Replace all violations with environment variable equivalents before proceeding.

## Step 13: Tech Stack Integration (Optional)

If the skill should be tech-aware (references the project's tech stack):

### 13.1: Identify Tech Context Needs

Ask: "Should this skill reference the project's tech stack?"

**Tech-aware skills** (answer YES):
- PRD generation → Reference stack in technical sections
- Code generation → Use correct frameworks and patterns
- Story writing → Mention implementation details
- API documentation → Reference actual endpoints/frameworks

**Tech-agnostic skills** (answer NO):
- Research → General knowledge gathering
- Documentation (non-technical) → General content
- Roadmap planning → High-level features

### 13.2: Update SKILL.md to Read tech.md

If YES, add to Pre-Execution section:
```markdown
Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for relevant features
```

### 13.3: Update template.md with Section Imports

If YES, add imports for relevant sections:
```markdown
## Technical Context

**Stack**: {{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}

**Frameworks**: {{import:$JAAN_CONTEXT_DIR/tech.md#frameworks}}

**Constraints**: {{import:$JAAN_CONTEXT_DIR/tech.md#constraints}}
```

### 13.4: Document Tech Integration

If YES, add to SKILL.md Context Files section:
```markdown
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
```

> "Tech integration: [enabled / not applicable]"

## Step 14: Update Config Catalog

Edit `scripts/seeds/config.md` to add skill to Available Skills table:

```markdown
| {role}-{domain}-{action} | `/{name}` | {short_description} |
```

## Step 15: Auto-Invoke Documentation

Run `/jaan-to:docs-create` to create:
- `docs/skills/{role}/{name}.md`

This ensures documentation is always created with the skill.

## Step 16: Commit to Branch

```bash
git add skills/{name}/ jaan-to/ docs/skills/{role}/{name}.md
git commit -m "feat(skill): Add {name} skill

- {description}
- Research-informed: {source_count} sources consulted
- Auto-generated with /jaan-to:skill-create

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

# PHASE 3: Testing & PR

## Step 17: Validate v3.0.0 Compliance

Before user testing, validate the created skill:

```
/jaan-to:skill-update {skill-name}
```

This checks for:
- ✓ v3.0.0 compliance (all paths use `$JAAN_*` variables)
- ✓ Required sections present
- ✓ Frontmatter correctness
- ✓ Template variable syntax
- ✓ Learning file structure
- ✓ Tech integration (if applicable)

**If validation fails**:
1. Review the validation output
2. Return to appropriate step (usually Step 12)
3. Fix identified issues
4. Re-validate until all checks pass

**Only proceed to user testing after validation passes.**

## Step 18: User Testing

> "Please test the skill in a new session. Here's a copy-paste ready example:"
>
> ```
> /{name} "{example_input_based_on_skill_purpose}"
> ```
>
> For example, if the skill is `pm-prd-write`:
> ```
> /jaan-to:pm-prd-write "Add user authentication with OAuth support"
> ```
>
> "Did it work correctly? [y/n]"

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

## Step 19: Create Pull Request

When user confirms working:
> "Create pull request to merge to dev? [y/n]"

If yes:
```bash
git push -u origin skill/{name}
gh pr create --base dev --title "feat(skill): Add {name} skill" --body "$(cat <<'EOF'
## Summary

- **Skill**: `{name}`
- **Command**: `/{name}`
- **Purpose**: {description}

## Research Used

Consulted {source_count} sources for best practices:
{research_summary}

## Files Created

- `skills/{name}/SKILL.md`
- `$JAAN_LEARN_DIR/{name}.learn.md`
- `$JAAN_TEMPLATES_DIR/{name}.template.md` (if applicable)
- `docs/skills/{role}/{name}.md`

## Testing

✅ User confirmed skill works correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Show PR URL to user.

If no:
> "Branch `skill/{name}` is ready. Merge manually when ready."

---

## Step 20: Capture Feedback

> "Any feedback on the skill creation process? [y/n]"

If yes:
- Run `/jaan-to:learn-add skill-create "{feedback}"`

---

## Step 21: Auto-Invoke Roadmap Update

Run `/jaan-to:roadmap-update` to sync the new skill with the roadmap.

This ensures the roadmap reflects the latest skill additions.

---

## Definition of Done

- [ ] Duplicate check completed
- [ ] Web research performed
- [ ] All skill files created (SKILL.md, LEARN.md, template.md)
- [ ] Passes specification validation
- [ ] Registered in context/config.md
- [ ] Documentation created via /jaan-to:docs-create
- [ ] User tested and confirmed working
- [ ] PR created (or branch ready for manual merge)
- [ ] Roadmap synced via /jaan-to:roadmap-update
- [ ] User approved final result
