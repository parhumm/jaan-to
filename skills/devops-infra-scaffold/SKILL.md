---
name: devops-infra-scaffold
description: Generate CI/CD workflows, Dockerfiles, and deployment configs from tech stack.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/devops/infra-scaffold/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[tech.md | (interactive)]"
---

# devops-infra-scaffold

> Generate CI/CD workflows, Dockerfiles, and deployment configs from tech.md — you can't ship what you can't deploy.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL -- determines framework, services, deployment target)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#versioning`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:devops-infra-scaffold.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:devops-infra-scaffold.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- `${CLAUDE_PLUGIN_ROOT}/docs/research/74-dev-cicd-infra-scaffold-generation.md` - Research reference

## Input

**Upstream Artifacts**: $ARGUMENTS

Accepts file paths or descriptions:
- **tech.md** -- Path to tech stack definition (from `$JAAN_CONTEXT_DIR/tech.md`)
- **backend-scaffold output** -- Path to backend scaffold output (from `/jaan-to:backend-scaffold`)
- **frontend-scaffold output** -- Path to frontend scaffold output (from `/jaan-to:frontend-scaffold`)
- **detect-dev output** -- Path to detect-dev output (optional, from `/jaan-to:detect-dev`)
- **Empty** -- Interactive wizard prompting for tech stack, CI/CD platform, and deployment target

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `devops-infra-scaffold`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` -- Know the tech stack for framework-specific infrastructure generation
- `$JAAN_CONTEXT_DIR/config.md` -- Project configuration

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_devops-infra-scaffold`

> **Language exception**: Generated code output (Dockerfiles, YAML workflows, shell scripts, .env files, deployment configs) is NOT affected by this setting and remains in English/code.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing tech stack to determine optimal CI/CD pipeline stages
- Mapping framework + database + deployment target to infrastructure patterns
- Planning multi-stage Docker build strategy from detected stack
- Identifying environment variable hierarchy and secret management needs
- Evaluating existing CI/CD setup from detect-dev output (if available)

## Step 1: Parse Tech Stack & Upstream Artifacts

Read and parse all available inputs:

1. **tech.md** -- Extract from `#current-stack`:
   - Languages and frameworks (Node.js/Next.js, PHP/Laravel, Go, etc.)
   - Databases (PostgreSQL, MySQL, Redis, etc.)
   - Package manager (pnpm, npm, yarn, composer, go mod)
   - Monorepo tool (Turborepo, Nx, none)

2. **backend-scaffold output** -- Extract:
   - Entry points and build commands
   - Dependencies and ORM
   - Port configuration
   - Environment variables referenced

3. **frontend-scaffold output** -- Extract:
   - Framework and build config (Next.js standalone, Vite, etc.)
   - Static vs SSR rendering
   - Build output directory
   - Environment variables (public + server)

4. **detect-dev output** (optional) -- Extract:
   - Existing CI/CD workflows
   - Current Dockerfiles
   - Existing deployment configs
   - Identified gaps and recommendations

Present input summary:
```
INPUT SUMMARY
-------------
Tech Stack:       {framework} + {database} + {cache}
Package Manager:  {package_manager}
Monorepo:         {monorepo_tool or "no"}
Backend Entry:    {entry_point}
Frontend Build:   {build_tool / output_mode}
Existing CI/CD:   {found / none}
Sources Found:    {list}
Sources Missing:  {list with fallback suggestions}
```

## Step 2: Clarify Infrastructure Decisions

AskUserQuestion for items not derivable from inputs:

- **CI/CD Platform**: GitHub Actions (default) / GitLab CI / other
- **Deployment Target**: Vercel (frontend) + Railway (backend) / Fly.io / AWS ECS / Docker Compose only
- **Container Registry**: GitHub Container Registry (ghcr.io, default) / Docker Hub / AWS ECR / none
- **Environment Strategy**: How many environments? (dev / staging / production)
- **Database Migrations**: Which tool? (Prisma / Drizzle / Knex / golang-migrate / Laravel migrations)
- **Security Scanning**: Include Trivy container scanning? (recommended: yes)

