# Backend Task Breakdown Skill: Complete Research Guide

PRDs don't naturally decompose into implementation tasks—that transformation requires systematic methodology. This research establishes the foundations for a skill that converts Product Requirements Documents into structured backend development tasks, producing markdown files at `jaan-to/outputs/backend/{slug}/task-breakdown.md`. The skill targets Laravel 10/PHP teams running sprint-based development with **2-4 developers**, generating **ticket-level tasks** (1 PR = 1-3 days = T-shirt sized S/M/L/XL) that can be directly imported into Jira or Linear.

The research synthesizes industry standards from IEEE, SAFe, and Shape Up with Laravel-specific patterns from Spatie guidelines and real-world examples from 12+ engineering teams. Key findings include: vertical slicing produces more independently deployable tasks than horizontal layering; INVEST criteria adapted for backend tasks requires explicit testability annotations; and PRD transformation must identify **implicit tasks** (indexes, error handling, monitoring) that requirements documents rarely specify.

---

## Industry standards provide the theoretical foundation

Three frameworks dominate modern task decomposition, each contributing distinct principles applicable to backend development.

**IEEE 830 and ISO/IEC/IEEE 29148** establish hierarchical requirement structures where high-level requirements cascade into detailed sub-requirements. The critical principle for task breakdown: every requirement must be **testable** with measurable criteria—"the system shall process orders within 5 seconds" rather than "the system shall be fast." This maps directly to acceptance criteria in task definitions.

**SAFe's five-week cycle** structures work as Epics → Features → Stories → Tasks, with enablers handling technical work that doesn't directly deliver user value (migrations, infrastructure). The key insight: tasks should be **1-4 hours** of ideal time to maintain transparency and enable daily progress tracking. SAFe's "Definition of Done" concept ensures each task represents complete, shippable work.

**Basecamp's Shape Up** offers the most practical framework for PRD-to-task conversion. The methodology defines shaped work as having three properties: **rough** (room for developer contribution), **solved** (main elements connected at macro level), and **bounded** (clear scope limits). Shape Up's "hill chart" metaphor—tasks move through uphill (discovery/uncertainty) and downhill (execution/known)—provides a mental model for estimating backend tasks with varying unknowns.

| Framework | Task Duration | Key Principle | Best For |
|-----------|--------------|---------------|----------|
| IEEE 830 | Flexible | Testable criteria | Complex compliance projects |
| SAFe | 1-4 hours | Hierarchical decomposition | Large teams (10+) |
| Shape Up | 1-5 days | Fixed time, variable scope | Product teams (2-6) |
| Scrum | 1 day max | Sprint-completable | Cross-functional teams |

### INVEST criteria adapted for backend tasks

The INVEST framework (Independent, Negotiable, Valuable, Estimable, Small, Testable) designed for user stories requires adaptation for technical backend tasks:

- **Independent**: Each task deployable and testable without others. Database migrations complicate this—prefer additive schema changes that don't require coordinated deployment
- **Negotiable**: Implementation approach flexible, but acceptance criteria fixed. "Optimize query performance" → "Reduce user list query from 500ms to under 100ms p95"
- **Valuable**: Technical tasks must connect to user or business value. Not "refactor repository pattern" but "enable parallel team development by extracting order module"
- **Estimable**: Requires listing all files to modify and external dependencies. Unknown APIs or undocumented legacy code inflate estimates
- **Small**: **2-8 hours** ideal for sprint-based teams; tasks exceeding 5 days need decomposition
- **Testable**: Every backend task must specify what test verifies completion—PHPUnit assertion, API response, or performance benchmark

---

## Vertical slicing delivers independently shippable work

The choice between vertical and horizontal slicing fundamentally shapes task breakdown quality. **Horizontal slicing** separates by architectural layer (database, API, service)—one task for migrations, another for models, another for controllers. This approach fails INVEST's Independent criteria because no single task delivers value until all complete.

**Vertical slicing** cuts through every layer to deliver complete functionality. A single task might include migration, model, controller method, and test for one specific operation. This approach:

