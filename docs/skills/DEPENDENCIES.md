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
│  /pm-prd-write                                  │
│  "Generate PRD from initiative"                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /pm-story-write (Optional)
                 │    "Generate user stories from PRD"
                 │
                 ├──> /detect-dev
                 │    "Engineering audit of codebase"
                 │
                 ├──> /ux-flowchart-generate
                 │    "Generate Mermaid flowcharts from PRD"
                 │
                 ├──> /frontend-task-breakdown
                 │    "Frontend task breakdown from PRD"
                 │     │
                 │     └──> /frontend-state-machine (Future)
                 │          "State machine definitions"
                 │
                 ├──> /frontend-design
                 │    "Create production-grade frontend interfaces"
                 │
                 ├──> /backend-task-breakdown
                 │    "Backend task breakdown from PRD"
                 │     │
                 │     ├──> /backend-data-model
                 │     │    "Data model specification"
                 │     │
                 │     └──> /backend-api-contract
                 │          "OpenAPI 3.1 contract from entities"
                 │
                 ├──> /qa-test-cases
                 │    "Generate BDD test cases from PRD"
                 │
                 └──> /data-gtm-datalayer
                      "GTM tracking code from PRD"
```

### Research Flow

```
Research & Learning:
┌─────────────────────────────────────────────────────────┐
│  /pm-research-about                             │
│  "Deep research on any topic"                           │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /learn-add (Suggested)
                      "Capture research insights as lessons"
```

### Documentation Flow

```
Documentation Management:
┌─────────────────────────────────────────────────────────┐
│  /docs-create                                   │
│  "Create new documentation"                             │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /docs-update (Suggested)
                      "Audit and update stale docs"
```

### UX Research Flow

```
UX Research & Design:
┌─────────────────────────────────────────────────────────┐
│  /ux-research-synthesize                        │
│  "Synthesize UX research findings"                      │
└─────────────────────────────────────────────────────────┘
                 │
                 ├──> /ux-microcopy-write
                 │    "Multi-language UI copy from insights"
                 │
                 ├──> /ux-heatmap-analyze
                 │    "Analyze interaction patterns from heatmaps"
                 │
                 └──> /ux-flowchart-generate
                      "Generate Mermaid flowcharts from findings"
```

### Detection / Audit Flow

```
Detection & Audit:
┌─────────────────────────────────────────────────────────┐
│  Run any combination of detect skills:                  │
│                                                         │
│  /detect-dev        "Engineering audit"         │
│  /detect-design     "Design system detection"   │
│  /detect-ux         "UX audit"                  │
│  /detect-product    "Product reality extraction" │
│  /detect-writing    "Writing system extraction"  │
└────────────────┬────────────────────────────────────────┘
                 │
                 └──> /detect-pack
                      "Consolidate into unified index with risk heatmap"
```

### Code Review Flow

```
Code Review:
┌─────────────────────────────────────────────────────────┐
│  /backend-pr-review                             │
│  "Review backend PRs for security and quality"          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  /wp-pr-review                                  │
│  "Review WordPress plugin PRs"                          │
└─────────────────────────────────────────────────────────┘
```

### Issue Reporting & Validation Flow

```
Issue Reporting:
┌─────────────────────────────────────────────────────────┐
│  /qa-issue-report                               │
│  "Report issues to any GitHub/GitLab repo"              │
└─────────────────────────────────────────────────────────┘

Issue Validation:
┌─────────────────────────────────────────────────────────┐
│  /qa-issue-validate                             │
│  "Validate issues against codebase with RCA"            │
└────────────────┬────────────────────────────────────────┘
                 │
                 └──> /pm-roadmap-add (if VALID + user approves)
                      "Add validated issue to roadmap"

> Cross-pipeline: For VALID_BUG verdicts, the reproduction scenario can feed
> /qa-test-cases → /qa-test-generate for regression tests. For VALID_FEATURE
> verdicts, the RCA summary provides acceptance criteria for the same pipeline.

