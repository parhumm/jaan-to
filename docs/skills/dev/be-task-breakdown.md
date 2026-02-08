---
title: "dev-be-task-breakdown"
sidebar_position: 4
---

# /jaan-to:dev-be-task-breakdown

> Convert PRDs into structured backend development tasks with data model notes, reliability patterns, and error taxonomy.

---

## What It Does

Transforms a PRD into a comprehensive backend task breakdown with:
- **Entity extraction** - Nouns → models, verbs → controllers, temporal → jobs
- **Implicit task detection** - DB indexes, error handling, security, observability
- **Master task cards** - Each task includes: data model notes, idempotency patterns, error scenarios, reliability notes
- **Dependency mapping** - Critical path, parallel tracks, blocked-by chains
- **Framework adaptation** - Reads tech.md to adapt for Laravel, Django, FastAPI, etc.
- **3 export formats** - Jira CSV, Linear markdown, JSON

Uses vertical slicing by default (user-facing features, not technical layers).

---

## Usage

```bash
/jaan-to:dev-be-task-breakdown "path/to/prd.md"
```

Or with a feature description:
```bash
/jaan-to:dev-be-task-breakdown "User can subscribe to premium features"
```

Or with a tech plan (from upstream skill):
```bash
/jaan-to:dev-be-task-breakdown "path/to/tech-plan.md"
```

---

## What It Asks

| Question | Why |
|----------|-----|
| **Slicing strategy** | Vertical (features) or horizontal (layers)? |
| **Team size** | Calibrates T-shirt sizes (2-dev vs 8-dev team) |
| **API conventions** | REST/JSON, GraphQL, gRPC? |
| **Delete strategy** | Hard delete or soft delete? |
| **Legacy constraints** | Mixing old and new tech stacks? |

Then shows a **HARD STOP** with:
- Entity map (models, relationships, task count)
- Task list preview (ID, type, size, dependencies)
- Implicit tasks detected
- Critical path
- XXL task warnings (if any need decomposition)

---

## Output

**Path:** `$JAAN_OUTPUTS_DIR/dev/backend/{slug}/task-breakdown.md`

**Structure:**
- Overview table (metrics)
- Tech stack (imported from tech.md)
- Entity map
- Task cards (full breakdown with 8+ sections each)
- Dependency graph
- Critical path analysis
- Implicit tasks (auto-detected)
- Ambiguity defaults applied
- 3 export formats (Jira CSV, Linear MD, JSON)
- Validation summary
- Definition of Ready/Done

**Task Card Template:**
Each task includes:
1. ID, Type, Size, Priority, Files, Dependencies
2. Acceptance Criteria (3-5 testable bullets)
3. Data Model Notes (table, columns, indexes, constraints)
4. Idempotency (type, key, storage, duplicate handling)
5. Error Scenarios (scenario → HTTP code → handling)
6. Reliability Notes (queue config, retries, circuit breaker)
7. Security Checklist
8. Test Requirements

---

## Example

**Input:**
```bash
/jaan-to:dev-be-task-breakdown "$JAAN_OUTPUTS_DIR/pm/user-subscriptions/prd.md"
```

**Extracts:**
- Entities: User, Subscription, Plan, Payment
- Actions: create subscription, cancel subscription, upgrade plan
- Jobs: Process payment, send welcome email, sync to billing system
- Policies: User can only cancel own subscription

**Generates:**
- 12 vertical-slice tasks
- 4 implicit tasks (indexes, error handling, audit logs, monitoring)
- Critical path: 7 tasks (sequential)
- Parallel tracks: 5 tasks (can run concurrently)
- T-shirt sizes: 2 XS, 6 S, 3 M, 1 L
- Estimated duration: 3-4 sprints (2-week sprints, 2-dev team)

**Output:** `$JAAN_OUTPUTS_DIR/dev/backend/user-subscriptions/task-breakdown.md`

---

## Tips

- **Read tech.md first** - Framework determines task templates (Laravel ≠ Django)
- **Vertical slicing wins** - "Add subscription" (migration + model + controller + tests) beats "Create all migrations"
- **Implicit tasks matter** - PRDs forget indexes, error handling, security
- **HARD STOP is critical** - Catching entity extraction mistakes early saves hours
- **Use tech plan upstream** - `/jaan-to:dev-tech-plan` → this skill = better task breakdown
- **Export all 3 formats** - Costs nothing, saves time when switching project trackers
- **Watch for XXL warnings** - Tasks >800 LOC should be decomposed

---

## Related

- [/jaan-to:dev-fe-task-breakdown](../dev/fe-task-breakdown.md) - Frontend counterpart
- [/jaan-to:pm-prd-write](../pm/prd-write.md) - Upstream: PRD generation
- [/jaan-to:pm-story-write](../pm/story-write.md) - Upstream: User stories
- [Tech Stack Context](../../config/context-system.md) - How tech.md works
