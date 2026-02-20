# backend-api-contract Reference

> Reference material for the `backend-api-contract` skill. See `skills/backend-api-contract/SKILL.md` for the main workflow.

---

## Schema Design Patterns

### Base Schemas (always included)

- `Timestamps` — created_at, updated_at (allOf composition base)
- `ProblemDetails` — RFC 9457 error response
- `ValidationProblemDetails` — extends ProblemDetails with errors array
- `PaginationMeta` — cursor, has_more, limit (if pagination enabled)

### Per-Resource Schemas (naming convention)

- `{Resource}` — Full resource with all fields
- `{Resource}Create` — No id/timestamps, required fields for creation
- `{Resource}Update` — All optional fields for PATCH
- `{Resource}Response` — allOf Resource + Timestamps (single item response)
- `{Resource}List` — Paginated list wrapper

### Shared Components

- `components/parameters` — CursorParam, LimitParam, path IDs
- `components/responses` — BadRequest, Unauthorized, Forbidden, NotFound, Conflict, ValidationError, TooManyRequests, InternalError
- `components/examples` — Named examples per operation scenario

### Design Rules (from research)

- Flat `components/schemas` — never deep inline, always `$ref`
- Null handling — `type: ["string", "null"]` (never `nullable: true`)
- Composition — `allOf` for extending base schemas, `oneOf` for alternatives with discriminator only when needed for code generation
- JSON Schema 2020-12 — `const` instead of single-value enum, `contentMediaType` for binary

---

## Generation Rules

### Schema Rules

- Every schema has `description`
- Properties have `type`, `format` (where applicable), `example`
- String properties with validation: `minLength`, `maxLength`, `pattern`
- Integer properties with bounds: `minimum`, `maximum`
- Enums use `enum` array with `description` per value where helpful
- Null handling: `type: ["string", "null"]` — never use `nullable: true`
- Composition: `allOf` to extend Timestamps, `oneOf` for polymorphic types

### Operation Rules

- Every operation has `operationId` (unique, camelCase: `listUsers`, `createUser`)
- Every operation has `summary` (short) and `description` (detailed)
- Every operation has `tags` array (resource name)
- Request body: `application/json` with `$ref` to Create/Update schema
- Success responses: body with `$ref` to Response schema
- Error responses: `application/problem+json` with `$ref` to ProblemDetails

### Status Codes per Operation Type

- GET (list): 200 → PaginatedList, 401, 403, 429, 500
- GET (single): 200 → Response, 401, 403, 404, 429, 500
- POST (create): 201 → Response + Location header, 400, 401, 403, 409, 422, 429, 500
- PATCH (update): 200 → Response, 400, 401, 403, 404, 409, 422, 429, 500
- DELETE: 204, 401, 403, 404, 429, 500

### Example Rules

- Named media type `examples` (plural) on each operation response
- Organized by scenario: `{resource}-{scenario}` (e.g., `user-success`, `user-not-found`)
- Property-level `example` on every schema property as baseline
- Examples must validate against their schemas

### Pagination Format (if enabled)

- List endpoints accept `cursor` (optional string) and `limit` (integer, default 20, max 100) query params
- Response wraps data in `{ data: [...], pagination: { cursor, has_more, limit } }`

---

## Companion Markdown Structure

**Executive Summary** — 1-2 sentences describing what this API does

**Authentication** — How to authenticate, security schemes, scopes (if OAuth2)

**Quick Start** — 3-5 cURL examples showing common operations:
```bash
# List users
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/v1/users

# Create a user
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "name": "Jane Doe"}' \
  https://api.example.com/v1/users
```

**Pagination** — How cursor-based pagination works, example flow

**Error Handling** — RFC 9457 format explanation, example error response:
```json
{
  "type": "https://api.example.com/errors/validation",
  "status": 422,
  "title": "Validation Error",
  "detail": "Request body contains invalid fields",
  "errors": [
    { "detail": "must be a valid email", "pointer": "/email" }
  ]
}
```

**Resources** — Table of all endpoints:
| Method | Path | Operation | Description |
|--------|------|-----------|-------------|
| GET | /v1/users | listUsers | List all users |
| POST | /v1/users | createUser | Create a new user |

**Validation & Tooling** — Commands for downstream use:
```bash
# Lint the spec
npx @stoplight/spectral-cli lint api.yaml
npx @redocly/cli lint api.yaml

# Start mock server
npx @stoplight/prism-cli mock api.yaml

# Generate TypeScript client
npx orval --input api.yaml --output ./src/api/

# Run contract tests
schemathesis run --url http://localhost:4010 api.yaml
```

**Metadata** table: Generated date, skill name, version, status

---

## Quality Checklist

### Structural (OpenAPI 3.1)

- [ ] `openapi: 3.1.0` declared
- [ ] `info` has title, version, description
- [ ] All `$ref` paths resolve to defined components
- [ ] Flat `components/schemas` — no deeply nested inline schemas
- [ ] No `nullable: true` anywhere (use `type` arrays)
- [ ] Every operation has unique `operationId`
- [ ] Every operation has `summary` and `tags`

### Error Handling

- [ ] `ProblemDetails` schema follows RFC 9457
- [ ] `ValidationProblemDetails` extends with `errors` array
- [ ] Error responses use `application/problem+json` media type
- [ ] All operations have appropriate error responses

### Completeness

- [ ] All requested resources have CRUD operations
- [ ] Security scheme defined and applied globally
- [ ] Named examples on every operation response
- [ ] Pagination on all list endpoints (if pagination enabled)
- [ ] Executive Summary in companion markdown

If any check fails, fix before preview.
