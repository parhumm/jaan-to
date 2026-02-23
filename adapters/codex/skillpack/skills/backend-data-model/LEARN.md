# Lessons: backend-data-model

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-backend-data-model.learn.md`

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before executing to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during information gathering:

- Ask about enum strategy early — native ENUM vs CHECK constraint affects all status/type columns across the schema
- Clarify if polyglot persistence (multiple engines) — syntax differs dramatically between PostgreSQL, MySQL, SQLite
- Ask about event sourcing/CQRS patterns — changes whether to generate outbox tables and event store schema
- When M:N relationship detected, ask if the relationship itself has attributes (junction table needs own PK + timestamps)
- Ask about expected scale early — affects PK strategy (bigint vs uuid), partitioning decisions, and index types (B-tree vs BRIN)

## Edge Cases

Special cases to check and handle:

- Polymorphic associations: avoid type+id columns — use separate join tables per entity type (GitLab pattern bans polymorphic FKs)
- Self-referential FKs: tree structures need careful index planning (parent_id with closure table or materialized path)
- M:N with payload: junction table needs its own PK, timestamps, and possibly soft delete (not just two FK columns)
- Multi-tenant unique constraints: `UNIQUE(email)` must become `UNIQUE(tenant_id, email)` — single most common AI failure
- MySQL CHECK constraints silently ignored before 8.0.16 — generated code appears valid but doesn't enforce
- SQLite foreign keys OFF by default — must emit `PRAGMA foreign_keys = ON` per connection
- SQLite type affinity: `VARCHAR(255)` accepted but no length enforcement unless STRICT mode (3.37+)

## Workflow

Process improvements:

- Generate Mermaid ER diagram BEFORE table details — visual-first catches relationship errors early in review
- Validate naming conventions before constraint analysis — prevents rework on constraint names
- For brownfield: check existing schema first to detect naming conflicts and FK chains
- Source `scripts/lib/id-generator.sh` and `scripts/lib/index-updater.sh` for output structure

## Common Mistakes

Things to avoid:

- Using PostgreSQL native ENUM types for evolving values — cannot remove values; prefer CHECK on VARCHAR
- Missing partial indexes on soft-deleted tables — always add `WHERE deleted_at IS NULL`
- Forgetting tenant_id in unique constraints for multi-tenant schemas — the #1 data isolation failure
- Missing FK indexes on PostgreSQL — not auto-created unlike MySQL InnoDB
- Omitting ON DELETE behavior on foreign keys — every FK must specify CASCADE, RESTRICT, or SET NULL
- Boolean columns without DEFAULT values — always set DEFAULT true/false
- PostgreSQL SERIAL keyword — legacy; use GENERATED ALWAYS AS IDENTITY instead
- Hardcoding `jaan-to/` paths — always use `$JAAN_*` environment variables
