---
title: "backend-data-model"
sidebar_position: 3
doc_type: skill
created_date: 2026-02-08
updated_date: 2026-02-08
tags: [dev, backend, data-model, database, schema, constraints, indexes, migrations]
related: [be-task-breakdown, api-contract]
---

# /jaan-to:backend-data-model

> Generate data model documentation with tables, constraints, indexes, retention, and migration notes from entity descriptions.

---

## Overview

Analyzes entity descriptions and produces a comprehensive data model document with Mermaid ER diagrams, engine-specific table definitions, ESR-ordered composite indexes, zero-downtime migration playbooks, and a 5-dimension quality scorecard. Supports PostgreSQL, MySQL, and SQLite with engine-specific syntax.

---

## Usage

```
/jaan-to:backend-data-model "User, Post, Comment"
/jaan-to:backend-data-model "See PRD at jaan-to/outputs/pm/prd/01-user-auth/01-prd-user-auth.md"
/jaan-to:backend-data-model "path/to/schema.sql"
```

| Argument | Required | Description |
|----------|----------|-------------|
| entities-or-prd-path | Yes | Comma-separated entity names, PRD path, existing DDL/migration file, or feature description |

---

## What It Asks

| Question | Why |
|----------|-----|
| Database engine | Determines type syntax, index types, and migration patterns |
| Greenfield vs brownfield | Controls whether output includes CREATE TABLE or zero-downtime ALTER steps |
| Multi-tenancy | Adds tenant_id to all tables, composite unique constraints, RLS policy templates |
| Delete strategy | Configures soft delete columns, partial indexes, or archival tables |
| Retention / GDPR | Adds GDPR deletion strategy, TTL cleanup, or custom retention rules |
| Output depth | Production (full), MVP (core only), or Schema only (no migration notes) |

Questions are skipped when already answered by input or `$JAAN_CONTEXT_DIR/tech.md`.

---

## What It Produces

One file at `$JAAN_OUTPUTS_DIR/backend/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-data-model-{slug}.md` | Full data model document with ER diagram, table definitions, indexes, migrations, retention, and quality scorecard |

### Document Sections

| Section | Details |
|---------|---------|
| Executive Summary | Entity count, engine, key design decisions |
| ER Diagram | Mermaid `erDiagram` with all relationships |
| Table Definitions | Per-entity columns, types, constraints, indexes, FK behavior, migration notes |
| Cross-Cutting Concerns | Timestamps, soft deletes, multi-tenancy, enum strategy, PK strategy |
| Index Strategy | Composite indexes with ESR rationale, partial indexes, engine-specific types |
| Migration Playbook | Per-table safety classification (instant / NOT VALID+VALIDATE / expand-contract) |
| Retention & Compliance | GDPR deletion, TTL cleanup, legal holds |
| Quality Scorecard | 5-dimension weighted scoring rubric |

---

## Design Patterns

Based on research from `60-backend-data-model.md` (420 lines, 10 major areas):

- **CHECK constraints on VARCHAR** instead of native ENUM types — strongest consensus from production schemas (GitLab, Discourse, Mastodon)
- **ESR composite index ordering** — Equality columns first, Sort next, Range last
- **NOT NULL by default** — fields nullable only when explicitly optional
- **Multi-tenant rule** — every unique constraint includes `tenant_id` when tenancy enabled
- **Plural snake_case tables**, singular snake_case columns, GitLab-style constraint naming
- **No polymorphic type+id columns** — use separate tables per GitLab pattern

---

## Tech Stack Integration

Reads `$JAAN_CONTEXT_DIR/tech.md` to adapt the data model:
- **Database engine** from `#current-stack` — determines type syntax and migration patterns
- **Constraints** from `#constraints` — informs multi-tenancy, compliance, and performance targets
- **Patterns** from `#patterns` — applies auth, error handling, and data access patterns

---

## Workflow Chain

This skill fits in the dev workflow:

```
/jaan-to:backend-task-breakdown → /jaan-to:backend-data-model → /jaan-to:backend-api-contract
```

After generating the data model, the skill suggests:
- API contract generation with `/jaan-to:backend-api-contract`
- Backend task breakdown with `/jaan-to:backend-task-breakdown`

---

## Quality Scorecard

Every output includes a weighted quality score:

| Dimension | Weight |
|-----------|--------|
| Referential Integrity | 25% |
| Constraint Completeness | 25% |
| Index Coverage | 20% |
| Convention Consistency | 15% |
| Operational Readiness | 15% |

---

## Research Source

Based on comprehensive research at `jaan-to/outputs/research/60-backend-data-model.md` covering NLP constraint extraction, zero-downtime migrations (PostgreSQL, MySQL, expand-contract), ESR indexing rules, multi-tenant isolation patterns, schema evolution, GDPR/retention strategies, engine syntax comparison tables, and production schema analysis (Discourse, Mastodon, Ghost, Cal.com, GitLab, Supabase).

---

[Back to Dev Skills](README.md) | [Back to All Skills](../README.md)
