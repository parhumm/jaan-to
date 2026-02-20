---
title: "team-ship"
sidebar_position: 10
---

# /jaan-to:team-ship

> Assemble role-based AI teammates to ship ideas from concept to production.

---

## What It Does

Spawns a virtual company of AI teammates — each a role (PM, Backend, Frontend, QA, UX, DevOps, Security) — to ship an initiative from idea to working product. The lead orchestrates teammates through phased execution with dependency management, quality gates, and checkpointing.

Uses Claude Code's Agent Teams feature. Each teammate gets its own context, runs role-specific skills, and communicates with other teammates via messaging.

---

## Usage

```
/jaan-to:team-ship "AI task manager with natural language input"
/jaan-to:team-ship --track fast "auth system"
/jaan-to:team-ship --detect
/jaan-to:team-ship --roles pm,backend "payment flow"
/jaan-to:team-ship --dry-run "social feed"
/jaan-to:team-ship --resume
```

---

## Arguments

| Argument | Effect |
|----------|--------|
| `[initiative]` | Idea to build (required unless --detect or --resume) |
| `--track fast` | 8-skill fast track: PM, Backend, Frontend, QA, DevOps |
| `--track full` | 20-skill full track with all roles (default) |
| `--detect` | Run 5 detect auditors in parallel, then consolidate |
| `--roles role1,role2` | Select specific roles only |
| `--dry-run` | Preview team plan without spawning |
| `--resume` | Continue from last checkpoint |

---

## Prerequisites

Before using team-ship:

1. **Enable agent teams** in `jaan-to/config/settings.yaml`:
   ```yaml
   agent_teams_enabled: true
   ```
2. **Set environment variable**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
3. **Initialize project**: Run `/jaan-to:jaan-init` if not already done

---

## Execution Phases

```
Phase 0 → Setup, validate, build team roster
        → HARD STOP: User approves team composition
Phase 1 → PM defines: PRD + stories
        → HARD STOP: User approves PRD
Phase 2 → Build team works in parallel:
          Backend, Frontend, QA, UX (full track)
Phase 3 → Integration + DevOps + Security
Phase 4 → Verify, changelog, cleanup
```

Each teammate shuts down after its phase completes to free context.

---

## Tracks

| Track | Teammates | Skills | Use When |
|-------|-----------|--------|----------|
| `--track full` | 7 | 20 | Full product with design + security |
| `--track fast` | 4-5 | 8 | Rapid prototype, skip design steps |
| `--detect` | 5 | 5+1 | Audit existing codebase |
| `--roles X,Y` | Custom | Varies | Targeted work on specific areas |

---

## Roles

| Role | Teammate | Key Skills |
|------|----------|------------|
| PM | Product Manager | research, prd-write, story-write |
| UX | UX Designer | flowchart-generate, microcopy-write |
| Backend | Backend Engineer | task-breakdown, data-model, api-contract, scaffold |
| Frontend | Frontend Engineer | task-breakdown, scaffold, design |
| QA | QA Engineer | test-cases, test-generate, test-run |
| DevOps | DevOps Engineer | infra-scaffold, deploy-activate |
| Security | Security Engineer | audit-remediate |

Role definitions live in `skills/team-ship/roles.md`. New roles are added automatically via `/jaan-to:skill-create`.

---

## Output

**Path**: `jaan-to/outputs/team/{id}-{slug}/`

| File | Content |
|------|---------|
| `log.md` | Orchestration log with timeline and results |
| `checkpoint.yaml` | Resume state for interrupted runs |
| `plan.md` | Team plan (--dry-run only) |

Each role writes to its own output directory (`jaan-to/outputs/pm/`, `jaan-to/outputs/backend/`, etc.) — no file conflicts.

---

## Example

**Input**:
```
/jaan-to:team-ship --track fast "user authentication with OAuth"
```

**What happens**:
```
1. Lead reads roles.md, builds fast-track roster (4 teammates)
2. User approves team composition
3. PM teammate drafts PRD → user approves
4. Backend + Frontend + QA work in parallel
5. Lead integrates scaffolds, DevOps sets up CI/CD
6. QA runs tests, lead verifies build
7. Changelog generated, team cleaned up
```

---

## Configuration

Available in `jaan-to/config/settings.yaml`:

| Key | Default | Description |
|-----|---------|-------------|
| `agent_teams_enabled` | `false` | Enable agent teams |
| `agent_teams_default_track` | `full` | Default track (fast/full) |
| `agent_teams_plan_approval` | `true` | Require plan approval |
| `agent_teams_quality_gate` | `true` | Quality checks on outputs |
| `agent_teams_teammate_model` | (inherit) | Override teammate model |
| `agent_teams_detect_model` | `haiku` | Model for detect skills |

---

## Tips

- Start with `--dry-run` to preview the team plan before committing
- Use `--track fast` for prototyping, `--track full` for production
- The `--resume` flag picks up from the last checkpoint after interruptions
- Each role uses the optimal model (haiku for detect, sonnet for code gen)
- Provide a detailed initiative description for better PRD quality
