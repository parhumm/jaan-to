# Building a Production-Ready Documentation Generation Framework

**A comprehensive technical research guide for implementing `dev:docs-generate` across PHP/Laravel, TypeScript/React, and Docusaurus stacks.**

The most effective approach for this documentation framework combines **code-first generation** (Scramble, TypeDoc, Storybook) with **OpenAPI as the single source of truth** for API contracts. This research identifies **Scramble + openapi-typescript + Docusaurus** as the optimal pipeline, achieving automated documentation with **minimal manual annotation** while maintaining type safety across the full stack.

---

## 1. Executive summary

This research establishes a documentation generation framework for a heterogeneous stack spanning Laravel 10/PHP 8.2+, TypeScript 5.x/React 18, Storybook CSF 3.0, and Docusaurus. The recommended architecture follows three core principles:

**OpenAPI as contract**: Scramble generates OpenAPI 3.1.0 specs from Laravel code without annotations, which then drives both human-readable docs (Scribe) and TypeScript type generation (openapi-typescript). This eliminates manual type synchronization between backend and frontend.

**Documentation as code**: All five doc types (README, API, Component, Runbook, ADR) live alongside source code, with generation triggered by CI/CD pipelines. Quality gates validate documentation coverage, link integrity, and spec compliance before merge.

**Layered generation strategy**: Tier 1 documentation (README, API) receives deepest automation investment since it changes most frequently. Tier 2-3 documentation (Components, Runbooks, ADRs) uses template-driven generation with human review.

The critical path for implementation is:
1. Configure Scramble for OpenAPI generation from Laravel
2. Set up openapi-typescript for frontend type generation
3. Integrate docusaurus-openapi-docs for unified portal
4. Implement Spectral validation in CI/CD
5. Create templates for each doc type with required/optional field schemas

---

## 2. Standards reference

### The Diátaxis framework structures all documentation

Developed by Daniele Procida and adopted by Canonical, Cloudflare, and Python, Diátaxis divides documentation into four types based on user needs:

| Type | User Mode | Purpose | Example |
|------|-----------|---------|---------|
| **Tutorials** | Study | Learning through hands-on lessons | "Build your first API endpoint" |
| **How-to Guides** | Work | Solving specific problems | "How to implement rate limiting" |
| **Reference** | Work | Technical specifications | API endpoint documentation |
| **Explanation** | Study | Understanding concepts | "Why we chose event sourcing" |

The `dev:docs-generate` skill maps directly to these types: **README** serves as tutorial/explanation, **API docs** are reference, **Runbooks** are how-to guides, **ADRs** are explanation, and **Component docs** blend reference with examples.

### Style guide principles from Google and Microsoft

**Google Developer Documentation Style Guide** establishes these rules: use **second person** ("you" not "we"), **active voice**, **present tense**, and **sentence case** for headings. Put conditions before instructions ("If you want caching, set `CACHE_ENABLED=true`").

**Microsoft Writing Style Guide** emphasizes **empathy** (never condescend), **simple sentences** for translation, and **scannable structure** with frontloaded key information. Maximum procedure length is **12 steps** before chunking into sections.

Both guides mandate **accessible language**: provide alt text for images, use unambiguous date formats (2024-01-15, not 1/15/24), and avoid idioms that don't translate globally.

### The Good Docs Project provides templates

This open-source initiative (thegooddocsproject.dev) offers peer-reviewed templates for concept docs, how-to guides, READMEs, release notes, and changelogs. Templates are integrated into JetBrains Writerside and available on GitLab/GitHub. Each template includes a **writing guide** explaining what content belongs in each section.

---

## 3. Tier 1 deep dive: README best practices

### Standard-Readme specification defines authoritative structure

The Standard-Readme spec (github.com/RichardLitt/standard-readme) establishes this section order:

1. **Title** (required) — Project name
2. **Badges** (optional) — Build status, coverage, version, license
3. **Short Description** (required) — One paragraph explaining what the project does
4. **Table of Contents** (required for >100 lines)
5. **Install** (required) — Code block with installation steps
6. **Usage** (required) — Code examples, CLI commands
7. **API** (optional) — Technical reference
8. **Contributing** (optional) — Link to CONTRIBUTING.md
9. **License** (required) — License information

The philosophy: "Documentation, not code, defines what a module does." A developer should understand and use the module **without reading source code**.

### Badge strategy prioritizes relevance over quantity

Research from daily.dev and SonarSource identifies these badge categories in priority order:

- **Build/CI status** — Shows project health at a glance
- **Test coverage** — Indicates code quality investment
- **Version** — npm/Packagist current version
- **License** — Legal clarity for adopters
- **Documentation** — Links to full docs site

