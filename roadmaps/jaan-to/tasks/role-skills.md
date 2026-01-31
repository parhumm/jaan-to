# Role Skills Catalog

> Phase 4 (Quick Wins) + Phase 6 (Advanced) | Status: pending | 41 skills across 6 roles

## Overview

Skills split into two phases by effort:
- **Phase 4**: Quick Win skills (18) - No MCP required, ordered by research rank
- **Phase 6**: Advanced skills (23) - Require MCP connectors

**Research source**: [AI-Assisted Product Operations](../../docs/deepresearches/ai-assisted-product-operations-The-60-highest-leverage-tasks-across-SaaS-teams.md) - 60 highest-leverage tasks across SaaS teams. Skills marked with **Rank #N** are from the Top 20 list.

---

## PM Skills (6)

### /jaan-to-pm-decision-brief

- **Logical**: `pm:decision-brief`
- **Description**: 1-page decision record with options, recommendation, risks, open questions
- **Quick Win**: Yes - simple artifact, minimal MCP
- **MCP Required**: GA4, Clarity (optional for evidence)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/decision/{slug}/brief.md`

### /jaan-to-pm-north-star

- **Logical**: `pm:north-star`
- **Description**: North star metric + drivers + boundaries + cadence (weekly/monthly)
- **Quick Win**: No - needs baseline data
- **MCP Required**: GA4 (baselines/segments)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/metrics/{slug}/north-star.md`

### /jaan-to-pm-scope-slice

- **Logical**: `pm:scope-slice`
- **Description**: MVP vs Later slicing with milestones and dependency list
- **Quick Win**: No - pairs with PRD
- **MCP Required**: Jira (backlog), GitLab (complexity)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/plan/{slug}/scope.md`

### /jaan-to-pm-release-review

- **Logical**: `pm:release-review`
- **Description**: Post-release review: KPI deltas, unexpected outcomes, learnings, follow-ups
- **Quick Win**: No - needs post-launch data
- **MCP Required**: GA4 (KPI deltas), Clarity (UX regressions), Sentry (optional)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/release/{slug}/review.md`

### /jaan-to-pm-story-write

- **Logical**: `pm:story-write`
- **Description**: User stories in standard format with Given/When/Then acceptance criteria
- **Quick Win**: Yes - highly structured, template-based
- **AI Score**: 5 | **Rank**: #6
- **MCP Required**: Jira (optional backlog context)
- **Input**: [feature] [persona] [goal]
- **Output**: `jaan-to/outputs/pm/stories/{slug}/stories.md`
- **Failure Modes**: Too technical; missing "so that"; AC not testable
- **Quality Gates**: INVEST criteria met; QA confirms testability

### /jaan-to-pm-feedback-synthesize

- **Logical**: `pm:feedback-synthesize`
- **Description**: Synthesize customer feedback into categorized themes with prioritized pain points
- **Quick Win**: Yes - pattern recognition, summarization
- **AI Score**: 5 | **Rank**: #15
- **MCP Required**: None (text input), Jira/Intercom (optional)
- **Input**: [feedback_sources] [date_range] [segment]
- **Output**: `jaan-to/outputs/pm/feedback/{slug}/synthesis.md`
- **Failure Modes**: Feedback silos; recency bias; loud customers over-represented
- **Quality Gates**: Multiple sources triangulated; connected to segments

---

## DEV Skills (6)

### /jaan-to-dev-tech-plan

- **Logical**: `dev:tech-plan`
- **Description**: Tech approach with architecture, tradeoffs, risks, rollout/rollback, unknowns
- **Quick Win**: Yes - extends existing pattern
- **MCP Required**: GitLab (modules/flags), Figma (optional constraints)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/plan/{slug}/tech-plan.md`

### /jaan-to-dev-test-plan

- **Logical**: `dev:test-plan`
- **Description**: Dev-owned test plan: unit/integration/e2e scope, fixtures, mocks, highest-risk scenarios
- **Quick Win**: Yes - simple test plan
- **MCP Required**: GitLab (diff impact)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/test/{slug}/test-plan.md`

