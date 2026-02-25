---
title: "Skill Dependencies"
sidebar_position: 2
---

# Skill Dependencies

Visual map of skill relationships and suggested workflows.

---

## Dependency Graph

### Primary Workflows

```
Product Development Flow:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:pm-prd-write                                  │
│  "Generate PRD from initiative"                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:pm-story-write (Optional)
                 │    "Generate user stories from PRD"
                 │
                 ├──> /jaan-to:detect-dev
                 │    "Engineering audit of codebase"
                 │
                 ├──> /jaan-to:ux-flowchart-generate
                 │    "Generate Mermaid flowcharts from PRD"
                 │
                 ├──> /jaan-to:frontend-task-breakdown
                 │    "Frontend task breakdown from PRD"
                 │     │
                 │     └──> /jaan-to:frontend-state-machine (Future)
                 │          "State machine definitions"
                 │
                 ├──> /jaan-to:frontend-design
                 │    "Create production-grade frontend interfaces"
                 │
                 ├──> /jaan-to:backend-task-breakdown
                 │    "Backend task breakdown from PRD"
                 │     │
                 │     ├──> /jaan-to:backend-data-model
                 │     │    "Data model specification"
                 │     │
                 │     └──> /jaan-to:backend-api-contract
                 │          "OpenAPI 3.1 contract from entities"
                 │
                 ├──> /jaan-to:qa-test-cases
                 │    "Generate BDD test cases from PRD"
                 │
                 └──> /jaan-to:data-gtm-datalayer
                      "GTM tracking code from PRD"
```

### Research Flow

```
Research & Learning:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:pm-research-about                             │
│  "Deep research on any topic"                           │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /jaan-to:learn-add (Suggested)
                      "Capture research insights as lessons"
```

### Documentation Flow

```
Documentation Management:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:docs-create                                   │
│  "Create new documentation"                             │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /jaan-to:docs-update (Suggested)
                      "Audit and update stale docs"
```

### UX Research Flow

```
UX Research & Design:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:ux-research-synthesize                        │
│  "Synthesize UX research findings"                      │
└─────────────────────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:ux-microcopy-write
                 │    "Multi-language UI copy from insights"
                 │
                 ├──> /jaan-to:ux-heatmap-analyze
                 │    "Analyze interaction patterns from heatmaps"
                 │
                 └──> /jaan-to:ux-flowchart-generate
                      "Generate Mermaid flowcharts from findings"
```

### Detection / Audit Flow

```
Detection & Audit:
┌─────────────────────────────────────────────────────────┐
│  Run any combination of detect skills:                  │
│                                                         │
│  /jaan-to:detect-dev        "Engineering audit"         │
│  /jaan-to:detect-design     "Design system detection"   │
│  /jaan-to:detect-ux         "UX audit"                  │
│  /jaan-to:detect-product    "Product reality extraction" │
│  /jaan-to:detect-writing    "Writing system extraction"  │
└────────────────┬────────────────────────────────────────┘
                 │
                 └──> /jaan-to:detect-pack
                      "Consolidate into unified index with risk heatmap"
```

### Code Review Flow

```
Code Review:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:backend-pr-review                             │
│  "Review backend PRs for security and quality"          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  /jaan-to:wp-pr-review                                  │
│  "Review WordPress plugin PRs"                          │
└─────────────────────────────────────────────────────────┘
```

### Issue Reporting & Validation Flow

```
Issue Reporting:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:qa-issue-report                               │
│  "Report issues to any GitHub/GitLab repo"              │
└─────────────────────────────────────────────────────────┘

Issue Validation:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:qa-issue-validate                             │
│  "Validate issues against codebase with RCA"            │
└────────────────┬────────────────────────────────────────┘
                 │
                 └──> /jaan-to:pm-roadmap-add (if VALID + user approves)
                      "Add validated issue to roadmap"

> Cross-pipeline: For VALID_BUG verdicts, the reproduction scenario can feed
> /qa-test-cases → /qa-test-generate for regression tests. For VALID_FEATURE
> verdicts, the RCA summary provides acceptance criteria for the same pipeline.

Internal:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:jaan-issue-report                             │
│  "Report jaan-to plugin issues"                         │
└─────────────────────────────────────────────────────────┘
```

