# Agent Teams Integration for jaan-to

> Research: How Claude Code Agent Teams can power role-based parallel execution in jaan-to.

**Source**: [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)
**Status**: Experimental (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
**Date**: 2026-02-18

---

## Executive Summary

Claude Code Agent Teams allow spawning multiple independent Claude Code sessions as teammates, coordinated by a lead session through shared task lists and direct messaging. jaan-to's role-based architecture maps naturally: each teammate IS a role (PM, Backend, Frontend, QA, etc.), running their skill chains in parallel while the lead orchestrates like a CTO.

**Key decision**: One orchestration skill (`team-ship`) instead of multiple team-* skills. `roles.md` is the scalable data layer — add a role definition, the orchestrator adapts automatically.

---

## Agent Teams Feature Summary

| Aspect | Detail |
|--------|--------|
| Architecture | Lead session + N teammate sessions, each with own context window |
| Coordination | Shared task list with claim/assign + direct inter-agent messaging |
| Display modes | In-process (default) or split-pane (tmux/iTerm2) |
| Delegate mode | Lead restricted to coordination-only tools |
| Hooks | `TeammateIdle` (exit 2 = feedback), `TaskCompleted` (exit 2 = block) |
| Permissions | Teammates inherit lead's permission settings |
| Context | Teammates load CLAUDE.md + MCP + skills but NOT lead's conversation history |
| Limitations | No session resumption, one team per session, no nested teams |

## Pipeline Parallelism Analysis

### Idea-to-Product Pipeline Dependency Graph

```
Phase 1 (Sequential): PM → PRD approval gate
Phase 2 (Parallel):   Backend ∥ Frontend ∥ QA ∥ UX
Phase 3 (Parallel):   Integration ∥ DevOps ∥ Security
Phase 4 (Sequential): Verify → Changelog
```

### File Ownership Matrix (No Conflicts)

| Role | Writes To | Never Touches |
|------|----------|---------------|
| PM | `$JAAN_OUTPUTS_DIR/pm/`, `$JAAN_OUTPUTS_DIR/research/` | Code files |
| UX | `$JAAN_OUTPUTS_DIR/ux/` | Code files |
| Backend | `$JAAN_OUTPUTS_DIR/backend/` | Frontend files |
| Frontend | `$JAAN_OUTPUTS_DIR/frontend/` | Backend files |
| QA | `$JAAN_OUTPUTS_DIR/qa/` | Source code |
| DevOps | CI/CD, Docker configs | Application code |
| Security | `$JAAN_OUTPUTS_DIR/sec/` | Application code |

Only `dev-project-assemble` + `dev-output-integrate` write to `src/` — sequentially after all scaffolds complete.

### Inter-Teammate Dependencies

| From | To | Data Shared | Mechanism |
|------|----|-------------|-----------|
| PM | Backend, Frontend, QA, UX | PRD path, stories path | Message after PRD approval |
| Backend | Frontend | API contract path | Direct message |
| Backend | QA | Scaffold path | Direct message |
| Frontend | QA | Scaffold path | Direct message |
| UX | Frontend | Flowchart paths | Direct message |

## Token Cost Analysis

### Per-Teammate Session Cost

Each teammate loads the full plugin system prompt:
- ~8,400 chars skill descriptions (43 skills × ~195 chars avg)
- ~119 lines CLAUDE.md (~3K tokens)
- Session overhead: ~4-5K tokens per teammate

### Track Cost Comparison

| Track | Teammates | Max Concurrent | Estimated Session Overhead |
|-------|-----------|---------------|--------------------------|
| `--detect` | 5 (haiku) | 5 | ~25K tokens (haiku = cheaper) |
| `--track fast` | 4 | 3-4 | ~20K tokens |
| `--track full` | 7 | 4-5 | ~30K tokens |
| `--roles pm,backend` | 2 | 2 | ~10K tokens |

### Optimization Strategies Applied

1. **Reference extraction** — SKILL.md ≤500 lines, verbose content in team-ship-reference.md
2. **roles.md as data file** — on-demand, never in system prompt
3. **Compact spawn prompts** — ~200 tokens per teammate
4. **`context: fork`** — orchestration isolated from parent (saves 30-48K tokens)
5. **Per-role model selection** — haiku for detect, sonnet for code gen, inherit for PM
6. **Phased spawning** — max 4-5 concurrent, PM shut down after Phase 1
7. **Hook stdout cap** — ≤1,200 chars per hook

## Decision Rationale

### Why Agent Teams (Not Subagents) for Idea-to-Product

Subagents only report results back to the main agent. Agent teams allow:
- Backend → Frontend messaging (API contract handoff)
- QA waiting for signals from both Backend and Frontend
- Shared task list for self-coordination
- Independent context windows for heavy skill chains

Subagents are better for: detect-pack consolidation (lead runs it after teammates finish), context-scout (quick project scan), quality-reviewer (focused validation).

### Why One Skill (`team-ship`) Not Many

- Avoids skill sprawl (team-detect-audit, team-dev-cycle, team-qa-cycle, etc.)
- Single entry point for users: `/jaan-to:team-ship`
- `--track` and `--roles` flags cover all use cases
- `roles.md` as data layer means adding roles requires zero SKILL.md changes
- Description budget: 1 skill = ~100 chars instead of N × ~100 chars

### Why `roles.md` Auto-Sync (Three Mechanisms)

| Mechanism | Trigger | Purpose |
|-----------|---------|---------|
| skill-create Step 14.5 | New skill | Proactive: register in role |
| skill-update Step 11.5 | Skill modified | Proactive: sync changes |
| PostToolUse hook | Any SKILL.md write | Safety net: catch manual edits |

---

## Known Limitations

1. **No session resumption** — `/resume` doesn't restore in-process teammates. Mitigated by checkpoint system.
2. **Task status lag** — teammates may forget to mark tasks done. Mitigated by TeammateIdle hook.
3. **One team per session** — can't run multiple team-ship invocations concurrently.
4. **No nested teams** — teammates can't spawn their own teams.
5. **Split panes not in VSCode** — in-process mode only for VSCode integrated terminal.
6. **Experimental** — feature may change or break between Claude Code versions.

---

## References

- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [jaan-to idea-to-product guide](https://github.com/parhumm/jaanify/docs/idea-to-product.md)
- [Role Skills Catalog](../roadmap/tasks/role-skills.md)
- [Token Strategy](../token-strategy.md)
