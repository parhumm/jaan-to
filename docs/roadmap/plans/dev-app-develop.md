# Plan: Create `dev-app-develop` Skill

## Context

The user wants a new jaan-to skill that orchestrates full-lifecycle app development — from task selection through deployment. The original ~600-line spec was project-specific (jaan.coach). It must be **generified**: no project-specific references, no hardcoded credentials/IPs, technology-agnostic (reads stack from `tech.md`), and portable across any project.

This is the **first "action skill"** in jaan-to — it writes source code to the project itself (not to `jaan-to/outputs/`), runs tests, commits, and pushes.

**Research conducted**: 600+ sources across 13 agents covering SDLC, CI/CD, Git workflows, AI-assisted dev, deployment strategies, feature flags, incident management, security, metrics (DORA/SPACE), code review, collaboration, scaffold generation, backend service patterns, BDD test generation, security hardening, SARIF remediation, and CI/CD infrastructure. Full findings documented across 7 research documents:

| # | Research Document | Key Contributions to This Skill |
|---|-------------------|-------------------------------|
| 68 | [Full-Cycle App Development Workflow](../../jaan-to/outputs/research/68-dev-fullcycle-app-development-workflow.md) | SDLC phases, DORA metrics, conventional commits, feature flags, observability |
| 69 | [Scaffold-to-Project Assembly](../research/69-dev-scaffold-project-assembly-automation.md) | Monorepo detection, provider wiring, config inheritance, env var layering |
| 70 | [Backend Service Implementation](../research/70-dev-backend-service-implementation-generation.md) | Service layer architecture, RFC 9457 errors, pagination, auth/JWT, transactions, idempotency |
| 71 | [BDD/Gherkin Test Generation](../research/71-qa-bdd-gherkin-test-code-generation.md) | Test tag routing, data factories, MSW mocks, coverage strategies, playwright-bdd |
| 72 | [Secure Backend Scaffold Hardening](../research/72-dev-secure-backend-scaffold-hardening.md) | OWASP Top 10 mapping, jose JWT, helmet/CORS/rate-limit defaults, input sanitization |
| 73 | [SARIF Security Remediation](../research/73-dev-sarif-security-remediation-automation.md) | SARIF parsing, CWE-to-fix mapping, security regression tests, CI security gates |
| 74 | [CI/CD Infra Scaffold Generation](../research/74-dev-cicd-infra-scaffold-generation.md) | GitHub Actions patterns, Docker multi-stage, docker-compose, deployment configs |

---

## Files to Create

### 1. `skills/dev-app-develop/SKILL.md`

**Frontmatter:**
```yaml
---
name: dev-app-develop
description: Full-lifecycle app development from task selection through implementation, testing, and deployment.
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write, Edit, AskUserQuestion, Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(pip:*), Bash(python:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*), Bash(composer:*), Bash(php:*), Bash(make:*), Bash(docker:*), Bash(curl:*), Bash(semgrep:*), Bash(trivy:*)
argument-hint: [task-id or task-description]
---
```

**Body structure** (research-informed, all generic):

| Section | Content | Research Basis |
|---------|---------|----------------|
| `# dev-app-develop` | Title + tagline | — |
| `## Context Files` | tech.md (CRITICAL), config.md, boundaries.md, learn.md | — |
| `## Input` | Task ID, description, roadmap path, or empty (interactive) | — |
| `## Pre-Execution` | Standard learn.md + language protocol | v3.0.0 spec |
| `# PRE-FLIGHT CHECK` | Verify tech.md, git repo, detect project structure, check branch, detect monorepo, detect security tooling | R68 Twelve-Factor, R69 monorepo detection, R72 OWASP |
| `# PHASE 0: Task Selection` | Generic roadmap/task Glob, present task, create feature branch | R68 Agile/workflow, trunk-based dev |
| `# PHASE 1: Analysis` | ultrathink, explore codebase, detect stack, detect architecture patterns, design plan with files/deps/tests/risks/security, cross-ref existing patterns | R69 scaffold detection, R70 service layer, R72 security audit |
| `# HARD STOP` | Present plan with security implications, require approval | — |
| `# PHASE 2: Implementation` | TodoWrite tracking, install deps, implement with architecture awareness, write tests with tiered strategy, quality + security checks | R70 backend patterns, R71 test strategy, R72 security defaults |
| `# PHASE 3: Test & Fix Loop` | Run tests (unit→integration→E2E), security scan, fix failures (max 3 iter), re-run quality, results summary | R71 coverage strategy, R73 SARIF remediation |
| `# PHASE 4: Commit & Deploy` | Conventional commits, push, optional PR via `gh`, CI/CD monitoring, git-based rollback only | R68 progressive delivery, R74 CI/CD patterns |
| `# PHASE 5: Documentation & Closure` | Changelog, roadmap, learn-add, summary with DORA-aligned metrics | R68 conventional commits → semantic release |
| `## Security Checklist` | OWASP Top 10 mapped, SARIF scan, dependency audit, secret detection | R72 OWASP mapping, R73 SARIF pipeline |
| `## Safety Rules` | Never skip tests, verify CI/CD, human confirmation, rollback-first | R68 Google SRE, R72 security-first |
| `## Definition of Done` | Research-backed checklist including security verification | R68 + R72 + R73 |

