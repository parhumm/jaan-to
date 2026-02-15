# Lessons: devops-infra-scaffold

> Last updated: 2026-02-10

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:devops-infra-scaffold.learn.md`

Seeded from research: $JAAN_OUTPUTS_DIR/research/74-dev-cicd-infra-scaffold-generation.md

---

## Better Questions

Questions to ask during information gathering:

- Ask about monorepo vs single-repo -- determines path filtering, turbo prune, and build scoping strategies
- Ask about environment count and promotion strategy -- dev/staging/production or just dev/production
- Ask about existing CI/CD setup before generating -- detect-dev output may reveal workflows to preserve or migrate
- Ask about container registry preference -- ghcr.io is free for public repos, ECR for AWS-heavy teams
- Ask about database migration tool -- Prisma migrate deploy vs Drizzle Kit vs golang-migrate differ significantly
- Ask about secret management approach -- GitHub Secrets vs Doppler vs AWS Secrets Manager vs HashiCorp Vault
- Ask about preview environment strategy -- per-PR deploys need ephemeral databases (Neon/PlanetScale branching)

## Edge Cases

Special cases to check and handle:

- Monorepo with shared packages -- path filters must include `packages/shared/**` as trigger for all dependent services
- Next.js standalone mode requires `output: 'standalone'` in next.config -- when generating Dockerfile.frontend with standalone COPY stage, check if config already has it; if missing, generate `config/next.config.standalone.ts` reference snippet and add README verification step
- pnpm store cache path differs between CI runners -- use `actions/setup-node@v4` built-in cache, not manual paths
- pnpm `packageManager` field in package.json: check for field presence before configuring `pnpm/action-setup@v4` -- if `packageManager` exists, omit the `version` parameter (action reads it from package.json); if absent, set `version` explicitly. Mismatch causes `ERR_PNPM_BAD_PM_VERSION`
- Docker BuildKit cache mounts need `DOCKER_BUILDKIT=1` on older Docker versions
- PostgreSQL healthcheck needs the correct `-U` flag matching `POSTGRES_USER`
- docker-compose volume mounts: anonymous volume for node_modules prevents host/container architecture mismatch
- `.env` files with `#` in values need quoting -- common gotcha with passwords containing hash characters
- GitHub Actions matrix builds with `fail-fast: false` -- ensure all combinations run even if one fails
- ARM-based CI runners (ubuntu-24.04-arm) need different Docker base images or multi-platform builds
- Railway watch patterns must include all workspace dependencies, not just the target package
- Fly.io `auto_stop_machines` can cause cold starts -- warn if latency-sensitive

## Workflow

Process improvements:

- Read tech.md FIRST -- framework determines every infrastructure decision
- Check detect-dev output for existing CI/CD before generating from scratch
- Follow input priority: tech.md -> backend-scaffold -> frontend-scaffold -> detect-dev
- Generate CI workflow before CD -- CI is prerequisite for CD
- Generate Dockerfiles before docker-compose -- compose references Dockerfiles
- Always validate docker-compose with `docker compose config` (mentally or actually)
- Include inline comments in all generated YAML/Dockerfile/shell files for learnability

## Common Mistakes

Things to avoid:

- Generating GitHub Actions workflows when the project uses GitLab CI -- always confirm CI platform
- Using `depends_on` without `condition: service_healthy` -- services start but may not be ready
- Missing `.dockerignore` -- causes bloated build context and potential secret leakage
- Hardcoding secrets in .env.example -- use placeholder values like `change-me-in-production`
- Using `node:20` (Debian) instead of `node:20-alpine` -- 1.1GB vs 180MB image size
- Running as root in Docker runtime stage -- always add non-root user
- Missing `--frozen-lockfile` in CI installs -- allows non-reproducible builds
- Generating migration commands for wrong ORM (e.g., `prisma migrate deploy` when project uses Drizzle)
- Not separating migration job from deployment job in CD pipeline
- Using `npm audit` when project uses pnpm -- use `pnpm audit` instead
- Committing `.env` in generated .gitignore exclusions -- make sure `.env*` pattern is in .gitignore
- Using `latest` tag for Docker base images -- pin to specific versions (e.g., `node:20-alpine`)
- Forgetting `NEXT_TELEMETRY_DISABLED=1` in Next.js Docker builds
- Passing explicit `version` to `pnpm/action-setup@v4` when `packageManager` field exists in package.json -- causes `ERR_PNPM_BAD_PM_VERSION` because action reads version from package.json and conflicts with explicit param
- Generating Dockerfile.frontend with standalone COPY stage but no `output: 'standalone'` in next.config -- Docker build succeeds but `.next/standalone` directory is empty, causing runtime failure
- Creating duplicate incident issues in health-check workflow -- always search for existing open issues with `incident` label before creating a new one