Use **shields.io** for consistency. For projects with 5+ badges, organize into a table with rows per category. The common mistake is "badge soup" — displaying every possible badge dilutes signal.

### Monorepo README strategy for NX workspaces

NX monorepos require a **two-tier README approach**:

**Root README** contains:
- Organization/project overview
- Architecture diagram showing app/lib relationships
- Getting started (workspace setup, prerequisites)
- Links to all apps and libraries
- Development workflow (`nx serve`, `nx build`, `nx test`)
- CI/CD overview

**Package-level READMEs** contain:
- Package-specific purpose
- Public API documentation
- Usage examples within monorepo context
- Internal dependencies (which libs this package uses)
- Package-specific configuration

NX's project graph (`nx graph`) can auto-generate dependency documentation. Each library exports via `index.ts` as its public API contract.

### Exemplary README patterns from open source

Analysis of 10+ highly-starred repositories reveals common excellence patterns:

**NestJS** (github.com/nestjs/nest): Clean logo, clear value proposition, multi-language documentation links, organized badge row, prominent sponsor section.

**httpie** (github.com/httpie/httpie): Demo screenshots showing actual usage, GIF animations, clear table of contents, quick install/usage section.

**Prisma** (github.com/prisma/prisma): Visual database diagrams, quickstart section, badges that convey trust signals.

**tRPC** (github.com/trpc/trpc): Clear tagline ("End-to-end typesafe APIs"), feature list with emojis, live playground links.

**Linting with markdownlint** enforces consistency. Install via `npm install markdownlint --save-dev` and use the VS Code extension for real-time feedback. The tool is used by .NET Documentation, Electron, ESLint, and MDN Web Docs.

---

## 4. Tier 1 deep dive: API documentation

### Laravel Scramble generates OpenAPI without annotations

Scramble (scramble.dedoc.co) is the recommended tool for Laravel 10 API documentation. Unlike annotation-based tools, Scramble uses **code inference** to generate OpenAPI 3.1.0 specs automatically.

**Installation and basic setup:**
```bash
composer require dedoc/scramble
php artisan vendor:publish --provider="Dedoc\Scramble\ScrambleServiceProvider"
```

Routes are automatically added at `/docs/api` (UI) and `/docs/api.json` (OpenAPI spec).

**Authentication documentation for Sanctum/Passport:**
```php
// In AppServiceProvider boot() method
use Dedoc\Scramble\Scramble;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\SecurityScheme;

Scramble::configure()
    ->withDocumentTransformers(function (OpenApi $openApi) {
        $openApi->secure(
            SecurityScheme::http('bearer', 'JWT')
        );
    });
```

Mark specific routes as unauthenticated with the `@unauthenticated` PHPDoc annotation.

**Custom response schemas via Document Transformers:**
```php
class AddWebhookDocumentationTransformer implements DocumentTransformer
{
    public function handle(OpenApi $document, $context): void
    {
        $operation = (new Operation('post'));
        $operation->summary('Webhook Notification')
            ->description('Webhook sent after transaction completion.');
        
        $path = (new Path('/webhooks/notification'))->addOperation($operation);
        $document->paths[] = $path;
    }
}
```

**Endpoint grouping** uses PHP 8 attributes:
```php
use Dedoc\Scramble\Attributes\Group;

#[Group('User Management')]
class UserController extends Controller { }
```

### Scribe provides enhanced human-readable documentation

For projects needing richer documentation than Scramble's auto-generation, Scribe (scribe.knuckles.wtf/laravel) offers:

- Pretty single-page HTML documentation
- **Multi-language code samples** (bash, JavaScript, PHP, Python, Ruby)
- Postman/Insomnia collection generation
- In-browser "Try It Out" API tester

**Key configuration in `config/scribe.php`:**
```php
'example_languages' => ['bash', 'javascript', 'php', 'python'],
'auth' => [
    'enabled' => true,
    'in' => 'bearer',
    'name' => 'Authorization',
],
'openapi' => [
    'enabled' => true,
    'version' => '3.1.0',
],
```

**Parameter documentation via PHPDoc:**
```php
/**
 * Create a new user
 *
 * @bodyParam name string required The name of the user. Example: John Doe
 * @bodyParam email string required The email address. Example: john@example.com
 *
 * @response 201 {"id": 1, "name": "John Doe"}
 * @response 422 scenario="Validation error" {"message": "Invalid data"}
 */
public function store(StoreUserRequest $request) { }
```

### PHPDoc standards for Laravel with generics

PHP 8.2+ supports advanced type hints through PHPDoc annotations that tools like PHPStan and IDE plugins understand:

```php
/**
 * @template T
 * @param class-string<T> $class
 * @return T
 */
function resolve(string $class): object
{
    return app($class);
}

// Eloquent relationship generics
class User extends Model
{
    /** @return HasMany<Post, $this> */
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
}
```

