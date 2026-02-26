# Swagger tooling for AI-driven development with Claude Code

**Scalar has dethroned Swagger UI as the best API documentation renderer for modern Next.js projects**, offering native dark mode, first-class Next.js 15 integration via `@scalar/nextjs-api-reference`, and the most powerful interactive "Try it out" experience — all under an MIT license. For the jaan-to workflow, Scalar slots in as the API documentation counterpart to Storybook: where Storybook visually verifies UI components, Scalar visually verifies API contracts. Meanwhile, Swagger Editor has become irrelevant for AI-driven workflows — VS Code extensions combined with Claude Code provide a superior spec authoring experience. On the code generation front, **Swagger Codegen is effectively legacy**; the community has moved to OpenAPI Generator, Orval, and the fast-rising @hey-api/openapi-ts. This report covers every Swagger-adjacent tool gap, with practical configurations for integrating each into the jaan-to pipeline of Claude Code Skills, hooks, slash commands, Storybook 9, and shadcn/ui.

---

## Swagger UI still works, but Scalar is the modern choice

Swagger UI v5.31.2 remains the most widely deployed API documentation renderer, with **28.6k GitHub stars** and weekly downloads of `swagger-ui-dist` exceeding 5.8 million. It supports OpenAPI 2.0 through 3.1.2 and offers a plugin architecture built on React/Redux patterns. The "Try it out" feature makes real HTTP requests from the browser — which means CORS must be configured on the API server and security implications must be considered for production deployments.

For Next.js 15 App Router projects, `swagger-ui-react` requires a `'use client'` directive since it cannot be server-rendered. The component ships its own copies of React, Redux, and many dependencies, bloating the bundle to roughly **1.5–2MB minified**. Dynamic imports with `ssr: false` are essential to avoid shipping this on initial page load. Dark mode support landed in late 2025 via PR #10653, but it remains limited — only available in StandaloneLayout with no configuration option to default to dark mode, and CSS scoping issues can bleed into host applications.

**Scalar comprehensively outperforms Swagger UI for this stack.** With over **30,800 GitHub stars** (surpassing both Swagger UI and Redoc), Scalar offers a dedicated `@scalar/nextjs-api-reference` package at just 66.4 kB that works with Next.js 15 App Router out of the box. Dark mode is the default aesthetic — aligning perfectly with shadcn/ui's dark-mode-first philosophy. The "Try it out" functionality doubles as a full API client with multi-language code snippet generation (curl, JavaScript, Python, and more). Nine built-in themes (Moon, Purple, Solarized, BluePlanet, DeepSpace, Saturn, Kepler, Mars) plus custom CSS support make it trivial to match your design system. Microsoft endorsed Scalar for .NET 9, replacing Swagger UI as the default — a significant signal of industry direction.

Redoc occupies a different niche as a read-only, three-panel documentation renderer in the style of Stripe's API docs. The open-source version has **no interactive "Try it out"** capability; that feature requires the commercial Redocly Realm platform. Redoc's strength is SSR support and clean typography for reference documentation, but for an AI-driven workflow that needs interactivity, it falls short of both Swagger UI and Scalar.

### The practical setup: Scalar in Next.js 15

The simplest integration uses an API route handler:

```typescript
// app/reference/route.ts
import { ApiReference } from '@scalar/nextjs-api-reference'

const config = {
  url: '/api/openapi.json',
  theme: 'moon', // dark theme matching shadcn/ui
}

export const GET = ApiReference(config)
```

For more control, the React component approach works:

```tsx
'use client'
import { ApiReferenceReact } from '@scalar/api-reference-react'
import '@scalar/api-reference-react/style.css'

export default function References() {
  return (
    <ApiReferenceReact
      configuration={{
        url: '/api/openapi.json',
        theme: 'moon',
      }}
    />
  )
}
```

Serve the OpenAPI spec from a Next.js API route:

```typescript
// app/api/openapi/route.ts
import { NextResponse } from 'next/server'
import yaml from 'js-yaml'
import fs from 'fs'
import path from 'path'

export async function GET() {
  const filePath = path.join(process.cwd(), 'specs/openapi.yaml')
  const fileContent = fs.readFileSync(filePath, 'utf8')
  const spec = yaml.load(fileContent)
  return NextResponse.json(spec)
}
```

If Swagger UI is still needed (for familiarity or plugin system access), the pattern uses a client component wrapper:

