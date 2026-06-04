# The Perfect API Contract — OpenAPI/Swagger Best Practices, Anti-Patterns & Checklist

> A synthesized reference for designing, generating, and operating API contracts in an AI-driven workflow.
> Source: deep read of internal research summaries (59, 83, 84).

---

## The One Principle Everything Else Follows From

**The OpenAPI 3.1 spec is the single source of truth. Everything downstream is *generated* from it, never hand-written — and the generation only stays honest if the spec is validated on every change.**

"Swagger" today is an ecosystem, not a format. The format is **OpenAPI 3.1** (full JSON Schema 2020-12 alignment), and one `specs/openapi.yaml` should drive the entire stack:

```
specs/openapi.yaml  →  types (openapi-typescript / Orval)
                    →  typed hooks + Zod validators (Orval / @hey-api)
                    →  mock servers (Prism standalone, MSW in-app/Storybook)
                    →  interactive docs (Scalar)
                    →  contract tests (Schemathesis, Prism proxy, Dredd)
```

Two hard truths flow from this:

1. **Drift is the enemy.** The moment a type, mock, or client is hand-written instead of generated, it diverges from the contract. Hand-writing types when a spec exists is the single most common drift risk.
2. **AI generates predictable, detectable errors.** LLMs produce broken `$ref` paths, missing required `description` fields, hallucinated status codes, and OAS 2/3 syntax mixing. **62% of 900,000+ analyzed OpenAPI documents have no security documentation at all.** Without a validate-after-generate loop, these ship silently.

So the golden rule is: **Author the spec (with human review of the data model), then generate everything else and gate every change behind lint + validation.** The spec is the contract; the contract is the system.

For every artifact, apply this filter:

> **"Can this be generated from the spec?"** If yes → generate it, never hand-write it. **"Did the spec change?"** If yes → lint, validate, and regenerate before moving on.

---

## What to Include vs. Exclude

| ✅ Do (spec-first discipline) | ❌ Don't (drift & risk) |
|------------------------------|-------------------------|
| OpenAPI **3.1** as the format (`type: ["string","null"]`) | OpenAPI 3.0 `nullable: true` (removed, not deprecated, in 3.1) |
| Flat `components/schemas` library referenced via `$ref` | Deeply nested inline schemas (unreadable, bad codegen names) |
| Generate types/clients/mocks/docs from the spec | Hand-written types, clients, or mocks alongside a spec |
| RFC 9457 Problem Details for every 4xx/5xx | Ad-hoc, per-endpoint error shapes |
| Request/response **examples** in every schema | Schemas with no examples (breaks mocks + "Try it out") |
| Human-reviewed **data model** | Trusting AI-drafted entity relationships unverified |
| Scalar (modern renderer) + VS Code spec tooling | Swagger Codegen, swagger-cli, Swagger Editor (legacy/abandoned) |
| Docs served at a same-domain path (`/reference`) | Production docs exposed without auth (full recon map) |

---

## Recommended Structure

Split anything reused; keep the root spec as an index. The OpenAPI Initiative's rule: *"If the same piece of YAML appears more than once, move it to `components`."*

```
specs/
├── openapi.yaml              # index — references domain files via $ref
├── paths/
│   ├── tasks.yaml
│   └── users.yaml
└── components/
    ├── schemas/              # flat library: User, TaskCreateRequest, …
    ├── responses/            # NotFoundResponse, ValidationError (RFC 9457)
    ├── parameters/           # LimitParam, CursorParam (shared pagination)
    └── examples/             # named scenario examples, $ref'd into operations
```

**Four component categories** (not just schemas): `schemas`, `responses`, `parameters`, `examples`. Bundle multi-file specs at build time with `redocly bundle`.

**Naming conventions** (consistency lets AI and codegen predict identifiers):

| Element | Convention | Example |
|---------|-----------|---------|
| `operationId` | camelCase | `getUsers`, `createTask` |
| Tags | PascalCase plural | `Users`, `Tasks` |
| Schema names | PascalCase singular | `User`, `TaskCreateRequest` |
| Paths | kebab-case, no verbs | `/api/v1/task-lists` |

---

## Best Practices

### Schema design that scales
1. **Flat component library + `$ref` everywhere.** Descriptive names, no deep inline nesting. Generators infer names from parent nodes — nesting produces ugly identifiers.
2. **Composition by intent:** `allOf` to compose/extend, `oneOf` for mutually exclusive, `anyOf` for overlapping unions. The `discriminator` is "generally redundant and confusing" — JSON Schema's `const` is an inherent discriminator; reserve `discriminator` for codegen optimization.
3. **Null handling = `type: ["string", "null"]`.** Never `nullable: true` (gone in 3.1). Maps cleanly to `string | null`, `Optional[str]`, `*string`.
4. **Cursor-based pagination is the default** (opaque `cursor` + `limit` → `has_more`, `next_cursor`). Offset-based only for admin/small datasets. Model both as reusable `components`.