---

### Detailed Phase Specifications (Research-Enriched)

#### PRE-FLIGHT CHECK (enhanced with R69, R72, R74)

Current plan detects tech.md, git repo, project structure, branch. **Add:**

1. **Monorepo detection** (R69): Check for `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json`. If monorepo detected, identify which package(s) the task affects. Use `pnpm --filter` / `turbo --filter` scoping throughout.

2. **Architecture pattern detection** (R69, R70): Check for:
   - `apps/` + `packages/` directory structure (monorepo layout)
   - `src/routes/` or `src/app/` (framework routing patterns)
   - `src/services/` or `src/modules/` (service layer pattern)
   - `prisma/schema.prisma` or `drizzle.config.ts` (ORM)
   - `openapi.yaml` / `swagger.json` (API contract)

3. **Security tooling detection** (R72, R73): Check for:
   - `.github/workflows/*security*` or CodeQL config
   - `.semgrepignore` or `semgrep.yml`
   - `.snyk` or `snyk.config`
   - `@fastify/helmet`, `@fastify/rate-limit`, `@fastify/cors` in deps

4. **Test infrastructure detection** (R71): Check for:
   - `vitest.config.*` / `jest.config.*` / `playwright.config.*`
   - `features/*.feature` (Gherkin/BDD)
   - `test/factories/` or `test/mocks/` (existing test data patterns)
   - `test/setup/` files (MSW, DB seeding)

5. **CI/CD detection** (R74): Check for:
   - `.github/workflows/` (GitHub Actions)
   - `Dockerfile` / `docker-compose.yml`
   - `vercel.json` / `railway.toml` / `fly.toml`
   - `.env.example` (environment variable documentation)

6. **Environment variable management** (R69, R74): Check for:
   - `src/env.ts` or `src/env.mjs` (typed env validation with `@t3-oss/env-nextjs` or `envalid`)
   - `.env.example` file (document all required vars)
   - Warn if `.env` files are tracked in git

#### PHASE 1: Analysis (enhanced with R69, R70, R72)

Current plan explores codebase, detects stack, designs plan. **Add:**

1. **Service architecture awareness** (R70): When task involves backend changes, detect and follow existing patterns:
   - **Layer separation**: Route handlers → Service layer → Repository/ORM. Never put business logic in route handlers.
   - **Error handling pattern**: Check if RFC 9457 (Problem Details) or custom error format is used. Follow existing convention.
   - **Pagination pattern**: Check if cursor-based or offset-based is used. Default to cursor-based for new endpoints (R70: stable under concurrent writes, O(1) seek).
   - **Auth pattern**: Detect JWT (check for `jose` or `jsonwebtoken`), session-based (`@fastify/secure-session`), or OAuth. Follow existing pattern.

2. **Frontend architecture awareness** (R69): When task involves frontend changes, detect:
   - **Provider composition**: Check `app/providers.tsx` or `_app.tsx` for provider ordering. Follow existing nesting (Auth → Theme → Data → State).
   - **Component patterns**: Check for barrel exports, sub-path exports, shared packages.
   - **Server/client boundaries**: In Next.js App Router, respect `"use client"` directives. New providers go in `providers.tsx`.