```tsx
// app/api-docs/ReactSwagger.tsx
'use client'
import SwaggerUI from 'swagger-ui-react'
import 'swagger-ui-react/swagger-ui.css'

export default function ReactSwagger({ spec }: { spec: Record<string, any> }) {
  return <SwaggerUI spec={spec} supportedSubmitMethods={[]} /> // disabled Try-it-out for safety
}
```

### Head-to-head comparison

| Feature | Swagger UI | Redoc (OSS) | **Scalar** |
|---------|-----------|-------------|-----------|
| Bundle impact | ~1.5–2MB | ~800KB | ~66 kB (Next.js pkg) |
| "Try it out" | ✅ Real API calls | ❌ Read-only | ✅ Best — full API client + code snippets |
| Dark mode | Limited (late 2025) | Not native | **Default**, built-in |
| Next.js integration | Manual, `'use client'` only | Manual, `ssr: false` | `@scalar/nextjs-api-reference` |
| OpenAPI 3.1 | ✅ v5.19.0+ | ✅ | ✅ Full |
| Themes | CSS overrides | Theme object | **9 built-in + custom CSS** |
| Code snippets | ❌ | ❌ | ✅ Multi-language |
| License | Apache 2.0 | MIT | MIT |
| GitHub stars | ~28.6k | ~25.5k | **~30.8k** |

**Recommendation**: Use Scalar as the primary API documentation renderer. Keep `swagger-ui-express` for Express/Fastify backends that need it. Use Redocly CLI for spec linting and bundling in CI, not for rendering.

---

## VS Code extensions have replaced Swagger Editor for AI workflows

**Swagger Editor v5** shipped on December 5, 2025, rebuilt on the Monaco editor engine (the same engine behind VS Code). It supports OpenAPI 2.0, 3.0, 3.1, and AsyncAPI 2.x with real-time validation and intelligent autocompletion. The previous v4 is officially deprecated. Docker images are available at `docker.swagger.io/swaggerapi/swagger-editor:latest` mapping port 80 on the container.

However, in a Claude Code workflow where AI generates and modifies OpenAPI specs directly, the browser-based Swagger Editor becomes redundant. **VS Code extensions provide everything the editor does — plus Git integration, Spectral linting, security auditing, and direct AI interaction** — without leaving the IDE.

### The optimal VS Code extension stack

**42Crunch OpenAPI Editor** (`42Crunch.vscode-openapi`, 1.35M installs, v5.0.0) is the primary editing extension. It provides IntelliSense, code navigation via an OpenAPI Explorer tree view, live documentation preview in either Swagger UI or Redoc format, and a security audit with 300+ static checks. The "Try it" feature lets you invoke API operations directly from VS Code. It requires the Red Hat YAML extension as a dependency.

**Swagger Viewer** (`Arjun.swagger-viewer`, 930k installs, v3.2.0 released December 2025) recently received a major rewrite adding OpenAPI 3.1 support, automatic dark theme detection, remote development support, and hot reload for external `$ref` changes. It's best used as a complementary preview tool alongside 42Crunch.

**Spectral VS Code** (`stoplight.spectral`, 56k installs) provides lint-on-save or lint-on-type with custom ruleset support, aligning your IDE experience with CI/CD governance rules defined in `.spectral.yaml`.

**Redocly VS Code** (`Redocly.redocly-vs-code`) adds autocomplete sorted per OAS spec order, a cursor context panel with interactive visual editing, and preview capabilities (requires a free Redocly API key).

The recommended combination: **42Crunch for editing + Spectral for linting + Swagger Viewer for preview**. This gives you autocompletion, navigation, dual-renderer preview, security auditing, and custom governance rules — all within the IDE where Claude Code operates.

```json
// .vscode/extensions.json
{
  "recommendations": [
    "42Crunch.vscode-openapi",
    "stoplight.spectral",
    "Arjun.swagger-viewer",
    "redhat.vscode-yaml",
    "esbenp.prettier-vscode"
  ]
}
```

```json
// .vscode/settings.json
{
  "yaml.schemas": {
    "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json": [
      "specs/**/*.yaml",
      "specs/**/*.yml"
    ]
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
```

### The AI paradigm shift in spec authoring

When Claude Code is the primary author of OpenAPI specs, the editor's role transforms from authoring to **validation, preview, and refinement**. The practical workflow becomes: Claude Code generates or modifies `specs/openapi.yaml` → 42Crunch immediately validates in the Problems panel → Spectral rules flag style guide violations → the preview panel shows rendered documentation → you review and make minor tweaks with IntelliSense help → Git commit. A browser-based Swagger Editor adds nothing to this loop.

