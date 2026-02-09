# Building a production-ready OpenAPI 3.1 contract generator

**The "backend:api-contract" skill must master eight interlocking domains to generate production-quality OpenAPI 3.1 YAML.** This report distills findings from 40+ authoritative sources — official specs, tool documentation, major API references, and academic research — into actionable patterns for each domain. The core insight: OpenAPI 3.1's full JSON Schema 2020-12 alignment unlocks powerful schema capabilities (`if/then/else`, `prefixItems`, `$dynamicRef`), but tool support remains uneven, making validation pipelines and carefully structured generation guardrails essential.

---

## 1. Schema design patterns that scale

OpenAPI 3.1's alignment with JSON Schema Draft 2020-12 is the single most important architectural change from 3.0. The Schema Object now supports the complete JSON Schema vocabulary, meaning every keyword from Draft 2020-12 is valid.

**`$ref` strategy: flat component libraries beat deep nesting.** The OpenAPI Initiative's official best practices state: "If the same piece of YAML or JSON appears more than once in the document, it's time to move it to `components`." liblab's analysis of hundreds of production specs confirms that deeply nested inline schemas produce unreadable specs and poor code generation output — generators infer names from parent nodes, producing unfriendly identifiers. The recommended pattern is a **flat `components/schemas` library** with descriptive names, referenced throughout via `$ref: "#/components/schemas/ModelName"`. Cross-document references (`$ref: ./models/User.yaml`) enable multi-file organization following the natural URL hierarchy.

**Reusable components span four categories.** Beyond `components/schemas`, production specs should define shared `components/responses` (e.g., `NotFoundResponse`, `ValidationError`), `components/parameters` (pagination params like `page`, `limit`, `cursor`), and `components/examples` (named scenario examples referenced via `$ref`). The Stripe API spec demonstrates this at massive scale with hundreds of shared schemas and vendor extensions like `x-expandableFields`.

**Polymorphism: `oneOf`/`anyOf`/`allOf` with or without discriminator.** Phil Sturgeon's November 2024 analysis on Bump.sh argues that **the discriminator is "generally redundant and confusing"** — it does not affect validation and only serves as a hint for tooling optimization. JSON Schema's `const` keyword handles the same use case natively: a `type` property with `const: "dog"` acts as an inherent discriminator. The main legitimate use for the `discriminator` keyword is code generation optimization. When using discriminator, Redocly's documentation specifies that it must be used with `anyOf`/`oneOf`/`allOf`, the discriminated property must be `type: string`, inline schemas are ignored (only `$ref` works), and explicit `mapping` is recommended.

**Composition vs inheritance follows clear rules.** Use `allOf` to compose schemas (combine properties from multiple schemas). Use `oneOf` for mutually exclusive alternatives (exactly one must match). Use `anyOf` for overlapping unions (one or more may match). The `allOf` + discriminator pattern models classical inheritance where a base `Vehicle` schema discriminates into `ElectricVehicle` or `FueledVehicle` subtypes.

**JSON Schema 2020-12 features now available in 3.1** include conditional schemas (`if`/`then`/`else` for context-dependent validation like payment methods), `prefixItems` for tuple validation, `$dynamicRef`/`$dynamicAnchor` for extensible base entities, `const` as a single-value enum replacement, and `contentEncoding`/`contentMediaType` replacing `format: binary` for file uploads. However, tool support for advanced features like `$dynamicRef` remains inconsistent — testing against specific toolchains is essential.