3. **Security-first analysis** (R72): For every change, evaluate:
   - Does this handle user input? → Plan input validation + sanitization
   - Does this expose an API endpoint? → Plan auth, rate limiting, CORS
   - Does this store/transmit sensitive data? → Plan encryption, secure headers
   - Does this add dependencies? → Plan dependency audit

4. **Test strategy in plan** (R71): Include in plan output:
   - Which test tiers are needed (unit / integration / E2E)
   - Tag routing: `@unit` → Vitest, `@e2e` → Playwright
   - Whether test data factories or MSW mocks are needed
   - Whether new Gherkin scenarios should be written (if BDD is used)

5. **Enhanced tech detection tables** (R69, R70, R72):

   **Monorepo tools detection:**
   | Indicator File | Tool | Filter Command |
   |---------------|------|---------------|
   | `turbo.json` | Turborepo | `turbo --filter=<pkg>` |
   | `nx.json` | Nx | `nx affected --target=<task>` |
   | `pnpm-workspace.yaml` | pnpm workspaces | `pnpm --filter <pkg>` |
   | `lerna.json` | Lerna | `lerna run --scope=<pkg>` |

   **ORM/Database detection:**
   | Indicator File | ORM | Migration Command | Query Style |
   |---------------|-----|-------------------|-------------|
   | `prisma/schema.prisma` | Prisma | `prisma migrate deploy` | Fluent API, `include`/`select` |
   | `drizzle.config.ts` | Drizzle | `drizzle-kit migrate` | SQL-like builder |
   | `knexfile.ts` | Knex | `knex migrate:latest` | Query builder |
   | `ormconfig.ts` | TypeORM | `typeorm migration:run` | Active Record / Data Mapper |

   **Auth detection:**
   | Indicator | Pattern | Library |
   |-----------|---------|---------|
   | `jose` in deps | JWT verification (recommended) | `jose` |
   | `jsonwebtoken` in deps | JWT (legacy, consider migration) | `jsonwebtoken` |
   | `@fastify/secure-session` | Encrypted cookie sessions | sodium-native |
   | `next-auth` / `@auth/core` | OAuth/social auth | NextAuth.js |
   | `passport` in deps | Strategy-based auth | Passport.js |

   **Security plugin detection (Fastify):**
   | Plugin | Purpose | Default If Missing |
   |--------|---------|-------------------|
   | `@fastify/helmet` | Security headers (CSP, HSTS, X-Content-Type) | Recommend adding |
   | `@fastify/cors` | CORS with explicit origin allowlist | Recommend adding |
   | `@fastify/rate-limit` | Rate limiting (per-route configurable) | Recommend adding |
   | `@fastify/csrf-protection` | CSRF tokens for cookie-based auth | Recommend if cookies used |
   | `@fastify/secure-session` | Encrypted httpOnly cookie sessions | Recommend over localStorage JWT |

#### PHASE 2: Implementation (enhanced with R70, R71, R72)

Current plan: TodoWrite, install deps, implement, write tests, quality checks. **Add:**

1. **Backend implementation patterns** (R70): When implementing backend features:
   - **Service layer**: Create `services/<entity>.service.ts` with constructor-based DI. Pass `PrismaClient` (or ORM) as constructor param.
   - **Validation layers**: Schema validation (TypeBox/Zod) at route level + business rule validation in service layer + authorization guards as middleware.
   - **Error handling**: Use RFC 9457 Problem Details format if project has it. Map ORM errors (Prisma P2002 → 409 Conflict, P2025 → 404 Not Found).
   - **Transaction management**: Use interactive transactions (`prisma.$transaction(async (tx) => {...})`) for multi-step operations. Keep transactions short; move side effects (notifications, events) outside.
   - **Idempotency**: For POST endpoints creating resources, consider `Idempotency-Key` header pattern (R70: database-backed, 24h TTL).

2. **Frontend implementation patterns** (R69): When implementing frontend features:
   - **Provider wiring**: If adding a new provider, follow ordering: Session/Auth → Theme → Data (tRPC/React Query) → State (Zustand/Jotai).
   - **Shared packages**: Use `workspace:*` protocol for internal dependencies. Set `"main": "./src/index.ts"` for dev-time source imports.
   - **Bundle awareness**: Use `sideEffects: false` and sub-path exports for tree-shaking.