### Docker Compose for team environments

For teams that still want Swagger Editor alongside mock servers, this Docker Compose setup provides the full suite:

```yaml
version: '3.8'
services:
  swagger-editor:
    image: docker.swagger.io/swaggerapi/swagger-editor:latest
    ports:
      - "8081:80"
  swagger-ui:
    image: docker.swagger.io/swaggerapi/swagger-ui
    ports:
      - "8082:8080"
    environment:
      SWAGGER_JSON: /specs/openapi.yaml
    volumes:
      - ./specs:/specs
  prism-mock:
    image: stoplight/prism:4
    command: mock -h 0.0.0.0 /specs/openapi.yaml
    ports:
      - "4010:4010"
    volumes:
      - ./specs:/specs
```

---

## Code generation: Swagger Codegen is legacy, Orval and @hey-api lead

In May 2018, over 40 top contributors forked Swagger Codegen to create **OpenAPI Generator** after disagreements with SmartBear over the 3.0.0 beta's breaking changes, uncommented test cases, and unreviewed merges. The fork has decisively won the community: OpenAPI Generator has **25.8k stars** and 540+ contributors versus Swagger Codegen's 17.6k stars and moderate contributor base. Critically, **Swagger Codegen 3.x does not support OpenAPI 3.1** — a dealbreaker for modern specs.

Neither Swagger Codegen nor OpenAPI Generator produce idiomatic TypeScript for Next.js projects. Both require a Java runtime (JDK 11+), and their TypeScript output is verbose and "Java-flavored" with no native TanStack Query integration, no MSW mock generation, and no Zod schema support. For a TypeScript-only project, they are the wrong tools.

### The TypeScript code generation tier list

**Tier 1 — Orval** (already in use, 5.4k stars, 749k weekly npm downloads): Generates idiomatic TypeScript with built-in TanStack Query hooks, MSW mock handlers with Faker.js data, custom mutator patterns, and SWR support. The combination of type-safe clients plus auto-generated mocks from a single OpenAPI spec is its killer feature. No Java dependency — pure Node.js.

**Tier 1 — @hey-api/openapi-ts** (4.1k stars, **977k weekly npm downloads** — highest of all TypeScript generators, v0.93.0): The successor to `openapi-typescript-codegen`, used by Vercel, PayPal, and OpenCode. Offers a plugin architecture with 20+ plugins including a dedicated **Next.js HTTP client**, Zod v3/v4/mini validation schemas, TanStack Query hooks for React/Vue/Svelte/Solid/Angular, and tree-shakeable output. Explicitly AI-friendly — provides `/llms.txt` and `/llms-full.txt` for LLM-optimized documentation. Endorsed by Guillermo Rauch (Vercel CEO). Still pre-v1.0, so pin exact versions.

**Tier 2 — OpenAPI Generator** (25.8k stars, 600k weekly npm downloads for CLI): Best when multi-language support is needed (50+ languages). TypeScript output works but requires Java, produces verbose code, and lacks React Query or MSW integration. Use for polyglot projects, skip for TypeScript-only stacks.

**Tier 3 — Swagger Codegen** (17.6k stars): No OpenAPI 3.1 support. Slower release cadence. Uses Handlebars templates (3.x). Only relevant if deeply embedded in SmartBear's ecosystem. Not recommended for new projects.

| Feature | Swagger Codegen | OpenAPI Generator | Orval | @hey-api/openapi-ts |
|---------|----------------|-------------------|-------|---------------------|
| Runtime | Java | Java | **Node.js** | **Node.js** |
| OpenAPI 3.1 | ❌ | Partial | ✅ | ✅ Full |
| TanStack Query | ❌ | ❌ | ✅ Built-in | ✅ Plugin |
| MSW mocks | ❌ | ❌ | ✅ Built-in | ❌ |
| Zod schemas | ❌ | ❌ | ❌ | ✅ Plugin |
| Next.js client | ❌ | ❌ | Via mutator | ✅ Dedicated |
| npm weekly downloads | N/A (Java) | ~600k | ~749k | **~977k** |

**Recommendation**: Keep Orval as the primary generator for its MSW mock generation. Evaluate @hey-api/openapi-ts as a complementary or future replacement — its Zod plugin and dedicated Next.js client are compelling for the stack, and its LLM-friendly documentation makes it the best choice for AI-augmented development once it reaches v1.0.

---

## SwaggerHub, platforms, and the modern docs landscape