This enables IDE autocompletion and static analysis without runtime overhead.

### OpenAPI validation with Spectral in CI/CD

Spectral (github.com/stoplightio/spectral) provides linting for OpenAPI specs:

```yaml
# .spectral.yaml
extends: spectral:oas
rules:
  require-description:
    description: "Operations must have descriptions"
    given: "$.paths[*][*]"
    severity: error
    then:
      field: description
      function: truthy
      
  naming-convention:
    description: "Paths should use kebab-case"
    given: "$.paths[*]~"
    severity: warn
    then:
      function: pattern
      functionOptions:
        match: "^(/[a-z][a-z0-9-]*)+$"
```

**GitHub Actions integration:**
```yaml
- name: Run Spectral
  uses: stoplightio/spectral-action@v0.8.10
  with:
    file_glob: 'openapi.yaml'
    spectral_ruleset: '.spectral.yaml'
```

### Legacy Slim 3 migration path

For Slim 3 APIs without Scramble support, use **zircote/swagger-php** with PHP 8 attributes:

```php
use OpenApi\Attributes as OA;

#[OA\Info(title: 'Legacy API', version: '1.0')]
class OpenApiInfo {}

class UserController
{
    #[OA\Get(
        path: '/api/users',
        operationId: 'getUsers',
        tags: ['Users'],
        responses: [new OA\Response(response: 200, description: 'Success')]
    )]
    public function getUsers($request, $response) { }
}
```

Generate the spec with: `./vendor/bin/openapi app -o openapi.yaml`

**Documentation parity strategy**: Use versioned API paths (`/v1/*` for Slim, `/v2/*` for Laravel) and generate separate OpenAPI specs that both render in the same Docusaurus portal.

### TypeScript type generation with openapi-typescript

openapi-typescript (openapi-ts.dev) generates TypeScript types from OpenAPI specs:

```bash
npx openapi-typescript ./openapi.yaml -o ./src/types/api.d.ts
```

**Using generated types:**
```typescript
import type { paths, components } from "./api";

type User = components["schemas"]["User"];
type GetUserParams = paths["/users/{id}"]["parameters"];
type UserResponse = paths["/users/{id}"]["get"]["responses"][200]["content"]["application/json"];
```

**NX monorepo integration** via project.json:
```json
{
  "targets": {
    "generate-types": {
      "executor": "nx:run-commands",
      "options": {
        "command": "npx openapi-typescript ../../openapi/api.yaml -o src/generated/api.d.ts"
      },
      "inputs": ["{workspaceRoot}/openapi/**/*.yaml"],
      "outputs": ["{projectRoot}/src/generated"]
    },
    "build": {
      "dependsOn": ["generate-types"]
    }
  }
}
```

### React Query hooks generation with Orval

Orval (orval.dev) generates type-safe API clients with React Query hooks:

```typescript
// orval.config.ts
export default {
  petstore: {
    input: { target: './openapi.yaml' },
    output: {
      mode: 'tags-split',
      target: './src/api',
      client: 'react-query',
      override: {
        query: {
          useQuery: true,
          usePrefetch: true,
          options: { staleTime: 10000 },
        },
      },
    },
  },
};
```

**Generated hook usage:**
```typescript
import { useGetUsers, useCreateUser } from '@myorg/api-client';

function UserList() {
  const { data: users, isLoading } = useGetUsers();
  const createUser = useCreateUser();
  // Fully typed, no manual type definitions
}
```

### Breaking change detection with oasdiff

oasdiff (github.com/oasdiff/oasdiff) detects breaking API changes in CI:

```yaml
- name: Check for breaking changes
  uses: oasdiff/oasdiff-action/breaking@main
  with:
    base: base-spec.yaml
    revision: openapi/api.yaml
    fail-on-diff: true
```

Changes are classified as **ERR** (definite breaking), **WARN** (potential breaking), or **INFO** (non-breaking).

### TypeDoc for TypeScript library documentation

TypeDoc (typedoc.org) generates API documentation from TypeScript source:

```json
{
  "entryPoints": ["src/index.ts"],
  "out": "docs",
  "excludePrivate": true,
  "plugin": ["typedoc-plugin-markdown"]
}
```

**TSDoc comment standards:**
```typescript
/**
 * Summary section - shown in listings.
 *
 * @remarks Extended documentation with details.
 * @param x - The first input number
 * @returns The arithmetic mean
 * @example
 * ```ts
 * const result = getAverage(10, 20); // 15
 * ```
 * @public
 */
export function getAverage(x: number, y: number): number {
  return (x + y) / 2.0;
}
```

---

## 5. Tier 2: Component documentation and runbooks

