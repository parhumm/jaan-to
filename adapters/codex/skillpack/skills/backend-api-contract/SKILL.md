---
name: backend-api-contract
description: Generate OpenAPI 3.1 contracts with schemas, RFC 9457 errors, versioning, and examples. Use when defining API contracts from entities.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/api-contract/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [entities-or-prd-path]
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# backend-api-contract

> Generate production-quality OpenAPI 3.1 contracts from API resource entities.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#versioning`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to-backend-api-contract.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-backend-api-contract.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**API Entities**: $ARGUMENTS

Accepts any of:
- **Entity list** — Comma-separated resource names (e.g., "User, Post, Comment")
- **PRD reference** — Path to PRD file with API requirements
- **Database schema** — Path to DDL/migration file
- **Existing spec** — Path to existing OpenAPI file for enhancement

If no input provided, ask: "What API resources should be included?"

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `backend-api-contract`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for framework-specific patterns (versioning, auth, error format)

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_backend-api-contract`

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing input to extract API resource structure
- Mapping resource relationships and CRUD operations
- Designing schema composition strategy (flat components, $ref hierarchy)
- Planning endpoint structure, error handling, and pagination

## Step 1: Parse Input

Analyze the provided input to extract API resources:

**If entity list:**
1. Split comma-separated names
2. Infer resource types (collection, singleton, nested)
3. Note any implied relationships (e.g., "Comment" implies parent "Post")

**If PRD reference:**
1. Read the PRD file
2. Extract API-relevant user stories and acceptance criteria
3. Identify resources, operations, and data requirements
4. Note technical constraints mentioned

**If database schema:**
1. Read DDL/migration file
2. Extract tables, columns, types, constraints
3. Map foreign keys to resource relationships
4. Identify indexes that imply query patterns

**If existing spec:**
1. Read the OpenAPI file
2. Identify gaps (missing schemas, error responses, examples)
3. Offer enhancement vs. regeneration

Build initial understanding:
```
INPUT SUMMARY
─────────────
Type:        {input-type}
Resources:   {resources}
Relationships: {implied relationships}
Unknown:     {unclear areas}
```

## Step 2: Clarify API Design

Ask up to 6 smart questions based on what's unclear from Step 1. Skip questions already answered by the input or tech.md.

**Scope question** (ask if multiple resources):
1. Use AskUserQuestion:
   - Question: "Which resources should be included in this contract?"
   - Header: "Scope"
   - Options:
     - "All listed" — Generate contract for all identified resources
     - "Select specific" — Let me choose which resources to include
     - "Priority subset" — Start with core resources, add others later

**Design questions** (ask if not in tech.md):
2. Use AskUserQuestion:
   - Question: "Which API versioning strategy should be used?"
   - Header: "Versioning"
   - Options:
     - "URL path /v1/ (Recommended)" — Most visible, cache-friendly, separate spec per version
     - "Header (API-Version)" — Clean URLs, less discoverable
     - "No versioning" — API evolution with additive-only changes
     - "Date-based (Stripe style)" — e.g., v2024-01-15 for major breaks

3. Use AskUserQuestion:
   - Question: "What authentication method does this API use?"
   - Header: "Auth"
   - Options:
     - "OAuth2 + JWT (Recommended)" — Full OAuth2 flow with JWT tokens
     - "API Key" — Simple key in header or query param
     - "JWT Bearer only" — Direct JWT without OAuth2 flow
     - "None" — No authentication required

4. Use AskUserQuestion:
   - Question: "What level of detail should the contract include?"
   - Header: "Depth"
   - Options:
     - "Production (Recommended)" — Full schemas, validation rules, examples, all error codes
     - "MVP" — Core CRUD operations, basic schemas, minimal examples
     - "Framework only" — Schemas and components only, no paths

5. Use AskUserQuestion:
   - Question: "Which pagination strategy for list endpoints?"
   - Header: "Pagination"
   - Options:
     - "Cursor-based (Recommended)" — Consistent results, scalable, opaque cursor + has_more
     - "Offset-based" — Simple page + limit, less scalable
     - "None" — No pagination needed

**Ownership question** (always ask):
6. Use AskUserQuestion:
   - Question: "Who are the primary API consumers?"
   - Header: "Consumers"
   - Options:
     - "Internal frontends" — Web/mobile apps owned by same team
     - "Third-party developers" — External integrators, needs comprehensive docs
     - "Both" — Internal and external consumers
     - "Machine-to-machine" — Service-to-service, no human consumers

## Step 3: Resource Relationship Mapping

For each resource, determine:

| Attribute | Options | Example |
|-----------|---------|---------|
| **Type** | Collection / Singleton / Nested / Action | Collection |
| **Relationships** | 1:N / M:N / Polymorphic / None | User 1:N Posts |
| **CRUD** | Which HTTP methods needed | GET, POST, PATCH, DELETE |
| **Fields** | Name, type, constraints | email: string, format: email |
| **Nullable** | Which fields can be null | bio: ["string", "null"] |

Present resource map:
```
RESOURCE MAP
────────────
Resource: User
  Type:       Collection
  Fields:     id (uuid), email (email), name (string), role (enum), bio (nullable string), created_at, updated_at
  Relations:  1:N → Posts, 1:N → Comments
  Operations: List, Create, Read, Update, Delete
  Custom:     Verify email (POST /users/{id}/verify)

