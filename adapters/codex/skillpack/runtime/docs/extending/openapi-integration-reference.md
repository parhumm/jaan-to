# OpenAPI Integration Reference

> Cross-skill patterns for API-aware development. Skills reference this instead of duplicating OpenAPI logic.

**Consumers**: `frontend-scaffold`, `frontend-story-generate`, `frontend-task-breakdown`, `dev-project-assemble`, `dev-output-integrate`, `qa-test-cases`

**Not covered here**: Contract validation tools (Spectral, oasdiff, Prism, Schemathesis) — see `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-contract-validate-reference.md`.

---

## Contract Discovery

Glob patterns to locate OpenAPI specs in a project:

```
specs/openapi.yaml
specs/openapi.json
docs/openapi.yaml
docs/api-spec.yaml
$JAAN_OUTPUTS_DIR/backend/api-contract/**/openapi.yaml
$JAAN_OUTPUTS_DIR/backend/api-contract/**/openapi.json
```

Validation: file must contain top-level `openapi:` (3.x) or `swagger:` (2.x) key.

---

## Code Generation Decision Tree

| Feature | Orval | openapi-typescript | @hey-api/openapi-ts |
|---------|-------|--------------------|---------------------|
| Runtime | Node.js | Node.js | Node.js |
| OpenAPI 3.1 | Yes | Yes | Yes (full) |
| TanStack Query | Built-in | Manual | Plugin |
| MSW mocks | Built-in (`mock: true`) | No | No |
| Zod schemas | No | No | Plugin |
| Next.js client | Via mutator | Via openapi-fetch | Dedicated |
| npm weekly DL | ~749k | ~1.68M | ~977k |

**Default recommendation**: Orval — generates hooks + mocks in one config. Use `openapi-typescript` when only types are needed (zero runtime). Use `@hey-api/openapi-ts` for Zod validation + Next.js-specific client.

---

## Orval Configuration

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

Generated hooks usage:
```typescript
import { useListTasks, useCreateTask } from '@/lib/api/generated';

function TaskList() {
  const { data, isLoading } = useListTasks({ status: 'todo' });
  const createTask = useCreateTask();
}
```

---

## MSW Handler Patterns

### Per-endpoint handlers (success/error/loading/empty)

```typescript
import { http, HttpResponse, delay } from 'msw';

// Success
http.get('/api/tasks', () => {
  return HttpResponse.json({ data: mockTasks, hasMore: false, nextCursor: null });
});

// Loading (infinite delay)
http.get('/api/tasks', async () => {
  await delay('infinite');
  return HttpResponse.json({});
});

// Error (RFC 9457)
http.get('/api/tasks', () => {
  return HttpResponse.json(
    { type: '/errors/internal', title: 'Internal Server Error', status: 500 },
    { status: 500, headers: { 'Content-Type': 'application/problem+json' } }
  );
});

// Empty
http.get('/api/tasks', () => {
  return HttpResponse.json({ data: [], hasMore: false, nextCursor: null });
});
```

### MSW generation options

| Method | When to use |
|--------|-------------|
| Orval `mock: true` | Default — generates alongside hooks |
| `@msw/source/open-api` | Runtime generation from spec (no build step) |
| `msw-auto-mock` CLI | Standalone mock generation with faker data |

### MSW browser setup (setupWorker)

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

### MSW server setup (setupServer)

```typescript
// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### MSW + Next.js App Router

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

## MSW + Storybook Integration

### Storybook preview setup

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

### Story with MSW handlers

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { http, HttpResponse, delay } from 'msw';
import { TaskList } from './TaskList';

const meta: Meta<typeof TaskList> = {
  component: TaskList,
  tags: ['autodocs'],
};
export default meta;
type Story = StoryObj<typeof meta>;

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

### Required dependencies

```
msw (v2.x)
msw-storybook-addon
```

---

## Scalar API Documentation (Node.js/TS only)

### Next.js API route handler

```typescript
// app/reference/route.ts
import { ApiReference } from '@scalar/nextjs-api-reference';

const config = {
  url: '/api/openapi.json',
  theme: 'moon', // dark theme matching shadcn/ui
};

export const GET = ApiReference(config);
```

### Spec serving route

```typescript
// app/api/openapi/route.ts
import { NextResponse } from 'next/server';
import yaml from 'js-yaml';
import fs from 'fs';
import path from 'path';

export async function GET() {
  const filePath = path.join(process.cwd(), 'specs/openapi.yaml');
  const fileContent = fs.readFileSync(filePath, 'utf8');
  const spec = yaml.load(fileContent);
  return NextResponse.json(spec);
}
```

### Required dependency

```
@scalar/nextjs-api-reference (~66kB)
```

Non-Node stacks (PHP/Laravel, Go, etc.): emit setup instructions in output readme only.

---

## RFC 9457 Error Shape

Standard error response format for MSW error handlers and API contract schemas:

```yaml
components:
  schemas:
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
```

---

## Flat Output Conventions

All generated API artifacts are flat output files in `$JAAN_OUTPUTS_DIR`. The `dev-output-integrate` skill is responsible for placing them in project paths.

| Output File | Project Destination |
|-------------|-------------------|
| `{id}-{slug}-orval-config.ts` | `orval.config.ts` (project root) |
| `{id}-{slug}-msw-handlers.ts` | `src/mocks/handlers.ts` |
| `{id}-{slug}-msw-browser.ts` | `src/mocks/browser.ts` |
| `{id}-{slug}-msw-server.ts` | `src/mocks/server.ts` |

Skills generating these files MUST include a Source → Destination mapping table in their readme output.

---

## Anti-Patterns

1. **Never hand-write API types** when an OpenAPI spec exists — generate with Orval or openapi-typescript
2. **Never edit generated files** — treat `src/lib/api/generated/` as a dependency
3. **Spec-first discipline** — design the API contract before implementing endpoints
4. **Never use Swagger Codegen** — OpenAPI Generator is the maintained fork
5. **Never use swagger-cli** — abandoned; use Spectral for validation
6. **Never expose Swagger UI in production** without authentication
7. **Never use Postman collections as source of truth** — OpenAPI spec is the single source
8. **Never skip API linting** — run Spectral in CI
9. **Never build frontend without API mocks** — use MSW from day one
10. **Never commit secrets** in Postman collections or environment files
