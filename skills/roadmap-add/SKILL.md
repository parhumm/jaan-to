---
name: roadmap-add
description: |
  [Internal] Add a task to the jaan.to development roadmap.
  For jaan.to project maintenance, not end-user use.
  Maps to: jaan-to:roadmap-add
allowed-tools: Read, Glob, Grep, Write(roadmaps/**)
argument-hint: [task-description]
---

# jaan-to:roadmap-add

> Add tasks to jaan.to roadmap with duplication check and proper formatting.

## Context Files

- `roadmaps/jaan-to/roadmap-jaan-to.md` - Current roadmap
- `roadmaps/jaan-to/tasks/README.md` - Task standards

## Input

**Task**: $ARGUMENTS

If no input provided, ask: "What task would you like to add to the roadmap?"

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Read Current Roadmap

Read `roadmaps/jaan-to/roadmap-jaan-to.md` to understand:
- Current phases and their status (Done/Pending)
- Existing tasks in each phase
- Formatting conventions

## Step 2: Duplication Check

Extract keywords from the task description and search:
```
grep -i "<keyword>" roadmaps/jaan-to/roadmap-jaan-to.md
```

If potential duplicate found:
> "Similar task exists: '{existing}' in Phase {n}. Proceed anyway? [y/n/merge]"

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

Ask: "Add to Phase {suggested}? Or specify different phase (1-8)"

## Step 4: Detail Check

Ask: "Does this need a detailed task doc in `tasks/`? [y/n]"

---

# HARD STOP - Human Review Check

Show preview:
```markdown
Ready to Add

**Phase:** {phase}
**Task:** `- [ ] {formatted task}`
**Detail doc:** {yes/no - tasks/{slug}.md}

Confirm? [y/n/edit]
```

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
4. If detail doc needed: create `roadmaps/jaan-to/tasks/{slug}.md` using template

## Step 7: Auto-Commit

```bash
git add roadmaps/jaan-to/roadmap-jaan-to.md roadmaps/jaan-to/tasks/
git commit -m "docs(roadmap): Add {task-title} to Phase {n}"
```

## Step 8: Confirm

```markdown
Task Added

**Phase:** {n}
**Task:** - [ ] {task}
**Commit:** {hash}

Push to remote? [y/n]
```

---

## Error Handling

### No Description
> "No task description. Usage: `/jaan-to:roadmap-add Add LEARN.md files`"

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