### Storybook CSF 3.0 patterns for React + TypeScript

Component Story Format 3.0 (Storybook 7+) uses object-based story definitions:

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { fn, expect, userEvent } from 'storybook/test';
import { Button } from './Button';

const meta = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost'],
      description: 'Visual style variant',
      table: { category: 'Appearance' },
    },
    onClick: { action: 'clicked' },
  },
  args: {
    variant: 'primary',
    onClick: fn(),
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: { children: 'Primary Button' },
};

export const WithInteraction: Story = {
  args: { children: 'Click Me' },
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button'));
    await expect(args.onClick).toHaveBeenCalled();
  },
};
```

**Key CSF 3.0 advantages**: spreadable story objects (`...Primary.args`), default render functions (no boilerplate), automatic titles from file location, and play functions for interaction testing.

### MDX documentation patterns

Storybook MDX combines Markdown with JSX for rich documentation:

```mdx
import { Canvas, Meta, Controls } from '@storybook/addon-docs/blocks';
import * as ButtonStories from './Button.stories';

<Meta of={ButtonStories} />

# Button

A button triggers actions when clicked.

## Primary Variant

<Canvas of={ButtonStories.Primary} />

## Props

<Controls />
```

**Multi-component documentation:**
```mdx
import * as ListStories from './List.stories';
import * as ListItemStories from './ListItem.stories';

<Meta of={ListStories} />

# List Components

<Story of={ListStories.Filled} />

## List Item
<Story of={ListItemStories.Basic} meta={ListItemStories} />
```

### Design tokens documentation

The `storybook-design-token` addon extracts tokens from CSS custom properties:

```css
:root {
  /**
   * @tokens Colors
   * @presenter Color
   */
  --color-primary: #0066cc;
  
  /**
   * @tokens Spacing
   * @presenter Spacing
   */
  --spacing-md: 16px;
}
```

Built-in Storybook doc blocks also document design systems:

```mdx
import { ColorPalette, ColorItem, Typeset } from '@storybook/addon-docs/blocks';

<ColorPalette>
  <ColorItem
    title="Brand Colors"
    colors={{ Primary: '#0066cc', Secondary: '#6c757d' }}
  />
</ColorPalette>

<Typeset
  fontSizes={['12px', '16px', '24px']}
  fontWeight={400}
  sampleText="The quick brown fox"
/>
```

### Visual regression testing with Chromatic

Chromatic (chromatic.com) provides visual testing integrated with Storybook:

```yaml
# .github/workflows/chromatic.yml
- name: Publish to Chromatic
  uses: chromaui/action@v1
  with:
    projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
```

Chromatic captures snapshots of every story on each commit, highlighting visual differences in pull requests.

### Runbook structure standards from Google SRE

Based on Google SRE patterns and PagerDuty best practices, runbooks follow this structure:

```markdown
# [Service/Alert Name] Runbook

## Metadata
- **Last Updated:** YYYY-MM-DD
- **Owner:** Team/Individual
- **Severity Level:** SEV1/SEV2/SEV3

## Summary
One or two sentences describing WHAT is happening.

## Prerequisites
- Access requirements (SSH keys, permissions)
- Tools needed (CLI tools, dashboards)

## Triage & Severity Assessment
1. Investigation step one
2. Decision tree for severity classification

## Mitigation Steps
Steps to stop the situation from getting worse.

## Rollback Procedures
Specific steps to revert changes if mitigation fails.

## Validation
Indicators that health has been restored.

## Escalation Path
| Level | Contact | When to Escalate |
|-------|---------|------------------|
| L1 | On-call engineer | Initial response |
| L2 | Team lead | > 30 min unresolved |
```

The **Five A's** of effective runbooks: Actionable, Accessible, Accurate, Authoritative, Adaptable.

### Laravel deployment runbook template

```markdown
# Laravel Deployment Runbook

## Deployment Script (Forge Zero-Downtime)
```bash
cd $FORGE_SITE_PATH
$FORGE_PHP artisan down --retry=60

cd $FORGE_RELEASE_DIRECTORY
git pull origin $FORGE_SITE_BRANCH

$FORGE_COMPOSER install --no-dev --optimize-autoloader
$FORGE_PHP artisan migrate --force
$FORGE_PHP artisan config:cache
$FORGE_PHP artisan route:cache
$FORGE_PHP artisan queue:restart

npm ci && npm run build

$ACTIVATE_RELEASE()
$FORGE_PHP artisan up
```

