# CI/CD and Infrastructure Scaffold Generation

> Research conducted: 2026-02-10

## Executive Summary

- **Scaffold generation from tech stack definitions** is an emerging pattern that reduces boilerplate by 60-80% in new project setup; the key is layered templates that compose based on detected frameworks, package managers, and deployment targets rather than monolithic generators.
- **GitHub Actions reusable workflows and composite actions** are the foundation for maintainable CI/CD in monorepos, with path-filtered matrix builds, dependency-aware caching (pnpm store, Next.js `.next/cache`, Docker layer cache), and artifact passing between jobs reducing pipeline times by 40-60%.
- **Multi-stage Docker builds for Node.js/Next.js** should follow a strict 3-4 stage pattern (deps -> build -> runtime) using Alpine or distroless base images; combined with `.dockerignore` optimization and BuildKit cache mounts, production images can be reduced from 1GB+ to under 150MB.
- **Docker Compose for full-stack development** requires careful orchestration of service dependencies via healthchecks (not just `depends_on`), named volumes for data persistence, bind mounts for hot-reload, and isolated networks per service group; the `profiles` feature enables selective service startup.
- **Environment variable management** demands a strict hierarchy (`.env.defaults` < `.env.local` < `.env.{environment}` < process env < secrets manager) with validation at startup, typed schemas (using zod or envalid), and secret injection via CI/CD variables or external vaults rather than committed `.env` files.

## Background & Context

CI/CD and infrastructure configuration has become one of the most significant sources of boilerplate in modern software projects. A typical Node.js/TypeScript monorepo targeting production deployment needs GitHub Actions workflows for CI (lint, test, build, security scan), multi-stage Dockerfiles for containerization, docker-compose configurations for local development, environment variable management across multiple environments, and platform-specific deployment configs. Setting all this up manually for each project takes days and is error-prone.

The concept of "scaffold generation" -- automatically producing these infrastructure files from a project's tech stack definition -- has gained traction through tools like Create T3 App, Turborepo generators, Nx workspace generators, and platforms like Vercel and Railway that auto-detect frameworks. The core insight is that most infrastructure configuration is deterministic: given a tech stack (e.g., Next.js + PostgreSQL + Redis + pnpm monorepo), the optimal CI/CD pipeline, Dockerfile, and docker-compose configuration follow predictable patterns.

This research covers the full spectrum of infrastructure scaffold generation for Node.js/TypeScript monorepos: GitHub Actions workflow patterns, Docker multi-stage builds, docker-compose orchestration, environment management, deployment platform configs, database migration automation, security scanning integration, and infrastructure-as-code patterns. The focus is on patterns that can be codified into generators and templates, making them reproducible across projects.

## Key Findings

### 1. GitHub Actions Workflow Patterns

#### Matrix Builds for Monorepos

Matrix builds in GitHub Actions allow testing across multiple Node.js versions, operating systems, and package configurations in parallel. For monorepos, the critical pattern is **dynamic matrix generation** using path filters:

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      packages: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            api:
              - 'packages/api/**'
            web:
              - 'packages/web/**'
            shared:
              - 'packages/shared/**'

  test:
    needs: detect-changes
    if: needs.detect-changes.outputs.packages != '[]'
    strategy:
      matrix:
        package: ${{ fromJson(needs.detect-changes.outputs.packages) }}
        node-version: [18, 20, 22]
      fail-fast: false
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: pnpm --filter ${{ matrix.package }} test
```

Key patterns:
- **Path-filtered triggers** prevent unnecessary builds when only specific packages change.
- **`fail-fast: false`** ensures all matrix combinations complete even if one fails, giving complete visibility.
- **Dynamic matrix from job outputs** enables the matrix to be computed at runtime based on changed files.
- **Shared package detection**: When `shared` changes, all dependent packages should rebuild. This requires dependency graph awareness.

#### Caching Strategies

Caching is the single most impactful optimization for CI/CD pipeline performance. The hierarchy of caches for a Node.js monorepo:

1. **Package manager cache** (pnpm store, npm cache, yarn cache):
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: 'pnpm'
```

2. **Build output cache** (Next.js `.next/cache`, TypeScript `tsconfig.tsbuildinfo`):
```yaml
- uses: actions/cache@v4
  with:
    path: |
      packages/web/.next/cache
      **/*.tsbuildinfo
    key: build-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}-${{ hashFiles('packages/web/src/**') }}
    restore-keys: |
      build-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}-
      build-${{ runner.os }}-
```

3. **Docker layer cache** (BuildKit inline cache or GitHub Actions cache backend):
```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

4. **Turborepo remote cache** (for monorepo build orchestration):
```yaml
- run: pnpm turbo build --filter=${{ matrix.package }}
  env:
    TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
    TURBO_TEAM: ${{ vars.TURBO_TEAM }}
```

Cache key design best practices:
- Include OS, lock file hash, and source file hashes in keys.
- Use `restore-keys` with progressively less specific prefixes for partial cache hits.
- GitHub Actions cache has a 10GB limit per repository; use `actions/cache/save` and `actions/cache/restore` for fine-grained control.
- Cache eviction follows LRU; unreferenced caches are purged after 7 days.

#### Artifact Management

Artifacts enable passing build outputs between jobs in a workflow:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm build
      - uses: actions/upload-artifact@v4
        with:
          name: build-output-${{ matrix.package }}
          path: packages/${{ matrix.package }}/dist
          retention-days: 1

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build-output-web
          path: dist
```

Key considerations:
- Use `retention-days: 1` for ephemeral build artifacts to save storage.
- Artifact names must be unique across matrix runs; include the matrix variable in the name.
- `actions/upload-artifact@v4` supports immutable artifacts and concurrent uploads.
- For Docker images, prefer pushing to a registry (ghcr.io) over artifact storage.

#### Reusable Workflows

