---
name: backend-data-model
description: Generate data model docs with tables, constraints, indexes, retention, and migration notes from entities.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/data-model/**), Write($JAAN_OUTPUTS_DIR/frontend/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [entities-or-prd-path]
---

# backend-data-model

> Generate production-quality data model documentation from entity descriptions.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL: determines database engine and patterns)
  - Uses sections: `#current-stack`, `#constraints`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:backend-data-model.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:backend-data-model.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Entities**: $ARGUMENTS

Accepts any of:
- **Entity list** — Comma-separated entity names (e.g., "User, Post, Comment")
- **PRD reference** — Path to PRD file with data requirements
- **Existing schema** — Path to DDL/migration file for enhancement
- **Feature description** — Free text describing the feature's data needs

If no input provided, ask: "What entities or features should the data model cover?"

---

## Pre-Execution: Apply Past Lessons
Read and apply: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `backend-data-model`

Also read tech context (CRITICAL for this skill):
- `$JAAN_CONTEXT_DIR/tech.md` - Determines database engine, constraints, common patterns

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_backend-data-model`

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Extracting constraints from natural language (uniqueness, cardinality, CHECK)
- Mapping entity relationships and detecting implicit constraints
- Planning index strategy using ESR ordering
- Assessing migration complexity per table

## Step 1: Parse Input

Analyze the provided input to extract entities:

**If entity list:**
1. Split comma-separated names
2. Infer relationships from naming (e.g., "Comment" implies parent "Post")
3. Note implied attributes (e.g., "User" implies email, name)

**If PRD reference:**
1. Read the PRD file
2. Extract data-relevant user stories and acceptance criteria
3. Identify entities (nouns), relationships (verbs), and constraints
4. Note technical constraints mentioned

**If existing schema:**
1. Read DDL/migration file
2. Extract tables, columns, types, constraints, indexes
3. Map foreign keys to relationships
4. Identify gaps or enhancement opportunities

**If feature description:**
1. Parse for entity nouns and relationship verbs
2. Identify implied constraints and data rules
3. Note any retention or compliance mentions

Build initial understanding:
```
INPUT SUMMARY
─────────────
Type:          {entity-list/prd/schema/description}
Entities:      {list of identified entities}
Relationships: {implied relationships}
Constraints:   {mentioned constraints}
Unknown:       {areas needing clarification}
```

## Step 2: Clarify Data Design

Ask up to 6 smart questions based on what's unclear from Step 1. Skip questions already answered by the input or tech.md.

**Engine question** (ask if not in tech.md):
1. Use AskUserQuestion:
   - Question: "Which database engine(s) should the model target?"
   - Header: "Engine"
   - Options:
     - "PostgreSQL (Recommended)" — Full constraint support, JSONB, RLS, transactional DDL
     - "MySQL" — INSTANT DDL (8.0+), InnoDB clustered index, CHECK (8.0.16+)
     - "SQLite" — Lightweight, limited ALTER TABLE, edge/embedded use cases
     - "Multiple engines" — Generate engine-specific variants

**Migration question** (always ask):
2. Use AskUserQuestion:
   - Question: "Is this a greenfield schema or extending existing tables?"
   - Header: "Migration"
   - Options:
     - "Greenfield (Recommended)" — New schema, CREATE TABLE statements
     - "Brownfield" — Extending existing tables, zero-downtime migration notes
     - "Mixed" — Some new tables, some alterations

**Tenancy question** (ask if not in tech.md constraints):
3. Use AskUserQuestion:
   - Question: "Does this system require multi-tenancy?"
   - Header: "Tenancy"
   - Options:
     - "No multi-tenancy" — Single-tenant application
     - "Shared tables + tenant_id (Recommended)" — Discriminator column with RLS
     - "Schema-per-tenant" — Separate schemas per tenant
     - "Database-per-tenant" — Full isolation, regulated industries

**Delete question** (ask if entities involve user data):
4. Use AskUserQuestion:
   - Question: "What delete strategy for records?"
   - Header: "Deletes"
   - Options:
     - "Soft delete via deleted_at (Recommended)" — Preserves data, supports undelete
     - "Hard delete" — Permanent removal, simpler queries
     - "Archival" — Move to cold storage tables
     - "Mixed per entity" — Different strategy per entity type

**Retention question** (ask if user data or compliance mentioned):
5. Use AskUserQuestion:
   - Question: "Are there data retention or GDPR requirements?"
   - Header: "Retention"
   - Options:
     - "No requirements" — Standard data lifecycle
     - "GDPR compliance needed" — Right-to-deletion, crypto-shredding options
     - "TTL-based cleanup" — Automatic expiration of old records
     - "Custom retention policy" — Per-entity retention rules

**Depth question** (always ask):
6. Use AskUserQuestion:
   - Question: "What level of detail should the output include?"
   - Header: "Depth"
   - Options:
     - "Production (Recommended)" — Full tables, indexes, migrations, retention, quality scorecard
     - "MVP" — Core tables and constraints only, minimal migration notes
     - "Schema only" — Tables and relationships, no migration or retention notes

## Step 3: Entity-Relationship Analysis

For each entity, apply constraint extraction heuristics:

### Constraint Extraction Rules

**Uniqueness detection:**
| NL Pattern | Constraint | Confidence |
|---|---|---|
| "unique email" / "distinct slug" | `UNIQUE(column)` | Explicit |
| "each user has an email" | `UNIQUE(email)` per scope | Implicit |
| "no two orders share the same number" | `UNIQUE(order_number)` | Explicit |
| "one license per driver" | `UNIQUE(driver_id, license_number)` | Composite |

**Critical multi-tenant rule**: When multi-tenancy is enabled, every uniqueness constraint must include `tenant_id` — `UNIQUE(tenant_id, email)`, never `UNIQUE(email)`. This is the most common AI failure in schema generation.

**Relationship mapping:**
| NL Pattern | Cardinality | Implementation |
|---|---|---|
| "belongs to" / "owned by" | N:1 | FK on child table |
| "has many" / "contains" | 1:N | FK on child table |
| "has one" / "has a single" | 1:1 | FK with UNIQUE constraint |
| "can have many...and...can have many" | M:N | Junction table |
| "is a" / "is a type of" | Inheritance | Single-table or table-per-type |

**Ambiguity defaults**: Plural nouns on both sides → M:N. Doubt between 1:N and M:N → default 1:N (simpler, upgradeable). Junction tables when relationship has attributes ("enrolled *with a grade*").

**CHECK constraints from domain language:**
- "must be active/inactive" → `CHECK (status IN ('active','inactive'))`
- "price > 0" → `CHECK (price > 0)`
- "between 0 and 150" → `CHECK (age BETWEEN 0 AND 150)`

**NOT NULL defaults**: Fields default to NOT NULL unless explicitly optional ("optionally", "can have", "if available" → nullable).

### Per-Entity Analysis

For each entity, determine:

| Attribute | Detail |
|---|---|
| **Table name** | Plural snake_case (e.g., `order_items`) |
| **PK** | bigint (GENERATED ALWAYS AS IDENTITY / AUTO_INCREMENT) or uuid |
| **Columns** | Name, type (engine-specific), nullable, default, constraints |
| **Relationships** | Cardinality, FK column, ON DELETE behavior |
| **Indexes** | Apply ESR rule for composites (Equality → Sort → Range) |
| **Constraints** | UNIQUE, CHECK, NOT NULL, FK |

### ESR Composite Index Rule

For composite indexes, always order columns:
1. **Equality** columns first (=, IN)
2. **Sort** columns next (ORDER BY, matching direction)
3. **Range** columns last (>, <, BETWEEN)

Example: `WHERE tenant_id = ? AND status = 'active' AND created_at > ?` → Index: `(tenant_id, status, created_at)`

Present entity map:
```
ENTITY MAP
──────────
Entity: User
  Table:      users
  PK:         id (bigint)
  Columns:    email (varchar, NOT NULL, UNIQUE), name (varchar, NOT NULL), role (varchar, CHECK), bio (text, nullable), created_at, updated_at
  Relations:  1:N → posts, 1:N → comments
  Indexes:    (email) UNIQUE, (created_at)
  Migration:  Greenfield — CREATE TABLE

Entity: Post
  Table:      posts
  PK:         id (bigint)
  Columns:    title (varchar, NOT NULL), body (text, NOT NULL), status (varchar, CHECK: draft/published), user_id (bigint, FK, NOT NULL), created_at, updated_at
  Relations:  N:1 → users, 1:N → comments
  Indexes:    (user_id), (status, created_at) — ESR: equality then range
  Migration:  Greenfield — CREATE TABLE
```

## Step 4: Cross-Cutting Concerns

Plan cross-cutting patterns based on Step 2 decisions:

### Timestamps
All tables include:
- `created_at` — TIMESTAMPTZ (PostgreSQL) / TIMESTAMP (MySQL) / TEXT ISO8601 (SQLite), NOT NULL, DEFAULT now()
- `updated_at` — Same type, NOT NULL, DEFAULT now(), updated by application or trigger

### Soft Deletes (if enabled)
- Add `deleted_at` column (same timestamp type, nullable, DEFAULT NULL)
- Create partial unique indexes: `UNIQUE(email) WHERE deleted_at IS NULL`
- Every query filter must include `WHERE deleted_at IS NULL` (note for application layer)
- Partial index for active records: `CREATE INDEX ON {table}(id) WHERE deleted_at IS NULL`

### Multi-Tenancy (if enabled)
- Add `tenant_id` (uuid/bigint, NOT NULL, FK to tenants.id) to every business table
- ALL unique constraints become composite: `UNIQUE(tenant_id, email)`
- ALL composite indexes start with `tenant_id`: `(tenant_id, status, created_at)`
- FK constraints include tenant_id where possible for cross-tenant protection
- For PostgreSQL: note RLS policy template:
  ```sql
  ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
  CREATE POLICY tenant_isolation ON {table}
      USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
  ```

### Enum Strategy
- Use `CHECK` constraints on `VARCHAR` columns — NOT native ENUM types
- Rationale: Cannot remove ENUM values without aggressive locking; CHECK is operationally flexible
- Pattern: `status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'inactive'))`

### PK Strategy
- PostgreSQL: `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
- MySQL/InnoDB: `id BIGINT AUTO_INCREMENT PRIMARY KEY` (short PKs critical — PKs stored in every secondary index)
- SQLite: `id INTEGER PRIMARY KEY` (implicit rowid)
- If public-facing IDs needed: separate `uuid` column with unique index

### Naming Conventions
- Tables: plural snake_case (`users`, `order_items`)
- Columns: singular snake_case (`user_id`, `created_at`)
- Constraints: `pk_{table}`, `fk_{table}_{column}_{ref_table}`, `check_{table}_{column}_{type}`, `idx_{table}_on_{columns}`

---

# HARD STOP — Review Data Model Plan

Present the complete analysis summary:

```
DATA MODEL PLAN
═══════════════

SUMMARY
───────
Engine:        {from tech.md or Step 2}
Migration:     {Greenfield/Brownfield/Mixed}
Tenancy:       {None/Shared+tenant_id/Schema-per-tenant/DB-per-tenant}
Deletes:       {Soft/Hard/Archival/Mixed}
Retention:     {None/GDPR/TTL/Custom}
Depth:         {Production/MVP/Schema}

ENTITIES ({count})
──────────────────
| Entity | Table | Columns | Relationships | Indexes | Constraints |
|--------|-------|---------|---------------|---------|-------------|
| User | users | 6 | 1:N posts, 1:N comments | 3 | 2 UNIQUE, 1 CHECK |
| Post | posts | 7 | N:1 users, 1:N comments | 3 | 1 CHECK |
| ... | ... | ... | ... | ... | ... |

CROSS-CUTTING
─────────────
Timestamps:    created_at + updated_at on all tables
Soft Deletes:  {enabled/disabled} {+ partial unique indexes if enabled}
Multi-Tenancy: {strategy + tenant_id placement}
Enum Strategy: CHECK on VARCHAR (no native ENUM)
PK Strategy:   {bigint/uuid}
Naming:        plural snake_case tables, GitLab-style constraint naming

OUTPUT
──────
Folder: $JAAN_OUTPUTS_DIR/backend/data-model/{id}-{slug}/
File:   {id}-{slug}.md
```

Use AskUserQuestion:
- Question: "Proceed with generating the data model document?"
- Header: "Generate"
- Options:
  - "Yes" — Generate the data model
  - "No" — Cancel
  - "Edit" — Let me revise the scope or design first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 5: Generate Data Model Document

Read template: `$JAAN_TEMPLATES_DIR/jaan-to:backend-data-model.template.md`

If tech stack needed, extract sections from tech.md:
- Current Stack: `#current-stack`
- Constraints: `#constraints`
- Patterns: `#patterns`

Generate the document in this order:

### 5.1: Executive Summary
1-2 sentences describing: entity count, database engine, key design decisions (tenancy, delete strategy), and migration approach.

### 5.2: Entity-Relationship Diagram
Generate Mermaid `erDiagram` with all entities, relationships, and cardinality.

### 5.3: Table Definitions
For each entity, generate:

**Column table:**
| Column | Type | Nullable | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | BIGINT GENERATED ALWAYS AS IDENTITY | NO | — | PRIMARY KEY |
| email | VARCHAR(255) | NO | — | UNIQUE, NOT NULL |
| status | VARCHAR(20) | NO | 'pending' | CHECK (status IN (...)) |
| user_id | BIGINT | NO | — | FK → users.id ON DELETE CASCADE |
| created_at | TIMESTAMPTZ | NO | now() | — |
| updated_at | TIMESTAMPTZ | NO | now() | — |

**Engine-specific type rules:**
- PostgreSQL: `BIGINT GENERATED ALWAYS AS IDENTITY`, `TIMESTAMPTZ`, `JSONB`, `BOOLEAN`
- MySQL: `BIGINT AUTO_INCREMENT`, `TIMESTAMP`/`DATETIME`, `JSON`, `TINYINT(1)`
- SQLite: `INTEGER PRIMARY KEY`, `TEXT` (ISO8601), `TEXT` (JSON), `INTEGER` (0/1)

**Indexes table:**
| Name | Columns | Type | Rationale |
|------|---------|------|-----------|
| idx_posts_on_user_id | (user_id) | B-tree | FK lookup performance |
| idx_posts_on_status_created | (status, created_at) | B-tree | ESR: equality then range |

**Foreign Keys table:**
| Column | References | ON DELETE | ON UPDATE |
|--------|-----------|-----------|-----------|
| user_id | users.id | CASCADE | CASCADE |

**Migration Notes** (per table):
- Greenfield: `CREATE TABLE` statement
- Brownfield: Zero-downtime steps using engine-appropriate patterns:
  - PostgreSQL: `CREATE INDEX CONCURRENTLY`, `NOT VALID` + `VALIDATE CONSTRAINT`, `SET lock_timeout`
  - MySQL: Check INSTANT/INPLACE/COPY algorithm; use pt-osc or gh-ost for COPY operations
  - Expand-contract pattern for column renames, type changes, structural refactoring

### 5.4: Cross-Cutting Concerns
Document the patterns chosen in Step 4 with concrete implementation details.

### 5.5: Index Strategy
For each composite index, show ESR rationale. Include:
- Engine-specific index types (GIN for JSONB, BRIN for time-series, partial indexes)
- Multi-tenant indexes: tenant_id always first
- Soft delete partial indexes: `WHERE deleted_at IS NULL`
- Covering indexes for high-frequency queries: `INCLUDE` clause

### 5.6: Migration Playbook
Per-table migration classification:
| Table | Operation | Safety | Method | Notes |
|-------|-----------|--------|--------|-------|
| users | CREATE TABLE | Safe | Instant | New table, no locks |
| orders | ADD COLUMN amount | Safe | Instant | PG 11+ constant default |
| users | ADD NOT NULL | Caution | NOT VALID + VALIDATE | Two-step: add CHECK NOT VALID, then VALIDATE |
| orders | RENAME status | Breaking | Expand-Contract | Three-phase: add new, dual-write, drop old |

### 5.7: Retention & Compliance
If GDPR: document deletion strategy (hard delete + anonymized audit, crypto-shredding, or separate PII tables).
If TTL: document cleanup approach (pg_cron + batched DELETE, partition-based retention, MongoDB TTL indexes, DynamoDB TTL).
If legal holds: note legal_holds table pattern.

### 5.8: Quality Scorecard
Apply 5-dimension scoring rubric:

| Dimension | Weight | Checks |
|-----------|--------|--------|
| Referential Integrity | 25% | FKs defined; ON DELETE specified; FK indexes present |
| Constraint Completeness | 25% | CHECK for enums/ranges; NOT NULL where appropriate; UNIQUE for business rules |
| Index Coverage | 20% | FK columns indexed; query patterns covered; composite ordering correct (ESR) |
| Convention Consistency | 15% | snake_case naming; plural tables; consistent constraint naming |
| Operational Readiness | 15% | Timestamps present; soft-delete support; migration notes included |

Score each dimension and compute weighted overall score.

## Step 6: Quality Check

Before preview, verify every item:

**Structure:**
- [ ] Every table has PK (bigint or uuid per strategy)
- [ ] Every table has `created_at` and `updated_at` timestamps
- [ ] Naming: plural snake_case tables, singular snake_case columns

**Constraints:**
- [ ] All FKs specify ON DELETE behavior (CASCADE/RESTRICT/SET NULL)
- [ ] No bare VARCHAR without length constraint
- [ ] No native ENUM types — all use CHECK on VARCHAR
- [ ] Booleans have DEFAULT values
- [ ] Multi-tenant: all unique constraints include tenant_id

**Indexes:**
- [ ] All FK columns have matching indexes (PostgreSQL doesn't auto-create)
- [ ] Composite indexes follow ESR rule (Equality → Sort → Range)
- [ ] Soft delete tables have partial index `WHERE deleted_at IS NULL`

**Anti-patterns:**
- [ ] No polymorphic type+id columns (use separate tables per GitLab pattern)
- [ ] No god tables (50+ columns → decompose)
- [ ] No orphan tables (tables with no FK relationships)

**Completeness:**
- [ ] Executive Summary present
- [ ] Mermaid ER diagram present and matches table definitions
- [ ] Migration notes included for all tables
- [ ] Quality scorecard computed

If any check fails, fix before preview.

## Step 7: Preview & Approval

Show the complete data model document.

Use AskUserQuestion:
- Question: "Write the data model document to output?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "No" — Cancel
  - "Edit" — Let me revise something first

## Step 7.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/backend/data-model"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths (slug from entity/feature name)
slug="{lowercase-hyphenated-name-max-50-chars}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/backend/data-model/{NEXT_ID}-{slug}/`
> - Main: `{NEXT_ID}-{slug}.md`

## Step 8: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write data model document to main file.

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Data Model Title}" \
  "{1-2 sentence executive summary}"
```

4. Confirm completion:
> ✓ Data model written to: `$JAAN_OUTPUTS_DIR/backend/data-model/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> ✓ Index updated: `$JAAN_OUTPUTS_DIR/backend/data-model/README.md`

## Step 9: Suggest Next Steps

> "Data model generated. Suggested next steps:"
>
> 1. **API contract**: Generate OpenAPI spec from this data model:
>    ```
>    /jaan-to:backend-api-contract "{entity-list}"
>    ```
> 2. **Task breakdown**: Generate backend tasks from this data model:
>    ```
>    /jaan-to:backend-task-breakdown "{prd-or-feature}"
>    ```
> 3. **Review**: Have the team review constraint completeness and index strategy

## Step 10: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the generated data model?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update something in the data model
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update the output file, re-preview, re-write
- **Learn**: Run `/jaan-to:learn-add backend-data-model "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] Input parsed, entities identified and confirmed
- [ ] Data design decisions confirmed (engine, migration, tenancy, deletes, retention, depth)
- [ ] Entity relationships mapped with columns, constraints, indexes
- [ ] Cross-cutting concerns documented (timestamps, soft deletes, tenancy, audit, enums)
- [ ] Data model document generated with Mermaid ER diagram
- [ ] Migration notes included per table (zero-downtime for brownfield)
- [ ] Quality checks passed (anti-patterns + 5-dimension rubric)
- [ ] Output written to `$JAAN_OUTPUTS_DIR/backend/data-model/{id}-{slug}/`
- [ ] Subdomain index updated
- [ ] User approved final result