### SmartBear API Hub (formerly SwaggerHub) is skippable for most teams

SwaggerHub has been rebranded to **SmartBear API Hub** with pricing starting at $22.80/month for individuals and $34–85/user/month for teams. SmartBear acquired Stoplight in August 2023, absorbing its tools (Spectral, Prism, Elements) into the platform. SmartBear and Postman are separate, competing companies — not related by acquisition.

For AI-driven solo or small-team development, API Hub adds negligible value over free tools. When Claude Code writes specs directly in `specs/openapi.yaml` and Git handles version control, a hosted platform creates sync friction and ongoing costs without meaningful benefits. **The "docs as code" approach — specs versioned alongside application code — perfectly aligns with AI-first workflows where everything lives in the repository.**

API Hub becomes relevant only for enterprise teams needing centralized API catalogs, RBAC, SSO, and governance dashboards for non-developer stakeholders.

### Deprecated and sunset tools to avoid

**swagger-cli** (`@apidevtools/swagger-cli`): Officially **deprecated**. The npm package message reads: "This package has been abandoned. Please switch to using the actively maintained @redocly/cli." Last version 4.0.4 was published six years ago. Use **Redocly CLI** (`@redocly/cli`) for spec validation and bundling instead.

**Swagger Inspector**: **Sunset on September 29, 2023.** The free cloud-based API testing tool that could auto-generate OpenAPI definitions from tested API calls was replaced by SwaggerHub Explore.

**Stoplight Studio**: Effectively in **maintenance mode** post-SmartBear acquisition. Only low-stakes commits since August 2023. Don't adopt for new projects. Its open-source tools (Spectral, Prism) remain actively maintained independently.

**Stoplight Elements**: Development has slowed significantly. Still receives bug fixes but no major features. Not recommended for new projects — Scalar is the better React-based API docs component.

### The emerging platform landscape

**Bump.sh** ($50–250/month) stands out for one specific feature: **automatic API changelog generation** from spec diffs. It detects additions, modifications, deprecations, and breaking changes between spec versions, generates structured changelogs, and can block CI releases on breaking changes. The GitHub Action (`bump-sh/github-action@v1`) comments PR diffs automatically. Worth considering if API changelog tracking is a priority, but expensive for solo developers.

**Mintlify** (free–$300/month) is the AI-native documentation platform used by Anthropic, Perplexity, Cursor, and Vercel. It auto-generates MCP servers from documentation and produces `llms.txt` files for LLM consumption. However, its pricing is steep and API documentation is just one feature of a broader docs platform.

**Redocly** ($10–24/month for commercial features) offers the strongest CLI tooling: `redocly lint` for validation with configurable rulesets (compatible with Spectral rules), `redocly bundle` for resolving `$ref` references, `redocly split` for decomposing large specs, and `redocly preview` for local hot-reload documentation. Redocly Realm includes a built-in **MCP server** at the `/mcp` endpoint — the only API docs platform with native MCP support as of early 2026.

### MCP server availability across tools

| Tool | MCP Server | Details |
|------|-----------|---------|
| Redocly Realm | ✅ Built-in | `/mcp` endpoint with auth/RBAC |
| Mintlify | ✅ Generator | Auto-generates MCP servers + llms.txt |
| Scalar | Indirect | OpenAPI-first feeds into MCP generators |
| ReadMe | Partial | llms.txt support |
| Bump.sh | ❌ | No MCP integration |

For converting any OpenAPI spec to an MCP server, standalone tools like **openapi-mcp-generator** (TypeScript CLI), **FastMCP** (Python, `FastMCP.from_openapi()`), and **AWS Labs openapi-mcp-server** are available. These let Claude Code and other AI agents interact with documented APIs programmatically.

---

## Integrating into the jaan-to pipeline: Skills, hooks, and slash commands

The jaan-to architecture creates a natural parallel between Storybook and API documentation. Storybook at `localhost:6006` visually verifies UI component rendering; Scalar at `/reference` (or Swagger UI at `/api-docs`) visually verifies API contract documentation. Both consume a source-of-truth artifact (component code / OpenAPI spec) and produce an interactive verification environment. Together they form a complete dev portal.

### Claude Code Skill for API documentation