3. **Security-by-default implementation** (R72): For new endpoints/features:
   - **Input sanitization**: Beyond schema validation — sanitize HTML with DOMPurify for stored content, prevent prototype pollution (block `__proto__`, `constructor`, `prototype` keys).
   - **Parameterized queries only**: Never use string interpolation in raw SQL. Use ORM methods or tagged template literals (`prisma.$queryRaw\`...\``).
   - **No secrets in code**: All sensitive values via `process.env`. Check for accidentally hardcoded values.
   - **Secure defaults for new routes**: Require auth by default (explicitly mark public routes), include in rate limiting scope.

4. **Test implementation strategy** (R71): Write tests following tiered approach:

   **Test tier decision table:**
   | Change Type | Unit Test | Integration Test | E2E Test |
   |------------|-----------|-----------------|----------|
   | Pure function / utility | Required | — | — |
   | Service layer logic | Required | Recommended | — |
   | API endpoint | — | Required | Smoke |
   | UI component (logic) | Required | — | — |
   | UI component (interaction) | — | — | Required |
   | Auth flow | — | Required | Required |
   | Database migration | — | Required | — |

   **Test data strategy** (R71):
   - Use **Fishery** factories for entity construction with traits/sequences
   - Use **@anatine/zod-mock** for schema-derived defaults (if Zod schemas exist)
   - Use **MSW** handlers for API mocking in unit tests (check for existing `test/mocks/` setup)
   - For integration tests with DB: use transaction rollback isolation or truncate-and-seed per test

   **Coverage targets** (R71):
   | Tier | Target | Measurement |
   |------|--------|-------------|
   | Unit | 80% line, 70% branch | `@vitest/coverage-v8` |
   | Integration | 60% line | `@vitest/coverage-v8` |
   | E2E | Not line-measured | Scenario coverage (acceptance criteria → Gherkin) |

5. **Enhanced linter/formatter detection** (expanded with R69):

   | Indicator | Tool | Check Command | Fix Command |
   |-----------|------|--------------|-------------|
   | `eslint.config.*` / `.eslintrc.*` | ESLint | `eslint . --max-warnings 0` | `eslint . --fix` |
   | `biome.json` | Biome | `biome check .` | `biome check . --apply` |
   | `.prettierrc*` | Prettier | `prettier --check .` | `prettier --write .` |
   | `tsconfig.json` | TypeScript | `tsc --noEmit` | — |
   | `tooling/eslint/` | Shared ESLint config (monorepo) | `turbo lint` | `turbo lint -- --fix` |

#### PHASE 3: Test & Fix Loop (enhanced with R71, R73)

Current plan: Run tests, fix failures (max 3 iter), re-run quality. **Add:**

1. **Tiered test execution order** (R71):
   ```
   Step 1: Unit tests (fastest feedback)
     → Vitest / Jest with --reporter=verbose
   Step 2: Integration tests (DB/API)
     → Vitest with database setup or MSW
   Step 3: Lint + type-check
     → eslint + tsc --noEmit (or biome check)
   Step 4: Security scan (if tooling detected)
     → semgrep --config auto --sarif (or npm audit)
   Step 5: E2E tests (if relevant changes)
     → Playwright with --grep matching affected features
   ```

2. **Security scan integration** (R73): If security scanning tools detected in project:
   - Run `semgrep --config auto --sarif` or `npx eslint --plugin security` on changed files
   - Parse SARIF output for new findings
   - **Auto-remediation for high-confidence findings** (R73): CWE-327 (weak crypto) → replace algorithm; CWE-79 (XSS) → add DOMPurify; CWE-89 (SQL injection) → parameterize query
   - Report findings in test results summary with severity and CWE
   - Block proceeding to PHASE 4 if critical/high severity findings with high confidence

3. **Test failure analysis** (R71, R73):
   - On failure, distinguish: pre-existing failure (was in baseline) vs new failure (introduced by changes)
   - For security findings: apply CWE-to-remediation mapping (R73) for auto-fixable categories
   - For test failures: read error output, identify root cause, fix and re-run (max 3 iterations)
   - If hitting max iterations: present status to user with findings, ask whether to proceed or abort

4. **Results summary** (enhanced):
   ```
   Test Results:
   - Unit: X passed, Y failed, Z skipped
   - Integration: X passed, Y failed
   - E2E: X passed, Y failed
   - Lint: pass/fail
   - Type check: pass/fail
   - Security: X findings (C critical, H high, M medium, L low)
   - Coverage: X% line (target: 80%)
   ```

