# Lessons: backend-scaffold

> Last updated: 2026-02-09

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-backend-scaffold.learn.md`

Seeded from research: $JAAN_OUTPUTS_DIR/research/63-dev-scaffolds.md

---

## Better Questions

Questions to ask during information gathering:

- Ask about idempotency key requirements for mutation endpoints — every POST/PUT/DELETE needs a strategy
- Ask about repository pattern vs direct ORM preference — some teams want the abstraction layer
- Ask about WebSocket vs SSE requirements — suggest SSE first (handles 95% of real-time use cases)
- Ask about relation loading strategies — eager vs lazy, depth limits, circular reference handling
- Ask about zero-downtime migration requirements — expand-contract pattern for schema changes

## Edge Cases

Special cases to check and handle:

- API contract endpoints without corresponding data model coverage — need to infer or ask
- Uncovered audit tables — many projects need audit logging but don't specify it in specs
- Middleware configuration gaps — auth, CORS, rate limiting not always explicit in upstream artifacts
- Prisma error codes: P2002 (unique constraint) → 409, P2003 (foreign key) → 409, P2025 (not found) → 404
- Zod type provider scoping across Fastify encapsulation boundaries — `withTypeProvider()` needed per context
- MySQL DDL limitations — no transactional DDL means migrations can leave partial state on failure
- Go connection pool sizing — `SetMaxOpenConns()` and `SetMaxIdleConns()` must be tuned per workload

## Workflow

Process improvements:

- Read tech.md FIRST — framework determines all code patterns, file extensions, and dependencies
- Follow input order: backend-api-contract → backend-data-model → backend-task-breakdown
- Suggest SSE before WebSocket for real-time requirements — simpler, works over HTTP, auto-reconnects

## Common Mistakes

Things to avoid:

- Generating wrong framework code (e.g., Fastify patterns when tech.md says Laravel)
- Express-style error middleware in Fastify — use `setErrorHandler` instead
- Multiple PrismaClient instances — use `globalThis` singleton pattern
- Exposing raw Eloquent models in API responses — always use API Resources
- N+1 queries — add eager loading with `with()` in Eloquent or `include` in Prisma
- `env()` calls outside config files in Laravel — only use in `config/*.php`
- Global database connections in Go — pass via constructor injection
- Missing `.js` extensions in ESM imports — causes `ERR_MODULE_NOT_FOUND` at runtime
- Using `instanceof ZodError` instead of `hasZodFastifySchemaValidationErrors` helper — fails across module boundaries
- Missing Eloquent strictness modes in `AppServiceProvider::boot()`
- `moduleResolution: "bundler"` for backend Node.js projects — allows vague imports that fail at runtime
