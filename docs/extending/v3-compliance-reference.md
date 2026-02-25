# v3.0.0 Compliance Reference

> Shared reference for v3.0.0 best practices, compliance checks, and template variable syntax.
> Referenced by: `skill-create`, `skill-update`

---

## skill-update: v3.0.0 Compliance Checks

> Used by Step 2.1 (compliance check), Step 5 Option 8 (migration wizard), and Step 10.5 (output structure migration).

### V3.1: Frontmatter Permissions Use Environment Variables

Check `allowed-tools` field:

```yaml
# ✓ v3.0.0 compliant
allowed-tools: Write($JAAN_OUTPUTS_DIR/{role}/**), Read($JAAN_CONTEXT_DIR/**)

# ✗ v2.x pattern (hardcoded)
allowed-tools: Write(jaan-to/outputs/{role}/**), Read(jaan-to/context/**)
```

**Detection**: Search SKILL.md for hardcoded `jaan-to/` paths in frontmatter.

**Status**:
- [ ] ✓ All paths use `$JAAN_*` variables
- [ ] ✗ Has hardcoded `jaan-to/` paths (v2.x pattern)

### V3.2: Context Files Section Uses Environment Variables

Check `## Context Files` section references:

```markdown
# ✓ v3.0.0 compliant
- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_TEMPLATES_DIR/{name}.template.md` - Template
- `$JAAN_LEARN_DIR/{name}.learn.md` - Lessons

# ✗ v2.x pattern (hardcoded)
- `jaan-to/context/config.md` - Configuration
- `skills/{name}/template.md` - Template
- `jaan-to/learn/{name}.learn.md` - Lessons
```

**Detection**: Grep for `jaan-to/` in Context Files section.

**Status**:
- [ ] ✓ All context paths use `$JAAN_*` variables
- [ ] ✗ Has hardcoded paths

### V3.3: Pre-Execution Uses Learning Directory Variable

Check Pre-Execution / Step 0 section:

```markdown
# ✓ v3.0.0 compliant
Read: `$JAAN_LEARN_DIR/{name}.learn.md`

# ✗ v2.x pattern
Read: `jaan-to/learn/{name}.learn.md`
```

**Detection**: Check Pre-Execution and Step 0 for learning file references.

**Status**:
- [ ] ✓ Uses `$JAAN_LEARN_DIR`
- [ ] ✗ Uses hardcoded path

### V3.4: Template References Use Template Directory Variable

Check any template read instructions (typically in generation phase):

```markdown
# ✓ v3.0.0 compliant
Use template: `$JAAN_TEMPLATES_DIR/{name}.template.md`

# ✗ v2.x pattern
Use template: `skills/{name}/template.md`
Use template: `jaan-to/templates/{name}.template.md` (old location)
```

**Detection**: Grep for template references in SKILL.md.

**Status**:
- [ ] ✓ Uses `$JAAN_TEMPLATES_DIR`
- [ ] ✗ Uses hardcoded path
- [ ] N/A (skill doesn't use templates)

### V3.5: Output Paths Use Outputs Directory Variable

Check write/output instructions (typically in Phase 2):

```markdown
# ✓ v3.0.0 compliant
Write to: `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/`

# ✗ v2.x pattern
Write to: `jaan-to/outputs/{role}/{domain}/{slug}/`
```

**Detection**: Grep for output path instructions.

**Status**:
- [ ] ✓ Uses `$JAAN_OUTPUTS_DIR`
- [ ] ✗ Uses hardcoded path
- [ ] N/A (skill doesn't write outputs)

### V3.6: template.md Uses Template Variable Syntax (if exists)

If `template.md` exists, check for v3.0.0 template variables:

**Expected patterns**:
- Field variables: `{{title}}`, `{{date}}`, `{{author}}`
- Environment variables: `{{env:JAAN_OUTPUTS_DIR}}`
- Configuration variables: `{{config:paths_templates}}`
- Section imports: `{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}`

**Detection**: Read template.md and check for variable usage.

**Status**:
- [ ] ✓ Uses template variables
- [ ] ✗ No variables (static template)
- [ ] N/A (no template.md)

### V3.7: Tech Stack Integration (Optional)

Check if skill is tech-aware (references project's tech stack):

**Indicators**:
- Reads `$JAAN_CONTEXT_DIR/tech.md`
- Uses section imports like `{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}`
- PRD/spec generation mentions tech stack

**Status**:
- [ ] ✓ Tech-aware (integrates with tech.md)
- [ ] N/A (skill doesn't need tech context)

### V3.8: Output Structure Compliance (For Output-Generating Skills)

Check if skill follows ID-based folder output pattern:

**1. ID Generation Check**:
```bash
# ✓ Compliant
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# ✗ Non-compliant
# Missing ID generation
```

**Detection**: Search for `scripts/lib/id-generator.sh` and `generate_next_id` calls.

**Status**:
- [ ] ✓ Uses ID generator
- [ ] ✗ Missing ID generation
- [ ] N/A (skill doesn't write outputs)

**2. Folder Structure Check**:
```bash
# ✓ Compliant
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"