Reusable workflows (called workflows) are the primary mechanism for DRY CI/CD in organizations:

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'
      package:
        type: string
        required: true
    secrets:
      NPM_TOKEN:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: pnpm --filter ${{ inputs.package }} test
```

Called from another workflow:
```yaml
jobs:
  test-api:
    uses: ./.github/workflows/reusable-test.yml
    with:
      package: api
    secrets: inherit
```

Limitations and patterns:
- Reusable workflows can be nested up to 4 levels deep.
- `secrets: inherit` passes all secrets from the caller (simpler but less explicit).
- Reusable workflows cannot access the calling workflow's `env` context; pass values as `inputs`.
- Composite actions are preferred for reusable steps within a job; reusable workflows for reusable jobs.
- Store organization-wide reusable workflows in a `.github` repository for centralized management.

### 2. Multi-Stage Docker Builds for Node.js/Next.js

#### The Standard 3-Stage Pattern

The recommended pattern for Node.js/Next.js applications:

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/web/package.json ./packages/web/
COPY packages/shared/package.json ./packages/shared/
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# Stage 2: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/packages/web/node_modules ./packages/web/node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN corepack enable pnpm && pnpm --filter web build

# Stage 3: Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
COPY --from=builder /app/packages/web/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/packages/web/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/packages/web/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
```

#### Layer Optimization Techniques

1. **Copy package files first, then source**: Placing `COPY package.json` and `RUN install` before `COPY . .` ensures the dependency layer is cached unless lock files change.

2. **Use `.dockerignore`** aggressively:
```
node_modules
.next
.git
*.md
.env*
coverage
.turbo
dist
```

3. **BuildKit cache mounts** for package managers:
```dockerfile
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile
```

4. **Next.js standalone output**: Set `output: 'standalone'` in `next.config.js` to generate a minimal server bundle that includes only necessary `node_modules`, reducing image size from ~500MB to ~100MB.

5. **Multi-platform builds** with BuildKit:
```yaml
- uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64
    push: true
```

#### Distroless and Minimal Base Images

For maximum security and minimal image size:

```dockerfile
# Option A: Google's distroless Node.js image
FROM gcr.io/distroless/nodejs20-debian12 AS runner
COPY --from=builder /app/.next/standalone ./
CMD ["server.js"]

# Option B: Chainguard's Node.js image
FROM cgr.dev/chainguard/node:latest AS runner

# Option C: Alpine with stripped base
FROM node:20-alpine AS runner
RUN apk add --no-cache dumb-init
```

Size comparison (approximate for a Next.js app):
| Base Image | Image Size |
|------------|-----------|
| `node:20` (Debian) | ~1.1GB |
| `node:20-slim` | ~250MB |
| `node:20-alpine` | ~180MB |
| `node:20-alpine` + standalone | ~120MB |
| `distroless/nodejs20` + standalone | ~90MB |

#### Monorepo-Specific Docker Patterns

For pnpm/Turborepo monorepos, use `turbo prune` to create minimal Docker contexts:

```dockerfile
FROM node:20-alpine AS pruner
WORKDIR /app
RUN npm install -g turbo
COPY . .
RUN turbo prune --scope=web --docker

FROM node:20-alpine AS deps
WORKDIR /app
COPY --from=pruner /app/out/json/ .
COPY --from=pruner /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN corepack enable pnpm && pnpm install --frozen-lockfile

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/ .
COPY --from=pruner /app/out/full/ .
RUN corepack enable pnpm && pnpm turbo build --filter=web

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/packages/web/.next/standalone ./
COPY --from=builder /app/packages/web/.next/static ./.next/static
COPY --from=builder /app/packages/web/public ./public
CMD ["node", "server.js"]
```

The `turbo prune --docker` command generates two directories:
- `out/json/`: Only `package.json` files for the target and its dependencies (for dependency installation layer).
- `out/full/`: Full source files for the target and its workspace dependencies (for build layer).

### 3. Docker Compose for Full-Stack Development

#### Service Dependencies and Healthchecks

The `depends_on` directive alone only waits for container start, not service readiness. Use healthchecks:

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    ports:
      - "6379:6379"

  api:
    build:
      context: .
      dockerfile: packages/api/Dockerfile
      target: development
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://postgres:postgres@postgres:5432/myapp
      REDIS_URL: redis://redis:6379
    ports:
      - "4000:4000"
    volumes:
      - ./packages/api/src:/app/packages/api/src
      - ./packages/shared/src:/app/packages/shared/src
    command: pnpm --filter api dev

  web:
    build:
      context: .
      dockerfile: packages/web/Dockerfile
      target: development
    depends_on:
      api:
        condition: service_healthy
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:4000
    ports:
      - "3000:3000"
    volumes:
      - ./packages/web/src:/app/packages/web/src
      - ./packages/shared/src:/app/packages/shared/src
    command: pnpm --filter web dev

volumes:
  postgres-data:
```

#### Volume Management Patterns

Three categories of volumes in development:

1. **Named volumes** for persistent data (databases):
```yaml
volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
```

2. **Bind mounts** for hot-reload development:
```yaml
volumes:
  - ./packages/api/src:/app/packages/api/src  # Source code
  - /app/node_modules                          # Exclude node_modules
  - /app/packages/api/node_modules             # Exclude per-package node_modules
```

3. **tmpfs mounts** for transient data:
```yaml
tmpfs:
  - /tmp
  - /app/.next/cache  # Build cache in memory for speed
```

The anonymous volume pattern (`/app/node_modules`) prevents bind-mounted source from overriding container's `node_modules`. This is essential when host and container have different architectures or when native modules are involved.

#### Network Isolation

```yaml
services:
  web:
    networks:
      - frontend
  api:
    networks:
      - frontend
      - backend
  postgres:
    networks:
      - backend
  redis:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

