---
title: "Give Soul to Your Workflow: Why We Built jaan.to"
slug: give-soul-to-your-workflow
authors: [parhum]
tags: [philosophy, announcement]
---

AI doesn't have a consistency problem. Teams do.

40–60% of product work is repetitive. Same request, different outcomes depending on who asks, when they ask, and how much context they remember. PRDs miss sections. Test plans skip edge cases. Tracking implementations drift from spec to spec.

The problem isn't capability. It's consistency.

<!-- truncate -->

## The philosophy

**Let AI handle the hands. Keep humans on the mind.**

jaan.to is a workflow layer for Claude Code. It standardizes execution so teams stop reinventing the same deliverables. The repetitive parts—formatting PRDs, writing test matrices, generating boilerplate—get automated. The human parts stay human.

Humans become more senior:
- **Clarity** — Defining the right problem
- **Judgment** — Making trade-off decisions
- **Customer empathy** — Understanding real needs
- **Quality** — Knowing when "done" means done

## How it works

Four components, each with a single responsibility:

- **Skills** know *what* to do
- **Stacks** know *how* your team works
- **Templates** know *what* outputs look like
- **Learning** knows *what went wrong before*

Skills stay generic. Your tech stack, team structure, and integration config live in context files. One skill definition works across teams because the real context comes from your environment.

## The two-phase workflow

Every skill follows the same pattern:

1. **Phase 1 (Analysis)** — Read context, gather input, plan structure. Read-only. No side effects.
2. **Hard stop** — You review. You approve. Nothing proceeds without your say.
3. **Phase 2 (Generation)** — Generate, validate, preview, write.

No surprises. No files appearing without consent. The human stays in control.

## The learning system

Every skill remembers. When something fails, when users give feedback, when bugs are fixed—it's captured. Next time, the skill reads its lessons first.

Learning happens at three layers:
- **Skill learning** — Better questions to ask, edge cases to check
- **Template learning** — Missing sections, phrasing improvements
- **Stack learning** — Tech constraints, team norms, integration quirks

The system gets better over time because feedback routes to the right place.

## What's available now

21 skills across 6 roles:

| Role | What it covers |
|------|---------------|
| **PM** | PRDs, user stories, research |
| **Dev** | API contracts, data models, task breakdowns, frontend design |
| **UX** | Heatmap analysis, microcopy, research synthesis |
| **QA** | Test case generation |
| **Data** | GTM tracking implementation |
| **Core** | Docs, learning, roadmap, skill management |

Open source. MIT licensed. Install with one command:

```
/plugin marketplace add parhumm/jaan-to
```

## What's next

- **MCP connectors** — Bridge skills to real systems: Figma, Jira, GA4, GitLab
- **More roles** — DevOps, Growth, SEO
- **Community skills** — Build and share your own

## Start minimal

This is not replacing teams. This is making teams faster.

Start with one skill. See if it helps. Add more as you grow. Every component is optional except core safety.

Learn fast. Extend as needed. Give soul to your workflow.
