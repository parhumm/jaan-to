# backend-service-implement — Reference Material

> Extracted reference tables, code templates, and patterns for the `backend-service-implement` skill.
> This file is loaded by `backend-service-implement` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Business Logic Derivation Patterns

**From HTTP Status Codes:**
- `201 Created` — creation logic, uniqueness checks, default value assignment
- `409 Conflict` — duplicate detection or state conflict checking
- `402 Payment Required` — payment gateway integration
- `429 Too Many Requests` — rate limiting logic

**From Request/Response Schema Differences:**
- Fields in response but not in request (e.g., `id`, `createdAt`) — server-generated values
- Fields in request but not in response (e.g., `idempotencyKey`) — processing-only inputs
- Optional fields with defaults — fallback logic

**From Endpoint Relationships:**
- POST + POST /{id}/confirm — state machine pattern
- GET ?status=pending — filterable list with business states
- DELETE + 404 — soft or hard delete policy

**From Task Breakdown:**
- Acceptance criteria encode validation rules
- Implementation notes encode architectural decisions
- Cross-cutting concerns (auth, audit, notifications)

## Helper Generation Patterns

### 6.1: Error Factory (RFC 9457)

Generate `error-factory.ts` with:
- `ProblemDetail` interface (type, title, status, detail, instance, extensions)
- `createProblemDetail()` factory function
- `BusinessError` class extending Error with ProblemDetail fields
- Error type registry derived from API contract error responses:
  ```typescript
  const PROBLEM_TYPES = {
    'validation-error':           { status: 400, title: 'Validation Failed' },
    'authentication-required':    { status: 401, title: 'Authentication Required' },
    'insufficient-permissions':   { status: 403, title: 'Insufficient Permissions' },
    'resource-not-found':         { status: 404, title: 'Not Found' },
    'unique-constraint-violation': { status: 409, title: 'Resource Already Exists' },
    'invalid-state-transition':   { status: 409, title: 'Invalid State Transition' },
    'rate-limit-exceeded':        { status: 429, title: 'Rate Limit Exceeded' },
    // ... derived from API contract error responses
  } as const;
  ```
- Prisma error mapper (P2002 → 409, P2003 → 409, P2025 → 404)
- Fastify `setErrorHandler` plugin (NOT Express-style middleware)
  - Use `hasZodFastifySchemaValidationErrors(error)` for 400 (NOT `instanceof ZodError`)
  - Use `isResponseSerializationError(error)` for 500
  - Always set `Content-Type: application/problem+json`

**PHP Stack:** Generate RFC 9457 via `crell/api-problem` v3.8.0
**Go Stack:** Generate custom `ProblemDetail` struct with `application/problem+json`

### 6.2: Pagination Helper

**If cursor-based:**
Generate `pagination.ts` + `cursor.ts` with:
- `CursorPaginationParams` interface (cursor, limit, direction)
- `CursorPaginatedResponse<T>` interface (data, pagination: {hasNextPage, hasPreviousPage, startCursor, endCursor})
- `paginateWithCursor()` — Prisma cursor API with `take: limit + 1` pattern
- `encodeCursor()` / `decodeCursor()` — base64url encoding for opaque cursors
- Default limit: 20, max: 100

**If offset-based:**
Generate `pagination.ts` with:
- `OffsetPaginationParams` (page, pageSize)
- `OffsetPaginatedResponse<T>` (data, pagination with totalCount/totalPages)
- `paginateWithOffset()` — Prisma skip/take with `$transaction` for count

**PHP Stack:** Use Laravel's built-in `->paginate()` / `->cursorPaginate()`
**Go Stack:** Generate pagination struct with sqlc query helpers

### 6.3: Auth Service (if applicable)

Generate `auth.service.ts` with `jose` library:
- `AuthTokenService` class:
  - `generateAccessToken(user)` — 15min TTL, HS256, includes sub/role/tid claims, jti for identification
  - `generateRefreshToken(user)` — 7d TTL, stored in DB for revocability
  - `verifyAccessToken(token)` — issuer/audience validation, 30s clock skew tolerance
  - `rotateRefreshToken(oldToken)` — revoke old, issue new pair, family revocation on reuse detection
  - `revokeAllUserTokens(userId)` — force logout