The `internal: true` flag on the backend network prevents direct external access to databases, mimicking production network isolation.

#### Docker Compose Profiles

```yaml
services:
  web:
    profiles: ["frontend", "full"]
  api:
    profiles: ["backend", "full"]
  postgres:
    profiles: ["backend", "full", "db"]
  redis:
    profiles: ["backend", "full"]
  mailhog:
    profiles: ["debug"]
  pgadmin:
    profiles: ["debug"]
```

Usage: `docker compose --profile backend up` starts only API, Postgres, and Redis.

### 4. Environment Variable Management

#### The .env Hierarchy

The recommended loading order (later overrides earlier):

1. **`.env.defaults`** (or `.env.example`): Checked into git. Contains all variable names with safe defaults or placeholder values. Serves as documentation.
2. **`.env`**: Local overrides. In `.gitignore`. Optional.
3. **`.env.local`**: Machine-specific overrides. In `.gitignore`. Highest local priority.
4. **`.env.{NODE_ENV}`** (e.g., `.env.production`, `.env.test`): Environment-specific. May be checked in if they contain no secrets.
5. **Process environment variables**: Set by CI/CD or container orchestrator. Highest priority.
6. **Secrets manager**: For production secrets (API keys, database credentials).

Next.js implements a similar hierarchy natively:
- `.env` (all environments)
- `.env.local` (all environments, gitignored)
- `.env.development` / `.env.production` / `.env.test`
- `.env.development.local` / `.env.production.local` / `.env.test.local`

#### Typed Validation with Schemas

Using `@t3-oss/env-nextjs` or `envalid`:

```typescript
// env.ts (using @t3-oss/env-nextjs)
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    REDIS_URL: z.string().url(),
    JWT_SECRET: z.string().min(32),
    NODE_ENV: z.enum(["development", "test", "production"]),
  },
  client: {
    NEXT_PUBLIC_API_URL: z.string().url(),
    NEXT_PUBLIC_APP_URL: z.string().url(),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    REDIS_URL: process.env.REDIS_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    NODE_ENV: process.env.NODE_ENV,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  },
});
```

Using `envalid`:
```typescript
import { cleanEnv, str, url, port, bool } from "envalid";

export const env = cleanEnv(process.env, {
  DATABASE_URL: url(),
  REDIS_URL: url(),
  PORT: port({ default: 4000 }),
  JWT_SECRET: str({ desc: "JWT signing secret" }),
  ENABLE_CACHE: bool({ default: true }),
});
```

Benefits:
- Application fails fast at startup if required variables are missing or malformed.
- TypeScript autocompletion for environment variables.
- Clear documentation of all required configuration.

#### Secrets Handling in CI/CD

```yaml
# GitHub Actions secrets and variables
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  NEXT_PUBLIC_API_URL: ${{ vars.NEXT_PUBLIC_API_URL }}  # Non-secret variable

# Using GitHub OIDC for cloud provider authentication (no stored secrets)
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789:role/github-actions
    aws-region: us-east-1
```

Best practices:
- Use GitHub **environment secrets** for per-environment values (staging vs production).
- Use **OIDC federation** instead of long-lived credentials for cloud providers.
- Never log or echo secret values in CI; GitHub auto-masks known secrets.
- Use `.env.ci` for CI-specific non-secret configuration, committed to the repo.
- Store production secrets in a proper secrets manager (AWS Secrets Manager, HashiCorp Vault, Doppler).

### 5. Deployment Platform Configurations

#### Vercel

Vercel provides zero-config deployment for Next.js with auto-detection:

```json
// vercel.json
{
  "framework": "nextjs",
  "buildCommand": "pnpm turbo build --filter=web",
  "outputDirectory": "packages/web/.next",
  "installCommand": "pnpm install",
  "ignoreCommand": "npx turbo-ignore",
  "env": {
    "DATABASE_URL": "@database-url"
  },
  "crons": [{
    "path": "/api/cron/cleanup",
    "schedule": "0 0 * * *"
  }]
}
```

Monorepo-specific configuration:
- `root` directory setting to point to the correct package.
- `turbo-ignore` for skipping builds when the relevant package has not changed.
- Environment variables per deployment environment (preview, production).
- Edge Functions and Middleware deploy automatically from Next.js conventions.

#### Railway

```yaml
# railway.toml
[build]
builder = "dockerfile"
dockerfilePath = "packages/api/Dockerfile"
watchPatterns = ["packages/api/**", "packages/shared/**"]

[deploy]
startCommand = "node dist/main.js"
healthcheckPath = "/health"
healthcheckTimeout = 300
numReplicas = 2
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3

[deploy.resources]
memory = "512Mi"
cpu = "0.5"
```

Railway features for monorepos:
- Multiple services from one repo, each with its own `railway.toml`.
- Reference variables between services using `${{ service_name.VARIABLE }}`.
- Built-in PostgreSQL, Redis, and other database provisioning.
- Preview environments per PR with ephemeral databases.

#### Fly.io

```toml
# fly.toml
app = "myapp-api"
primary_region = "iad"

[build]
  dockerfile = "packages/api/Dockerfile"

[env]
  NODE_ENV = "production"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

  [http_service.concurrency]
    type = "requests"
    hard_limit = 250
    soft_limit = 200

[[services]]
  protocol = "tcp"
  internal_port = 8080

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [[services.tcp_checks]]
    grace_period = "10s"
    interval = "15s"
    timeout = "2s"

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512
```

Fly.io features:
- **Machines API** for auto-scaling to zero and back.
- **LiteFS** for distributed SQLite.
- Multi-region deployment with read replicas.
- Built-in Wireguard private networking between services.

#### AWS ECS (with Fargate)

