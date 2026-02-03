---
name: to-jaan-learn-add
description: |
  Add a lesson to a skill's LEARN.md file.
  Routes feedback to skill, template, or context learning.
  Maps to: to-jaan-learn-add
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Bash(git add:*), Bash(git commit:*)
argument-hint: "[target] [lesson]"
---

# to-jaan-learn-add

> Route feedback to the appropriate LEARN.md file.

## Context Files

- `$JAAN_LEARN_DIR/*.learn.md` - Skill lessons
- `$JAAN_CONTEXT_DIR/*.md` - Context files and lessons

## Input

**Arguments**: $ARGUMENTS

Expected format: `"target" "lesson"`
- Target: skill name, `$JAAN_TEMPLATES_DIR/name`, or `$JAAN_CONTEXT_DIR/name`
- Lesson: the feedback to add

Examples:
- `/to-jaan-learn-add "jaan-to-pm-prd-write" "Always ask about rollback strategy"`
- `/to-jaan-learn-add "$JAAN_CONTEXT_DIR/tech" "All new tables need soft delete"`

If no input provided, ask for target and lesson.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Parse Input

Extract target and lesson from arguments.

If format is unclear:
1. "Which skill/context should this lesson apply to?"
2. "What is the lesson to add?"

## Step 2: Determine Target File

Route based on target:

| Target Pattern | LEARN.md Location |
|----------------|-------------------|
| Skill name (e.g., `pm-prd-write`) | `$JAAN_LEARN_DIR/{skill}.learn.md` |
| System skill (e.g., `skill-create`) | `$JAAN_LEARN_DIR/{skill}.learn.md` |
| `$JAAN_TEMPLATES_DIR/{name}` | `$JAAN_TEMPLATES_DIR/LEARN.md` |
| `$JAAN_CONTEXT_DIR/{name}` | `$JAAN_CONTEXT_DIR/LEARN.md` |
| `$JAAN_CONTEXT_DIR/tech` | `$JAAN_CONTEXT_DIR/tech.md` (constraints section) |
| `$JAAN_CONTEXT_DIR/team` | `$JAAN_CONTEXT_DIR/team.md` (norms section) |

## Step 3: Auto-Categorize Lesson

Detect category from lesson keywords:

| Category | Trigger Keywords |
|----------|------------------|
| Better Questions | ask, question, clarify, confirm, "should ask" |
| Edge Cases | edge, special, case, handle, check, "need to handle" |
| Workflow | workflow, process, step, order, "before/after" |
| Common Mistakes | avoid, mistake, wrong, don't, never, "should not" |

If unclear, use AskUserQuestion:
- Question: "Which category fits this lesson?"
- Header: "Category"
- Options:
  - "Questions" — Better questions to ask during gathering
  - "Edge Cases" — Special cases to check and handle
  - "Workflow" — Process improvements
  - "Mistakes" — Things to avoid

## Step 4: Read Current LEARN.md

Read the target LEARN.md file if it exists.
If it doesn't exist, prepare to create with template.

---

# HARD STOP - Human Review Check

Show preview:
```markdown
Ready to Add Lesson

**File:** {file path}
**Category:** {category}
**Lesson:** {lesson text}

Preview:
## {Category}
- {existing lessons...}
- {new lesson}  <-- NEW

```

Use AskUserQuestion:
- Question: "Add this lesson?"
- Header: "Confirm"
- Options:
  - "Yes" — Add the lesson
  - "No" — Cancel
  - "Edit" — Let me revise the lesson

**Do NOT proceed without explicit approval.**

---

# PHASE 2: Write

## Step 5: Update LEARN.md

If file exists:
1. Read current content
2. Find the category section (e.g., `## Better Questions`)
3. Append new lesson as bullet point
4. Update "Last updated" date
5. Write file

If file doesn't exist:
1. Create from template
2. Add lesson to appropriate category
3. Write file

### LEARN.md Template

```markdown
# Lessons: {skill-name}

> Last updated: {date}

## Better Questions
- {lesson if category matches}

## Edge Cases
- {lesson if category matches}

## Workflow
- {lesson if category matches}

## Common Mistakes
- {lesson if category matches}
```

## Step 6: Confirm Write

```markdown
Lesson Added

**File:** {path}
**Category:** {category}
**Lesson:** {lesson}
```

## Step 7: Offer to Commit

Use AskUserQuestion:
- Question: "Commit this lesson?"
- Header: "Commit"
- Options:
  - "Yes" — Stage and commit
  - "No" — Save locally without committing

**If confirmed:**
1. Stage: `git add {file_path}`
2. Commit: `git commit -m "learn({skill}): {short lesson summary}"`
3. Show: "Lesson committed: `{commit hash}`"

**If declined:**
- Skip commit, lesson is saved locally
- Show: "Lesson saved (not committed)"

---

## Error Handling

### No Target
> "No target specified. Which skill or context should this lesson apply to?"

### Target Not Found
> "Skill '{target}' not found. Available skills: {list}"

### Empty Lesson
> "No lesson provided. What feedback should be remembered?"

### LEARN.md Create Fail
> "Could not create LEARN.md. Check file permissions."

---

## Trust Rules

1. **NEVER** modify without user confirmation
2. **ALWAYS** show preview before writing
3. **PRESERVE** existing lessons
4. **ASK** when category is unclear