# ✗ Non-compliant
OUTPUT_FILE="$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}.md"  # Direct file, no folder
OUTPUT_FILE="$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/{filename}"  # No ID
```

**Detection**: Check output path construction pattern.

**Status**:
- [ ] ✓ Creates folder `{id}-{slug}/`
- [ ] ✗ Direct file write or missing ID in folder name
- [ ] N/A

**3. Index Management Check**:
```bash
# ✓ Compliant
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index "$SUBDOMAIN_DIR/README.md" "$NEXT_ID" "..." "..." "..."

# ✗ Non-compliant
# No index management
```

**Detection**: Search for `scripts/lib/index-updater.sh` and `add_to_index` calls.

**Status**:
- [ ] ✓ Updates subdomain index
- [ ] ✗ Missing index management
- [ ] N/A

**4. Executive Summary Check**:
```markdown
# ✓ Compliant template
## Executive Summary
{1-2 sentence summary}

# ✗ Non-compliant
Missing Executive Summary section
```

**Detection**: Read template.md and check for `## Executive Summary` section.

**Status**:
- [ ] ✓ Template has Executive Summary
- [ ] ✗ Template missing Executive Summary
- [ ] N/A (no template.md)

**Migration Suggestion Format** (if any check fails):
```
❌ Output structure outdated
   Current: {current pattern}
   Standard: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{id}-{slug}/{id}-{slug}.md

   Required changes:
   1. Add Step 5.5: Generate ID using scripts/lib/id-generator.sh
   2. Update output step: Create folder instead of direct file
   3. Add index management using scripts/lib/index-updater.sh
   4. Add Executive Summary to template

   Reference: skills/pm-prd-write/SKILL.md (compliant example)
```

### V3.9: Description Budget Compliance

Check that description field is concise and budget-friendly:

**Rules:**
- Description should be 1-2 sentences (under 120 chars)
- Must NOT contain `Auto-triggers on:` line
- Must NOT contain `Maps to:` line
- Must use single-line YAML format (no `|` block scalar)

**Detection**: Check description field length and content in YAML frontmatter.

**Status**:
- [ ] ✓ Description is concise (under 120 chars, no trigger/mapping lines)
- [ ] ✗ Description too long or contains `Auto-triggers on:` / `Maps to:` lines

### V3.10: Preview & Confirmation Text Uses Variables

Check display strings for hardcoded paths:

**Detection**: Search for `jaan-to/outputs/`, `jaan-to/templates/`, `jaan-to/learn/`, `jaan-to/context/` in:
- Output preview sections ("> - Folder: ...")
- Completion confirmations ("> ✓ Written to: ...")
- Index confirmations ("> ✓ Index updated: ...")
- Git add commands

**Exclude**: Lines showing old patterns as bad examples (marked with ✗ or inside migration arrows `→`)

**Fix**: Replace with corresponding `$JAAN_*` environment variable.

**Status**:
- [ ] ✓ All display strings use `$JAAN_*` variables
- [ ] ✗ Hardcoded paths found in display strings

---

### Migration Wizard (v2.x → v3.0.0)

> Referenced from Step 5 Option 8.

Use AskUserQuestion to ask the user:
- Question: "Choose migration approach:"
- Header: "Migrate"
- Options:
  - "Auto-fix all" — Apply all v3.0.0 patterns automatically
  - "Interactive" — Review each change before applying
  - "Manual checklist" — Show what needs fixing step by step
  - "Guidance only" — Show what needs fixing, don't auto-apply

#### Option 8.1: Auto-Fix All

Apply these transformations automatically:

**Frontmatter**:
```yaml
# Transform
allowed-tools: Write(jaan-to/outputs/**) → Write($JAAN_OUTPUTS_DIR/**)
allowed-tools: Read(jaan-to/context/**) → Read($JAAN_CONTEXT_DIR/**)
allowed-tools: Edit(jaan-to/templates/**) → Edit($JAAN_TEMPLATES_DIR/**)
```

**Context Files section**:
```markdown
# Transform
- `jaan-to/context/config.md` → `$JAAN_CONTEXT_DIR/config.md`
- `jaan-to/learn/{name}.learn.md` → `$JAAN_LEARN_DIR/{name}.learn.md`
- `skills/{name}/template.md` → `$JAAN_TEMPLATES_DIR/{name}.template.md`
```