## Rollback
```bash
# Symlink to previous release
ln -sfn releases/PREVIOUS_TIMESTAMP current
sudo service php8.2-fpm reload
php artisan migrate:rollback --force
```
```

---

## 6. Tier 3: Architecture Decision Records

### ADR format comparison

| Format | Complexity | Best For |
|--------|------------|----------|
| **Nygard** | Simple | Quick decisions |
| **MADR** | Medium | Detailed analysis with options |
| **Y-Statements** | Minimal | One-liner records |

**MADR (Markdown Any Decision Records) v4.0** is recommended for most teams:

```markdown
# Use React for Frontend Framework

## Status
Accepted

## Context and Problem Statement
We need to choose a frontend framework for our customer portal.

## Decision Drivers
* Team expertise and learning curve
* Performance requirements
* Ecosystem maturity

## Considered Options
* React
* Vue.js
* Angular

## Decision Outcome
Chosen option: "React", because it best balances team expertise
and ecosystem maturity.

### Consequences
* Good, because team has existing React experience
* Bad, because requires additional state management decisions

## Pros and Cons of Options

### React
* Good, because mature ecosystem
* Bad, because requires state management choice

### Vue.js
* Good, because simpler learning curve
* Bad, because smaller ecosystem
```

### ADR tooling recommendations

**Log4brains** (github.com/thomvaill/log4brains) is recommended for teams needing a published documentation site:

```bash
npm install -g log4brains
log4brains init
log4brains adr new "Use Redis for Caching"
log4brains preview  # Local preview
log4brains build    # Static site
```

**adr-tools** (github.com/npryce/adr-tools) provides simple CLI:

```bash
brew install adr-tools
adr init doc/architecture/decisions
adr new "Use PostgreSQL for Database"
```

Store ADRs in `docs/decisions/` alongside code, with Git workflow integration for review.

---

## 7. Documentation workflow

### End-to-end pipeline architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SOURCE CODE                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  BACKEND (Laravel)              FRONTEND (TypeScript)        │
│  PHPDoc → Scramble              TSDoc → TypeDoc              │
│       ↓                              ↓                       │
│  OpenAPI 3.1.0 spec             Markdown docs                │
│       ↓                              │                       │
│  Scribe (enhanced docs)              │                       │
│       ↓                              │                       │
│  openapi-typescript ←────────────────┘                       │
│       ↓                                                      │
│  TypeScript types for frontend                               │
│                                                              │
│  COMPONENTS                                                  │
│  React + MDX → Storybook CSF 3.0 → Stories + Docs           │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                    DOCUSAURUS PORTAL                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  docusaurus-openapi-docs plugin → /api/ MDX files           │
│  docusaurus-plugin-typedoc → /frontend/ MDX files           │
│  StorybookEmbed (iframe) → /components/ embedded stories    │
│                                                              │
│                         ↓                                    │
│              Docusaurus Build                                │
│                         ↓                                    │
│              Static Site (Vercel)                            │
└─────────────────────────────────────────────────────────────┘
```

### Shared OpenAPI spec as contract

The OpenAPI spec serves as the **single source of truth** for API contracts:

1. **Backend generates spec**: Scramble exports `openapi.yaml` on each build
2. **Frontend consumes spec**: openapi-typescript generates types, Orval generates hooks
3. **Breaking changes detected**: oasdiff compares specs in CI, fails on breaking changes
4. **Docs stay synchronized**: Docusaurus regenerates API docs from spec

This eliminates manual type synchronization—changing a Laravel endpoint automatically updates TypeScript types and documentation.

### CI/CD automation

```yaml
# .github/workflows/docs.yml
name: Documentation Pipeline

on:
  push:
    branches: [main]
    paths:
      - 'app/**'
      - 'openapi/**'
      - 'packages/**'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Generate OpenAPI from Laravel
      - name: Export OpenAPI spec
        run: php artisan scramble:export --path=openapi/api.yaml
      
      # Validate spec
      - name: Lint OpenAPI
        run: npx spectral lint openapi/api.yaml
      
      # Generate TypeScript types
      - name: Generate types
        run: npx openapi-typescript openapi/api.yaml -o packages/api-types/src/api.d.ts
      
      # Check for uncommitted changes
      - name: Verify generated files
        run: git diff --exit-code packages/api-types/
      
      # Build documentation portal
      - name: Generate API docs
        run: yarn docusaurus gen-api-docs all
      
      - name: Build Docusaurus
        run: yarn build
      
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          publish_dir: ./build
```

---

## 8. Unified portal with Docusaurus

### Multi-project structure

```
docs-website/
├── docs/
│   ├── api/              # Generated from OpenAPI
│   │   ├── backend/
│   │   └── legacy/
│   ├── frontend/         # Generated from TypeDoc
│   ├── components/       # Storybook embeds
│   └── guides/           # Manual documentation
├── docusaurus.config.ts
└── sidebars.ts
```

### OpenAPI plugin configuration

