---
title: "team-roles-sync-check"
---

# team-roles-sync-check

> Warns when a skill with a role prefix is missing from team-ship/roles.md.

---

## When It Runs

- **Type**: PostToolUse
- **Trigger**: After writing to any `skills/*/SKILL.md` file

---

## What It Does

Drift detection safety net for the agent teams role registry. When a SKILL.md file is written for a skill whose name starts with a known role prefix (pm-, backend-, frontend-, etc.), checks if that skill appears in `skills/team-ship/roles.md`. Warns if missing.

This catches manual edits that bypass the automatic sync in `/jaan-to:skill-create` and `/jaan-to:skill-update`.

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|
| Not a SKILL.md write | 0 | Skip |
| No role prefix in name | 0 | Skip |
| Skill found in roles.md | 0 | Silent pass |
| Skill missing from roles.md | 0 | Print warning note |

---

## Recognized Role Prefixes

`pm`, `ux`, `backend`, `frontend`, `qa`, `devops`, `sec`, `data`, `growth`, `delivery`, `sre`, `support`, `release`, `detect`

---

## What You See

```
NOTE: Skill 'backend-cache-optimize' (role: backend) is not in team-ship/roles.md.
Add it to enable agent team orchestration.
```