Internal:
┌─────────────────────────────────────────────────────────┐
│  /jaan-issue-report                             │
│  "Report jaan-to plugin issues"                         │
└─────────────────────────────────────────────────────────┘
```

### Spec-to-Ship Flow

```
Code Generation & Deployment:
┌─────────────────────────────────────────────────────────┐
│  /backend-scaffold + /frontend-scaffold │
│  "Generate code stubs from specs"                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /backend-service-implement
                 │    "Fill service stubs with business logic"
                 │
                 ├──> /dev-project-assemble
                 │    "Wire scaffolds into runnable project"
                 │
                 ├──> /qa-test-generate
                 │    "Generate runnable tests from BDD cases"
                 │     │
                 │     └──> /qa-test-run
                 │          "Execute tests, diagnose failures, report coverage"
                 │
                 ├──> /detect-dev
                 │    "Security audit of generated code"
                 │     │
                 │     └──> /sec-audit-remediate
                 │          "Fix security findings with patches"
                 │
                 ├──> /backend-pr-review
                 │    "Review backend PRs for security and quality"
                 │
                 ├──> /devops-infra-scaffold
                 │    "Generate CI/CD, Docker, deployment configs"
                 │
                 ├──> /dev-output-integrate
                 │    "Copy outputs into project locations"
                 │     │
                 │     └──> (suggested) /detect-dev --incremental
                 │          "Re-audit integrated files for security and quality"
                 │
                 ├──> /dev-verify
                 │    "Validate build pipeline and running services"
                 │
                 └──> /devops-deploy-activate
                      "Activate deployment pipeline"
```

### Library Context Flow

```
Library Documentation:
┌─────────────────────────────────────────────────────────┐
│  /dev-docs-fetch                                │
│  "Fetch library docs via Context7 MCP"                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /backend-scaffold
                 │    "Generated code uses current API patterns"
                 │
                 ├──> /frontend-scaffold
                 │    "Generated components use current framework patterns"
                 │
                 └──> /dev-project-assemble
                      "Project config follows current best practices"
```

### Release Flow

```
Release Management:
┌─────────────────────────────────────────────────────────┐
│  /release-iterate-changelog                     │
│  "Generate changelog from git history"                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /pm-changelog-rewrite (Auto-invoked)
                 │    "Transform into user-facing product changelog"
                 │
                 └──> /qa-issue-report (Suggested)
                      "Post supportive comment on closed issues"
```

### Skill Development Flow

```
Plugin Development:
┌─────────────────────────────────────────────────────────┐
│  /skill-create                                  │
│  "Create new skill with wizard"                         │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /skill-update
                      "Update existing skill"
```

---

## Cross-Cutting Skills

These skills are suggested by multiple other skills:

### Learning & Feedback
- **Used by:** ALL skills (after execution)
- **Command:** `/learn-add`
- **Purpose:** Capture lessons learned for continuous improvement
- **Trigger:** User provides feedback about skill execution

### Roadmap Management
- **Used by:** Skills that create new features
- **Command:** `/pm-roadmap-add`
- **Purpose:** Track feature requests and improvements
- **Trigger:** User identifies missing functionality

---

## Skill Chains (Common Workflows)

### 1. Feature Development (Complete Flow)

```bash
# Step 1: Research & PRD
/pm-research-about "authentication best practices"
/pm-prd-write "OAuth2 authentication"

# Step 2: User Stories & Flowcharts
/pm-story-write from prd
/ux-flowchart-generate from prd

# Step 3: Tech Planning
/detect-dev
/frontend-task-breakdown from prd
/backend-task-breakdown from prd
/backend-data-model from task breakdown
/backend-api-contract from entities

# Step 4: QA & Tracking
/qa-test-cases from prd
/data-gtm-datalayer "auth flow tracking"
```

### 2. UX Enhancement Flow

```bash
# Step 1: Analyze Current State
/ux-heatmap-analyze "homepage-heatmap.csv"

# Step 2: Synthesize Research
/ux-research-synthesize "UX research notes"

# Step 3: Generate Microcopy
/ux-microcopy-write based on insights
```

### 3. Documentation Maintenance

```bash
# Step 1: Audit Staleness
/docs-update --check-only

# Step 2: Fix Stale Docs
/docs-update --fix

# Step 3: Create New Docs as Needed
/docs-create guide "API integration"
```

### 4. Detection & Audit

```bash
# Step 1: Run detect skills
/detect-dev
/detect-design
/detect-ux
/detect-product
/detect-writing

# Step 2: Consolidate findings
/detect-pack
```

### 5. Code Review

```bash
# Backend PRs (any stack)
/backend-pr-review

