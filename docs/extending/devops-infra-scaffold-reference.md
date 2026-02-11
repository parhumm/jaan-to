# devops-infra-scaffold — Reference Material

> Extracted reference tables, code templates, and patterns for the `devops-infra-scaffold` skill.
> This file is loaded by `devops-infra-scaffold` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Dockerfile Generation Patterns

### Dockerfile.backend

Multi-stage build following research best practices:

**Node.js/TypeScript (Fastify/Express/NestJS):**
- Stage 1 (deps): `node:20-alpine`, install with `--frozen-lockfile`
- Stage 2 (build): Copy deps, build TypeScript
- Stage 3 (runtime): Alpine, non-root user, copy dist only
- Use BuildKit cache mounts for package manager store
- For monorepos: Use `turbo prune --docker` if Turborepo detected

**PHP (Laravel/Symfony):**
- Stage 1 (deps): `composer:2` for dependency install
- Stage 2 (build): `php:8.3-fpm-alpine`, copy vendor + source
- Stage 3 (runtime): Alpine with required PHP extensions
- Use OPcache for production

**Go:**
- Stage 1 (build): `golang:1.22-alpine`, build static binary with `CGO_ENABLED=0`
- Stage 2 (runtime): `gcr.io/distroless/static-debian12` (10-20MB images)
- Use `-ldflags="-s -w"` to strip debug info

### Dockerfile.frontend

**Next.js:**
- Stage 1 (deps): Install with frozen lockfile
- Stage 2 (build): Build with `NEXT_TELEMETRY_DISABLED=1`
- Stage 3 (runtime): Copy `.next/standalone` + `.next/static` + `public`
- Non-root user, `ENV PORT=3000`
- For monorepos: `turbo prune --docker` pattern

**Vite/SPA:**
- Stage 1 (deps): Install dependencies
- Stage 2 (build): Build static assets
- Stage 3 (runtime): `nginx:alpine` with custom `nginx.conf`

### .dockerignore

Generate comprehensive `.dockerignore`:
```
node_modules
.next
.git
*.md
.env*
coverage
.turbo
dist
.cache
__tests__
```

## Deployment Platform Configurations

### Vercel (vercel.json)
- Framework auto-detection
- Monorepo: `buildCommand`, `outputDirectory`, `installCommand`
- `turbo-ignore` for skip builds
- Environment variables per deployment environment
- Cron jobs if applicable

### Railway (railway.toml)
- Dockerfile builder
- Watch patterns for monorepo
- Health check path and timeout
- Resource limits
- Replica count

### Fly.io (fly.toml)
- Primary region selection
- Auto-stop/start machines
- Concurrency limits
- VM sizing
- Health checks

### AWS ECS (task-definition.json)
- Fargate task definition
- Container definitions with health checks
- Secrets from AWS Secrets Manager
- Log configuration (CloudWatch)
- OIDC-based deployment from GitHub Actions

### migration.sh
Database migration script:
```bash
#!/bin/bash
set -euo pipefail
# Detect migration tool and run
```
- Auto-detect migration tool from tech.md (Prisma, Drizzle, Knex, golang-migrate, Laravel)
- Include rollback instructions
- Support for CI and local execution

## Multi-Stack Infrastructure Patterns

The skill reads tech.md `#current-stack` to determine which stack to generate:

| tech.md value | CI Lint | Dockerfile Pattern | Deploy Target | Migration Tool |
|---------------|---------|-------------------|---------------|----------------|
| Node.js / TypeScript + Next.js | ESLint + tsc | 3-stage Alpine + standalone | Vercel (FE) + Railway (BE) | Prisma / Drizzle |
| Node.js / TypeScript + Fastify | ESLint + tsc | 3-stage Alpine | Railway / Fly.io | Prisma / Drizzle |
| PHP / Laravel | PHP-CS-Fixer + PHPStan | 3-stage php-fpm Alpine | Forge / Vapor | Laravel migrations |
| Go | golangci-lint + go vet | 2-stage distroless | Fly.io / Railway | golang-migrate |

### Node.js/Next.js + Fastify Key Patterns

**CI:**
- `pnpm install --frozen-lockfile` with cache
- Monorepo: `dorny/paths-filter@v3` for selective builds
- Turbo remote cache with `TURBO_TOKEN` and `TURBO_TEAM`
- PostgreSQL + Redis service containers with healthchecks

**Docker:**
- Multi-stage: deps -> build -> runtime (Alpine)
- Next.js: `output: 'standalone'` for ~120MB images
- BuildKit cache mounts for pnpm store
- Monorepo: `turbo prune --docker` for minimal context

**docker-compose:**
- PostgreSQL 16 Alpine with `pg_isready` healthcheck
- Redis 7 Alpine with `redis-cli ping` healthcheck
- Bind mounts for source, anonymous volumes for node_modules
- Network isolation: frontend + backend (internal)
- Profiles: `backend`, `frontend`, `full`, `debug`

**Environment:**
- `.env.example` with all DATABASE_URL, REDIS_URL, JWT_SECRET, etc.
- Typed validation with `@t3-oss/env-nextjs` or `envalid`
- OIDC federation for cloud credentials in CI

### PHP/Laravel Key Patterns

**CI:**
- `composer install --no-dev --optimize-autoloader` for production
- PHP-CS-Fixer + PHPStan for lint/static analysis
- Pest 3 for testing with architecture presets

**Docker:**
- `composer:2` stage for deps, `php:8.3-fpm-alpine` for runtime
- OPcache enabled for production
- Nginx or Caddy as reverse proxy

### Go Key Patterns

**CI:**
- `golangci-lint` for linting, `go vet` for static analysis
- `go test ./...` with race detector
- `CGO_ENABLED=0` for static binary builds

**Docker:**
- 2-stage: `golang:1.22-alpine` build -> `gcr.io/distroless/static-debian12` runtime
- 10-20MB production images
- `-ldflags="-s -w"` to strip debug info

## Security Best Practices

- Pin GitHub Actions by SHA (not just version tag)
- Use non-root users in all Dockerfiles
- Never commit `.env` files with real secrets
- Use OIDC federation instead of stored cloud credentials
- Include Trivy container scanning in CI
- Add `.dockerignore` to minimize build context and prevent secret leakage
- Use `--frozen-lockfile` for reproducible installs
- Set `NODE_ENV=production` in runtime Docker stage
- Use healthchecks for all docker-compose services
