---
name: jaan-to-dev-stack-detect
description: |
  Auto-detect project tech stack and populate jaan.to context files.
  Scans languages, frameworks, databases, infrastructure, CI/CD, and integrations.
  Auto-triggers on: detect stack, scan project, setup context, analyze tech
  Maps to: dev:stack-detect
allowed-tools: Read, Glob, Grep, Bash(git remote:*), Bash(ls:*), Write($JAAN_CONTEXT_DIR/**), Edit($JAAN_CONTEXT_DIR/**), Write($JAAN_OUTPUTS_DIR/dev/**)
argument-hint: [optional-focus-area]
---

# dev:stack-detect

> Auto-detect project tech stack and populate jaan.to context files.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Technology stack (primary output target)
- `$JAAN_CONTEXT_DIR/integrations.md` - External tools and integrations
- `$JAAN_CONTEXT_DIR/boundaries.md` - Safe write paths
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_LEARN_DIR/jaan-to-dev-stack-detect.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-dev-stack-detect.template.md` - Detection report template

## Input

**Focus Area**: $ARGUMENTS

If a focus area is provided (e.g., "backend", "frontend", "infrastructure"), limit detection to that area only. Otherwise, scan everything.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-dev-stack-detect.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add detection patterns from "Better Questions"
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 1: Detection (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing detected dependencies and mapping to stack sections
- Resolving version conflicts or migration detection
- Confidence scoring
- Planning merge strategy for customized sections

## Step 1: Read Current Context Files

Read all four context files to classify each section:

1. Read `$JAAN_CONTEXT_DIR/tech.md`
2. Read `$JAAN_CONTEXT_DIR/integrations.md`
3. Read `$JAAN_CONTEXT_DIR/boundaries.md`
4. Read `$JAAN_CONTEXT_DIR/config.md`

**Classify each section** as one of:

| State | Detection Rule | Example |
|-------|---------------|---------|
| **empty** | Contains `{placeholder}` syntax or template defaults | `- **Language**: Python 3.11` (unchanged seed) |
| **customized** | Values differ from seed template defaults | `- **Language**: Go 1.22` (user edited) |
| **missing** | Section header does not exist | No `### Mobile` section |

To detect **empty vs customized**: Compare against the known seed template values. If values exactly match the seed defaults (Python 3.11, FastAPI 0.104, PostgreSQL 15, TypeScript 5.2, React 18, Next.js 14, etc.), treat as empty/placeholder. If values differ, treat as customized.

## Step 2: Scan Config Files (Layer 1 — 95-100% confidence)

Use **Glob** to find manifest files, then **Read** each one:

### Node.js / TypeScript
- Glob: `**/package.json` (exclude `node_modules/`)
- Extract: name, dependencies, devDependencies
- Detect frameworks: react, next, vue, angular, svelte, express, nestjs, fastify, hono
- Detect state: redux, zustand, recoil, jotai, mobx
- Detect styling: tailwindcss, styled-components, emotion, sass
- Detect build: vite, webpack, turbopack, esbuild, rollup
- Detect testing: jest, vitest, mocha, cypress, playwright
- Detect TypeScript from: `typescript` in deps OR `tsconfig.json` exists

### Python
- Glob: `**/pyproject.toml`, `**/requirements.txt`, `**/Pipfile`, `**/setup.py`, `**/setup.cfg`
- Extract: dependencies, dev-dependencies
- Detect frameworks: fastapi, django, flask, starlette, litestar, tornado
- Detect ORM: sqlalchemy, django-orm, tortoise-orm, peewee
- Detect testing: pytest, unittest, nose2, tox
- Detect version from: `python_requires` or `[tool.poetry.dependencies].python`

### Go
- Glob: `**/go.mod`
- Extract: module name, go version, require statements
- Detect frameworks: gin, echo, fiber, chi, gorilla/mux

### Rust
- Glob: `**/Cargo.toml`
- Extract: package name, edition, dependencies
- Detect frameworks: actix-web, axum, rocket, warp, tokio

### Ruby
- Glob: `**/Gemfile`
- Extract: gems
- Detect frameworks: rails, sinatra, hanami

### Java / Kotlin
- Glob: `**/pom.xml`, `**/build.gradle`, `**/build.gradle.kts`
- Detect: spring-boot, quarkus, micronaut, ktor

### PHP
- Glob: `**/composer.json`
- Detect: laravel, symfony, slim

### C# / .NET
- Glob: `**/*.csproj`, `**/*.sln`
- Detect: aspnet, blazor, maui

### Dart / Flutter
- Glob: `**/pubspec.yaml`
- Detect: flutter

### Elixir
- Glob: `**/mix.exs`
- Detect: phoenix

### Swift
- Glob: `**/Package.swift`
- Detect: vapor, swiftui

## Step 3: Scan Docker & Databases (Layer 2 — 90-95% confidence)

- Glob: `**/docker-compose.yml`, `**/docker-compose.yaml`, `**/docker-compose.*.yml`
- Read and parse service definitions
- Detect databases from image names:
  - `postgres` → PostgreSQL (extract version from tag)
  - `mysql` / `mariadb` → MySQL/MariaDB
  - `mongo` → MongoDB
  - `redis` → Redis
  - `rabbitmq` → RabbitMQ
  - `elasticsearch` / `opensearch` → Elasticsearch/OpenSearch
  - `memcached` → Memcached
  - `minio` → MinIO (S3-compatible storage)
  - `localstack` → AWS services (local development)

- Glob: `**/Dockerfile`, `**/Dockerfile.*`
- Extract: base image, runtime version

## Step 4: Scan CI/CD & Testing (Layer 3 — 90-95% confidence)

### CI/CD
- Glob: `.github/workflows/*.yml` → GitHub Actions
- Glob: `.gitlab-ci.yml` → GitLab CI
- Glob: `.circleci/config.yml` → CircleCI
- Glob: `Jenkinsfile` → Jenkins
- Glob: `.travis.yml` → Travis CI
- Glob: `bitbucket-pipelines.yml` → Bitbucket Pipelines
- Glob: `azure-pipelines.yml` → Azure DevOps

### Testing (if not already detected from deps)
- Glob: `jest.config.*`, `vitest.config.*` → JS test runners
- Glob: `pytest.ini`, `conftest.py`, `pyproject.toml` (check `[tool.pytest]`) → Python testing
- Glob: `playwright.config.*` → Playwright E2E
- Glob: `cypress.json`, `cypress.config.*`, `cypress/` → Cypress E2E
- Glob: `.storybook/` → Storybook component testing

### Linting & Formatting
- Glob: `.eslintrc.*`, `eslint.config.*` → ESLint
- Glob: `.prettierrc.*`, `prettier.config.*` → Prettier
- Glob: `biome.json`, `biome.jsonc` → Biome
- Glob: `ruff.toml`, `pyproject.toml` (check `[tool.ruff]`) → Ruff
- Glob: `.flake8`, `setup.cfg` (check `[flake8]`) → Flake8
- Glob: `mypy.ini`, `pyproject.toml` (check `[tool.mypy]`) → mypy
- Glob: `.editorconfig` → EditorConfig

## Step 5: Scan Git & Integrations (Layer 4 — 95% confidence)

### Source Control
- Run: `git remote -v` → Extract platform (github.com, gitlab.com, bitbucket.org) and org/repo
- Check default branch: look at `.git/HEAD` or use Glob for branch refs
- Glob: `.github/CODEOWNERS` → Code ownership
- Glob: `.github/PULL_REQUEST_TEMPLATE*`, `.github/pull_request_template*` → PR templates
- Glob: `.gitlab/merge_request_templates/` → MR templates

### Dependency Management
- Glob: `renovate.json`, `renovate.json5`, `.renovaterc` → Renovate
- Glob: `.github/dependabot.yml` → Dependabot

### Monorepo Detection
- Glob: `pnpm-workspace.yaml` → pnpm workspaces
- Glob: `lerna.json` → Lerna
- Glob: `nx.json` → Nx
- Glob: `turbo.json` → Turborepo
- Multiple `package.json` files at different depths → generic monorepo

## Step 6: Scan Infrastructure (Layer 5 — 60-80% confidence)

### Cloud & Deployment
- Glob: `**/terraform/**/*.tf`, `**/*.tf` → Terraform (check provider blocks for AWS/GCP/Azure)
- Glob: `serverless.yml`, `serverless.ts` → Serverless Framework
- Glob: `vercel.json`, `.vercel/` → Vercel
- Glob: `netlify.toml` → Netlify
- Glob: `fly.toml` → Fly.io
- Glob: `render.yaml` → Render
- Glob: `Procfile` → Heroku
- Glob: `app.yaml`, `app.yml` → Google App Engine
- Glob: `amplify.yml` → AWS Amplify

### Container Orchestration
- Glob: `k8s/**`, `kubernetes/**`, `kustomization.yaml` → Kubernetes
- Glob: `helm/**`, `Chart.yaml` → Helm charts
- Glob: `docker-compose.yml` (already scanned in Step 3)

### Monitoring & Observability (low confidence — often not in configs)
- Grep in config files for: `datadog`, `sentry`, `newrelic`, `grafana`, `prometheus`
- Grep in package deps for: `@sentry/`, `dd-trace`, `newrelic`, `prom-client`

## Step 7: Scan Project Structure (Layer 5 — 60-80% confidence)

Use **Glob** and **Bash(ls:*)** to map the directory structure:

- Identify source directories: `src/`, `lib/`, `app/`, `packages/`, `services/`
- Identify config directories: `config/`, `settings/`
- Identify build outputs: `dist/`, `build/`, `.next/`, `__pycache__/`
- Identify documentation: `docs/`, `wiki/`
- Identify test directories: `tests/`, `test/`, `__tests__/`, `spec/`

This information feeds into `boundaries.md` generation.

## Step 8: Score & Categorize

For each detection, assign a confidence score:

| Confidence | Source | Example |
|-----------|--------|---------|
| 95-100% | Manifest file with explicit dependency | `"react": "^18.2.0"` in package.json |
| 90-95% | Docker image with version tag | `postgres:15` in docker-compose |
| 80-90% | CI workflow file | `.github/workflows/` exists |
| 60-80% | Directory structure inference | `k8s/` directory exists |
| <60% | Grep mention in arbitrary files | "datadog" mentioned in a README |

**Only include detections with >60% confidence in the report.**

Group detections by context file target:
- **tech.md**: Languages, frameworks, databases, testing, infrastructure
- **integrations.md**: Source control, CI/CD, dependency management
- **boundaries.md**: Source dirs, config dirs, build outputs
- **config.md**: Detected roles to enable

## Step 9: Plan Updates

For each context file section, determine the action:

| Section State | Detected Value? | Action |
|--------------|----------------|--------|
| empty | yes | auto-fill |
| empty | no | leave as-is |
| customized | yes, matches | skip (already correct) |
| customized | yes, differs | needs-approval (show diff) |
| customized | no | skip |
| missing | yes | add section |

Build the update plan:
- Count auto-fill sections
- Count needs-approval sections
- Count sections to skip
- Prepare diff for each needs-approval section

---

# HARD STOP — Detection Report & User Approval

## Step 10: Present Detection Report

Output a text summary of all findings:

```
DETECTION COMPLETE
══════════════════

DETECTED STACK
──────────────
Backend:        {language} {version} + {framework} {version}  [{confidence}%]
Frontend:       {language} {version} + {framework} {version}  [{confidence}%]
Database:       {database} {version}                           [{confidence}%]
Infrastructure: {container} + {ci/cd}                          [{confidence}%]
Source Control: {platform} ({org}/{repo})                      [{confidence}%]
Monorepo:       {tool} ({package_count} packages)              [{confidence}%]

CONTEXT FILE UPDATES
────────────────────
tech.md:         {n} sections ({auto} auto-fill, {approval} need approval)
integrations.md: {n} sections ({auto} auto-fill, {approval} need approval)
boundaries.md:   {action}
config.md:       {action}
```

## Step 11: Merge Mode & File Selection

Ask two questions:

**Question 1 — Merge Mode:**
> "How should detected values be applied to your context files?
> [1] Auto-fill - Fill empty sections, skip customized ones
> [2] Interactive - Fill empty, ask per customized section
> [3] Overwrite - Replace all sections (shows full diff first)
> [4] Cancel - Save report only, don't modify files"

**Question 2 — File Selection:**
> "Which context files should be updated?
> [1] All detected - tech.md, integrations.md, boundaries.md, config.md
> [2] tech.md only - Just the technology stack file
> [3] tech + integrations - Stack and tools, skip boundaries/config"

**If user selects "Cancel"**: Save detection report to `$JAAN_OUTPUTS_DIR/dev/stack-detect/` and stop.

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write

## Step 12: Update tech.md

Based on merge mode selected in Step 11:

### Auto-fill mode
1. Read current `$JAAN_CONTEXT_DIR/tech.md`
2. For each **empty** section: replace with detected values
3. For each **customized** section: skip entirely
4. For each **missing** section: add at appropriate position
5. Write updated file using Edit tool

### Interactive mode
1. Auto-fill all empty sections (same as above)
2. For each **customized** section that has a different detected value, ask:

> "{section}: Current: {current_value} -> Detected: {detected_value} ({source}, {confidence}%)
> [1] Accept - Update to detected value
> [2] Keep - Keep current value
> [3] Skip all - Keep all remaining customized sections"

If user selects "Skip all" on any question, stop prompting and keep all remaining customized sections.

### Overwrite mode
1. Show complete diff of proposed changes
2. Confirm with user:

> "This will overwrite ALL sections in tech.md with detected values. Proceed?
> [1] Overwrite - Replace all sections with detected values
> [2] Cancel - Don't modify tech.md"

3. If confirmed, write entire file with detected values

### Section Mapping

Map detections to tech.md sections:

| Detection | tech.md Section | Anchor |
|-----------|----------------|--------|
| Backend language + framework | `## Current Stack > ### Backend` | `{#current-stack}` |
| Frontend language + framework | `## Current Stack > ### Frontend` | `{#current-stack}` |
| Mobile frameworks | `## Current Stack > ### Mobile` | `{#current-stack}` |
| Cloud + containers + CI/CD | `## Current Stack > ### Infrastructure` | `{#current-stack}` |
| API/Web/Testing frameworks | `## Frameworks` | `{#frameworks}` |
| Test runners + E2E tools | `## Frameworks > ### Testing` | `{#frameworks}` |
| Linting + formatting tools | (add as subsection or note) | — |

**Preserve anchors**: Always keep `{#anchor-name}` syntax on section headers.

**Version format**: Use exact version when detected (e.g., `PostgreSQL 15` from docker tag), or range when from manifest (e.g., `React ^18.2.0` → `React 18`).

## Step 13: Update integrations.md

If selected in file scope:

Map detections to integrations.md sections:

| Detection | Section | Fields |
|-----------|---------|--------|
| Git platform + org | `## Source Control` | Tool, Organization, Main Branch |
| PR/MR templates | `## Source Control` | MR/PR Template |
| CI/CD tool | (add as note or new section) | — |
| Dependabot/Renovate | (add as note) | — |

**Leave these for manual entry** (cannot reliably detect):
- Issue Tracking (Jira/Linear/GitHub Issues)
- Communication channels
- Analytics tools
- Design tools

## Step 14: Update boundaries.md

If selected in file scope:

Generate safe paths from detected project structure:

### Allowed Write Locations
Keep existing: `jaan-to/**`, `docs/**`

### Denied Locations
Auto-generate from detected structure:
- Source directories found in Step 7 (e.g., `src/`, `lib/`, `app/`, `packages/`)
- Configuration files (`.env`, `*.config.*`)
- Build outputs (e.g., `dist/`, `build/`, `.next/`)
- Package files (`package.json`, `go.mod`, etc.)
- Hidden directories (except `.claude/`)

Show the proposed boundaries and ask if they differ from current:

> "Update safe write paths based on detected project structure?
> [1] Accept - Update denied locations list
> [2] Keep - Keep current boundaries unchanged"

## Step 15: Update config.md

If selected in file scope:

Enable roles based on detections:

| Detection | Role to Enable |
|-----------|---------------|
| Backend or frontend code | `dev` |
| Test frameworks | `qa` |
| Analytics deps (GA4, Mixpanel, Segment) | `data` |
| CSS/design system deps | `ux` |

Only add roles not already in the Enabled Roles list.

## Step 16: Save Detection Report

Save a detection report to `$JAAN_OUTPUTS_DIR/dev/stack-detect/`:

1. Read template: `$JAAN_TEMPLATES_DIR/jaan-to-dev-stack-detect.template.md`
2. Fill template variables with detection results
3. Generate filename: `stack-detect-{YYYY-MM-DD}.md`
4. Write to: `$JAAN_OUTPUTS_DIR/dev/stack-detect/stack-detect-{YYYY-MM-DD}.md`

## Step 17: Show Summary

Output a summary of all changes made:

```
CHANGES APPLIED
═══════════════
tech.md:         {n} sections updated, {m} skipped
integrations.md: {n} sections updated, {m} skipped
boundaries.md:   {updated/unchanged}
config.md:       {roles_added} roles enabled

Report saved: $JAAN_OUTPUTS_DIR/dev/stack-detect/stack-detect-{date}.md

MANUAL REVIEW SUGGESTED
───────────────────────
- [ ] Review Technical Constraints section (cannot auto-detect)
- [ ] Review Common Patterns section (cannot auto-detect)
- [ ] Fill Issue Tracking in integrations.md
- [ ] Fill Communication channels in integrations.md
- [ ] Review team.md (not modified by this skill)
```

---

## Step 18: Capture Feedback

> "Any feedback on the detection? Anything missed or incorrect? [y/n]"

If yes:
- Run `/to-jaan-learn-add jaan-to-dev-stack-detect "{feedback}"`

---

## Definition of Done

- [ ] All requested context files scanned for current state
- [ ] Config files scanned across all detection layers
- [ ] Confidence scores assigned to all detections
- [ ] Detection report shown to user
- [ ] User approved merge mode
- [ ] Context files updated per merge decisions
- [ ] Detection report saved to outputs
- [ ] Summary shown with manual review suggestions
