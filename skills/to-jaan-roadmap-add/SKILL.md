---
name: to-jaan-roadmap-add
description: |
  [Internal] Add a task to the jaan.to development roadmap.
  For jaan.to project maintenance, not end-user use.
  Maps to: to-jaan-roadmap-add
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**)
argument-hint: [task-description]
---

# to-jaan-roadmap-add

> Add tasks to jaan.to roadmap with duplication check and proper formatting.

## Context Files

- `jaan-to/roadmap.md` - Current roadmap
- `jaan-to/tasks/` - Task standards
- `$JAAN_LEARN_DIR/to-jaan-roadmap-add.learn.md` - Past lessons (loaded in Pre-Execution)

## Input

**Task**: $ARGUMENTS

If no input provided, ask: "What task would you like to add to the roadmap?"

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/to-jaan-roadmap-add.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Read Current Roadmap

Read `jaan-to/roadmap.md` to understand:
- Current phases and their status (Done/Pending)
- Existing tasks in each phase
- Formatting conventions

## Step 2: Duplication Check

Extract keywords from the task description and search:
```
grep -i "<keyword>" jaan-to/roadmap.md
```

If potential duplicate found, use AskUserQuestion:
- Question: "Similar task exists: '{existing}' in Phase {n}. Proceed?"
- Header: "Duplicate"
- Options:
  - "Yes" — Create a new task anyway
  - "No" — Cancel
  - "Merge" — Merge with existing task

## Step 3: Phase Detection

Determine which phase the task belongs to:

| Task Pattern | Suggested Phase |
|--------------|-----------------|
| Foundation, setup, optimization | Phase 1 (Done) |
| Learning, docs, context | Phase 2 (Done) |
| Development workflow, constitution | Phase 3 |
| Quick win skills (no MCP) | Phase 4 |
| MCP connectors, infrastructure | Phase 5 |
| Advanced skills (need MCP) | Phase 6 |
| Tests, polish, export | Phase 7 |
| Distribution, plugin | Phase 8 |

Use AskUserQuestion:
- Question: "Add to Phase {suggested}?"
- Header: "Phase"
- Options:
  - "Yes" — Add to suggested phase
  - "Different" — Let me specify a different phase

If "Different", ask (text response expected):
> "Which phase? (1-8)"

## Step 4: Detail Check

Use AskUserQuestion:
- Question: "Does this need a detailed task doc in `tasks/`?"
- Header: "Detail"
- Options:
  - "Yes" — Create a tasks/{slug}.md file
  - "No" — Inline task only

---

# HARD STOP - Human Review Check

Show preview:
```markdown
Ready to Add

**Phase:** {phase}
**Task:** `- [ ] {formatted task}`
**Detail doc:** {yes/no - tasks/{slug}.md}

```

Use AskUserQuestion:
- Question: "Add this task to the roadmap?"
- Header: "Add"
- Options:
  - "Yes" — Add the task
  - "No" — Cancel
  - "Edit" — Let me revise it

**Do NOT proceed without explicit approval.**

---

# PHASE 2: Write

## Step 5: Format Task

Format: `- [ ] {Task description}`
- If detail doc: `- [ ] {Task} → [details](tasks/{slug}.md)`
- Max 5 sub-bullets for inline details

## Step 6: Write to Roadmap

1. Read current file for exact insertion point
2. Append task to correct phase section
3. Write using Edit tool
4. If detail doc needed: create `jaan-to/tasks/{slug}.md` using template

## Step 7: Auto-Commit

```bash
git add jaan-to/roadmap.md jaan-to/tasks/
git commit -m "docs(roadmap): Add {task-title} to Phase {n}"
```

## Step 8: Confirm

```markdown
Task Added

**Phase:** {n}
**Task:** - [ ] {task}
**Commit:** {hash}

```

Use AskUserQuestion:
- Question: "Push to remote?"
- Header: "Push"
- Options:
  - "Yes" — Push to origin
  - "No" — Keep local only
```

---

## Error Handling

### No Description
> "No task description. Usage: `/to-jaan-roadmap-add Add LEARN.md files`"

### Duplicate Found
> "Similar task '{existing}' exists. Options: proceed / merge / cancel"

### Invalid Phase
> "Invalid phase. Valid: 1, 2, 3, 4, 5, 6, 7, 8"

---

## Trust Rules

1. **NEVER** add without user confirmation
2. **ALWAYS** check for duplicates first
3. **PRESERVE** existing formatting
4. **ASK** when phase is ambiguous