### Spec-to-Ship Flow

```
Code Generation & Deployment:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:backend-scaffold + /jaan-to:frontend-scaffold │
│  "Generate code stubs from specs"                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:backend-service-implement
                 │    "Fill service stubs with business logic"
                 │
                 ├──> /jaan-to:dev-project-assemble
                 │    "Wire scaffolds into runnable project"
                 │
                 ├──> /jaan-to:qa-test-generate
                 │    "Generate runnable tests from BDD cases"
                 │     │
                 │     └──> /jaan-to:qa-test-run
                 │          "Execute tests, diagnose failures, report coverage"
                 │
                 ├──> /jaan-to:detect-dev
                 │    "Security audit of generated code"
                 │     │
                 │     └──> /jaan-to:sec-audit-remediate
                 │          "Fix security findings with patches"
                 │
                 ├──> /jaan-to:backend-pr-review
                 │    "Review backend PRs for security and quality"
                 │
                 ├──> /jaan-to:devops-infra-scaffold
                 │    "Generate CI/CD, Docker, deployment configs"
                 │
                 ├──> /jaan-to:dev-output-integrate
                 │    "Copy outputs into project locations"
                 │     │
                 │     └──> (suggested) /jaan-to:detect-dev --incremental
                 │          "Re-audit integrated files for security and quality"
                 │
                 ├──> /jaan-to:dev-verify
                 │    "Validate build pipeline and running services"
                 │
                 └──> /jaan-to:devops-deploy-activate
                      "Activate deployment pipeline"
```

### Library Context Flow

```
Library Documentation:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:dev-docs-fetch                                │
│  "Fetch library docs via Context7 MCP"                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:backend-scaffold
                 │    "Generated code uses current API patterns"
                 │
                 ├──> /jaan-to:frontend-scaffold
                 │    "Generated components use current framework patterns"
                 │
                 └──> /jaan-to:dev-project-assemble
                      "Project config follows current best practices"
```

### Release Flow

```
Release Management:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:release-iterate-changelog                     │
│  "Generate changelog from git history"                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:pm-changelog-rewrite (Auto-invoked)
                 │    "Transform into user-facing product changelog"
                 │
                 └──> /jaan-to:qa-issue-report (Suggested)
                      "Post supportive comment on closed issues"
```

### Skill Development Flow

```
Plugin Development:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:skill-create                                  │
│  "Create new skill with wizard"                         │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /jaan-to:skill-update
                      "Update existing skill"
```

---

## Cross-Cutting Skills

These skills are suggested by multiple other skills:

### Learning & Feedback
- **Used by:** ALL skills (after execution)
- **Command:** `/jaan-to:learn-add`
- **Purpose:** Capture lessons learned for continuous improvement
- **Trigger:** User provides feedback about skill execution

### Roadmap Management
- **Used by:** Skills that create new features
- **Command:** `/jaan-to:pm-roadmap-add`
- **Purpose:** Track feature requests and improvements
- **Trigger:** User identifies missing functionality

---

## Skill Chains (Common Workflows)

### 1. Feature Development (Complete Flow)

```bash
# Step 1: Research & PRD
/jaan-to:pm-research-about "authentication best practices"
/jaan-to:pm-prd-write "OAuth2 authentication"

# Step 2: User Stories & Flowcharts
/jaan-to:pm-story-write from prd
/jaan-to:ux-flowchart-generate from prd

# Step 3: Tech Planning
/jaan-to:detect-dev
/jaan-to:frontend-task-breakdown from prd
/jaan-to:backend-task-breakdown from prd
/jaan-to:backend-data-model from task breakdown
/jaan-to:backend-api-contract from entities

# Step 4: QA & Tracking
/jaan-to:qa-test-cases from prd
/jaan-to:data-gtm-datalayer "auth flow tracking"
```

