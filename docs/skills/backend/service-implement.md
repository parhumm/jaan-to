---
title: "backend-service-implement"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-11
tags: [dev, backend, service, implement, business-logic, crud, state-machine]
related: [backend-scaffold, backend-api-contract, backend-data-model, backend-task-breakdown]
---

# /backend-service-implement

> Bridge spec to code — generate full service implementations with business logic from TODO stubs and upstream specs.

---

## Overview

Takes scaffold stubs (from `/backend-scaffold`) and upstream specs (API contract, data model, task breakdown) to generate production-ready service implementations with business logic, helpers, error handling, and pagination. Supports Node.js/TypeScript, PHP (Laravel/Symfony), and Go.

---

## Usage

```
/backend-service-implement
/backend-service-implement backend-scaffold backend-api-contract backend-data-model backend-task-breakdown
```

| Argument | Required | Description |
|----------|----------|-------------|
| backend-scaffold | No | Path to scaffold output (route handlers with TODO stubs) |
| backend-api-contract | No | Path to OpenAPI 3.1 YAML |
| backend-data-model | No | Path to data model document |
| backend-task-breakdown | No | Path to BE task breakdown |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/backend/service-implement/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Implementation guide with architecture notes |
| `*-services.ts` | Service layer with full business logic |
| `*-helpers.ts` | Shared helpers (error factory, pagination, auth) |
| `*-routes.ts` | Updated route handlers calling services |
| `*-tests.ts` | Unit test stubs for each service method |
| `*-readme.md` | Setup + run instructions |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Implementation scope | Always | Which services/resources to implement |
| Business logic gaps | Spec ambiguity | Clarify domain rules not in spec |
| Auth pattern | Not in tech.md | JWT / API key / session |
| Error handling depth | Not in tech.md | Basic / full RFC 9457 |

---

## Multi-Stack Support

| Stack | Framework | ORM/DB | Patterns |
|-------|-----------|--------|----------|
| Node.js / TypeScript | Fastify v5+ | Prisma | CRUD + state machines + helpers |
| PHP | Laravel 12 / Symfony 7 | Eloquent / Doctrine | Service classes + Form Requests |
| Go | Chi / stdlib | sqlc / GORM | Handler functions + repository pattern |

---

## Workflow Chain

```
/backend-scaffold --> /backend-service-implement --> /qa-test-generate
```

---

## Example

**Input:**
```
/backend-service-implement path/to/scaffold path/to/api.yaml path/to/data-model.md
```

**Output:**
```
jaan-to/outputs/backend/service-implement/01-user-api/
├── 01-user-api.md
├── 01-user-api-services.ts
├── 01-user-api-helpers.ts
├── 01-user-api-routes.ts
├── 01-user-api-tests.ts
└── 01-user-api-readme.md
```

---

## Tips

- Run `/backend-scaffold` first to generate the stubs this skill fills in
- Provide all 4 upstream artifacts for best results
- Review the implementation guide (.md) for business logic decisions
- Use `/qa-test-generate` to generate tests for the implemented services

---

## Related Skills

- [/backend-scaffold](scaffold.md) - Generate backend code stubs from specs
- [/backend-api-contract](api-contract.md) - Generate OpenAPI contracts
- [/backend-data-model](data-model.md) - Generate data model docs
- [/qa-test-generate](../qa/test-generate.md) - Generate runnable tests

---

## Technical Details

- **Logical Name**: backend-service-implement
- **Command**: `/backend-service-implement`
- **Role**: dev (backend)
- **Output**: `$JAAN_OUTPUTS_DIR/backend/service-implement/{id}-{slug}/`
