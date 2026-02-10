# Full-Lifecycle App Development Workflow

> Comprehensive research on modern software development lifecycle standards, CI/CD pipeline best practices, Git workflows, deployment strategies, metrics frameworks, and team collaboration patterns — informing the `dev-app-develop` skill design.
> Date: 2026-02-10
> Category: dev
> Research Size: Deep (100+ sources, 7 agents, 3 waves)

---

## Executive Summary

1. **Shift-left is the dominant paradigm** — testing, security scanning, observability, and quality gates all move earlier in the pipeline. Running existing tests *before* changes establishes baselines; SAST runs on every commit; performance testing integrates into CI/CD.
2. **Progressive delivery decouples deployment from release** — feature flags, canary releases, and ring-based rollouts reduce blast radius. AI-powered flag intelligence reduces failure rates by 68% and cuts MTTR by 85% (2026 trend).
3. **DORA + SPACE provide complementary measurement** — DORA's four metrics (deployment frequency, lead time, change failure rate, MTTR) measure delivery performance; SPACE's five dimensions (Satisfaction, Performance, Activity, Communication, Efficiency) capture developer experience holistically.
4. **Conventional commits enable full automation** — structured commit messages (`type(scope): subject`) drive semantic versioning, changelog generation, and release automation without manual intervention.
5. **Blameless postmortems transform incidents into organizational learning** — Google SRE culture assumes good intentions, investigates systemic causes, and produces actionable improvements with specific owners and target dates.

---

## Background

Modern software development has evolved from waterfall and basic agile toward continuous delivery pipelines with automated quality gates, progressive release strategies, and data-driven team health monitoring. The emergence of AI-assisted development (2024-2026) adds new dimensions: AI pair programming, automated code review, and intelligent deployment orchestration.

This research was conducted to inform the design of `dev-app-develop`, jaan-to's first "action skill" that writes source code to projects. The skill must be technology-agnostic, portable across ecosystems, and grounded in industry best practices.

Research spanned three waves across seven parallel agents, covering 15+ topic areas with 100+ unique sources consulted.

---

## 1. SDLC Fundamentals & 2025-2026 Evolution

### Core Lifecycle Phases
The modern SDLC follows: Planning → Analysis → Design → Implementation → Testing → Deployment → Maintenance. Key evolution in 2025-2026:

- **AI-assisted development** becomes standard: AWS AI-DLC (Development Lifecycle Companion) and pair-programmer models where AI handles boilerplate while humans focus on architecture and business logic
- **Shift-left principle** applies universally: security, testing, observability, and documentation all move earlier in the pipeline
- **Test pyramid** remains foundational: broad unit test base → integration tests → narrow E2E tests at the top

### Twelve-Factor App Principles
Factor X (Dev/Prod Parity) is critical for development workflows:
- **Time gap**: Deploy in hours/minutes, not weeks
- **Personnel gap**: Code authors involved in deployment and monitoring
- **Tools gap**: Identical service types and versions across all environments
- Modern implementation: Dev Containers (`.devcontainer.json`) + Docker ensure environmental parity

