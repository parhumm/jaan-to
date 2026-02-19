---
title: "team-idle-redirect"
---

# team-idle-redirect

> Keeps idle teammates productive by suggesting unclaimed tasks.

---

## When It Runs

- **Type**: TeammateIdle
- **Trigger**: When a teammate in an agent team session is about to go idle

---

## What It Does

Detects when a teammate has no active work. Extracts the teammate's role from its name and suggests checking for unclaimed tasks matching that role, or shutting down to free context.

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|
| Agent teams disabled | 0 | Allow idle |
| No teammate name | 0 | Allow idle |
| No recognized role | 0 | Allow idle |
| Role-based teammate idle | 2 | Send feedback to check for unclaimed tasks |

---

## Configuration

Only active when `agent_teams_enabled: true` in `jaan-to/config/settings.yaml`.

---

## What You See

```
Teammate 'backend-engineer' (backend) is idle.
Check if there are unclaimed tasks for this role, or shut down to free context.
```