- Enables parallel developer work on different features
- Provides faster feedback through deployable increments
- Reduces integration risk by forcing layer coordination within each task
- Maps naturally to Laravel's MVC structure where a single feature touches route, controller, model, and view

**Practical vertical slice for Laravel order creation:**
```
Task: Implement order creation endpoint
Files:
  - database/migrations/xxxx_create_orders_table.php
  - app/Models/Order.php (with User relationship)
  - app/Http/Controllers/Api/OrdersController.php (store method only)
  - app/Http/Requests/StoreOrderRequest.php
  - tests/Feature/Api/OrdersControllerTest.php (store test)
```

The exception: when extensive foundational work (bulk data collection, infrastructure setup) must precede feature work, a **sprint zero** horizontal layer followed by vertical slices represents an acceptable hybrid.

---

## PRD sections map systematically to backend task types

Transforming PRD content into tasks requires extraction rules that identify task types from document patterns:

| PRD Content | Recognition Pattern | Laravel Task Type |
|------------|---------------------|-------------------|
| Data entities | Nouns representing stored data ("user profile", "order history") | Migration + Model |
| User actions | Verbs ("create", "submit", "approve") | Controller/Action class |
| Temporal indicators | "later", "scheduled", "async", "batch" | Queue Job |
| Authorization language | "only if admin", "requires permission" | Policy/Middleware |
| Relationship phrases | "belongs to", "has many", "associated with" | Model relationships |
| Integration mentions | Third-party services, external APIs | Service class + Job |

### Extraction rules for implicit tasks

PRDs consistently omit technical requirements that experienced developers know to include. The skill must detect and generate tasks for:

**Database layer gaps:**
- "Search by name" → Add index on name column task
- "Filter by status and date" → Composite index task
- "Unique email required" → Unique constraint migration
- "Delete user deletes orders" → Cascade foreign key task
- Any entity mention → Soft delete columns (default assumption)

**Error handling requirements:**
- Payment processing → Payment failure handling, retry logic tasks
- File upload → Size/type validation, storage failure handling
- External API calls → Timeout handling, circuit breaker implementation
- Form submission → Validation error response formatting

**Security requirements:**
- User data access → Ownership policy task
- Admin operations → Admin middleware/gate task
- Any API endpoint → Rate limiting task
- Sensitive data fields → Encryption at rest task

**Observability requirements:**
- Queue jobs → Failed job monitoring, Horizon configuration
- Critical operations → Audit logging task
- Performance NFRs → Query monitoring setup

### Handling PRD ambiguity

When PRDs lack specificity, apply these defaults:

| Ambiguous Area | Default Assumption |
|----------------|-------------------|
| Soft vs hard delete | Soft delete (add deleted_at) |
| Pagination | Yes, 15-25 items per page |
| Default sort order | created_at descending |
| Timestamps | Always include created_at, updated_at |
| User data ownership | Creator owns content |
| Status field type | Enum, not boolean (allows future states) |
| Error response format | RFC 7807 Problem Details |

---

## Laravel task types follow consistent structural patterns

Each Laravel component type has established patterns for task definition:

### Migration tasks

**Naming:** `{timestamp}_{action}_{table_name}_table.php`

**Task template:**
```markdown
### Task: Migration - Create orders table
**Type:** Migration (create_table)
**Size:** S
**File:** database/migrations/xxxx_create_orders_table.php

**Schema:**
- id: ulid, primary
- user_id: foreignId, constrained, cascadeOnDelete
- status: string, default 'pending'
- total_amount: decimal(10,2)
- timestamps(), softDeletes()

**Indexes:**
- Composite: (user_id, status) for user order queries
- Single: (created_at) for date filtering

**Zero-downtime:** Yes (additive only)
```

### Model tasks

**Task template:**
```markdown
### Task: Model - Order with relationships
**Type:** Model
**Size:** M
**File:** app/Models/Order.php

**Relationships:**
- belongsTo: User (user_id)
- hasMany: OrderItem (cascade soft delete)
- belongsToMany: Product (through order_items pivot)

**Scopes:**
- scopePending($query) - where status = 'pending'
- scopeForUser($query, $userId)

**Casts:**
- status: OrderStatus::class (enum)
- total_amount: 'decimal:2'
- metadata: 'array'

**Factory:** OrderFactory with states: pending, completed, cancelled
```