```typescript
// docusaurus.config.ts
export default {
  plugins: [
    [
      'docusaurus-plugin-openapi-docs',
      {
        id: "api",
        docsPluginId: "classic",
        config: {
          backend: {
            specPath: "openapi/backend-api.yaml",
            outputDir: "docs/api/backend",
            sidebarOptions: {
              groupPathsBy: "tag",
              categoryLinkSource: "tag",
            },
            downloadUrl: "/openapi/backend-api.yaml",
          },
          legacy: {
            specPath: "openapi/slim-api.yaml",
            outputDir: "docs/api/legacy",
          },
        },
      },
    ],
  ],
  themes: ["docusaurus-theme-openapi-docs"],
};
```

Generate docs with: `yarn docusaurus gen-api-docs all`

### Search integration options

**Algolia DocSearch** (recommended for public sites):
```typescript
themeConfig: {
  algolia: {
    appId: 'YOUR_APP_ID',
    apiKey: 'YOUR_SEARCH_API_KEY',
    indexName: 'YOUR_INDEX_NAME',
    contextualSearch: true,
  },
}
```

**Local search** with @easyops-cn/docusaurus-search-local:
```typescript
themes: [[
  require.resolve("@easyops-cn/docusaurus-search-local"),
  {
    hashed: true,
    indexDocs: true,
    docsRouteBasePath: ["/docs", "/api"],
  },
]],
```

### Storybook embedding pattern

```tsx
// src/components/StorybookEmbed.tsx
export default function StorybookEmbed({ story, height = 400 }) {
  const baseUrl = process.env.NODE_ENV === 'production'
    ? 'https://storybook.example.com'
    : 'http://localhost:6006';
  
  return (
    <iframe
      src={`${baseUrl}/iframe.html?id=${story}&viewMode=story`}
      style={{ width: '100%', height: `${height}px`, border: '1px solid #ddd' }}
    />
  );
}
```

Usage in MDX:
```mdx
import StorybookEmbed from '@site/src/components/StorybookEmbed';

## Button Component

<StorybookEmbed story="components-button--primary" height={300} />
```

### Alternatives comparison

| Feature | Docusaurus | Mintlify | GitBook | ReadMe |
|---------|-----------|----------|---------|--------|
| **Pricing** | Free (OSS) | $300/mo Pro | $6.70/user/mo | Custom |
| **OpenAPI** | Plugin | Built-in | Basic | Built-in |
| **Customization** | Full (React) | Limited | Limited | Limited |
| **Best For** | Full control, OSS | Beautiful docs fast | Mixed teams | API-first |

**Choose Docusaurus** if you have React developers, need full customization, and want zero licensing costs.

---

## 9. Template recommendations

### README template with required/optional fields

```yaml
# readme-template-schema.yaml
required:
  - title
  - short_description
  - installation
  - usage
  - license

optional:
  - badges
  - table_of_contents  # Required if >100 lines
  - features
  - api_reference
  - contributing
  - acknowledgments
```

**Filled example:**
```markdown
# @myorg/component-library

[![Build](https://img.shields.io/github/actions/workflow/status/myorg/components/ci.yml)](...)
[![npm](https://img.shields.io/npm/v/@myorg/component-library)](...)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](...)

> Production-ready React components for the MyOrg design system.

## Features
- ✨ 50+ accessible components
- 🎨 Themeable with CSS custom properties
- 📦 Tree-shakeable ESM builds

## Installation
```bash
npm install @myorg/component-library
```

## Usage
```tsx
import { Button } from '@myorg/component-library';

export default () => <Button variant="primary">Click me</Button>;
```

## License
MIT © MyOrg
```

### API endpoint documentation template

```yaml
# api-doc-template-schema.yaml
required:
  - endpoint_path
  - method
  - description
  - response_schema

optional:
  - authentication
  - request_body
  - query_parameters
  - path_parameters
  - example_request
  - example_response
  - error_responses
```

### Component documentation template

```yaml
# component-doc-template-schema.yaml
required:
  - component_name
  - description
  - props_table
  - basic_example

optional:
  - variants
  - accessibility
  - design_tokens
  - related_components
  - storybook_link
```

### Runbook template

```yaml
# runbook-template-schema.yaml
required:
  - title
  - summary
  - prerequisites
  - mitigation_steps
  - escalation_path

optional:
  - severity_assessment
  - rollback_procedures
  - validation_steps
  - related_documentation
```

### ADR template (MADR)

```yaml
# adr-template-schema.yaml
required:
  - title
  - status  # enum: proposed, accepted, deprecated, superseded
  - context
  - decision
  - consequences

optional:
  - decision_drivers
  - considered_options
  - pros_cons_analysis
  - confirmation_criteria
```

---

## 10. Quality gates and validation checklist

### Laravel API quality gates

