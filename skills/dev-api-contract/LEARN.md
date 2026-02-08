# Lessons: dev-api-contract

> Last updated: 2026-02-08

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:dev-api-contract.learn.md`

Accumulated lessons from past executions. Read this before executing to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during information gathering:

- Ask about existing OpenAPI specs before generating from scratch — enhancement is faster and preserves manual edits
- Ask about downstream consumers (mobile apps, web frontends, third-party integrations) — affects depth of examples and documentation
- Ask about breaking change tolerance and deprecation timeline — influences versioning strategy
- Ask if there are existing API guidelines or style guides the team follows (Google AIP, Zalando, custom)
- Ask about expected traffic patterns — affects rate limiting and pagination defaults

## Edge Cases

Special cases to check and handle:

- Polymorphic resources (e.g., PaymentMethod with card/bank subtypes) — use `oneOf` with discriminator only when needed for code generation
- File uploads (multipart/form-data with binary content) — use `contentMediaType` not `format: binary` in 3.1
- Long-running operations (async with status polling) — model as action endpoints with 202 Accepted
- Webhooks (event payloads, retry policies) — OpenAPI 3.1 supports `webhooks` top-level key
- Self-referencing schemas (e.g., Comment with replies) — use `$ref` to same schema

## Workflow

Process improvements:

- Generate `components/schemas` BEFORE `paths` to minimize broken `$ref` references
- Validate examples against schemas during generation — invalid examples cause downstream tooling failures
- Check `operationId` uniqueness across all paths before finalizing
- Use components-first generation order: securitySchemes → schemas → parameters → responses → examples → paths

## Common Mistakes

Things to avoid:

- Using `nullable: true` (OAS 3.0 construct, removed in 3.1) instead of `type: ["string", "null"]`
- Mixing Swagger 2.0 constructs (`consumes`/`produces`/`definitions`) in 3.x specs
- Missing `operationId` on operations — breaks code generation (Orval, openapi-generator)
- Deeply nested inline schemas instead of flat `$ref` components — produces unreadable specs and poor generated code
- Using `format: binary` instead of `contentMediaType`/`contentEncoding` (3.1 change)
- Missing `description` on Response objects (required by spec)
- Using `discriminator` unnecessarily — JSON Schema `const` handles the same use case natively