### Controller/API tasks

**Task template:**
```markdown
### Task: Controller - OrdersController CRUD API
**Type:** API Controller
**Size:** L
**File:** app/Http/Controllers/Api/V1/OrdersController.php

**Endpoints:**
| Method | URI | Action | Request | Response |
|--------|-----|--------|---------|----------|
| GET | /api/v1/orders | index | - | OrderCollection |
| POST | /api/v1/orders | store | StoreOrderRequest | OrderResource (201) |
| GET | /api/v1/orders/{order} | show | - | OrderResource |
| PUT | /api/v1/orders/{order} | update | UpdateOrderRequest | OrderResource |
| DELETE | /api/v1/orders/{order} | destroy | - | 204 |

**Authorization:** OrderPolicy for all actions
**Documentation:** Scramble auto-generated
```

### Job/Queue tasks

**Task template:**
```markdown
### Task: Job - ProcessOrderPayment
**Type:** Queued Job
**Size:** L
**File:** app/Jobs/ProcessOrderPayment.php
**Queue:** payments (high priority)

**Configuration:**
- tries: 3
- backoff: [10, 60, 300] seconds (exponential)
- timeout: 120 seconds
- unique: ShouldBeUnique by order_id for 1 hour

**Idempotency:**
- Check payment not already processed before charging
- Use idempotency key: "payment:{order_id}:{amount}"
- Store payment attempt before external API call

**Failure handling:**
- Log with context (order_id, amount, gateway_error)
- Notify admin after final failure
- Update order status to 'payment_failed'
```

### Action/Service class tasks

**When to use Actions:** Single business operation with side effects (notifications, events), orchestrating multiple steps, callable from controllers/jobs/commands.

**When to use Services:** Reusable logic without side effects, calculations, third-party API wrappers.

**Task template:**
```markdown
### Task: Action - CreateOrder
**Type:** Action Class
**Size:** M
**File:** app/Actions/Orders/CreateOrder.php

**Dependencies:** PricingService, InventoryService (injected)

**Handle method:**
```php
public function handle(CreateOrderDTO $data): Order
```

**Logic flow:**
1. Validate inventory availability
2. Calculate pricing with discounts
3. DB::transaction: Create Order + OrderItems, reserve inventory
4. Dispatch OrderCreatedEvent
5. Return Order

**Exceptions:** InsufficientInventoryException, InvalidDiscountCodeException
```

---

## Data model annotations belong inline with tasks

Each task involving database changes requires explicit schema documentation:

```yaml
## Data Model Notes
Table: orders
Columns:
  - id: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
  - user_id: BIGINT UNSIGNED NOT NULL (FK → users.id ON DELETE CASCADE)
  - external_id: VARCHAR(64) UNIQUE NOT NULL  # Idempotency key
  - status: ENUM('pending','processing','completed','failed')
  - total_amount: DECIMAL(10,2) NOT NULL
  - created_at, updated_at: TIMESTAMPS
  - deleted_at: TIMESTAMP NULL

Indexes:
  - PRIMARY: id
  - UNIQUE: external_id (idempotency)
  - INDEX: user_id (FK lookup)
  - COMPOSITE: (status, created_at) for filtered date queries

Constraints:
  - FK: user_id → users(id) ON DELETE CASCADE
  - CHECK: total_amount >= 0 (PostgreSQL only)
```

### Index strategy decision tree

```
Queried frequently?
├── YES → Primary key? → AUTO (Laravel handles)
│         └── NO → Unique? → UNIQUE INDEX
│                  └── NO → Used in WHERE + ORDER BY together?
│                           └── YES → COMPOSITE (filter cols first)
│                           └── NO → SINGLE COLUMN INDEX
└── NO → Don't add index
```

### Zero-downtime migration classification

