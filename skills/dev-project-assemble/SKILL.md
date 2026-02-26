---
name: dev-project-assemble
description: Wire scaffold outputs into runnable project structure with configs and entry points. Use when assembling project from scaffolds.
allowed-tools: Read, Glob, Grep, Write(src/**), Write(prisma/**), Write(package.json), Write(tsconfig.json), Write(next.config.*), Write(tailwind.config.*), Write(.env.example), Write(.gitignore), Write($JAAN_OUTPUTS_DIR/dev/project-assemble/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [backend-scaffold, frontend-scaffold] [backend-api-contract] [target-dir]
disable-model-invocation: true
license: PROPRIETARY
---

# dev-project-assemble

> Wire backend + frontend scaffold outputs into a runnable project with proper directory tree, configs, and entry points.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL -- determines framework, monorepo tool, package manager)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to-dev-project-assemble.template.md` - Output template (assembly log)
- `$JAAN_LEARN_DIR/jaan-to-dev-project-assemble.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- `${CLAUDE_PLUGIN_ROOT}/docs/research/69-dev-scaffold-project-assembly-automation.md` - Research: monorepo patterns, entry points, provider wiring, config inheritance, .env validation

## Input

**Upstream Artifacts**: $ARGUMENTS

Accepts 2-3 file paths or descriptions plus optional target directory:
- **backend-scaffold** -- Path to backend scaffold output folder (from `/jaan-to:backend-scaffold` output: `$JAAN_OUTPUTS_DIR/backend/scaffold/{id}-{slug}/`)
- **frontend-scaffold** -- Path to frontend scaffold output folder (from `/jaan-to:frontend-scaffold` output: `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`)
- **frontend-design** -- Path to HTML previews (from `/jaan-to:frontend-design` output, optional)
- **backend-api-contract** — Optional OpenAPI spec path (from /jaan-to:backend-api-contract output). Enables API documentation page generation.
- **target-dir** -- Target project directory (default: current working directory)
- **Empty** -- Interactive wizard prompting for each

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `dev-project-assemble`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` -- Know the tech stack for framework-specific assembly
- `$JAAN_CONTEXT_DIR/config.md` -- Project configuration
- `${CLAUDE_PLUGIN_ROOT}/docs/research/69-dev-scaffold-project-assembly-automation.md` -- Research reference for assembly patterns

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_dev-project-assemble`

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing scaffold outputs to determine file splitting strategy
- Planning monorepo vs single-project structure
- Mapping bundled scaffold files to individual project files
- Detecting provider wiring order from dependencies
- Planning config inheritance chains

## Step 1: Validate & Parse Scaffold Inputs

For each provided path:

**backend-scaffold**: Read all files in the scaffold folder:
- `{id}-{slug}.md` -- Main doc (setup guide, architecture)
- `{id}-{slug}-routes.ts` -- Route handlers
- `{id}-{slug}-services.ts` -- Service layer
- `{id}-{slug}-schemas.ts` -- Validation schemas
- `{id}-{slug}-middleware.ts` -- Auth + error handling
- `{id}-{slug}-prisma.prisma` -- ORM data model
- `{id}-{slug}-config.ts` -- Package.json + tsconfig content
- `{id}-{slug}-readme.md` -- Setup instructions

**frontend-scaffold**: Read all files in the scaffold folder:
- `{id}-{slug}.md` -- Main doc (architecture, component map)
- `{id}-{slug}-components.tsx` -- React components
- `{id}-{slug}-hooks.ts` -- Typed API client hooks
- `{id}-{slug}-types.ts` -- TypeScript interfaces
- `{id}-{slug}-pages.tsx` -- Page layouts / routes
- `{id}-{slug}-config.ts` -- Package.json + tsconfig + tailwind config
- `{id}-{slug}-readme.md` -- Setup instructions

**frontend-design** (optional): Read HTML preview files for visual reference.

Report which inputs found vs missing:
```
INPUT SUMMARY
-------------
Sources Found:    {list}
Sources Missing:  {list with fallback suggestions}
Backend Files:    {count}
Frontend Files:   {count}
Design Files:     {count or "none"}
Entities:         {extracted entity names from backend}
Components:       {extracted component names from frontend}
```

## Step 2: Detect Tech Stack

Read `$JAAN_CONTEXT_DIR/tech.md`:
- Extract backend framework from `#current-stack` (default: Fastify v5 + Node.js)
- Extract frontend framework from `#current-stack` (default: React v19 + Next.js v15)
- Extract package manager (default: pnpm)
- Extract monorepo tool preference (Turborepo / Nx / none)
- Extract DB from `#current-stack` (default: PostgreSQL + Prisma)
- Extract styling from `#current-stack` (default: TailwindCSS v4)
- Extract patterns from `#patterns` (auth, error handling, state management)
- If tech.md missing: ask framework/package manager via AskUserQuestion

Determine primary stack from tech.md:

| tech.md value | Backend | Frontend | Package Manager |
|---------------|---------|----------|-----------------|
| Node.js / TypeScript | Fastify v5+ | Next.js v15+ | pnpm |
| PHP | Laravel 12 / Symfony 7 | Next.js v15+ (or Blade/Inertia) | composer + pnpm |
| Go | Chi / stdlib | Next.js v15+ | go mod + pnpm |

## Step 3: Clarify Project Structure

AskUserQuestion:
- Question: "How should the project be structured?"
- Header: "Project Structure"
- Options:
  - "Monorepo (Turborepo + pnpm workspaces)" -- Recommended for full-stack TypeScript
  - "Monorepo (Nx)" -- For teams needing generator ecosystem
  - "Separate projects" -- Backend and frontend in separate directories
  - "Single project (Next.js with API routes)" -- Frontend-first, backend collocated

Based on selection, determine directory layout:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Directory Layout Templates" for monorepo and separate project directory trees.

## Step 4: Plan File Splitting

Map bundled scaffold files to individual project files:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "File Splitting Maps" for scaffold-to-project file mapping tables.

Present file tree:
```
FILE SPLIT PLAN
===============

BACKEND ({count} files)
-----------------------
{numbered list with source -> target mapping}

FRONTEND ({count} files)
------------------------
{numbered list with source -> target mapping}

GENERATED ENTRY POINTS ({count} files)
---------------------------------------
{numbered list}

CONFIG FILES ({count} files)
----------------------------
{numbered list}

TOTAL: {count} files to write
```

## Step 5: Plan Provider Wiring

Detect required providers from scaffold dependencies:

**Frontend providers (ordered by dependency):**
1. **Session/Auth** (outermost) -- if `next-auth` or auth hooks detected
2. **Theme** -- if `next-themes` detected
3. **Data layer** -- TanStack Query `QueryClientProvider` + optional tRPC
4. **State stores** -- Zustand (no provider needed) / other

**Backend plugins (ordered by registration):**
1. **Infrastructure** -- CORS, compression, logging
2. **Auth** -- JWT verification, session
3. **Database** -- Prisma singleton
4. **Routes** -- Autoload or manual registration

Present wiring plan:
```
PROVIDER WIRING
===============

Frontend (providers.tsx):
  1. {Provider} -- {reason}
  2. {Provider} -- {reason}
  ...

Backend (app.ts plugin registration):
  1. {Plugin} -- {reason}
  2. {Plugin} -- {reason}
  ...
```

---

# HARD STOP -- Review Assembly Plan

Use AskUserQuestion:
- Question: "Review the assembly plan. Proceed with writing files to the project?"
- Header: "Assemble Project"
- Options:
  - "Yes" -- Write all files to the project directory
  - "No" -- Cancel
  - "Edit" -- Let me revise the structure, file splitting, or wiring

Present full summary:
```
ASSEMBLY PLAN SUMMARY
=====================

Project Structure:  {monorepo / separate / single}
Target Directory:   {path}
Package Manager:    {pnpm / npm / yarn}
Backend Stack:      {framework + DB + ORM}
Frontend Stack:     {framework + styling + state}

FILES TO WRITE
--------------
Backend:       {count} files
Frontend:      {count} files
Entry Points:  {count} files (generated)
Configs:       {count} files (generated)
Total:         {count} files

PROVIDERS
---------
Frontend: {list}
Backend:  {list}

ENVIRONMENT VARIABLES
---------------------
{list of all .env variables with descriptions}
```

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Split Backend Scaffold Files

Read each bundled backend scaffold file and split into individual project files:

### 6.1: Routes
Parse `{id}-{slug}-routes.ts` and split per resource:
- For each resource endpoint group, create:
  - `{target}/src/routes/{resource}/index.ts` -- Route handler
  - Import from collocated schema and service files

### 6.2: Schemas
Parse `{id}-{slug}-schemas.ts` and split per resource:
- For each resource schema group, create:
  - `{target}/src/routes/{resource}/{resource}.schema.ts` -- Zod schemas + inferred types

### 6.3: Services
Parse `{id}-{slug}-services.ts` and split per resource:
- For each resource service group, create:
  - `{target}/src/routes/{resource}/{resource}.service.ts` -- Business logic with Prisma

### 6.4: Middleware to Plugins
Parse `{id}-{slug}-middleware.ts` and create:
- `{target}/src/plugins/auth.ts` -- Auth plugin (fastify-plugin wrapped)
- `{target}/src/plugins/error-handler.ts` -- Error handler (RFC 9457)
- `{target}/src/plugins/cors.ts` -- CORS configuration (if not inline)

### 6.5: Prisma
Copy `{id}-{slug}-prisma.prisma` to:
- `{target}/prisma/schema.prisma`
- Generate `{target}/prisma/seed.ts` with placeholder seed data

## Step 7: Generate Backend Entry Points

Create entry points that wire everything together:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Backend Entry Point Templates" for app.ts, server.ts, and env.ts code templates.

## Step 8: Split Frontend Scaffold Files

Read each bundled frontend scaffold file and split into individual project files:

### 8.1: Components
Parse `{id}-{slug}-components.tsx` and split per component:
- Detect atomic level (atom/molecule/organism)
- Create: `{target}/src/components/{level}/{ComponentName}.tsx`
- Add `'use client'` directive only where needed

### 8.2: Hooks
Parse `{id}-{slug}-hooks.ts` and create:
- `{target}/src/lib/api/hooks.ts` -- TanStack Query hooks
- `{target}/src/lib/api/query-client.ts` -- Query client configuration

### 8.3: Types
Parse `{id}-{slug}-types.ts` and create:
- `{target}/src/types/api.ts` -- API response/request types
- In monorepo: `packages/types/src/index.ts`

### 8.4: Pages
Parse `{id}-{slug}-pages.tsx` and split per route:
- `{target}/src/app/{route}/page.tsx`
- `{target}/src/app/{route}/layout.tsx` (where needed)
- `{target}/src/app/{route}/loading.tsx` (skeleton states)

## Step 9: Generate Frontend Entry Points

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Frontend Entry Point Templates" for layout, providers, page, global.css, and env.ts code templates.

## Step 10: Generate Config Files

### 10.1: Root `package.json`
- Monorepo: Root with workspaces, Turborepo scripts
- Separate: Individual per project
- Include all dependencies from scaffold configs
- Standard scripts: dev, build, start, lint, type-check, clean

### 10.2: `tsconfig.json`
- Monorepo: Base config in `tooling/typescript/`, extended per app
- Separate: Individual per project
- Strict mode, correct module resolution per stack

### 10.3: `next.config.ts`
- React compiler (if React 19) — ensure `babel-plugin-react-compiler` is in devDependencies when `reactCompiler: true`
- Transpile packages (monorepo)
- Image domains, rewrites as needed
- Check tech.md `#current-stack` — PHP/Go projects may have equivalent config-implied dependencies (see reference)

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Build Plugin Detection" for multi-stack config-implied dependency detection.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Config File Content Patterns" for .env.example, .gitignore, and monorepo-specific config content.

## Step 10.4: Generate API Documentation Page (if backend-api-contract provided AND Node.js/TS)

**Condition**: Only when `backend-api-contract` is in inputs AND `$JAAN_CONTEXT_DIR/tech.md` indicates Node.js/TypeScript stack.

### Next.js projects:
1. Generate `src/app/reference/route.ts` — Scalar API reference route:
   ```typescript
   import { ApiReference } from '@scalar/nextjs-api-reference';
   const config = { url: '/api/openapi.json', theme: 'moon' };
   export const GET = ApiReference(config);
   ```
2. Generate `src/app/api/openapi/route.ts` — spec serving route:
   ```typescript
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
3. Add `@scalar/nextjs-api-reference` and `js-yaml` to `package.json` dependencies

### Other Node.js (Express/Fastify):
- Add setup instructions to readme output (no direct file writes)

### Non-Node stacks:
- Emit API docs setup instructions in output readme only — do NOT attempt writes

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/openapi-integration-reference.md` section "Scalar API Documentation".

## Step 11: Quality Check

Before preview, verify:
- [ ] All bundled scaffold files have been split into individual files
- [ ] No code from scaffold files was lost during splitting
- [ ] Backend entry points wire all plugins and routes correctly
- [ ] Frontend providers are nested in correct dependency order
- [ ] All imports use correct relative paths and file extensions
- [ ] TypeScript config has correct module resolution for the stack
- [ ] Package.json includes all dependencies from both scaffolds
- [ ] .env.example documents every environment variable
- [ ] .gitignore covers all build artifacts and secrets
- [ ] Monorepo config (if selected) has correct workspace paths
- [ ] No hardcoded paths or placeholder TODOs remain in generated code
- [ ] Config-implied build dependencies present in dependency manifest

If any check fails, fix before preview.

## Step 12: Preview & Approval

Present complete file list with sizes and key content:
```
ASSEMBLY PREVIEW
================

{target}/
  {full directory tree with file sizes}

Key Generated Files:
  - src/app.ts: {brief description}
  - src/app/layout.tsx: {brief description}
  - src/app/providers.tsx: {providers listed}
  - package.json: {dependency count}
  - .env.example: {variable count}
```

Use AskUserQuestion:
- Question: "Write all files to the project directory?"
- Header: "Write Files"
- Options:
  - "Yes" -- Write all files
  - "No" -- Cancel
  - "Refine" -- Make adjustments first

## Step 13: Write Project Files

If approved:
1. Create directory structure
2. Write all backend files (routes, schemas, services, plugins, entry points)
3. Write all frontend files (components, hooks, types, pages, entry points)
4. Write config files (package.json, tsconfig.json, next.config.ts, etc.)
5. Write .env.example and .gitignore
6. Write monorepo configs if applicable (turbo.json, pnpm-workspace.yaml)

Confirm each batch:
> Backend files written: {count} files
> Frontend files written: {count} files
> Config files written: {count} files

## Step 14: Generate Assembly Log

Write assembly log to `$JAAN_OUTPUTS_DIR/dev/project-assemble/`:

### 14.1: Generate ID and Folder Structure
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/dev/project-assemble"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{project-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

### 14.2: Write Assembly Log
Write `{NEXT_ID}-{slug}.md` with:
- Executive Summary
- Input scaffolds used
- Project structure chosen
- File manifest (every file written with path)
- Provider wiring map
- Config inheritance chain
- Environment variables documented
- Next steps for the developer

### 14.3: Update Index
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project Title}" \
  "{Executive summary -- 1-2 sentences}"
```

Confirm:
> Assembly log written to: `$JAAN_OUTPUTS_DIR/dev/project-assemble/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> Index updated: `$JAAN_OUTPUTS_DIR/dev/project-assemble/README.md`

## Step 15: Suggest Next Actions

> **Project assembled successfully!**
>
> **Immediate Steps:**
> - Run `pnpm install` (or `npm install`) to install dependencies
> - Copy `.env.example` to `.env.local` and fill in values
> - Run `pnpm db:generate && pnpm db:push` to set up database
> - Run `pnpm dev` to start development
>
> **Next Skills in Pipeline:**
> - Run `/jaan-to:backend-service-implement` to fill in service layer business logic
> - Run `/jaan-to:qa-test-generate` to generate test suites
> - Run `/jaan-to:devops-infra-scaffold` to generate deployment configs

## Step 16: Capture Feedback

Use AskUserQuestion:
- Question: "How did the assembly turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I adjust?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add dev-project-assemble "{feedback}"`

---

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-project-assemble-reference.md` section "Multi-Stack Assembly Rules" for Node.js/TypeScript, PHP/Laravel, and Go stack-specific assembly patterns.

## Anti-Patterns to NEVER Generate

- **File splitting**: Losing code during bundled-to-individual file conversion
- **Imports**: Wrong relative paths, missing `.js` extensions in ESM
- **Providers**: Wrong nesting order (auth must be outermost)
- **Config**: Hardcoded values instead of environment variables
- **Monorepo**: Circular dependencies between packages
- **TypeScript**: `any` types, loose module resolution
- **.env**: Committing secrets, missing variables in .env.example
- **Entry points**: Business logic in entry points (keep thin)

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] All bundled scaffold files split into individual project files
- [ ] Backend entry points generated (app.ts, server.ts, env.ts)
- [ ] Frontend entry points generated (layout.tsx, providers.tsx, page.tsx)
- [ ] Provider wiring in correct dependency order
- [ ] All config files generated (package.json, tsconfig.json, etc.)
- [ ] .env.example documents every required variable
- [ ] .gitignore covers all build artifacts
- [ ] Monorepo config generated (if applicable)
- [ ] No code lost during file splitting
- [ ] Assembly log written to output directory
- [ ] Index updated with executive summary
- [ ] User approved final result