| Gate | Tool | Threshold | Command |
|------|------|-----------|---------|
| All endpoints documented | Scramble | 100% coverage | `php artisan scramble:export` |
| Custom response schemas | Manual review | Per endpoint | — |
| Auth flows documented | Scramble config | All auth routes | Check `SecurityScheme` |
| OpenAPI valid | Spectral | 0 errors | `spectral lint api.yaml` |
| Scribe examples current | Scribe | All endpoints | `php artisan scribe:generate` |

### TypeScript frontend quality gates

| Gate | Tool | Threshold | Command |
|------|------|-----------|---------|
| Public APIs have TSDoc | TypeDoc | 100% exports | `typedoc --validation.notDocumented` |
| Components have stories | Storybook | All components | Custom script |
| Types from OpenAPI | openapi-typescript | No manual types | `git diff --exit-code` |
| Breaking changes detected | oasdiff | 0 ERR in CI | `oasdiff breaking` |
| TypeScript compiles | tsc | 0 errors | `tsc --noEmit` |
| Storybook builds | Storybook | Success | `npm run build-storybook` |

### Unified portal quality gates

| Gate | Tool | Threshold | Command |
|------|------|-----------|---------|
| All projects documented | Docusaurus | Build success | `yarn build` |
| Cross-doc search works | Algolia/local | Indexed | Manual test |
| No broken links | linkinator | 0 broken | `linkinator ./build --recurse` |
| API reference current | Docusaurus | Sync with spec | `yarn gen-api-docs all` |
| Prose quality | Vale | Custom rules | `vale docs/` |
| Markdown valid | markdownlint | 0 errors | `markdownlint docs/` |

### CI/CD pipeline implementation

```yaml
name: Documentation Quality Gates
on:
  pull_request:
    paths: ['docs/**', 'openapi/**', 'packages/**/src/**']

jobs:
  quality-gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Gate 1: OpenAPI Validation
      - run: npx @redocly/cli lint openapi/*.yaml
      
      # Gate 2: TypeScript Validation
      - run: npm run typecheck
      
      # Gate 3: Storybook Build
      - run: npm run build-storybook
      
      # Gate 4: Docusaurus Build
      - run: npm run build
      
      # Gate 5: Link Check
      - run: npx linkinator ./build --recurse --skip "^(?!http)"
      
      # Gate 6: Generated Files Sync
      - run: |
          npm run generate-types
          git diff --exit-code packages/api-types/
```

---

## 11. AI generation patterns and failure modes

### Laravel 10 vs 11 hallucination prevention

| Aspect | Laravel 10 (Target) | Laravel 11 | AI Mistake |
|--------|---------------------|------------|------------|
| Middleware | `app/Http/Kernel.php` | `bootstrap/app.php` | Using L11 syntax |
| api.php | Present by default | Opt-in | Assuming missing |
| Service providers | 5 default | Single `AppServiceProvider` | Wrong registration |
| Rate limiting | `decayMinutes` | `decaySeconds` | Wrong time unit |

**Validation**: Check `composer.json` for `"laravel/framework": "^10.0"` before generating.

### Storybook CSF 2 vs 3 differences

| CSF 2 (Legacy) | CSF 3 (Current) |
|----------------|-----------------|
| `Template.bind({})` | Object spread `{ ...Primary }` |
| `ComponentMeta`, `ComponentStory` | `Meta`, `StoryObj` |
| Explicit render function | Default render (optional) |
| Manual title | Automatic from file path |

**Validation**: Check `@storybook/react` version in `package.json`. Version 7+ uses CSF 3.

### TypeScript 5.x feature accuracy

| Feature | Version | Common Mistake |
|---------|---------|----------------|
| `satisfies` operator | 4.9+ | Assuming 5.0 |
| Stage 3 decorators | 5.0+ | Using experimental decorators |
| `isolatedDeclarations` | 5.5+ | Assuming earlier |
| ES2024 target | 5.7+ | Using with older TS |

**Validation**: Run `tsc --version` and verify features against release notes.

### React 18 concurrent features

| Feature | Requirement | Mistake |
|---------|-------------|---------|
| Concurrent rendering | `createRoot` API | Using `ReactDOM.render` |
| Server Components | Framework support | Assuming universal support |
| `useTransition` | React 18+ | Using in React 17 |

**Validation**: Check `"react": "^18.0.0"` and verify `createRoot` usage.

### Validation automation

```yaml
# Pre-generation validation script
validate-environment:
  - run: |
      # Check Laravel version
      composer show laravel/framework | grep -E "^versions" | grep "10\."
      
      # Check TypeScript version
      npx tsc --version | grep -E "^Version 5\."
      
      # Check React version
      npm list react | grep -E "react@18\."
      
      # Check Storybook version
      npm list @storybook/react | grep -E "@storybook/react@[78]\."
```