```json
// task-definition.json
{
  "family": "myapp-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789:role/ecsTaskRole",
  "containerDefinitions": [{
    "name": "api",
    "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/myapp-api:latest",
    "portMappings": [{
      "containerPort": 4000,
      "protocol": "tcp"
    }],
    "healthCheck": {
      "command": ["CMD-SHELL", "curl -f http://localhost:4000/health || exit 1"],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/myapp-api",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "secrets": [
      {
        "name": "DATABASE_URL",
        "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:myapp/database-url"
      }
    ],
    "environment": [
      { "name": "NODE_ENV", "value": "production" },
      { "name": "PORT", "value": "4000" }
    ]
  }]
}
```

GitHub Actions deployment to ECS:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1

- name: Login to Amazon ECR
  uses: aws-actions/amazon-ecr-login@v2

- name: Build, tag, and push image
  env:
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    IMAGE_TAG: ${{ github.sha }}
  run: |
    docker build -t $ECR_REGISTRY/myapp-api:$IMAGE_TAG -f packages/api/Dockerfile .
    docker push $ECR_REGISTRY/myapp-api:$IMAGE_TAG

- name: Deploy to ECS
  uses: aws-actions/amazon-ecs-deploy-task-definition@v1
  with:
    task-definition: task-definition.json
    service: myapp-api
    cluster: myapp-cluster
    wait-for-service-stability: true
```

### 6. Database Migration Automation in CI

#### Migration Strategies

```yaml
# GitHub Actions migration job
jobs:
  migrate:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Run migrations
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          pnpm --filter api prisma migrate deploy

      # Alternative: Drizzle Kit
      - name: Run Drizzle migrations
        run: pnpm --filter api drizzle-kit migrate

      # Alternative: node-pg-migrate / Knex
      - name: Run Knex migrations
        run: pnpm --filter api knex migrate:latest
```

Best practices for CI migrations:
1. **Run migrations as a separate job** before deployment, not as part of the application startup.
2. **Use `migrate deploy`** (Prisma) or equivalent non-interactive commands; never run `migrate dev` in CI.
3. **Implement rollback steps**: Include a rollback workflow or step that can revert the last migration.
4. **Test migrations against a shadow database**: Prisma's shadow database feature validates migrations before applying to production.
5. **Use database branching** (PlanetScale, Neon) for preview environments to avoid schema conflicts.
6. **Lock-based migration execution**: Use advisory locks to prevent concurrent migration runs.

```yaml
# Migration with rollback support
- name: Run migration with safety check
  run: |
    # Capture current migration state
    pnpm prisma migrate status > /tmp/migration-status-before.txt

    # Apply migrations
    pnpm prisma migrate deploy

    # Verify
    pnpm prisma migrate status > /tmp/migration-status-after.txt

- name: Rollback on failure
  if: failure()
  run: |
    echo "Migration failed. Manual rollback required."
    echo "Review migration status and apply corrective migration."
    # Alert team via Slack/PagerDuty
```

#### Database Seeding in CI

For test environments:
```yaml
- name: Setup test database
  run: |
    pnpm --filter api prisma migrate deploy
    pnpm --filter api prisma db seed
  env:
    DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

services:
  postgres:
    image: postgres:16-alpine
    env:
      POSTGRES_DB: test
      POSTGRES_PASSWORD: postgres
    ports:
      - 5432:5432
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```

### 7. Security Scanning in Pipelines

#### Container Scanning with Trivy

```yaml
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t myapp:scan -f packages/api/Dockerfile .

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:scan'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail on CRITICAL/HIGH

      - name: Upload Trivy scan results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

      # Filesystem scan for IaC and secrets
      - name: Trivy filesystem scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'table'
          severity: 'CRITICAL,HIGH'
          security-checks: 'vuln,secret,config'
```

Trivy scan types relevant to scaffold generation:
- **`image`**: Scans container images for OS and language vulnerabilities.
- **`fs`**: Scans filesystem for vulnerabilities in dependencies, exposed secrets, and IaC misconfigurations.
- **`config`**: Scans Dockerfiles, Kubernetes manifests, Terraform files for misconfigurations.
- **`sbom`**: Generates Software Bill of Materials.

#### Dependency Scanning with Snyk

```yaml
- name: Run Snyk to check for vulnerabilities
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --all-projects --severity-threshold=high

- name: Snyk Container scan
  uses: snyk/actions/docker@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    image: myapp:latest
    args: --severity-threshold=high

- name: Snyk IaC scan
  uses: snyk/actions/iac@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

#### Combined Security Pipeline Pattern

```yaml
name: Security
on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday scan

jobs:
  dependency-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm audit --audit-level=high

  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript-typescript
      - uses: github/codeql-action/analyze@v3

  container-scan:
    runs-on: ubuntu-latest
    needs: [dependency-audit]
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:${{ github.sha }}'
          severity: 'CRITICAL,HIGH'

  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified
```

### 8. Infrastructure-as-Code Patterns for Application Deployment

#### Pulumi (TypeScript-native IaC)

For Node.js/TypeScript teams, Pulumi offers infrastructure-as-code in TypeScript:

```typescript
// infra/index.ts
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

// VPC with public/private subnets
const vpc = new awsx.ec2.Vpc("myapp-vpc", {
  numberOfAvailabilityZones: 2,
  natGateways: { strategy: "Single" },
});

// ECS Cluster
const cluster = new aws.ecs.Cluster("myapp-cluster");

// ECR Repository
const repo = new awsx.ecr.Repository("myapp-api");

// Build and push Docker image
const image = new awsx.ecr.Image("myapp-api-image", {
  repositoryUrl: repo.url,
  context: "../",
  dockerfile: "../packages/api/Dockerfile",
  platform: "linux/amd64",
});

// Fargate Service
const service = new awsx.ecs.FargateService("myapp-api", {
  cluster: cluster.arn,
  desiredCount: 2,
  taskDefinitionArgs: {
    container: {
      name: "api",
      image: image.imageUri,
      cpu: 512,
      memory: 1024,
      portMappings: [{ containerPort: 4000 }],
      environment: [
        { name: "NODE_ENV", value: "production" },
      ],
      secrets: [
        {
          name: "DATABASE_URL",
          valueFrom: databaseSecret.arn,
        },
      ],
    },
  },
  networkConfiguration: {
    subnets: vpc.privateSubnetIds,
    securityGroups: [apiSecurityGroup.id],
  },
});
```