### /jaan-to-dev-api-contract

- **Logical**: `dev:api-contract`
- **Description**: OpenAPI contract with payloads, errors, versioning, example requests/responses
- **Quick Win**: No - needs OpenAPI MCP
- **MCP Required**: OpenAPI/Swagger, Postman (optional)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/contract/{slug}/api.yaml`

### /jaan-to-dev-pr-review

- **Logical**: `dev:pr-review`
- **Description**: PR review pack: summary, risky files, security/perf hints, missing tests, CI failures
- **Quick Win**: No - needs GitLab MCP
- **MCP Required**: GitLab (MR + pipeline), Sentry (optional regressions)
- **Input**: [pr-link-or-branch]
- **Output**: `jaan-to/outputs/dev/review/{slug}/pr-review.md`

### /jaan-to-dev-ship-check

- **Logical**: `dev:ship-check`
- **Description**: Pre-ship checklist: flags, migrations, monitoring, rollback, Go/No-Go recommendation
- **Quick Win**: No - needs multiple MCPs
- **MCP Required**: GitLab (pipelines), Sentry (health)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/release/{slug}/ship-check.md`

### /jaan-to-dev-docs-generate

- **Logical**: `dev:docs-generate`
- **Description**: Technical documentation: README files, API docs, runbooks, architecture decisions
- **Quick Win**: Yes - draft generation, format standardization
- **AI Score**: 5 | **Rank**: #14
- **MCP Required**: GitLab (code context, optional)
- **Input**: [component] [doc_type]
- **Output**: `jaan-to/outputs/dev/docs/{slug}/{doc_type}.md`
- **Failure Modes**: Documentation stale; inconsistent formatting; missing context
- **Quality Gates**: Up-to-date with code; follows style guide; onboarding-friendly

---

## QA Skills (7)

### /jaan-to-qa-test-matrix

- **Logical**: `qa:test-matrix`
- **Description**: Risk-based matrix: P0/P1 flows × states × devices × env (staging/prod-like)
- **Quick Win**: Yes - structured output
- **MCP Required**: Figma (flow-states), GitLab (impacted areas)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/matrix/{slug}/test-matrix.md`

### /jaan-to-qa-bug-triage

- **Logical**: `qa:bug-triage`
- **Description**: Dedupe + severity + repro hints + next action per issue, cluster by root cause
- **Quick Win**: Yes - simple triage logic
- **MCP Required**: Jira (bug list), Sentry (optional context)
- **Input**: [issue-list]
- **Output**: `jaan-to/outputs/qa/triage/{slug}/bug-triage.md`

### /jaan-to-qa-automation-plan

- **Logical**: `qa:automation-plan`
- **Description**: Automation plan: what to automate now vs later, flakiness risk, testability changes needed
- **Quick Win**: No - planning artifact
- **MCP Required**: Playwright (direction), GitLab (automation MRs)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/automation/{slug}/automation-plan.md`

### /jaan-to-qa-regression-runbook

- **Logical**: `qa:regression-runbook`
- **Description**: Step-by-step regression runbook: smoke → critical → deep checks with timing/owners
- **Quick Win**: No - reusable checklist
- **MCP Required**: GitLab (release branch), Playwright (optional)
- **Input**: [release]
- **Output**: `jaan-to/outputs/qa/regression/{slug}/runbook.md`

### /jaan-to-qa-release-signoff