# WordPress plugin PRs
/wp-pr-review
```

---

## Standalone Skills

These skills don't typically call others:

| Skill | Purpose | Usage Pattern |
|-------|---------|---------------|
| `/pm-story-write` | Generate user stories | Standalone or from PRD |
| `/ux-microcopy-write` | Multi-language UI copy | Standalone |
| `/ux-heatmap-analyze` | Heatmap analysis | Standalone (requires CSV/screenshot) |
| `/ux-flowchart-generate` | Generate Mermaid flowcharts | Standalone or from PRD |
| `/frontend-design` | Create frontend interfaces | Standalone or from PRD |
| `/release-iterate-changelog` | Generate changelog | Standalone → /pm-changelog-rewrite |
| `/pm-changelog-rewrite` | Product changelog | Auto-invoked by release-iterate-changelog |
| `/jaan-init` | Initialize jaan-to for project | Run once per project |
| `/jaan-issue-report` | Report bugs/issues | Standalone |
| `/qa-issue-report` | Report issues to any repo | Standalone |
| `/qa-issue-validate` | Validate issues against codebase | Standalone → /pm-roadmap-add |
| `/pm-roadmap-add` | Add prioritized items to project roadmap | Standalone or from PRD |
| `/pm-roadmap-update` | Review and maintain project roadmap | Standalone (maintenance) |

---

## Future Skills (Planned)

These skills are referenced but not yet implemented:

| Skill | Referenced By | Purpose |
|-------|---------------|---------|
| `/frontend-state-machine` | frontend-task-breakdown | Component state machine definitions |

---

## Complete Skill Inventory

All 53 skills grouped by role.

| Role | Skill | Purpose |
|------|-------|---------|
| **pm** | `/pm-prd-write` | Generate PRD from initiative |
| | `/pm-story-write` | Generate user stories with acceptance criteria |
| | `/pm-research-about` | Deep research on any topic |
| | `/pm-roadmap-add` | Add prioritized items to project roadmap |
| | `/pm-roadmap-update` | Review and maintain project roadmap |
| | `/pm-changelog-rewrite` | Transform technical changelog into product changelog |
| **backend** | `/backend-task-breakdown` | Convert PRD into backend tasks |
| | `/backend-data-model` | Generate data model docs from entities |
| | `/backend-api-contract` | Generate OpenAPI 3.1 contracts |
| | `/backend-scaffold` | Generate backend code stubs |
| | `/backend-service-implement` | Generate service implementations |
| | `/backend-pr-review` | Review backend PRs for security and quality |
| **frontend** | `/frontend-task-breakdown` | Frontend task breakdown from PRD |
| | `/frontend-scaffold` | Convert designs to React/Next.js components |
| | `/frontend-design` | Create production-grade frontend interfaces |
| **ux** | `/ux-research-synthesize` | Synthesize UX research findings |
| | `/ux-microcopy-write` | Generate multi-language UI microcopy |
| | `/ux-heatmap-analyze` | Analyze heatmap data |
| | `/ux-flowchart-generate` | Generate Mermaid flowcharts |
| **qa** | `/qa-test-cases` | Generate BDD test cases |
| | `/qa-test-generate` | Generate runnable test files |
| | `/qa-test-run` | Execute tests, diagnose failures |
| | `/qa-test-mutate` | Run mutation testing with multi-stack support |
| | `/qa-tdd-orchestrate` | Orchestrate TDD cycle with isolated agents |
| | `/qa-contract-validate` | Validate API contracts with multi-tool pipeline |
| | `/qa-quality-gate` | Compute composite quality score |
| | `/qa-issue-report` | Report issues to any GitHub/GitLab repo |
| | `/qa-issue-validate` | Validate issues against codebase with RCA |
| **detect** | `/detect-dev` | Engineering audit with SARIF evidence |
| | `/detect-design` | Design system detection |
| | `/detect-ux` | Repo-driven UX audit |
| | `/detect-product` | Product reality extraction |
| | `/detect-writing` | Writing system extraction |
| | `/detect-pack` | Consolidate detect outputs |
| **dev** | `/dev-docs-fetch` | Fetch library docs via Context7 MCP |
| | `/dev-project-assemble` | Wire scaffolds into runnable project |
| | `/dev-output-integrate` | Copy outputs into project locations |
| | `/dev-verify` | Validate build pipeline and services |
| **sec** | `/sec-audit-remediate` | Fix security findings with patches |
| **devops** | `/devops-infra-scaffold` | Generate CI/CD, Docker, deployment configs |
| | `/devops-deploy-activate` | Activate deployment pipeline |
| **data** | `/data-gtm-datalayer` | Generate GTM tracking code |
| **wp** | `/wp-pr-review` | Review WordPress plugin PRs |
| **release** | `/release-iterate-changelog` | Generate changelog from git history |
| **core** | `/docs-create` | Create new documentation |
| | `/docs-update` | Audit and update stale docs |
| | `/skill-create` | Create new skills |
| | `/skill-update` | Update existing skills |
| | `/learn-add` | Capture lessons learned |
| | `/jaan-init` | Initialize jaan-to for project |
| | `/jaan-issue-report` | Report bugs/issues |

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
- **Feedback Loop:** All skills suggest `/learn-add` after execution for continuous improvement
- **Context Reuse:** Running `/detect-dev` once benefits all subsequent tech-aware skills

---

**Last Updated:** 2026-02-25