| Change Type | Zero-Downtime? | Strategy |
|-------------|---------------|----------|
| Add nullable column | ✅ Yes | Direct DDL |
| Add NOT NULL column | ⚠️ Requires care | Add nullable → backfill → add constraint |
| Drop column | ⚠️ Requires care | Remove code references first → drop column |
| Rename column | ❌ No | Expand-contract: add new → dual-write → migrate → drop old |
| Change column type | ❌ No | Create new column, migrate data, drop old |
| Add index | ✅ Yes (online) | `CREATE INDEX CONCURRENTLY` (PostgreSQL) |

---

## Idempotency patterns prevent duplicate operations

Every task involving state mutation should specify idempotency requirements:

**Pattern 1: Database unique constraint + createOrFirst (Laravel 10+)**
```php
$order = Order::createOrFirst(
    ['external_id' => $request->idempotency_key],  // Lookup key
    ['user_id' => $user->id, 'total' => $total]    // Create values
);
```
Best for: High-concurrency internal operations with unique business keys.

**Pattern 2: Request-level idempotency with Redis caching**
```php
class IdempotencyMiddleware
{
    public function handle($request, Closure $next)
    {
        $key = $request->header('Idempotency-Key');
        $cacheKey = "idempotency:{$request->user()->id}:{$key}";
        
        if ($cached = Cache::get($cacheKey)) {
            return response()->json(json_decode($cached), 200)
                ->header('X-Idempotent-Replayed', 'true');
        }
        
        $response = $next($request);
        Cache::put($cacheKey, $response->getContent(), now()->addHours(24));
        return $response;
    }
}
```
Best for: Payment processing, critical API mutations.

**Task annotation template:**
```yaml
## Idempotency Requirements
Type: Database-Level | Request-Level | None
Key: external_id | Idempotency-Key header | composite
Storage: Database unique constraint | Redis cache (24h TTL) | Both
Duplicate handling: Return existing | Skip silently | Error 409
```

---

## Error taxonomy classifies handling requirements

Each task should document error scenarios with handling strategies:

| Category | HTTP Code | Retryable | Example |
|----------|-----------|-----------|---------|
| **Validation Error** | 422 | No | Missing required field, invalid format |
| **Authentication Error** | 401 | No | Invalid/expired token |
| **Authorization Error** | 403 | No | Insufficient permissions |
| **Not Found** | 404 | No | Resource doesn't exist |
| **Conflict** | 409 | No | Duplicate idempotency key |
| **Rate Limited** | 429 | Yes (with backoff) | Too many requests |
| **Transient Error** | 503/504 | Yes (with backoff) | Service unavailable, timeout |
| **Server Error** | 500 | Maybe | Internal error |

**RFC 7807 Problem Details format for Laravel:**
```php
throw new ApiException(
    type: 'https://api.example.com/errors/insufficient-funds',
    title: 'Insufficient Funds',
    status: 403,
    detail: 'Account balance is 30, but transaction requires 50.',
    extensions: ['balance' => 30, 'required' => 50]
);
```

**Task error annotation template:**
```yaml
## Error Scenarios
- Scenario: Payment gateway timeout
  Type: Transient
  HTTP: 504
  Handling: Retry 3x with exponential backoff [10s, 60s, 300s]
  Fallback: Queue for manual processing
  
- Scenario: Insufficient inventory
  Type: Business Rule Violation  
  HTTP: 422
  Handling: Rollback transaction, return specific error
```

---

## Dependencies determine task sequencing

### Dependency notation for markdown task lists

```markdown
## Sprint Tasks

### Epic: User Authentication
- [ ] **AUTH-1**: Design database schema [S] 
- [ ] **AUTH-2**: Implement User model [M] (blocked-by: AUTH-1)
- [ ] **AUTH-3**: Create registration endpoint [M] (blocked-by: AUTH-2)
- [ ] **AUTH-4**: Create login endpoint [M] (blocked-by: AUTH-2)
- [ ] **AUTH-5**: JWT token service [S] (parallel-with: AUTH-3, AUTH-4)
- [ ] **AUTH-6**: Integration tests [L] (blocked-by: AUTH-3, AUTH-4, AUTH-5)

**Dependency Legend:**
- `blocked-by:` = Hard dependency (cannot start)
- `needs:` = Soft dependency (can start, cannot complete)
- `parallel-with:` = Can run concurrently
```