## Step 3: Plan Infrastructure Structure

Based on tech stack + decisions, plan the complete infrastructure scaffold:

```
INFRASTRUCTURE PLAN
===================

CI/CD PLATFORM: {platform}
DEPLOYMENT:     {target}
REGISTRY:       {registry}
ENVIRONMENTS:   {list}

OUTPUT STRUCTURE
----------------
{id}-{slug}/
+-- {id}-{slug}.md                          # Infrastructure guide
+-- ci/
|   +-- ci.yml                              # CI workflow (lint, type-check, test, build)
|   +-- cd.yml                              # CD workflow (deploy to environments)
+-- docker/
|   +-- Dockerfile.backend                  # Multi-stage backend build
|   +-- Dockerfile.frontend                 # Multi-stage frontend build
|   +-- docker-compose.yml                  # Full-stack dev environment
|   +-- docker-compose.prod.yml             # Production overrides
|   +-- .dockerignore                       # Build context exclusions
+-- config/
|   +-- .env.example                        # All variables with safe defaults
|   +-- .env.test                           # Test environment variables
|   +-- .env.production.example             # Production template (no secrets)
+-- deploy/
|   +-- {platform}.yml                      # Platform-specific config
|   +-- migration.sh                        # Database migration script
+-- {id}-{slug}-readme.md                   # Setup + deployment instructions

PIPELINE STAGES
---------------
CI: {stage_list}
CD: {stage_list}
Docker Stages: {stage_list}
Services: {service_list}
```

Report any conflicts or missing information.

---

# HARD STOP -- Review Infrastructure Plan

Use AskUserQuestion:
- Question: "Proceed with generating the infrastructure scaffold?"
- Header: "Generate"
- Options:
  - "Yes" -- Generate all infrastructure files
  - "No" -- Cancel
  - "Edit" -- Let me revise the deployment target or CI/CD strategy first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Phase 2 Output -- Folder with subfolders

All files in `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{id}-{slug}/`:

```
{id}-{slug}/
+-- {id}-{slug}.md                          # Main doc (infrastructure guide)
+-- ci/
|   +-- ci.yml                              # GitHub Actions CI workflow
|   +-- cd.yml                              # GitHub Actions CD workflow
+-- docker/
|   +-- Dockerfile.backend                  # Multi-stage backend Dockerfile
|   +-- Dockerfile.frontend                 # Multi-stage frontend Dockerfile
|   +-- docker-compose.yml                  # Development docker-compose
|   +-- docker-compose.prod.yml             # Production overrides (optional)
|   +-- .dockerignore                       # Build context exclusions
+-- config/
|   +-- .env.example                        # All env vars with safe defaults
|   +-- .env.test                           # Test environment config
|   +-- .env.production.example             # Production template (no secrets)
+-- deploy/
|   +-- {platform}.yml                      # Deployment platform config
|   +-- migration.sh                        # Database migration script
+-- {id}-{slug}-readme.md                   # Setup + deployment instructions
```

## Step 5: Generate CI Workflow (ci.yml)

Generate GitHub Actions CI workflow with these stages:

1. **Detect Changes** -- Use `dorny/paths-filter@v3` for monorepo path filtering
2. **Lint** -- ESLint/Biome (Node.js), PHP-CS-Fixer (PHP), golangci-lint (Go)
3. **Type Check** -- `tsc --noEmit` (TypeScript), PHPStan (PHP), `go vet` (Go)
4. **Test** -- With service containers (PostgreSQL, Redis) and healthchecks
5. **Build** -- Framework-specific build with caching
6. **Security Scan** -- Trivy filesystem scan + `pnpm audit` / `npm audit`

Caching strategy:
- Package manager cache via `actions/setup-node@v4` (or equivalent)
- Build output cache via `actions/cache@v4` (Next.js `.next/cache`, TypeScript `tsbuildinfo`)
- Docker layer cache via `docker/build-push-action@v5` with `cache-from: type=gha`

