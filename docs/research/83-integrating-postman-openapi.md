# Integrating Postman and OpenAPI into the jaan-to AI workflow

**OpenAPI specifications are the single most impactful addition you can make to a Claude Code workflow.** They serve as machine-readable API contracts that let Claude generate typed clients, mock servers, Zod validators, and test suites from a single source of truth — collapsing what used to be weeks of manual coordination into minutes. Combined with Postman for interactive exploration and testing, and wired into the jaan-to folder structure through MCP servers, skills, and hooks, you get an API development pipeline where Claude handles the entire lifecycle: design → mock → build → test → document. This report covers every layer of that integration, from fundamentals to copy-pasteable configurations.

The timing is right. OpenAPI 3.2 (September 2025) added first-class MCP connector support. Postman shipped Agent Mode and an official MCP server in 2025. Orval v8 can now generate MCP servers directly from OpenAPI specs. The ecosystem has converged around the idea that **API specs are AI tool definitions**, and the jaan-to architecture — with its "skills stay generic, MCP provides real context" philosophy — is perfectly positioned to exploit this.

---

## OpenAPI 3.1 is the language AI agents speak natively

OpenAPI is a standardized, machine-readable format for describing REST APIs. Think of it as a blueprint that both humans and AI can read. For someone starting fresh, here's what matters.

**OpenAPI 3.1** (your target version) aligns fully with JSON Schema 2020-12, supports `type: ["string", "null"]` instead of the clunky `nullable: true`, and allows `$ref` siblings for inline overrides. **OpenAPI 3.2** (released September 2025) adds structured tags, first-class streaming/SSE support, and — critically — the ability to capture MCP connectors in a single OpenAPI file. Stick with 3.1 for now since tooling support is universal; upgrade to 3.2 when your tools catch up.

**YAML vs JSON**: Author in YAML (human-readable, supports comments, less verbose), serve as JSON for machines. Both are interchangeable per the spec. Claude Code reads both formats equally well, but YAML comments act as inline documentation that Claude uses for better context.

For AI agents to consume your spec effectively, the key is **descriptive `operationId` values** (these become function names), **detailed `description` fields** at every level, **`example` values** for all parameters, and **`enum` constraints** wherever possible. AI agents perform dramatically better with bounded option spaces. Here's a minimal but well-structured OpenAPI 3.1 spec:

```yaml
# specs/openapi.yaml
openapi: 3.1.0
info:
  title: Tasks API
  version: 1.0.0
  description: CRUD API for task management. Used by the jaan-to project frontend.

servers:
  - url: http://localhost:3000/api
    description: Local development
  - url: https://api.example.com
    description: Production

paths:
  /tasks:
    get:
      operationId: listTasks
      summary: List all tasks with pagination
      tags: [Tasks]
      parameters:
        - name: cursor
          in: query
          schema: { type: string }
          description: Opaque cursor for pagination. Omit for first page.
        - name: limit
          in: query
          schema: { type: integer, default: 20, maximum: 100 }
        - name: status
          in: query
          schema:
            type: string
            enum: [todo, in_progress, done]
      responses:
        '200':
          description: Paginated list of tasks
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/TaskListResponse'
        '400':
          $ref: '#/components/responses/BadRequest'

    post:
      operationId: createTask
      summary: Create a new task
      tags: [Tasks]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateTaskInput'
            example:
              title: "Implement login page"
              status: todo
              priority: high
      responses:
        '201':
          description: Task created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Task'
        '422':
          $ref: '#/components/responses/ValidationError'

  /tasks/{taskId}:
    get:
      operationId: getTask
      summary: Get a single task by ID
      tags: [Tasks]
      parameters:
        - $ref: '#/components/parameters/TaskId'
      responses:
        '200':
          description: Task details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Task'
        '404':
          $ref: '#/components/responses/NotFound'

    put:
      operationId: updateTask
      summary: Update an existing task
      tags: [Tasks]
      parameters:
        - $ref: '#/components/parameters/TaskId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateTaskInput'
      responses:
        '200':
          description: Updated task
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Task'

    delete:
      operationId: deleteTask
      summary: Delete a task
      tags: [Tasks]
      parameters:
        - $ref: '#/components/parameters/TaskId'
      responses:
        '204':
          description: Task deleted

components:
  parameters:
    TaskId:
      name: taskId
      in: path
      required: true
      schema: { type: string, format: uuid }
      description: Unique task identifier

  schemas:
    Task:
      type: object
      required: [id, title, status, createdAt]
      properties:
        id:
          type: string
          format: uuid
          example: "550e8400-e29b-41d4-a716-446655440000"
        title:
          type: string
          minLength: 1
          maxLength: 200
          example: "Implement login page"
        description:
          type: [string, "null"]
          maxLength: 2000
        status:
          type: string
          enum: [todo, in_progress, done]
          example: "todo"
        priority:
          type: string
          enum: [low, medium, high]
          default: medium
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: [string, "null"]
          format: date-time

    CreateTaskInput:
      type: object
      required: [title]
      properties:
        title: { type: string, minLength: 1, maxLength: 200 }
        description: { type: [string, "null"], maxLength: 2000 }
        status: { type: string, enum: [todo, in_progress, done], default: todo }
        priority: { type: string, enum: [low, medium, high], default: medium }

    UpdateTaskInput:
      type: object
      properties:
        title: { type: string, minLength: 1, maxLength: 200 }
        description: { type: [string, "null"], maxLength: 2000 }
        status: { type: string, enum: [todo, in_progress, done] }
        priority: { type: string, enum: [low, medium, high] }

    TaskListResponse:
      type: object
      required: [data, hasMore]
      properties:
        data:
          type: array
          items: { $ref: '#/components/schemas/Task' }
        nextCursor: { type: [string, "null"] }
        hasMore: { type: boolean }

    ProblemDetails:
      type: object
      description: RFC 9457 Problem Details
      properties:
        type: { type: string, format: uri-reference }
        title: { type: string }
        status: { type: integer, minimum: 100, maximum: 599 }
        detail: { type: string }
        instance: { type: string, format: uri-reference }

  responses:
    BadRequest:
      description: Bad request
      content:
        application/problem+json:
          schema: { $ref: '#/components/schemas/ProblemDetails' }
    NotFound:
      description: Resource not found
      content:
        application/problem+json:
          schema: { $ref: '#/components/schemas/ProblemDetails' }
    ValidationError:
      description: Validation failed
      content:
        application/problem+json:
          schema:
            allOf:
              - $ref: '#/components/schemas/ProblemDetails'
              - type: object
                properties:
                  errors:
                    type: array
                    items:
                      type: object
                      properties:
                        field: { type: string }
                        message: { type: string }

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

Notice the patterns: every schema lives in `components/schemas/` for reuse via `$ref`, errors follow **RFC 9457 Problem Details** (the updated successor to RFC 7807), pagination uses cursor-based design, and every field has an `example`. This spec is simultaneously human-readable documentation, an AI-parseable contract, and the source for all generated code.

**Swagger tools in 2025**: Swagger UI still works for interactive documentation, but for AI-driven workflows, the spec file itself is the product. SwaggerHub (now called "API Hub") is optional overhead. Use your text editor plus **Spectral** for linting — that's all you need. The real value comes from what you generate from the spec, not how you edit it.

---

## Postman brings interactive exploration and team testing

Postman complements OpenAPI specs as an interactive layer. Where the spec is the contract, Postman is the workbench where you explore, test, and monitor APIs. Starting fresh, here's what to focus on.

**Postbot and Agent Mode** are Postman's AI features. Postbot (launched 2023, refined through 2025) generates test scripts from natural language, auto-writes documentation, and debugs failed requests. **Agent Mode** (announced June 2025 at POST/CON) goes further — it's a full execution agent that creates collections, generates tests, builds documentation, and organizes environments from natural language instructions. Free plans include **50 AI credits per month**.

**The critical architectural decision**: OpenAPI spec is your source of truth, not Postman collections. Import the spec into Postman for interactive testing, but never let the Postman collection become the canonical definition of your API. Postman supports importing OpenAPI 3.0/3.1 natively, and you can re-import after spec changes. However, Postman still lacks native collection-to-OpenAPI export — you'd need the third-party `postman-to-openapi` npm package for that direction, which reinforces why the spec should be the source.

**Newman CLI** is Postman's headless collection runner for CI/CD, installed via `npm install -g newman`. It executes Postman collections from the command line with configurable reporters (CLI, JSON, JUnit, HTML). A GitHub Actions workflow is straightforward:

```yaml
name: API Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v3
        with: { node-version: '20' }
      - run: npm install -g newman
      - run: newman run tests/api-collection.json -e tests/env-staging.json -r cli,junit --reporter-junit-export results.xml
```

**Postman mock servers** generate cloud-hosted stubs from your collection examples. When you save example responses for each endpoint (200, 404, 500), the mock server returns them based on a matching algorithm. The mock URL takes the form `https://<mock-id>.mock.pstmn.io/<path>`. This is useful for quick team sharing, but for local development, **Prism** or **MSW** are better choices (covered below).

**Environments and variables** enable multi-environment testing. Postman's variable hierarchy (Global < Collection < Environment < Data < Local) lets you swap between dev/staging/production by switching environments. For secrets, Postman Vault integrates with 1Password, AWS Secrets Manager, and HashiCorp Vault — never commit secrets to collection files.