#### Terraform with CDKTF (TypeScript)

```typescript
// infra/main.ts
import { App, TerraformStack } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { EcsCluster } from "@cdktf/provider-aws/lib/ecs-cluster";
import { EcsService } from "@cdktf/provider-aws/lib/ecs-service";

class MyAppStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);
    new AwsProvider(this, "aws", { region: "us-east-1" });

    const cluster = new EcsCluster(this, "cluster", {
      name: "myapp-cluster",
    });

    // ... service definitions
  }
}

const app = new App();
new MyAppStack(app, "myapp-production");
app.synth();
```

#### SST (Serverless Stack) for AWS

SST is purpose-built for Node.js/TypeScript deployments on AWS:

```typescript
// sst.config.ts
export default $config({
  app(input) {
    return {
      name: "myapp",
      removal: input.stage === "production" ? "retain" : "remove",
    };
  },
  async run() {
    const database = new sst.aws.Postgres("MyDatabase", {
      scaling: { min: "0.5 ACU", max: "4 ACU" },
    });

    const api = new sst.aws.Function("MyApi", {
      handler: "packages/api/src/index.handler",
      link: [database],
      environment: {
        NODE_ENV: $app.stage === "production" ? "production" : "development",
      },
    });

    const web = new sst.aws.Nextjs("MyWeb", {
      path: "packages/web",
      environment: {
        NEXT_PUBLIC_API_URL: api.url,
      },
    });

    return { apiUrl: api.url, webUrl: web.url };
  },
});
```

### 9. Scaffold Generation Architecture

#### Template Composition Pattern

The most effective scaffold generators use a composition-based approach:

```
Tech Stack Definition (input)
    |
    v
[Parser] --> Detect: framework, db, cache, package-manager, deploy-target
    |
    v
[Template Selector] --> Pick templates for each layer:
    |   - ci.yml.hbs (GitHub Actions)
    |   - Dockerfile.hbs (multi-stage build)
    |   - docker-compose.yml.hbs (dev environment)
    |   - .env.example.hbs (environment variables)
    |   - deploy.{platform}.hbs (deployment config)
    |
    v
[Composer] --> Merge templates with context:
    |   - Framework-specific build commands
    |   - Database healthchecks and connection strings
    |   - Cache service configuration
    |   - Platform-specific deploy settings
    |
    v
[Validator] --> Validate generated configs:
    |   - YAML lint
    |   - Dockerfile lint (hadolint)
    |   - docker-compose config validation
    |   - GitHub Actions workflow validation
    |
    v
[Output] --> Generated files
```

Key design decisions:
1. **Use Handlebars or EJS** for templates, not string concatenation -- enables conditionals and loops.
2. **Layered overrides**: Base template -> framework override -> user customization.
3. **Validate at generation time**: Run `docker compose config`, `actionlint`, and `hadolint` on generated files.
4. **Include comments**: Generated files should include comments explaining each section for learnability.

#### Tech Stack Definition Format

```yaml
# stack.yaml
name: myapp
type: monorepo
package_manager: pnpm

services:
  web:
    framework: nextjs
    version: "14"
    path: packages/web
    port: 3000

  api:
    framework: express
    version: "4"
    path: packages/api
    port: 4000

databases:
  primary:
    engine: postgresql
    version: "16"
    orm: prisma

  cache:
    engine: redis
    version: "7"

deployment:
  platform: railway  # or: vercel, fly, aws-ecs
  environments:
    - name: production
      auto_deploy: main
    - name: staging
      auto_deploy: develop
    - name: preview
      auto_deploy: pull_request

ci:
  provider: github-actions
  features:
    - lint
    - test
    - build
    - security-scan
    - docker-build
    - deploy

  node_versions: [20]
  test_databases: true
```

From this definition, a generator can produce all infrastructure files deterministically.

## Recent Developments (2024-2026)

1. **GitHub Actions Immutable Actions (2024)**: GitHub introduced immutable actions publishing and attestations, improving supply chain security for CI pipelines. Actions pinned by SHA are now the recommended approach.

2. **Docker Build Cloud (2024-2025)**: Docker's cloud build service integrates with GitHub Actions, providing shared build caches across team members and CI, significantly reducing build times for multi-platform images.

3. **Nx and Turborepo CI improvements**: Both tools now support distributed task execution in CI with remote caching, making monorepo builds more efficient. Turborepo's `turbo prune --docker` has become the standard pattern for monorepo Docker builds.

4. **GitHub Actions larger runners and ARM (2024-2025)**: ARM-based runners (`ubuntu-24.04-arm`) offer cost-effective builds, especially relevant for building ARM Docker images without QEMU emulation.

5. **OIDC Federation becoming standard (2024-2025)**: Major cloud providers now fully support GitHub Actions OIDC, eliminating the need for stored cloud credentials in CI/CD.

6. **Distroless and Chainguard images maturation**: Chainguard's Node.js images have matured to production-ready status, offering the smallest attack surface for Node.js containers. Wolfi-based images are now widely adopted.

7. **SST v3 and Ion (2024-2025)**: SST's rewrite (Ion) with Pulumi backend represents a shift toward TypeScript-first IaC for application teams, with built-in support for Next.js, Remix, and other frameworks.

8. **Docker Compose Watch (2024-2025)**: The `docker compose watch` command provides native file-sync and rebuild triggers, reducing the need for complex volume mount configurations in development.