### Critical path identification

For 2-4 developer teams in 1-2 week sprints:

1. **Map all blocking dependencies** as a directed graph
2. **Calculate duration** for each path (sum of T-shirt sizes converted to hours)
3. **Longest path = critical path**—delays here delay the sprint
4. **Mark critical tasks** with explicit priority

**Maximizing parallel work:**
- Assign independent vertical slices to different developers
- Define API contracts first so dependent work can proceed with mocks
- Use feature flags to merge incomplete features safely
- Limit WIP to 2-3 items per developer

---

## T-shirt sizing follows backend-specific benchmarks

| Size | Duration | Complexity Signals | Backend Examples |
|------|----------|-------------------|------------------|
| **XS** | 1-2 hours | Single file, no new logic | Config update, error message fix |
| **S** | 2-4 hours | Single component, well-understood | Add field to model, simple validation |
| **M** | 4-8 hours | Multiple components, some unknowns | New API endpoint with auth, query optimization |
| **L** | 2-3 days | Cross-cutting, integration points | Feature with multiple models, external API |
| **XL** | 4-5 days | High complexity, significant unknowns | New auth system, major refactor |
| **XXL** | >1 week | **Must decompose** | Complete subsystem |

### Size escalation factors

| Factor | +Size | Example |
|--------|-------|---------|
| Each new database model | +S | User + Profile + Address = base + 2S |
| External API integration | +M | Payment gateway = base + M |
| Complex business rules | +M | Multi-tier pricing logic |
| Test coverage requirements | +S | >80% coverage mandate |
| Unknown legacy code | +M to +L | Undocumented Slim 3 module |

### Decomposition triggers

Flag XL/XXL tasks for splitting when:
- Task spans more than one sprint
- Involves more than 3 database tables
- Requires coordination with more than 2 external systems
- Contains more than 5 acceptance criteria
- Description exceeds 500 words
- Team estimates vary by more than 2 sizes

---

## Quality validation prevents common breakdowns failures

### Completeness checklist

```markdown
## Task Breakdown Validation

### Coverage
- [ ] Every PRD requirement maps to ≥1 task
- [ ] All CRUD operations covered per entity
- [ ] Error handling tasks exist per integration point
- [ ] Auth/authz requirements have explicit tasks
- [ ] Logging and monitoring tasks included
- [ ] Test tasks exist for each feature

### Structure
- [ ] No task exceeds XL size
- [ ] Each task has testable acceptance criteria
- [ ] Dependencies explicitly documented
- [ ] All tasks have size estimates
- [ ] Each task assignable to single developer

### Technical
- [ ] Migration tasks specify up/down methods
- [ ] Index strategy documented for queries
- [ ] Idempotency requirements stated for mutations
- [ ] Error scenarios listed per task
- [ ] Queue configuration specified for async work
```

### Anti-pattern detection rules

| Anti-Pattern | Detection Signal | Resolution |
|--------------|------------------|------------|
| **Too granular** | >30 tasks per feature, avg <XS | Combine into meaningful units |
| **Too coarse** | Single task spans days, vague scope | Apply decomposition strategies |
| **Missing error handling** | Only happy path tasks | Add explicit error task per integration |
| **No test tasks** | "Testing included" without explicit tasks | Create separate unit/feature/integration test tasks |
| **Missing migrations** | Model tasks without schema tasks | Add explicit migration tasks |
| **Orphan tasks** | Tasks without PRD requirement linkage | Ensure traceability or remove |
| **Hero tasks** | Complex task assigned to single person | Split or require pair programming |

### Definition of Done for backend tasks

```markdown
## Definition of Done: Backend Task

### Code Quality
- [ ] Compiles without errors/warnings
- [ ] Passes linting (Pint/PHP-CS-Fixer)
- [ ] Follows team coding standards
- [ ] Self-documenting or adequately commented

### Testing  
- [ ] Unit tests passing (>80% coverage for new code)
- [ ] Feature tests passing
- [ ] No regression in existing tests

### Review
- [ ] Code reviewed by ≥1 team member
- [ ] Review comments addressed

### Documentation
- [ ] API docs updated (Scramble regenerated)
- [ ] README updated if setup changes

### Deployment
- [ ] Migrations tested (up and down)
- [ ] Deployed to staging
- [ ] Smoke tests passing
```

