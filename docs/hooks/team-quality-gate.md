---
title: "team-quality-gate"
---

# team-quality-gate

> Blocks task completion when agent team outputs are empty or incomplete.

---

## When It Runs

- **Type**: TaskCompleted
- **Trigger**: When any task is marked complete during agent team orchestration

---

## What It Does

Checks if completed tasks produced expected output files. Targets key skill outputs: PRDs, scaffolds, test files, API contracts, and data models. Blocks completion if the output directory exists but is empty.

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|
| Output exists with files | 0 | Allow completion |
| No output path in task | 0 | Allow completion (not a tracked output) |
| Quality gate disabled | 0 | Allow completion |
| Output directory is empty | 2 | Block completion, send feedback |

---

## Configuration

Controlled by `agent_teams_quality_gate` in `jaan-to/config/settings.yaml`:

```yaml
agent_teams_quality_gate: true   # default
```

Set to `false` to disable quality checks on task completion.

---

## What You See

When blocked:
```
Quality gate: Output directory is empty (jaan-to/outputs/backend/scaffold/01-auth).
Ensure the skill completed successfully before marking done.
```