**Pre-Execution / Step 0**:
```markdown
# Transform
Read: `jaan-to/learn/{name}.learn.md` → `$JAAN_LEARN_DIR/{name}.learn.md`
```

**Template references**:
```markdown
# Transform
Use template from `skills/{name}/template.md` → `$JAAN_TEMPLATES_DIR/{name}.template.md`
```

**Output paths**:
```markdown
# Transform
Write to `jaan-to/outputs/{role}/` → `$JAAN_OUTPUTS_DIR/{role}/`
Create: `jaan-to/outputs/{role}/{slug}/` → `$JAAN_OUTPUTS_DIR/{role}/{slug}/`
```

**template.md** (if exists):
- Add field variables: `{{title}}`, `{{date}}`
- Add metadata table with `{{env:JAAN_OUTPUTS_DIR}}`
- Suggest section imports for tech-aware skills

Show preview of all transformations before applying.

#### Option 8.2: Interactive

For each detected v2.x pattern:
1. Show current code
2. Show proposed v3.0.0 replacement
3. Ask: "Apply this change? [y/n/skip-all]"

#### Option 8.3: Guidance Only

Display migration checklist:

```
v3.0.0 MIGRATION CHECKLIST
──────────────────────────
□ Update frontmatter permissions:
  - Replace jaan-to/outputs/** → $JAAN_OUTPUTS_DIR/**
  - Replace jaan-to/context/** → $JAAN_CONTEXT_DIR/**
  - Replace jaan-to/templates/** → $JAAN_TEMPLATES_DIR/**
  - Replace jaan-to/learn/** → $JAAN_LEARN_DIR/**

□ Update Context Files section (~ line {X}):
  - Replace all `jaan-to/` → `$JAAN_*`

□ Update Pre-Execution section (~ line {Y}):
  - Replace `jaan-to/learn/` → `$JAAN_LEARN_DIR/`

□ Update template references (~ line {Z}):
  - Replace `skills/{name}/template.md` → `$JAAN_TEMPLATES_DIR/{name}.template.md`

□ Update output paths throughout Phase 2:
  - Replace `jaan-to/outputs/` → `$JAAN_OUTPUTS_DIR/`

□ Update template.md (if exists):
  - Add {{title}}, {{date}} field variables
  - Add {{env:JAAN_OUTPUTS_DIR}} for path references
  - Consider {{import:$JAAN_CONTEXT_DIR/tech.md#section}} for tech-aware skills

□ Re-validate with:
  `/skill-update {name}` → Check v3.0.0 compliance
```

> "Apply these changes manually, then re-run validation."

---

### Output Structure Migration (Step 10.5)

> Referenced from Step 10.5 when user selects option [9].

If user selected option [9] "Migrate output structure to ID-based folders":

#### 10.5.1: Show Migration Plan

Display migration summary:
```
OUTPUT STRUCTURE MIGRATION
──────────────────────────
This skill will be updated to use the standardized output pattern:

Old: {current_pattern}
New: {subdomain}/{id}-{slug}/{id}-{slug}.md

Required changes:
□ Add Step 5.5: Generate ID using scripts/lib/id-generator.sh
□ Update output step: Create folder instead of direct file
□ Add index management using scripts/lib/index-updater.sh
□ Add Executive Summary to template (if template.md exists)
□ Update validation checklist

Reference: skills/pm-prd-write/SKILL.md (compliant example)
```

#### 10.5.2: HARD STOP - Approve Migration

> "Migrate output structure? This will modify SKILL.md and template.md. [y/n]"

**Do NOT proceed without explicit approval.**

#### 10.5.3: Apply Migration (If Approved)

If approved, apply these changes:

**1. Insert Step 5.5 in SKILL.md** (after slug generation step):
```markdown
## Step 5.5: Generate ID and Folder Structure

1. Source ID generator:
\`\`\`bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
\`\`\`

2. Generate paths:
\`\`\`bash
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/{role}/{subdomain}"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
\`\`\`

3. Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{slug}.md
```

**2. Update output writing step** (typically Step 6 or 7):

Replace:
```markdown
Write file: `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/{filename}`
```

With:
```markdown
1. Create folder:
\`\`\`bash
mkdir -p "$OUTPUT_FOLDER"
\`\`\`

2. Write main file:
\`\`\`bash
cat > "$MAIN_FILE" <<'EOF'
{output content}
EOF
\`\`\`

3. Update index:
\`\`\`bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Title}" \
  "{Executive summary}"
\`\`\`

4. Confirm:
> ✓ Output written to: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md
> ✓ Index updated
```

**3. Update template.md** (if exists):

Add Executive Summary section after title:
```markdown
## Executive Summary

{1-2 sentence high-level summary of the problem, solution, or findings}
```