### Post-generation validation

1. **TypeScript examples**: `tsc --noEmit` on all code blocks
2. **PHP examples**: `php -l` syntax check
3. **OpenAPI specs**: `spectral lint` validates generated specs
4. **Storybook stories**: `npm run build-storybook` confirms compilation
5. **Docusaurus links**: `onBrokenLinks: 'throw'` in config catches dead links

---

## 12. Tool integration reference

### Primary toolchain

| Layer | Tool | Purpose | Integration Point |
|-------|------|---------|-------------------|
| **Backend API** | Scramble | OpenAPI generation | PHPDoc → OpenAPI 3.1.0 |
| **Backend Docs** | Scribe | Human-readable docs | OpenAPI → HTML/Postman |
| **OpenAPI Lint** | Spectral | Spec validation | CI/CD gate |
| **Type Generation** | openapi-typescript | TS types from spec | OpenAPI → .d.ts |
| **API Client** | Orval | React Query hooks | OpenAPI → hooks |
| **Frontend Docs** | TypeDoc | TS library docs | TSDoc → Markdown |
| **Components** | Storybook | Component docs | CSF 3.0 → stories |
| **Visual Testing** | Chromatic | Snapshot testing | Stories → screenshots |
| **Portal** | Docusaurus | Unified docs site | All → static site |
| **Search** | Algolia | Doc search | Docusaurus plugin |
| **Breaking Changes** | oasdiff | API diff | CI/CD gate |

### Configuration files reference

| File | Purpose |
|------|---------|
| `config/scramble.php` | Scramble configuration |
| `config/scribe.php` | Scribe configuration |
| `.spectral.yaml` | OpenAPI linting rules |
| `orval.config.ts` | API client generation |
| `typedoc.json` | TypeDoc configuration |
| `.storybook/main.ts` | Storybook configuration |
| `docusaurus.config.ts` | Docusaurus configuration |
| `.vale.ini` | Prose linting rules |

### NPM packages

```json
{
  "devDependencies": {
    "openapi-typescript": "^7.0.0",
    "orval": "^7.0.0",
    "typedoc": "^0.26.0",
    "typedoc-plugin-markdown": "^4.0.0",
    "@storybook/react": "^8.0.0",
    "@stoplight/spectral-cli": "^6.0.0",
    "oasdiff": "^1.0.0",
    "docusaurus-plugin-openapi-docs": "^4.0.0",
    "docusaurus-theme-openapi-docs": "^4.0.0",
    "@easyops-cn/docusaurus-search-local": "^0.44.0"
  }
}
```

### Composer packages

```json
{
  "require-dev": {
    "dedoc/scramble": "^0.13.0",
    "knuckleswtf/scribe": "^4.0.0",
    "zircote/swagger-php": "^4.0.0"
  }
}
```

---

## 13. Key resources and references

### Official documentation

- **Scramble**: scramble.dedoc.co
- **Scribe**: scribe.knuckles.wtf/laravel
- **TypeDoc**: typedoc.org
- **TSDoc**: tsdoc.org
- **openapi-typescript**: openapi-ts.dev
- **Orval**: orval.dev
- **Storybook**: storybook.js.org/docs
- **Docusaurus**: docusaurus.io/docs
- **Spectral**: github.com/stoplightio/spectral
- **oasdiff**: github.com/oasdiff/oasdiff

### Standards and frameworks

- **Diátaxis**: diataxis.fr
- **Google Developer Documentation Style Guide**: developers.google.com/style
- **Microsoft Writing Style Guide**: learn.microsoft.com/style-guide
- **The Good Docs Project**: thegooddocsproject.dev
- **Standard-Readme**: github.com/RichardLitt/standard-readme
- **MADR**: adr.github.io/madr

### Exemplary documentation sites

- **Stripe API**: docs.stripe.com/api — Multi-language samples, interactive testing
- **Twilio**: twilio.com/docs — Product-organized navigation
- **GitHub REST API**: docs.github.com/en/rest — OpenAPI-driven
- **Laravel**: laravel.com/docs — Version switching, clear examples
- **Shopify Polaris**: polaris.shopify.com — Component + design token docs
- **Adobe Spectrum**: react-spectrum.adobe.com — Accessibility-first

### GitHub repositories for ADRs and runbooks

- **Joel Parker Henderson's ADR collection**: github.com/joelparkerhenderson/architecture-decision-record
- **MADR templates**: github.com/adr/madr
- **Log4brains**: github.com/thomvaill/log4brains
- **adr-tools**: github.com/npryce/adr-tools
- **PagerDuty Incident Response**: response.pagerduty.com
- **Google SRE Book**: sre.google/workbook