### 2. UX Enhancement Flow

```bash
# Step 1: Analyze Current State
/jaan-to:ux-heatmap-analyze "homepage-heatmap.csv"

# Step 2: Synthesize Research
/jaan-to:ux-research-synthesize "UX research notes"

# Step 3: Generate Microcopy
/jaan-to:ux-microcopy-write based on insights
```

### 3. Documentation Maintenance

```bash
# Step 1: Audit Staleness
/jaan-to:docs-update --check-only

# Step 2: Fix Stale Docs
/jaan-to:docs-update --fix

# Step 3: Create New Docs as Needed
/jaan-to:docs-create guide "API integration"
```

### 4. Detection & Audit

```bash
# Step 1: Run detect skills
/jaan-to:detect-dev
/jaan-to:detect-design
/jaan-to:detect-ux
/jaan-to:detect-product
/jaan-to:detect-writing

# Step 2: Consolidate findings
/jaan-to:detect-pack
```

### 5. Code Review

```bash
# Backend PRs (any stack)
/jaan-to:backend-pr-review

# WordPress plugin PRs
/jaan-to:wp-pr-review
```

---

## Standalone Skills

These skills don't typically call others:

| Skill | Purpose | Usage Pattern |
|-------|---------|---------------|
| `/jaan-to:pm-story-write` | Generate user stories | Standalone or from PRD |
| `/jaan-to:ux-microcopy-write` | Multi-language UI copy | Standalone |
| `/jaan-to:ux-heatmap-analyze` | Heatmap analysis | Standalone (requires CSV/screenshot) |
| `/jaan-to:ux-flowchart-generate` | Generate Mermaid flowcharts | Standalone or from PRD |
| `/jaan-to:frontend-design` | Create frontend interfaces | Standalone or from PRD |
| `/jaan-to:release-iterate-changelog` | Generate changelog | Standalone → /pm-changelog-rewrite |
| `/jaan-to:pm-changelog-rewrite` | Product changelog | Auto-invoked by release-iterate-changelog |
| `/jaan-to:jaan-init` | Initialize jaan-to for project | Run once per project |
| `/jaan-to:jaan-issue-report` | Report bugs/issues | Standalone |
| `/jaan-to:qa-issue-report` | Report issues to any repo | Standalone |
| `/jaan-to:qa-issue-validate` | Validate issues against codebase | Standalone → /pm-roadmap-add |
| `/jaan-to:pm-roadmap-add` | Add prioritized items to project roadmap | Standalone or from PRD |
| `/jaan-to:pm-roadmap-update` | Review and maintain project roadmap | Standalone (maintenance) |

---

## Future Skills (Planned)

These skills are referenced but not yet implemented:

| Skill | Referenced By | Purpose |
|-------|---------------|---------|
| `/jaan-to:frontend-state-machine` | frontend-task-breakdown | Component state machine definitions |

---

## Complete Skill Inventory

All 52 skills grouped by role.

