# Role Orchestrator Skills

> Phase 6 | Status: pending

## Description

Create a single orchestrator skill per role (PM, UX, DEV, QA, DevOps, SEC) that intelligently coordinates all sub-skills within that role using Claude Code Agent Teams. Update team-ship to delegate to these orchestrators as a meta-orchestrator.

**Problem**: Users must know individual skill names (`pm-prd-write`, `qa-test-cases`, etc.) and chain them manually. `team-ship` manages all roles monolithically — adding sub-skills requires editing its reference docs.

**Solution**: Role orchestrator skills (`/pm`, `/ux`, `/dev`, `/qa`, `/devops`, `/sec`) that:
- Standalone invocation — user calls `/pm` and the orchestrator decides which sub-skills to run
- Agent Teams coordination — assembles a team of sub-skill agents within the role
- Dynamic discovery — reads `sub-skills.md` registry, no hardcoded skill lists
- Composable — `team-ship` delegates to orchestrators instead of managing individual skills

### Architecture

```
team-ship (CEO / meta-orchestrator)
  ├── /pm orchestrator → pm-research-about, pm-prd-write, pm-story-write
  ├── /ux orchestrator → ux-research-synthesize, ux-flowchart-generate, ux-microcopy-write, ux-heatmap-analyze
  ├── /dev orchestrator → dev-docs-fetch, backend-*, frontend-*, dev-project-assemble, dev-output-integrate, dev-verify
  ├── /qa orchestrator → qa-test-cases, qa-test-generate, qa-test-run, qa-contract-validate, qa-issue-validate, qa-quality-gate, qa-tdd-orchestrate, qa-test-mutate, qa-issue-report
  ├── /devops orchestrator → devops-infra-scaffold, devops-deploy-activate
  └── /sec orchestrator → sec-audit-remediate
```

Two-level agent hierarchy: `team-ship → role orchestrators → sub-skill agents`

## Acceptance Criteria

### Shared Infrastructure
- [ ] Create `docs/extending/role-orchestrator-reference.md` — shared SKILL.md skeleton, sub-skills.md format, prompts.md format
- [ ] Define orchestrator naming convention in `docs/extending/naming-conventions.md`

### 6 Role Orchestrator Skills
- [ ] `skills/pm/` — SKILL.md + sub-skills.md + prompts.md (3 sub-skills)
- [ ] `skills/ux/` — SKILL.md + sub-skills.md + prompts.md (4 sub-skills)
- [ ] `skills/dev/` — SKILL.md + sub-skills.md + prompts.md (12+ sub-skills: backend-*, frontend-*, dev-*)
- [ ] `skills/qa/` — SKILL.md + sub-skills.md + prompts.md (9 sub-skills)
- [ ] `skills/devops/` — SKILL.md + sub-skills.md + prompts.md (2 sub-skills)
- [ ] `skills/sec/` — SKILL.md + sub-skills.md + prompts.md (1-2 sub-skills)

### Orchestrator Behavior
- [ ] Each orchestrator analyzes user request and determines which sub-skills to run (AI reasoning)
- [ ] Each orchestrator uses Claude Code Agent Teams (TeamCreate, Task with team_name, SendMessage)
- [ ] Each orchestrator supports `--track fast|full`, `--skills skill1,skill2`, `--dry-run` flags
- [ ] Single sub-skill requests run directly without team overhead
- [ ] Multi sub-skill requests spawn parallel agents where dependencies allow
- [ ] Dynamic sub-skill discovery from `sub-skills.md` (not hardcoded in SKILL.md)
- [ ] HARD STOP before execution — user approves planned sub-skill chain
- [ ] Outputs collected and summarized to user on completion

### team-ship Integration
- [ ] `skills/team-ship/roles.md` — add `Orchestrator` field to each role
- [ ] `skills/team-ship/SKILL.md` — orchestrator-aware spawn logic (if Orchestrator field → delegate, else → direct chain)
- [ ] `docs/extending/team-ship-reference.md` — add orchestrator spawn prompt templates
- [ ] Backward compatibility — direct skill chains remain as fallback when no orchestrator exists
- [ ] `--legacy` flag forces old direct-chain behavior