- **Logical**: `qa:release-signoff`
- **Description**: Go/No-Go summary with evidence, open risks, mitigations, rollback readiness
- **Quick Win**: No - needs multiple MCPs
- **MCP Required**: GitLab (pipeline), Jira (test evidence)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/signoff/{slug}/release-signoff.md`

### /jaan-to-qa-test-cases

- **Logical**: `qa:test-cases`
- **Description**: Test cases from acceptance criteria with edge cases, preconditions, expected results
- **Quick Win**: Yes - highly structured, template-based
- **AI Score**: 5 | **Rank**: #1 (highest-leverage task)
- **MCP Required**: Jira (user story context, optional)
- **Input**: [user_story_id] or [acceptance_criteria]
- **Output**: `jaan-to/outputs/qa/cases/{slug}/test-cases.md`
- **Failure Modes**: Vague steps; missing edge cases; not traceable to requirements
- **Quality Gates**: Peer review; traceable to requirements; reusable format

### /jaan-to-qa-bug-report

- **Logical**: `qa:bug-report`
- **Description**: Structured bug reports with severity, priority, steps to reproduce, expected vs actual
- **Quick Win**: Yes - structured output
- **AI Score**: 5 | **Rank**: #10
- **MCP Required**: Jira (duplicate detection, optional), Sentry (stack traces, optional)
- **Input**: [observation] [test_case_id]
- **Output**: `jaan-to/outputs/qa/bugs/{slug}/bug-report.md`
- **Failure Modes**: Vague descriptions; missing repro steps; incorrect severity
- **Quality Gates**: Developer can reproduce in <5 min; linked to test case

---

## DATA Skills (8)

### /jaan-to-data-event-spec

- **Logical**: `data:event-spec`
- **Description**: GA4-ready event/param spec: naming, triggers, required properties, GTM implementation notes
- **Quick Win**: Yes - extends gtm-datalayer pattern
- **MCP Required**: GA4 (measurement alignment)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/data/events/{slug}/event-spec.md`

### /jaan-to-data-metric-spec

- **Logical**: `data:metric-spec`
- **Description**: Metric definition: formula, caveats, segmentation rules, owner, gaming prevention
- **Quick Win**: Yes - simple definition
- **MCP Required**: GA4 (dimension/metric checks)
- **Input**: [metric]
- **Output**: `jaan-to/outputs/data/metrics/{slug}/metric-spec.md`

### /jaan-to-data-funnel-review

- **Logical**: `data:funnel-review`
- **Description**: Funnel baseline + top drop-offs + segments + 3-5 hypotheses ranked by impact × confidence
- **Quick Win**: No - needs GA4 MCP
- **MCP Required**: GA4 (funnel analysis), Clarity (qualitative)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/data/insights/{slug}/funnel-review.md`

### /jaan-to-data-experiment-design

- **Logical**: `data:experiment-design`
- **Description**: Experiment plan: hypothesis, success metric, boundaries, ramp/kill criteria, analysis checklist
- **Quick Win**: No - builds on metric-spec
- **MCP Required**: GA4 (baseline + segments)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/data/experiments/{slug}/experiment-design.md`

### /jaan-to-data-anomaly-triage

- **Logical**: `data:anomaly-triage`
- **Description**: Triage pack: scope, likely causes, next checks, who to pull in, RCA starter template
- **Quick Win**: No - needs multiple MCPs
- **MCP Required**: GA4 (anomaly detection), Sentry, Clarity (optional)
- **Input**: [kpi]
- **Output**: `jaan-to/outputs/data/monitoring/{slug}/anomaly-triage.md`

### /jaan-to-data-sql-query

- **Logical**: `data:sql-query`
- **Description**: Ad-hoc SQL queries from natural language with results summary
- **Quick Win**: Yes - natural language to SQL
- **AI Score**: 5 | **Rank**: #2 (2nd highest-leverage task)
- **MCP Required**: None (schema context provided)
- **Input**: [question] [tables/schema]
- **Output**: `jaan-to/outputs/data/queries/{slug}/query.sql`
- **Failure Modes**: Misunderstanding question; wrong joins; incorrect filters
- **Quality Gates**: Row count sanity checks; cross-reference dashboards

### /jaan-to-data-cohort-analyze

- **Logical**: `data:cohort-analyze`
- **Description**: Cohort/retention analysis with retention curves and churn risk identification
- **Quick Win**: No - needs window functions expertise
- **AI Score**: 5
- **MCP Required**: GA4 (cohort data), BigQuery (optional)
- **Input**: [cohort_type] [retention_event] [periods]
- **Output**: `jaan-to/outputs/data/cohorts/{slug}/cohort-analysis.md`
- **Failure Modes**: Incomplete data; timezone issues; not accounting for seasonality
- **Quality Gates**: Early cohorts stable; cross-reference with finance