**4. Add validation checklist** (in quality check step):
```markdown
**Output Structure**:
- [ ] ID generated using scripts/lib/id-generator.sh
- [ ] Folder created: {subdomain}/{id}-{slug}/
- [ ] File named: {id}-{slug}.md
- [ ] Index updated
- [ ] Executive Summary included
```

---

## skill-create: v3.0.0 Best Practices for Writing Skills

The following sections document the v3.0.0 patterns that `skill-create` enforces when generating new skill files (Steps 12.1-12.9).

### 12.1: SKILL.md Frontmatter

**v3.0.0 Best Practices for Frontmatter**:

1. **Use Environment Variables in Permissions**:
   ```yaml
   # Correct (v3.0.0)
   allowed-tools: Write($JAAN_OUTPUTS_DIR/{role}/**), Read($JAAN_CONTEXT_DIR/**)

   # Deprecated (v2.x)
   allowed-tools: Write(jaan-to/outputs/{role}/**), Read(jaan-to/context/**)
   ```

2. **Standard Permission Patterns**:
   - Output writes: `Write($JAAN_OUTPUTS_DIR/{role}/**)`
   - Template edits: `Edit($JAAN_TEMPLATES_DIR/**)`
   - Learning writes: `Write($JAAN_LEARN_DIR/**)`
   - Context reads: `Read($JAAN_CONTEXT_DIR/**)`

3. **Anti-patterns to Avoid**:
   - `Write(jaan-to/**)` - Too broad, doesn't respect configuration
   - Hardcoded paths like `jaan-to/outputs/` - Not customizable
   - Mixed v2.x and v3.0.0 patterns

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
## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `{skill-name}`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_{skill-name}` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" -- Options: "English" (default), "Persian", "Other (specify)" -- then save choice to `jaan-to/config/settings.yaml` |

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
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
\`\`\`

3. Preview for user:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{slug}.md

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
> Output written to: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md
> Index updated: $JAAN_OUTPUTS_DIR/{role}/{subdomain}/README.md
```

**Key Components**:
- **ID**: Auto-generated sequential number per subdomain (01, 02, 03...)
- **Slug**: lowercase-kebab-case from title (max 50 chars)
- **Report-type**: Subdomain name (prd, story, gtm, tasks, etc.)
- **Index**: Automatic README.md updates with executive summaries

**Never hardcode** `jaan-to/outputs/` - always use `$JAAN_OUTPUTS_DIR`.

**Exception**: Research outputs use flat files (`$JAAN_OUTPUTS_DIR/research/{id}-{category}-{slug}.md`) instead of folders.

### 12.6: Template Variable Syntax (template.md)

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

### 12.7: LEARN.md Seed Structure

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
- [ ] Main file named: `{id}-{slug}.md`
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

### 12.9: Automated Path Scan

Before writing the generated SKILL.md, scan its content for hardcoded paths:

**Search for violations:**
- `jaan-to/outputs/` (should be `$JAAN_OUTPUTS_DIR/`)
- `jaan-to/templates/` (should be `$JAAN_TEMPLATES_DIR/`)
- `jaan-to/learn/` (should be `$JAAN_LEARN_DIR/`)
- `jaan-to/context/` (should be `$JAAN_CONTEXT_DIR/`)

**Exclude**: Lines that are examples of what NOT to do (marked with X or inside bad-example blocks)

If violations found:
> "Found {N} hardcoded path(s) in generated SKILL.md. Auto-fix? [y/n]"

Replace all violations with environment variable equivalents before proceeding.

---

## skill-create: Tech Stack Integration Reference

If the skill should be tech-aware (references the project's tech stack):

### 13.1: Identify Tech Context Needs

Ask: "Should this skill reference the project's tech stack?"

**Tech-aware skills** (answer YES):
- PRD generation -> Reference stack in technical sections
- Code generation -> Use correct frameworks and patterns
- Story writing -> Mention implementation details
- API documentation -> Reference actual endpoints/frameworks

**Tech-agnostic skills** (answer NO):
- Research -> General knowledge gathering
- Documentation (non-technical) -> General content
- Roadmap planning -> High-level features

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

---

## skill-create: v3.0.0 Post-Creation Validation

Before user testing, validate the created skill:

```
/skill-update {skill-name}
```

This checks for:
- v3.0.0 compliance (all paths use `$JAAN_*` variables)
- Required sections present
- Frontmatter correctness
- Template variable syntax
- Learning file structure
- Tech integration (if applicable)

**If validation fails**:
1. Review the validation output
2. Return to appropriate step (usually Step 12)
3. Fix identified issues
4. Re-validate until all checks pass

**Only proceed to user testing after validation passes.**
