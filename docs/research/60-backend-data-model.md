# Building an AI data modeling skill: a practitioner's research compendium

**The core challenge in building `backend-data-model` is bridging the gap between fuzzy natural language ("users have unique emails") and production-ready DDL with correct constraints, indexes, and migration safety across engines.** This report distills research across PostgreSQL, MySQL, MongoDB, DynamoDB, and edge SQLite into actionable rules, decision algorithms, and syntax references an AI tool can execute directly. Every section targets a specific implementation concern — from NLP constraint extraction heuristics to zero-downtime migration matrices — and provides concrete code, comparison tables, and decision trees rather than abstract guidance.

---

## 1. Extracting database constraints from natural language

This is the highest-value and hardest problem the skill must solve. Requirements documents say "unique email" but never say "composite unique index on (tenant_id, email)." Research reveals a taxonomy of linguistic patterns that map reliably to constraint types, plus well-documented LLM failure modes.

### Uniqueness detection heuristics

Language patterns map to uniqueness constraints with varying confidence:

| NL pattern | Constraint | Confidence |
|---|---|---|
| "unique email" / "distinct slug" | `UNIQUE(column)` | Explicit |
| "each user has an email" | `UNIQUE(email)` per user scope | Implicit |
| "no two orders share the same number" | `UNIQUE(order_number)` | Explicit |
| "one license per driver" | `UNIQUE(driver_id, license_number)` | Composite implicit |
| "identified by SSN" | `UNIQUE(ssn)` or PK | Explicit |

**The critical multi-tenant rule**: When the context mentions "tenant," "organization," "workspace," or "account" as a scoping entity, every uniqueness constraint must be composite — `UNIQUE(tenant_id, email)`, never `UNIQUE(email)`. This is the single most common AI failure in schema generation. The heuristic: if an entity belongs to a parent scope, all uniqueness constraints include the parent's FK.

### Relationship language → cardinality mapping

| NL pattern | Cardinality | Implementation |
|---|---|---|
| "belongs to" / "owned by" | N:1 | FK on child table |
| "has many" / "contains" | 1:N | FK on child table |
| "has one" / "has a single" | 1:1 | FK with UNIQUE constraint |
| "can have many…and…can have many" | M:N | Junction table |
| "is a" / "is a type of" | Inheritance | Single-table or table-per-type |

**Ambiguity resolution defaults**: When plural nouns appear on both sides ("students take courses"), default to M:N. When in doubt between 1:N and M:N, default to **1:N** (simpler, upgradeable). When in doubt between 1:1 and embedded, default to embedded (fewer joins). Create junction tables when the relationship itself has attributes ("enrolled *with a grade*") or when both entities have independent lifecycles.

### CHECK constraints from domain language

Pattern matching for domain rules is highly reliable: "must be active/inactive" → `CHECK (status IN ('active','inactive'))`; "price > 0" → `CHECK (price > 0)`; "between 0 and 150" → `CHECK (age BETWEEN 0 AND 150)`. The heuristic for DB-level vs. application-level validation: push simple enumerations, range checks, NOT NULL, and uniqueness to the database (cheap, last line of defense). Leave complex format validation (email regex, URL), cross-entity business logic, and temporal rules to the application.

### NOT NULL defaults

**Fields should default to NOT NULL unless explicitly marked optional.** Language like "every user must have" or "required" confirms NOT NULL. Words like "optionally," "can have," or "if available" signal nullable. This conservative default follows the principle that data integrity is harder to add retroactively than to relax.

### NLP/ML research landscape

The foundational work traces to **Chen (1983)** mapping English sentence structures to ER concepts. The **ER-Converter tool** (Omar et al., 2004) achieved **95% recall and 82% precision** using heuristic rules: nouns → entities, verbs → relationships, adjectives → attributes, possessives → ownership. Modern approaches include **SchemaAgent (2025)**, a multi-agent LLM framework using 6 specialized agents (analyst, designer, reviewer, tester) that achieved **91.3% accuracy** on schema element identification with GPT-4. The **NL2ERM dataset** (2023) provides 500+ requirement-schema pairs for training. Key finding: a dedicated Reviewer agent reduces error accumulation significantly — single-shot LLM approaches are insufficient for complex schemas.

### LLM failure modes and mitigations

Research across practitioner blogs, academic papers, and production systems reveals **13 systematic failure modes**:

- **Wrong cardinality** (defaulting 1:1 when 1:N needed) — mitigate with post-generation cardinality validation and multi-agent review
- **Missing indexes on FK columns** — auto-add indexes on all FK columns as a post-processing step
- **Ignoring multi-tenancy** (`UNIQUE(email)` instead of `UNIQUE(tenant_id, email)`) — scan all unique constraints for missing tenant scope
- **Over-normalization** (separate table for every 1:1 attribute) — embed when cardinality is truly 1:1 and entity has no independent lifecycle
- **Hallucinated syntax** (JSONB in MySQL, non-existent constraint types) — validate with **sqlglot** library for dialect-aware AST parsing
- **Missing timestamps** (no `created_at`/`updated_at`) — enforce via template
- **Missing default values** (booleans without `DEFAULT`, status fields without initial value) — post-generation scan
- **Non-deterministic outputs** — use `temperature=0`, structured output schemas, pin to specific model versions
- **Missing `ON DELETE` behavior** on foreign keys — require explicit cascade specification

**Tiger Data** found that **42% of context-less LLM-generated SQL queries missed critical filters or misunderstood relationships**. The mitigation: always provide engine target, multi-tenant context, expected scale, and query patterns in the prompt.

---

## 2. Zero-downtime migrations across every major engine

This is the #1 production concern. A migration that locks a table for 30 seconds can cause cascading timeouts across an entire application. Each engine has dramatically different capabilities.

### PostgreSQL: the gold standard for safe DDL

PostgreSQL's **transactional DDL** means schema changes roll back on failure — a massive safety advantage. Key patterns:

**`CREATE INDEX CONCURRENTLY`** uses a weaker `ShareUpdateExclusiveLock` that allows concurrent reads and writes. Critical constraints: cannot run inside a transaction block; requires two table scans; leaves an **invalid index** on failure that must be manually dropped. Monitor via `pg_stat_progress_create_index`.

**Adding columns with defaults is instant since PG 11**. PostgreSQL stores the default in `pg_attribute` and returns it dynamically for existing rows — no table scan, no rewrite, ~5ms even on billions of rows. This only works for non-volatile (constant) defaults; `clock_timestamp()` still triggers a rewrite.

**Adding NOT NULL safely** requires a three-step pattern because `ALTER TABLE SET NOT NULL` performs a full table scan with `ACCESS EXCLUSIVE` lock:

```sql
-- Step 1: Add CHECK constraint as NOT VALID (instant, no scan)
ALTER TABLE users ADD CONSTRAINT users_status_nn CHECK (status IS NOT NULL) NOT VALID;
-- Step 2: Validate existing data (ShareUpdateExclusiveLock, allows concurrent DML)
ALTER TABLE users VALIDATE CONSTRAINT users_status_nn;
```

**The NOT VALID + VALIDATE pattern** works for CHECK constraints and foreign keys. Phase 1 adds the constraint instantly (new data validated immediately); Phase 2 validates existing data with a weaker lock that allows concurrent operations.

**Always set `lock_timeout`** (e.g., `SET lock_timeout = '5s'`) before DDL. GoCardless documented a production incident where a fast FK addition caused downtime — not from execution time, but from waiting for an `AccessExclusive` lock while queries piled up behind it.

### MySQL: the INSTANT/INPLACE/COPY hierarchy

MySQL 8.0 tries algorithms in order: **INSTANT → INPLACE → COPY**. INSTANT operations are metadata-only and complete in milliseconds:

| Operation | Algorithm | Since | Concurrent DML? |
|---|---|---|---|
| Add column (any position) | INSTANT | 8.0.29 | Yes |
| Drop column | INSTANT | 8.0.29 | Yes |
| Rename column | INSTANT | 8.0.28 | Yes |
| Change column default | INSTANT | 8.0.12 | Yes |
| Add/drop index | INPLACE | All | Yes |
| Change column type | COPY | All | **No** |

For operations requiring COPY (like changing column types), use external tools: **pt-online-schema-change** (trigger-based, supports foreign keys, works with Galera clusters) or **gh-ost** (binlog-based, triggerless, pausable, interactive cutover, but no FK support). Decision rule: FKs present → pt-osc; need pausability → gh-ost; MySQL 8.0+ → check if INSTANT/INPLACE solves it first.

### The expand-contract pattern (universal)

For any backward-incompatible schema change across all engines:

1. **Expand**: Add new column/table alongside old; deploy dual-write code
2. **Migrate**: Backfill existing data in batches (1,000–50,000 rows, with sleep between batches)
3. **Contract**: Switch reads to new structure; stop writing to old; drop old column/table

This is the only safe pattern for column renames, type changes, and structural refactoring in production. Tools like **pgroll** and **Reshape** automate expand-contract for PostgreSQL.

### Migration tools landscape

| Tool | Approach | Rollback | Notable feature |
|---|---|---|---|
| **Atlas** | Declarative (schema-as-code) | Auto-planned | **50+ migration linting checks**; Terraform provider |
| **Flyway** | Imperative (SQL files) | Paid tier only | Simple versioned files; checksums |
| **Alembic** | Imperative (Python) | Downgrade scripts | Auto-generate from SQLAlchemy models |
| **Prisma Migrate** | Hybrid | Manual SQL edit | Shadow database for drift detection |
| **Sqitch** | Dependency graph | Explicit revert scripts | Not linear — true dependency ordering |

**Key distinction**: Declarative tools (Atlas, Prisma) define desired state and compute diffs — generally safer. Imperative tools (Flyway, Alembic) give more control but require careful authoring.

---

## 3. Indexing decision rules the AI can execute directly

Generic advice like "add indexes for performance" is useless for an AI tool. What follows are concrete, implementable algorithms.

### The universal composite index ordering algorithm

```
FUNCTION order_composite_index(query_columns):
  1. Separate columns into: EQUALITY (=, IN), SORT (ORDER BY), RANGE (>, <, BETWEEN)
  2. Place EQUALITY columns first
  3. Place SORT columns next (matching ORDER BY direction)
  4. Place RANGE columns last
  RETURN ordered_columns
```

This aligns with MongoDB's **ESR (Equality, Sort, Range) Rule** and is universally applicable. The "selectivity-first" guidance that appears in older documentation is **erroneous for B-tree indexes** — MongoDB's documentation explicitly states this. When all columns are equality conditions, ordering among them has minimal practical impact.

**Concrete example**: For `WHERE customer_id = 101 AND status = 'active' AND order_date > '2024-01-01' ORDER BY total DESC`, the optimal index is `(customer_id, status, total DESC, order_date)` — equality, then sort, then range.

### Engine-specific index type selection

**PostgreSQL** offers the richest index ecosystem. Decision rules:

- **JSONB columns** → GIN index with `jsonb_path_ops` (3× faster lookups than GiST for containment queries)
- **Geometric/range data** → GiST index (supports nearest-neighbor via `<->` operator)
- **Time-series on very large tables** → **BRIN index** (can be **1000× smaller** than B-tree; stores min/max per block range; only effective when physical row order correlates with column values)
- **Expression-based queries** (e.g., `WHERE LOWER(email) = ?`) → Expression index: `CREATE INDEX ON users(LOWER(email))`
- **Small subset queried** (e.g., only 'active' records) → **Partial index**: `CREATE INDEX ON orders(id) WHERE status = 'active'` — dramatically reduces index size when filtered subset is <20% of total rows

**MySQL/InnoDB** has a unique architecture where **the primary key IS the table data** (clustered index). Every secondary index stores the PK columns — so UUID primary keys add 16 bytes to every secondary index entry and cause random page splits. **Always prefer short auto-increment integer PKs in InnoDB.** Use prefix indexes for TEXT columns: `CREATE INDEX ON products(description(20))`.

**DynamoDB** requires access-pattern-driven design. Use **GSI overloading** with generic attribute names (`GSI1PK`, `GSI1SK`) when approaching the 20-GSI limit. **Sparse indexes** automatically filter items — only items with the GSI key attributes appear in the index.

### Index types across engines

| Feature | PostgreSQL | MySQL/InnoDB | MongoDB | DynamoDB |
|---|---|---|---|---|
| Default | B-tree | B-tree (clustered PK) | B-tree | Hash+Range |
| Partial/Filtered | `WHERE` clause | Not natively | `partialFilterExpression` | Sparse indexes |
| Covering | `INCLUDE` clause | Implicit PK in secondary | With projection | GSI projection |
| Full-text | GIN on tsvector | FULLTEXT | Text indexes | Not supported |
| JSON indexing | GIN on JSONB | Generated columns | Wildcard indexes | Not supported |
| TTL/Expiration | pg_cron (manual) | Manual | TTL indexes | TTL attribute |
| Time-series optimized | BRIN | Not available | Time-series collections | Not available |