Resource: Post
  Type:       Collection (nested under User optional)
  Fields:     id (uuid), title (string), body (string), status (enum: draft/published), author_id (uuid)
  Relations:  N:1 → User, 1:N → Comments
  Operations: List, Create, Read, Update, Delete, Publish (action)
```

## Step 4: Schema Design Strategy

Plan the component architecture using research-informed patterns.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-api-contract-reference.md` — "Schema Design Patterns" for base schemas, per-resource schemas, shared components, and design rules.

Present schema plan:
```
SCHEMA PLAN
───────────
Base schemas:     {count} (Timestamps, ProblemDetails, ValidationProblemDetails, PaginationMeta)
Resource schemas: {count} ({Resource}, {Resource}Create, {Resource}Update, {Resource}Response, {Resource}List × N)
Shared params:    {count}
Shared responses: {count}
Named examples:   {count}
Total components: {total}
```

---

# HARD STOP — Review Contract Plan

```
API CONTRACT PLAN
═════════════════

RESOURCES ({count})
───────────────────
{resource1} ({op_count} ops)
{resource2} ({op_count} ops)
...

SCHEMAS ({count} total)
───────────────────────
Base:     {count} (Timestamps, ProblemDetails, ValidationProblemDetails, PaginationMeta)
Resource: {count} (5 per resource × {resource_count})
Shared:   {count} (params, responses, examples)

ENDPOINTS ({count} total)
─────────────────────────
Auth:       {strategy}
Versioning: {strategy}
Errors:     RFC 9457 Problem Details
Pagination: {strategy}
Consumers:  {audience}

STATUS CODES
────────────
Success: 200 (GET/PATCH), 201 (POST), 204 (DELETE)
Client:  400, 401, 403, 404, 409, 422, 429
Server:  500

OUTPUT
──────
Main:      api.yaml (OpenAPI 3.1)
Companion: {id}-{slug}.md (quick-start guide)
```

Use AskUserQuestion:
- Question: "Proceed with generating the OpenAPI 3.1 contract?"
- Header: "Generate"
- Options:
  - "Yes" — Generate the contract
  - "No" — Cancel
  - "Edit" — Let me revise the scope or design first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 5: Generate OpenAPI YAML

Read template: `$JAAN_TEMPLATES_DIR/jaan-to-backend-api-contract.template.md`

If tech stack needed, extract sections from tech.md:
- Current Stack: `#current-stack`
- Frameworks: `#frameworks`
- Constraints: `#constraints`
- Versioning: `#versioning`
- Patterns: `#patterns`