### /jaan-to-data-dbt-model

- **Logical**: `data:dbt-model`
- **Description**: dbt staging/mart models with tests, documentation (schema.yml)
- **Quick Win**: No - needs dbt knowledge
- **AI Score**: 5 | **Rank**: #19
- **MCP Required**: dbt Cloud (optional), BigQuery/Snowflake (schema)
- **Input**: [source_table] [model_type]
- **Output**: `jaan-to/outputs/data/dbt/{slug}/model.sql`
- **Failure Modes**: Circular dependencies; missing tests; poor documentation
- **Quality Gates**: dbt test passes; row counts match; code review

---

## GROWTH Skills (7)

### /jaan-to-growth-content-outline

- **Logical**: `growth:content-outline`
- **Description**: Writing-ready outline: H1-H3, FAQs, entities, internal links, intent matching
- **Quick Win**: Yes - content structure
- **MCP Required**: GSC (opportunity pages + queries)
- **Input**: [page]
- **Output**: `jaan-to/outputs/growth/content/{slug}/outline.md`

### /jaan-to-growth-keyword-brief

- **Logical**: `growth:keyword-brief`
- **Description**: Keyword + intent map with primary/secondary targets, SERP notes, content angle, internal linking
- **Quick Win**: No - needs GSC MCP
- **MCP Required**: GSC (queries/pages)
- **Input**: [topic]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/keyword-brief.md`

### /jaan-to-growth-seo-audit

- **Logical**: `growth:seo-audit`
- **Description**: On-page checklist: title/meta, headings, content gaps, internal links, schema opportunities
- **Quick Win**: No - needs GSC MCP
- **MCP Required**: GSC (page CTR/impressions), GitLab (optional route ownership)
- **Input**: [url_or_route] [target_keyword]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/seo-audit.md`

### /jaan-to-growth-seo-check

- **Logical**: `growth:seo-check`
- **Description**: Technical audit: indexability, crawl signals, critical errors, remediation plan
- **Quick Win**: No - technical checklist
- **MCP Required**: GSC (coverage/index diagnostics)
- **Input**: [site_or_app] [scope]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/seo-check.md`

### /jaan-to-growth-weekly-report

- **Logical**: `growth:weekly-report`
- **Description**: Weekly wins/losses, top pages/queries, actions + owners, next experiments
- **Quick Win**: No - needs multiple MCPs
- **MCP Required**: GA4 (deltas), GSC (deltas)
- **Input**: [period]
- **Output**: `jaan-to/outputs/growth/reports/{slug}/weekly-report.md`

### /jaan-to-growth-meta-write

- **Logical**: `growth:meta-write`
- **Description**: Meta titles (<60 chars) and descriptions (<155 chars) with A/B variations
- **Quick Win**: Yes - structured output, character limits
- **AI Score**: 5 | **Rank**: #12
- **MCP Required**: None (target keyword provided)
- **Input**: [page_url] [target_keyword]
- **Output**: `jaan-to/outputs/growth/meta/{slug}/meta-tags.md`
- **Failure Modes**: Truncation; keyword stuffing; generic descriptions
- **Quality Gates**: Primary keyword included; compelling; proper length

### /jaan-to-growth-content-optimize

- **Logical**: `growth:content-optimize`
- **Description**: Existing content optimization checklist with updated sections and internal links
- **Quick Win**: No - needs traffic analysis
- **AI Score**: 5 | **Rank**: #18
- **MCP Required**: GSC (traffic decline reports), GA4 (engagement)
- **Input**: [page_url]
- **Output**: `jaan-to/outputs/growth/optimization/{slug}/content-refresh.md`
- **Failure Modes**: Surface-level changes; breaking existing rankings
- **Quality Gates**: Matches current intent; competitive depth; tracked 30/60/90 days

---

## UX Skills (7)

### /jaan-to-ux-flow-spec

- **Logical**: `ux:flow-spec`
- **Description**: Flow spec: happy path + empty/loading/error states + edge cases + implementation notes
- **Quick Win**: Yes - flow documentation
- **MCP Required**: Figma (flow/state extraction)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/flows/{slug}/flow-spec.md`

