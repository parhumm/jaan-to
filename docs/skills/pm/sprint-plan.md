---
title: "pm-sprint-plan"
sidebar_position: 8
---

# /pm-sprint-plan

> Assess project progress and build a prioritized sprint plan from ROADMAP gaps.

---

## What It Does

Reads your project state (ROADMAP.md, gap reports, scorecards) and produces a structured sprint plan with:
- Progress matrix (specification, scaffold, code, tests, infrastructure percentages)
- Bottleneck classification via state machine
- Prioritized execution queue (max 12 items from 7 priority sources)
- Risk assessment per queue item

The sprint plan artifact is consumed by `/team-ship --track sprint` for automated execution.

---

## Usage

```
/pm-sprint-plan
/pm-sprint-plan --focus code
/pm-sprint-plan --tasks "auth,payments"
/pm-sprint-plan --focus test --tasks "login,profile"
```

---

## Arguments

| Argument | Description |
|----------|-------------|
| `--focus` | Scope filter: `spec`, `scaffold`, `code`, `test`, `audit` |
| `--tasks` | Comma-separated task keywords to match against ROADMAP.md |

---

## Input Requirements

| File | Required | If Missing |
|------|----------|------------|
| `ROADMAP.md` | Yes | Skill stops with message |
| `gap-reports/` | No | Skips progress matrix |
| `scorecards/` | No | Skips trend analysis |
| `tech.md` | No | Skips stack-specific filtering |

---

## Output

Sprint plan artifact written to `jaan-to/outputs/pm/sprint-plan/`.

Includes machine-readable YAML frontmatter for consumption by team-ship.

---

## Workflow

1. **Phase 1** (Read-Only): Read project state, calculate progress, classify bottleneck, build queue
2. **HARD STOP**: Present sprint plan for user approval
3. **Phase 2**: Write approved plan to output directory

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `/team-sprint` | Invokes pm-sprint-plan as its planning phase |
| `/team-ship --track sprint` | Consumes the sprint plan artifact |
| `/pm-roadmap-add` | Populates the ROADMAP that pm-sprint-plan reads |

---

## Notes

- Both `disable-model-invocation: true` — invoke manually via `/pm-sprint-plan`
- Reference material in `docs/extending/pm-sprint-plan-reference.md`