**Pricing alert for 2026**: Postman's free tier shrinks to **1 user only** effective March 1, 2026 (down from 3), with 25 collection runs per month across all plans. Unlimited runs require a paid add-on. For solo developers this is fine; for teams, budget for the Team plan at **$14-29/user/month**.

**Organizing collections**: Structure folders by resource (Users, Tasks, Auth), use descriptive request names ("Create Task," "List Tasks with Pagination"), add descriptions everywhere, and save multiple response examples per endpoint to power both documentation and mock servers.

---

## MCP servers connect API specs to Claude Code in real time

This is where the jaan-to architecture shines. MCP servers bridge the gap between static API specs and Claude's active context, giving it live access to your API definitions, Postman workspace, and testing tools.

**The official Postman MCP server** (`@postman/postman-mcp-server`) is production-ready, maintained by Postman Labs, and exposes **100+ tools** in full mode — covering collection management, workspace operations, spec management, mock servers, monitors, and critically, the ability to run collections as API tests. It supports both local (stdio) and remote (HTTPS) transports:

```bash
# Add to Claude Code (full mode)
claude mcp add postman --env POSTMAN_API_KEY=YOUR_KEY -- npx @postman/postman-mcp-server@latest --full

# Or code mode (lighter — spec search + client code generation)
claude mcp add postman --env POSTMAN_API_KEY=YOUR_KEY -- npx @postman/postman-mcp-server@latest --code
```

**For OpenAPI spec access**, several MCP servers exist. The best options for the jaan-to workflow:

- **`@reapi/mcp-openapi`** loads all specs from a directory and gives Claude structured access to operations and schemas. Perfect for pointing at your `specs/` folder.
- **AWS Labs `awslabs.openapi-mcp-server`** turns an OpenAPI spec into callable MCP tools with authentication support, validation, and caching — ideal for production APIs.
- **`mcp-openapi-proxy`** is the quickest way to proxy any spec URL as MCP tools, useful for third-party APIs.

For API testing directly from Claude Code, **`dkmaker-mcp-rest-api`** lets Claude make HTTP requests against your running dev server with full auth support.

Here's the complete `.mcp.json` configuration for an API-focused jaan-to project:

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://www.shadcn.io/api/mcp"]
    },
    "storybook-mcp": {
      "url": "http://localhost:6006/mcp",
      "type": "http"
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "postman": {
      "command": "npx",
      "args": ["-y", "@postman/postman-mcp-server@latest", "--code"],
      "env": {
        "POSTMAN_API_KEY": "${POSTMAN_API_KEY}"
      }
    },
    "openapi": {
      "command": "npx",
      "args": ["-y", "@reapi/mcp-openapi@latest", "--dir", "./specs"]
    },
    "rest-api": {
      "command": "npx",
      "args": ["-y", "dkmaker-mcp-rest-api"],
      "env": {
        "REST_BASE_URL": "http://localhost:3000"
      }
    }
  }
}
```

Note the `${POSTMAN_API_KEY}` environment variable syntax — `.mcp.json` supports this for referencing secrets without committing them. Keep MCP server count **under 10** with **under 80 total tools** to avoid consuming too much of Claude's context window. The configuration above hits the sweet spot: component library (shadcn), visual testing (Storybook), browser automation (Playwright), API management (Postman), spec access (OpenAPI), and live API testing (REST API).

---

## The API-first pipeline from design to deployment

The real power emerges when you chain these tools into a pipeline that Claude drives end-to-end. Here's how each phase works within the existing Storybook + shadcn/ui workflow.

**Design phase**: Claude creates or refines the OpenAPI spec with your input. Using the OpenAPI MCP server, it has real-time access to existing specs and can validate changes against Spectral rules. Start by describing what you need in natural language; Claude drafts the spec, you review the data model (this is the one step that always needs human eyes), and then it becomes the contract.

**Mock phase**: Before any backend code exists, generate mock servers. Three options serve different needs. **Prism** (`npm install -g @stoplight/prism-cli`) creates a standalone mock server from your spec in one command:

```bash
prism mock specs/openapi.yaml
# Mock server running at http://localhost:4010
# Dynamic mode with faker-generated data:
prism mock -d specs/openapi.yaml
```

**MSW** (Mock Service Worker) intercepts requests at the network level inside your app — critical for Storybook stories and component tests. **Postman mock servers** work for team sharing over the cloud. Use Prism during design, MSW during development and testing, Postman mocks for team collaboration.

**Frontend phase**: Claude generates typed API clients from the spec. The recommended toolchain for TypeScript/Next.js:

```bash
# Generate TypeScript types (zero runtime)
npx openapi-typescript ./specs/openapi.yaml -o ./src/lib/api/types.d.ts

