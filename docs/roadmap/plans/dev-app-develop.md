# Plan: Create `dev-app-develop` Skill

## Context

The user wants a new jaan-to skill that orchestrates full-lifecycle app development — from task selection through deployment. The original ~600-line spec was project-specific (jaan.coach). It must be **generified**: no project-specific references, no hardcoded credentials/IPs, technology-agnostic (reads stack from `tech.md`), and portable across any project.

This is the **first "action skill"** in jaan-to — it writes source code to the project itself (not to `jaan-to/outputs/`), runs tests, commits, and pushes.

**Research conducted**: 100+ sources across 7 agents covering SDLC, CI/CD, Git workflows, AI-assisted dev, deployment strategies, feature flags, incident management, security, metrics (DORA/SPACE), code review, and collaboration patterns.

---

## Files to Create

### 1. `skills/dev-app-develop/SKILL.md`

**Frontmatter:**
```yaml
---
name: dev-app-develop
description: Full-lifecycle app development from task selection through implementation, testing, and deployment.
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write, Edit, AskUserQuestion, Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(pip:*), Bash(python:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*), Bash(composer:*), Bash(php:*), Bash(make:*), Bash(docker:*), Bash(curl:*)
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
| `# PRE-FLIGHT CHECK` | Verify tech.md, git repo, detect project structure, check branch (warn if on main) | Twelve-Factor (dev/prod parity), Git workflow standards |
| `# PHASE 0: Task Selection` | Generic roadmap/task Glob, present task, create feature branch | Agile/workflow management (Atlassian), trunk-based dev patterns |
| `# PHASE 1: Analysis` | ultrathink, explore codebase, detect stack from tech.md + config fallback, design plan with files/deps/tests/risks, cross-ref existing patterns | AWS AI-DLC, Addy Osmani's AI coding workflow, shift-left principle |
| `# HARD STOP` | Present plan, require approval | — |
| `# PHASE 2: Implementation` | TodoWrite tracking, install deps (multi-pkg-mgr table), implement changes, i18n detection, write tests (multi-framework table), quality checks (multi-linter table) | SDLC best practices, test pyramid, conventional commits |
| `# PHASE 3: Test & Fix Loop` | Run tests (unit→integration→E2E), fix failures (max 3 iter), re-run quality, results summary | Shift-left testing, DORA metrics (change failure rate) |
| `# PHASE 4: Commit & Deploy` | Conventional commits, push, optional PR via `gh`, CI/CD monitoring, git-based rollback only | Progressive delivery, trunk-based dev, blue-green/canary concepts |
| `# PHASE 5: Documentation & Closure` | Changelog via `/jaan-to:release-iterate-changelog`, roadmap via `/jaan-to:roadmap-update`, `/jaan-to:learn-add`, summary with DORA-aligned metrics | Conventional commits → semantic release, blameless postmortem culture |
| `## Security Checklist` | No hardcoded creds, input validation, dependency scanning, error handling | DevSecOps shift-left, SAST/DAST pipeline placement |
| `## Safety Rules` | Never skip tests, verify CI/CD, human confirmation, rollback-first | Google SRE postmortem culture, incident management best practices |
| `## Definition of Done` | Research-backed checklist | Engineering DoD standards (Atlassian, Scrum.org) |

**Key research-informed additions (vs. original spec):**
- **Tech detection tables**: Package managers, test frameworks, linters/formatters — each with indicator files → tool → command mappings (Node/Python/Go/Rust/PHP)
- **Conventional commits**: `type(scope): subject` format with automatic detection of project's existing convention
- **DORA-aligned summary**: Cycle time, test count, files changed (not lines of code)
- **Progressive delivery awareness**: Check for feature flag configs, suggest canary/staged rollout if detected
- **Observability check**: Verify monitoring/alerting exists if deploying to production (shift-left observability)
- **ADR suggestion**: For architectural decisions, suggest creating ADR in `docs/decisions/`
- **Code ownership**: Check CODEOWNERS file, tag appropriate reviewers on PR
- **Baseline test run**: Run existing tests BEFORE making changes to establish baseline

