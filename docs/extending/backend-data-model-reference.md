# backend-data-model — Reference Material

> Extracted from `skills/backend-data-model/SKILL.md` for token optimization.
> Contains data type mappings, constraint patterns, and migration templates.

---

## Constraint Extraction Patterns

### Uniqueness Detection

| NL Pattern | Constraint | Confidence |
|---|---|---|
| "unique email" / "distinct slug" | `UNIQUE(column)` | Explicit |
| "each user has an email" | `UNIQUE(email)` per scope | Implicit |
| "no two orders share the same number" | `UNIQUE(order_number)` | Explicit |
| "one license per driver" | `UNIQUE(driver_id, license_number)` | Composite |

### Relationship Mapping

| NL Pattern | Cardinality | Implementation |
|---|---|---|
| "belongs to" / "owned by" | N:1 | FK on child table |
| "has many" / "contains" | 1:N | FK on child table |
| "has one" / "has a single" | 1:1 | FK with UNIQUE constraint |
| "can have many...and...can have many" | M:N | Junction table |
| "is a" / "is a type of" | Inheritance | Single-table or table-per-type |

**Ambiguity defaults**: Plural nouns on both sides → M:N. Doubt between 1:N and M:N → default 1:N (simpler, upgradeable). Junction tables when relationship has attributes ("enrolled *with a grade*").

### CHECK Constraints from Domain Language

- "must be active/inactive" → `CHECK (status IN ('active','inactive'))`
- "price > 0" → `CHECK (price > 0)`
- "between 0 and 150" → `CHECK (age BETWEEN 0 AND 150)`

**NOT NULL defaults**: Fields default to NOT NULL unless explicitly optional ("optionally", "can have", "if available" → nullable).

---

## Cross-Cutting Concern Patterns

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

## Engine-Specific Type Rules

| Feature | PostgreSQL | MySQL | SQLite |
|---------|-----------|-------|--------|
| PK / Identity | `BIGINT GENERATED ALWAYS AS IDENTITY` | `BIGINT AUTO_INCREMENT` | `INTEGER PRIMARY KEY` |
| Timestamp | `TIMESTAMPTZ` | `TIMESTAMP`/`DATETIME` | `TEXT` (ISO8601) |
| JSON | `JSONB` | `JSON` | `TEXT` (JSON) |
| Boolean | `BOOLEAN` | `TINYINT(1)` | `INTEGER` (0/1) |

---

## Index Strategy Patterns

Engine-specific index types and patterns:
- **GIN indexes**: For JSONB columns (PostgreSQL)
- **BRIN indexes**: For time-series / append-only data (PostgreSQL)
- **Partial indexes**: `WHERE deleted_at IS NULL` for soft-delete tables
- **Multi-tenant indexes**: `tenant_id` always as the first column
- **Covering indexes**: Use `INCLUDE` clause for high-frequency queries to avoid heap lookups

---

## Migration Safety Classification

| Operation | Safety | Method | Notes |
|-----------|--------|--------|-------|
| CREATE TABLE | Safe | Instant | New table, no locks |
| ADD COLUMN (nullable) | Safe | Instant | PG 11+ constant default |
| ADD NOT NULL constraint | Caution | NOT VALID + VALIDATE | Two-step: add CHECK NOT VALID, then VALIDATE |
| RENAME column | Breaking | Expand-Contract | Three-phase: add new, dual-write, drop old |
| ADD INDEX | Caution | CONCURRENTLY | `CREATE INDEX CONCURRENTLY` (PG), online DDL (MySQL) |

### Brownfield Zero-Downtime Patterns
- **PostgreSQL**: `CREATE INDEX CONCURRENTLY`, `NOT VALID` + `VALIDATE CONSTRAINT`, `SET lock_timeout`
- **MySQL**: Check INSTANT/INPLACE/COPY algorithm; use pt-osc or gh-ost for COPY operations
- **Expand-contract pattern**: For column renames, type changes, structural refactoring

---

## Quality Scorecard Rubric

| Dimension | Weight | Checks |
|-----------|--------|--------|
| Referential Integrity | 25% | FKs defined; ON DELETE specified; FK indexes present |
| Constraint Completeness | 25% | CHECK for enums/ranges; NOT NULL where appropriate; UNIQUE for business rules |
| Index Coverage | 20% | FK columns indexed; query patterns covered; composite ordering correct (ESR) |
| Convention Consistency | 15% | snake_case naming; plural tables; consistent constraint naming |
| Operational Readiness | 15% | Timestamps present; soft-delete support; migration notes included |

Score each dimension and compute weighted overall score.

---

## Quality Check Checklist

### Structure
- [ ] Every table has PK (bigint or uuid per strategy)
- [ ] Every table has `created_at` and `updated_at` timestamps
- [ ] Naming: plural snake_case tables, singular snake_case columns

### Constraints
- [ ] All FKs specify ON DELETE behavior (CASCADE/RESTRICT/SET NULL)
- [ ] No bare VARCHAR without length constraint
- [ ] No native ENUM types — all use CHECK on VARCHAR
- [ ] Booleans have DEFAULT values
- [ ] Multi-tenant: all unique constraints include tenant_id

### Indexes
- [ ] All FK columns have matching indexes (PostgreSQL doesn't auto-create)
- [ ] Composite indexes follow ESR rule (Equality → Sort → Range)
- [ ] Soft delete tables have partial index `WHERE deleted_at IS NULL`

### Anti-patterns
- [ ] No polymorphic type+id columns (use separate tables per GitLab pattern)
- [ ] No god tables (50+ columns → decompose)
- [ ] No orphan tables (tables with no FK relationships)

### Completeness
- [ ] Executive Summary present
- [ ] Mermaid ER diagram present and matches table definitions
- [ ] Migration notes included for all tables
- [ ] Quality scorecard computed