### Sources
- [Twelve-Factor App - Dev/Prod Parity](https://12factor.net/dev-prod-parity) — Foundational reference
- [Introduction to dev containers - GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers) — Official GitHub documentation

---

## 2. CI/CD Pipeline Best Practices

### Pipeline Architecture
- **Shift-left testing**: Run tests as early as possible; unit tests on every commit, integration tests on PR, E2E tests pre-deploy
- **Build-time quality gates**: Define measurable thresholds (latency, throughput, error rates) that block builds if exceeded
- **Parallel execution**: Independent test suites run concurrently to reduce pipeline duration
- **Caching**: Build artifacts and dependency caches reduce rebuild times significantly

### Test Framework Detection
A portable development skill must detect the project's test infrastructure:

| Ecosystem | Config Files | Test Runner | Command |
|-----------|-------------|-------------|---------|
| Node.js | `package.json`, `jest.config.*`, `vitest.config.*` | Jest, Vitest, Mocha | `npm test` / `npx jest` |
| Python | `pyproject.toml`, `setup.cfg`, `pytest.ini` | pytest, unittest | `pytest` / `python -m pytest` |
| Go | `go.mod`, `*_test.go` | go test | `go test ./...` |
| Rust | `Cargo.toml` | cargo test | `cargo test` |
| PHP | `composer.json`, `phpunit.xml` | PHPUnit, Pest | `vendor/bin/phpunit` |

### Package Manager Detection

| Ecosystem | Lock File | Tool | Install Command |
|-----------|----------|------|-----------------|
| Node.js | `package-lock.json` | npm | `npm install` |
| Node.js | `yarn.lock` | Yarn | `yarn install` |
| Node.js | `pnpm-lock.yaml` | pnpm | `pnpm install` |
| Python | `requirements.txt` | pip | `pip install -r requirements.txt` |
| Python | `poetry.lock` | Poetry | `poetry install` |
| Go | `go.sum` | go modules | `go mod download` |
| Rust | `Cargo.lock` | Cargo | `cargo build` |
| PHP | `composer.lock` | Composer | `composer install` |

### Linter/Formatter Detection

| Ecosystem | Config Files | Tool | Command |
|-----------|-------------|------|---------|
| Node.js | `.eslintrc.*`, `eslint.config.*` | ESLint | `npx eslint .` |
| Node.js | `.prettierrc.*` | Prettier | `npx prettier --check .` |
| Python | `pyproject.toml [tool.ruff]`, `ruff.toml` | Ruff | `ruff check .` |
| Python | `pyproject.toml [tool.black]` | Black | `black --check .` |
| Go | (built-in) | gofmt, golint | `go fmt ./...` |
| Rust | `rustfmt.toml` | rustfmt | `cargo fmt --check` |
| PHP | `phpcs.xml`, `.php-cs-fixer.php` | PHPCS, PHP-CS-Fixer | `vendor/bin/phpcs` |

### Sources
- [Shift Left Testing: Turn Quality Into a Growth Engine](https://abstracta.us/blog/devops/shift-left-testing/) — Strategic overview
- [How to Optimize Your CI/CD Pipeline with Performance Testing](https://frugaltesting.com/blog/how-to-optimize-your-cicd-pipeline-with-performance-testing) — Implementation guide
- [Gatling: Add load Testing to your CI/CD pipeline](https://gatling.io/blog/performance-testing-ci-cd) — Performance testing leader

---

## 3. Git Workflow Standards

### Branching Strategies

**Trunk-Based Development (recommended for CI/CD):**
- Short-lived feature branches (< 1 day ideal, < 3 days maximum)
- Merge to main/trunk frequently
- Feature flags control visibility of incomplete work
- Best for: High-velocity teams with strong CI/CD

**Feature Branch (GitHub Flow):**
- Feature branches from main
- PR-based review process
- Merge after review + CI pass
- Best for: Teams requiring code review gates

### Conventional Commits
Specification: `type(scope): subject`

| Type | Usage |
|------|-------|
| `feat` | New feature (triggers MINOR version bump) |
| `fix` | Bug fix (triggers PATCH version bump) |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code restructuring |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `build` | Build system changes |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |

`BREAKING CHANGE` in commit body triggers MAJOR version bump.

### Branch Protection
- Main/master branches should require PR reviews
- CI must pass before merge
- CODEOWNERS file auto-assigns reviewers based on changed files
- Never commit directly to protected branches

### Sources
- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — Official specification
- [Semantic Release Documentation](https://semantic-release.gitbook.io/) — Automation tool
- [Code Ownership | Martin Fowler](https://martinfowler.com/bliki/CodeOwnership.html) — Foundational patterns

---

## 4. AI-Assisted Development Patterns

### AI Pair Programmer Model
- AI handles: boilerplate generation, test scaffolding, documentation, refactoring suggestions
- Human handles: architecture decisions, business logic, security review, final approval
- Key principle: AI augments developer productivity; human remains decision-maker

### Codebase Exploration First
Research consistently shows: **explore existing code BEFORE planning changes**. This prevents:
- Style inconsistencies with existing codebase
- Duplicating functionality that already exists
- Breaking established patterns and conventions

### Baseline Test Run
Run existing tests BEFORE making any changes:
- Establishes known-good state
- Separates pre-existing failures from new regressions
- Provides confidence in test suite reliability

### Sources
- [Addy Osmani: AI-Assisted Coding Workflow](https://addyosmani.com/) — Google Chrome team lead
- [AWS AI-DLC: Development Lifecycle Companion](https://aws.amazon.com/blogs/devops/) — Enterprise AI-dev patterns

---

## 5. Feature Flags & Progressive Delivery

### Feature Flag Lifecycle
- **Temporary flags** (designed for removal): Branch by abstraction, A/B testing, database migrations
- **Long-lived flags** (permanent infrastructure): Entitlements/permissions, rebranding, circuit breakers/kill switches
- **Critical practice**: Flag cleanup at 30+ days; automated expiration date reminders prevent technical debt

### Progressive Rollout Strategy (2025-2026 Best Practice)
1. **Phase 1**: Internal teams + low-risk segments (monitor technical metrics)
2. **Phase 2**: Percentage-based (10-25% of users, monitor business metrics)
3. **Phase 3**: Full rollout (monitor stability across all rings)
4. **Advanced**: Automated progression — if metrics pass all gates for 24hrs, auto-expand to next ring

### 2026 Trend
AI-powered feature flag intelligence reduces failure rates by **68%** and cuts MTTR by **85%**.

### Key Tools
LaunchDarkly, Flagsmith, Unleash, Statsig, Split.io, Harness

### Sources
- [The 12 Commandments Of Feature Flags In 2025](https://octopus.com/devops/feature-flags/feature-flag-best-practices/) — Octopus Deploy
- [How feature management enables Progressive Delivery](https://launchdarkly.com/guides/progressive-delivery/how-feature-management-enables-progressive-delivery/) — LaunchDarkly
- [AI-Powered Progressive Delivery: Feature Flags 2026](https://azati.ai/blog/ai-powered-progressive-delivery-feature-flags-2026/) — 2026 trends

---

## 6. Incident Management & Blameless Postmortems

### Blameless Culture (Google SRE)
Core philosophy: "Everyone involved in an incident had good intentions and did the right thing with the information they had." Investigate systemic gaps, not individual failures.

### Postmortem Triggers
- User-visible downtime exceeding thresholds
- Any data loss
- Manual on-call interventions required
- Resolution times above acceptable limits
- Level 2+ severity incidents

### Postmortem Structure
1. High-level summary
2. Rough timeline (minutes to days)
3. Root cause analysis (ask "why" 5 times)
4. Action items with **specific owners and target dates**
5. Lessons learned documentation

### Action Item Quality
Each action must be phrased as verb-driven outcome:
- **Good**: "Enumerate the list of critical dependencies"
- **Bad**: "Investigate dependencies"

### Timeline
Conduct within **48 hours** of incident resolution for accuracy.

### Sources
- [Google SRE - Blameless Postmortem for System Resilience](https://sre.google/sre-book/postmortem-culture/) — Foundational philosophy
- [Best practices for writing incident postmortems](https://www.datadoghq.com/blog/incident-postmortem-process-best-practices/) — Datadog
- [Incident Review and Postmortem Best Practices](https://blog.pragmaticengineer.com/postmortem-best-practices/) — Pragmatic Engineer

---

## 7. DevSecOps & Security Scanning

### Pipeline Placement
- **SAST** (Static): Run on every commit/PR — white-box source code scanning pre-merge
- **DAST** (Dynamic): Post-build/deployment against staging — black-box runtime testing
- **SCA** (Software Composition Analysis): Dependency vulnerability scanning
- **IaC scanning**: Infrastructure as Code misconfigurations

### Shift-Left Security Practices
- "Scan-in-scope" optimization: Target only changed application sections for routine runs
- Full scans reserved for nightly/pre-production deployments
- Results surface in developer-familiar tools (PR comments, IDE integrations)
- Never in separate dashboards developers won't check

### 2025 Compliance Trends
- **70% reduction** in audit preparation time through automated compliance checks
- Supply chain security: SBOMs becoming mandatory (NIS2, CMMC regulations)
- Automated remediation: Systems autonomously patch, roll back, or isolate without delay
- Compliance-by-Default: Multiple frameworks (SOC 2, ISO 27001, PCI DSS, HIPAA) in single pipeline

### Security Checklist for Development
- [ ] No hardcoded credentials, tokens, or API keys
- [ ] Input validation at system boundaries
- [ ] Dependency scanning for known vulnerabilities
- [ ] Error messages don't leak internal details
- [ ] Environment-specific values via env vars, not code

### Sources
- [A Guide to Integrating Application Security Tools into CI/CD Pipelines](https://www.jit.io/resources/appsec-tools/integrating-application-security-tools-into-ci-cd-pipelines) — Jit
- [DAST in CI/CD Pipelines: Integration Strategies and Best Practices](https://snyk.io/articles/dast-ci-cd-pipelines/) — Snyk
- [Building end-to-end AWS DevSecOps CI/CD pipeline](https://aws.amazon.com/blogs/devops/building-end-to-end-aws-devsecops-ci-cd-pipeline-with-open-source-sca-sast-and-dast-tools/) — AWS DevOps Blog

---

## 8. DORA Metrics & Developer Productivity

### DORA's Four Key Metrics

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deployment Frequency | On-demand (multiple/day) | Weekly-monthly | Monthly-biannually | < 1/6 months |
| Lead Time for Changes | < 1 hour | 1 day-1 week | 1-6 months | > 6 months |
| Change Failure Rate | 0-15% | 16-30% | 16-30% | > 30% |
| Mean Time to Recovery | < 1 hour | < 1 day | 1 day-1 week | > 6 months |

Elite DORA performers are **2x more likely** to exceed organizational goals (profitability, productivity, customer satisfaction).

### SPACE Framework (Five Dimensions)

1. **Satisfaction & Well-being**: Fulfillment with work, team, tools, culture
2. **Performance**: How well software fulfills intended function and delivers value
3. **Activity**: Daily activity levels (coding, testing, debugging, collaboration)
4. **Communication & Collaboration**: Quality of information sharing and teamwork
5. **Efficiency & Flow**: Smoothness from ideation to deployment; waste reduction

### Anti-Patterns (What NOT to Measure)
- Lines of code (encourages bloat)
- Commit counts (incentivizes gaming)
- Story points delivered (encourages inflation)
- Individual deployment frequency (team metric, not individual)

### Sources
- [DORA Report 2025](https://dora.dev/research/2025/dora-report/) — Official DORA research
- [SPACE Metrics Framework](https://linearb.io/blog/space-framework) — LinearB 2025 edition
- [The SPACE of Developer Productivity - ACM Queue](https://queue.acm.org/detail.cfm?id=3454124) — Original research paper
- [Measuring developer productivity? A response to McKinsey](https://newsletter.pragmaticengineer.com/p/measuring-developer-productivity) — Pragmatic Engineer critical analysis

---

## 9. Deployment Strategies

### Strategy Comparison

| Strategy | Risk | Complexity | Rollback Speed | Best For |
|----------|------|-----------|----------------|----------|
| Blue-Green | Low | Medium | Instant (switch) | Stateless apps |
| Canary | Low | High | Fast (route change) | User-facing services |
| Rolling | Medium | Low | Slow (gradual) | Stateful services |
| Feature Flags | Very Low | Medium | Instant (flag toggle) | Any application |

### Canary Release Mechanics
- Route new version to small production subset via load balancer
- Ensure user consistency while testing stability
- Combined with feature flags provides superior rollback control

### Git-Based Rollback
For development workflows without infrastructure orchestration:
- `git revert <commit>` — creates new commit undoing changes
- Tag-based rollback — deploy specific tagged version
- Feature flag disable — instant without code changes

### Sources
- [Why progressive delivery is essential](https://www.harness.io/harness-devops-academy/progressive-delivery-explained) — Harness
- [Canary release vs progressive delivery](https://www.getunleash.io/blog/canary-release-vs-progressive-delivery) — Unleash

---

## 10. Code Review Standards & Automation

### Modern Best Practices (2025-2026)
- Keep PRs small and focused on single logical units
- Review turnaround within hours to keep teams unblocked
- Focus areas: Functionality, Software Design, Complexity, Test Coverage, Naming
- AI code review tools emerging as standard (Graphite, CodeRabbit, Qodo)

### Automation Tools
- SonarQube (27+ language support)
- CodeRabbit (40+ linters)
- Codacy, DeepSource, Snyk
- GitHub/Azure DevOps branch protection enforces quality gates

### Code Ownership Models

| Model | Definition | Tradeoff |
|-------|-----------|----------|
| Strong | Owner responsible; others ask permission | Safety + Control; lower velocity |
| Weak | Owner assigned; any developer can change; owner reviews | Balanced approach |
| Collective | Every developer responsible for all code | High velocity; requires trust |

### CODEOWNERS
- Pattern-based file/folder mapping to developers or teams
- Automates reviewer assignment based on changed files
- Research shows adoption reduces merge time and comment volume

### Sources
- [Code Review Best Practices for 2025](https://group107.com/blog/code-review-best-practices/) — Current analysis
- [Code Ownership: Using CODEOWNERS Strategically](https://www.aviator.co/blog/code-ownership-using-codeowners-strategically/) — Aviator
- [Code Ownership | Martin Fowler](https://martinfowler.com/bliki/CodeOwnership.html) — Foundational reference

---

## 11. Conventional Commits & Changelog Automation

### Commit Format
```
type(scope): subject

[optional body]

[optional footer(s)]
```

### Automation Pipeline
1. Developer writes conventional commits
2. CI parses commit messages
3. Semantic version determined automatically (feat → MINOR, fix → PATCH, BREAKING → MAJOR)
4. Changelog generated from commit history
5. Release published with notes

### Tools
- **semantic-release**: Full automation from commits to npm/GitHub release
- **standard-version**: Lightweight versioning + changelog
- **conventional-changelog**: Changelog-only generation
- **Keep a Changelog** format: Structured, human-friendly standard

### Sources
- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — Specification
- [Semantic Release Documentation](https://semantic-release.gitbook.io/) — Official tool docs
- [Automating Versioning and Releases | Agoda Engineering](https://medium.com/agoda-engineering/automating-versioning-and-releases-using-semantic-release-6ed355ede742) — Enterprise case study

---

## 12. Development Environment Standardization

### Dev Containers
- `.devcontainer.json` + `Dockerfile` committed to repository
- Eliminates "works on my machine" problems
- Best practice: Include team-shared tools (linters, formatters); exclude personal preferences
- CI/CD runs same container image for environmental parity

### Monorepo vs Polyrepo (2026 Analysis)

| Factor | Monorepo | Polyrepo |
|--------|----------|----------|
| Shared Code | Atomic changes, single source of truth | Coordination overhead |
| Build Tools | Bazel, Nx, Turborepo, Pants | Individual CI/CD per repo |
| AI Integration | **2026 Advantage**: Single agent instruction set | Multiple convention sets |
| Team Scale | Requires tooling investment | Scales with independent teams |

**2026 Insight**: AI tools favor monorepos — one canonical set of agent instructions at top level.

### Sources
- [Introduction to dev containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers) — GitHub Docs
- [Will AI turn 2026 into the year of the monorepo?](https://www.spectrocloud.com/blog/will-ai-turn-2026-into-the-year-of-the-monorepo/) — Spectro Cloud
- [Twelve-Factor App - Dev/Prod Parity](https://12factor.net/dev-prod-parity) — Foundational reference

---

## 13. Database Migration Strategies

### Tool Comparison

| Tool | Approach | Database Support | Best For |
|------|----------|-----------------|----------|
| Flyway | SQL files, numbered sequentially | 22+ SQL | Simple migrations, speed |
| Liquibase | Changelog (SQL/XML/JSON/YAML) | 50+ SQL + NoSQL | Complex migrations, conditional logic |
| Alembic | Python-first, SQLAlchemy | PostgreSQL, MySQL, SQLite | Python ecosystems |

### Backwards Compatibility
- Add columns before removing
- Migrate data out-of-band
- Blue/green deployments for zero-downtime migrations
- Checksum validation prevents tampering

### Sources
- [Flyway vs Liquibase in 2026](https://www.bytebase.com/blog/flyway-vs-liquibase/) — ByteBase comparative analysis
- [Choosing the Right Schema Migration Tool](https://www.pingcap.com/article/choosing-the-right-schema-migration-tool-a-comparative-guide/) — PingCAP

---

## 14. Technical Debt Management

### Kaplan-Moss Framework
1. **Measure consistently**: Pick one technique (issue tracker labels, DORA metrics, staff surveys) and follow it over time
2. **Establish time budget**: Allocate **10-20%** of engineering capacity to debt reduction
3. **Review regularly**: Monthly/quarterly stakeholder reviews of metrics vs. allocation

### Key Metrics
- Technical Debt Ratio (TDR) = Remediation effort / Total development effort
- Healthy benchmark: TDR < 5%
- McKinsey data: Tech debt = 20-40% of technology estates
- Leading teams achieve 50%+ faster delivery by managing debt

### Sources
- [Managing Technical Debt | Jacob Kaplan-Moss](https://jacobian.org/2023/dec/20/tech-debt/) — Former Django lead
- [5 Recommendations | CMU/SEI](https://www.sei.cmu.edu/blog/5-recommendations-to-help-your-organization-manage-technical-debt/) — Carnegie Mellon

---

## 15. Observability & Monitoring

### Key Distinction
- **Monitoring**: Reactive, predefined metrics/alerts
- **Observability**: Proactive, links logs + metrics + traces for comprehensive system view

### Best Practices
1. **Shift-left observability**: Build into SDLC during dev/testing, not post-deployment
2. **Intelligent alerting**: Dynamic baselines and anomaly detection vs static thresholds
3. **Selective metrics**: RED Method (Rate, Errors, Duration) for microservices; USE Method (Utilization, Saturation, Errors) for resources
4. **Unified platform**: Integrate across tools for correlated insights

### SLO/SLI/SLA Framework
- **SLI** (Indicator): Quantitative measure (e.g., API response time < 200ms)
- **SLO** (Objective): Internal target (e.g., 99.95% availability over 30 days)
- **SLA** (Agreement): External contract with penalties

### Impact
- 78% of enterprises report 30% faster incident resolution
- Up to 50% MTTR reduction potential
- Gartner: 60% of Fortune 500 will prioritize observability by 2027

### Sources
- [Observability Best Practices 2026](https://spacelift.io/blog/observability-best-practices) — Spacelift
- [SRE fundamentals: SLAs vs SLOs vs SLIs](https://cloud.google.com/blog/products/devops-sre/sre-fundamentals-slis-slas-and-slos) — Google Cloud
- [Observability vs. Monitoring](https://newrelic.com/blog/best-practices/observability-vs-monitoring) — New Relic

---

## 16. Team Collaboration & Async Communication

### Shopify Model
- Async communication is "the great leveler" — treats all team members equally
- Communication spectrum: video → chat → email → wikis/READMEs
- Teams define own communication norms: response times, working hours, decision-making
- Deliberate synchronous touchpoints maintained for human connection

### Architecture Decision Records (ADRs)
- Lightweight Markdown documents stored in source control
- Each captures one design decision with context, alternatives, and consequences
- Meeting structure: 30-45 minutes maximum per decision
- Post-decision review at 1 month to validate assumptions
- Status tracking: proposed → accepted → deprecated → superseded

### Definition of Done (Engineering)
- Code adheres to style conventions, passes linters
- Peer-reviewed with no outstanding discussions
- Documentation created/updated for expected behavior
- All automated tests pass; tests stored alongside code
- Legal/regulatory compliance verified
- Quarterly DoD review cycles to evolve with project maturity

### Sources
- [Asynchronous Communication | Shopify Engineering](https://shopify.engineering/asynchronous-communication-shopify-engineering) — Enterprise implementation
- [Architecture Decision Records | AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html) — Implementation guidance
- [Definition of Done | Atlassian](https://www.atlassian.com/agile/project-management/definition-of-done) — Enterprise standard
- [What is Definition of Done | Scrum.org](https://www.scrum.org/resources/what-definition-done) — Official Scrum framework

---

## 17. Versioning & Release Management

### Semantic Versioning (SemVer)
- Format: `MAJOR.MINOR.PATCH` (e.g., `1.4.2`)
- Best for: Libraries, packages, APIs with backward compatibility concerns
- Guarantees effective dependency management

### Calendar Versioning (CalVer)
- Format: `YYYY.MM.DD` or similar date-based scheme
- Best for: Applications, internal software, predictable release cadences
- Advantage: Aligns versioning with release cycles

### API Backwards Compatibility
- **Non-breaking**: Add new response attributes, add optional fields, create new endpoints
- **Breaking**: Remove fields, change paths, alter response formats
- **Deprecation pattern**: Maintain endpoint for fixed period; communicate sunset date; force migration with major version bump

### Sources
- [SemVer vs CalVer](https://sensiolabs.com/blog/2025/semantic-vs-calendar-versioning) — SensioLabs 2025 comparison
- [Calendar Versioning](https://calver.org/) — Official CalVer reference

---

## Open Questions

1. How should AI-generated code be attributed in commit history?
2. What is the optimal feature flag cleanup cadence for different team sizes?
3. How to balance automated rollback triggers with human oversight?
4. What metrics best predict deployment success before release?
5. How to measure the ROI of shift-left security investments?

---

## Research Metadata

- **Date**: 2026-02-10
- **Category**: dev
- **Research Size**: Deep (100+ sources)
- **Agents Used**: 7 (1 scout + 2 gap-fill + 3 expansion + 1 main)
- **Waves**: 3 (Scout → Gap Fill → Expansion)
- **Queries Used**: 30+ search queries across all agents

### Adaptive Research Flow
- W1 Scout: 8 searches — mapped SDLC, CI/CD, Git, AI-dev, DX, deployment landscape
- W2 Gaps: 2 agents — filled feature flags, incident management, ADRs, DevSecOps, performance testing
- W3 Expand: 3 agents — expanded dev env standardization, migrations, monorepo/polyrepo, DORA/SPACE, observability, SLO/SLI/SLA, code review, conventional commits, changelog, tech debt, code ownership, async communication

### Source Priority
- **Primary (official/authoritative)**: Google SRE Book, Twelve-Factor App, DORA Official, Conventional Commits Spec, ACM Queue, Scrum.org, AWS Docs
- **Supporting (quality engineering blogs)**: Pragmatic Engineer, Martin Fowler, Shopify Engineering, Atlassian, Harness, LaunchDarkly
- **Reference (tool vendors)**: LinearB, Spacelift, Snyk, Jit, SonarQube, ByteBase
