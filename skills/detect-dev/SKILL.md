---
name: detect-dev
description: Engineering audit with SARIF evidence, 4-level confidence, and OpenSSF scoring.
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git remote:*), Bash(git show:*), Write($JAAN_OUTPUTS_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# detect-dev

> Repo engineering audit with machine-parseable findings and OpenSSF-style scoring.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-dev.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (if populated by dev-stack-detect, used as starting input)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-dev.template.md` - Output template

**Output path**: `$JAAN_OUTPUTS_DIR/detect/dev/` — flat files, overwritten each run (no IDs).

## Input

**Repository**: $ARGUMENTS

If a repository path is provided, scan that repo. Otherwise, scan the current working directory.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:detect-dev.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add detection patterns from "Better Questions"
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_detect-dev` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names, evidence blocks.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

## Standards Reference

### Evidence Format (SARIF-compatible)

Every finding MUST include structured evidence blocks:

```yaml
evidence:
  id: E-DEV-001
  type: code-location          # code-location | config-pattern | dependency | metric | absence
  confidence: 0.95             # 0.0-1.0
  location:
    uri: "src/auth/login.py"
    startLine: 42
    endLine: 58
    snippet: |
      query = "SELECT * FROM users WHERE id=" + user_id
  method: manifest-analysis    # manifest-analysis | static-analysis | manual-review | pattern-match | heuristic
```

Evidence IDs use namespace `E-DEV-NNN` to prevent collisions in pack-detect aggregation.

### Confidence Levels (4-level)

| Level | Label | Range | Criteria |
|-------|-------|-------|----------|
| 4 | **Confirmed** | 0.95-1.00 | Multiple independent methods agree; reproducible |
| 3 | **Firm** | 0.80-0.94 | Single high-precision method with clear evidence |
| 2 | **Tentative** | 0.50-0.79 | Pattern match without full analysis; needs investigation |
| 1 | **Uncertain** | 0.20-0.49 | Absence-of-evidence reasoning; expert judgment only |

**Downgrade one level** if: evidence from outdated code, finding in dead code, tool has high false-positive rate.
**Upgrade one level** if: multiple tools agree, maintainer confirmed, systematic pattern detected.

### Frontmatter Schema (Universal)

Every output file MUST include this YAML frontmatter:

```yaml
---
title: "{document title}"
id: "{AUDIT-YYYY-NNN}"
version: "1.0.0"
status: draft
date: {YYYY-MM-DD}
target:
  name: "{repo-name}"
  commit: "{git HEAD hash}"
  branch: "{current branch}"
tool:
  name: "detect-dev"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 0
overall_score: 0.0             # 0-10, OpenSSF-style
lifecycle_phase: post-build    # CycloneDX vocabulary
---
```

### Document Structure (Diataxis)

Each output file follows:
1. **Executive Summary** - BLUF: what was found and why it matters
2. **Scope and Methodology** - What was analyzed, tools used, exclusions
3. **Findings** - Each as H3 with ID/severity/confidence/description/evidence/impact/remediation
4. **Recommendations** - Prioritized remediation roadmap
5. **Appendices** - Methodology details, confidence scale reference

### Prohibited Anti-patterns

- Never present speculation as evidence. Use hedging for confidence < Firm.
- Never omit confidence levels. Every finding MUST include confidence.
- Never inflate severity. Reserve Critical for verified, exploitable, high-impact.
- Never make scope-exceeding claims. Distinguish "findings" from "observations".

---

# PHASE 1: Detection (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing detected dependencies and mapping to stack sections
- Resolving version conflicts or migration detection
- Confidence scoring decisions
- Architecture pattern recognition

## Step 1: Read Existing Context

If `$JAAN_CONTEXT_DIR/tech.md` exists and is populated (not just placeholders), read it as starting input. This provides a baseline for deeper evidence-backed analysis.

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
  - `postgres` -> PostgreSQL (extract version from tag)
  - `mysql` / `mariadb` -> MySQL/MariaDB
  - `mongo` -> MongoDB
  - `redis` -> Redis
  - `rabbitmq` -> RabbitMQ
  - `elasticsearch` / `opensearch` -> Elasticsearch/OpenSearch
  - `memcached` -> Memcached
  - `minio` -> MinIO (S3-compatible storage)
  - `localstack` -> AWS services (local development)

- Glob: `**/Dockerfile`, `**/Dockerfile.*`
- Extract: base image, runtime version

## Step 4: Scan CI/CD & Testing (Layer 3 — 90-95% confidence)

### CI/CD Pipelines
- Glob: `.github/workflows/*.yml` -> GitHub Actions
- Glob: `.gitlab-ci.yml` -> GitLab CI
- Glob: `.circleci/config.yml` -> CircleCI
- Glob: `Jenkinsfile` -> Jenkins
- Glob: `.travis.yml` -> Travis CI
- Glob: `bitbucket-pipelines.yml` -> Bitbucket Pipelines
- Glob: `azure-pipelines.yml` -> Azure DevOps

### CI/CD Security Checks (explicit)

For each CI/CD pipeline found, check:

**Secrets boundaries**:
- Grep for `secrets.` in workflow files — detect env vars referencing secrets
- Check for env vars without vault/secret manager references
- Flag hardcoded credentials or tokens

**Runner trust**:
- Check for `runs-on: self-hosted` — flag with security note
- Audit IP allowlists and network-level trust

**Permissions**:
- Scan `permissions:` blocks in job specs
- Flag `permissions: write-all` or overly broad permissions
- Check for least-privilege principle

**Action pinning**:
- Check action versions: SHA pins (secure) vs `@main`/`@latest` (risky)
- Flag unpinned third-party actions

**Provenance / Supply chain**:
- Detect SLSA attestation files
- Check for `.cyclonedx.json`, `*.sbom.json`, SBOM presence
- Look for sigstore/cosign signing artifacts

### Testing (if not already detected from deps)
- Glob: `jest.config.*`, `vitest.config.*` -> JS test runners
- Glob: `pytest.ini`, `conftest.py`, `pyproject.toml` (check `[tool.pytest]`) -> Python testing
- Glob: `playwright.config.*` -> Playwright E2E
- Glob: `cypress.json`, `cypress.config.*`, `cypress/` -> Cypress E2E
- Glob: `.storybook/` -> Storybook component testing

### Linting & Formatting
- Glob: `.eslintrc.*`, `eslint.config.*` -> ESLint
- Glob: `.prettierrc.*`, `prettier.config.*` -> Prettier
- Glob: `biome.json`, `biome.jsonc` -> Biome
- Glob: `ruff.toml`, `pyproject.toml` (check `[tool.ruff]`) -> Ruff
- Glob: `.flake8`, `setup.cfg` (check `[flake8]`) -> Flake8
- Glob: `mypy.ini`, `pyproject.toml` (check `[tool.mypy]`) -> mypy
- Glob: `.editorconfig` -> EditorConfig

## Step 5: Scan Git & Integrations (Layer 4 — 95% confidence)

### Source Control
- Run: `git remote -v` -> Extract platform (github.com, gitlab.com, bitbucket.org) and org/repo
- Glob: `.github/CODEOWNERS` -> Code ownership
- Glob: `.github/PULL_REQUEST_TEMPLATE*` -> PR templates
- Glob: `.gitlab/merge_request_templates/` -> MR templates

### Dependency Management
- Glob: `renovate.json`, `renovate.json5`, `.renovaterc` -> Renovate
- Glob: `.github/dependabot.yml` -> Dependabot

### Monorepo Detection
- Glob: `pnpm-workspace.yaml` -> pnpm workspaces
- Glob: `lerna.json` -> Lerna
- Glob: `nx.json` -> Nx
- Glob: `turbo.json` -> Turborepo
- Multiple `package.json` files at different depths -> generic monorepo

## Step 6: Scan Infrastructure (Layer 5 — 60-80% confidence)

### Cloud & Deployment
- Glob: `**/terraform/**/*.tf`, `**/*.tf` -> Terraform (check provider blocks for AWS/GCP/Azure)
- Glob: `serverless.yml`, `serverless.ts` -> Serverless Framework
- Glob: `vercel.json`, `.vercel/` -> Vercel
- Glob: `netlify.toml` -> Netlify
- Glob: `fly.toml` -> Fly.io
- Glob: `render.yaml` -> Render
- Glob: `Procfile` -> Heroku
- Glob: `app.yaml`, `app.yml` -> Google App Engine
- Glob: `amplify.yml` -> AWS Amplify

### Container Orchestration
- Glob: `k8s/**`, `kubernetes/**`, `kustomization.yaml` -> Kubernetes
- Glob: `helm/**`, `Chart.yaml` -> Helm charts

### Monitoring & Observability (low confidence)
- Grep in config files for: `datadog`, `sentry`, `newrelic`, `grafana`, `prometheus`
- Grep in package deps for: `@sentry/`, `dd-trace`, `newrelic`, `prom-client`

## Step 7: Scan Project Structure (Layer 5 — 60-80% confidence)

Use **Glob** to map the directory structure:

- Identify source directories: `src/`, `lib/`, `app/`, `packages/`, `services/`
- Identify config directories: `config/`, `settings/`
- Identify build outputs: `dist/`, `build/`, `.next/`, `__pycache__/`
- Identify documentation: `docs/`, `wiki/`
- Identify test directories: `tests/`, `test/`, `__tests__/`, `spec/`

## Step 8: Score & Categorize

For each detection, assign a confidence score using the 4-level system:

| Confidence | Source | Example |
|-----------|--------|---------|
| Confirmed (0.95-1.00) | Manifest file with explicit dependency | `"react": "^18.2.0"` in package.json |
| Firm (0.80-0.94) | Docker image with version tag | `postgres:15` in docker-compose |
| Firm (0.80-0.94) | CI workflow file | `.github/workflows/` exists |
| Tentative (0.50-0.79) | Directory structure inference | `k8s/` directory exists |
| Uncertain (0.20-0.49) | Grep mention in arbitrary files | "datadog" mentioned in a README |

**Only include detections with confidence >= Uncertain (0.20) in findings.**

Calculate overall_score (OpenSSF-style 0-10):
`overall_score = 10 - (critical * 2.0 + high * 1.0 + medium * 0.4 + low * 0.1) / max(total_findings, 1)`
Clamp result to 0-10 range.

---

# HARD STOP — Detection Summary & User Approval

## Step 9: Present Detection Summary

Output a structured summary of all findings organized by output file:

```
DETECTION COMPLETE
------------------

STACK FINDINGS
  Backend:        {lang} {ver} + {framework} {ver}    [Confidence: {level}]
  Frontend:       {lang} {ver} + {framework} {ver}    [Confidence: {level}]
  Database:       {database} {ver}                      [Confidence: {level}]
  Infrastructure: {container} + {ci/cd}                 [Confidence: {level}]

SEVERITY SUMMARY
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10 (OpenSSF-style)

OUTPUT FILES (9):
  $JAAN_OUTPUTS_DIR/detect/dev/stack.md           - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/architecture.md    - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/standards.md       - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/testing.md         - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/cicd.md            - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/deployment.md      - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/security.md        - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/observability.md   - {n} findings
  $JAAN_OUTPUTS_DIR/detect/dev/risks.md           - {n} findings
```

> "Proceed with writing 9 output files to $JAAN_OUTPUTS_DIR/detect/dev/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 10: Write to $JAAN_OUTPUTS_DIR/detect/dev/

Create directory `$JAAN_OUTPUTS_DIR/detect/dev/` if it does not exist.

For each of the 9 output files, use the template from `$JAAN_TEMPLATES_DIR/jaan-to:detect-dev.template.md` and fill with findings:

### Output Files

| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/dev/stack.md` | Tech stack with version evidence |
| `$JAAN_OUTPUTS_DIR/detect/dev/architecture.md` | Architecture patterns and data flow |
| `$JAAN_OUTPUTS_DIR/detect/dev/standards.md` | Coding standards and conventions |
| `$JAAN_OUTPUTS_DIR/detect/dev/testing.md` | Test coverage and strategy |
| `$JAAN_OUTPUTS_DIR/detect/dev/cicd.md` | CI/CD pipelines and security |
| `$JAAN_OUTPUTS_DIR/detect/dev/deployment.md` | Deployment patterns |
| `$JAAN_OUTPUTS_DIR/detect/dev/security.md` | Security posture and findings (OWASP mapping) |
| `$JAAN_OUTPUTS_DIR/detect/dev/observability.md` | Logging, metrics, tracing |
| `$JAAN_OUTPUTS_DIR/detect/dev/risks.md` | Technical risks and debt |

Each file MUST include:
1. Universal YAML frontmatter with findings_summary and overall_score
2. Executive Summary
3. Scope and Methodology
4. Findings with evidence blocks (using E-DEV-NNN IDs)
5. Recommendations
6. Appendices (if applicable)

## Step 11: Quality Check

Before finalizing, verify:
- [ ] All 9 files have valid YAML frontmatter
- [ ] Every finding has an evidence block with E-DEV-NNN ID
- [ ] Confidence levels assigned to all findings
- [ ] No speculation presented as evidence
- [ ] No scope-exceeding claims
- [ ] CI/CD security checks explicitly covered
- [ ] Overall score calculated correctly

---

## Step 12: Capture Feedback

> "Any feedback on the engineering audit? Anything missed or incorrect? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-dev "{feedback}"`

---

## Definition of Done

- [ ] All 9 output files written to `$JAAN_OUTPUTS_DIR/detect/dev/`
- [ ] Universal YAML frontmatter in every file
- [ ] Every finding has evidence block with E-DEV-NNN ID
- [ ] Confidence scores assigned to all findings
- [ ] CI/CD security explicitly checked (secrets, runner trust, permissions, pinning, provenance)
- [ ] Overall score calculated (OpenSSF 0-10)
- [ ] Detection summary shown to user before writing
- [ ] User approved output
- [ ] Summary shown with any manual review suggestions
