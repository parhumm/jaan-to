# Backend Task Breakdown — Reference Material

> Extracted from `skills/backend-task-breakdown/SKILL.md` for token optimization.
> This file contains pure reference material: templates, format specifications, example blocks, and checklists.

---

## T-shirt Sizing

Apply backend-specific benchmarks:

| Size | Lines of Code | Typical Work | Example |
|------|---------------|--------------|---------|
| **XS** | <50 LOC | Single-column migration, config change | Add `deleted_at` column |
| **S** | 50-150 LOC | Standard CRUD endpoint, simple model | OrderController@store |
| **M** | 150-300 LOC | Complex validation, relationships, job | ProcessPaymentJob with retries |
| **L** | 300-500 LOC | Multi-step workflow, transaction handling | Checkout flow service |
| **XL** | 500-800 LOC | Complex integration, state machine | Payment provider integration |
| **XXL** | >800 LOC | FLAG FOR DECOMPOSITION | Should be split |

**Escalation factors** (increase size by one level if applies):
- Needs idempotency handling
- Requires zero-downtime migration (expand-contract pattern)
- Involves external API integration
- Handles money/payments
- Complex business logic with edge cases

---

## Master Task Card Template

For **each task**, generate a complete task card:

```markdown
## [TASK-ID] Type: Task Title

**Size:** {XS/S/M/L/XL} ({hour range})
**Priority:** {P0/P1/P2}
**Complexity:** {Low/Medium/High}

**File(s):**
- `{full/file/path/to/create/or/modify.php}`
- `{another/file/if/applicable.php}`

**Dependencies:**
- blocked-by: [{TASK-IDS}]
- needs: [{TASK-IDS}]
- parallel-with: [{TASK-IDS}]

**Description:**
{1-2 sentence description of what this task accomplishes and why it's needed}

**Acceptance Criteria:**
- [ ] {Testable criterion 1}
- [ ] {Testable criterion 2}
- [ ] {Testable criterion 3}
- [ ] {Testable criterion 4-5 as needed}

**Data Model Notes:** *(for Migration/Model tasks only)*
```yaml
table: {table_name}
columns:
  - name: id
    type: bigIncrements
    nullable: false
  - name: user_id
    type: unsignedBigInteger
    nullable: false
    foreign_key: users.id
  - name: status
    type: enum ['pending', 'processing', 'completed', 'failed']
    default: 'pending'
  - name: amount
    type: decimal(10,2)
    nullable: false
indexes:
  - columns: [user_id, status]
    name: idx_user_status
  - columns: [created_at]
    name: idx_created_at
constraints:
  - unique: [user_id, external_id]
  - check: amount > 0
migration:
  zero_downtime: {true/false}
  expand_contract: {true/false — if renaming/changing type}
```

**Idempotency:** *(for Controller/Job tasks with mutations)*
- Type: {Database unique constraint | Redis caching | Idempotency key header}
- Key: `{user_id}:{resource}:{external_id}` or similar
- Storage: Database `idempotency_keys` table | Redis with TTL
- Duplicate handling: Return original response with 200 or 409 Conflict

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| {Error 1} | {code} | {retry/log/alert/fail-gracefully} |
| {Error 2} | {code} | {strategy} |

**Reliability Notes:** *(for Job tasks)*
- Queue: `{queue_name}` (e.g., `default`, `high`, `low`)
- Tries: {number} (default: 3)
- Backoff: {strategy} (exponential: 30s, 2m, 8m)
- Timeout: {seconds} (default: 60s)
- Transaction scope: {Yes — wrap in DB::transaction | No — idempotent design}

**Security Checklist:** *(for Controller/API tasks)*
- [ ] Input validation via FormRequest
- [ ] Authorization check (Policy/Gate)
- [ ] Rate limiting applied ({n} req/min)
- [ ] CSRF protection (if applicable)
- [ ] SQL injection prevention (use query builder/Eloquent)

**Test Requirements:**
- Unit test: `tests/Unit/{Path}/{ClassName}Test.php`
- Feature test: `tests/Feature/{Feature}/{ActionName}Test.php`
- Coverage: {Happy path + 2-3 edge cases minimum}
```

---

## Dependency Graph Format

Generate a text-based dependency graph:

```
DEPENDENCY CHAINS
=================

Critical Path (Sequential):
[ORD-001] -> [ORD-002] -> [ORD-003] -> [ORD-004] -> [ORD-006]
Migration -> Model -> Controller -> Job -> Test
S + S + M + M + M = ~8-12 hours

Parallel Tracks:
Track A (Orders): [ORD-001] -> [ORD-002] -> [ORD-003]
Track B (Payments): [PAY-001] -> [PAY-002] -> [PAY-003]
Track C (Users): [USR-001] -> [USR-002] -> [USR-003]

Integration Point:
[CHK-001] Checkout Service (needs: [ORD-003], [PAY-003], [USR-003])
```

---

## Ambiguity Defaults Table

Document all defaults applied where PRD was ambiguous:

| Area | PRD Ambiguity | Default Applied | Override? |
|------|---------------|-----------------|-----------|
| Delete strategy | Not specified | Soft delete for all entities | Can hard-delete logs |
| Pagination | "Show orders" | Cursor-based, 25 per page | - |
| Timestamps | Not mentioned | All tables have created_at, updated_at | - |
| Status fields | "Track order state" | Enum: pending/processing/completed/failed | - |
| Error format | Not specified | RFC 7807 Problem Details | - |

---

## Export Formats

### Jira CSV Import

```csv
Summary,Description,Issue Type,Priority,Story Points,Parent,Labels
"[ORD-001] Migration: Create orders table","See task card for full details",Task,Medium,1,EPIC-123,"backend,database"
"[ORD-002] Model: Order with relationships","See task card for full details",Task,Medium,1,EPIC-123,"backend,model"
...
```

### Linear Markdown

```markdown
## Backend Task Breakdown: {Feature Name}

- [ ] [ORD-001] Migration: Create orders table (S, 1-2h) `backend` `database`
- [ ] [ORD-002] Model: Order with relationships (S, 1-2h, blocked-by: ORD-001) `backend` `model`
- [ ] [ORD-003] Controller: OrderController@store (M, 2-4h, blocked-by: ORD-002) `backend` `api`
...
```

### JSON Export

```json
{
  "feature": "{feature_name}",
  "framework": "{framework}",
  "slicing": "{vertical/horizontal}",
  "total_tasks": "{count}",
  "tasks": [
    {
      "id": "ORD-001",
      "type": "Migration",
      "title": "Create orders table",
      "size": "S",
      "duration_hours": "1-2",
      "priority": "P1",
      "files": ["database/migrations/YYYY_MM_DD_create_orders_table.php"],
      "dependencies": {
        "blocked_by": ["USR-001"],
        "needs": [],
        "parallel_with": ["PAY-001"]
      },
      "acceptance_criteria": ["..."]
    }
  ]
}
```

---

## Quality Checklists

### Coverage Validation
- [ ] Every PRD requirement maps to at least one task
- [ ] All CRUD operations covered per entity
- [ ] Error handling tasks exist per integration point
- [ ] Auth/authz requirements have explicit tasks (Policies)
- [ ] Logging and monitoring tasks included
- [ ] Test tasks exist for each feature area

### Structure Validation
- [ ] No task exceeds XL size (XXL flagged for decomposition)
- [ ] Each task has 3-5 testable acceptance criteria
- [ ] Dependencies explicitly documented
- [ ] All tasks have size estimates
- [ ] Each task assignable to a single developer

### Technical Validation
- [ ] Migration tasks specify up/down methods
- [ ] Index strategy documented for queried fields
- [ ] Idempotency requirements stated for mutations
- [ ] Error scenarios listed per external integration
- [ ] Queue configuration specified for async work
- [ ] Zero-downtime classification for schema changes

### Anti-pattern Validation
- [ ] Not too granular (>30 tasks -> suggest chunking)
- [ ] Not too coarse (no XXL tasks remain)
- [ ] No orphan tasks (every task traces to PRD)
- [ ] No hero tasks (multi-discipline single tasks)
- [ ] Error handling present for all integrations

---

## Implicit Tasks Detection Checklists

Automated scan for tasks the PRD doesn't explicitly mention but are required for production.

### Database Implicit Tasks

For each entity:
- [ ] **Indexes**: Any field used in WHERE clauses or foreign keys
  - Signal: User stories mention "search", "filter", "sort"
  - Task: Add database index migration
- [ ] **Soft deletes**: If delete strategy = soft (from Step 2)
  - Signal: PRD mentions "archive", "restore", "undo delete"
  - Task: Add `deleted_at` column + SoftDeletes trait
- [ ] **Cascading deletes**: Parent-child relationships
  - Signal: "when X is deleted, remove all Y"
  - Task: Add `onDelete('cascade')` foreign key constraint
- [ ] **Unique constraints**: Business rules requiring uniqueness
  - Signal: "only one", "unique", "duplicate prevention"
  - Task: Add unique index migration

### Error Handling Implicit Tasks

For each integration point (external API, job, async operation):
- [ ] **Circuit breaker**: Prevent cascade failures
  - Signal: External API dependency
  - Task: Add circuit breaker with retry limits
- [ ] **Timeout handling**: Prevent hanging requests
  - Signal: API integration
  - Task: Set timeout (default 30s), handle timeout exceptions
- [ ] **Retry logic**: Handle transient failures
  - Signal: Queue job, payment processing, webhook
  - Task: Configure retry attempts (3x with exponential backoff)
- [ ] **Dead letter queue**: Capture failed jobs
  - Signal: Critical jobs (payments, notifications)
  - Task: Configure failed_jobs table + monitoring

### Security Implicit Tasks

For protected resources:
- [ ] **Authorization policies**: Who can perform actions
  - Signal: PRD mentions "owner", "admin", "permission"
  - Task: Create Policy class per model
- [ ] **Rate limiting**: Prevent abuse
  - Signal: Public API endpoints, authentication
  - Task: Add rate limiting middleware (60 req/min default)