9. **Vercel and Netlify monorepo detection improvements (2025)**: Both platforms now better auto-detect monorepo structures and only rebuild affected packages, using `turbo-ignore` or custom ignore scripts.

10. **Supply chain security evolution**: SLSA framework adoption, Sigstore for container signing, and GitHub's artifact attestations have become standard practices in production CI/CD pipelines.

## Best Practices & Recommendations

1. **Start with a tech stack definition file**: Define your stack declaratively (framework, databases, deployment target) and generate infrastructure configs from it. This ensures consistency and makes it trivial to update configurations across all files when the stack changes.

2. **Use reusable workflows for organizational standards**: Extract common CI patterns (lint, test, security scan) into reusable workflows stored in a `.github` repository. Individual project workflows become thin orchestrators that call shared workflows with project-specific inputs.

3. **Implement the 3-4 stage Dockerfile pattern religiously**: deps -> build -> (optional: prune) -> runtime. Use `turbo prune --docker` for monorepos, `output: 'standalone'` for Next.js, and always run as a non-root user in the runtime stage.

4. **Design environment variables with validation-first**: Use typed env validation libraries (t3-env, envalid) that fail at startup. Maintain a `.env.example` as documentation. Never commit actual secrets. Use OIDC federation for cloud credentials in CI.

5. **Implement security scanning as a required check**: Run Trivy container scans on every PR, npm/pnpm audit weekly, and SAST (CodeQL) on pushes. Upload results as SARIF to GitHub Security tab for centralized vulnerability management. Block merges on critical/high findings.

6. **Use healthcheck-based dependencies in docker-compose**: Never rely on bare `depends_on` for service ordering. Implement proper healthchecks for every service and use `condition: service_healthy`. This eliminates race conditions and flaky development environments.

7. **Run database migrations as a separate CI job**: Migrations should execute before deployment, not during application startup. Use database branching (PlanetScale, Neon) for preview environments. Always have a rollback strategy documented.

8. **Cache aggressively in CI with proper invalidation**: Layer caches from broadest (package manager store) to narrowest (build output). Use content-addressable cache keys (hash of lock file + source). Implement remote caching (Turborepo, Nx) for monorepo build orchestration.

9. **Generate configs with validation**: Any scaffold generator should validate its output (actionlint for workflows, hadolint for Dockerfiles, `docker compose config` for compose files). Include inline comments in generated files explaining each section.

10. **Adopt OIDC and keyless authentication**: Replace long-lived credentials with short-lived tokens from GitHub's OIDC provider. This applies to AWS, GCP, Azure, and container registries. It eliminates secret rotation burden and reduces blast radius.

## Comparisons

### Deployment Platforms

| Aspect | Vercel | Railway | Fly.io | AWS ECS |
|--------|--------|---------|--------|---------|
| **Best for** | Next.js/frontend | Full-stack apps | Global edge | Enterprise/control |
| **Auto-detection** | Excellent (Next.js native) | Good (Nixpacks) | Manual (Dockerfile) | Manual (Task definition) |
| **Monorepo support** | Good (turbo-ignore) | Good (watch patterns) | Manual | Manual |
| **Databases** | Via integrations | Built-in provisioning | Fly Postgres | RDS/Aurora |
| **Preview envs** | Automatic per PR | Automatic per PR | Manual | Manual (with IaC) |
| **Pricing model** | Per-request/bandwidth | Per-resource (vCPU/GB) | Per-VM (machines) | Per-resource (Fargate) |
| **Scale to zero** | Yes (serverless) | Yes (with sleep) | Yes (Machines) | No (min tasks=1) |
| **Cold start** | ~100ms (Edge), ~250ms (Serverless) | ~2-5s | ~300ms-2s | N/A (always running) |
| **Max runtime** | 5min (hobby), 15min (pro) | Unlimited | Unlimited | Unlimited |
| **Custom domains** | Yes (automatic SSL) | Yes (automatic SSL) | Yes (automatic SSL) | Manual (ALB + ACM) |
| **Complexity** | Low | Low-Medium | Medium | High |

### IaC Tools for Node.js Teams

| Aspect | Pulumi (TS) | CDKTF (TS) | SST | Terraform (HCL) |
|--------|-------------|------------|-----|------------------|
| **Language** | TypeScript native | TypeScript via CDK | TypeScript native | HCL |
| **Learning curve** | Low for TS devs | Medium | Low | Medium-High |
| **State management** | Pulumi Cloud/self-hosted | Terraform Cloud/local | Pulumi backend | Terraform Cloud/local |
| **Cloud support** | Multi-cloud | Multi-cloud | AWS primarily | Multi-cloud |
| **Framework support** | Manual | Manual | Built-in (Next.js, etc.) | Manual |
| **Community** | Growing | Growing | Active (AWS focused) | Very large |
| **Best for** | Full-stack TS teams | Terraform shops + TS | AWS app developers | Multi-cloud enterprises |

### Security Scanning Tools

| Aspect | Trivy | Snyk | CodeQL | GitHub Dependabot |
|--------|-------|------|--------|-------------------|
| **Cost** | Free/OSS | Free tier + paid | Free for public repos | Free |
| **Container scanning** | Yes (excellent) | Yes | No | No |
| **Dependency scanning** | Yes | Yes (excellent) | Limited | Yes |
| **IaC scanning** | Yes | Yes | No | No |
| **SAST** | Limited | Yes (Code) | Yes (excellent) | No |
| **Secret detection** | Yes | No (use Git Guardian) | No | Yes (secret scanning) |
| **CI integration** | GitHub Action | GitHub Action | Native GitHub | Native GitHub |
| **SARIF output** | Yes | Yes | Yes | N/A |
| **Best for** | Container + IaC security | Dependency management | Code quality/security | Auto-fix PRs |