#### PHASE 4: Commit & Deploy (enhanced with R74)

Current plan: Conventional commits, push, PR, CI monitoring. **Add:**

1. **CI/CD awareness** (R74): Before pushing:
   - Check if `.github/workflows/` exists — if so, note which checks will run on PR
   - If Dockerfile exists and changes affect the service, note that container rebuild will be triggered
   - If `turbo.json` exists, note which packages will be affected by the change (dependency graph)

2. **PR creation enrichment** (R74): When creating PR:
   - Include security scan summary if findings were addressed
   - Reference test results (pass count, coverage delta)
   - If monorepo, note affected packages
   - Check CODEOWNERS file for auto-reviewer assignment

3. **Environment variable documentation** (R69, R74): If new env vars were introduced:
   - Update `.env.example` with new variable names and descriptions
   - Update typed env validation file (`env.ts`) if it exists
   - Note in PR description that environment configuration is required

#### PHASE 5: Documentation & Closure (enhanced)

Current plan: Changelog, roadmap, learn-add, DORA summary. **Add:**

1. **Architecture Decision Records** (R68): If the implementation involved an architectural choice (new dependency, pattern choice, technology decision), suggest creating an ADR in `docs/decisions/`:
   ```
   # ADR-XXX: [Decision Title]
   ## Context: [Why was this decision needed?]
   ## Decision: [What was chosen?]
   ## Alternatives: [What was considered?]
   ## Consequences: [What are the trade-offs?]
   ```

2. **Security documentation** (R72, R73): If security-relevant changes were made:
   - Note in changelog which security improvements were included
   - Update `SECURITY.md` if it exists and the change affects the security posture
   - Document any new security dependencies or configurations

---

### Security Checklist (enhanced with R72, R73)

The current checklist covers basics. **Replace with OWASP Top 10 mapped checklist:**

| # | OWASP Category | Check | How to Verify |
|---|---------------|-------|---------------|
| A01 | Broken Access Control | All endpoints require auth by default; public routes explicitly marked | Grep for route definitions without auth middleware |
| A02 | Cryptographic Failures | No MD5/SHA1 for security; TLS enforced; secrets in env vars | Grep for `createHash('md5')`, `createHash('sha1')` |
| A03 | Injection | Parameterized ORM queries only; no string concat in SQL/commands | Grep for template literals in `.query()`, `.execute()`, `exec()` |
| A04 | Insecure Design | Rate limiting on mutation endpoints; CSRF for cookie auth | Check `@fastify/rate-limit` registration; CSRF middleware |
| A05 | Security Misconfiguration | Helmet/CSP headers; CORS with explicit origins (not `*`) | Check `@fastify/helmet` and `@fastify/cors` config |
| A06 | Vulnerable Components | `npm audit` / `pnpm audit` passes; no critical CVEs | Run audit command after dependency changes |
| A07 | Auth Failures | JWT via `jose` (not base64 decode); secure session cookies | Check JWT verification uses algorithm whitelist |
| A08 | Software Integrity | Lockfile committed; no `--no-verify` flags | Check lockfile in git; grep for `--no-verify` |
| A09 | Logging Failures | Structured logging; no PII/secrets in logs | Check logger config for redaction serializers |
| A10 | SSRF | URL allowlisting for external fetches; private IP blocking | Check fetch/axios calls for URL validation |

**Additional security checks:**
- No `eval()`, `Function()`, or `vm.runInNewContext()` with user input
- No `dangerouslySetInnerHTML` without DOMPurify
- No `__proto__`, `constructor`, `prototype` in user-controlled object keys
- Error responses don't leak stack traces in production (`NODE_ENV=production`)

---

### 2. `skills/dev-app-develop/LEARN.md`

Research-seeded lessons (expanded with R69–R74):

**Better Questions** (from research):
- Ask about rollback strategy (git revert vs feature flags vs tag-based)
- Ask about test coverage expectations and CI enforcement
- Ask about code review requirements (approvals, CODEOWNERS)
- Ask about i18n/l10n requirements if user-facing strings involved
- Ask about feature flags for progressive delivery
- Ask about deployment target (staging first vs direct production)
- **(R70)** Ask about pagination preference (cursor vs offset) for new list endpoints
- **(R70)** Ask about idempotency requirements for POST/PUT endpoints
- **(R72)** Ask about auth pattern preference (JWT vs session cookies) if no existing pattern
- **(R74)** Ask about deployment platform (Vercel/Railway/Fly/AWS) if no config detected

