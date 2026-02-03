---
name: to-jaan-skill-update
description: |
  Update an existing jaan.to skill following standards.
  Auto-triggers on: update skill, modify skill, improve skill, fix skill.
  Maps to: to-jaan-skill-update
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write(skills/**), Write(docs/**), Write($JAAN_OUTPUTS_DIR/**), Edit, Bash(git checkout:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [skill-name]
---

# skill:update

> Update existing jaan.to skills with specification compliance and documentation sync.

## Context Files

- `docs/extending/create-skill.md` - Skill specification (REQUIRED)
- `$JAAN_LEARN_DIR/to-jaan-skill-update.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/config.md` - Current skill catalog

## Input

**Skill Name**: $ARGUMENTS

The name of the skill to update (e.g., `jaan-to-pm-prd-write` or just `prd-write`).

If not provided, list available skills and ask which to update.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/to-jaan-skill-update.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 0: Git Branch Setup

Create feature branch for updates:

```bash
git checkout -b update/{skill-name}
```

Confirm: "Created branch `update/{name}`. All updates on this branch."

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
Logical: {logical_name}
Description: {description}

FILES
─────
□ SKILL.md ({line_count} lines)
□ LEARN.md ({lesson_count} lessons)
□ template.md ({exists/missing})
```

## Step 2: Validate Against Specification

Check current skill against `jaan-to/docs/create-skill.md`:

**Frontmatter**:
- [ ] Has `name` matching directory
- [ ] Has `description` with purpose and mapping
- [ ] Has `allowed-tools` with valid patterns
- [ ] Has `argument-hint`

**Body**:
- [ ] Has H1 title with logical name
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

### V3.8: AskUserQuestion Usage

Check that structured interactions use AskUserQuestion instead of text prompts:

**Expected patterns** (v3.8 compliant):
```markdown
# ✓ Uses AskUserQuestion
Use AskUserQuestion to ask the user:
- Question: "Ready to proceed?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the output
  - "No" — Cancel

# ✗ Uses text prompt for structured choice
> "Proceed? [y/n]"
> "[1] Fix now  [2] Learn  [3] Both"
```

**Check these sections**:
1. HARD STOP gate — must use AskUserQuestion
2. Preview & Approval — must use AskUserQuestion
3. Feedback section — must use AskUserQuestion with 3-4 options
4. Any other 2-4 option choices — should use AskUserQuestion

**Detection**: Grep for `> ".*\[y/n` and `> "\[1\]` patterns in SKILL.md.

**Status**:
- [ ] ✓ HARD STOP uses AskUserQuestion
- [ ] ✓ Preview uses AskUserQuestion
- [ ] ✓ Feedback uses AskUserQuestion
- [ ] ✓ All structured choices (2-4 options) use AskUserQuestion
- [ ] ✗ Text prompts used for structured choices (suggest option [9])

### v3.0.0 Compliance Summary

Display results:
```
v3.0.0 COMPLIANCE
─────────────────
V3.1 Frontmatter env vars:  ✓ / ✗
V3.2 Context paths:          ✓ / ✗
V3.3 Learning path:          ✓ / ✗
V3.4 Template path:          ✓ / ✗ / N/A
V3.5 Output path:            ✓ / ✗ / N/A
V3.6 Template variables:     ✓ / ✗ / N/A
V3.7 Tech integration:       ✓ / N/A
V3.8 AskUserQuestion:        ✓ / ✗

VERDICT: v3.0.0 Compliant / Needs Migration
```

If **any check fails (✗)**:
- Add option [8] to Step 3: "Migrate to v3.0.0"
- If V3.8 fails: Add option [9] to Step 3: "Convert text prompts to AskUserQuestion"

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
> [8] Migrate to v3.0.0 (if compliance check failed)
> [9] Convert text prompts to AskUserQuestion (if V3.8 check failed)

**Option 9 (Convert to AskUserQuestion)**:

Scan the target skill for text-based prompts that should use AskUserQuestion:

1. **Find all prompt patterns**: Grep for `> ".*\[y/n` and `> "\[1\]` and `> ".*? \[` patterns
2. **Categorize each prompt**:
   - **Convertible** (2-4 fixed options): HARD STOP [y/n/edit], Preview [y/n], Feedback [y/n] + [1-3], confirmations
   - **Must stay as text** (5+ options, open-ended): menus with 5+ items, free-text input, multi-line
3. **Show conversion plan**:
   ```
   ASKUSERQUESTION CONVERSION PLAN
   ─────────────────────────────────
   ✓ Convert (2-4 options):
     Line {n}: "Proceed? [y/n]" → AskUserQuestion (Yes/No)
     Line {n}: "[1] Fix [2] Learn [3] Both" → AskUserQuestion (3 options)

   ✗ Keep as text:
     Line {n}: "[1]...[2]...[8]..." → Too many options
     Line {n}: "What is the...?" → Open-ended

   Total: {x} convertible, {y} keep as text
   ```
4. **Apply conversions**: Replace text prompts with AskUserQuestion instruction blocks
5. **Validate**: Ensure converted prompts follow the spec pattern from `docs/extending/create-skill.md` "User Interaction Patterns" section

## Step 4: Optional Web Research

For options [1], [2], [3], or [7], use AskUserQuestion:
- Question: "Search for updated best practices?"
- Header: "Research"
- Options:
  - "Yes" — Research current best practices
  - "No" — Skip research

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
3. Use AskUserQuestion:
   - Question: "Apply this change?"
   - Header: "Apply"
   - Options:
     - "Yes" — Apply this change
     - "No" — Skip this change
     - "Skip all" — Keep remaining as-is

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
  `/to-jaan-skill-update {name}` → Check v3.0.0 compliance
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

Use AskUserQuestion to ask the user:
- Question: "Apply these changes?"
- Header: "Apply"
- Options:
  - "Yes" — Apply all changes
  - "No" — Cancel and discard
  - "Edit" — Let me revise the plan first

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

Use AskUserQuestion:
- Question: "Write these updates?"
- Header: "Write"
- Options:
  - "Yes" — Write all updated files
  - "No" — Cancel

## Step 11: Write Updated Files

If approved:
1. Write SKILL.md to `skills/{name}/SKILL.md`
2. Write template.md to `skills/{name}/template.md` (if modified)
3. Write LEARN.md to `skills/{name}/LEARN.md`

Confirm: "Skill files updated in `skills/{name}/`"

## Step 12: Auto-Invoke Documentation Sync

Run `/to-jaan-docs-update {name}` to sync:
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
> For example, if updating `to-jaan-docs-create`:
> ```
> /to-jaan-docs-create skill "my-new-feature"
> ```
>
Use AskUserQuestion:
- Question: "Did the skill work correctly?"
- Header: "Test"
- Options:
  - "Yes" — Works as expected
  - "No" — Has issues to fix

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

## Step 15: Create Pull Request

When user confirms working, use AskUserQuestion:
- Question: "Create pull request to merge to main?"
- Header: "PR"
- Options:
  - "Yes" — Push branch and create PR
  - "No" — Keep branch, merge manually later

If yes:
```bash
git push -u origin update/{name}
gh pr create --title "fix(skill): Update {name} skill" --body "$(cat <<'EOF'
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

Use AskUserQuestion:
- Question: "Any feedback on the skill update process?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update something in the skill
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update skill files, re-validate
- **Learn**: Run `/to-jaan-learn-add to-jaan-skill-update "{feedback}"`
- **Both**: Do both

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
/to-jaan-learn-add to-jaan-skill-update "Auto-fix missed pattern: \`Read(jaan-to/docs/**)\` in doc-generation skills. Add to v3-autofix.sh transformations."
```

---

## Step 17: Auto-Invoke Roadmap Update

Run `/to-jaan-roadmap-update` to sync the skill update with the roadmap.

This ensures the roadmap reflects the latest skill changes.

---

## Definition of Done

- [ ] Existing skill files read and analyzed
- [ ] Specification compliance validated
- [ ] User-selected updates applied
- [ ] Passes specification validation after update
- [ ] Documentation synced via /to-jaan-docs-update
- [ ] User tested and confirmed working
- [ ] PR created (or branch ready for manual merge)
- [ ] Roadmap synced via /to-jaan-roadmap-update
- [ ] User approved final result