```markdown
<!-- .claude/skills/api-docs/SKILL.md -->
---
name: api-docs
description: >
  Manage OpenAPI API documentation. Use when creating, updating,
  or reviewing API specs, generating docs, or working with files
  in specs/ directory or any openapi.yaml file.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# API Documentation Skill

## Context
This project uses OpenAPI 3.1 specs at `specs/openapi.yaml` as the single
source of truth. API docs are served via Scalar at `/reference`.

## When Creating/Editing Specs
1. Follow OpenAPI 3.1 specification strictly
2. Always include: operationId, description, tags, request/response examples
3. Use `$ref` for reusable schemas in `specs/components/`
4. Validate after changes: `npx @redocly/cli lint specs/openapi.yaml`
5. Regenerate types: `npx orval`

## File Locations
- Main spec: `specs/openapi.yaml`
- Generated API client: `src/api/generated/`
- Scalar docs page: `app/reference/route.ts`
- MSW mock handlers: `src/mocks/handlers.ts`
- Orval config: `orval.config.ts`

## Naming Conventions
- operationId: camelCase (`getUsers`, `createTask`)
- Tags: PascalCase plural (`Users`, `Tasks`)
- Schema names: PascalCase singular (`User`, `TaskCreateRequest`)
- Always include example values in schemas

## After Spec Changes
Run `npx @redocly/cli lint specs/openapi.yaml && npx orval` to
validate and regenerate the typed API client and MSW mocks.
```

### Claude Code hook for automatic validation on spec changes

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-openapi.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/bin/bash
# .claude/hooks/validate-openapi.sh
FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *"openapi"* ]] || [[ "$FILE_PATH" == *"specs/"* ]]; then
  echo "🔍 OpenAPI spec changed: $FILE_PATH" >&2
  npx @redocly/cli lint "$FILE_PATH" 2>&1
  LINT_EXIT=$?
  if [ $LINT_EXIT -ne 0 ]; then
    echo "❌ OpenAPI validation failed" >&2
    exit 2  # Block and show message to Claude
  fi
  npx orval 2>&1
  echo "✅ Spec validated, API client and mocks regenerated" >&2
fi
exit 0
```

### Slash command for previewing API docs

```markdown
<!-- .claude/commands/preview-api-docs.md -->
---
description: Validate and preview API documentation changes
allowed-tools: Read, Bash, Grep, Glob, WebFetch
---

1. Validate the spec: `npx @redocly/cli lint specs/openapi.yaml`
2. Check endpoint count: `grep -c 'operationId' specs/openapi.yaml`
3. Check for missing descriptions: `npx @redocly/cli lint specs/openapi.yaml --format stylish 2>&1 | grep 'description'`
4. Report validation results, endpoint count, and any issues found.
5. If specific concerns were provided, address them: $ARGUMENTS
```

### Path-targeted rules for API files

```markdown
<!-- .claude/rules/api-specs.md -->
---
paths:
  - specs/**/*.yaml
  - specs/**/*.yml
---
# OpenAPI Specification Rules
- Follow OpenAPI 3.1 specification strictly
- Every operation must have operationId, description, tags, and examples
- Use $ref for all reusable schemas — never inline complex schemas
- Include error responses (400, 401, 403, 404, 500) for every endpoint
- Validate with `npx @redocly/cli lint` after every change
- Security schemes must be applied to all authenticated endpoints
```

### Swagger UI + Playwright visual testing

Playwright can screenshot API documentation pages for visual regression testing, mirroring how Storybook uses Chromatic:

```typescript
// tests/api-docs-visual.spec.ts
import { test, expect } from '@playwright/test'

test.describe('API Documentation Visual Regression', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/reference')
    await page.waitForLoadState('networkidle')
  })

  test('API docs page matches baseline', async ({ page }) => {
    await expect(page).toHaveScreenshot('api-docs-overview.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.05,
    })
  })
})
```

### The MSW + Swagger UI complete loop

When MSW is running in the browser and Swagger UI (or Scalar) renders the same spec, "Try it out" sends requests that MSW intercepts and returns mock data — **no backend required**. The `@msw/source/open-api` package generates handlers directly from the spec:

```typescript
import { fromOpenApi } from '@msw/source/open-api'
import spec from '../../specs/openapi.json'

export const handlers = await fromOpenApi(spec)
```

This creates the full cycle: OpenAPI spec → Orval generates typed client + MSW mocks → Scalar renders interactive docs → "Try it out" hits MSW handlers → realistic mock responses. The entire frontend development environment operates without a live backend.

### Embedding API docs in Storybook 9

Three approaches work, in order of recommendation:

**Iframe embed** (cleanest, avoids bundle bloat):
```mdx
{/* src/stories/ApiDocs.mdx */}
import { Meta } from '@storybook/blocks'
<Meta title="Documentation/API Reference" />
# API Reference
<iframe src="/reference" style={{ width: '100%', height: '800px', border: 'none' }} />
```

**Direct React component** (heavier, but inline):
```tsx
import { ApiReferenceReact } from '@scalar/api-reference-react'
import '@scalar/api-reference-react/style.css'

