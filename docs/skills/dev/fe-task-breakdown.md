---
title: "dev-fe-task-breakdown"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-03
updated_date: 2026-02-03
tags: [dev, frontend, task-breakdown, ux-handoff, components, atomic-design]
related: [stack-detect, fe-state-machine]
---

# /jaan-to:dev-fe-task-breakdown

> Transform UX design handoffs into production-ready frontend task breakdowns.

---

## Overview

Analyzes UX handoffs (Figma links, design descriptions, screenshots, or PRDs) and produces a structured task breakdown with component inventory, state matrices, estimate bands, dependency graphs, performance budgets, and risk assessment.

---

## Usage

```
/jaan-to:dev-fe-task-breakdown "User profile redesign with settings modal"
/jaan-to:dev-fe-task-breakdown "https://figma.com/file/abc123"
/jaan-to:dev-fe-task-breakdown "See PRD at jaan-to/outputs/pm/prd/profile-redesign/prd.md"
```

| Argument | Required | Description |
|----------|----------|-------------|
| ux-handoff | Yes | Figma link, design description, screenshot path, PRD path, or feature name |

---

## What It Produces

A comprehensive task breakdown document at `$JAAN_OUTPUTS_DIR/dev/frontend/{slug}/task-breakdown.md` containing:

| Section | Content |
|---------|---------|
| Component Inventory | All components identified with atomic design levels (Atom/Molecule/Organism/Template/Page) |
| State Matrices | 6 states per component: Default, Loading, Success, Error, Empty, Partial |
| Estimate Bands | T-shirt sizes: XS (<1h), S (1-2h), M (2-4h), L (4-8h), XL (1-2d) |
| State Machine Stubs | States, events, and transitions for complex components |
| Dependency Graph | Mermaid diagram showing build order and parallel tracks |
| Performance Budget | LCP, INP, CLS targets with specific optimization tasks |
| Risk Register | Technical, integration, and UX risks with mitigations |
| Coverage Checklist | Accessibility, responsive, testing items (50+ items at full scope) |
| Definition of Ready/Done | Checklists for task readiness and completion |

---

## Scope Levels

Selected interactively during execution:

| Scope | Coverage |
|-------|----------|
| **MVP** | Core functionality, happy path, basic loading/error states |
| **Production** | All 6 states, full accessibility, performance budgets, edge cases, 50+ checklist items |
| **In between** | Core + error/loading/empty states, essential accessibility |

---

## Methodology

Based on industry standards:

- **Atomic Design** (Brad Frost) for component taxonomy and sizing
- **PMI WBS 100% Rule** for completeness verification
- **Component-Driven Development** for parallelizable task structure
- **Core Web Vitals 2025** for performance targets (INP replaced FID)

---

## Tech Stack Integration

Reads `$JAAN_CONTEXT_DIR/tech.md` to adapt the breakdown for the project's framework:
- React 18+ patterns: Suspense boundaries, useTransition, Server Components
- Next.js 14+ patterns: App Router file conventions, Server Actions
- Framework-agnostic fallback when tech.md unavailable

---

## Workflow Chain

This skill fits in the dev workflow:

```
/jaan-to:dev-tech-plan → /jaan-to:dev-fe-task-breakdown → /jaan-to:dev-fe-state-machine
```

After generating the task breakdown, the skill suggests running `/jaan-to:dev-fe-state-machine` for detailed state machine definitions per component.

---

## Research Source

Based on comprehensive framework research at `jaan-to/outputs/research/51-dev-fe-task-breakdown.md` covering PMI WBS, Atomic Design, CDD, Shape Up, Feature-Sliced Design, and React/Next.js specific patterns.

---

[Back to Dev Skills](README.md) | [Back to All Skills](../README.md)