**Edge Cases** (from research):
- Missing tech.md — must detect stack from config files (package.json, pyproject.toml, go.mod, etc.)
- Monorepo structure — task may affect only one package; scope changes accordingly
- Fullstack projects (frontend + backend) — determine which layer the task affects
- No test infrastructure — offer to set up minimal test framework first
- Protected branches — main/master may require PR; never commit directly
- Multiple package managers in fullstack projects — use correct one per layer
- No CI/CD config — warn that changes won't be automatically validated
- **(R69)** Internal packages with `"main": "./src/index.ts"` — don't try to build them separately, consuming app's bundler handles it
- **(R69)** Provider ordering matters in Next.js — Auth outermost, then Theme, then Data, then State
- **(R70)** Prisma `$queryRaw` with string interpolation vs tagged template — only tagged templates are parameterized
- **(R70)** Interactive transactions need explicit `maxWait` and `timeout` — defaults may be too short for complex operations
- **(R71)** Vitest workspaces separate unit/integration/bdd — don't mix DB-dependent tests with pure unit tests
- **(R72)** `@fastify/cors` with `origin: true` or `origin: '*'` — never use in production, always explicit allowlist
- **(R72)** `jsonwebtoken` has known CVEs (algorithm confusion) — prefer `jose` for new code
- **(R74)** Docker COPY order matters for layer caching — copy lockfile first, install, then copy source

**Workflow** (from research):
- Always run existing tests BEFORE changes to establish baseline (shift-left)
- Explore codebase BEFORE planning — prevents style conflicts
- Commit incrementally for large tasks (one logical change per commit)
- Check CI/CD config early — run same checks locally first
- Read CONTRIBUTING.md if it exists
- Use conventional commit format for automated changelog generation
- **(R70)** Follow existing service layer architecture — don't put business logic in route handlers
- **(R70)** Move side effects (notifications, events) outside database transactions
- **(R71)** Write tests at the right tier — don't E2E-test what a unit test can cover
- **(R72)** Register security plugins early — helmet first, then CORS, then rate limit, then session, then CSRF
- **(R73)** When fixing security findings, verify the fix with re-scan — don't just trust the code change
- **(R74)** Update `.env.example` when adding new environment variables

**Common Mistakes** (from research):
- Implementing without reading existing code patterns → inconsistent style
- Skipping test baseline → inheriting pre-existing failures
- Assuming test/lint framework without checking config files
- Hardcoding environment-specific values instead of using env vars
- Writing tests that depend on execution order
- Committing generated files (node_modules, __pycache__, build/)
- Using `git push --force` on shared branches
- Forgetting to update imports when moving/renaming files
- Measuring productivity by lines of code (SPACE framework warns against this)
- **(R70)** Using `select` with `include` in the same Prisma query — they're mutually exclusive
- **(R70)** Forgetting to handle Prisma error codes (P2002 = unique violation, P2025 = not found)
- **(R69)** Adding dependencies to root `package.json` in a monorepo when they belong to a specific package
- **(R71)** Mixing test tiers in the same test file — unit tests should not hit the database
- **(R72)** Decoding JWT with base64 instead of cryptographic verification — always use `jose.jwtVerify()`
- **(R72)** Storing JWT in localStorage — vulnerable to XSS; prefer httpOnly cookies
- **(R73)** Ignoring security scan findings because "it works" — fix or explicitly suppress with documented reason
- **(R74)** Using `COPY . .` before `RUN install` in Dockerfile — breaks layer caching for dependencies

**Architecture Patterns** (NEW section, from R69, R70):
- Monorepo: `apps/` for deployable apps, `packages/` for shared libraries, `tooling/` for configs
- Backend: Route handlers (HTTP only) → Service layer (business logic) → Repository/ORM (data access)
- Frontend: Server Components by default; `"use client"` providers in separate `providers.tsx`
- Config inheritance: Shared base tsconfig/eslint in `tooling/`, extended per-package
- Environment: `.env.defaults` (committed) < `.env.local` (gitignored) < `.env.{environment}` < process env