Key patterns from research:
- `fail-fast: false` for matrix builds
- Reusable workflow structure for DRY CI
- `retention-days: 1` for ephemeral build artifacts
- Pin actions by SHA for supply chain security

## Step 6: Generate CD Workflow (cd.yml)

Generate deployment workflow triggered on:
- Push to `main` -- Deploy to production
- Push to `develop` -- Deploy to staging (if configured)
- PR -- Deploy preview (if platform supports it)

Stages:
1. **Build Docker Images** -- Multi-stage build, push to registry
2. **Run Migrations** -- Separate job, before deployment
3. **Deploy** -- Platform-specific (Vercel CLI / Railway CLI / Fly deploy / ECS update)
4. **Smoke Test** -- Health check on deployed URL
5. **Notify** -- Success/failure notification (optional)

Environment protection:
- Use GitHub Environments with required reviewers for production
- Use OIDC federation for cloud credentials (no stored secrets)
- Separate secrets per environment

## Step 7: Generate Dockerfiles

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-infra-scaffold-reference.md` section "Dockerfile Generation Patterns" for per-stack Dockerfile patterns (backend, frontend, .dockerignore).

## Step 8: Generate docker-compose.yml

Full-stack development environment with:

**Services** (based on tech.md):
- Backend app (build from Dockerfile.backend, target: development)
- Frontend app (build from Dockerfile.frontend, target: development)
- PostgreSQL (if detected) -- with healthcheck (`pg_isready`)
- MySQL (if detected) -- with healthcheck (`mysqladmin ping`)
- Redis (if detected) -- with healthcheck (`redis-cli ping`)
- Additional services from tech.md

**Patterns from research:**
- `condition: service_healthy` for all `depends_on`
- Named volumes for database persistence
- Bind mounts for hot-reload (source code only)
- Anonymous volumes to protect `node_modules`
- Network isolation (frontend / backend networks)
- Profiles for selective startup (`--profile backend`, `--profile full`)
- Environment variables from `.env` file

**docker-compose.prod.yml** (optional overlay):
- Production-optimized settings
- No bind mounts
- Resource limits
- Restart policies

## Step 9: Generate Environment Config Files

### .env.example
All variables with safe defaults and descriptions:
```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp

# Redis
REDIS_URL=redis://localhost:6379

# App
NODE_ENV=development
PORT=4000
HOST=0.0.0.0

# Auth
JWT_SECRET=change-me-in-production

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:4000
```

### .env.test
Test-specific overrides:
```bash
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_test
NODE_ENV=test
LOG_LEVEL=silent
```

### .env.production.example
Production template (NO actual secrets):
```bash
# Secrets: Set via CI/CD environment variables or secrets manager
# DATABASE_URL=<set via secrets>
# JWT_SECRET=<set via secrets>

NODE_ENV=production
PORT=4000
```

## Step 10: Generate Deployment Config

Based on selected deployment target:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-infra-scaffold-reference.md` section "Deployment Platform Configurations" for Vercel, Railway, Fly.io, AWS ECS configs and migration.sh.

## Step 11: Quality Check

Validate generated output against checklist:
- [ ] CI workflow covers lint, type-check, test, build stages
- [ ] CD workflow deploys to all configured environments
- [ ] Dockerfiles use multi-stage builds with non-root users
- [ ] docker-compose.yml has healthchecks for all services
- [ ] .env.example documents all required variables
- [ ] .env.production.example contains NO actual secrets
- [ ] Deployment config matches selected platform
- [ ] migration.sh handles the correct ORM/migration tool
- [ ] All files have inline comments explaining each section
- [ ] No hardcoded secrets or credentials in any file

**Output Structure**:
- [ ] ID generated using scripts/lib/id-generator.sh
- [ ] Folder created: infra-scaffold/{id}-{slug}/
- [ ] Main file named: {id}-{slug}.md
- [ ] Index updated
- [ ] Executive Summary included

If any check fails, fix before preview.

## Step 12: Preview & Approval