- Fastify auth hook plugin (decorateRequest, onRequest hook, Bearer extraction)
- Public route config support (`routeOptions.config?.public`)

**PHP Stack:** Use Laravel Sanctum or `lexik/jwt-authentication-bundle`
**Go Stack:** Use `golang-jwt/jwt/v5`

### 6.4: Idempotency Middleware (if enabled)

Generate `idempotency.ts` with:
- Fastify `preHandler` hook for POST/PUT methods
- `Idempotency-Key` header extraction
- Database-backed key storage (IdempotencyKey model)
- Same-request validation (method + path must match)
- In-flight concurrent request handling (409)
- `onSend` hook to store response
- 24h TTL with cleanup job
- `idempotency-replayed: true` header on cached responses

## Per-Method Implementation Patterns

**CREATE operations (POST → 201):**
1. Business rule validation (beyond schema validation)
2. Uniqueness checks (pre-check for better error messages, DB constraint as safety net)
3. Default value assignment (server-generated fields)
4. Transaction wrapping (if multi-step: inventory reservation, related records)
5. Prisma `create` with `include` for response data
6. Idempotency key storage (if enabled)
7. Post-transaction side effects (notifications, events) — OUTSIDE transaction
8. DTO mapping: internal model → API response

**READ operations (GET → 200):**
1. Authorization check (ownership, org-level access)
2. Prisma `findUniqueOrThrow` with `select` (prefer over `include` for specific fields)
3. Define reusable `select` objects per use-case (list view vs detail view)
4. DTO mapping

**LIST operations (GET → 200):**
1. Filter parameter extraction and validation
2. Pagination (cursor or offset per Step 4 choice)
3. Prisma `findMany` with composable where clauses
4. Use `Prisma.validator<>()` for type-safe query fragments
5. DTO mapping for each item

**UPDATE operations (PATCH → 200):**
1. Authorization check
2. Existence check (findUniqueOrThrow → 404)
3. Business rule validation
4. State transition validation (if status field, use state machine)
5. Optimistic concurrency (if version field: `where: { id, version }`, catch P2025)
6. Prisma `update` with `select`
7. DTO mapping

**DELETE operations (DELETE → 204):**
1. Authorization check
2. Existence check
3. Soft delete: `update({ data: { deletedAt: new Date() } })`
4. Hard delete: `delete()`
5. Cascade considerations (from data model FK constraints)

**ACTION operations (POST /{id}/action → 200):**
1. Authorization check
2. Existence check
3. State transition validation
4. Business logic execution (within transaction if multi-step)
5. Side effects (notifications, events)
6. DTO mapping

## State Machine Generation

For resources with status enum + transition endpoints:

```typescript
const TRANSITIONS: Record<Status, Status[]> = {
  pending:   ['confirmed', 'cancelled'],
  confirmed: ['shipped', 'cancelled'],
  shipped:   ['delivered', 'returned'],
  delivered: ['returned'],
  cancelled: [],
  returned:  [],
};

function validateTransition(current: Status, next: Status): void {
  if (!TRANSITIONS[current].includes(next)) {
    throw new BusinessError(
      'invalid-state-transition',
      `Cannot transition from ${current} to ${next}`,
      409,
      undefined,
      { current, next, allowed: TRANSITIONS[current] }
    );
  }
}
```

## Multi-Stack Service Patterns

**PHP Stack (Laravel):**
- Service classes with constructor injection + Eloquent models
- Form Requests for validation (`$request->validated()`, never `$request->all()`)
- API Resources for response transformation (never expose raw models)
- Eloquent scopes for composable query conditions
- `preventLazyLoading()`, `preventSilentlyDiscardingAttributes()` in `AppServiceProvider::boot()`
- RFC 9457 via `crell/api-problem` v3.8.0
- Sanctum for auth (SPA cookies + API tokens)
- DB::transaction for multi-step operations

**PHP Stack (Symfony):**
- Service classes with autowired constructor injection
- Doctrine EntityManager for data access (Data Mapper pattern)
- DTOs with `#[MapRequestPayload]` and Symfony Validator constraints
- API Platform v4.x for automatic CRUD operations
- JWT via `lexik/jwt-authentication-bundle` v3.2.0 with RS256

