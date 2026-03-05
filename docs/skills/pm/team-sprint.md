---
title: "team-sprint"
sidebar_position: 9
---

# /team-sprint

> Run a full development sprint cycle from planning to PR.

---

## What It Does

Orchestrates a complete sprint cycle by composing two skills:
1. `/pm-sprint-plan` — assess project state, build execution queue
2. `/team-ship --track sprint` — execute the plan via Agent Teams

Additionally handles the full git lifecycle:
- Creates a cycle branch from dev
- Commits execution results
- Marks completed ROADMAP items
- Writes gap report
- Creates PR to dev

---

## Usage

```
/team-sprint
/team-sprint 5
/team-sprint 3 --focus code --tasks "auth,payments"
```

---

## Arguments

| Argument | Description |
|----------|-------------|
| `[cycle-number]` | Cycle number (auto-detected if omitted) |
| `--focus` | Scope filter passed to pm-sprint-plan |
| `--tasks` | Task keywords passed to pm-sprint-plan |

---

## Prerequisites

- `ROADMAP.md` must exist in project root
- `agent_teams_enabled: true` in `jaan-to/config/settings.yaml`
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable
- Clean git working tree on `dev` branch

---

## Lifecycle

1. **Pre-flight**: Create cycle branch, verify plugin, security check
2. **Plan**: Invoke `/pm-sprint-plan` (HARD STOP for approval)
3. **Execute**: Invoke `/team-ship --track sprint` (Agent Teams)
4. **Post-cycle**: Mark ROADMAP, write gap report, create PR

---

## Output

- Sprint plan artifact in `jaan-to/outputs/pm/sprint-plan/`
- Gap report in `gap-reports/{N}-cycle/`
- Cycle report using template
- PR to dev branch

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `/pm-sprint-plan` | Planning phase (invoked by team-sprint) |
| `/team-ship` | Execution engine (--track sprint) |
| `/release-iterate-changelog` | Changelog update (post-cycle) |

---

## Notes

- `disable-model-invocation: true` — invoke manually via `/team-sprint`
- Follows `team-{action}` naming pattern (matches `/team-ship`)
- Requires Agent Teams for parallel execution