Generate the OpenAPI 3.1 YAML in this order (minimizes broken `$ref`):

1. **Header**: `openapi: 3.1.0`, `info` (title, version, description, contact, license), `servers`
2. **Tags**: One per resource, with description
3. **Components** (define before referencing):
   a. `securitySchemes` — Based on auth choice from Step 2
   b. `schemas` — Base schemas first (Timestamps, ProblemDetails, ValidationProblemDetails, PaginationMeta), then resource schemas in dependency order
   c. `parameters` — CursorParam, LimitParam, path ID params
   d. `responses` — Shared error responses referencing ProblemDetails schemas
   e. `examples` — Named examples per operation (happy path, edge cases)
4. **Paths**: All operations grouped by resource, referencing components via `$ref`
5. **Security**: Global security requirement

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-api-contract-reference.md` — "Generation Rules" for schema rules, operation rules, status codes per operation type, example rules, and pagination format.

## Step 6: Generate Companion Markdown

Generate a companion markdown guide covering: Executive Summary, Authentication, Quick Start (cURL examples), Pagination, Error Handling (RFC 9457), Resources endpoint table, Validation & Tooling commands, and Metadata.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-api-contract-reference.md` — "Companion Markdown Structure" for the full template with examples.

## Step 7: Quality Check

Before preview, verify all structural (OpenAPI 3.1), error handling, and completeness checks pass. If any check fails, fix before preview.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-api-contract-reference.md` — "Quality Checklist" for the full verification checklist.

## Step 8: Preview & Approval

Use AskUserQuestion:
- Question: "Write the contract files to output?"
- Header: "Write"
- Options:
  - "Yes" — Write both files
  - "No" — Cancel
  - "Edit" — Let me revise something first

## Step 8.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/backend/api-contract"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths (slug from API name)
slug="{lowercase-hyphenated-api-name}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/api.yaml"
COMPANION_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/backend/api-contract/{NEXT_ID}-{slug}/`
> - Main: `api.yaml`
> - Companion: `{NEXT_ID}-{slug}.md`

## Step 9: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write OpenAPI spec to `api.yaml`

3. Write companion guide to `{NEXT_ID}-{slug}.md`

4. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{API Title}" \
  "{executive-summary}"
```

5. Confirm completion:
> ✓ Contract written to: `$JAAN_OUTPUTS_DIR/backend/api-contract/{NEXT_ID}-{slug}/api.yaml`
> ✓ Guide written to: `$JAAN_OUTPUTS_DIR/backend/api-contract/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> ✓ Index updated: `$JAAN_OUTPUTS_DIR/backend/api-contract/README.md`

## Step 10: Suggest Next Steps

> "Contract generated. Suggested next steps:"
>
> 1. **Mock server**: `npx @stoplight/prism-cli mock api.yaml`
> 2. **Generate client SDK**: `npx orval --input api.yaml --output ./src/api/`
> 3. **Contract tests**: `schemathesis run api.yaml`
> 4. **Versioning plan**: `/jaan-to:backend-api-versioning`
> 5. **API documentation**: `/jaan-to:dev-docs-generate`

## Step 11: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the generated contract?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update something in the contract
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Update the output files, re-preview, re-write
- **Learn**: Run `/jaan-to:learn-add backend-api-contract "{feedback}"`
- **Both**: Do both

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] Input parsed, resources identified and confirmed
- [ ] API design decisions confirmed (versioning, auth, errors, pagination, consumers)
- [ ] Resource relationships mapped with fields and operations
- [ ] Schema hierarchy designed (flat components, $ref strategy)
- [ ] OpenAPI 3.1 YAML generated with all components and paths
- [ ] Companion markdown guide generated with Executive Summary
- [ ] Quality checks passed (structural, error handling, completeness)
- [ ] Output written to `$JAAN_OUTPUTS_DIR/backend/api-contract/{id}-{slug}/`
- [ ] Subdomain index updated
- [ ] User approved final result