### Errors built on RFC 9457
5. **RFC 9457 Problem Details for every 4xx/5xx** — media type `application/problem+json`, fields `type`/`title`/`status`/`detail`/`instance`. It's *not* built into OpenAPI; define it as a base schema in `components/responses` and `$ref` it explicitly per operation.
6. **Validation errors extend the base** via `allOf` + an `errors` array (`detail` + JSON Pointer `pointer`). Use **422** for validation (GitHub's convention), 401/403 share the generic schema, 500s expose minimal detail + a request ID.

### Examples that drive docs *and* tests
7. **Every property gets an `example`; every operation gets named `examples`** (happy path, edge cases, polymorphic variants). They power mock data (Prism/Orval + Faker), "Try it out" prefill, and AI's understanding of payloads.
8. **Examples must validate against their own schemas** — an invalid example (`minimum: 50` with `example: 10`) breaks downstream tooling. Lint enforces this (`oas3-valid-media-example`).

### Versioning & deprecation
9. **URL path versioning (`/api/v1/…`)** is the most AI-discoverable and testable. Stripe-style date versioning for major breaks is the hybrid alternative; prefer additive-only "API evolution" where possible.
10. **Model deprecation in the contract** — `deprecated: true` (operation/parameter/property level), RFC 8594 `Sunset` header, `x-sunset` extensions. **Gate breaking changes in CI** with `oasdiff breaking` (or Optic).

### AI generation guardrails (the validate-after-generate loop)
11. **Pipeline: lint → validate → mock test → contract test.** Never trust a generated spec unvalidated.
    - **Spectral** (`spectral:oas` + OWASP ruleset `@stoplight/spectral-owasp-ruleset`) — style/completeness/security lint
    - **Redocly CLI** (`@redocly/cli lint`) — fast structural validation, multi-file `$ref` resolution, `no-unresolved-refs` (critical for AI specs)
    - **Prism** — mock server (static from examples, `-d` dynamic) + **validation proxy** (live traffic vs. spec)
    - **Schemathesis** — property-based fuzzing; production schemas surface **5–15 issues on first run**
12. **Generate paths and schemas separately, then assemble** — reduces broken `$ref` paths. Provide 2–3 validated endpoints as few-shot examples and **feed lint errors back into the prompt** for iterative self-correction.
13. **Enrich with Overlays, don't overwrite.** The OpenAPI Overlay Spec v1.0 (JSONPath `update`/`remove`, recursive merge preserving existing properties) is the safe way to layer AI enrichments onto a partial spec without clobbering manual edits.

### Tooling (the modern stack — Swagger ≠ Swagger anymore)
14. **Render with Scalar, not Swagger UI.** `@scalar/nextjs-api-reference` (~66 kB vs. Swagger UI's ~1.5–2 MB), dark-mode default, full API client + multi-language snippets. Microsoft made it the .NET 9 default. Keep `swagger-ui-express` only for backends that need it.
15. **Author in VS Code, not Swagger Editor.** 42Crunch (300+ security checks) + Spectral (lint-on-save) + Swagger Viewer (preview). When Claude authors the spec, the editor's job is validation/preview/refinement.
16. **Generate TypeScript with Orval or @hey-api, not Swagger Codegen/OpenAPI Generator.** Swagger Codegen has **no 3.1 support**; both Java tools produce verbose, "Java-flavored" output. Orval gives TanStack Query hooks + MSW mocks + Zod from one config; @hey-api adds a dedicated Next.js client and is the highest-downloaded TS generator (pin versions — pre-v1.0).

    | Need | Tool |
    |------|------|
    | Types only (zero runtime) | `openapi-typescript` |
    | Type-safe fetch client | `openapi-fetch` |
    | TanStack Query hooks + MSW mocks | **Orval** |
    | Zod + multi-client plugin ecosystem | **@hey-api/openapi-ts** |
    | Polyglot/enterprise SDKs (50+ langs) | `openapi-generator` |
    | MCP server from a spec | `openapi-mcp-generator`, Orval v8, FastMCP |

### Operations & the closed loop
17. **Validate on every change via a hook.** A `PostToolUse` hook running `@redocly/cli lint` + `orval` on spec edits keeps types/mocks regenerated automatically; a `PreToolUse` hook that **blocks edits to `generated/`** enforces spec-first discipline.
18. **Docs-as-code.** Keep `specs/` in git next to the app — no hosted platform (SmartBear API Hub adds little for solo/small teams). Serve docs at a same-domain path; never expose them unauthenticated in production.
19. **The complete loop:** spec → Orval (types + hooks + MSW mocks) → Scalar (interactive docs) → MSW intercepts "Try it out" → Playwright screenshots docs for visual regression. **Zero backend required** for frontend development.

---

## Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|--------------|-----|
| **Hand-writing types when a spec exists** | Diverges the moment an endpoint changes | Generate via `openapi-typescript`/Orval; block generated-file edits with a hook |
| **Editing generated files** | Overwritten on next `orval` run | Use Orval's mutator/override; never patch `generated/` |
| **Postman collection as source of truth** | Collections are tests, not contracts; lack schema precision | Spec is the contract — import spec *into* Postman, not the reverse |
| **Monolithic spec file (1000s of lines)** | Unreadable, slow tooling, bad codegen | Split via `$ref`; bundle with `redocly bundle` |
| **Skipping linting** | Missing descriptions, undocumented errors, naming drift | Spectral + Redocly in CI *and* Claude hooks |
| **No examples in schemas** | Breaks mock data + "Try it out" + AI comprehension | Add `example` to every property; named `examples` per operation |
| **Generating docs but never validating vs. implementation** | Docs drift from reality | Prism proxy / Schemathesis contract tests in CI |
| **Over-trusting AI data models** | Wrong entities/constraints/business logic ship | Human review of the data model is the one non-skippable step |
| **`nullable: true` in 3.1** | Removed from the spec; invalid | `type: ["string", "null"]` |
| **Swagger Codegen / swagger-cli / Swagger Editor** | No 3.1 support / abandoned / redundant | OpenAPI Generator → Orval/@hey-api; `@redocly/cli`; VS Code |
| **Docs exposed in prod without auth** | Full endpoint/schema/auth recon map for attackers | Gate by env/auth; serve internal-only if needed |
| **Too many MCP/codegen servers** | 15+ servers, 200+ tools = half the context window gone | Keep `.mcp.json` lean (~6); see [Perfect MCP](perfect-mcp.md) |

---

## The Checklist

**Contract & schema**
- [ ] Format is **OpenAPI 3.1**; nulls use `type: [..., "null"]`, never `nullable: true`
- [ ] **Flat `components/schemas`** library; everything reused is `$ref`'d, nothing deeply inlined
- [ ] Shared `responses`, `parameters`, `examples` factored into `components`
- [ ] Naming consistent (operationId camelCase, Tags PascalCase plural, Schemas PascalCase singular)
- [ ] Cursor-based pagination modeled as reusable components

**Errors, examples, versioning**
- [ ] **RFC 9457** Problem Details for every 4xx/5xx; validation errors extend it with an `errors` array
- [ ] Every property has an `example`; every operation has named `examples` that **validate against their schemas**
- [ ] Versioning strategy chosen (URL path default); `deprecated` + `Sunset` modeled in-contract
- [ ] Breaking changes gated in CI (`oasdiff breaking`)

**Generation & validation (the loop)**
- [ ] Types/clients/mocks/docs are **generated**, never hand-written
- [ ] Pipeline runs **lint → validate → mock test → contract test** (Spectral + Redocly + Prism + Schemathesis)
- [ ] OWASP Spectral ruleset enabled; security schemes applied to all authenticated endpoints
- [ ] Spec edits trigger a **validation hook**; edits to `generated/` are **blocked**
- [ ] Data model **reviewed by a human** before the spec becomes the contract

**Tooling & ops**
- [ ] Rendering via **Scalar**; authoring via VS Code (42Crunch + Spectral), not Swagger Editor
- [ ] TS codegen via **Orval / @hey-api**, not Swagger Codegen/OpenAPI Generator
- [ ] `specs/` committed to git (docs-as-code); no secrets in Postman collections
- [ ] Docs served same-domain; **never exposed unauthenticated in production**

---

## Tooling Reference

| Job | Use | Avoid |
|-----|-----|-------|
| **Render docs** | Scalar (`@scalar/nextjs-api-reference`) | Swagger UI as primary; Redoc OSS (no "Try it out") |
| **Author/edit** | VS Code: 42Crunch + Spectral + Swagger Viewer | Swagger Editor (redundant for AI workflows) |
| **Lint/validate** | Spectral + `@redocly/cli` | `swagger-cli` (abandoned → Redocly) |
| **TS codegen** | Orval (mocks) / @hey-api (Zod, Next.js) | Swagger Codegen (no 3.1); OpenAPI Generator for TS-only |
| **Mock** | Prism (standalone), MSW (in-app/Storybook) | Hand-written mocks |
| **Contract test** | Schemathesis (fuzz), Prism proxy, Dredd | "Try it out" as a test framework |
| **Breaking changes** | oasdiff, Optic | Manual diff review |
| **Spec → MCP** | openapi-mcp-generator, FastMCP, Orval v8 | — |

---

## TL;DR

A perfect API contract is **one OpenAPI 3.1 spec that drives everything.** Author it with a human reviewing the data model, factor reuse into a flat `components` library, standardize errors on RFC 9457, and put validating examples on every schema. Then *generate* types, clients, mocks, and docs — never hand-write what the spec can produce — and gate every change behind a lint → validate → mock → contract-test loop, with hooks that block edits to generated files. Render with Scalar, author in VS Code, generate with Orval/@hey-api, and keep `specs/` in git. The spec is the contract; the contract is the system — so every change has to pass through it.