---

## Real-world examples demonstrate practical patterns

### Example 1: Jacob Kaplan-Moss streak tracker decomposition

The iterative refinement approach from a Django developer building a personal project demonstrates how tasks evolve through multiple passes:

**Iteration 1 (too vague):** "Streak tracking app"
**Iteration 2 (clearer):** "Weekly calendar showing activities, streak calculation, freeze system"
**Iteration 3 (implementable):**
```
1. Model the data:
   1.1 activity types: hardcoded list
   1.2 recorded activities: date, type
   1.3 freezes: date earned, date spent
   1.4 streaks: date started, date ended, stats

2. Static calendar view:
   2.1 Weekly view: shows days, activities
   2.2 Index: shows current week
   2.3 Monthly view: whole month overview
   
3. Streak calculation:
   3.1 Walk activity history, calculate stats
   3.2 Display in UI
   3.3 Recalculate on new activity
```

**Key insight:** Tasks are "sufficiently defined" when you can answer: Is the change understood? Is "done" clear? Can all steps be listed? Are dependencies known?

### Example 2: Laravel e-commerce task structure

```markdown
## Feature: Order Management

### Database Layer
- [ ] Migration - Create orders table (S)
- [ ] Migration - Create order_items table (S)  
- [ ] Migration - Create order_product pivot (XS)
- [ ] Model - Order with relationships (M)
- [ ] Model - OrderItem with product relationship (S)

### Business Logic
- [ ] Action - CreateOrder with inventory validation (L)
- [ ] Action - CancelOrder with refund logic (M)
- [ ] Service - OrderPricingService (M)
- [ ] Job - ProcessOrderPayment (L)

### API Layer
- [ ] Controller - OrdersController CRUD (L)
- [ ] FormRequest - StoreOrderRequest (S)
- [ ] FormRequest - UpdateOrderRequest (S)
- [ ] Resource - OrderResource (S)
- [ ] Resource - OrderCollection with pagination (S)

### Testing
- [ ] Feature Test - OrdersController (M)
- [ ] Unit Test - CreateOrder action (M)
- [ ] Unit Test - OrderPricingService (S)
```

### Example 3: Fintech backend with security-first ordering

```markdown
## Week 1: Foundation
- [ ] Threat model customer flow end-to-end
- [ ] Define security requirements document
- [ ] Identify critical technical assumptions

## Week 2: Core Infrastructure  
- [ ] Schema and API contracts
- [ ] Idempotent command handlers
- [ ] Queue setup for transaction processing

## Week 3: Security Layer
- [ ] Wire managed KMS for encryption
- [ ] Implement tokenization for PII
- [ ] Configure audit event logging

## Week 4: Feature Implementation
- [ ] Payment service (isolated)
- [ ] Risk checks service (separated)
- [ ] Customer data service
```

### Example 4: GitHub Copilot implementation plan format

```markdown
---
goal: User Authentication API
version: 1.0
status: Planned
tags: [feature, backend, auth]
---

## Requirements & Constraints
- **REQ-001**: JWT-based authentication
- **SEC-001**: Bcrypt password hashing (cost ≥ 10)
- **CON-001**: PHP 8.2 / Laravel 10 only
- **PAT-001**: Action classes for business logic

## Implementation Phase 1 - Database & Models
| Task | Description | Completed |
|------|-------------|-----------|
| TASK-001 | Create users migration | |
| TASK-002 | Implement User model | |

## Implementation Phase 2 - Auth Logic  
| Task | Description | Completed |
|------|-------------|-----------|
| TASK-003 | CreateUser action | |
| TASK-004 | AuthenticateUser action | |
```

---

## Tool integration enables automation

### Jira CSV import format

