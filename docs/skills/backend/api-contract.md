---
title: "backend-api-contract"
sidebar_position: 2
doc_type: skill
created_date: 2026-02-08
updated_date: 2026-02-23
tags: [dev, api, openapi, contract, rest, schema, backend]
related: [be-task-breakdown, fe-task-breakdown]
---

# /backend-api-contract

> Generate OpenAPI 3.1 contracts from API resource entities.

---

## Overview

Analyzes API resource entities and produces a validated OpenAPI 3.1 specification (`api.yaml`) with flat component schemas, RFC 9457 error responses, cursor-based pagination, named examples, and a companion markdown quick-start guide.

---

## Usage

```
/backend-api-contract "User, Post, Comment"
/backend-api-contract "See PRD at jaan-to/outputs/pm/prd/01-user-auth/01-prd-user-auth.md"
/backend-api-contract "path/to/schema.sql"
```

| Argument | Required | Description |
|----------|----------|-------------|
| entities-or-prd-path | Yes | Comma-separated entity names, PRD path, database schema path, or existing OpenAPI spec path |

---

## What It Asks

| Question | Why |
|----------|-----|
| Resources scope | Which entities to include in the contract |
| Versioning strategy | URL path `/v1/`, header, or no versioning |
| Authentication | OAuth2, API Key, JWT Bearer, or none |
| Depth | MVP (CRUD only), Production (full), or Framework (schemas only) |
| Pagination | Cursor-based, offset-based, or none |
| Consumers | Internal frontends, third-party devs, both, or M2M |

Questions are skipped when already answered by input or `$JAAN_CONTEXT_DIR/tech.md`.

---

## What It Produces

Two files at `$JAAN_OUTPUTS_DIR/backend/api-contract/{id}-{slug}/`:

| File | Content |
|------|---------|
| `api.yaml` | OpenAPI 3.1 specification with all components and paths |
| `{id}-{slug}.md` | Quick-start guide with auth, examples, error handling, and tooling commands |

### OpenAPI Spec Includes

| Section | Details |
|---------|---------|
| Schemas | Flat `components/schemas` with `$ref` — base (Timestamps, ProblemDetails, PaginationMeta) + per-resource (Create, Update, Response, List) |
| Errors | RFC 9457 Problem Details with `ValidationProblemDetails` extension for field-level errors |
| Pagination | Cursor-based with `has_more` + opaque cursor (or offset-based if selected) |
| Examples | Named media type examples per operation organized by scenario |
| Security | Configured security scheme applied globally |

---

## Design Patterns

Based on research from `59-backend-api-contract.md` (40+ sources):

- **OpenAPI 3.1** with full JSON Schema 2020-12 alignment
- **Flat component architecture** — never deep inline, always `$ref`
- **RFC 9457** error format with `application/problem+json`
- **Null handling** — `type: ["string", "null"]` (never `nullable: true`)
- **Components-first generation** — schemas before paths to minimize broken `$ref`
- **GitHub REST API** as 3.1 gold standard reference

---

## Tech Stack Integration

Reads `$JAAN_CONTEXT_DIR/tech.md` to adapt the contract:
- **Versioning** from `#versioning` — applies URL path, header, or date-based strategy
- **Auth patterns** from `#patterns` — configures security schemes
- **Frameworks** from `#frameworks` — adds `x-framework` extension
- **Constraints** from `#constraints` — informs validation rules

---

## Workflow Chain

This skill fits in the dev workflow:

```
/backend-task-breakdown → /backend-api-contract → /dev-api-versioning
```

After generating the contract, the skill suggests:
- Mock server with Prism
- Client SDK generation with Orval
- Contract testing with Schemathesis
- Versioning plan with `/dev-api-versioning`

---

## Spectral Config Companion

When generating a contract, the skill also produces a `.spectral.yaml` companion file configured with recommended rulesets for the generated spec. This ensures consistent linting from day one.

### Validation Commands

After generating the contract, use these commands to validate:

| Command | Purpose |
|---------|---------|
| `spectral lint api.yaml` | Lint the spec against style rules |
| `prism mock api.yaml` | Start a mock server from the contract |
| `oasdiff breaking base.yaml api.yaml` | Detect breaking changes against a baseline |
| `schemathesis run --url http://localhost:4010 api.yaml` | Fuzz-test endpoints against the contract |

---

## Research Source

Based on comprehensive research at `jaan-to/outputs/research/59-backend-api-contract.md` covering schema design, RFC 9457 errors, example generation, versioning, AI generation guardrails, hybrid authoring, reference specs (GitHub, Stripe, Zalando), and the validation tooling stack (Spectral, Redocly, Prism, Schemathesis).

---

[Back to Dev Skills](docs/skills/backend/README.md) | [Back to All Skills](../README.md)