Present generated output summary showing:
- File count and structure
- CI stages and estimated pipeline time
- Docker image target sizes
- Environment variable count
- Deployment target summary

Use AskUserQuestion:
- Question: "Write infrastructure scaffold files to output?"
- Header: "Write Files"
- Options:
  - "Yes" -- Write the files
  - "No" -- Cancel
  - "Refine" -- Make adjustments first

## Step 13: Generate ID and Folder Structure

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/devops/infra-scaffold"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{project-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{NEXT_ID}-{slug}/`
> - Main file: `{NEXT_ID}-{slug}.md`

## Step 14: Write Output

1. Create output folder and subfolders:
```bash
mkdir -p "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER/ci"
mkdir -p "$OUTPUT_FOLDER/docker"
mkdir -p "$OUTPUT_FOLDER/config"
mkdir -p "$OUTPUT_FOLDER/deploy"
```

2. Write all files to respective subfolders:
   - `{id}-{slug}.md` -- Main infrastructure guide (from template)
   - `ci/ci.yml` -- CI workflow
   - `ci/cd.yml` -- CD workflow
   - `docker/Dockerfile.backend` -- Backend Dockerfile
   - `docker/Dockerfile.frontend` -- Frontend Dockerfile
   - `docker/docker-compose.yml` -- Dev docker-compose
   - `docker/docker-compose.prod.yml` -- Production overrides (if applicable)
   - `docker/.dockerignore` -- Build context exclusions
   - `config/.env.example` -- All env vars
   - `config/.env.test` -- Test env vars
   - `config/.env.production.example` -- Production template
   - `deploy/{platform}.yml` -- Deployment config
   - `deploy/migration.sh` -- Migration script
   - `{id}-{slug}-readme.md` -- Setup + deployment instructions

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project Title} Infrastructure" \
  "{Executive summary -- 1-2 sentences}"
```

4. Confirm completion:
> Scaffold written to: `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{NEXT_ID}-{slug}/`
> Index updated: `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/README.md`

## Step 15: Suggest Next Actions

> **Infrastructure scaffold generated successfully!**
>
> **Next Steps:**
> - Copy CI/CD workflows to `.github/workflows/`
> - Copy Dockerfiles and docker-compose to project root
> - Copy `.env.example` to project root and create `.env` from it
> - Copy deployment config to project root
> - Run `docker compose up` to verify local development environment
> - Push a branch to test CI workflow
> - Run `/jaan-to:sec-audit-remediate` to audit security of generated configs
> - Run `/jaan-to:learn-add devops-infra-scaffold "{feedback}"` to capture lessons

## Step 16: Capture Feedback

Use AskUserQuestion:
- Question: "How did the infrastructure scaffold turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I improve?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add devops-infra-scaffold "{feedback}"`

---

## Multi-Stack Support (Research-Informed)

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-infra-scaffold-reference.md` section "Multi-Stack Infrastructure Patterns" for detection table and per-stack key patterns (Node.js, PHP/Laravel, Go).

---

## Security Best Practices (Applied to All Generated Files)

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-infra-scaffold-reference.md` section "Security Best Practices" for full security checklist applied to all generated files.

---

## DAG Position

```
tech.md + backend-scaffold + frontend-scaffold + detect-dev (optional)
  |
  v
devops-infra-scaffold
```

---

## Definition of Done

- [ ] CI workflow covers lint, type-check, test, build, security scan stages
- [ ] CD workflow deploys to configured environments with migration step
- [ ] Dockerfiles use multi-stage builds with non-root runtime users
- [ ] docker-compose.yml has healthchecks and proper service dependencies
- [ ] .env files document all required variables without exposing secrets
- [ ] Deployment config matches selected platform
- [ ] Migration script handles the correct ORM/migration tool
- [ ] All generated files have inline comments
- [ ] Output follows v3.0.0 structure (ID, folder, index)
- [ ] Index updated with executive summary
- [ ] README with setup + deployment instructions is complete
- [ ] User approved final result
