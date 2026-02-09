---
name: backend-task-breakdown
description: Convert a PRD into structured backend development tasks with data model notes, reliability patterns, and error taxonomy.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/**), Write($JAAN_OUTPUTS_DIR/frontend/**), Task, Edit(jaan-to/config/settings.yaml)
argument-hint: [prd-path] OR [feature-description]
---

# backend-task-breakdown

> Convert PRDs into structured backend development tasks with data model notes, reliability patterns, and error taxonomy.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL: determines framework patterns)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:backend-task-breakdown.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:backend-task-breakdown.learn.md` - Past lessons (loaded in Pre-Execution)

## Input

**PRD/Feature**: $ARGUMENTS

Accepts any of:
- **PRD file path** — Path to PRD file (primary input)
- **Tech plan path** — Path to tech plan from `/jaan-to:dev-tech-plan`
- **Feature description** — Free text describing the feature

If no input provided, ask: "What PRD or feature should I break down into backend tasks?"

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:backend-task-breakdown.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 2
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

Also read tech context (CRITICAL for this skill):
- `$JAAN_CONTEXT_DIR/tech.md` - Determines framework (Laravel, FastAPI, Django, etc.), constraints, patterns

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_backend-task-breakdown` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing PRD to extract entities and actions
- Mapping requirements to task types (migrations, models, controllers, jobs)
- Building dependency graphs
- Detecting implicit tasks that PRDs don't mention
- Assessing complexity and risks

## Step 1: Parse Input

Analyze the provided input to extract requirements:

**If PRD file path:**
1. Read the PRD file using the Read tool
2. Extract:
   - Title and problem statement
   - User stories and acceptance criteria
   - Technical constraints mentioned
   - API requirements
3. Parse content for entity extraction (Step 3)

**If tech plan path:**
1. Read the tech plan file
2. Extract:
   - Architecture decisions
   - Data model notes
   - API contracts
   - Technical approach
3. Use as additional context for task breakdown

**If feature description:**
1. Parse the description
2. Identify:
   - Core entities (nouns)
   - User actions (verbs)
   - Data relationships
   - Integration points

Build an initial understanding:
```
INPUT SUMMARY
─────────────
Type:      {prd/tech-plan/description}
Entities:  {list of identified entities}
Actions:   {list of user actions}
Integrations: {external systems}
Unknown:   {areas needing clarification}
```

## Step 2: Clarify Scope

Ask up to 5 smart questions based on what's unclear from Step 1. Skip questions already answered by the input or tech.md.

**Slicing strategy** (always ask):
1. > "What task breakdown approach?
   > [1] Vertical — Each task delivers complete functionality through all layers (recommended)
   > [2] Horizontal — Separate by layer (migrations, models, controllers)
   > [3] Hybrid — Foundation layer + vertical feature slices"

**Framework questions** (ask if tech.md unavailable):
2. "What backend framework?" — only if not in tech.md
   - Affects file paths, naming conventions, component types

**Team context** (ask if relevant):
3. "Team size and sprint duration?" — for sizing calibration
   - 2-dev team vs 8-dev team changes task granularity

**Data model defaults** (ask if entities identified):
4. "Delete strategy per entity?" — with defaults suggested
   - Show extracted entities, suggest soft delete for all
   - User can override per entity

**API conventions** (ask if not in tech.md):
5. "API conventions?" — pagination, versioning, error format
   - Default: cursor-based pagination (25/page), RFC 7807 errors

## Step 3: Extract Entities and Actions

Apply the **PRD-to-Task Mapping Engine**:

| PRD Content Pattern | Recognition Signal | Task Type | Example |
|---------------------|-------------------|-----------|---------|
| **Nouns (stored data)** | "user profile", "order history", "subscription" | Migration + Model | "users table", "User.php" |
| **Verbs (user actions)** | "create", "submit", "approve", "cancel" | Controller/Action | "OrderController@store" |
| **Temporal indicators** | "later", "scheduled", "async", "background" | Queue Job | "ProcessOrderJob.php" |
| **Authorization language** | "only if admin", "requires permission", "owner can" | Policy/Middleware | "OrderPolicy@update" |
| **Relationship phrases** | "belongs to", "has many", "associated with" | Model relationships | "belongsTo(User::class)" |
| **Integration mentions** | Third-party APIs, webhooks, external services | Service class + Job | "StripePaymentService" |

**For each entity identified, record:**
- Name (singular, PascalCase for models)
- Table name (plural, snake_case)
- Key attributes (from PRD context)
- Relationships to other entities
- Operations needed (CRUD, custom actions)

**For each action identified, record:**
- HTTP method and endpoint
- Controller and method
- Request validation needs
- Authorization requirements

**Present extraction results:**
```
ENTITY EXTRACTION
═════════════════

Entities: {count}
─────────
1. User → users (registration, profile, auth)
2. Order → orders (create, update, cancel, fulfill)
3. Payment → payments (process, refund, void)

Actions: {count}
────────
1. POST /api/orders → OrderController@store
2. PUT /api/orders/{id}/cancel → OrderController@cancel
3. POST /api/payments → PaymentController@process

Relationships:
──────────────
- Order belongsTo User
- Order hasMany OrderItems
- Payment belongsTo Order
```

## Step 4: Detect Implicit Tasks

Automated scan for tasks the PRD doesn't explicitly mention but are required for production:

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

**Present detected implicit tasks:**
```
IMPLICIT TASKS DETECTED
═══════════════════════

Database (4 tasks):
- Add index on users.email (search/login)
- Add soft deletes to orders (restoration requirement)
- Add cascade delete orders→order_items
- Add unique constraint on subscriptions (user_id, status='active')

Error Handling (3 tasks):
- Add circuit breaker for Stripe API calls
- Configure retry logic for ProcessPaymentJob (3 attempts, exponential backoff)
- Set 30s timeout for webhook deliveries

Security (2 tasks):
- Create OrderPolicy for ownership checks
- Add rate limiting to /api/auth/* endpoints (5 req/min)

Observability (2 tasks):
- Add audit log for order cancellations
- Configure error monitoring for payment failures
```

## Step 5: Plan Task Structure

Organize all extracted and implicit tasks into a structured breakdown:

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

### T-shirt Sizing

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

### Dependency Notation

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

### Critical Path Calculation

Identify the **longest chain of sequential dependencies** — this determines minimum project duration.

**Example critical path:**
```
[ORD-001] → [ORD-002] → [ORD-003] → [ORD-004] → [ORD-006]
Migration → Model → Controller → Job → Test
S + S + M + M + M = 5-10 hours
```

### Anti-pattern Detection

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

**Present planned structure:**
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

---

# HARD STOP — Review Breakdown Plan

Present the complete analysis summary:

```
TASK BREAKDOWN PLAN
═══════════════════

SUMMARY
───────
PRD:           {title}
Framework:     {from tech.md}
Slicing:       {Vertical/Horizontal/Hybrid}
Total Tasks:   {count}
Critical Path: {n} tasks ({duration estimate})
Parallel Tracks: {n} independent streams

ENTITIES ({count})
──────────────────
{table with entity → table → task count → key notes}

TASKS ({count})
───────────────
{numbered list with: [ID] Type: Description (Size, duration)}
{with dependency markers}

IMPLICIT TASKS ({count})
─────────────────────────
{auto-detected tasks with rationale}

VALIDATION
──────────
✓ Coverage: All PRD requirements mapped
✓ Structure: No XXL tasks, clear dependencies
✓ Technical: Idempotency, errors, security checked
✗ Anti-pattern: {any warnings flagged}
```

> "Proceed with generating the full task breakdown? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Generate Task Breakdown Document

1. Read template: `$JAAN_TEMPLATES_DIR/jaan-to:backend-task-breakdown.template.md`
2. If tech stack needed, extract sections from tech.md:
   - Current Stack: `#current-stack`
   - Frameworks: `#frameworks`
   - Constraints: `#constraints`
   - Patterns: `#patterns`

3. Fill all template sections with analysis from Phase 1:

### Master Task Card Template

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

### Dependency Graph

Generate a text-based dependency graph:

```
DEPENDENCY CHAINS
═════════════════

Critical Path (Sequential):
[ORD-001] → [ORD-002] → [ORD-003] → [ORD-004] → [ORD-006]
Migration → Model → Controller → Job → Test
S + S + M + M + M = ~8-12 hours

Parallel Tracks:
Track A (Orders): [ORD-001] → [ORD-002] → [ORD-003]
Track B (Payments): [PAY-001] → [PAY-002] → [PAY-003]
Track C (Users): [USR-001] → [USR-002] → [USR-003]

Integration Point:
[CHK-001] Checkout Service (needs: [ORD-003], [PAY-003], [USR-003])
```

### Ambiguity Defaults Applied

Document all defaults applied where PRD was ambiguous:

| Area | PRD Ambiguity | Default Applied | Override? |
|------|---------------|-----------------|-----------|
| Delete strategy | Not specified | Soft delete for all entities | Can hard-delete logs |
| Pagination | "Show orders" | Cursor-based, 25 per page | - |
| Timestamps | Not mentioned | All tables have created_at, updated_at | - |
| Status fields | "Track order state" | Enum: pending/processing/completed/failed | - |
| Error format | Not specified | RFC 7807 Problem Details | - |

## Step 7: Generate Export Formats

Append export-ready formats to the document:

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
  "total_tasks": {count},
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
      "acceptance_criteria": [...]
    },
    ...
  ]
}
```

## Step 8: Quality Check

Before preview, validate the breakdown:

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
- [ ] Not too granular (>30 tasks → suggest chunking)
- [ ] Not too coarse (no XXL tasks remain)
- [ ] No orphan tasks (every task traces to PRD)
- [ ] No hero tasks (multi-discipline single tasks)
- [ ] Error handling present for all integrations

If any check fails, fix before preview.

## Step 9: Preview & Approval

Show the complete task breakdown document.

> "Here's the task breakdown preview. Write to `$JAAN_OUTPUTS_DIR/backend/{slug}/task-breakdown.md`? [y/n]"

## Step 9.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/backend"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths
slug="{lowercase-hyphenated-from-prd-title-max-50-chars}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-be-tasks-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: jaan-to/outputs/backend/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-be-tasks-{slug}.md

## Step 10: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write task breakdown to main file:
```bash
cat > "$MAIN_FILE" <<'EOF'
{generated task breakdown with Executive Summary}
EOF
```

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature Title}" \
  "{1-2 sentence summary: backend task breakdown for feature}"
```

4. Confirm completion:
> ✓ Task breakdown written to: jaan-to/outputs/backend/{NEXT_ID}-{slug}/{NEXT_ID}-be-tasks-{slug}.md
> ✓ Index updated: jaan-to/outputs/backend/README.md

## Step 11: Suggest Next Skill

> "Backend task breakdown complete."
>
> **Recommended next step**: For comprehensive data model documentation with constraints, indexes, migration playbooks, and retention policies:
> ```
> /jaan-to:backend-data-model "{entity-list-from-extraction}"
> ```

## Step 12: Capture Feedback

> "Any feedback or improvements needed? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this?
   > [1] Fix now - Update the breakdown
   > [2] Learn - Save for future runs
   > [3] Both - Fix now AND save lesson"

- **Option 1 - Fix now**: Update the output file, re-preview, re-write
- **Option 2 - Learn**: Run `/jaan-to:learn-add dev-be-task-breakdown "{feedback}"`
- **Option 3 - Both**: Do both

---

## Definition of Done

- [ ] Input parsed and entities/actions extracted
- [ ] Scope clarified with user (slicing strategy, defaults)
- [ ] PRD parsing engine applied to extract entities and actions
- [ ] Implicit tasks detected across 4 categories (DB, errors, security, observability)
- [ ] Task structure planned with sizes, dependencies, critical path
- [ ] User approved plan at HARD STOP
- [ ] Full task cards generated with master template per task
- [ ] Export formats generated (Jira CSV, Linear MD, JSON)
- [ ] Quality checks passed (Coverage, Structure, Technical, Anti-patterns)
- [ ] Task breakdown document written to `$JAAN_OUTPUTS_DIR/backend/{slug}/task-breakdown.md`
- [ ] User approved final result