### 3. No `template.md`

This skill writes source code, not structured output documents.

---

## Files to Modify

### 4. `scripts/seeds/config.md` (~line 62)

Add after `frontend-scaffold`:
```markdown
| dev-app-develop | `/jaan-to:dev-app-develop` | Full-lifecycle app development from task to deployed code |
```

---

## Research Documents (completed)

### 5. Research Index

| # | Document | Sources | Status |
|---|----------|---------|--------|
| 68 | `jaan-to/outputs/research/68-dev-fullcycle-app-development-workflow.md` | 100+ | Done |
| 69 | `docs/research/69-dev-scaffold-project-assembly-automation.md` | 30 | Done |
| 70 | `docs/research/70-dev-backend-service-implementation-generation.md` | 25 | Done |
| 71 | `docs/research/71-qa-bdd-gherkin-test-code-generation.md` | 24 | Done |
| 72 | `docs/research/72-dev-secure-backend-scaffold-hardening.md` | 96 | Done |
| 73 | `docs/research/73-dev-sarif-security-remediation-automation.md` | 28 | Done |
| 74 | `docs/research/74-dev-cicd-infra-scaffold-generation.md` | 65 | Done |

README index updated: `jaan-to/outputs/research/README.md`

---

## Implementation Steps

1. ~~Write research document `68-dev-fullcycle-app-development-workflow.md` + update README index~~ **Done**
2. ~~Write research documents 69–74~~ **Done**
3. Create directory `skills/dev-app-develop/`
4. Write `skills/dev-app-develop/SKILL.md` — full skill with all phases, research-informed (use this plan as specification)
5. Write `skills/dev-app-develop/LEARN.md` — seeded with research lessons (use LEARN.md section above)
6. Edit `scripts/seeds/config.md` — add catalog entry
7. Create git branch `skill/dev-app-develop`
8. Commit all files
9. Invoke `/jaan-to:docs-create` for skill documentation (use `/jaan-to:docs-update` if docs already exist)
10. Run `/jaan-to:skill-update dev-app-develop` for v3.0.0 compliance
11. Use `/jaan-to:pm-roadmap-add` to add skill to roadmap (or `/jaan-to:pm-roadmap-update` to sync)
12. Use `/jaan-to:release-iterate-changelog` to update changelog
13. Create PR to `dev`

---

## Verification

### Structural
1. Read SKILL.md — verify no project-specific references remain
2. Frontmatter: name matches dir, description < 120 chars, no `: ` issues, no `model:` field
3. Required sections: Context Files, Input, Pre-Execution, HARD STOP, Definition of Done
4. All paths use `$JAAN_*` env vars
5. `/jaan-to:learn-add` used (not `/update-lessons-learned`)
6. No hardcoded credentials, IPs, or tokens

### Detection Tables
7. Tech detection tables cover Node, Python, Go, Rust, PHP ecosystems
8. Monorepo tool detection table present (Turborepo, Nx, pnpm workspaces, Lerna)
9. ORM/Database detection table present (Prisma, Drizzle, Knex, TypeORM)
10. Auth pattern detection table present (jose, jsonwebtoken, secure-session, NextAuth)
11. Security plugin detection table present (helmet, cors, rate-limit, csrf, secure-session)
12. Test framework detection table present (Vitest, Jest, Playwright, Cucumber)
13. Linter/formatter detection table present (ESLint, Biome, Prettier, TypeScript)

### Security
14. OWASP Top 10 checklist present with all 10 categories
15. Security scan integration in PHASE 3 (SARIF-aware)
16. CWE-to-remediation guidance for common TypeScript vulnerabilities
17. Secure defaults documented for new endpoints (auth required, rate limited)
18. No `eval()`, `innerHTML`, raw SQL, or `--force` patterns recommended

### Testing
19. Tiered test strategy documented (unit → integration → E2E)
20. Test data strategy documented (factories, mocks, seeding)
21. Coverage targets per tier documented
22. Tag-based test routing documented (@unit, @integration, @e2e)

### Patterns
23. Backend service layer architecture documented
24. Frontend provider wiring order documented
25. Conventional commits format documented
26. Environment variable management documented

### Compliance
27. Run `/jaan-to:skill-update dev-app-develop` for compliance check
