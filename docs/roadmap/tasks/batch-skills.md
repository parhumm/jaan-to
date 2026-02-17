---
title: "Batch / Combination Skills"
sidebar_position: 13
---

# Batch / Combination Skills

> Phase 6 | Status: pending

## Problem

Shipping an idea from concept to production requires invoking many individual skills in sequence. Users must know the correct order, manually pass outputs between skills, and track progress across 10+ skill invocations. This friction slows adoption and increases the chance of skipping steps.

## Solution

Create **role-level batch skills** that orchestrate a chain of individual skills into a single end-to-end workflow. Each batch skill runs the full pipeline for a role, with minimal human intervention between steps.

## Existing Pattern

The `detect-pack` skill already demonstrates this pattern — it aggregates outputs from 5 independent detect skills into a single consolidated result. Similarly, `dev-project-assemble` wires together backend and frontend scaffolds.

## Proposed Batch Skills

| Batch Skill | Role | Chain | Human Stops |
|-------------|------|-------|-------------|
| `pm-idea-to-prd` | PM | research → problem-statement → competitor-matrix → persona → prd-write → story-write | After research, after PRD |
| `dev-spec-to-code` | Dev | task-breakdown → scaffold → service-implement → verify | After breakdown |
| `wp-plugin-ship` | WP | (consolidated 7 WP skills in sequence) | After plan, after build |
| `qa-full-cycle` | QA | test-cases → test-generate → test-run | After cases |
| `ux-design-to-handoff` | UX | flowchart → research-synthesize → microcopy → heatmap-analyze | After flowchart |
| `detect-full-audit` | Detect | dev → design → ux → writing → product → security → pack | None (fully automated) |

## Design Principles

1. **Each batch skill reads outputs from previous step** — no manual copy-paste
2. **Human approval gates** at key decision points (not every step)
3. **Resumable** — if interrupted, can continue from last completed step
4. **Individual skills still work standalone** — batch is an orchestration layer
5. **Output structure** follows existing `$JAAN_OUTPUTS_DIR/{role}/batch/{id}-{slug}/`

## Implementation Steps

1. Define batch skill specification pattern (extends SKILL.md frontmatter)
2. Implement first batch: `detect-full-audit` (simplest — no human gates)
3. Implement `pm-idea-to-prd` (most valuable — highest friction reduction)
4. Implement remaining batch skills per role priority
5. Add `--dry-run` flag to preview the chain without executing

## Dependencies

- All individual skills in each chain must be shipped first
- PM role gap skills needed for `pm-idea-to-prd`
- WP consolidation needed for `wp-plugin-ship`
