# Lessons: backend-task-breakdown

> Last updated: 2026-02-03

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:backend-task-breakdown.learn.md`

Seeded from research: $JAAN_OUTPUTS_DIR/research/52-dev-be-task-breakdown.md

---

## Better Questions

Questions to ask during information gathering:

- Ask about team size and sprint duration early — T-shirt sizes need calibration (2-dev vs 8-dev team)
- Ask about existing API conventions before assuming REST/JSON — could be GraphQL, gRPC
- Ask about deployment strategy (blue-green, canary) — affects zero-downtime migration classification
- Ask "which entities are shared across bounded contexts?" — detects cross-service dependencies
- Ask about existing auth middleware/patterns before generating new Policy tasks
- Confirm idempotency requirements explicitly for payment and financial operations
- Ask about existing test patterns (factories, seeders) to match team conventions

## Edge Cases

Special cases to check and handle:

- PRDs describing UI features with no explicit backend requirements — infer API needs from UI actions
- Legacy codebase mixing: when tech.md shows both modern and legacy stacks, add compatibility annotations
- Multi-tenant systems: every query needs tenant scoping, add as implicit task
- PRDs with "real-time" language — detect and add WebSocket/broadcasting tasks
- Soft delete cascade: when parent uses soft delete, children may need SoftDeletingScope
- External API integrations always need: timeout handling, circuit breaker, retry logic (3 implicit tasks minimum)
- Migration ordering: foreign key migrations must run after referenced table migrations
- Feature flags: when PRD mentions gradual rollout, add feature flag infrastructure task

## Workflow

Process improvements:

- Read tech.md FIRST — framework determines all task templates and file paths
- Extract entities BEFORE asking questions — show user what you found, ask about what's ambiguous
- Apply vertical slicing by default — only switch to horizontal when user explicitly requests
- Generate dependency graph BEFORE sizing — dependencies affect size estimates
- Run anti-pattern detection BEFORE HARD STOP — catch issues early
- Include test tasks inline with each feature task (not as a separate group)
- Always generate all three export formats (Jira CSV, Linear MD, JSON) regardless of user preference
- Mark critical path tasks with priority P0 automatically

## Common Mistakes

Things to avoid:

- Don't generate tasks for frontend/UI work — this is a backend-only skill
- Don't assume Laravel — always check tech.md first (could be FastAPI, Django, Express, etc.)
- Don't create horizontal slices (separate migration/model/controller tasks) as default — use vertical
- Don't skip idempotency annotations for mutation endpoints — every POST/PUT/DELETE needs one
- Don't omit the "down" migration description — rollback capability is required
- Don't size migration-only tasks as M or L — standalone migrations are S unless complex data backfill
- Don't generate generic error handling — each integration point needs specific error scenarios
- Don't create >30 tasks for a single PRD without suggesting feature-area chunking
- Don't assume all entities need CRUD — some are read-only (lookups, configs)
- Don't forget queue configuration for async tasks (queue name, tries, backoff, timeout)
- Don't generate tasks without file paths — every task must list exact files to create/modify
- Don't flag PRD ambiguity as errors — apply sensible defaults (soft delete, pagination, timestamps) and document them