# Or use Orval for full TanStack Query hooks + Zod schemas
npx orval --config orval.config.ts
```

The Orval configuration for the jaan-to workflow:

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: { target: './specs/openapi.yaml' },
    output: {
      clean: true,
      mode: 'tags-split',
      target: './src/lib/api/generated',
      schemas: './src/lib/api/schemas',
      client: 'react-query',
      override: {
        mutator: { path: './src/lib/api/custom-fetch.ts', name: 'customFetch' },
        query: {
          useQuery: true,
          useSuspenseQuery: true,
          signal: true,
        },
      },
      mock: true, // generates MSW handlers automatically
    },
  },
});
```

This single config generates TanStack Query hooks, TypeScript types, **and** MSW mock handlers — all from your OpenAPI spec. The `mock: true` flag is key for the Storybook integration.

**Backend phase**: Claude generates route handlers, validation middleware, and database schemas from the spec. With Zod schemas generated from OpenAPI (via Orval's `client: 'zod'` mode or `@hey-api/openapi-ts` with its Zod plugin), you get runtime validation that mirrors the spec exactly:

```typescript
// Generated by Orval — never hand-edit
export const createTaskInputSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(2000).nullable().optional(),
  status: z.enum(['todo', 'in_progress', 'done']).default('todo'),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
});
```

**The Storybook connection**: MSW handlers generated from OpenAPI specs power realistic API mocking in Storybook stories. This means a component that fetches data from `/api/tasks` will render with realistic mock data in Storybook without any backend running. The shadcn/ui components get their props, the API layer is mocked, and Playwright MCP can visually verify the result.

---

## Code generation tools are the bridge between specs and implementation

Five tools matter for TypeScript/Next.js. Choose based on your needs.

**`openapi-typescript`** (v7.13+, ~6k GitHub stars) generates zero-runtime TypeScript types. It's the lightest option — millisecond generation, no runtime overhead. Use it when you want types only and will handle fetching yourself:

```typescript
import type { paths, components } from './api-types';
type Task = components['schemas']['Task'];
type ListResponse = paths['/tasks']['get']['responses']['200']['content']['application/json'];
```

**`openapi-fetch`** (same monorepo, ~5kb) wraps native `fetch()` with full type inference from those generated types. No generics needed — types flow automatically from the path string:

```typescript
import createClient from 'openapi-fetch';
import type { paths } from './api-types';

const api = createClient<paths>({ baseUrl: 'http://localhost:3000/api' });

// Fully typed — params, body, and response all inferred from '/tasks'
const { data, error } = await api.GET('/tasks', {
  params: { query: { status: 'todo', limit: 10 } },
});
```

**Orval** (v8+, ~13k GitHub stars) is the most feature-rich option for React/Next.js. It generates TanStack Query hooks, MSW mocks, and Zod schemas in one pass. Each OpenAPI path becomes a ready-to-use hook:

```typescript
// Auto-generated by Orval — use directly in components
import { useListTasks, useCreateTask } from '@/lib/api/generated';

function TaskList() {
  const { data, isLoading } = useListTasks({ status: 'todo' });
  const createTask = useCreateTask();
  // ...
}
```

**`@hey-api/openapi-ts`** is a fast-growing alternative (used by Vercel and PayPal) with a plugin architecture supporting Zod, TanStack Query, and multiple HTTP clients. Its docs include an "Are you an LLM?" section — designed explicitly for AI consumption.

**`openapi-generator`** (~23k GitHub stars) supports 40+ languages but requires a JVM. It's best for polyglot/enterprise teams; for pure TypeScript, the lighter tools above are preferred.

**The cardinal rule**: generated files are never hand-edited. Add `src/lib/api/generated/` to `.gitignore` or clearly mark generated files. Regenerate on every spec change. This eliminates type drift entirely.

---

## Contract testing ensures specs and implementations stay honest

Linting, fuzzing, and contract testing form three layers of API quality assurance.

**Spectral** (by Stoplight) lints OpenAPI specs against configurable rulesets. Install it and create a `.spectral.yaml`:

```yaml
# .spectral.yaml
extends: ["spectral:oas"]
rules:
  operation-operationId:
    severity: error
  operation-description:
    severity: warn
  oas3-api-servers:
    severity: error
  operation-tag-defined:
    severity: error
```

Run with `npx spectral lint specs/openapi.yaml`. The GitHub Action (`stoplightio/spectral-action`) integrates directly into PR checks.

**Schemathesis** (v4.10+) fuzzes your running API by generating thousands of test cases from the OpenAPI spec — boundary values, edge cases, malformed inputs. It catches 500 errors, schema violations, and validation bypasses that manual testing misses:

```bash
pip install schemathesis
schemathesis run http://localhost:3000/api/openapi.json
```

In CI, use the official GitHub Action:

```yaml
- uses: schemathesis/action@v2
  with:
    schema: 'http://localhost:3000/api/openapi.json'
```

**Pact** remains the standard for consumer-driven contract testing in 2025. The consumer (your Next.js frontend) writes tests defining its expectations, generating a contract file that the provider (your API) verifies against. `@pact-foundation/pact` supports Pact Specification v4 with full TypeScript support.

**MSW + Storybook** is the critical integration for the existing jaan-to visual workflow. MSW 2.x (currently v2.12) intercepts network requests at the Service Worker level in the browser and uses class extension in Node.js — same handlers work in both. The `msw-storybook-addon` wires MSW directly into Storybook:

```bash
npm install msw msw-storybook-addon --save-dev
npx msw init public/ --save
```

```typescript
// .storybook/preview.ts
import type { Preview } from '@storybook/react';
import { initialize, mswLoader } from 'msw-storybook-addon';

initialize({ onUnhandledRequest: 'warn' });

const preview: Preview = {
  loaders: [mswLoader],
};
export default preview;
```

Then in your stories, define per-story mock responses:

```typescript
// src/components/TaskList.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { http, HttpResponse, delay } from 'msw';
import { TaskList } from './TaskList';

const meta: Meta<typeof TaskList> = {
  component: TaskList,
  tags: ['autodocs'],
};
export default meta;
type Story = StoryObj<typeof meta>;

const mockTasks = [
  { id: '1', title: 'Design login page', status: 'done', priority: 'high', createdAt: '2026-01-15T10:00:00Z' },
  { id: '2', title: 'Implement auth flow', status: 'in_progress', priority: 'high', createdAt: '2026-01-16T10:00:00Z' },
  { id: '3', title: 'Write tests', status: 'todo', priority: 'medium', createdAt: '2026-01-17T10:00:00Z' },
];

export const Default: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/tasks', () => {
          return HttpResponse.json({ data: mockTasks, hasMore: false, nextCursor: null });
        }),
      ],
    },
  },
};

export const Loading: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/tasks', async () => {
          await delay('infinite');
          return HttpResponse.json({});
        }),
      ],
    },
  },
};

export const Error: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/tasks', () => {
          return HttpResponse.json(
            { type: '/errors/internal', title: 'Internal Server Error', status: 500 },
            { status: 500, headers: { 'Content-Type': 'application/problem+json' } }
          );
        }),
      ],
    },
  },
};

export const Empty: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/tasks', () => {
          return HttpResponse.json({ data: [], hasMore: false, nextCursor: null });
        }),
      ],
    },
  },
};
```

This gives you four visual states for every API-dependent component — success, loading, error, and empty — all verifiable through the Storybook MCP addon and Playwright visual tests. **The pipeline becomes**: OpenAPI spec → Orval generates hooks + MSW handlers → Storybook stories use MSW handlers → Playwright MCP captures screenshots → Claude verifies visual correctness.

For auto-generating MSW handlers from specs (instead of writing them by hand), three approaches exist:

```typescript
// Option 1: @msw/source (official, runtime generation)
import { fromOpenApi } from '@msw/source/open-api';
import spec from '../specs/openapi.json';
const handlers = await fromOpenApi(spec);

// Option 2: msw-auto-mock (CLI code generator with faker)
// npx msw-auto-mock specs/openapi.yaml -o ./src/mocks

// Option 3: Orval with mock: true (generates alongside hooks)
// Already configured in orval.config.ts above
```

**MSW with Next.js App Router** requires the instrumentation hook pattern for server-side interception:

```typescript
// instrumentation.ts (project root)
export async function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    if (process.env.NEXT_PUBLIC_API_MOCKING === 'enabled') {
      const { server } = await import('./src/mocks/server');
      server.listen();
    }
  }
}
```

---

## Mapping everything into the jaan-to folder structure

Here's how API tooling maps to the jaan-to conventions. The folder structure extends cleanly:

```
project-root/
├── .mcp.json                          # MCP server configs (shown above)
├── .spectral.yaml                     # OpenAPI linting rules
├── orval.config.ts                    # Code generation config
├── specs/
│   └── openapi.yaml                   # Single source of truth
├── src/
│   ├── lib/api/
│   │   ├── generated/                 # Orval output (gitignored or committed)
│   │   ├── schemas/                   # Generated Zod schemas
│   │   └── custom-fetch.ts            # Custom fetch mutator
│   ├── mocks/
│   │   ├── handlers.ts                # MSW handlers (generated + custom)
│   │   ├── browser.ts                 # MSW browser setup
│   │   └── server.ts                  # MSW Node.js setup
│   └── components/
│       └── TaskList.stories.tsx        # Stories with MSW parameters
├── jaan-to/
│   ├── skills/
│   │   └── api-development/
│   │       ├── SKILL.md               # API development skill
│   │       └── references/
│   │           ├── openapi-patterns.md
│   │           └── error-handling.md
│   ├── agent-docs/
│   │   └── api-conventions.md         # API coding standards
│   └── commands/
│       ├── generate-api-client.md     # /generate-api-client
│       ├── create-mock-server.md      # /create-mock-server
│       └── validate-api-spec.md       # /validate-api-spec
├── .claude/
│   ├── settings.json                  # Hooks configuration
│   └── rules/
│       └── api-rules.md               # API-specific rules
└── CLAUDE.md                          # References specs/ and conventions
```

**SKILL.md for API development** — this is the skill Claude activates when API work is detected:

```markdown
---
name: api-development
description: >
  API development workflow using OpenAPI specs as the single source of truth.
  Covers generating typed clients, mock servers, Zod validators, and contract tests.
  Activate when working with REST APIs, OpenAPI specs, API routes, or data fetching.
---

# API Development Skill

## Core Principle
The OpenAPI spec at `specs/openapi.yaml` is the single source of truth.
All types, clients, validators, and mocks are generated from it. Never hand-write API types.

## Workflow

### Adding a new endpoint
1. Update `specs/openapi.yaml` with the new path, schemas, and examples
2. Run `npx spectral lint specs/openapi.yaml` to validate
3. Run `npx orval --config orval.config.ts` to regenerate clients + hooks + mocks
4. Implement the backend route handler using generated Zod schemas for validation
5. Create Storybook stories with MSW handlers for the new endpoint
6. Run Playwright visual tests to verify

### Modifying an existing endpoint
1. Update the spec first, always
2. Regenerate all code: `npx orval --config orval.config.ts`
3. Fix any type errors in consuming components (the compiler catches drift)
4. Update affected Storybook stories and their MSW handlers

## Key Files
- `specs/openapi.yaml` — API contract
- `orval.config.ts` — code generation config
- `src/lib/api/generated/` — generated hooks and types (never edit)
- `src/lib/api/schemas/` — generated Zod schemas (never edit)
- `src/mocks/handlers.ts` — MSW mock handlers
- `.spectral.yaml` — linting rules

## Tools
- **Spectral**: `npx spectral lint specs/openapi.yaml`
- **Orval**: `npx orval --config orval.config.ts`
- **Prism mock**: `npx prism mock specs/openapi.yaml`
- **Schemathesis**: `schemathesis run http://localhost:3000/api/openapi.json`

## Error Handling
All API errors must follow RFC 9457 Problem Details format.
Content-Type for errors: `application/problem+json`.
See `jaan-to/skills/api-development/references/error-handling.md` for patterns.

## Code Generation Tools
- `openapi-typescript` → TypeScript types (zero runtime)
- `openapi-fetch` → type-safe fetch wrapper
- `Orval` → TanStack Query hooks + MSW mocks + Zod schemas
Use Orval as the default. Fall back to openapi-typescript + openapi-fetch for lightweight needs.
```

**Slash command `/generate-api-client`**:

```markdown
<!-- .claude/commands/generate-api-client.md -->
Regenerate all API client code from the OpenAPI spec.

Steps:
1. Lint the spec: `npx spectral lint specs/openapi.yaml`
2. If lint passes, generate: `npx orval --config orval.config.ts`
3. Report what was generated (new hooks, updated types, new MSW handlers)
4. Check for any type errors in files that import from the generated directory
5. If there are type errors, suggest fixes

$ARGUMENTS can specify a subset: "only types", "only hooks", "only mocks"
```

**Slash command `/validate-api-spec`**:

```markdown
<!-- .claude/commands/validate-api-spec.md -->
Validate the OpenAPI spec for correctness and best practices.

Steps:
1. Run `npx spectral lint specs/openapi.yaml --format json`
2. Summarize all errors and warnings
3. For each error, suggest a fix with the corrected YAML
4. Check that all schemas have examples
5. Check that all operationIds are unique and descriptive
6. Check that error responses use RFC 9457 Problem Details format
7. Verify all $ref targets exist and are used
```

**Slash command `/create-mock-server`**:

```markdown
<!-- .claude/commands/create-mock-server.md -->
Create a mock server from the OpenAPI spec for frontend development.

Options based on $ARGUMENTS:
- "prism" (default): Run `npx prism mock specs/openapi.yaml` for standalone mock server
- "msw": Generate MSW handlers from spec using `npx msw-auto-mock specs/openapi.yaml -o src/mocks/generated`
- "postman": Import spec to Postman and create a cloud mock server (requires Postman MCP)

After creating the mock server, update the dev environment to point to the mock URL.
```

**API rules for `.claude/rules/`**:

```markdown
<!-- .claude/rules/api-rules.md -->
paths: ["src/lib/api/**", "specs/**", "src/app/api/**"]

## API Development Rules

- NEVER hand-write TypeScript types for API request/response shapes. Always generate from specs/openapi.yaml.
- NEVER edit files in src/lib/api/generated/ or src/lib/api/schemas/ — these are generated by Orval.
- When adding or modifying API endpoints, ALWAYS update specs/openapi.yaml FIRST, then regenerate.
- All API errors MUST use RFC 9457 Problem Details format with content-type application/problem+json.
- All API routes MUST validate request bodies using the generated Zod schemas.
- All Storybook stories for API-dependent components MUST include MSW handlers for success, error, loading, and empty states.
- Use cursor-based pagination (never offset-based) for list endpoints.
- All operationIds must be camelCase and descriptive (e.g., listTasks, createTask, not get1 or post2).
- Include example values for every schema property in the OpenAPI spec.
```

**Hooks in `.claude/settings.json`** for automatic API validation:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATHS\" | grep -q 'specs/.*\\.yaml\\|specs/.*\\.yml'; then npx spectral lint specs/openapi.yaml --fail-severity warn 2>&1 | head -20; fi",
            "timeout": 15
          },
          {
            "type": "command",
            "command": "prettier --write \"$CLAUDE_FILE_PATHS\" 2>/dev/null || true"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATHS\" | grep -q 'src/lib/api/generated/\\|src/lib/api/schemas/'; then echo '{\"block\": true, \"message\": \"Cannot edit generated API files. Update specs/openapi.yaml and run /generate-api-client instead.\"}' >&2; exit 2; fi",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

The PostToolUse hook runs Spectral every time Claude edits an OpenAPI spec file, catching errors immediately. The PreToolUse hook **blocks Claude from editing generated files** — forcing the spec-first workflow.

**Agent-docs for API conventions**:

```markdown
<!-- jaan-to/agent-docs/api-conventions.md -->
# API Conventions

## Endpoint Design
- Resource names are plural nouns: /tasks, /users, /projects
- Use kebab-case for multi-word paths: /task-comments
- Nest only one level deep: /tasks/{taskId}/comments (never deeper)
- Standard CRUD operations: GET (list), POST (create), GET /:id (read), PUT /:id (update), DELETE /:id (delete)

## Versioning
- URL path versioning: /api/v1/tasks
- Major version only — no minor/patch in URLs
- Old versions supported for minimum 6 months after deprecation

## Request/Response
- Request bodies: JSON only, Content-Type: application/json
- Successful responses: 200 (read/update), 201 (create), 204 (delete)
- Error responses: RFC 9457 Problem Details, Content-Type: application/problem+json
- Timestamps: ISO 8601 format, always UTC (2026-02-26T15:30:00Z)
- IDs: UUID v4 format

## Pagination
- Cursor-based only. Response shape:
  { data: T[], nextCursor: string | null, hasMore: boolean }
- Default limit: 20, max limit: 100
- Cursor is an opaque string (base64-encoded composite key)

## Authentication
- Bearer JWT tokens in Authorization header
- OpenAPI spec uses bearerAuth security scheme
- Refresh tokens via /auth/refresh endpoint

## Naming Conventions
- operationId: camelCase (listTasks, createTask, getTaskById)
- Schema names: PascalCase (Task, CreateTaskInput, TaskListResponse)
- Properties: camelCase (createdAt, taskId)
- Query parameters: camelCase (sortBy, pageSize)
- Enum values: snake_case (in_progress, high_priority)
```

**CLAUDE.md additions** — add these lines to the project's CLAUDE.md:

```markdown
## API Development
- API spec lives at specs/openapi.yaml — this is the single source of truth
- Generate API clients: `npx orval --config orval.config.ts`
- Lint API spec: `npx spectral lint specs/openapi.yaml`
- Mock server: `npx prism mock specs/openapi.yaml` (runs on :4010)
- Never hand-write API types — always generate from spec
- See jaan-to/agent-docs/api-conventions.md for REST design patterns
- See jaan-to/skills/api-development/SKILL.md for full workflow
```

---

## Best practices and standards that make AI-generated APIs consistent

**API versioning**: Use URL path versioning (`/api/v1/tasks`). It's the most explicit, easiest to test, and most discoverable for AI agents. Twitter, Facebook, and Airbnb use this pattern. Header-based versioning (used by GitHub) is elegant but harder for AI agents to discover and for developers to test in browsers.

**Error standardization**: RFC 9457 (successor to RFC 7807) defines Problem Details — a standard JSON structure for all errors. Every 4xx and 5xx response should return `application/problem+json` with `type`, `title`, `status`, `detail`, and `instance` fields. This gives AI agents a consistent error interface to handle programmatically. Spectral can enforce this with the `operation-4xx-problem-details-rfc7807` rule.

**Authentication in specs**: Document OAuth 2.0, JWT Bearer, and API key schemes in `components/securitySchemes`. OpenAPI 3.2 adds device authorization flow and metadata URLs. For most Next.js apps, JWT Bearer is the practical choice — simple, well-supported, and easily documented.

**Pagination**: Cursor-based pagination is the 2025 standard for production APIs. It handles concurrent modifications gracefully and performs well with large datasets. Offset-based is acceptable for admin interfaces or small datasets but degrades under concurrent writes.

**HATEOAS**: Skip it. For AI-first development with OpenAPI specs, HATEOAS adds complexity without proportional benefit. The OpenAPI spec itself is the discoverability mechanism; MCP is the preferred way for AI agents to discover and invoke tools.

**The code generation recommendation matrix**:

- Types only (zero runtime) → **openapi-typescript**
- Type-safe fetch client → **openapi-fetch**
- TanStack Query hooks with mocks → **Orval**
- Full plugin ecosystem (Zod, TanStack, multiple clients) → **@hey-api/openapi-ts**
- Polyglot/enterprise SDKs → **openapi-generator**
- Zod-first backend → OpenAPI → **zod-openapi** or **@hono/zod-openapi**
- MCP server from spec → **Orval v8** (direct generation)

---

## Ten anti-patterns that will sabotage the workflow

**1. Hand-writing API types when a spec exists.** This is the single most common drift risk. Generated types from `openapi-typescript` or Orval are always in sync; hand-written types will diverge the moment someone updates an endpoint. The PreToolUse hook above blocks this pattern.

**2. Using Postman collections as the source of truth.** Collections are interactive testing tools, not contracts. They lack the schema precision of OpenAPI specs, and Postman still can't natively export to OpenAPI. Import specs into Postman, not the other way around.

**3. One massive monolithic spec file.** For APIs with 50+ endpoints, split into modular files using `$ref: './schemas/task.yaml'`. Keep the main `openapi.yaml` as an index that references domain-specific files. Spectral and Orval both handle multi-file specs.

**4. Skipping API linting.** Without Spectral, specs accumulate inconsistencies — missing descriptions, undocumented errors, inconsistent naming. Add linting to CI and to Claude Code hooks.

**5. Building frontend without API mocks.** This blocks frontend work on backend completion. MSW + Prism eliminate this dependency entirely. Frontend development should never wait for backend endpoints.

**6. Committing secrets in Postman collections.** Postman collections are JSON files — any API keys or tokens in them will end up in git history. Use Postman Vault for secrets, environment variables for CI, and `.gitignore` for sensitive environment files.

**7. Over-trusting AI-generated data models.** Claude can draft excellent OpenAPI specs, but the data model — entity relationships, field types, constraints, and business logic — requires human review. Always treat AI-generated schemas as drafts until a human verifies the domain model.

**8. Editing generated files.** Any change to files in `generated/` will be overwritten on the next Orval run. If you need customization, use Orval's mutator pattern or override configuration — never patch generated code directly.

**9. Ignoring the mock → real transition.** MSW handlers that don't match actual API behavior create false confidence. Generate handlers from the same spec that drives the backend, and run contract tests (Schemathesis, Pact) to catch divergence.

**10. Installing too many MCP servers.** Each MCP server's tool descriptions consume context tokens. With 15+ servers and 200+ tools, you can lose over half your context window. The `.mcp.json` configuration above uses 6 servers — enough for the full workflow without context bloat.

---

## Conclusion: the API layer completes the jaan-to loop

The integration creates a closed loop where a single OpenAPI spec file drives the entire stack. Claude reads the spec via MCP, generates typed hooks and Zod validators via Orval, creates MSW handlers for Storybook stories, and validates everything through Spectral linting and Schemathesis fuzzing — all within the existing shadcn/ui + Storybook + Playwright visual workflow.

The most impactful first steps: create `specs/openapi.yaml` with one resource, configure Orval, add the Spectral lint hook, and set up MSW in Storybook. Within an hour, you'll have a pipeline where changing one line in the spec ripples correctly through types, hooks, mocks, validation, and documentation. The PreToolUse hook that blocks generated file edits is what keeps the system honest — it forces the spec-first discipline that makes everything else work.

For solo developers, this eliminates the cognitive load of keeping types, mocks, and implementation in sync manually. For teams, the OpenAPI spec becomes the handshake between frontend and backend engineers, with Claude as the translator who ensures both sides speak the same language.