export default { title: 'Documentation/API Reference' }
export const Default = () => (
  <ApiReferenceReact configuration={{ url: '/api/openapi.json', theme: 'moon' }} />
)
```

**@storybook-extras/swagger addon** (experimental, uses swagger-ui-react internally).

---

## Ten anti-patterns that break API documentation workflows

**Exposing Swagger UI in production without authentication** is the most common and dangerous mistake. Rendered documentation reveals every endpoint, parameter, schema, and authentication mechanism — giving attackers a complete reconnaissance map. In Next.js, conditionally render based on environment: `if (process.env.NODE_ENV === 'production') return null`. If production docs are needed, protect with authentication middleware or restrict to VPN/internal network.

**Using Swagger Codegen when OpenAPI Generator is the maintained fork.** Swagger Codegen 3.x lacks OpenAPI 3.1 support, has fewer contributors, and slower release cycles. For any new project, OpenAPI Generator is the correct choice — though for TypeScript-only stacks, Orval or @hey-api/openapi-ts are better still.

**Using swagger-cli for validation.** The package is abandoned with a six-year-old last release. The npm page explicitly directs users to Redocly CLI. Use `npx @redocly/cli lint` instead.

**Relying on Swagger UI as the primary API testing tool.** It's documentation, not a testing framework. "Try it out" is useful for quick manual checks, but automated testing should use Playwright, Jest, or Schemathesis. Manual exploratory testing should use Postman or Scalar's standalone API client.

**Generating documentation but never validating it against the implementation.** Auto-generated docs drift from reality without contract testing. Add Prism proxy mode or Schemathesis to CI/CD to catch spec-implementation divergence.

**Shipping auto-generated docs without human-written descriptions.** Enforce meaningful descriptions via Spectral rules: `operation-description: error` in `.spectral.yml`. Every operation, parameter, and schema should have a human-readable description — even if Claude Code writes them.

**Massive monolithic spec files** exceeding thousands of lines. Use `$ref` to split schemas into `specs/components/schemas/`, paths into `specs/paths/`, and bundle at build time with `redocly bundle`.

**Hosting API docs on a separate domain** causes CORS issues with "Try it out" and fragments the developer experience. Serve docs at a path on the same domain — `/reference` or `/api-docs`.

**Not including request/response examples in specs.** Examples power mock data generation (Orval + Faker.js), "Try it out" prefilling, and AI understanding of expected payloads. Always include `example` values in schemas.

**Not updating the documentation renderer.** Swagger UI has had known XSS and DOM injection vulnerabilities in older versions. Swagger Viewer's v3.2.0 update specifically patched a critical XSS fix from Swagger UI v5.18.2. Pin to latest versions and update regularly.

---

## Conclusion

The Swagger tooling landscape has consolidated around a clear set of winners for AI-driven TypeScript development. **Scalar replaces Swagger UI** as the API documentation renderer — its Next.js 15 integration, dark-mode default, and interactive API client are purpose-built for the modern stack. **VS Code extensions replace Swagger Editor** — the 42Crunch + Spectral combination provides superior validation when Claude Code is the primary spec author. **Orval and @hey-api/openapi-ts replace Swagger Codegen and OpenAPI Generator** for TypeScript projects, eliminating the Java dependency while adding TanStack Query hooks, MSW mocks, and Zod schemas.

The jaan-to integration pattern treats API documentation as a parallel verification layer to Storybook. A Claude Code hook validates specs on every change, a Skill teaches Claude the project's API conventions, and a slash command previews documentation state. The complete data flow — `specs/openapi.yaml` → Orval (types + mocks) → Scalar (docs) → MSW ("Try it out") → Playwright (visual regression) — creates a zero-backend frontend development environment where the OpenAPI spec truly serves as the single source of truth.

Three tools worth watching: @hey-api/openapi-ts for its Zod plugin and Vercel endorsement once it reaches v1.0, Redocly's MCP server for feeding API documentation to AI agents, and Bump.sh for automated API changelog generation from spec diffs. The trend is unmistakable — the entire API toolchain is converging on "docs as code" patterns that align perfectly with AI-first development where specs, code, and documentation all live in Git and flow through the same CI/CD pipeline.