### When to use external search engines

Use database-native full-text search when: search is not a primary feature, dataset <5M documents, and only simple keyword matching is needed. Switch to **Elasticsearch/Meilisearch/Typesense** when you need typo tolerance, faceted search, relevance tuning, autocomplete, or the dataset exceeds 10M documents with complex queries. The tradeoff: external engines require data sync pipelines and introduce eventual consistency.

---

## 4. Multi-tenant data isolation patterns and their index implications

### The decision tree

```
< 50 large enterprise tenants + strict compliance → DATABASE-PER-TENANT
50–1,000 tenants + moderate isolation → SCHEMA-PER-TENANT or SHARED + RLS
1,000–100,000 tenants (typical SaaS) → SHARED TABLE + tenant_id + RLS
100,000+ tenants (consumer-scale) → SHARED TABLE + tenant_id (+ Citus for horizontal scale)
```

**The industry consensus** (Bytebase, Crunchy Data, Supabase) is clear: **adopt shared table with discriminator column whenever possible.** Schema-per-tenant combines the drawbacks of both models. Database-per-tenant is justified only for regulated industries or large enterprise customers.

### PostgreSQL RLS as defense-in-depth

Row-Level Security adds database-enforced tenant isolation on top of application-level `WHERE` clauses:

```sql
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;  -- Even table owner must comply

CREATE POLICY tenant_isolation ON orders
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

Set tenant context per-transaction for connection pool safety: `SELECT set_config('app.current_tenant_id', $1, true)` (the `true` parameter makes it transaction-local, compatible with PgBouncer in transaction mode).

**Critical RLS pitfalls**: Superusers and table owners bypass RLS by default — use `FORCE ROW LEVEL SECURITY`. Views bypass RLS unless `security_invoker = true` (PG 15+). Subqueries in policies can cause exponential performance degradation — from Supabase testing, a 1M-row table with a subquery-based policy can take **3+ minutes** vs. milliseconds with a simple equality check.

### Six index rules for multi-tenant schemas

1. **`tenant_id` FIRST in every composite index** — B-tree prefix scanning requires it
2. **Equality before range**: `(tenant_id, status, created_at)` for `WHERE tenant_id = ? AND status = 'active' AND created_at > ?`
3. **Unique constraints MUST include tenant_id**: `UNIQUE(tenant_id, email)`, never `UNIQUE(email)`
4. **Foreign keys should include tenant_id**: `FOREIGN KEY (tenant_id, order_id) REFERENCES orders(tenant_id, id)` for safer cross-tenant protection
5. **Partial indexes for common filters**: `WHERE status = 'active'` reduces index size significantly
6. **Covering indexes for high-frequency queries**: `INCLUDE (status, total)` enables index-only scans

**Partition by tenant_id** only when tables exceed 10GB. LIST partitioning supports per-tenant lifecycle (drop partition = instant tenant deletion) but doesn't scale beyond ~5,000 partitions. HASH partitioning distributes evenly but prevents per-tenant operations.

---

## 5. Schema evolution that won't break async consumers

### Compatibility rules every change must pass

| Change | Backward compatible? | Forward compatible? | Safe for async? |
|---|---|---|---|
| Add optional field with default | ✅ | ✅ | ✅ Safe |
| Remove optional field | ✅ | ❌ | ⚠️ Use expand-contract |
| Remove required field | ❌ | ❌ | ❌ Breaking |
| Rename field | ❌ (Avro/JSON) / ✅ (Protobuf) | Varies | ⚠️ Depends on format |
| Change field type | ❌ | ❌ | ❌ Breaking |
| Add new enum value | ✅ | ❌ | ⚠️ Old consumers fail on unknown |

**Protobuf** identifies fields by tag numbers, making renames free. **Avro** supports aliases for backward-compatible renames. **JSON Schema** has the weakest evolution story — no built-in compatibility checking. For Kafka-centric systems, use **Confluent Schema Registry** with FULL_TRANSITIVE compatibility mode for maximum safety (both backward and forward compatible against all previous versions).

### The outbox pattern schema

The outbox pattern decouples database schema from event payload, preventing DB migrations from breaking consumers:

```sql
CREATE TABLE outbox_events (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id   VARCHAR(255) NOT NULL,
    event_type     VARCHAR(255) NOT NULL,
    payload        JSONB NOT NULL,          -- Decoupled from DB schema
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    published_at   TIMESTAMPTZ NULL         -- NULL = not yet published
);

