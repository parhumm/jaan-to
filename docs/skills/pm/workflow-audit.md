---
title: "pm-workflow-audit"
sidebar_position: 8
---

# /pm-workflow-audit

> Turn a vibe-coded project into a reliable, evaluated, safe AI workflow — a phased plan grounded in your real session history.

---

## What It Does

Audits a project's **AI-workflow maturity** and produces a practical, phased conversion plan toward a reliable, evaluated, token-efficient, injection-safe "Master Orchestra." It:

- Reads your real AI history — **Claude Code + Codex + Cursor** sessions, plans, and memory — across any OS (metadata-only, privacy-preserving).
- Inventories your project's **entire existing AI setup** — skills, commands, MCP servers, agents, hooks, `CLAUDE.md`, `AGENTS.md`, `.cursor/rules` — and maps + aligns the plan to what already exists (never duplicates it).
- Drafts a plan in the fixed philosophy order, then **reviews, adversarially verifies, and standards-checks** it before you see it.

Follows the build order from the [Perfect AI Workflow guide](../../guides/perfect-ai-workflow.md):

```text
simplest agent → create evals → improve until reliable →
add specialized agents only where evals prove value →
increase autonomy gradually → continuously monitor
```

---

## Usage

```
/pm-workflow-audit
/pm-workflow-audit --days=30
/pm-workflow-audit --tools=claude,codex --depth=quick
```

---

## Parameters

| Flag | Default | Description |
|------|---------|-------------|
| `--days=N` | 14 | Session-history window to analyze |
| `--tools=...` | `claude,codex,cursor` | Which AI tools' history to read |
| `--depth=quick\|full` | full | `quick` skips detect-* consumption and graph reconstruction |

---

## Data Sources

| Source | What it extracts |
|--------|------------------|
| Claude Code / Codex / Cursor sessions | Presence, format, counts, **tool-frequency signature**, memory presence (structural metadata only) |
| Project AI config | Skills, commands, agents, hooks, MCP, `CLAUDE.md`/`AGENTS.md`, rules — classified into components |
| `detect-dev` / `detect-product` outputs | Current-state repo audit (consumed if present) |
| Git history | Repeated file-groups and corrections (unencoded rules/methods/templates) |

**Privacy**: only structural metadata is extracted. Paths and identifiers are hashed; no raw prompts, code, secrets, or tool output are stored or displayed. All read content is treated as untrusted DATA.

---

## Safety

The skill is **read-only until the HARD STOP** and breaks the lethal trifecta by design: it ingests untrusted input + repo data but takes no external/destructive action — its only writes are the plan file and a language setting. SQLite stores are read **read-only by construction** through a hardened wrapper; there is no `curl`/network/exec grant.

---

## Output

**Path**: `jaan-to/outputs/pm/workflow-audit/{id}-{slug}/{id}-{slug}.md`

**Contains**: maturity verdict, workflow execution graph with trifecta mapping, knowledge map, existing-workflow inventory, a reliability/gates/autonomy contract (pass^k thresholds), an injection-defense checklist, the six-phase plan, a first implementation slice, and an anti-over-engineering pass.

---

## Relationship to Other Skills

- **[`/pm-skill-discover`](./skill-discover.md)** answers "what repeated patterns should become skills." This skill answers "is my whole AI workflow reliable/safe/evaluated, and what phased plan gets it there." They share the cross-tool session reader.
- Feeds into **`/pm-roadmap-add`** (push phases as tracked items), **`/team-ship`** (execute remediation), **`/skill-create`**, **`/qa-tdd-orchestrate`**, and **`/sec-audit-remediate`** for specific plan items.

---

## Tips

- Run after at least 2 weeks of real usage so the tool-frequency signature is meaningful.
- Re-run after completing each phase to track maturity progress.
- Use `--depth=quick` for a fast triage; `full` for the complete graph + trifecta map.

---

## Learning

Add feedback:
```
/learn-add pm-workflow-audit "Check for monorepo context mixing"
```