### /jaan-to-ux-microcopy-write

- **Logical**: `ux:microcopy-write`
- **Description**: Microcopy pack: labels, helper text, errors, toasts, confirmations, empty states, tone rules
- **Quick Win**: Yes - simple content
- **MCP Required**: Figma (components + strings)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/content/{slug}/microcopy.md`

### /jaan-to-ux-research-plan

- **Logical**: `ux:research-plan`
- **Description**: Research plan: questions, method, participants, script outline, timeline, deliverables
- **Quick Win**: No - planning artifact
- **MCP Required**: Clarity (pain signals), Figma (flow context)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/research/{slug}/research-plan.md`

### /jaan-to-ux-heuristic-review

- **Logical**: `ux:heuristic-review`
- **Description**: Heuristic review: issues, severity, recommended fixes, quick wins, usability principles
- **Quick Win**: No - structured review
- **MCP Required**: Clarity (behavior evidence), Figma (screens)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/review/{slug}/heuristic-review.md`

### /jaan-to-ux-competitive-review

- **Logical**: `ux:competitive-review`
- **Description**: Competitive teardown: step-by-step flows, patterns, strengths/weaknesses, opportunities
- **Quick Win**: No - needs Figma MCP
- **MCP Required**: Figma (optional), GA4/Clarity (validate assumptions)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/benchmark/{slug}/competitive-review.md`

### /jaan-to-ux-research-synthesize

- **Logical**: `ux:research-synthesize`
- **Description**: Synthesize research findings into themes, executive summary, and recommendations
- **Quick Win**: Yes - pattern recognition, summarization
- **AI Score**: 5 | **Rank**: #8
- **MCP Required**: None (raw data input)
- **Input**: [study_name] [data_sources]
- **Output**: `jaan-to/outputs/ux/research/{slug}/synthesis.md`
- **Failure Modes**: Too long reports; no actionable recommendations
- **Quality Gates**: Stakeholder feedback positive; action items tracked

### /jaan-to-ux-persona-create

- **Logical**: `ux:persona-create`
- **Description**: User personas with goals, pain points, behaviors, and Jobs-to-be-Done
- **Quick Win**: Yes - synthesize data, identify patterns
- **AI Score**: 5 | **Rank**: #16
- **MCP Required**: None (research data input), Clarity (optional)
- **Input**: [research_data] [segment]
- **Output**: `jaan-to/outputs/ux/personas/{slug}/persona.md`
- **Failure Modes**: Based on assumptions; not validated; too many personas
- **Quality Gates**: Validation interviews; periodic reviews; design decisions reference personas

---

## Acceptance Criteria

- [ ] All 41 skills created with SKILL.md + LEARN.md
- [ ] Each skill follows `docs/extending/create-skill.md` specification
- [ ] Documentation in docs/skills/{role}/
- [ ] Registered in context/config.md
- [ ] Tested with sample inputs

## Dependencies

- MCP connectors required for many skills (Phase 3 infrastructure)
- Quick win skills can be built without MCPs

## Priority Order (by research rank)

1. `/jaan-to-qa-test-cases` - Rank #1
2. `/jaan-to-data-sql-query` - Rank #2
3. `/jaan-to-pm-story-write` - Rank #6
4. `/jaan-to-ux-research-synthesize` - Rank #8
5. `/jaan-to-qa-bug-report` - Rank #10
6. `/jaan-to-growth-meta-write` - Rank #12
7. `/jaan-to-dev-docs-generate` - Rank #14
8. `/jaan-to-pm-feedback-synthesize` - Rank #15
9. `/jaan-to-ux-persona-create` - Rank #16
10. `/jaan-to-growth-content-optimize` - Rank #18
11. `/jaan-to-data-dbt-model` - Rank #19
12. `/jaan-to-data-cohort-analyze` - (supports #11 funnel analysis)