- [ ] **Input validation**: Prevent injection attacks
  - Signal: User input, forms, API endpoints
  - Task: Create FormRequest validation classes
- [ ] **Encryption**: Protect sensitive data
  - Signal: PII, payment data, credentials
  - Task: Add encryption to model attributes

### Observability Implicit Tasks

For each feature area:
- [ ] **Audit logging**: Track who did what when
  - Signal: Regulatory requirements, sensitive operations
  - Task: Create audit_logs table + logging events
- [ ] **Monitoring**: Detect failures in production
  - Signal: Critical user flows, payment processing
  - Task: Add monitoring events (errors, latency, throughput)
- [ ] **Alerting**: Notify team of issues
  - Signal: Revenue-impacting features, SLA commitments
  - Task: Configure alerts with thresholds

---

## Slicing Strategy Examples

### Vertical Slicing (default)

Group tasks by **user-facing feature**, not by technical layer. Each slice delivers complete end-to-end functionality.

**Example slice: "Order Placement"**
```
[ORD-001] Migration: Create orders table (S)
[ORD-002] Model: Order with relationships (S)
[ORD-003] Controller: OrderController@store (M)
[ORD-004] Job: ProcessOrderJob for async fulfillment (M)
[ORD-005] Policy: OrderPolicy for authorization (S)
[ORD-006] Test: Order placement feature test (M)
```

### Horizontal Slicing (if user selected)

Group tasks by **technical layer**. Requires careful dependency management.

**Example: Data layer first**
```
Phase 1: Migrations
[DB-001] Create users table (S)
[DB-002] Create orders table (S)
[DB-003] Create payments table (S)

Phase 2: Models
[MOD-001] User model (S)
[MOD-002] Order model (S)
[MOD-003] Payment model (S)

Phase 3: Controllers
[CTL-001] OrderController (M)
```

---

## Dependency Notation Format

Use explicit dependency markers:

**blocked-by:** Task cannot start until blocker completes
```
[ORD-003] Controller: OrderController@store
  blocked-by: [ORD-001], [ORD-002]
```

**needs:** Task requires output from another task
```
[ORD-006] Test: Order feature test
  needs: [ORD-003] (endpoint must exist to test)
```

**parallel-with:** Tasks that can be worked on simultaneously
```
[ORD-002] Model: Order
  parallel-with: [USR-002] Model: User
```

---

## Critical Path Calculation

Identify the **longest chain of sequential dependencies** — this determines minimum project duration.

**Example critical path:**
```
[ORD-001] → [ORD-002] → [ORD-003] → [ORD-004] → [ORD-006]
Migration → Model → Controller → Job → Test
S + S + M + M + M = 5-10 hours
```

---

## Anti-pattern Detection Rules

Flag issues before HARD STOP:

**Too granular** (>30 tasks for a single feature):
- Average size below XS
- Tasks like "Add one column", "Change one validation rule"
- **Fix**: Group related micro-tasks into single S-sized tasks

**Too coarse** (single task >2 days):
- XXL tasks without decomposition
- Vague scope like "Build entire checkout system"
- **Fix**: Split into smaller vertical slices

**Missing error handling:**
- Integration tasks without retry/timeout/circuit-breaker
- **Fix**: Add error handling as explicit tasks or sub-tasks

**Orphan tasks** (no trace to PRD):
- Cannot map task back to a specific user story or requirement
- **Fix**: Remove or justify why needed

**Hero tasks** (require multiple skills):
- Single task needs backend + frontend + database expertise
- **Fix**: Split by layer or assign multiple people

---

## Task Breakdown Plan Display Template

```
TASK BREAKDOWN PLAN
═══════════════════

Slicing: {Vertical/Horizontal/Hybrid}
Total Tasks: {count}
Critical Path: {n} sequential tasks ({estimated duration})

ENTITY SUMMARY
──────────────
| Entity | Table | Tasks | Notes |
|--------|-------|-------|-------|
| User | users | 6 | Auth + profile |
| Order | orders | 8 | Create, cancel, fulfill |
| Payment | payments | 5 | Process, refund, void |

TASK LIST (Draft)
─────────────────
[ORD-001] Migration: Create orders table (S, 1-2h)
  blocked-by: [USR-001]
[ORD-002] Model: Order with relationships (S, 1-2h)
  blocked-by: [ORD-001]
[ORD-003] Controller: OrderController@store (M, 2-4h)
  blocked-by: [ORD-002]
...

IMPLICIT TASKS
──────────────
[IMP-001] Add index on orders.user_id (XS, <1h) — JOIN performance
[IMP-002] Circuit breaker for Stripe API (S, 1-2h) — Prevent cascade failures
...

DECOMPOSITION WARNINGS
──────────────────────
⚠️ [PAY-003] "Stripe integration" is XL — consider splitting into:
  - Payment intent creation (M)
  - Webhook handling (M)
  - Refund processing (S)

ANTI-PATTERN CHECKS
───────────────────
✓ No orphan tasks
✓ No hero tasks
✓ Error handling present for all integrations
✗ 32 tasks detected — above 30 threshold, consider chunking by feature area
```
