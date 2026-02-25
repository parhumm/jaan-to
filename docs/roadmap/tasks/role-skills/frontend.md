---
title: "FRONTEND Skills (3)"
sidebar_position: 4
---

# FRONTEND Skills (3)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4 + Phase 6

**Chains**: Task Breakdown → State Machine + Scaffold

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-dev-tech-plan["dev-tech-plan<br>DEV: tech-plan"] --> frontend-task-breakdown["frontend-task-breakdown<br>FE Task Breakdown<br>FE tasks + estimates + risks"]
    frontend-task-breakdown["frontend-task-breakdown<br>FE Task Breakdown<br>FE tasks + estimates + risks"] --> jaan-to-frontend-scaffold["frontend-scaffold<br>FE Scaffold<br>React/Next.js + TailwindCSS + API client"]
    frontend-task-breakdown["frontend-task-breakdown<br>FE Task Breakdown<br>FE tasks + estimates + risks"] --> jaan-to-frontend-state-machine["frontend-state-machine<br>FE State Machine<br>UI states + transitions"]
    jaan-to-backend-api-contract["backend-api-contract<br>BACKEND: api-contract"] --> jaan-to-frontend-scaffold["frontend-scaffold<br>FE Scaffold<br>React/Next.js + TailwindCSS + API client"]
    ux-microcopy-write["ux-microcopy-write<br>UX: microcopy-write"] -.-> jaan-to-frontend-scaffold["frontend-scaffold<br>FE Scaffold<br>React/Next.js + TailwindCSS + API client"]
    jaan-to-frontend-scaffold["frontend-scaffold<br>FE Scaffold<br>React/Next.js + TailwindCSS + API client"] --> jaan-to-dev-integration-plan["dev-integration-plan<br>DEV: integration-plan"]
    jaan-to-frontend-scaffold["frontend-scaffold<br>FE Scaffold<br>React/Next.js + TailwindCSS + API client"] --> jaan-to-dev-test-plan["dev-test-plan<br>DEV: test-plan"]
    jaan-to-frontend-state-machine["frontend-state-machine<br>FE State Machine<br>UI states + transitions"] --> jaan-to-dev-test-plan["dev-test-plan<br>DEV: test-plan"]

    style jaan-to-dev-tech-plan fill:#f0f0f0,stroke:#999
    style jaan-to-backend-api-contract fill:#f0f0f0,stroke:#999
    style ux-microcopy-write fill:#f0f0f0,stroke:#999
    style jaan-to-dev-integration-plan fill:#f0f0f0,stroke:#999
    style jaan-to-dev-test-plan fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### ✅ /frontend-task-breakdown

- **Logical**: `frontend-task-breakdown`
- **Description**: FE tasks list (components, screens, states), estimate bands, risks + dependencies
- **Reference**: [Frontend Task Breakdown Skill: Complete Framework Research](https://github.com/parhumm/jaan-to/blob/main/jaan-to/outputs/research/51-frontend-task-breakdown.md)
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `frontend-state-machine`
- **MCP Required**: None
- **Input**: [ux-handoff]
- **Output**: `$JAAN_OUTPUTS_DIR/frontend/task-breakdown/{id}-{slug}/`

### /frontend-state-machine

- **Logical**: `frontend-state-machine`
- **Description**: UI states + transitions, events that trigger transitions, edge-case behavior
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `dev-test-plan`
- **MCP Required**: None
- **Input**: [screen]
- **Output**: `$JAAN_OUTPUTS_DIR/frontend/state-machine/{id}-{slug}/`

### /frontend-scaffold

- **Logical**: `frontend-scaffold`
- **Description**: Convert HTML design previews to React v19 / Next.js v15 components with TailwindCSS v4, TypeScript, and state management
- **Quick Win**: Yes
- **Key Points**:
  - Extract semantic HTML structure and preserve accessibility
  - Convert to TailwindCSS v4 utility classes
  - Generate TypeScript interfaces from API contract schemas
  - Create composable component hierarchy with loading/error/empty states
  - Generate typed API client hooks
- **→ Next**: `dev-integration-plan`, `dev-test-plan`
- **MCP Required**: None
- **Input**: [frontend-design, frontend-task-breakdown, api-contract]
- **Output**: `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`
- **Reference**: [`63-dev-scaffolds.md`](https://github.com/parhumm/jaan-to/blob/main/jaan-to/outputs/research/63-dev-scaffolds.md)
- **Plan**: [dev-scaffold-skills.md](../plans/dev-scaffold-skills.md)
