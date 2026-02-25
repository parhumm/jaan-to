---
title: "backend-scaffold"
sidebar_position: 5
doc_type: skill
created_date: 2026-02-09
updated_date: 2026-02-23
tags: [dev, backend, scaffold, routes, services, validation, prisma, fastify]
related: [backend-api-contract, backend-task-breakdown, backend-data-model]
---

# /backend-scaffold

> Generate production-ready backend code with routes, data models, service layers, and validation.

---

## Overview

Generates production-ready backend scaffolds from upstream specs (API contracts, task breakdowns, data models). Supports multiple stacks — Node.js/TypeScript (Fastify + Prisma), PHP (Laravel/Symfony), and Go (Chi/stdlib + sqlc) — auto-detected from `tech.md`.

---

## Usage

```
/backend-scaffold
/backend-scaffold backend-api-contract backend-task-breakdown backend-data-model
```

| Argument | Required | Description |
|----------|----------|-------------|
| backend-api-contract | No | Path to OpenAPI YAML |
| backend-task-breakdown | No | Path to BE task breakdown markdown |
| backend-data-model | No | Path to data model markdown |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/backend/scaffold/{id}-{slug}/` (Node.js/TypeScript example):

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Setup guide + architecture doc |
| `{id}-{slug}-routes.ts` | Route handlers (all resources) |
| `{id}-{slug}-services.ts` | Service layer (business logic) |
| `{id}-{slug}-schemas.ts` | Validation schemas |
| `{id}-{slug}-middleware.ts` | Auth + error handling middleware |
| `{id}-{slug}-prisma.prisma` | ORM data model |
| `{id}-{slug}-config.ts` | Package.json + tsconfig content |
| `{id}-{slug}-readme.md` | Setup + run instructions |

File extensions adapt to detected stack (.ts for Node.js, .php for PHP, .go for Go).

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Project structure | Not in tech.md | Monolith / modular monolith / microservice |
| Auth middleware | Not in tech.md | JWT / API key / session / none |
| Error handling depth | Not in tech.md | Basic / full RFC 9457 with error taxonomy |
| Logging | Not in tech.md | Structured JSON pino / winston / none |

---

## Multi-Stack Support

Reads `$JAAN_CONTEXT_DIR/tech.md` to auto-detect the stack:

| Stack | Framework | ORM/DB | Validation |
|-------|-----------|--------|------------|
| Node.js / TypeScript | Fastify v5+ | Prisma | Zod + type-provider |
| PHP | Laravel 12 / Symfony 7 | Eloquent / Doctrine | Form Requests / Validator |
| Go | Chi / stdlib (Go 1.22+) | sqlc / GORM | go-playground/validator |

---

## Key Patterns (Node.js/TypeScript)

- **Routing**: `@fastify/autoload` v6 for file-based route loading
- **Validation**: `fastify-type-provider-zod` v6.1+ with Zod schemas
- **ORM**: Prisma singleton with `globalThis` pattern
- **Services**: Plain exported functions, module caching as built-in singleton
- **Errors**: RFC 9457 Problem Details with `application/problem+json`
- **Structure**: Collocated routes + schemas + services per resource

---

## Test Framework & Mutation Tool Recommendations

The scaffold guide includes a recommended test framework and mutation testing tool per stack:

| Stack | Test Framework | Mutation Tool | Config File |
|-------|---------------|---------------|-------------|
| Node.js / TypeScript | Vitest | StrykerJS | `stryker.config.mjs` |
| PHP | PHPUnit / Pest | Infection | `infection.json5` |
| Go | `go test` | go-mutesting | `Makefile` target |

When the scaffold detects an existing test framework, it adapts its recommendations accordingly. Mutation testing config stubs are included in the scaffold output when applicable.

---

## Workflow Chain

```
/backend-api-contract → /backend-task-breakdown → /backend-scaffold → /qa-test-cases
```

---

## Example

**Input:**
```
/backend-scaffold path/to/api.yaml path/to/tasks.md path/to/data-model.md
```

**Output:**
```
jaan-to/outputs/backend/scaffold/01-user-api/
├── 01-user-api.md
├── 01-user-api-routes.ts
├── 01-user-api-services.ts
├── 01-user-api-schemas.ts
├── 01-user-api-middleware.ts
├── 01-user-api-prisma.prisma
├── 01-user-api-config.ts
└── 01-user-api-readme.md
```

---

## Tips

- Run `/backend-api-contract` and `/backend-data-model` first for best results
- Set up `$JAAN_CONTEXT_DIR/tech.md` to skip stack detection questions
- Copy scaffold files to your project directory and install dependencies
- Use `/frontend-scaffold` to generate matching frontend code

---

## Related Skills

- [/backend-api-contract](api-contract.md) - Generate OpenAPI contracts
- [/backend-data-model](data-model.md) - Generate data model docs
- [/backend-task-breakdown](task-breakdown.md) - Convert PRDs into backend tasks

---

## Technical Details

- **Logical Name**: backend-scaffold
- **Command**: `/backend-scaffold`
- **Role**: dev (backend)
- **Output**: `$JAAN_OUTPUTS_DIR/backend/scaffold/{id}-{slug}/`
