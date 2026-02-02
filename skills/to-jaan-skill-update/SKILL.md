---
name: to-jaan-skill-update
description: |
  Update an existing jaan.to skill following standards.
  Auto-triggers on: update skill, modify skill, improve skill, fix skill.
  Maps to: to-jaan-skill-update
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write(skills/**), Write(docs/**), Write($JAAN_OUTPUTS_DIR/**), Edit, Bash(git checkout:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [skill-name]
---

# to-jaan-skill-update

> Update existing jaan.to skills with specification compliance and documentation sync.

## Context Files

- `jaan-to/docs/create-skill.md` - Skill specification (REQUIRED)
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
> "Did it work correctly? [y/n]"

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

## Step 15: Create Pull Request

When user confirms working:
> "Create pull request to merge to main? [y/n]"

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

> "Any feedback on the skill update process? [y/n]"

If yes:
- Run `/to-jaan-learn-add to-jaan-skill-update "{feedback}"`

---

## Definition of Done

- [ ] Existing skill files read and analyzed
- [ ] Specification compliance validated
- [ ] User-selected updates applied
- [ ] Passes specification validation after update
- [ ] Documentation synced via /to-jaan-docs-update
- [ ] User tested and confirmed working
- [ ] PR created (or branch ready for manual merge)
- [ ] User approved final result
