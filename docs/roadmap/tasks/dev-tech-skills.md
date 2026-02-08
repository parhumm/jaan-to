---
title: "Dev Tech Skill Family"
sidebar_position: 2
---

# Dev Tech Skill Family

> Phase 3 + 3.5 | Status: pending

## Description

Spec-driven development workflow inspired by GitHub's spec-kit. A cohesive skill family that guides developers from technical planning through implementation.

## Skills Overview

| Skill | Phase | Purpose | Spec-Kit Equivalent |
|-------|-------|---------|---------------------|
| `/jaan-to:dev-tech-plan` | 3 | Technical planning | `/speckit.plan` |
| `/jaan-to:dev-tech-tasks` | 3 | Task decomposition | `/speckit.tasks` |
| `/jaan-to:dev-tech-validate` | 3 | Artifact validation | `/speckit.analyze` |
| `/jaan-to:dev-tech-guide` | 3.5 | Implementation guidance | `/speckit.implement` |

## Workflow

```
PRD ──────────────────────────────────────────────────────────────►
        │
        ▼
/dev-tech-plan ─► plan.md, data-model.md, api-contract.md, research.md
        │
        ▼
/dev-tech-tasks ─► tasks.md, tasks.json (with [P] parallel markers)
        │
        ▼
/dev-tech-validate ─► validation-report.md (PRD ↔ Plan ↔ Tasks)
        │
        ▼
/dev-tech-guide ─► implementation-guide.md (with phase gates)
```

---

## Sub-Tasks

### 3.1 `/jaan-to:dev-tech-plan` Skill

**Input:** PRD path or feature description
**Output:** Technical planning outputs

- [ ] Create SKILL.md with two-phase workflow
- [ ] Create template for plan.md (Technical Context, Constitution Check)
- [ ] Create template for data-model.md (entities, relationships, validation)
- [ ] Create template for api-contract.md (endpoints, payloads, errors)
- [ ] Create template for research.md (decisions, rationale, alternatives)
- [ ] Read context/tech.md for language/framework context
- [ ] Support NEEDS CLARIFICATION markers for unknowns
- [ ] Add LEARN.md for skill lessons

### 3.2 `/jaan-to:dev-tech-tasks` Skill

**Input:** plan.md from /dev-tech-plan
**Output:** Parallelizable task breakdown

- [ ] Create SKILL.md with task generation workflow
- [ ] Create tasks-template.md with phase structure:
  - Phase 1: Setup (shared infrastructure)
  - Phase 2: Foundational (blocking prerequisites)
  - Phase 3+: User Stories (can run in parallel)
  - Phase N: Polish & Cross-Cutting
- [ ] Support [P] parallel markers (different files, no dependencies)
- [ ] Support [Story] labels for user story mapping
- [ ] Generate tasks.json for machine consumption
- [ ] Add checkpoints between phases
- [ ] Add LEARN.md for skill lessons

### 3.3 `/jaan-to:dev-tech-validate` Skill

**Input:** PRD + plan.md + tasks.md
**Output:** Validation report

- [ ] Create SKILL.md with validation workflow
- [ ] Check PRD requirements → plan coverage
- [ ] Check plan entities → task implementation
- [ ] Check user stories → task mapping
- [ ] Report gaps with severity (error/warning/info)
- [ ] Suggest fixes for common issues
- [ ] Add LEARN.md for skill lessons

### 3.4 `/jaan-to:dev-tech-guide` Skill

**Input:** tasks.md + constitution
**Output:** Implementation guidance

- [ ] Create SKILL.md with guidance workflow
- [ ] Generate step-by-step implementation order
- [ ] Include phase gates (checkpoints requiring approval)
- [ ] Reference constitution principles for each phase
- [ ] Track complexity with justification table
- [ ] Add LEARN.md for skill lessons

---

## Acceptance Criteria

### /dev-tech-plan
- [ ] Generates plan.md with Technical Context section
- [ ] Generates data-model.md with entity definitions
- [ ] Generates api-contract.md with endpoint specs
- [ ] Marks unknowns as NEEDS CLARIFICATION
- [ ] Reads and applies context/tech.md context
- [ ] Follows two-phase workflow with HARD STOP

### /dev-tech-tasks
- [ ] Breaks plan into discrete tasks with IDs (T001, T002...)
- [ ] Marks parallelizable tasks with [P]
- [ ] Groups tasks by user story with [US1], [US2]...
- [ ] Includes checkpoints between phases
- [ ] Outputs both markdown and JSON formats

### /dev-tech-validate
- [ ] Validates PRD ↔ Plan coverage
- [ ] Validates Plan ↔ Tasks alignment
- [ ] Reports gaps with severity levels
- [ ] Provides actionable fix suggestions

### /dev-tech-guide
- [ ] Provides ordered implementation steps
- [ ] Includes phase gates with approval checkpoints
- [ ] References constitution principles
- [ ] Tracks complexity with justification

---

## Output Artifacts

```
jaan-to/outputs/dev/tech/{slug}/
├── plan.md              # Technical approach (/dev-tech-plan)
├── research.md          # Decisions & rationale (/dev-tech-plan)
├── data-model.md        # Entity definitions (/dev-tech-plan)
├── api-contract.md      # Endpoint specs (/dev-tech-plan)
├── tasks.md             # Task breakdown (/dev-tech-tasks)
├── tasks.json           # Machine-readable tasks (/dev-tech-tasks)
├── validation-report.md # Consistency check (/dev-tech-validate)
└── implementation-guide.md # Step-by-step guidance (/dev-tech-guide)
```

---

## Definition of Done

### Functional
- [ ] All four skills created with SKILL.md
- [ ] All templates created and functional
- [ ] Skills read context context
- [ ] Skills read and apply LEARN.md lessons
- [ ] Two-phase workflow with HARD STOP

### Quality
- [ ] Follows existing skill patterns
- [ ] Output follows jaan.to conventions
- [ ] JSON output validates against schema

### Testing
- [ ] E2E: /dev-tech-plan generates all outputs
- [ ] E2E: /dev-tech-tasks reads plan and generates tasks
- [ ] E2E: /dev-tech-validate catches intentional gaps
- [ ] E2E: Full workflow from PRD to implementation guide

---

## Dependencies

- Phase 2.5 complete (Documentation & Tooling)
- `/jaan-to:pm-prd-write` skill (PRD input)

## References

- [spec-kit](https://github.com/github/spec-kit) - Inspiration
- [vision.md](../vision.md) - Architecture philosophy
