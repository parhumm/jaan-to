# Lessons: backend-service-implement

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:backend-service-implement.learn.md`

## Better Questions

- Ask which scaffold stubs are highest priority — users often want core CRUD before complex flows
- Clarify if auth is already implemented in the project — avoid generating duplicate auth services
- Ask about existing error handling conventions — some teams have custom error formats predating RFC 9457
- Check if the project uses a DI container (tsyringe, inversify) — adapt service pattern accordingly instead of forcing plain functions
- Ask about event/notification systems — side effects may need to integrate with existing message queues or event buses

## Edge Cases

- Scaffold may have TODO stubs that don't correspond to any API contract endpoint (custom internal endpoints) — implement from scaffold route context alone
- API contract may define endpoints not present in scaffold (spec ahead of code) — generate standalone service methods with integration notes
- Data model may have tables without corresponding API resources (audit logs, system tables) — skip unless referenced by business logic
- Multi-tenant systems need tenant_id scoping in EVERY query — the most common AI failure; always check for tenant isolation
- Prisma `findUniqueOrThrow` changed error codes between versions — verify P2025 is still the not-found code for the project's Prisma version
- Soft-delete tables need `WHERE deleted_at IS NULL` in all queries including uniqueness checks — generate a reusable `activeFilter` object

## Workflow

- Always generate shared helpers BEFORE service files — services depend on error-factory, pagination, etc.
- Parse all four input artifacts before asking clarifying questions — many questions are answered by cross-referencing sources
- Present the TODO coverage report early (Step 5) so users can verify scope before generation begins
- Generate one service at a time and validate against the API contract before moving to the next
- After all services are generated, do a final cross-service dependency check — ensure no circular imports

## Common Mistakes

- Generating `instanceof ZodError` checks instead of using Fastify's v6 `hasZodFastifySchemaValidationErrors()` helper
- Using Express-style error middleware (`app.use((err, req, res, next)`) instead of Fastify's `setErrorHandler`
- Putting side effects (notifications, emails) inside database transactions — always move outside
- Creating multiple PrismaClient instances instead of importing the singleton
- Forgetting `.js` extensions in ESM imports when `moduleResolution: "NodeNext"` is configured
- Using `nullable: true` in OpenAPI schemas instead of `type: ["string", "null"]` (OAS 3.1)
- Generating `moduleResolution: "bundler"` for backend projects (causes runtime import failures)
- Exposing raw Prisma/Eloquent models in API responses instead of mapping to DTOs
- Skipping authorization checks in service methods (not just route middleware)
- Using offset pagination for public API endpoints (unstable under concurrent writes)