| Role | Skill | Purpose |
|------|-------|---------|
| **pm** | `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| | `/jaan-to:pm-story-write` | Generate user stories with acceptance criteria |
| | `/jaan-to:pm-research-about` | Deep research on any topic |
| | `/jaan-to:pm-roadmap-add` | Add prioritized items to project roadmap |
| | `/jaan-to:pm-roadmap-update` | Review and maintain project roadmap |
| | `/jaan-to:pm-changelog-rewrite` | Transform technical changelog into product changelog |
| **backend** | `/jaan-to:backend-task-breakdown` | Convert PRD into backend tasks |
| | `/jaan-to:backend-data-model` | Generate data model docs from entities |
| | `/jaan-to:backend-api-contract` | Generate OpenAPI 3.1 contracts |
| | `/jaan-to:backend-scaffold` | Generate backend code stubs |
| | `/jaan-to:backend-service-implement` | Generate service implementations |
| | `/jaan-to:backend-pr-review` | Review backend PRs for security and quality |
| **frontend** | `/jaan-to:frontend-task-breakdown` | Frontend task breakdown from PRD |
| | `/jaan-to:frontend-scaffold` | Convert designs to React/Next.js components |
| | `/jaan-to:frontend-design` | Create production-grade frontend interfaces |
| **ux** | `/jaan-to:ux-research-synthesize` | Synthesize UX research findings |
| | `/jaan-to:ux-microcopy-write` | Generate multi-language UI microcopy |
| | `/jaan-to:ux-heatmap-analyze` | Analyze heatmap data |
| | `/jaan-to:ux-flowchart-generate` | Generate Mermaid flowcharts |
| **qa** | `/jaan-to:qa-test-cases` | Generate BDD test cases |
| | `/jaan-to:qa-test-generate` | Generate runnable test files |
| | `/jaan-to:qa-test-run` | Execute tests, diagnose failures |
| | `/jaan-to:qa-test-mutate` | Run mutation testing with multi-stack support |
| | `/jaan-to:qa-tdd-orchestrate` | Orchestrate TDD cycle with isolated agents |
| | `/jaan-to:qa-contract-validate` | Validate API contracts with multi-tool pipeline |
| | `/jaan-to:qa-quality-gate` | Compute composite quality score |
| | `/jaan-to:qa-issue-report` | Report issues to any GitHub/GitLab repo |
| | `/jaan-to:qa-issue-validate` | Validate issues against codebase with RCA |
| **detect** | `/jaan-to:detect-dev` | Engineering audit with SARIF evidence |
| | `/jaan-to:detect-design` | Design system detection |
| | `/jaan-to:detect-ux` | Repo-driven UX audit |
| | `/jaan-to:detect-product` | Product reality extraction |
| | `/jaan-to:detect-writing` | Writing system extraction |
| | `/jaan-to:detect-pack` | Consolidate detect outputs |
| **dev** | `/jaan-to:dev-docs-fetch` | Fetch library docs via Context7 MCP |
| | `/jaan-to:dev-project-assemble` | Wire scaffolds into runnable project |
| | `/jaan-to:dev-output-integrate` | Copy outputs into project locations |
| | `/jaan-to:dev-verify` | Validate build pipeline and services |
| **sec** | `/jaan-to:sec-audit-remediate` | Fix security findings with patches |
| **devops** | `/jaan-to:devops-infra-scaffold` | Generate CI/CD, Docker, deployment configs |
| | `/jaan-to:devops-deploy-activate` | Activate deployment pipeline |
| **data** | `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| **wp** | `/jaan-to:wp-pr-review` | Review WordPress plugin PRs |
| **release** | `/jaan-to:release-iterate-changelog` | Generate changelog from git history |
| **core** | `/jaan-to:docs-create` | Create new documentation |
| | `/jaan-to:docs-update` | Audit and update stale docs |
| | `/jaan-to:skill-create` | Create new skills |
| | `/jaan-to:skill-update` | Update existing skills |
| | `/jaan-to:learn-add` | Capture lessons learned |
| | `/jaan-to:jaan-init` | Initialize jaan-to for project |
| | `/jaan-to:jaan-issue-report` | Report bugs/issues |

---

## Agent Integration

Skills may invoke agents automatically:

| Agent | Triggered By | Purpose |
|-------|-------------|---------|
| **quality-reviewer** | All output-generating skills | Review output completeness and quality |
| **context-scout** | pm-prd-write, task breakdowns | Gather project context before generation |

---

## Notes

- **Suggested vs Required:** Most skill chains are suggestions, not hard requirements
- **Flexibility:** You can use skills in any order that makes sense for your workflow
- **Feedback Loop:** All skills suggest `/jaan-to:learn-add` after execution for continuous improvement
- **Context Reuse:** Running `/jaan-to:detect-dev` once benefits all subsequent tech-aware skills

---

**Last Updated:** 2026-02-25