### Quality & Docs
- [ ] All 6 orchestrator skills pass `/skill-update` validation
- [ ] Roadmap updated with task reference
- [ ] Plugin manifest updated (if applicable)

## Dependencies

- Claude Code Agent Teams feature (experimental — requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- All existing sub-skills must be functional
- team-ship v7.2.0+ (stable orchestration patterns)

## Implementation Notes

### Files Per Orchestrator (3 files each)

| File | Purpose | Lines |
|------|---------|-------|
| `skills/{role}/SKILL.md` | Orchestrator logic — references shared template | ~200-300 |
| `skills/{role}/sub-skills.md` | Sub-skill registry with tracks, deps, intent hints | ~50-100 |
| `skills/{role}/prompts.md` | Spawn prompt templates for sub-agents | ~50-150 |

### sub-skills.md Format

```markdown
# {Role} Sub-Skills

## {skill-name}
- **Description**: {what it does}
- **Track**: fast, full
- **Phase**: 1 (early) | 2 (main) | 3 (late)
- **Depends on**: {other sub-skill output} or "none"
- **Outputs**: {what it produces}
- **When to use**: {intent matching hints for AI reasoning}
```

### SKILL.md Common Pattern

```yaml
---
name: {role}
description: {Role} orchestrator — coordinate {role} sub-skills via agent teams. Use when you need {role} work.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[task description] [--track fast|full] [--skills skill1,skill2] [--dry-run]"
context: fork
---
```

Execution flow:
1. Phase 0: Read sub-skills.md → analyze request → match intent to sub-skills → present plan (HARD STOP)
2. Phase 1: TeamCreate → spawn sub-agents → coordinate execution
3. Phase 2: Collect outputs → present summary → shutdown team → capture feedback

### team-ship roles.md Update

Add `Orchestrator` field:
```markdown
## pm
- **Orchestrator**: pm
- **Title**: Product Manager
- **Skills**: [pm-research-about, pm-prd-write, pm-story-write]  ← fallback
```

### Extensibility

**Add sub-skill to existing role**: Create skill + add to `sub-skills.md` → done
**Add new role**: Create orchestrator + add to `roles.md` with Orchestrator field → done

### Future Roles (ready to add when skills ship)
- `data` — data-gtm-datalayer + future data-* skills
- `growth` — future growth-* skills
- `delivery` — future delivery-* skills
- `sre` — future sre-* skills
- `support` — future support-* skills
- `release` — future release-* skills

### Token Budget
- Total new content: ~2000-3000 lines across all 18+ files
- Each orchestrator is lightweight — references shared `role-orchestrator-reference.md`

### Implementation Priority
1. `pm` (3 sub-skills — simplest, good first implementation to validate pattern)
2. `dev` (12+ sub-skills — highest user value)
3. `qa` (9 sub-skills — most complex orchestration)
4. `ux` (4 sub-skills)
5. `devops` (2 sub-skills)
6. `sec` (1-2 sub-skills)

## Verification

1. **Dry-run**: `/pm "Build a task manager" --dry-run` → shows planned sub-skills
2. **Standalone**: `/qa "Run tests"` → assembles QA team, runs appropriate sub-skills
3. **team-ship integration**: `/team-ship "Build a landing page" --track fast` → delegates to orchestrators
4. **Extensibility**: Add fake sub-skill to `skills/pm/sub-skills.md` → PM orchestrator discovers it
5. **Fallback**: Remove Orchestrator field from role → team-ship falls back to direct chain
6. **Validation**: `/skill-update` passes on all 6 orchestrators

## References

- team-ship skill: `skills/team-ship/SKILL.md`
- Role definitions: `skills/team-ship/roles.md`
- Spawn prompts: `docs/extending/team-ship-reference.md`
- Skill creation spec: `docs/extending/create-skill.md`
- Claude Code Agent Teams: https://code.claude.com/docs/en/agent-teams
- Plan: `.claude/plans/federated-cuddling-sunrise.md`