**Null handling changed fundamentally.** OpenAPI 3.0's `nullable: true` is completely removed (not deprecated) in 3.1. The replacement is **`type: ["string", "null"]`** using JSON Schema's type array syntax. Two approaches exist: the common pattern applies `format`/`maxLength` to the whole schema (used by GitHub's own 3.1 specs), while the technically precise approach uses `oneOf` to separate constraints for each type. SDK generators map this to `string | null` (TypeScript), `Optional[str]` (Python), or `*string` (Go).

**Pagination patterns split into two camps.** Offset-based pagination (`page` + `limit` parameters returning `total_pages` metadata) is simple but doesn't scale — databases must read offset+count rows, and results shift when data changes between requests. **Cursor-based pagination** (opaque `cursor` + `limit` returning `has_more` and `next_cursor`) offers consistent results and better performance at scale. Slack evolved through no pagination → offset → cursor-based, using sequential column IDs as cursors. Both patterns should be modeled as reusable `components/schemas/PaginationMeta` and `components/parameters/LimitParam`.

**Common anti-patterns to detect and prevent:** over-inlining schemas instead of using `$ref`, missing descriptions/examples/formats, invalid examples that don't conform to their own schemas, arrays for single-element properties, custom date formats instead of ISO 8601, exposing database schemas directly, missing `operationId` values, and mixing OAS 2/3 syntax. liblab notes that "most spec files are in varying degrees of incompletion."

---

## 2. Error responses built on RFC 9457

RFC 9457 (Problem Details for HTTP APIs, July 2023, authored by Nottingham, Wilde, and Dalal) obsoletes RFC 7807 and establishes the standard error format. **All five members are optional**, but together they form the canonical structure: `type` (URI identifying the problem type, defaults to `about:blank`), `status` (advisory HTTP status code), `title` (short human-readable summary that should not change between occurrences), `detail` (occurrence-specific explanation), and `instance` (URI identifying the specific occurrence). Extension members enable domain-specific data. The media type is **`application/problem+json`**.

**Validation errors require a dedicated schema.** RFC 9457 itself demonstrates the pattern with an `errors` array extension containing objects with `detail` (message) and `pointer` (JSON Pointer per RFC 6901 targeting the offending field). The recommended OpenAPI 3.1 approach uses `allOf` composition:

```yaml
ValidationProblemDetails:
  allOf:
    - $ref: '#/components/schemas/ProblemDetails'
    - type: object
      properties:
        errors:
          type: array
          items:
            type: object
            properties:
              detail: { type: string }
              pointer: { type: string }
            required: [detail, pointer]
```

**Real-world error formats vary significantly across major APIs.** Stripe wraps errors in an `error` envelope with `type` (enum: `api_error`, `card_error`, `invalid_request_error`), `code` (machine-readable like `parameter_missing`), `param` (field name), `message`, and `doc_url`. GitHub uses a flat `message` + optional `errors` array with `resource`, `field`, and `code` fields, using **422 for validation errors** (not 400). Google Cloud's AIP-193 defines a structured `error` object with numeric `code`, gRPC `status` name, and typed `details` array containing payloads like `ErrorInfo` (required on all errors), `BadRequest` with `fieldViolations`, and `Help` with documentation links. Twilio uses the simplest format: flat `status`, `message`, `code` (5-digit numeric), and `more_info` URL.

**Status code mapping determines which codes need dedicated schemas.** Validation errors (400/422) need field-level detail arrays. Authentication (401) and authorization (403) errors share the generic `ProblemDetails` schema. Not Found (404) benefits from including the resource type and ID. Conflict (409) may need the conflicting resource info. Rate limiting (429) should include `Retry-After` header information. Server errors (500-503) should expose minimal detail for security, always including a request ID. The `default` response in OpenAPI serves as a catch-all for undeclared codes.

**Shared responses belong in `components/responses`** referenced via `$ref`. Speakeasy's documentation emphasizes that RFC 9457 is not built into the OpenAPI specification — it must be manually defined as component schemas. Each operation must explicitly reference shared responses; they are not automatically applied.

---

## 3. Example generation that drives both docs and tests

OpenAPI has **three distinct example mechanisms** that work differently. Media Type `example` (singular) provides a single inline value next to the schema. Media Type `examples` (plural) is a map of named examples, each with a `value` key — documentation tools render these as selectable tabs. Schema-level `examples` (new in 3.1) is a bare JSON Schema array of values on individual properties. These are completely different structures despite sharing the keyword name.

**Named examples in `components/examples` enable reuse and scenario-based organization.** GitHub's spec uses descriptive names like `content-file-response-if-content-is-a-file` with `summary` and `description` fields. The `externalValue` keyword points to external JSON/YAML files for large examples. Best practice: use property-level `example` on each schema property as a baseline, then media type `examples` (plural) for complete request/response scenarios showing happy paths, edge cases, and polymorphic variants.

**Prism mock server consumes examples directly from the spec.** In static mode (default), `prism mock openapi.yaml` returns examples defined in the spec. In dynamic mode (`-d` flag), it uses Faker.js to generate randomized data conforming to schema constraints (`type`, `format`, `pattern`, `enum`, `minimum`, `maximum`). The **`Prefer` header** controls behavior: `Prefer: code=404` forces a specific status code, `Prefer: example=specific-name` selects a named example, and `Prefer: dynamic=true` forces dynamic generation per-request. Prism's **validation proxy mode** (`prism proxy openapi.yaml https://actual-api.com`) funnels live traffic and reports contract discrepancies — enabling contract testing in existing test suites with minimal effort.

**Examples serve as contract tests when they validate against their schemas.** APIMatic emphasizes that invalid examples (e.g., `minimum: 50` with `example: 10`) cause downstream tooling failures. The recommended structure: place complete request/response pairs as named media type examples, ensure all examples validate against their schemas, and use Prism's validation proxy to verify live API behavior matches the spec.

---

## 4. Versioning and deprecation modeled in contracts

**Three versioning strategies each model differently in OpenAPI.** URL path versioning (`/api/v1/users`) is the most visible and cache-friendly but creates version proliferation — modeled as separate spec files (`api-v1.yaml`, `api-v2.yaml`). Header versioning (`API-Version: 2.0` or `Accept: application/vnd.api.v2+json`) keeps URLs clean but is less discoverable — modeled as a header parameter in a single spec. Query param versioning (`?version=2`) is flexible but non-standard. Phil Sturgeon and APIs You Won't Hate advocate **API evolution** (single version, additive-only changes) over explicit versioning, noting that Stripe uses a hybrid approach with date-based versioning for major breaks (e.g., `v2024-01-15`).

**The `deprecated` flag applies at three levels in 3.1:** operation-level (`deprecated: true` on any path operation), parameter-level (on individual query/path/header parameters), and schema property-level (on individual object properties). Documentation tools automatically render deprecation badges, and SDK generators can produce compiler warnings. An open proposal (OAI issue #782) for `deprecatedVersion` and `replacementOperationId` hasn't landed yet but can be modeled via `x-` extensions.

**RFC 8594 defines the Sunset HTTP header** (`Sunset: Thu, 31 Dec 2025 23:59:59 GMT`) indicating when a URI will become unresponsive. A companion `Deprecation` header (draft RFC by Dalal and Wilde) signals the first stage. GitHub implements both headers in production with `Link` headers pointing to migration documentation. In OpenAPI, model these as response headers and use `x-sunset` extensions on operations. Client libraries like `faraday-sunset` (Ruby) and `guzzle-sunset` (PHP) detect and act on these headers automatically.

**Breaking change detection tools are CI/CD-essential.** oasdiff (Go-based, actively maintained) runs `oasdiff breaking base.yaml revision.yaml` to detect removed endpoints, changed types, new required fields, and removed enum values, outputting results as YAML, JSON, Markdown, HTML, JUnit XML, or GitHub Actions annotations. Its GitHub Action integrates directly into PR workflows. Optic (`@useoptic/optic`) takes a PR-based API review approach, exiting with code 1 on breaking changes.

---

## 5. AI generation guardrails that catch LLM mistakes

**LLMs make predictable, detectable errors when generating OpenAPI specs.** The most common failure modes, drawn from APIMatic's analysis and the AutoMCP paper's evaluation of 50 real-world APIs, include: broken `$ref` paths (referencing undefined schemas or using wrong path formats like `definitions/` instead of `components/schemas/`), missing required fields (`description` on Response objects is required but frequently omitted), hallucinated status codes, OAS version confusion (mixing Swagger 2.0 constructs like `consumes`/`produces` in 3.x), naming inconsistencies (mixed camelCase/snake_case), and security gaps (**62% of 900,000+ analyzed OpenAPI documents lack any security documentation**). An academic study found that LLM code completion performance "lags significantly" for OpenAPI compared to mainstream programming languages.

**Spectral and Redocly CLI form a complementary validation layer.** Spectral's `spectral:oas` ruleset includes 30+ rules catching structural errors: `oas3-unused-component` for orphaned schemas, `oas3-valid-media-example` for invalid examples, `operation-operationId-unique` for duplicate IDs, `path-params` for undefined path parameters, and `no-$ref-siblings` for invalid keywords next to `$ref`. Spectral uses JSONPath expressions and supports custom functions in JavaScript. Community rulesets exist from Adidas, Azure, Box, DigitalOcean, Zalando, and the **OWASP Security Ruleset** (`@stoplight/spectral-owasp-ruleset`) based on OWASP API Security Top 10 2023.

Redocly CLI uses a **type-tree traversal** approach (similar to programming language linters) rather than JSONPath, yielding major performance benefits — it lints a 1MB file in under 1 second. Unique rules with no Spectral equivalent include `no-unresolved-refs` (critical for AI-generated specs), `no-ambiguous-paths`, `no-http-verbs-in-paths`, `operation-4xx-problem-details-rfc7807`, `paths-kebab-case` (built-in vs custom in Spectral), `required-string-property-missing-min-length`, and `scalar-property-missing-range`.

**The recommended validation pipeline is lint → validate → mock test → contract test.** Spectral + Redocly handle linting and structural validation. Prism provides mock testing (start mock server, test against it) and validation proxy (compare live API responses against spec). Dredd sends real HTTP requests and validates status codes, response body schemas, content types, and headers. Redocly's newer **Respect** feature generates Arazzo test workflows from specs and runs contract tests automatically. Schemathesis adds property-based fuzzing.

**Prompt engineering dramatically improves generation quality.** A fine-tuned Code Llama model achieved **55.2% peak correctness improvement over GitHub Copilot** despite using 25x fewer parameters. Key strategies: always specify "Generate an OpenAPI 3.1 specification" explicitly, provide 2-3 complete validated endpoint definitions as few-shot examples, generate paths and schemas separately then assemble (reduces broken `$ref` paths), and implement a **feedback loop** where validation errors are fed back into the LLM prompt for iterative self-correction. Speakeasy's "Suggest" tool demonstrates this agent-based approach: validate → suggest → apply fix → revalidate.

---

## 6. Hybrid authoring with overlay-based enrichment

**Gap detection uses Spectral custom rules targeting completeness.** Rules can enforce that all operations have descriptions (`$.paths.*.*.description` → `truthy`), that error responses are documented (`$.paths.*.*.responses` must include `4XX`), that examples validate against schemas, and that security schemes are defined. Redocly's configurable rules add structural completeness checks with severity levels. Together, these tools can produce a quality "score" from structured JSON/SARIF output.

**The OpenAPI Overlay Specification v1.0.0** (released October 2024) is the official OAI standard for deterministic enrichment. It uses JSONPath (RFC 9535) to target spec nodes and applies `update` (recursive merge) or `remove` actions. The `update` field performs recursive merge — properties in the update object merge with matching properties in the target, new properties are added, and **existing properties not in the update are preserved**. This is the safest merge strategy for AI-generated enrichments. Tools supporting Overlays include Bump CLI, `openapi-overlays-js`, and Speakeasy's toolchain.

**Redocly Decorators provide an alternative enrichment mechanism** applied during the `bundle` process. Built-in decorators include `operation-description-override`, `media-type-examples-override`, `filter-in`/`filter-out` (for audience-specific variants), and `remove-unused-components`. Custom decorators via JavaScript plugins can target any part of the spec. The execution order is preprocessors → rules → decorators.

**Diff tools enable safe change management.** oasdiff's `changelog` command produces human-readable change logs, while `breaking` detects backwards-incompatible changes. It supports stability levels (draft/alpha/beta/stable) allowing breaking changes in early phases. OpenAPITools/openapi-diff (Java-based) offers HTML/Markdown diff reports with `--fail-on-incompatible` for CI gating. The pb33f openapi-changes tool provides a unique terminal UI "time machine" for exploring changes over time.

---

## 7. Reference specs and industry guidelines worth studying

**GitHub's REST API description is the gold standard for OpenAPI 3.1.** Available at `github/rest-api-description` on GitHub with 3.1 specs in the `/descriptions-next/` directory, it covers 600+ operations, uses 3.1's type arrays for nullable handling, supports webhooks (enabled by 3.1), and provides both bundled and dereferenced formats. Stripe's spec (`stripe/openapi` on GitHub) remains on 3.0 but is one of the most comprehensive public specs, demonstrating extensive polymorphism via `anyOf` and vendor extensions like `x-expandableFields` and `x-resourceId`. DigitalOcean (`digitalocean/openapi`) earned an "A" grade from API Evangelist for its well-structured multi-file organization.

**Three major company API guidelines serve as design references.** Google's API Improvement Proposals (google.aip.dev) define resource-oriented design with standard methods (Get, List, Create, Update, Delete) and structured error handling via AIP-193. Microsoft's REST API Guidelines (on GitHub) advocate design-first with TypeSpec for reusable patterns, covering error handling, long-running operations, and deprecation headers. **Zalando's RESTful API Guidelines** (opensource.zalando.com/restful-api-guidelines) champion "API First" as a key engineering principle, with extensive coverage of cursor-based pagination, naming conventions, and compatibility rules — enforceable via Spectral rulesets.

The APIs.guru OpenAPI Directory (apis.guru) is the largest collection of machine-readable API definitions with 4,353+ entries. The OAI's official examples repository includes 3.1-specific examples like `tictactoe`, `webhook-example`, and `non-oauth-scopes`. OpenAPI.tools (curated by Phil Sturgeon) aggregates the complete tooling ecosystem.

---

## 8. The validation tooling stack, assembled

Five tools form the complete contract validation pipeline:

- **Spectral** handles style and completeness linting with JSONPath-based custom rules, 30+ built-in OAS rules, community rulesets from major companies, and the OWASP security ruleset. Custom functions in JavaScript enable domain-specific checks. GitHub Action available for CI integration.

- **Redocly CLI** provides structural validation (faster than Spectral on large files), multi-file `$ref` resolution, `bundle`/`split`/`join` commands for spec management, decorators for pipeline-based enrichment, and the Respect contract testing system that auto-generates Arazzo test workflows.

- **Prism** delivers mock servers (static from examples, dynamic from schemas) and validation proxy mode for comparing live API traffic against the spec. The `Prefer` header controls response selection.

- **Schemathesis** adds property-based testing built on Python's Hypothesis library, automatically generating thousands of test cases from schemas. It supports stateful testing via OpenAPI links, runs with multiple workers, and is used by Spotify, WordPress, JetBrains, and Capital One. Production schemas typically surface **5-15 issues on first run**.

- **For code generation**, Orval dominates the TypeScript ecosystem (~630,000 weekly npm downloads vs openapi-generator's ~2,000) with end-to-end type safety, TanStack Query integration, MSW mock generation, and Zod schema output. openapi-generator covers 50+ languages for polyglot environments but produces lower-quality TypeScript output, particularly struggling with `anyOf` and `oneOf` constructs.

---

## Conclusion: patterns for the contract generator

The "backend:api-contract" skill should generate specs that follow a **flat `components/schemas` architecture** with `$ref` references throughout, RFC 9457 Problem Details as the base error schema extended with validation-specific `errors` arrays, named media type `examples` organized by scenario, and cursor-based pagination as the default pattern. Null handling must use `type: ["string", "null"]` exclusively — never `nullable: true`.

The generation pipeline should enforce a strict **validate-after-generate loop**: Spectral + Redocly lint → schema validation → Prism mock test → fix via feedback prompt. Few-shot prompting with validated examples and separate generation of paths vs schemas will minimize the predictable LLM failure modes (broken `$ref` paths, version syntax confusion, missing required `description` fields). The OpenAPI Overlay Specification provides the safest mechanism for enriching partial specs without overwriting manual edits. Breaking change detection via oasdiff should gate any spec modifications in CI.

The most actionable reference materials are GitHub's 3.1 spec (schema patterns), Google's AIP-193 (error taxonomy), Zalando's guidelines (design philosophy), and the OWASP Spectral ruleset (security baseline). OpenAPI 3.1's JSON Schema alignment is a generational improvement, but the skill must account for uneven tool support by testing generated specs against the specific downstream toolchain.