### 2. `skills/dev-app-develop/LEARN.md`

Research-seeded lessons:

**Better Questions** (from research):
- Ask about rollback strategy (git revert vs feature flags vs tag-based)
- Ask about test coverage expectations and CI enforcement
- Ask about code review requirements (approvals, CODEOWNERS)
- Ask about i18n/l10n requirements if user-facing strings involved
- Ask about feature flags for progressive delivery
- Ask about deployment target (staging first vs direct production)

**Edge Cases** (from research):
- Missing tech.md — must detect stack from config files (package.json, pyproject.toml, go.mod, etc.)
- Monorepo structure — task may affect only one package; scope changes accordingly
- Fullstack projects (frontend + backend) — determine which layer the task affects
- No test infrastructure — offer to set up minimal test framework first
- Protected branches — main/master may require PR; never commit directly
- Multiple package managers in fullstack projects — use correct one per layer
- No CI/CD config — warn that changes won't be automatically validated

**Workflow** (from research):
- Always run existing tests BEFORE changes to establish baseline (shift-left)
- Explore codebase BEFORE planning — prevents style conflicts
- Commit incrementally for large tasks (one logical change per commit)
- Check CI/CD config early — run same checks locally first
- Read CONTRIBUTING.md if it exists
- Use conventional commit format for automated changelog generation

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

## Also Create: Research Document

### 5. `jaan-to/outputs/research/68-dev-fullcycle-app-development-workflow.md`

Research document with all findings from 100+ sources across:
- SDLC fundamentals & 2025/2026 evolution
- CI/CD pipeline best practices (shift-left, progressive delivery)
- Git workflow standards (trunk-based dev vs feature branching)
- AI-assisted development patterns (AWS AI-DLC, pair programmer model)
- Feature flags & progressive delivery lifecycle
- Incident management & blameless postmortems (Google SRE)
- DevSecOps & security scanning (SAST/DAST pipeline placement)
- Developer experience & DORA/SPACE metrics
- Deployment strategies (blue-green, canary, rolling)
- Code review standards & automation tools
- Conventional commits & changelog automation
- Dev environment standardization (dev containers, twelve-factor parity)
- Database migration strategies (Flyway, Liquibase, Alembic)
- Technical debt management (Kaplan-Moss framework)
- Code ownership models (CODEOWNERS patterns)

Update `jaan-to/outputs/research/README.md` index.

---

## Implementation Steps

1. Write research document `68-dev-fullcycle-app-development-workflow.md` + update README index
2. Create directory `skills/dev-app-develop/`
3. Write `skills/dev-app-develop/SKILL.md` — full skill with all phases, research-informed
4. Write `skills/dev-app-develop/LEARN.md` — seeded with research lessons
5. Edit `scripts/seeds/config.md` — add catalog entry
6. Create git branch `skill/dev-app-develop`
7. Commit all files
8. Invoke `/jaan-to:docs-create` for skill documentation (use `/jaan-to:docs-update` if docs already exist)
9. Run `/jaan-to:skill-update dev-app-develop` for v3.0.0 compliance
10. Use `/jaan-to:roadmap-add` to add skill to roadmap (or `/jaan-to:roadmap-update` to sync)
11. Use `/jaan-to:release-iterate-changelog` to update changelog
12. Create PR to `dev`

---

## Verification

1. Read SKILL.md — verify no project-specific references remain
2. Frontmatter: name matches dir, description < 120 chars, no `: ` issues, no `model:` field
3. Required sections: Context Files, Input, Pre-Execution, HARD STOP, Definition of Done
4. All paths use `$JAAN_*` env vars
5. `/jaan-to:learn-add` used (not `/update-lessons-learned`)
6. No hardcoded credentials, IPs, or tokens
7. Tech detection tables cover Node, Python, Go, Rust, PHP ecosystems
8. Conventional commits format documented
9. Run `/jaan-to:skill-update dev-app-develop` for compliance check