```csv
Summary,Description,Issue Type,Priority,Labels,Story Points,Parent
"Migration - Create orders table","Create database schema for orders","Task","High","backend,database",2,
"Model - Order with relationships","Implement Order model with User/OrderItem relationships","Task","High","backend,model",3,"Migration - Create orders table"
```

**Key rules:**
- Quote multi-line descriptions with double quotes
- Escape literal quotes with double quotes (`""`)
- Use semicolons for multiple labels within a field
- Parent field enables hierarchy

### Linear-compatible markdown

```markdown
- [ ] **AUTH-001** Migration - Create users table `[S]` #backend #database
- [ ] **AUTH-002** Model - User with relationships `[M]` #backend #model (blocked-by: AUTH-001)
```

### JSON export schema

```json
{
  "tasks": [{
    "id": "TASK-001",
    "title": "Migration - Create orders table",
    "type": "task",
    "size": "S",
    "priority": "high",
    "labels": ["backend", "database"],
    "dependencies": [],
    "acceptance_criteria": [
      "Orders table created with all columns",
      "Down migration drops table cleanly",
      "Indexes created for user_id, status"
    ],
    "data_model": {
      "table": "orders",
      "columns": ["id", "user_id", "status", "total_amount"],
      "indexes": ["idx_user_status"]
    }
  }]
}
```

---

## Legacy code requires explicit compatibility annotations

For Slim 3 / PHP 7.1 portions of the codebase:

```markdown
### [LEGACY-001] Refactor User Repository
**Compatibility Constraints:**
- 🔴 PHP 7.1 Required (no nullable types, no void return)
- 🔴 No Eloquent ORM - PDO/raw SQL only
- 🟡 Slim 3 Container DI pattern
- 🟢 Migration phase: PARALLEL

**Anti-Patterns to Avoid:**
- No type declarations requiring PHP 7.4+
- No arrow functions (PHP 7.4+)
- No named arguments (PHP 8.0+)
- No attributes (PHP 8.0+)

**Migration Path:**
1. Create interface in legacy codebase
2. Implement adapter in Laravel
3. Route through strangler façade
4. Test both paths
5. Cutover when metrics confirm stability
```

### Strangler fig pattern task template

```markdown
## Phase 1: Façade Setup
- [ ] FACADE-001: Deploy API Gateway/Reverse Proxy
- [ ] FACADE-002: Route 100% traffic through façade → legacy
- [ ] FACADE-003: Add request/response logging for baseline

## Phase 2: Extract Feature (Auth)
- [ ] EXTRACT-001: Implement new auth service in Laravel 10
- [ ] EXTRACT-002: Create anti-corruption layer
- [ ] EXTRACT-003: Route 10% traffic to new service (canary)
- [ ] EXTRACT-004: Monitor error rates, latency
- [ ] EXTRACT-005: Gradual rollout: 10% → 50% → 100%
- [ ] EXTRACT-006: Decommission legacy endpoint
```

---

## AI task generation requires validation guardrails

### Common LLM failure modes

| Failure Mode | Detection | Mitigation |
|--------------|-----------|------------|
| **Hallucinated dependencies** | Package doesn't exist in Packagist | Verify all composer packages |
| **Wrong granularity** | Tasks <1 hour or >5 days | Enforce 2-8 hour range |
| **Missing edge cases** | Only happy path criteria | Require error handling in AC |
| **Version mismatch** | PHP 8+ syntax for 7.1 target | Validate syntax against target |
| **N+1 query patterns** | No eager loading specified | Require relationship loading notes |
| **Missing observability** | No logging/metrics tasks | Enforce logging task per feature |

### AI prompt template for task generation