**Go Stack:**
- Feature-based `internal/` packages (`internal/user/service.go`)
- Constructor injection with small interfaces (1-3 methods) defined at consumer site
- Accept interfaces, return structs; wire manually in `main.go`
- sqlc for type-safe queries from annotated SQL
- go-playground/validator v10 for struct validation
- Custom `ProblemDetail` struct for RFC 9457
- `database/sql` transactions with `context.Context`

## Anti-Patterns

**All Stacks:**
- Business logic in route handlers
- Direct ORM calls in route handlers
- Hardcoded secrets
- Missing error handling
- Side effects inside transactions
- Exposing raw ORM models in API responses
- `any` types in TypeScript

**Node.js:**
- Multiple PrismaClient instances (use singleton)
- `instanceof ZodError` (use v6 helpers)
- Express-style error middleware (use Fastify's `setErrorHandler`)
- Missing `.js` extensions in ESM imports
- `moduleResolution: "bundler"` for backends

**PHP:**
- Fat controllers with business logic
- N+1 queries (use eager loading)
- `env()` outside config files
- `$request->all()` (use `$request->validated()`)

**Go:**
- Global database connections
- Ignoring errors
- Generic package names (`utils/`)
- Layer-based `internal/handlers/` structure

## Quality Check Checklist

**Coverage:**
- [ ] Every TODO stub from scaffold has a corresponding implementation
- [ ] Every API contract endpoint has service method coverage
- [ ] Every data model relationship is correctly queried

**Error Handling:**
- [ ] All services use RFC 9457 ProblemDetail format
- [ ] Prisma errors mapped (P2002 → 409, P2025 → 404)
- [ ] Business errors use error type registry
- [ ] `Content-Type: application/problem+json` set on all error responses

**Patterns:**
- [ ] No business logic in route handlers (only in service layer)
- [ ] No direct Prisma calls in route handlers
- [ ] Service methods do not reference `request`/`reply` objects
- [ ] Transactions keep side effects outside transaction boundary
- [ ] State machines validate transitions before applying

**Security:**
- [ ] Auth tokens validated on protected routes
- [ ] Authorization checks (ownership, org-level) in service methods
- [ ] No hardcoded secrets
- [ ] Refresh token rotation with family revocation (if auth generated)

**Code Quality:**
- [ ] TypeScript strict mode compatible (no `any` types)
- [ ] ESM imports with `.js` extensions (if Node.js + NodeNext)
- [ ] Reusable select objects for Prisma queries
- [ ] Type-safe query fragments via `Prisma.validator<>()`

## Key Generation Rules — Node.js/TypeScript (Research-Informed)

- **Service Layer**: Plain exported functions importing the Prisma singleton — module caching acts as built-in singleton, making DI containers (tsyringe, inversify) unnecessary; testable via `vi.mock()`; callable from CRON jobs or queue consumers outside HTTP context
- **Prisma Queries**: Use `select` over `include` when possible; define reusable select objects per use-case; use `Prisma.validator<>()` for composable, type-safe query fragments; leverage `$transaction` for multi-step operations
- **Error Handler**: Use Fastify's `setErrorHandler` (NOT Express-style middleware) — use `hasZodFastifySchemaValidationErrors(error)` for 400 (NOT `instanceof ZodError`), use `isResponseSerializationError(error)` for 500; map PrismaClientKnownRequestError P2002 → 409, P2003 → 409, P2025 → 404; always set `Content-Type: application/problem+json`
- **RFC 9457 Fields**: `type` (URI), `title`, `status`, `detail`, `instance`; extension `errors[]` for validation details
- **JWT with jose**: HS256, 15min access / 7d refresh, jti claims, refresh token rotation with family revocation, 30s clock skew tolerance, issuer + audience validation
- **Cursor Pagination**: Prisma cursor API with `take: limit + 1` pattern; base64url cursor encoding; default limit 20, max 100
- **Idempotency**: `Idempotency-Key` header, DB-backed storage, same-request validation, in-flight 409, 24h TTL, onSend response caching
- **Transactions**: Interactive `$transaction` with `maxWait: 5000`, `timeout: 10000`; side effects outside transaction; optimistic concurrency via `where: { id, version }` + catch P2025
- **Import Extensions**: With `"type": "module"` and `moduleResolution: "NodeNext"`, all imports MUST include `.js` extensions
- **DTO Mapping**: Always map internal models to API response format in service methods; never expose raw ORM models