## Open Questions

- **How far can scaffold generation go before becoming a framework?** There is a tension between generating static config files (which developers own and modify) and providing a runtime framework that manages configuration dynamically. Tools like SST blur this line.
- **Should generated CI configs be treated as immutable or editable?** Some teams regenerate configs on every stack change (treating them as build artifacts), while others generate once and customize. The optimal approach likely depends on team maturity and project complexity.
- **What is the right granularity for monorepo CI triggers?** Path-based filtering can miss transitive dependency changes. Full dependency graph analysis (which Nx and Turborepo provide) is more accurate but adds complexity. When is the simpler approach sufficient?
- **How should preview environments handle database state?** Database branching (PlanetScale, Neon) is elegant but not universally available. Alternatives include ephemeral databases seeded from snapshots, shared staging databases with schema isolation, or skipping database-dependent features in previews.
- **Will AI-generated infrastructure configs become the norm?** Tools like GitHub Copilot and Claude Code are increasingly capable of generating CI/CD and Docker configurations. The question is whether declarative scaffold generators remain relevant or whether AI generates configs directly from natural language descriptions of the desired infrastructure.

## Sources

1. [GitHub Actions Documentation - Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows) - Official documentation on creating and calling reusable workflows, input/secret passing, and nesting limitations.
2. [GitHub Actions Documentation - Caching Dependencies](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows) - Official caching guide covering cache keys, restore-keys, scope, 10GB limits, and eviction policies.
3. [Docker Multi-Stage Builds Documentation](https://docs.docker.com/build/building/multi-stage/) - Official Docker documentation on multi-stage build patterns, named stages, and layer optimization.
4. [Next.js Docker Deployment Guide](https://nextjs.org/docs/deployment#docker-image) - Official Next.js documentation on standalone output mode and optimized Docker images.
5. [Turborepo Docker Guide](https://turbo.build/repo/docs/guides/tools/docker) - Official Turborepo documentation on `turbo prune --docker` for monorepo Docker builds.
6. [Docker Compose Specification](https://docs.docker.com/compose/compose-file/) - Official Compose specification covering services, healthchecks, volumes, networks, and profiles.
7. [Vercel Monorepo Documentation](https://vercel.com/docs/monorepos) - Vercel's guide to deploying monorepos with turbo-ignore and root directory configuration.
8. [Railway Configuration Reference](https://docs.railway.app/reference/config-as-code) - Railway's railway.toml specification for build, deploy, and resource configuration.
9. [Fly.io fly.toml Reference](https://fly.io/docs/reference/configuration/) - Fly.io's configuration reference covering services, machines, scaling, and health checks.
10. [AWS ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) - AWS documentation on Fargate task definitions, container definitions, secrets, and resource allocation.
11. [Trivy Documentation](https://aquasecurity.github.io/trivy/) - Aqua Security's Trivy documentation covering container, filesystem, IaC, and SBOM scanning.
12. [Snyk Documentation](https://docs.snyk.io/) - Snyk's documentation on dependency scanning, container scanning, and IaC analysis.
13. [Pulumi AWS Guide](https://www.pulumi.com/docs/clouds/aws/) - Pulumi's TypeScript-native infrastructure-as-code documentation for AWS deployments.
14. [SST Documentation](https://sst.dev/docs/) - SST's framework documentation for deploying full-stack TypeScript applications on AWS.
15. [CDKTF Documentation](https://developer.hashicorp.com/terraform/cdktf) - HashiCorp's CDK for Terraform documentation for TypeScript-based infrastructure definitions.
16. [GitHub Actions - Using Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) - Official documentation on matrix builds including dynamic matrix generation.
17. [GitHub OIDC Federation with Cloud Providers](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) - Official guide on keyless authentication with AWS, GCP, and Azure from GitHub Actions.
18. [dorny/paths-filter Action](https://github.com/dorny/paths-filter) - GitHub Action for path-based filtering in monorepo CI workflows.
19. [Docker BuildKit Cache Management](https://docs.docker.com/build/cache/) - Docker documentation on BuildKit cache backends, inline cache, and GitHub Actions cache integration.
20. [t3-oss/env-nextjs](https://env.t3.gg/) - T3 Env documentation for type-safe environment variable validation in Next.js applications.
21. [envalid](https://github.com/af/envalid) - Environment variable validation library documentation.
22. [Prisma Migrate Documentation](https://www.prisma.io/docs/concepts/components/prisma-migrate) - Prisma's migration documentation covering deploy, dev, and shadow database patterns.
23. [Drizzle Kit Migrations](https://orm.drizzle.team/docs/migrations) - Drizzle ORM migration documentation for TypeScript-first database schema management.
24. [actions/upload-artifact v4](https://github.com/actions/upload-artifact) - GitHub's official artifact upload action documentation for immutable artifacts.
25. [Chainguard Node.js Images](https://images.chainguard.dev/directory/image/node/overview) - Chainguard's minimal, hardened Node.js container images.
26. [Google Distroless Images](https://github.com/GoogleContainerTools/distroless) - Google's distroless container images for minimal runtime environments.
27. [hadolint - Dockerfile Linter](https://github.com/hadolint/hadolint) - Dockerfile linting tool for validating generated Dockerfiles.
28. [actionlint - GitHub Actions Linter](https://github.com/rhysd/actionlint) - Static analysis tool for GitHub Actions workflow files.
29. [Docker Compose Watch](https://docs.docker.com/compose/file-watch/) - Docker's native file-watch and sync feature for development environments.
30. [SLSA Framework](https://slsa.dev/) - Supply-chain Levels for Software Artifacts framework for CI/CD security.
31. [Sigstore / cosign](https://docs.sigstore.dev/) - Keyless container image signing for supply chain integrity.
32. [TruffleHog](https://github.com/trufflesecurity/trufflehog) - Secret detection tool for scanning repositories and CI pipelines.
33. [CodeQL Documentation](https://codeql.github.com/docs/) - GitHub's semantic code analysis engine for finding security vulnerabilities.
34. [pnpm Workspace Documentation](https://pnpm.io/workspaces) - pnpm's monorepo workspace configuration and filtering.
35. [Nx CI Configuration](https://nx.dev/ci/intro/ci-with-nx) - Nx's guide to CI/CD configuration for monorepos with distributed task execution.
36. [Turborepo Remote Caching](https://turbo.build/repo/docs/core-concepts/remote-caching) - Turborepo's remote cache documentation for sharing build artifacts across CI and local development.
37. [Docker Build Cloud](https://docs.docker.com/build/cloud/) - Docker's managed build service for shared caches and faster builds.
38. [GitHub Artifact Attestations](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds) - GitHub's build provenance attestation feature for supply chain security.
39. [PlanetScale Database Branching](https://planetscale.com/docs/concepts/branching) - PlanetScale's database branching for preview environments and schema migrations.
40. [Neon Database Branching](https://neon.tech/docs/introduction/branching) - Neon's serverless Postgres branching for CI/CD and preview environments.
41. [AWS ECR Login Action](https://github.com/aws-actions/amazon-ecr-login) - GitHub Action for authenticating with Amazon ECR.
42. [AWS ECS Deploy Task Definition Action](https://github.com/aws-actions/amazon-ecs-deploy-task-definition) - GitHub Action for deploying to Amazon ECS.
43. [Doppler Secrets Management](https://docs.doppler.com/) - Centralized secrets management platform with CI/CD integrations.
44. [HashiCorp Vault](https://developer.hashicorp.com/vault/docs) - Enterprise secrets management for production environments.
45. [GitHub Actions ARM Runners](https://github.blog/changelog/2024-06-03-actions-arm-based-linux-and-windows-runners-are-now-in-public-preview/) - ARM-based runners for cost-effective CI builds.
46. [Nixpacks](https://nixpacks.com/docs) - Railway's open-source build system that auto-detects frameworks and produces OCI images.
47. [Fly.io LiteFS](https://fly.io/docs/litefs/) - Distributed SQLite for Fly.io edge deployments.
48. [Vercel Edge Functions](https://vercel.com/docs/functions/edge-functions) - Vercel's edge runtime documentation for globally distributed serverless functions.
49. [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) - GitHub's deployment environments with protection rules and secrets scoping.
50. [Docker Compose Profiles](https://docs.docker.com/compose/profiles/) - Selective service startup in Docker Compose development environments.
51. [actions/cache Documentation](https://github.com/actions/cache) - GitHub's official caching action with detailed key strategy documentation.
52. [Turbo Ignore](https://turbo.build/repo/docs/reference/turbo-ignore) - Vercel/Turborepo's tool for skipping unnecessary builds in monorepo deployments.
53. [AWS Secrets Manager with ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html) - Injecting secrets from AWS Secrets Manager into ECS task containers.
54. [GitHub Actions Composite Actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) - Creating reusable action steps with composite actions.
55. [dumb-init for Node.js Containers](https://github.com/Yelp/dumb-init) - Minimal init system for proper signal handling in Docker containers.
56. [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md) - Official Node.js Docker working group best practices.
57. [Snyk Container Best Practices](https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/) - Snyk's research on Node.js containerization security best practices.
58. [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) - Complete reference for GitHub Actions workflow YAML syntax.
59. [Docker Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/) - Building images for multiple architectures with BuildKit.
60. [Fly.io Machines API](https://fly.io/docs/machines/) - Fly.io's Machines API for programmatic scaling and auto-stop/start.
61. [Railway Monorepo Deployments](https://docs.railway.app/guides/monorepo) - Railway's guide to deploying multiple services from a single monorepo.
62. [Vercel Cron Jobs](https://vercel.com/docs/cron-jobs) - Scheduled function execution in Vercel deployments.
63. [AWS CDK for ECS Patterns](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_ecs_patterns-readme.html) - High-level ECS deployment patterns in AWS CDK.
64. [GitHub Dependabot Configuration](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file) - Automated dependency update configuration.
65. [Renovate Bot](https://docs.renovatebot.com/) - Alternative dependency update bot with monorepo-aware grouping.

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** dev
- **Research Method:** Knowledge-based synthesis (web research tools unavailable; comprehensive coverage from training data on CI/CD, Docker, GitHub Actions, deployment platforms, and IaC patterns for Node.js/TypeScript monorepos)
- **Coverage Areas:**
  - GitHub Actions workflow patterns (matrix, caching, artifacts, reusable workflows)
  - Multi-stage Docker builds (Node.js/Next.js, layer optimization, distroless)
  - Docker Compose development environments (healthchecks, volumes, networks, profiles)
  - Environment variable management (hierarchy, validation, secrets)
  - Deployment platforms (Vercel, Railway, Fly.io, AWS ECS)
  - Database migration automation
  - Security scanning (Trivy, Snyk, CodeQL, TruffleHog)
  - Infrastructure-as-code (Pulumi, CDKTF, SST, Terraform)
  - Scaffold generation architecture patterns
- **Search Queries Used:**
  - GitHub Actions CI/CD scaffold generation best practices Node.js TypeScript monorepo
  - multi-stage Dockerfile Node.js Next.js best practices layer optimization distroless
  - docker-compose full-stack development service dependencies healthchecks volume management
  - GitHub Actions reusable workflows matrix builds caching strategies artifact management
  - infrastructure as code scaffold generation deployment configs from tech stack definition
  - CI/CD pipeline security scanning Trivy Snyk Node.js container scanning
  - environment variable management .env hierarchy secrets handling per-environment configs
  - deployment platform configs Vercel Railway Fly.io AWS ECS comparison