```markdown
You are a senior backend engineer breaking down a PRD into Laravel tasks.

**Context:**
- Framework: Laravel 10 (80%), Slim 3/PHP 7.1 (20% legacy)
- Task size: 2-8 hours each (S/M/L t-shirt sizing)
- Output: Jira/Linear compatible markdown

**PRD Section:**
{paste_prd_section}

**Generate for each task:**
1. ID & Title: [AREA-NNN] Descriptive title
2. Type: story | task | bug
3. Size: S (2-4h) | M (4-8h) | L (2-3d)
4. Description: 2-3 sentences
5. Acceptance Criteria: 3-5 testable bullets
6. Technical Notes: files to modify, patterns to use
7. Dependencies: other task IDs
8. Data Model Notes: tables, columns, indexes (if relevant)
9. Error Scenarios: what can fail, how to handle
10. Idempotency: required? what key?

**Rules:**
- Include error handling in acceptance criteria
- Specify N+1 prevention for database tasks
- Add security task for user input handling
- Include test task for each feature task
- Mark legacy-compatible tasks explicitly
```

---

## Observability tasks complete production readiness

### SRE golden signals as task requirements

```markdown
## Observability Tasks for [Feature]

### Logging (Required)
- [ ] OBS-001: Structured JSON logging
  - Levels: DEBUG, INFO, WARN, ERROR
  - Fields: request_id, user_id, timestamp, duration_ms
  - PII: masked/excluded

### Metrics (Required for critical paths)
- [ ] OBS-002: Prometheus metrics export
  - http_requests_total (counter)
  - http_request_duration_seconds (histogram)
  - db_query_duration_seconds (histogram)

### Alerting (Required for SLO-bound features)
- [ ] OBS-003: Alert rules
  - CRITICAL: Error rate >1% for 5 minutes
  - WARNING: p95 latency >500ms for 10 minutes
```

### Security checklist integration

```markdown
### [API-001] User Login Endpoint
**Security Requirements:**
- 🔒 Rate limit: 5 requests/minute per IP
- 🔒 Input validation: email (RFC 5322), password (8-128 chars)
- 🔒 Timing-safe comparison
- 🔒 Log failed attempts (without password)
- 🔒 Account lockout after 5 failures
- 🔒 Regenerate session on success
```

---

## Master task template consolidates all requirements

```markdown
### Task: [Type] - [Descriptive Name]

**ID:** [AREA-NNN]
**Type:** Migration | Model | Controller | Job | Action | Service | Test
**Size:** S | M | L | XL
**Priority:** P0 | P1 | P2
**File(s):** [Full file paths]
**Dependencies:** [Task IDs this blocks on]

**Description:**
[1-2 sentences explaining what this accomplishes and why]

**Acceptance Criteria:**
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]
- [ ] [Error case handled]

**Data Model Notes:** (if applicable)
```yaml
Table: table_name
Columns: [list with types]
Indexes: [list with columns]
Constraints: [FK, unique, check]
```

**Idempotency:** (if applicable)
- Type: Database | Request-level | None
- Key: [field or header]
- Duplicate handling: [return existing | error 409]

**Error Scenarios:**
| Scenario | HTTP | Handling |
|----------|------|----------|
| [Error] | [Code] | [Strategy] |

**Reliability Notes:**
- Queue config: [queue name, tries, backoff]
- Circuit breaker: [for external calls]
- Transaction: [scope if needed]

**Security Checklist:** (if user input involved)
- [ ] Input validation
- [ ] Authorization check
- [ ] Rate limiting

**Test Requirements:**
- [ ] Unit test for [component]
- [ ] Feature test for [endpoint]
```

---

## Conclusion

Building the `backend-task-breakdown` skill requires encoding three categories of knowledge: **industry methodology** (INVEST, vertical slicing, Shape Up's bounded scope), **Laravel conventions** (task types mapping to framework components with consistent naming), and **implicit requirements detection** (indexes, error handling, security, observability that PRDs omit).

The most critical implementation insights: vertical slicing produces independently shippable tasks while horizontal slicing creates blocking dependencies; every mutation task needs explicit idempotency annotation; T-shirt sizes only calibrate correctly when the team agrees on concrete examples for each size; and AI-generated tasks require validation against known failure modes (hallucinated packages, missing error handling, wrong PHP version syntax).

The skill should output markdown that humans can read and project management tools can import—the universal format is checkbox lists with inline metadata (`[Size]`, `#labels`, `(blocked-by: ID)`) that Jira/Linear parsers recognize. Quality gates should reject breakdowns missing test tasks, error scenarios, or observability requirements for production-bound features.