CREATE INDEX idx_outbox_unpublished ON outbox_events (created_at)
    WHERE published_at IS NULL;
```

Relay via **CDC (Debezium)** for low latency or **polling** for simplicity. The key insight: the `payload` JSONB column is independent of business entity columns, so renaming or restructuring business tables doesn't affect events.

### Event sourcing data model

```sql
CREATE TABLE events (
    global_position  BIGSERIAL PRIMARY KEY,
    stream_id        VARCHAR(255) NOT NULL,
    stream_position  INTEGER NOT NULL,
    event_type       VARCHAR(255) NOT NULL,
    data             JSONB NOT NULL,
    metadata         JSONB DEFAULT '{}',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (stream_id, stream_position)  -- Optimistic concurrency
);
```

Support with snapshot tables (stream_id + version + serialized state) for read performance, and projection checkpoint tables to track consumer progress through the event stream.

---

## 6. Data retention, soft deletes, and GDPR deletion

### Soft delete pattern comparison

| Pattern | Pros | Cons | Default? |
|---|---|---|---|
| **`deleted_at` timestamp** | Simple; preserves deletion time; supports partial index `WHERE deleted_at IS NULL` | Every query needs filter; unique constraint requires partial unique index | **Yes — recommended default** |
| **Status enum** (active/archived/deleted) | Multiple states; clearer lifecycle semantics | Enum evolution; more complex filtering | When entity has rich lifecycle |
| **Archive table** | Clean main table; no query filter | Complex transactional move; FK management; schema sync | High-volume tables with rare undelete |
| **Boolean `is_deleted`** | Simplest | No deletion timestamp; limited information | Only for prototypes |

For `deleted_at`, always create a partial unique index for active records: `CREATE UNIQUE INDEX ON users(email) WHERE deleted_at IS NULL` — this enforces uniqueness only among non-deleted records.

### GDPR right-to-deletion decision tree

The most practical patterns for "delete my data" requests:

- **Hard delete + anonymized audit log**: Delete PII rows, keep anonymized audit records. Simplest for single-DB systems.
- **Crypto-shredding**: Encrypt PII with per-user encryption key; "delete" by destroying the key. Works across distributed systems and handles backups automatically. **Spotify's "Padlock" system** uses this at scale.
- **Separate PII tables**: Model data so all personally identifiable information lives in dedicated tables (`user_pii`), while business data references `user_id` but contains no PII. Deletion = `DELETE FROM user_pii WHERE user_id = ?`.

**Legal note**: The European Commission considers encrypted personal data still personal data. Crypto-shredding's legal sufficiency varies by jurisdiction — consult legal counsel.

### Legal hold integration

Legal holds override all retention policies. Model with a `legal_holds` table plus a `legal_hold_items` junction table (entity_type, entity_id). Every deletion function must check for active holds before proceeding. A record can be under multiple concurrent holds; only after all holds are released does normal retention resume.

### TTL-based cleanup across engines

**DynamoDB** offers native TTL (set epoch timestamp attribute; deletion is free but eventually consistent — up to 48 hours delay). **MongoDB TTL indexes** (`expireAfterSeconds`) run a background thread every 60 seconds. **PostgreSQL** requires **pg_cron** with batched DELETE statements or, preferably, **partition-based retention** using pg_partman: `DETACH PARTITION CONCURRENTLY` is instant, and `DROP TABLE` of detached partitions avoids the VACUUM overhead of mass DELETEs.

---

## Engine syntax comparison tables for code generation

### Data type mapping across engines

| Concept | PostgreSQL | MySQL 8.x | SQLite |
|---|---|---|---|
| Auto-increment | `GENERATED ALWAYS AS IDENTITY` | `AUTO_INCREMENT` | `INTEGER PRIMARY KEY` (implicit rowid) |
| Boolean | `BOOLEAN` | `TINYINT(1)` | `INTEGER` (0/1) |
| Timestamp w/ TZ | `TIMESTAMPTZ` | `TIMESTAMP` (UTC) / `DATETIME` (no TZ) | `TEXT` (ISO8601) or `INTEGER` (epoch) |
| JSON | **`JSONB`** (binary, indexable) | `JSON` (binary since 8.0) | `TEXT` + `json_extract()` |
| UUID | Native `uuid` + `gen_random_uuid()` | `CHAR(36)` or `BINARY(16)` | `TEXT` |
| Enum | `CREATE TYPE AS ENUM` | `ENUM('a','b')` inline | `CHECK(col IN ('a','b'))` |
| Arrays | Native `INTEGER[]`, `TEXT[]` | Not supported (use JSON) | Not supported |
| Upsert | `ON CONFLICT (col) DO UPDATE SET x = EXCLUDED.x` | `ON DUPLICATE KEY UPDATE x = VALUES(x)` | Same as PG (since 3.24.0, lowercase `excluded`) |
| RETURNING | ✅ | ❌ | ✅ (since 3.35.0) |
| Transactional DDL | ✅ | ❌ (implicit commit) | ✅ |

### Critical gotchas for AI code generation

- **MySQL CHECK constraints** are silently ignored before 8.0.16 — generated code appears valid but doesn't enforce
- **SQLite foreign keys** are OFF by default — must emit `PRAGMA foreign_keys = ON` per connection
- **SQLite type affinity** means `VARCHAR(255)` is accepted but has no length enforcement unless `STRICT` mode (3.37+)
- **PostgreSQL SERIAL** is legacy — prefer `GENERATED ALWAYS AS IDENTITY`
- **MySQL BOOLEAN** is actually `TINYINT(1)` — `IS TRUE` behavior differs subtly from PostgreSQL
- **ALTER TABLE** in SQLite cannot add constraints, change column types, or drop columns before 3.35.0 — must recreate the table entirely (libSQL/Turso adds `ALTER COLUMN` support)

---

## Edge SQLite and serverless/wide-column engines

### SQLite at the edge via Turso, LiteFS, and D1

**Turso** (libSQL fork) transforms SQLite into a production database with **embedded replicas** (local SQLite syncs from remote primary, microsecond reads), **ALTER TABLE extensions** (can change column types, add/remove constraints — impossible in vanilla SQLite), and native vector search. Supports millions of databases per account, making it ideal for **per-user/per-tenant** patterns.

**Cloudflare D1** is serverless SQLite at the edge with a **10GB per-database hard limit**, single-threaded query processing (~1,000 reads/sec for 1ms queries), and access only through Workers bindings. Designed for many small databases, not one large database.

**LiteFS** (Fly.io) provides FUSE-based replication with **~100 transactions/sec** throughput due to FUSE overhead and single-writer constraint. **Warning**: Fly.io docs now state they cannot provide support for this product.

**When to choose edge SQLite**: local-first/offline-capable apps, per-user databases, edge functions with low-latency reads, prototyping. **Avoid for**: high write throughput, complex queries across large datasets, applications needing concurrent writes.

### DynamoDB single-table design essentials

Store all entity types in one table using entity-type prefixes: `PK = "USER#123"`, `SK = "PROFILE#123"`. Design around **access patterns**, not entities — there are no joins. Key limitations: **400KB item size**, eventually consistent GSI reads, max 20 GSIs per table. Avoid hot partitions by choosing high-cardinality partition keys or appending random suffixes for write sharding. Use DynamoDB when you need **single-digit millisecond latency at any scale** with well-defined access patterns. Avoid when query patterns are evolving or you need ad-hoc reporting.

### Cassandra partition design

Primary key structure: `PRIMARY KEY ((partition_cols), clustering_cols)`. **Every query MUST include the full partition key** — without it, Cassandra performs a cluster-wide scan. Keep partitions under **100MB**. For high-volume entities, use time-bucketed composite partition keys: `PRIMARY KEY ((tenant_id, log_month), created_at)`. Design one table per query pattern; denormalization is expected and optimized for.

---

## Quality validation checklist for generated schemas

These anti-patterns should be caught automatically in every generated schema:

1. **Orphan tables**: Tables with no FK relationships (isolated from the data model)
2. **Missing FK indexes**: PostgreSQL does not auto-create indexes on FK columns — every FK column needs an explicit index
3. **Unique constraints missing tenant_id**: In multi-tenant context, `UNIQUE(email)` instead of `UNIQUE(tenant_id, email)`
4. **Missing timestamps**: Tables without `created_at` and `updated_at` (all analyzed open-source projects include these)
5. **Boolean columns without defaults**: `is_active BOOLEAN` needs `DEFAULT true`
6. **Enum-as-string without CHECK**: Status columns like `status VARCHAR(20)` without `CHECK(status IN (...))`
7. **Missing ON DELETE behavior**: FK constraints without CASCADE/RESTRICT/SET NULL specification
8. **Over-normalization**: 1:1 tables that are always co-accessed (should be embedded)
9. **Polymorphic type+id columns**: `commentable_type + commentable_id` without FK enforcement — GitLab explicitly bans this pattern
10. **God tables**: Tables with 50+ columns that should be decomposed
11. **PostgreSQL ENUM types for evolving values**: Cannot remove values; prefer CHECK constraints on VARCHAR

### Schema quality scoring rubric

| Dimension | Weight | Checks |
|---|---|---|
| Referential integrity | 25% | FKs defined; ON DELETE specified; FK indexes present |
| Constraint completeness | 25% | CHECK for enums/ranges; NOT NULL where appropriate; UNIQUE for business rules |
| Index coverage | 20% | FK columns indexed; query patterns covered; composite ordering correct |
| Convention consistency | 15% | snake_case naming; plural table names; consistent constraint naming |
| Operational readiness | 15% | Timestamps present; soft-delete support; migration notes included |

---

## Patterns distilled from production open-source schemas

Analysis of **Discourse, Mastodon, Ghost, Cal.com, GitLab, and Supabase** reveals strong consensus on several patterns:

**Naming**: All projects use **plural snake_case table names** (`users`, `order_items`). This avoids PostgreSQL reserved word conflicts (`user` is reserved; `users` is not). GitLab provides the most detailed constraint naming convention: `pk_<table>`, `fk_<table>_<column>_<ref_table>`, `check_<table>_<column>_<type>`, `index_<table>_on_<columns>` — prefixes over suffixes for easy sorting and identification.

**Primary keys**: Most projects use **bigint with auto-increment**. Mastodon uses a custom `timestamp_id()` function (Snowflake-like IDs encoding creation time). Cal.com uses integer PKs with separate UUID columns for public-facing identifiers. Ghost's string IDs are atypical and not recommended.

**Enum handling**: Strong consensus against PostgreSQL native ENUM types (values cannot be removed, modifications require aggressive locking). GitLab, Close.com, and Crunchy Data independently confirmed: **prefer CHECK constraints on VARCHAR columns** for operational flexibility.

**Polymorphic associations**: GitLab's official position: *"Always use separate tables instead of polymorphic associations."* The type+id pattern cannot enforce FK constraints, wastes space, and mixes responsibilities. Better alternatives: separate tables per type, shared super-type table, or exclusive belongs-to with nullable FKs and a CHECK ensuring exactly one is set.

**Audit tables without FKs**: Cal.com intentionally omits FK constraints on audit tables so audit records survive the deletion of referenced entities — a pattern worth adopting for any audit/logging schema.

**RLS as default for PostgreSQL multi-tenant**: Supabase generates RLS policies alongside table definitions, indexes all columns used in policies, and wraps JWT functions in `(select auth.uid())` to enable query plan caching.

---

## Conclusion: implementation priorities for the skill

The research converges on five architectural decisions for `backend-data-model`:

**First, adopt a multi-agent review pipeline** inspired by SchemaAgent. A single LLM pass produces schemas with ~42% error rates on constraint extraction. A pipeline of analyst → designer → reviewer → validator, with structured validation between stages, dramatically reduces errors. The reviewer should run the full anti-pattern checklist against every generated schema.

**Second, make multi-tenancy a first-class input parameter**, not an afterthought. When enabled, the tool must automatically add `tenant_id` to every table, include it in all unique constraints and composite indexes, and generate RLS policies. This addresses the most dangerous LLM failure mode.

**Third, generate migration notes alongside DDL**, not just the target schema. Every ADD COLUMN should note whether it's instant (PG 11+ with constant default) or requires the NOT VALID + VALIDATE pattern. Every new index should specify `CONCURRENTLY`. The tool should flag operations that require expand-contract (column renames, type changes) and generate the multi-step migration plan.

**Fourth, use CHECK constraints on VARCHAR instead of native ENUMs** as the default for all engines. This is the strongest consensus finding from both open-source schema analysis and practitioner experience — it provides database-level validation without the operational pain of ENUM type evolution.

**Fifth, validate syntax per target engine using AST parsing** (sqlglot or equivalent). The hallucinated-syntax failure mode is endemic to LLM-generated DDL. Every output must be parsed and validated against the target dialect before being presented to the user, catching impossible constraints, missing features, and syntax differences between engines.