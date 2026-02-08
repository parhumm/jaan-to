---
name: skill-update
description: Update an existing jaan.to skill following standards.
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write(skills/**), Write(docs/**), Write($JAAN_OUTPUTS_DIR/**), Edit, Bash(git checkout:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [skill-name]
---

# skill-update

> Update existing jaan.to skills with specification compliance and documentation sync.

## Context Files

- `docs/extending/create-skill.md` - Skill specification (REQUIRED)
- `$JAAN_LEARN_DIR/jaan-to:skill-update.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/config.md` - Current skill catalog

## Input

**Skill Name**: $ARGUMENTS

The name of the skill to update (e.g., `pm-prd-write` or just `prd-write`).

If not provided, list available skills and ask which to update.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:skill-update.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_skill-update` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

# PHASE 0: Git Branch Setup

Create feature branch for updates:

```bash
git checkout dev
git pull origin dev
git checkout -b update/{skill-name}
```

Confirm: "Created branch `update/{name}` from `dev`. All updates on this branch."

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing existing skill structure
- Planning updates carefully
- Validating against specification
- Ensuring backward compatibility

## Questioning Guidelines

Ask up to 7 clarifying questions across Phase 1 if needed.

**Skip questions when**:
- Information already provided in user input
- Research answered the question
- Context files contain the answer
- Question is redundant with previous answer

**Make questions smart**:
- Reference user's input: "You said '{X}' — does that mean...?"
- Build on existing skill: "The current skill does Y — should that change?"
- Probe specifics: "What should happen when Z?"

## Step 1: Read Existing Skill

Read all files for the skill:
- `skills/{name}/SKILL.md` - Current skill definition
- `$JAAN_LEARN_DIR/{name}.learn.md` - Accumulated lessons
- `$JAAN_TEMPLATES_DIR/{name}.template.md` - Output template (if exists)

Display current structure:
```
CURRENT SKILL: {name}
────────────────────
Command: /{name}
Name: {name}
Description: {description}

FILES
─────
□ SKILL.md ({line_count} lines)
□ LEARN.md ({lesson_count} lessons)
□ template.md ({exists/missing})
```

## Step 2: Validate Against Specification

Check current skill against `docs/extending/create-skill.md`:

**Frontmatter**:
- [ ] Has `name` matching directory
- [ ] Has `description` with purpose and mapping
- [ ] Has `allowed-tools` with valid patterns
- [ ] Has `argument-hint`

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
- [ ] Tool permissions are sandboxed

Show compliance status:
```
SPECIFICATION COMPLIANCE
────────────────────────
✓ Frontmatter: 4/4 fields
✗ Body: 8/9 sections (missing: Step 0)
✓ Trust: sandboxed
```

## Step 2.1: v3.0.0 Compliance Check

Check the skill for v3.0.0 customization system compatibility:

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
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-{report-type}-${slug}.md"

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
   Standard: jaan-to/outputs/{role}/{subdomain}/{id}-{slug}/{id}-{report-type}-{slug}.md

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

### v3.0.0 Compliance Summary

Display results:
```
v3.0.0 COMPLIANCE
─────────────────
V3.1 Frontmatter env vars:     ✓ / ✗
V3.2 Context paths:             ✓ / ✗
V3.3 Learning path:             ✓ / ✗
V3.4 Template path:             ✓ / ✗ / N/A
V3.5 Output path:               ✓ / ✗ / N/A
V3.6 Template variables:        ✓ / ✗ / N/A
V3.7 Tech integration:          ✓ / N/A

OUTPUT STRUCTURE COMPLIANCE
───────────────────────────
V3.8.1 ID generation:           ✓ / ✗ / N/A
V3.8.2 Folder structure:        ✓ / ✗ / N/A
V3.8.3 Index management:        ✓ / ✗ / N/A
V3.8.4 Executive Summary:       ✓ / ✗ / N/A

DESCRIPTION BUDGET
──────────────────
V3.9 Description budget:        ✓ / ✗

VERDICT: v3.0.0 Compliant / Needs Migration / Needs Output Migration / Needs Description Fix
```

If **any check fails (✗)**:
- Add option [8] to Step 3: "Migrate to v3.0.0"
- If V3.8 checks fail: Add option [9]: "Migrate output structure to ID-based folders"

## Step 3: Ask Update Type

> "What do you want to change?"
>
> [1] Add/modify questions (Phase 1)
> [2] Update quality checks (Phase 2)
> [3] Modify output format (template.md)
> [4] Add tool permissions
> [5] Incorporate LEARN.md lessons → SKILL.md
> [6] Fix specification compliance issues
> [7] Other (describe)
> [8] Migrate to v3.0.0 (if v3.0.0 compliance check failed)
> [9] Migrate output structure to ID-based folders (if V3.8 check failed)
> [10] Fix description budget (trim Auto-triggers/Maps-to lines, shorten description)

## Step 4: Optional Web Research

For options [1], [2], [3], or [7], offer:
> "Search for updated best practices? [y/n]"

If yes, use **Task tool with Explore subagent**:
```
Task prompt: "Research current best practices for {domain}:
1. Search '{domain} best practices {year}'
2. Search '{domain} checklist {year}'
Return: new practices, updated methodologies, changes since {skill_created_date}"
```

## Step 5: Plan Changes

Based on selected option, plan specific changes:

**Option 1 (Questions)**: Show current questions, propose additions
**Option 2 (Quality)**: Show current checks, propose updates
**Option 3 (Template)**: Show current template, propose modifications
**Option 4 (Tools)**: Show current permissions, propose additions
**Option 5 (LEARN→SKILL)**: Map lessons to skill sections:

| LEARN.md Section | Incorporate Into |
|------------------|------------------|
| Better Questions | Phase 1 Step 1 questions |
| Edge Cases | Phase 2 quality checks |
| Workflow | Process steps + Definition of Done |
| Common Mistakes | Warnings in relevant sections |

**Option 6 (Compliance)**: List missing sections, propose additions
**Option 7 (Other)**: Gather details, plan custom changes

**Option 8 (Migrate to v3.0.0)**: Run automated migration wizard:

### Migration Wizard (v2.x → v3.0.0)

Detected v2.x patterns. Choose migration approach:

Use AskUserQuestion to ask the user:
- Question: "Choose migration approach:"
- Header: "Migrate"
- Options:
  - "Auto-fix all" — Apply all v3.0.0 patterns automatically
  - "Interactive" — Review each change before applying
  - "Manual script" — Generate `scripts/lib/v3-autofix.sh` for user to run
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

#### Option 8.3: Generate Auto-Fix Script

Create `scripts/lib/v3-autofix.sh`:

```bash
#!/bin/bash
# Auto-generated migration script for {skill-name}
# v2.x → v3.0.0 migration

SKILL_DIR="skills/{name}"

# Backup
cp "$SKILL_DIR/SKILL.md" "$SKILL_DIR/SKILL.md.v2.backup"

# Transform frontmatter
sed -i '' 's|Write(jaan-to/outputs/\*\*)|Write($JAAN_OUTPUTS_DIR/**)|g' "$SKILL_DIR/SKILL.md"
sed -i '' 's|Read(jaan-to/context/\*\*)|Read($JAAN_CONTEXT_DIR/**)|g' "$SKILL_DIR/SKILL.md"

# Transform context files section
sed -i '' 's|jaan-to/context/|$JAAN_CONTEXT_DIR/|g' "$SKILL_DIR/SKILL.md"
sed -i '' 's|jaan-to/learn/|$JAAN_LEARN_DIR/|g' "$SKILL_DIR/SKILL.md"
sed -i '' 's|skills/{name}/template.md|$JAAN_TEMPLATES_DIR/{name}.template.md|g' "$SKILL_DIR/SKILL.md"

# Transform output paths
sed -i '' 's|jaan-to/outputs/|$JAAN_OUTPUTS_DIR/|g' "$SKILL_DIR/SKILL.md"

# Validate
if grep -q 'jaan-to/' "$SKILL_DIR/SKILL.md"; then
  echo "⚠ WARNING: Some hardcoded paths remain. Review manually."
else
  echo "✓ Migration complete. Review and test before committing."
fi

# template.md (if exists)
if [ -f "$SKILL_DIR/template.md" ]; then
  cp "$SKILL_DIR/template.md" "$SKILL_DIR/template.md.v2.backup"
  # Add template variables (manual step - template structure varies)
  echo "⚠ template.md backed up. Add template variables manually."
fi
```

> "Script created. Run it with:"
> ```bash
> bash scripts/lib/v3-autofix.sh
> ```

#### Option 8.4: Guidance Only

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
  `/jaan-to:skill-update {name}` → Check v3.0.0 compliance
```

> "Apply these changes manually, then re-run validation."

---

# HARD STOP - Human Review Check

Show diff preview:

```
PROPOSED CHANGES
────────────────
File: SKILL.md
───
- old line
+ new line
───

File: template.md (if applicable)
───
- old line
+ new line
───

COMPLIANCE AFTER UPDATE
───────────────────────
✓ Frontmatter: 4/4 fields
✓ Body: 9/9 sections
✓ Trust: sandboxed
```

> "Apply these changes? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Update (Write Phase)

## Step 6: Update SKILL.md

Apply planned changes while preserving:
- Two-phase workflow structure
- HARD STOP section
- Definition of Done section
- Specification compliance

## Step 7: Update template.md (if needed)

If output format changes requested:
1. Update template structure
2. Preserve required metadata section
3. Update placeholders

## Step 8: Update LEARN.md

If Option 5 selected (lessons incorporated):
- Add workflow note: "Incorporated into SKILL.md on {date}"
- Keep original lessons for reference

Otherwise, add any new workflow learnings:
- "Updated {section} based on {reason}"

## Step 9: Validate Updated Skill

Run full specification check:

- [ ] YAML frontmatter complete
- [ ] All required sections present
- [ ] Two-phase workflow intact
- [ ] HARD STOP section exists
- [ ] Definition of Done present
- [ ] Tool permissions sandboxed

If any check fails, fix before continuing.

## Step 10: Preview All Changes

Show final versions of all modified files.

> "Write these updates? [y/n]"

## Step 10.5: Handle Output Structure Migration (If Option [9] Selected)

If user selected option [9] "Migrate output structure to ID-based folders":

### 10.5.1: Show Migration Plan

Display migration summary:
```
OUTPUT STRUCTURE MIGRATION
──────────────────────────
This skill will be updated to use the standardized output pattern:

Old: {current_pattern}
New: {subdomain}/{id}-{slug}/{id}-{report-type}-{slug}.md

Required changes:
□ Add Step 5.5: Generate ID using scripts/lib/id-generator.sh
□ Update output step: Create folder instead of direct file
□ Add index management using scripts/lib/index-updater.sh
□ Add Executive Summary to template (if template.md exists)
□ Update validation checklist

Reference: skills/pm-prd-write/SKILL.md (compliant example)
```

### 10.5.2: HARD STOP - Approve Migration

> "Migrate output structure? This will modify SKILL.md and template.md. [y/n]"

**Do NOT proceed without explicit approval.**

### 10.5.3: Apply Migration (If Approved)

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
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-{report-type}-${slug}.md"
\`\`\`

3. Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: jaan-to/outputs/{role}/{subdomain}/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{report-type}-{slug}.md
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
> ✓ Output written to: jaan-to/outputs/{role}/{subdomain}/{NEXT_ID}-{slug}/{NEXT_ID}-{report-type}-{slug}.md
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
- [ ] File named: {id}-{report-type}-{slug}.md
- [ ] Index updated
- [ ] Executive Summary included
```

## Step 11: Write Updated Files

If approved:
1. Write SKILL.md to `skills/{name}/SKILL.md`
2. Write template.md to `skills/{name}/template.md` (if modified)
3. Write LEARN.md to `skills/{name}/LEARN.md`

Confirm: "Skill files updated in `skills/{name}/`"

## Step 12: Auto-Invoke Documentation Sync

Run `/jaan-to:docs-update {name}` to sync:
- `docs/skills/{role}/{name}.md`

This ensures documentation stays in sync with skill changes.

## Step 13: Commit to Branch

```bash
git add skills/{name}/ jaan-to/ docs/skills/{role}/{name}.md
git commit -m "fix(skill): Update {name} skill

- {change_summary}
- Specification compliance: ✓

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

# PHASE 3: Testing & PR

## Step 14: User Testing

> "Please test the updated skill in a new session. Here's a copy-paste ready example:"
>
> ```
> /{name} "{example_input_based_on_skill_purpose}"
> ```
>
> For example, if updating `docs-create`:
> ```
> /jaan-to:docs-create skill "my-new-feature"
> ```
>
> "Did it work correctly? [y/n]"

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

## Step 15: Create Pull Request

When user confirms working:
> "Create pull request to merge to dev? [y/n]"

If yes:
```bash
git push -u origin update/{name}
gh pr create --base dev --title "fix(skill): Update {name} skill" --body "$(cat <<'EOF'
## Summary

Updated `{name}` skill with:
{change_list}

## Changes Made

{detailed_changes}

## Specification Compliance

✅ All checks pass after update

## Testing

✅ User confirmed skill works correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Show PR URL to user.

If no:
> "Branch `update/{name}` is ready. Merge manually when ready."

---

## Step 16: Capture Feedback

> "Any feedback on the skill update process? [y/n]"

If yes:
- Run `/jaan-to:learn-add skill-update "{feedback}"`

### v3.0.0 Migration Feedback (if Option 8 was used)

If skill was migrated to v3.0.0, capture migration-specific learnings:

**Suggested feedback categories**:

1. **Migration approach effectiveness**:
   - "Auto-fix worked perfectly for {skill-name}"
   - "Interactive mode caught edge case: {description}"
   - "Manual script needed adjustment: {what}"

2. **Patterns the auto-fix missed**:
   - "Auto-fix didn't catch: {pattern} in {location}"
   - "New v2.x pattern detected: {pattern} → should transform to {v3.0.0}"

3. **Template variable adoption**:
   - "Skill would benefit from {{import:tech.md#section}}"
   - "Template variables made {aspect} more flexible"

4. **Tech stack integration opportunities**:
   - "Skill {name} should reference tech.md for {reason}"
   - "Added tech integration, improved PRD quality"

**Auto-categorization**:
- Patterns → Add to v3-autofix.sh transformations
- Edge cases → Add to Step 2.1 validation checks
- Workflow improvements → Update Migration Wizard options

Example:
```
/jaan-to:learn-add skill-update "Auto-fix missed pattern: \`Read(jaan-to/docs/**)\` in doc-generation skills. Add to v3-autofix.sh transformations."
```

---

## Step 17: Auto-Invoke Roadmap Update

Run `/jaan-to:roadmap-update` to sync the skill update with the roadmap.

This ensures the roadmap reflects the latest skill changes.

---

## Definition of Done

- [ ] Existing skill files read and analyzed
- [ ] Specification compliance validated
- [ ] User-selected updates applied
- [ ] Passes specification validation after update
- [ ] Documentation synced via /jaan-to:docs-update
- [ ] User tested and confirmed working
- [ ] PR created (or branch ready for manual merge)
- [ ] Roadmap synced via /jaan-to:roadmap-update
- [ ] User approved final result
