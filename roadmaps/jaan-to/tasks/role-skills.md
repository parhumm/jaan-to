# Role Skills Catalog

> Phase 4 (Quick Wins) + Phase 6 (Advanced) | Status: pending | 130 skills across 11 roles

## Overview

Skills split into two phases by effort:
- **Phase 4**: Quick Win skills — No MCP required, ordered by research rank
- **Phase 6**: Advanced skills — Require MCP connectors

Skills within each role are **sorted by workflow dependency order** (topological). Skills you call first in a workflow appear first. Chains flow top-to-bottom.

**Research source**: [AI-Assisted Product Operations](../../docs/deepresearches/ai-assisted-product-operations-The-60-highest-leverage-tasks-across-SaaS-teams.md) - 60 highest-leverage tasks across SaaS teams. Skills marked with **Rank #N** are from the Top 20 list.

---

## PM Skills (23)

**Chains**: Discovery → Market → User → Metrics → Prioritize → Scope → PRD → Roadmap → Post-launch

### /jaan-to-pm-interview-guide

- **Logical**: `pm:interview-guide`
- **Description**: 30-min interview script with hypotheses, key probes, and bias-avoidance reminders
- **Quick Win**: Yes
- **Key Points**:
  - Keep questions open + behavioral ("tell me about the last time…")
  - Capture verbatim quotes + context (who/when/where)
  - Tag notes into pain / workaround / trigger / desired outcome
  - End with a hypotheses checklist to validate next
- **→ Next**: `pm-insights-synthesis`
- **MCP Required**: None
- **Input**: [persona] [topic]
- **Output**: `jaan-to/outputs/pm/discovery/{slug}/interview-guide.md`

### /jaan-to-pm-insights-synthesis

- **Logical**: `pm:insights-synthesis`
- **Description**: Top pains ranked by frequency/impact, quote bank by theme, frequency table + unknowns
- **Quick Win**: Yes
- **Key Points**:
  - Keep questions open + behavioral ("tell me about the last time…")
  - Capture verbatim quotes + context (who/when/where)
  - Tag notes into pain / workaround / trigger / desired outcome
- **→ Next**: `pm-problem-statement`
- **MCP Required**: None
- **Input**: [notes]
- **Output**: `jaan-to/outputs/pm/discovery/{slug}/insights-synthesis.md`

### /jaan-to-pm-problem-statement

- **Logical**: `pm:problem-statement`
- **Description**: 1–3 crisp problem statements (who/what/why) with explicit non-goals and assumptions to validate
- **Quick Win**: Yes
- **Key Points**:
  - Keep questions open + behavioral ("tell me about the last time…")
  - Capture verbatim quotes + context (who/when/where)
  - Tag notes into pain / workaround / trigger / desired outcome
- **→ Next**: `pm-competitor-matrix`, `pm-prd-write`
- **MCP Required**: None
- **Input**: [insights]
- **Output**: `jaan-to/outputs/pm/discovery/{slug}/problem-statement.md`

### /jaan-to-pm-competitor-matrix

- **Logical**: `pm:competitor-matrix`
- **Description**: Comparison table (criteria × competitors) with gaps/opportunities and "so what?" takeaways
- **Quick Win**: Yes
- **Key Points**:
  - Compare against user alternatives, not just direct competitors
  - Use consistent criteria (pricing, UX, coverage, latency, trust, etc.)
  - Look for differentiation wedges (distribution, content, workflow fit)
  - Call out risks and "copy traps"
- **→ Next**: `pm-positioning-brief`
- **MCP Required**: None
- **Input**: [competitors] [criteria]
- **Output**: `jaan-to/outputs/pm/market/{slug}/competitor-matrix.md`

### /jaan-to-pm-positioning-brief

- **Logical**: `pm:positioning-brief`
- **Description**: Positioning statement + core promise, differentiators + proof points, risks and open questions
- **Quick Win**: Yes
- **Key Points**:
  - Compare against user alternatives, not just direct competitors
  - Use consistent criteria (pricing, UX, coverage, latency, trust, etc.)
  - Look for differentiation wedges (distribution, content, workflow fit)
- **→ Next**: `pm-persona-card`
- **MCP Required**: None
- **Input**: [product] [audience]
- **Output**: `jaan-to/outputs/pm/market/{slug}/positioning-brief.md`

### /jaan-to-pm-persona-card

- **Logical**: `pm:persona-card`
- **Description**: Persona card (goals, pains, constraints, channels) with top jobs/gains and recognition signals
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-jtbd-map`
- **MCP Required**: None
- **Input**: [segment]
- **Output**: `jaan-to/outputs/pm/user/{slug}/persona-card.md`

### /jaan-to-pm-jtbd-map

- **Logical**: `pm:jtbd-map`
- **Description**: JTBD map (functional/emotional/social) with triggers, current workarounds, desired outcomes
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-success-criteria`
- **MCP Required**: None
- **Input**: [use-case]
- **Output**: `jaan-to/outputs/pm/user/{slug}/jtbd-map.md`

### /jaan-to-pm-success-criteria

- **Logical**: `pm:success-criteria`
- **Description**: Measurable "done means" criteria with key guardrails and edge cases to include/exclude
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-north-star`, `pm-prd-write`
- **MCP Required**: None
- **Input**: [persona] [goal]
- **Output**: `jaan-to/outputs/pm/user/{slug}/success-criteria.md`

### /jaan-to-pm-north-star

- **Logical**: `pm:north-star`
- **Description**: North star metric + drivers + boundaries + cadence (weekly/monthly)
- **Quick Win**: No - needs baseline data
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `pm-kpi-tree`
- **MCP Required**: GA4 (baselines/segments)
- **Input**: [product]
- **Output**: `jaan-to/outputs/pm/metrics/{slug}/north-star.md`

### /jaan-to-pm-kpi-tree

- **Logical**: `pm:kpi-tree`
- **Description**: KPI tree: input metrics + leading indicators + guardrails (quality, latency, churn, cost)
- **Quick Win**: Yes
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `pm-measurement-plan`
- **MCP Required**: None
- **Input**: [north-star]
- **Output**: `jaan-to/outputs/pm/metrics/{slug}/kpi-tree.md`

### /jaan-to-pm-measurement-plan

- **Logical**: `pm:measurement-plan`
- **Description**: Events/properties to track + triggers, source of truth per event, validation checklist (QA for analytics)
- **Quick Win**: Yes
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `data-event-spec`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/pm/metrics/{slug}/measurement-plan.md`

### /jaan-to-pm-feedback-synthesize

- **Logical**: `pm:feedback-synthesize`
- **Description**: Synthesize customer feedback into categorized themes with prioritized pain points
- **Quick Win**: Yes - pattern recognition, summarization
- **AI Score**: 5 | **Rank**: #15
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Multiple sources triangulated; connected to segments
- **→ Next**: `pm-priority-score`
- **MCP Required**: None (text input), Jira/Intercom (optional)
- **Input**: [feedback_sources] [date_range] [segment]
- **Output**: `jaan-to/outputs/pm/feedback/{slug}/synthesis.md`
- **Failure Modes**: Feedback silos; recency bias; loud customers over-represented
- **Quality Gates**: Multiple sources triangulated; connected to segments

### /jaan-to-pm-decision-brief

- **Logical**: `pm:decision-brief`
- **Description**: 1-page decision record with options, recommendation, risks, open questions
- **Quick Win**: Yes - simple artifact, minimal MCP
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-priority-score`
- **MCP Required**: GA4, Clarity (optional for evidence)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/decision/{slug}/brief.md`

### /jaan-to-pm-priority-score

- **Logical**: `pm:priority-score`
- **Description**: Ranked backlog with scoring, rationale per item (drivers + uncertainty), sensitivity notes
- **Quick Win**: Yes
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-bet-sizing`
- **MCP Required**: None
- **Input**: [ideas] [framework]
- **Output**: `jaan-to/outputs/pm/priority/{slug}/priority-score.md`

### /jaan-to-pm-bet-sizing

- **Logical**: `pm:bet-sizing`
- **Description**: Effort bands (S/M/L or weeks), risk notes + unknowns, suggested sequencing
- **Quick Win**: Yes
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-scope-slice`
- **MCP Required**: None
- **Input**: [top-ideas]
- **Output**: `jaan-to/outputs/pm/priority/{slug}/bet-sizing.md`

### /jaan-to-pm-scope-slice

- **Logical**: `pm:scope-slice`
- **Description**: MVP vs Later slicing with milestones and dependency list
- **Quick Win**: No - pairs with PRD
- **Key Points**:
  - MVP = smallest slice that tests core assumption
  - Include must-have states (empty/error/loading)
  - Define exit criteria (iterate/kill/scale)
- **→ Next**: `pm-experiment-plan`, `pm-prd-write`
- **MCP Required**: Jira (backlog), GitLab (complexity)
- **Input**: [idea]
- **Output**: `jaan-to/outputs/pm/plan/{slug}/scope.md`

### /jaan-to-pm-experiment-plan

- **Logical**: `pm:experiment-plan`
- **Description**: What to learn + hypothesis, success thresholds + guardrails, timeline + segments + rollout plan
- **Quick Win**: Yes
- **Key Points**:
  - MVP = smallest slice that tests core assumption
  - Include must-have states (empty/error/loading)
  - Define exit criteria (iterate/kill/scale)
- **→ Next**: `data-experiment-design`
- **MCP Required**: None
- **Input**: [mvp]
- **Output**: `jaan-to/outputs/pm/plan/{slug}/experiment-plan.md`

### /jaan-to-pm-acceptance-criteria

- **Logical**: `pm:acceptance-criteria`
- **Description**: Testable acceptance criteria with edge cases + failure handling and analytics requirements
- **Quick Win**: Yes
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `qa-test-cases`, `pm-story-write`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/pm/prd/{slug}/acceptance-criteria.md`

### /jaan-to-pm-story-write

- **Logical**: `pm:story-write`
- **Description**: User stories in standard format with Given/When/Then acceptance criteria
- **Quick Win**: Yes - highly structured, template-based
- **AI Score**: 5 | **Rank**: #6
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `dev-fe-task-breakdown`, `dev-be-task-breakdown`
- **MCP Required**: Jira (optional backlog context)
- **Input**: [feature] [persona] [goal]
- **Output**: `jaan-to/outputs/pm/stories/{slug}/stories.md`
- **Failure Modes**: Too technical; missing "so that"; AC not testable
- **Quality Gates**: INVEST criteria met; QA confirms testability

### /jaan-to-pm-release-notes-draft

- **Logical**: `pm:release-notes-draft`
- **Description**: User-facing release notes, what changed + who benefits, support notes / known limitations
- **Quick Win**: Yes
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `support-help-article`, `growth-launch-announcement`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/pm/prd/{slug}/release-notes.md`

### /jaan-to-pm-now-next-later

- **Logical**: `pm:now-next-later`
- **Description**: Now/Next/Later board with outcome per initiative and confidence level notes
- **Quick Win**: Yes
- **Key Points**:
  - Prefer outcome-based initiatives, not feature lists
  - Include dependencies + constraints
  - Keep a "Now/Next/Later" to reduce false certainty
- **→ Next**: `pm-milestones`
- **MCP Required**: None
- **Input**: [initiatives]
- **Output**: `jaan-to/outputs/pm/roadmap/{slug}/now-next-later.md`

### /jaan-to-pm-milestones

- **Logical**: `pm:milestones`
- **Description**: Milestones + owners, dependencies + critical path, risks + mitigation plan
- **Quick Win**: Yes
- **Key Points**:
  - Prefer outcome-based initiatives, not feature lists
  - Include dependencies + constraints
  - Keep a "Now/Next/Later" to reduce false certainty
- **→ Next**: `delivery-plan-milestones`
- **MCP Required**: None
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/roadmap/{slug}/milestones.md`

### /jaan-to-pm-release-review

- **Logical**: `pm:release-review`
- **Description**: Post-release review: KPI deltas, unexpected outcomes, learnings, follow-ups
- **Quick Win**: No - needs post-launch data
- **Key Points**:
  - Compare to expected impact + guardrails
  - Combine quant + qual (tickets, comments, usability)
  - Output should drive next actions, not just insights
- **→ Next**: `pm-feedback-synthesize`, `release-iterate-top-fixes`
- **MCP Required**: GA4 (KPI deltas), Clarity (UX regressions), Sentry (optional)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/pm/release/{slug}/review.md`

---

## DEV Skills (17)

**Chains**: Discovery → Architecture → BE → API → FE → Integration → Test → Observability → Ship

### /jaan-to-dev-feasibility-check

- **Logical**: `dev:feasibility-check`
- **Description**: Risks + dependencies, unknowns + spike recommendations, rough complexity estimate
- **Quick Win**: Yes
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-arch-proposal`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/dev/discovery/{slug}/feasibility-check.md`

### /jaan-to-dev-arch-proposal

- **Logical**: `dev:arch-proposal`
- **Description**: Architecture outline, key choices + tradeoffs, data flow + failure modes
- **Quick Win**: Yes
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-tech-plan`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/dev/discovery/{slug}/arch-proposal.md`

### /jaan-to-dev-tech-plan

- **Logical**: `dev:tech-plan`
- **Description**: Tech approach with architecture, tradeoffs, risks, rollout/rollback, unknowns
- **Quick Win**: Yes - extends existing pattern
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-fe-task-breakdown`, `dev-be-task-breakdown`
- **MCP Required**: GitLab (modules/flags), Figma (optional constraints)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/plan/{slug}/tech-plan.md`

### /jaan-to-dev-be-task-breakdown

- **Logical**: `dev:be-task-breakdown`
- **Description**: BE tasks list, data model notes, reliability considerations
- **Quick Win**: Yes
- **Key Points**:
  - Data model constraints first (unique, indexes, retention)
  - Idempotency + retries for safety
  - Clear error taxonomy
- **→ Next**: `dev-be-data-model`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/dev/backend/{slug}/task-breakdown.md`

### /jaan-to-dev-be-data-model

- **Logical**: `dev:be-data-model`
- **Description**: Tables/collections + fields, constraints + indexes, retention + migration notes
- **Quick Win**: Yes
- **Key Points**:
  - Data model constraints first (unique, indexes, retention)
  - Idempotency + retries for safety
  - Clear error taxonomy
- **→ Next**: `dev-api-contract`
- **MCP Required**: None
- **Input**: [entities]
- **Output**: `jaan-to/outputs/dev/backend/{slug}/data-model.md`

### /jaan-to-dev-api-contract

- **Logical**: `dev:api-contract`
- **Description**: OpenAPI contract with payloads, errors, versioning, example requests/responses
- **Quick Win**: No - needs OpenAPI MCP
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: `dev-api-versioning`, `dev-docs-generate`
- **MCP Required**: OpenAPI/Swagger, Postman (optional)
- **Input**: [entities]
- **Output**: `jaan-to/outputs/dev/contract/{slug}/api.yaml`

### /jaan-to-dev-api-versioning

- **Logical**: `dev:api-versioning`
- **Description**: Compatibility strategy, migration notes + timeline, deprecation communication plan
- **Quick Win**: Yes
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: `dev-docs-generate`
- **MCP Required**: None
- **Input**: [api]
- **Output**: `jaan-to/outputs/dev/contract/{slug}/versioning-plan.md`

### /jaan-to-dev-fe-task-breakdown

- **Logical**: `dev:fe-task-breakdown`
- **Description**: FE tasks list (components, screens, states), estimate bands, risks + dependencies
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `dev-fe-state-machine`
- **MCP Required**: None
- **Input**: [ux-handoff]
- **Output**: `jaan-to/outputs/dev/frontend/{slug}/task-breakdown.md`

### /jaan-to-dev-fe-state-machine

- **Logical**: `dev:fe-state-machine`
- **Description**: UI states + transitions, events that trigger transitions, edge-case behavior
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `dev-test-plan`
- **MCP Required**: None
- **Input**: [screen]
- **Output**: `jaan-to/outputs/dev/frontend/{slug}/state-machine.md`

### /jaan-to-dev-integration-plan

- **Logical**: `dev:integration-plan`
- **Description**: API call sequence, retry policy + failure modes, observability events
- **Quick Win**: Yes
- **Key Points**:
  - Define retries + backoff + idempotency
  - Plan for partial failures and timeouts
  - Provide mocks/stubs for local dev
- **→ Next**: `dev-integration-mock-stubs`
- **MCP Required**: None
- **Input**: [provider] [use-case]
- **Output**: `jaan-to/outputs/dev/integration/{slug}/integration-plan.md`

### /jaan-to-dev-integration-mock-stubs

- **Logical**: `dev:integration-mock-stubs`
- **Description**: Stub interfaces, fake responses (success/fail), test harness guidance
- **Quick Win**: Yes
- **Key Points**:
  - Define retries + backoff + idempotency
  - Plan for partial failures and timeouts
  - Provide mocks/stubs for local dev
- **→ Next**: `dev-test-plan`
- **MCP Required**: None
- **Input**: [provider]
- **Output**: `jaan-to/outputs/dev/integration/{slug}/mock-stubs.md`

### /jaan-to-dev-test-plan

- **Logical**: `dev:test-plan`
- **Description**: Dev-owned test plan: unit/integration/e2e scope, fixtures, mocks, highest-risk scenarios
- **Quick Win**: Yes - simple test plan
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `qa-test-cases`
- **MCP Required**: GitLab (diff impact)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/test/{slug}/test-plan.md`

### /jaan-to-dev-observability-events

- **Logical**: `dev:observability-events`
- **Description**: Log fields + metric names, trace spans suggestions, dashboard checklist
- **Quick Win**: Yes
- **Key Points**:
  - Define structured logs and consistent fields
  - Metrics for latency/error/throughput
  - Alerts should map to user impact
- **→ Next**: `dev-observability-alerts`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/dev/observability/{slug}/events.md`

### /jaan-to-dev-observability-alerts

- **Logical**: `dev:observability-alerts`
- **Description**: Suggested alerts + thresholds, severity levels, noise reduction ideas
- **Quick Win**: Yes
- **Key Points**:
  - Define structured logs and consistent fields
  - Metrics for latency/error/throughput
  - Alerts should map to user impact
- **→ Next**: `sre-slo-setup`
- **MCP Required**: None
- **Input**: [service]
- **Output**: `jaan-to/outputs/dev/observability/{slug}/alert-rules.md`

### /jaan-to-dev-docs-generate

- **Logical**: `dev:docs-generate`
- **Description**: Technical documentation: README files, API docs, runbooks, architecture decisions
- **Quick Win**: Yes - draft generation, format standardization
- **AI Score**: 5 | **Rank**: #14
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: —
- **MCP Required**: GitLab (code context, optional)
- **Input**: [component] [doc_type]
- **Output**: `jaan-to/outputs/dev/docs/{slug}/{doc_type}.md`
- **Failure Modes**: Documentation stale; inconsistent formatting; missing context
- **Quality Gates**: Up-to-date with code; follows style guide; onboarding-friendly

### /jaan-to-dev-pr-review

- **Logical**: `dev:pr-review`
- **Description**: PR review pack: summary, risky files, security/perf hints, missing tests, CI failures
- **Quick Win**: No - needs GitLab MCP
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: —
- **MCP Required**: GitLab (MR + pipeline), Sentry (optional regressions)
- **Input**: [pr-link-or-branch]
- **Output**: `jaan-to/outputs/dev/review/{slug}/pr-review.md`

### /jaan-to-dev-ship-check

- **Logical**: `dev:ship-check`
- **Description**: Pre-ship checklist: flags, migrations, monitoring, rollback, Go/No-Go recommendation
- **Quick Win**: No - needs multiple MCPs
- **Key Points**:
  - Feature flags with targeting and kill switch
  - Gradual rollout with monitoring gates
  - Data migrations planned for rollback
- **→ Next**: `release-prod-runbook`, `qa-release-signoff`
- **MCP Required**: GitLab (pipelines), Sentry (health)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/release/{slug}/ship-check.md`

---

## QA Skills (12)

**Chains**: Matrix → Cases → Data → E2E → Bug → Triage | Perf → Bottleneck | Automation → Smoke → Regression → Signoff

### /jaan-to-qa-test-matrix

- **Logical**: `qa:test-matrix`
- **Description**: Risk-based matrix: P0/P1 flows × states × devices × env (staging/prod-like)
- **Quick Win**: Yes - structured output
- **Key Points**:
  - Test matrix across roles/devices/states
  - Prioritize by risk/impact
  - Include analytics validation when needed
- **→ Next**: `qa-test-cases`
- **MCP Required**: Figma (flow-states), GitLab (impacted areas)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/matrix/{slug}/test-matrix.md`

### /jaan-to-qa-test-cases

- **Logical**: `qa:test-cases`
- **Description**: Test cases from acceptance criteria with edge cases, preconditions, expected results
- **Quick Win**: Yes - highly structured, template-based
- **AI Score**: 5 | **Rank**: #1 (highest-leverage task)
- **Key Points**:
  - Reproducible steps and expected results
  - Validate error/empty states
  - Confirm recovery paths
- **→ Next**: `qa-test-data`
- **MCP Required**: Jira (user story context, optional)
- **Input**: [user_story_id] or [acceptance_criteria]
- **Output**: `jaan-to/outputs/qa/cases/{slug}/test-cases.md`
- **Failure Modes**: Vague steps; missing edge cases; not traceable to requirements
- **Quality Gates**: Peer review; traceable to requirements; reusable format

### /jaan-to-qa-test-data

- **Logical**: `qa:test-data`
- **Description**: Test accounts + permissions, seed data requirements, edge-case data set list
- **Quick Win**: Yes
- **Key Points**:
  - Test matrix across roles/devices/states
  - Prioritize by risk/impact
  - Include analytics validation when needed
- **→ Next**: `qa-e2e-checklist`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/qa/data/{slug}/test-data.md`

### /jaan-to-qa-e2e-checklist

- **Logical**: `qa:e2e-checklist`
- **Description**: E2E checklist + expected results, preconditions + postconditions, state coverage
- **Quick Win**: Yes
- **Key Points**:
  - Reproducible steps and expected results
  - Validate error/empty states
  - Confirm recovery paths
- **→ Next**: `qa-automation-plan`, `qa-bug-report`
- **MCP Required**: None
- **Input**: [flow]
- **Output**: `jaan-to/outputs/qa/e2e/{slug}/e2e-checklist.md`

### /jaan-to-qa-bug-report

- **Logical**: `qa:bug-report`
- **Description**: Structured bug reports with severity, priority, steps to reproduce, expected vs actual
- **Quick Win**: Yes - structured output
- **AI Score**: 5 | **Rank**: #10
- **Key Points**:
  - Reproducible steps and expected results
  - Validate error/empty states
  - Confirm recovery paths
- **→ Next**: `qa-bug-triage`
- **MCP Required**: Jira (duplicate detection, optional), Sentry (stack traces, optional)
- **Input**: [observation] [test_case_id]
- **Output**: `jaan-to/outputs/qa/bugs/{slug}/bug-report.md`
- **Failure Modes**: Vague descriptions; missing repro steps; incorrect severity
- **Quality Gates**: Developer can reproduce in <5 min; linked to test case

### /jaan-to-qa-bug-triage

- **Logical**: `qa:bug-triage`
- **Description**: Dedupe + severity + repro hints + next action per issue, cluster by root cause
- **Quick Win**: Yes - simple triage logic
- **Key Points**:
  - Separate severity (user harm) from priority (when to fix)
  - Cluster duplicates and patterns
  - Tie decisions to metrics and impact
- **→ Next**: `dev-pr-review`, `release-triage-decision`
- **MCP Required**: Jira (bug list), Sentry (optional context)
- **Input**: [issue-list]
- **Output**: `jaan-to/outputs/qa/triage/{slug}/bug-triage.md`

### /jaan-to-qa-perf-plan

- **Logical**: `qa:perf-plan`
- **Description**: Load scenarios + thresholds, tooling checklist, monitoring requirements
- **Quick Win**: Yes
- **Key Points**:
  - Define load profiles (steady, spike, soak)
  - Pass/fail thresholds tied to user experience
  - Identify bottlenecks with data
- **→ Next**: `qa-perf-bottleneck`
- **MCP Required**: None
- **Input**: [service]
- **Output**: `jaan-to/outputs/qa/perf/{slug}/perf-plan.md`

### /jaan-to-qa-perf-bottleneck

- **Logical**: `qa:perf-bottleneck`
- **Description**: Suspected bottlenecks + checks, next diagnostic steps, quick remediation ideas
- **Quick Win**: Yes
- **Key Points**:
  - Define load profiles (steady, spike, soak)
  - Pass/fail thresholds tied to user experience
  - Identify bottlenecks with data
- **→ Next**: `dev-be-task-breakdown`
- **MCP Required**: None
- **Input**: [metrics]
- **Output**: `jaan-to/outputs/qa/perf/{slug}/bottleneck-hypotheses.md`

### /jaan-to-qa-automation-plan

- **Logical**: `qa:automation-plan`
- **Description**: Automation plan: what to automate now vs later, flakiness risk, testability changes needed
- **Quick Win**: No - planning artifact
- **Key Points**:
  - Smoke suite = minimal critical path checks
  - Target regressions based on what changed
  - Keep suites maintainable
- **→ Next**: `qa-smoke-suite`
- **MCP Required**: Playwright (direction), GitLab (automation MRs)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/automation/{slug}/automation-plan.md`

### /jaan-to-qa-smoke-suite

- **Logical**: `qa:smoke-suite`
- **Description**: Smoke tests list (critical paths), environment prerequisites, pass/fail criteria
- **Quick Win**: Yes
- **Key Points**:
  - Smoke suite = minimal critical path checks
  - Target regressions based on what changed
  - Keep suites maintainable
- **→ Next**: `qa-regression-runbook`
- **MCP Required**: None
- **Input**: [product]
- **Output**: `jaan-to/outputs/qa/regression/{slug}/smoke-suite.md`

### /jaan-to-qa-regression-runbook

- **Logical**: `qa:regression-runbook`
- **Description**: Step-by-step regression runbook: smoke → critical → deep checks with timing/owners
- **Quick Win**: No - reusable checklist
- **Key Points**:
  - Smoke suite = minimal critical path checks
  - Target regressions based on what changed
  - Keep suites maintainable
- **→ Next**: `qa-release-signoff`
- **MCP Required**: GitLab (release branch), Playwright (optional)
- **Input**: [release]
- **Output**: `jaan-to/outputs/qa/regression/{slug}/runbook.md`

### /jaan-to-qa-release-signoff

- **Logical**: `qa:release-signoff`
- **Description**: Go/No-Go summary with evidence, open risks, mitigations, rollback readiness
- **Quick Win**: No - needs multiple MCPs
- **Key Points**:
  - Smoke suite = minimal critical path checks
  - Target regressions based on what changed
  - Keep suites maintainable
- **→ Next**: `delivery-release-readiness`
- **MCP Required**: GitLab (pipeline), Jira (test evidence)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/qa/signoff/{slug}/release-signoff.md`

---

## DATA Skills (14)

**Chains**: Events → Metrics → Dictionary → Dashboard | Funnel → Experiment → Analysis → Cohort → Report | Attribution → LTV/CAC

### /jaan-to-data-event-spec

- **Logical**: `data:event-spec`
- **Description**: GA4-ready event/param spec: naming, triggers, required properties, GTM implementation notes
- **Quick Win**: Yes - extends gtm-datalayer pattern
- **Key Points**:
  - Events are verbs; properties add context
  - Ensure consistent naming + schema
  - Validate tracking with QA and dashboards
- **→ Next**: `data-gtm-datalayer`, `data-metric-spec`
- **MCP Required**: GA4 (measurement alignment)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/data/events/{slug}/event-spec.md`

### /jaan-to-data-metric-spec

- **Logical**: `data:metric-spec`
- **Description**: Metric definition: formula, caveats, segmentation rules, owner, gaming prevention
- **Quick Win**: Yes - simple definition
- **Key Points**:
  - Define metrics precisely (numerator/denominator)
  - Include guardrails and anomaly callouts
  - Make it "actionable by default"
- **→ Next**: `data-metric-dictionary`
- **MCP Required**: GA4 (dimension/metric checks)
- **Input**: [metric]
- **Output**: `jaan-to/outputs/data/metrics/{slug}/metric-spec.md`

### /jaan-to-data-metric-dictionary

- **Logical**: `data:metric-dictionary`
- **Description**: Metric definitions + SQL-like logic description, pitfalls + edge cases, example interpretations
- **Quick Win**: Yes
- **Key Points**:
  - Define metrics precisely (numerator/denominator)
  - Include guardrails and anomaly callouts
  - Make it "actionable by default"
- **→ Next**: `data-dashboard-spec`
- **MCP Required**: None
- **Input**: [metrics]
- **Output**: `jaan-to/outputs/data/metrics/{slug}/metric-dictionary.md`

### /jaan-to-data-dashboard-spec

- **Logical**: `data:dashboard-spec`
- **Description**: Dashboard layout + sections, definitions + filters, recommended review cadence
- **Quick Win**: Yes
- **Key Points**:
  - Define metrics precisely (numerator/denominator)
  - Include guardrails and anomaly callouts
  - Make it "actionable by default"
- **→ Next**: —
- **MCP Required**: None
- **Input**: [kpis]
- **Output**: `jaan-to/outputs/data/dashboard/{slug}/dashboard-spec.md`

### /jaan-to-data-funnel-review

- **Logical**: `data:funnel-review`
- **Description**: Funnel baseline + top drop-offs + segments + 3-5 hypotheses ranked by impact × confidence
- **Quick Win**: No - needs GA4 MCP
- **Key Points**:
  - Events are verbs; properties add context
  - Ensure consistent naming + schema
  - Validate tracking with QA and dashboards
- **→ Next**: `data-experiment-design`, `data-cohort-analyze`
- **MCP Required**: GA4 (funnel analysis), Clarity (qualitative)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/data/insights/{slug}/funnel-review.md`

### /jaan-to-data-experiment-design

- **Logical**: `data:experiment-design`
- **Description**: Experiment plan: hypothesis, success metric, boundaries, ramp/kill criteria, analysis checklist
- **Quick Win**: No - builds on metric-spec
- **Key Points**:
  - Hypothesis must be falsifiable
  - Predefine success/guardrails and decision rules
  - Track novelty effects and segment impacts
- **→ Next**: `data-analysis-plan`
- **MCP Required**: GA4 (baseline + segments)
- **Input**: [hypothesis]
- **Output**: `jaan-to/outputs/data/experiments/{slug}/experiment-design.md`

### /jaan-to-data-analysis-plan

- **Logical**: `data:analysis-plan`
- **Description**: Sample sizing notes (assumptions), decision rules (ship/iterate/stop), bias + data quality checks
- **Quick Win**: Yes
- **Key Points**:
  - Hypothesis must be falsifiable
  - Predefine success/guardrails and decision rules
  - Track novelty effects and segment impacts
- **→ Next**: `data-postlaunch-report`
- **MCP Required**: None
- **Input**: [experiment]
- **Output**: `jaan-to/outputs/data/experiments/{slug}/analysis-plan.md`

### /jaan-to-data-cohort-analyze

- **Logical**: `data:cohort-analyze`
- **Description**: Cohort/retention analysis with retention curves and churn risk identification
- **Quick Win**: No - needs window functions expertise
- **AI Score**: 5
- **Key Points**:
  - Combine cohorts + qualitative signals
  - Identify top drop-offs and root causes
  - Output a prioritized action list
- **→ Next**: `data-postlaunch-report`
- **MCP Required**: GA4 (cohort data), BigQuery (optional)
- **Input**: [cohort_type] [retention_event] [periods]
- **Output**: `jaan-to/outputs/data/cohorts/{slug}/cohort-analysis.md`
- **Failure Modes**: Incomplete data; timezone issues; not accounting for seasonality
- **Quality Gates**: Early cohorts stable; cross-reference with finance

### /jaan-to-data-postlaunch-report

- **Logical**: `data:postlaunch-report`
- **Description**: Insights summary + interpretation notes, chart checklist (no code), segment highlights
- **Quick Win**: No - needs post-launch data
- **Key Points**:
  - Combine cohorts + qualitative signals
  - Identify top drop-offs and root causes
  - Output a prioritized action list
- **→ Next**: `pm-release-review`
- **MCP Required**: GA4 (post-launch data)
- **Input**: [metrics]
- **Output**: `jaan-to/outputs/data/insights/{slug}/postlaunch-report.md`

### /jaan-to-data-attribution-plan

- **Logical**: `data:attribution-plan`
- **Description**: Tracking plan + UTMs, source of truth + governance, limits/risks checklist
- **Quick Win**: No - needs attribution setup
- **Key Points**:
  - Attribution limits (multi-touch vs last-touch)
  - UTM hygiene and naming
  - LTV/CAC models should show assumptions
- **→ Next**: `data-ltv-cac-model`
- **MCP Required**: GA4 (attribution data)
- **Input**: [channels]
- **Output**: `jaan-to/outputs/data/growth/{slug}/attribution-plan.md`

### /jaan-to-data-ltv-cac-model

- **Logical**: `data:ltv-cac-model`
- **Description**: Model inputs/outputs table, sensitivity notes (what drives outcomes), data needed to validate
- **Quick Win**: Yes
- **Key Points**:
  - Attribution limits (multi-touch vs last-touch)
  - UTM hygiene and naming
  - LTV/CAC models should show assumptions
- **→ Next**: —
- **MCP Required**: None
- **Input**: [assumptions]
- **Output**: `jaan-to/outputs/data/growth/{slug}/ltv-cac-model.md`

### /jaan-to-data-anomaly-triage

- **Logical**: `data:anomaly-triage`
- **Description**: Triage pack: scope, likely causes, next checks, who to pull in, RCA starter template
- **Quick Win**: No - needs multiple MCPs
- **Key Points**:
  - Combine cohorts + qualitative signals
  - Identify top drop-offs and root causes
  - Output a prioritized action list
- **→ Next**: `sre-incident-runbook`
- **MCP Required**: GA4 (anomaly detection), Sentry, Clarity (optional)
- **Input**: [kpi]
- **Output**: `jaan-to/outputs/data/monitoring/{slug}/anomaly-triage.md`

### /jaan-to-data-sql-query

- **Logical**: `data:sql-query`
- **Description**: Ad-hoc SQL queries from natural language with results summary
- **Quick Win**: Yes - natural language to SQL
- **AI Score**: 5 | **Rank**: #2 (2nd highest-leverage task)
- **Key Points**:
  - Events are verbs; properties add context
  - Ensure consistent naming + schema
  - Validate tracking with QA and dashboards
- **→ Next**: —
- **MCP Required**: None (schema context provided)
- **Input**: [question] [tables/schema]
- **Output**: `jaan-to/outputs/data/queries/{slug}/query.sql`
- **Failure Modes**: Misunderstanding question; wrong joins; incorrect filters
- **Quality Gates**: Row count sanity checks; cross-reference dashboards

### /jaan-to-data-dbt-model

- **Logical**: `data:dbt-model`
- **Description**: dbt staging/mart models with tests, documentation (schema.yml)
- **Quick Win**: No - needs dbt knowledge
- **AI Score**: 5 | **Rank**: #19
- **Key Points**:
  - Events are verbs; properties add context
  - Ensure consistent naming + schema
  - Validate tracking with QA and dashboards
- **→ Next**: `data-sql-query`
- **MCP Required**: dbt Cloud (optional), BigQuery/Snowflake (schema)
- **Input**: [source_table] [model_type]
- **Output**: `jaan-to/outputs/data/dbt/{slug}/model.sql`
- **Failure Modes**: Circular dependencies; missing tests; poor documentation
- **Quality Gates**: dbt test passes; row counts match; code review

---

## GROWTH Skills (15)

**Chains**: SEO: Keyword → Outline → Meta → Audit → Check | Beta → Feedback | Lifecycle → Variants | Loop → Guards | Launch → FAQ

### /jaan-to-growth-keyword-brief

- **Logical**: `growth:keyword-brief`
- **Description**: Keyword + intent map with primary/secondary targets, SERP notes, content angle, internal linking
- **Quick Win**: No - needs GSC MCP
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: `growth-content-outline`
- **MCP Required**: GSC (queries/pages)
- **Input**: [topic]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/keyword-brief.md`

### /jaan-to-growth-content-outline

- **Logical**: `growth:content-outline`
- **Description**: Writing-ready outline: H1-H3, FAQs, entities, internal links, intent matching
- **Quick Win**: Yes - content structure
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: `growth-meta-write`
- **MCP Required**: GSC (opportunity pages + queries)
- **Input**: [page]
- **Output**: `jaan-to/outputs/growth/content/{slug}/outline.md`

### /jaan-to-growth-meta-write

- **Logical**: `growth:meta-write`
- **Description**: Meta titles (<60 chars) and descriptions (<155 chars) with A/B variations
- **Quick Win**: Yes - structured output, character limits
- **AI Score**: 5 | **Rank**: #12
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: `growth-seo-audit`
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
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: `growth-meta-write`
- **MCP Required**: GSC (traffic decline reports), GA4 (engagement)
- **Input**: [page_url]
- **Output**: `jaan-to/outputs/growth/optimization/{slug}/content-refresh.md`
- **Failure Modes**: Surface-level changes; breaking existing rankings
- **Quality Gates**: Matches current intent; competitive depth; tracked 30/60/90 days

### /jaan-to-growth-seo-audit

- **Logical**: `growth:seo-audit`
- **Description**: On-page checklist: title/meta, headings, content gaps, internal links, schema opportunities
- **Quick Win**: No - needs GSC MCP
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: `growth-seo-check`
- **MCP Required**: GSC (page CTR/impressions), GitLab (optional route ownership)
- **Input**: [url_or_route] [target_keyword]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/seo-audit.md`

### /jaan-to-growth-seo-check

- **Logical**: `growth:seo-check`
- **Description**: Technical audit: indexability, crawl signals, critical errors, remediation plan
- **Quick Win**: No - technical checklist
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: —
- **MCP Required**: GSC (coverage/index diagnostics)
- **Input**: [site_or_app] [scope]
- **Output**: `jaan-to/outputs/growth/seo/{slug}/seo-check.md`

### /jaan-to-growth-beta-cohort-plan

- **Logical**: `growth:beta-cohort-plan`
- **Description**: Target cohort + rollout steps, eligibility rules, exit criteria
- **Quick Win**: Yes
- **Key Points**:
  - Define cohort criteria and exit conditions
  - Create feedback loops and comms
  - Monitor support load
- **→ Next**: `growth-beta-feedback-script`, `release-beta-rollout-plan`
- **MCP Required**: None
- **Input**: [criteria]
- **Output**: `jaan-to/outputs/growth/beta/{slug}/cohort-plan.md`

### /jaan-to-growth-beta-feedback-script

- **Logical**: `growth:beta-feedback-script`
- **Description**: Interview/survey prompts, success/failure probes, follow-up sequencing
- **Quick Win**: Yes
- **Key Points**:
  - Define cohort criteria and exit conditions
  - Create feedback loops and comms
  - Monitor support load
- **→ Next**: `pm-insights-synthesis`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/growth/beta/{slug}/feedback-script.md`

### /jaan-to-growth-lifecycle-message-map

- **Logical**: `growth:lifecycle-message-map`
- **Description**: Triggers + messages + timing, channel selection guidance, guardrails (fatigue limits)
- **Quick Win**: Yes
- **Key Points**:
  - Triggers must be event-based (behavioral)
  - Keep copy consistent with tone rules
  - Test variants and measure outcomes
- **→ Next**: `growth-lifecycle-copy-variants`
- **MCP Required**: None
- **Input**: [journey]
- **Output**: `jaan-to/outputs/growth/lifecycle/{slug}/message-map.md`

### /jaan-to-growth-lifecycle-copy-variants

- **Logical**: `growth:lifecycle-copy-variants`
- **Description**: 3–5 variants, tone + CTA options, personalization fields list
- **Quick Win**: Yes
- **Key Points**:
  - Triggers must be event-based (behavioral)
  - Keep copy consistent with tone rules
  - Test variants and measure outcomes
- **→ Next**: `data-experiment-design`
- **MCP Required**: None
- **Input**: [message]
- **Output**: `jaan-to/outputs/growth/lifecycle/{slug}/copy-variants.md`

### /jaan-to-growth-loop-design

- **Logical**: `growth:loop-design`
- **Description**: Loop diagram + steps, incentives + risks, metrics per step
- **Quick Win**: Yes
- **Key Points**:
  - Identify incentive + friction points
  - Add abuse and fraud protections
  - Measure loop conversion at each step
- **→ Next**: `growth-loop-abuse-guards`
- **MCP Required**: None
- **Input**: [mechanic]
- **Output**: `jaan-to/outputs/growth/loop/{slug}/loop-design.md`

### /jaan-to-growth-loop-abuse-guards

- **Logical**: `growth:loop-abuse-guards`
- **Description**: Anti-fraud checks, limits and cooldowns, monitoring signals
- **Quick Win**: Yes
- **Key Points**:
  - Identify incentive + friction points
  - Add abuse and fraud protections
  - Measure loop conversion at each step
- **→ Next**: `data-event-spec`
- **MCP Required**: None
- **Input**: [loop]
- **Output**: `jaan-to/outputs/growth/loop/{slug}/abuse-guards.md`

### /jaan-to-growth-launch-announcement

- **Logical**: `growth:launch-announcement`
- **Description**: Announcement copy pack (short/long), channel adaptations (email/in-app), key benefits bullets
- **Quick Win**: Yes
- **Key Points**:
  - Anchor on benefit and audience
  - Anticipate objections
  - Provide support-ready FAQ
- **→ Next**: `growth-launch-faq`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/growth/launch/{slug}/announcement.md`

### /jaan-to-growth-launch-faq

- **Logical**: `growth:launch-faq`
- **Description**: FAQ + objection handling, known limits + workarounds, support escalation notes
- **Quick Win**: Yes
- **Key Points**:
  - Anchor on benefit and audience
  - Anticipate objections
  - Provide support-ready FAQ
- **→ Next**: `support-help-article`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/growth/launch/{slug}/faq.md`

### /jaan-to-growth-weekly-report

- **Logical**: `growth:weekly-report`
- **Description**: Weekly wins/losses, top pages/queries, actions + owners, next experiments
- **Quick Win**: No - needs multiple MCPs
- **Key Points**:
  - Cluster keywords by intent, not volume only
  - Briefs should include SERP intent and CTA
  - Coordinate with tech SEO basics
- **→ Next**: —
- **MCP Required**: GA4 (deltas), GSC (deltas)
- **Input**: [period]
- **Output**: `jaan-to/outputs/growth/reports/{slug}/weekly-report.md`

---

## UX Skills (20)

**Chains**: Research → Synthesize → Persona | Journey → Edge Cases → Flow | IA: Sitemap → Taxonomy | Wireframe → Review → UI → Handoff | Copy → Errors | A11y → ARIA | Onboarding → Tooltips

### /jaan-to-ux-research-plan

- **Logical**: `ux:research-plan`
- **Description**: Research plan: questions, method, participants, script outline, timeline, deliverables
- **Quick Win**: No - planning artifact
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-research-synthesize`
- **MCP Required**: Clarity (pain signals), Figma (flow context)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/research/{slug}/research-plan.md`

### /jaan-to-ux-research-synthesize

- **Logical**: `ux:research-synthesize`
- **Description**: Synthesize research findings into themes, executive summary, and recommendations
- **Quick Win**: Yes - pattern recognition, summarization
- **AI Score**: 5 | **Rank**: #8
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-persona-create`
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
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `pm-jtbd-map`, `pm-persona-card`
- **MCP Required**: None (research data input), Clarity (optional)
- **Input**: [research_data] [segment]
- **Output**: `jaan-to/outputs/ux/personas/{slug}/persona.md`
- **Failure Modes**: Based on assumptions; not validated; too many personas
- **Quality Gates**: Validation interviews; periodic reviews; design decisions reference personas

### /jaan-to-ux-competitive-review

- **Logical**: `ux:competitive-review`
- **Description**: Competitive teardown: step-by-step flows, patterns, strengths/weaknesses, opportunities
- **Quick Win**: No - needs Figma MCP
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `pm-positioning-brief`
- **MCP Required**: Figma (optional), GA4/Clarity (validate assumptions)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/benchmark/{slug}/competitive-review.md`

### /jaan-to-ux-journey-map

- **Logical**: `ux:journey-map`
- **Description**: Step-by-step journey map, pain points + opportunities, metrics to watch per step
- **Quick Win**: Yes
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-journey-edge-cases`
- **MCP Required**: None
- **Input**: [persona] [task]
- **Output**: `jaan-to/outputs/ux/journey/{slug}/journey-map.md`

### /jaan-to-ux-journey-edge-cases

- **Logical**: `ux:journey-edge-cases`
- **Description**: Edge-case list, recovery paths + UI requirements, "must not happen" failures
- **Quick Win**: Yes
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-flow-spec`
- **MCP Required**: None
- **Input**: [flow]
- **Output**: `jaan-to/outputs/ux/journey/{slug}/edge-cases.md`

### /jaan-to-ux-sitemap

- **Logical**: `ux:sitemap`
- **Description**: Sitemap + page responsibilities, entry points + cross-links, IA risks (deep nesting, duplicates)
- **Quick Win**: Yes
- **Key Points**:
  - Group by user intent, not internal org
  - Define page responsibilities
  - Create naming rules to avoid drift
- **→ Next**: `ux-taxonomy`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/ux/ia/{slug}/sitemap.md`

### /jaan-to-ux-taxonomy

- **Logical**: `ux:taxonomy`
- **Description**: Naming + grouping rules, attribute set (what metadata matters), examples + anti-examples
- **Quick Win**: Yes
- **Key Points**:
  - Group by user intent, not internal org
  - Define page responsibilities
  - Create naming rules to avoid drift
- **→ Next**: `ux-wireframe-screens`
- **MCP Required**: None
- **Input**: [content-types]
- **Output**: `jaan-to/outputs/ux/ia/{slug}/taxonomy.md`

### /jaan-to-ux-wireframe-screens

- **Logical**: `ux:wireframe-screens`
- **Description**: Screen list by step, required states per screen, interaction notes
- **Quick Win**: Yes
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-wireframe-review`
- **MCP Required**: None
- **Input**: [journey]
- **Output**: `jaan-to/outputs/ux/wireframe/{slug}/screens.md`

### /jaan-to-ux-wireframe-review

- **Logical**: `ux:wireframe-review`
- **Description**: Usability checklist, heuristic issues to look for, missing-state detector
- **Quick Win**: Yes
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-ui-spec-states`
- **MCP Required**: None
- **Input**: [wireframes]
- **Output**: `jaan-to/outputs/ux/wireframe/{slug}/review-checklist.md`

### /jaan-to-ux-flow-spec

- **Logical**: `ux:flow-spec`
- **Description**: Flow spec: happy path + empty/loading/error states + edge cases + implementation notes
- **Quick Win**: Yes - flow documentation
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-microcopy-write`, `dev-fe-state-machine`
- **MCP Required**: Figma (flow/state extraction)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/flows/{slug}/flow-spec.md`

### /jaan-to-ux-heuristic-review

- **Logical**: `ux:heuristic-review`
- **Description**: Heuristic review: issues, severity, recommended fixes, quick wins, usability principles
- **Quick Win**: No - structured review
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-flow-spec`
- **MCP Required**: Clarity (behavior evidence), Figma (screens)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/review/{slug}/heuristic-review.md`

### /jaan-to-ux-ui-spec-states

- **Logical**: `ux:ui-spec-states`
- **Description**: State list + triggers, copy requirements per state, visual priority guidance
- **Quick Win**: No - needs Figma
- **Key Points**:
  - Ensure state coverage: success/error/empty/loading
  - Document component usage to reduce custom builds
  - Align spacing/typography with system tokens
- **→ Next**: `ux-ui-handoff-notes`
- **MCP Required**: Figma (screens/states)
- **Input**: [screen]
- **Output**: `jaan-to/outputs/ux/ui/{slug}/spec-states.md`

### /jaan-to-ux-ui-handoff-notes

- **Logical**: `ux:ui-handoff-notes`
- **Description**: Dev handoff notes, components + tokens used, interaction + animation guidance
- **Quick Win**: No - needs Figma
- **Key Points**:
  - Ensure state coverage: success/error/empty/loading
  - Document component usage to reduce custom builds
  - Align spacing/typography with system tokens
- **→ Next**: `dev-fe-task-breakdown`
- **MCP Required**: Figma (design specs)
- **Input**: [design]
- **Output**: `jaan-to/outputs/ux/ui/{slug}/handoff-notes.md`

### /jaan-to-ux-microcopy-write

- **Logical**: `ux:microcopy-write`
- **Description**: Microcopy pack: labels, helper text, errors, toasts, confirmations, empty states, tone rules
- **Quick Win**: Yes - simple content
- **Key Points**:
  - Use verbs, be specific, avoid blame
  - Error messages: what happened + what to do next
  - Maintain tone rules and consistency
- **→ Next**: `ux-error-messages`
- **MCP Required**: Figma (components + strings)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/ux/content/{slug}/microcopy.md`

### /jaan-to-ux-error-messages

- **Logical**: `ux:error-messages`
- **Description**: User-friendly errors, next steps + recovery actions, logging hints (error codes mapping)
- **Quick Win**: Yes
- **Key Points**:
  - Use verbs, be specific, avoid blame
  - Error messages: what happened + what to do next
  - Maintain tone rules and consistency
- **→ Next**: —
- **MCP Required**: None
- **Input**: [errors]
- **Output**: `jaan-to/outputs/ux/content/{slug}/error-messages.md`

### /jaan-to-ux-a11y-audit

- **Logical**: `ux:a11y-audit`
- **Description**: Issues + severity, fix checklist, quick wins vs structural changes
- **Quick Win**: Yes
- **Key Points**:
  - Contrast, focus order, keyboard operability
  - Labels for inputs, meaningful headings
  - Don't rely on color alone
- **→ Next**: `ux-a11y-aria-notes`
- **MCP Required**: None
- **Input**: [screens]
- **Output**: `jaan-to/outputs/ux/a11y/{slug}/audit.md`

### /jaan-to-ux-a11y-aria-notes

- **Logical**: `ux:a11y-aria-notes`
- **Description**: ARIA roles/labels guidance, focus management notes, accessible patterns reminders
- **Quick Win**: Yes
- **Key Points**:
  - Contrast, focus order, keyboard operability
  - Labels for inputs, meaningful headings
  - Don't rely on color alone
- **→ Next**: `dev-fe-task-breakdown`
- **MCP Required**: None
- **Input**: [components]
- **Output**: `jaan-to/outputs/ux/a11y/{slug}/aria-notes.md`

### /jaan-to-ux-onboarding-steps

- **Logical**: `ux:onboarding-steps`
- **Description**: Onboarding steps + activation event, drop-off risks, measurement plan pointers
- **Quick Win**: Yes
- **Key Points**:
  - Define activation event clearly
  - Use progressive disclosure (don't teach everything)
  - Tooltips must be contextual and skippable
- **→ Next**: `ux-onboarding-tooltips`
- **MCP Required**: None
- **Input**: [product]
- **Output**: `jaan-to/outputs/ux/onboarding/{slug}/steps.md`

### /jaan-to-ux-onboarding-tooltips

- **Logical**: `ux:onboarding-tooltips`
- **Description**: Tooltip copy set, tone rules + character limits, "skip/done" patterns
- **Quick Win**: Yes
- **Key Points**:
  - Define activation event clearly
  - Use progressive disclosure (don't teach everything)
  - Tooltips must be contextual and skippable
- **→ Next**: `data-event-spec`
- **MCP Required**: None
- **Input**: [steps]
- **Output**: `jaan-to/outputs/ux/onboarding/{slug}/tooltips.md`

---

## SEC Skills (4)

**Chain**: Threat Model → PII Map → Compliance → Evidence

### /jaan-to-sec-threat-model-lite

- **Logical**: `sec:threat-model-lite`
- **Description**: Threats + mitigations checklist, high-risk areas callout, verification steps
- **Quick Win**: Yes
- **Key Points**:
  - Identify PII and its lifecycle (collect/store/share/delete)
  - Least privilege for access
  - Threat model "lite" for common attack paths
- **→ Next**: `sec-pii-map`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/sec/review/{slug}/threat-model.md`

### /jaan-to-sec-pii-map

- **Logical**: `sec:pii-map`
- **Description**: PII inventory + where it flows, retention + deletion rules, access controls checklist
- **Quick Win**: Yes
- **Key Points**:
  - Identify PII and its lifecycle (collect/store/share/delete)
  - Least privilege for access
  - Threat model "lite" for common attack paths
- **→ Next**: `sec-compliance-requirements`
- **MCP Required**: None
- **Input**: [data]
- **Output**: `jaan-to/outputs/sec/review/{slug}/pii-map.md`

### /jaan-to-sec-compliance-requirements

- **Logical**: `sec:compliance-requirements`
- **Description**: Compliance checklist, data handling requirements, gaps + next steps
- **Quick Win**: Yes
- **Key Points**:
  - Map obligations by region/domain
  - Evidence pack should be audit-friendly
  - Keep controls traceable
- **→ Next**: `sec-compliance-evidence-pack`
- **MCP Required**: None
- **Input**: [region] [domain]
- **Output**: `jaan-to/outputs/sec/compliance/{slug}/requirements.md`

### /jaan-to-sec-compliance-evidence-pack

- **Logical**: `sec:compliance-evidence-pack`
- **Description**: What to document + where stored, evidence examples, ownership and review cadence
- **Quick Win**: Yes
- **Key Points**:
  - Map obligations by region/domain
  - Evidence pack should be audit-friendly
  - Keep controls traceable
- **→ Next**: —
- **MCP Required**: None
- **Input**: [controls]
- **Output**: `jaan-to/outputs/sec/compliance/{slug}/evidence-pack.md`

---

## DELIVERY Skills (8)

**Chains**: Plan → Risks → Backlog → Ready → Sprint → Deps | Readiness → Comms

### /jaan-to-delivery-plan-milestones

- **Logical**: `delivery:plan-milestones`
- **Description**: Milestone plan + owners, exit criteria per milestone, dependency notes
- **Quick Win**: Yes
- **Key Points**:
  - Define milestones with owners and exit criteria
  - Track dependencies explicitly
  - Maintain a risk register
- **→ Next**: `delivery-plan-risks`
- **MCP Required**: None
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/delivery/plan/{slug}/milestones.md`

### /jaan-to-delivery-plan-risks

- **Logical**: `delivery:plan-risks`
- **Description**: Risk register + mitigations, early warning signals, escalation suggestions
- **Quick Win**: Yes
- **Key Points**:
  - Define milestones with owners and exit criteria
  - Track dependencies explicitly
  - Maintain a risk register
- **→ Next**: `delivery-backlog-split`
- **MCP Required**: None
- **Input**: [plan]
- **Output**: `jaan-to/outputs/delivery/plan/{slug}/risks.md`

### /jaan-to-delivery-backlog-split

- **Logical**: `delivery:backlog-split`
- **Description**: Epics/stories/tasks, dependencies + sequencing, unknowns and spikes
- **Quick Win**: Yes
- **Key Points**:
  - Split into epics/stories with acceptance criteria
  - Mark dependencies and sequencing
  - Ensure "definition of ready"
- **→ Next**: `delivery-backlog-ready-check`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/delivery/backlog/{slug}/split.md`

### /jaan-to-delivery-backlog-ready-check

- **Logical**: `delivery:backlog-ready-check`
- **Description**: Definition-of-ready checklist, missing details/questions, risk flags
- **Quick Win**: Yes
- **Key Points**:
  - Split into epics/stories with acceptance criteria
  - Mark dependencies and sequencing
  - Ensure "definition of ready"
- **→ Next**: `delivery-sprint-planning-pack`
- **MCP Required**: None
- **Input**: [story]
- **Output**: `jaan-to/outputs/delivery/backlog/{slug}/ready-check.md`

### /jaan-to-delivery-sprint-planning-pack

- **Logical**: `delivery:sprint-planning-pack`
- **Description**: Sprint goal + selected scope, capacity notes, risks + contingency items
- **Quick Win**: Yes
- **Key Points**:
  - Set one sprint goal tied to outcome
  - Account for capacity and planned interrupts
  - Call out dependency risks
- **→ Next**: `delivery-sprint-dependency-map`
- **MCP Required**: None
- **Input**: [backlog]
- **Output**: `jaan-to/outputs/delivery/sprint/{slug}/planning-pack.md`

### /jaan-to-delivery-sprint-dependency-map

- **Logical**: `delivery:sprint-dependency-map`
- **Description**: Dependency list/graph, critical path callouts, suggested ordering
- **Quick Win**: Yes
- **Key Points**:
  - Set one sprint goal tied to outcome
  - Account for capacity and planned interrupts
  - Call out dependency risks
- **→ Next**: —
- **MCP Required**: None
- **Input**: [items]
- **Output**: `jaan-to/outputs/delivery/sprint/{slug}/dependency-map.md`

### /jaan-to-delivery-release-readiness

- **Logical**: `delivery:release-readiness`
- **Description**: Go/no-go checklist, required approvals, launch-day roles
- **Quick Win**: Yes
- **Key Points**:
  - Go/no-go checklist with owners
  - Comms plan across teams
  - Monitoring and rollback readiness
- **→ Next**: `delivery-release-comms-plan`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/delivery/release/{slug}/readiness.md`

### /jaan-to-delivery-release-comms-plan

- **Logical**: `delivery:release-comms-plan`
- **Description**: Who to notify + when, templates (Slack/email snippets), support/CS readiness prompts
- **Quick Win**: Yes
- **Key Points**:
  - Go/no-go checklist with owners
  - Comms plan across teams
  - Monitoring and rollback readiness
- **→ Next**: `release-prod-runbook`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/delivery/release/{slug}/comms-plan.md`

---

## SRE Skills (8)

**Chains**: SLO → Alerts | Pipeline → Env | Toil → Hardening | Runbook → Postmortem

### /jaan-to-sre-slo-setup

- **Logical**: `sre:slo-setup`
- **Description**: SLOs + error budgets, suggested SLIs (latency, errors, uptime), reporting cadence
- **Quick Win**: No - needs monitoring data
- **Key Points**:
  - Define SLOs and error budgets
  - Alerts should reflect user impact
  - Tune noise and prioritize
- **→ Next**: `sre-alert-tuning`
- **MCP Required**: Monitoring tools (Datadog/Grafana)
- **Input**: [service]
- **Output**: `jaan-to/outputs/sre/monitor/{slug}/slo-setup.md`

### /jaan-to-sre-alert-tuning

- **Logical**: `sre:alert-tuning`
- **Description**: Noise reduction plan, priorities + severity mapping, missing alerts checklist
- **Quick Win**: No - needs alert history
- **Key Points**:
  - Define SLOs and error budgets
  - Alerts should reflect user impact
  - Tune noise and prioritize
- **→ Next**: `dev-observability-alerts`
- **MCP Required**: Monitoring tools (Datadog/Grafana)
- **Input**: [alerts]
- **Output**: `jaan-to/outputs/sre/monitor/{slug}/alert-tuning.md`

### /jaan-to-sre-pipeline-audit

- **Logical**: `sre:pipeline-audit`
- **Description**: Weak points + quick fixes, missing gates checklist, reliability improvements backlog
- **Quick Win**: No - needs GitLab MCP
- **Key Points**:
  - Identify weak gates and flaky tests
  - Ensure env parity and secret management
  - Make rollbacks routine
- **→ Next**: `sre-env-check`
- **MCP Required**: GitLab (pipeline config)
- **Input**: [repo]
- **Output**: `jaan-to/outputs/sre/cicd/{slug}/pipeline-audit.md`

### /jaan-to-sre-env-check

- **Logical**: `sre:env-check`
- **Description**: Config drift + readiness checklist, missing secrets/configs, "safe to deploy?" hints
- **Quick Win**: No - needs GitLab MCP
- **Key Points**:
  - Identify weak gates and flaky tests
  - Ensure env parity and secret management
  - Make rollbacks routine
- **→ Next**: `dev-ship-check`
- **MCP Required**: GitLab (env config)
- **Input**: [env]
- **Output**: `jaan-to/outputs/sre/cicd/{slug}/env-check.md`

### /jaan-to-sre-toil-audit

- **Logical**: `sre:toil-audit`
- **Description**: Toil list + automation candidates, time spent estimates, top ROI opportunities
- **Quick Win**: Yes
- **Key Points**:
  - Track toil weekly; automate repeatable work
  - Maintain reliability backlog
  - Prioritize hardening with measurable outcomes
- **→ Next**: `sre-hardening-plan`
- **MCP Required**: None
- **Input**: [week]
- **Output**: `jaan-to/outputs/sre/ops/{slug}/toil-audit.md`

### /jaan-to-sre-hardening-plan

- **Logical**: `sre:hardening-plan`
- **Description**: Reliability improvement backlog, sequenced steps, verification metrics
- **Quick Win**: Yes
- **Key Points**:
  - Track toil weekly; automate repeatable work
  - Maintain reliability backlog
  - Prioritize hardening with measurable outcomes
- **→ Next**: `delivery-backlog-split`
- **MCP Required**: None
- **Input**: [service]
- **Output**: `jaan-to/outputs/sre/ops/{slug}/hardening-plan.md`

### /jaan-to-sre-incident-runbook

- **Logical**: `sre:incident-runbook`
- **Description**: Runbook + escalation steps, triage checklist, "if X then Y" actions
- **Quick Win**: Yes
- **Key Points**:
  - Runbooks should be actionable and short
  - Clear escalation paths
  - Postmortems must yield backlog items
- **→ Next**: `sre-incident-postmortem`
- **MCP Required**: None
- **Input**: [service]
- **Output**: `jaan-to/outputs/sre/incident/{slug}/runbook.md`

### /jaan-to-sre-incident-postmortem

- **Logical**: `sre:incident-postmortem`
- **Description**: Blameless retro template filled, timeline + contributing factors, action items + owners
- **Quick Win**: Yes
- **Key Points**:
  - Runbooks should be actionable and short
  - Clear escalation paths
  - Postmortems must yield backlog items
- **→ Next**: `sre-hardening-plan`
- **MCP Required**: None
- **Input**: [incident]
- **Output**: `jaan-to/outputs/sre/incident/{slug}/postmortem.md`

---

## SUPPORT Skills (8)

**Chains**: Taxonomy → Digest | Article → Reply | CX Touchpoints → Friction | Monitor → Triage

### /jaan-to-support-tag-taxonomy

- **Logical**: `support:tag-taxonomy`
- **Description**: Support tags + definitions, tagging rules + examples, "do not use" cases
- **Quick Win**: Yes
- **Key Points**:
  - Build a stable tag taxonomy
  - Summaries must include frequency and severity
  - Include example quotes/tickets
- **→ Next**: `support-weekly-digest`
- **MCP Required**: None
- **Input**: [product]
- **Output**: `jaan-to/outputs/support/feedback/{slug}/tag-taxonomy.md`

### /jaan-to-support-help-article

- **Logical**: `support:help-article`
- **Description**: Help-center article draft, step-by-step troubleshooting, "when to contact support" section
- **Quick Win**: Yes
- **Key Points**:
  - Articles should match user language, not internal terms
  - Macros need clear escalation rules
  - Keep troubleshooting steps ordered and testable
- **→ Next**: `support-reply-pack`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/support/docs/{slug}/help-article.md`

### /jaan-to-support-reply-pack

- **Logical**: `support:reply-pack`
- **Description**: Canned replies + tone rules, decision tree for escalation, required fields to collect
- **Quick Win**: Yes
- **Key Points**:
  - Articles should match user language, not internal terms
  - Macros need clear escalation rules
  - Keep troubleshooting steps ordered and testable
- **→ Next**: —
- **MCP Required**: None
- **Input**: [issue-type]
- **Output**: `jaan-to/outputs/support/docs/{slug}/reply-pack.md`

### /jaan-to-support-weekly-digest

- **Logical**: `support:weekly-digest`
- **Description**: Themes + top asks, severity + trend notes, suggested product actions
- **Quick Win**: Yes
- **Key Points**:
  - Build a stable tag taxonomy
  - Summaries must include frequency and severity
  - Include example quotes/tickets
- **→ Next**: `pm-feedback-synthesize`
- **MCP Required**: None
- **Input**: [tickets]
- **Output**: `jaan-to/outputs/support/feedback/{slug}/weekly-digest.md`

### /jaan-to-support-cx-touchpoints

- **Logical**: `support:cx-touchpoints`
- **Description**: Touchpoint map + gaps, ownership per touchpoint, risk points
- **Quick Win**: Yes
- **Key Points**:
  - Map touchpoints end-to-end
  - Identify friction and ownership gaps
  - Prioritize fixes by impact
- **→ Next**: `support-cx-friction-fixes`
- **MCP Required**: None
- **Input**: [journey]
- **Output**: `jaan-to/outputs/support/cx/{slug}/touchpoints.md`

### /jaan-to-support-cx-friction-fixes

- **Logical**: `support:cx-friction-fixes`
- **Description**: Prioritized CX fixes, expected impact + effort band, coordination needs
- **Quick Win**: Yes
- **Key Points**:
  - Map touchpoints end-to-end
  - Identify friction and ownership gaps
  - Prioritize fixes by impact
- **→ Next**: `pm-priority-score`
- **MCP Required**: None
- **Input**: [feedback]
- **Output**: `jaan-to/outputs/support/cx/{slug}/friction-fixes.md`

### /jaan-to-support-launch-monitor

- **Logical**: `support:launch-monitor`
- **Description**: Watchlist + response plan, roles + escalation steps, daily summary template
- **Quick Win**: Yes
- **Key Points**:
  - Define a watchlist (metrics + sentiment + tickets)
  - Set response SLAs
  - Close the loop with product/engineering
- **→ Next**: `support-triage-priority`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/support/watch/{slug}/launch-monitor.md`

### /jaan-to-support-triage-priority

- **Logical**: `support:triage-priority`
- **Description**: Severity + next action, escalation rules, suggested user messaging
- **Quick Win**: Yes
- **Key Points**:
  - Define a watchlist (metrics + sentiment + tickets)
  - Set response SLAs
  - Close the loop with product/engineering
- **→ Next**: `qa-bug-report`
- **MCP Required**: None
- **Input**: [ticket]
- **Output**: `jaan-to/outputs/support/triage/{slug}/priority.md`

---

## RELEASE Skills (8)

**Chains**: Beta Rollout → Issue Log → Triage → Hotfix | Prod Runbook → War Room | Iterate → Changelog

### /jaan-to-release-beta-rollout-plan

- **Logical**: `release:beta-rollout-plan`
- **Description**: Phased rollout plan, exit criteria per phase, targeting + monitoring notes
- **Quick Win**: Yes
- **Key Points**:
  - Phase gates + exit criteria
  - Track issues by category/owner
  - Prepare rollback triggers
- **→ Next**: `release-beta-issue-log`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/release/beta/{slug}/rollout-plan.md`

### /jaan-to-release-beta-issue-log

- **Logical**: `release:beta-issue-log`
- **Description**: Categorized issues + owners, trend summary, "stop the line" triggers
- **Quick Win**: Yes
- **Key Points**:
  - Phase gates + exit criteria
  - Track issues by category/owner
  - Prepare rollback triggers
- **→ Next**: `release-triage-decision`, `release-prod-runbook`
- **MCP Required**: None
- **Input**: [reports]
- **Output**: `jaan-to/outputs/release/beta/{slug}/issue-log.md`

### /jaan-to-release-prod-runbook

- **Logical**: `release:prod-runbook`
- **Description**: Launch steps + rollback triggers, verification checklist, dependencies + comms notes
- **Quick Win**: Yes
- **Key Points**:
  - Runbook with explicit steps
  - War room roles and timing
  - Monitoring dashboard links and thresholds
- **→ Next**: `release-prod-war-room-pack`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/release/prod/{slug}/runbook.md`

### /jaan-to-release-prod-war-room-pack

- **Logical**: `release:prod-war-room-pack`
- **Description**: Dashboard links + roles + schedule, incident comms templates, decision log structure
- **Quick Win**: Yes
- **Key Points**:
  - Runbook with explicit steps
  - War room roles and timing
  - Monitoring dashboard links and thresholds
- **→ Next**: `support-launch-monitor`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/release/prod/{slug}/war-room-pack.md`

### /jaan-to-release-triage-decision

- **Logical**: `release:triage-decision`
- **Description**: Fix/defer decision + rationale, risk notes, suggested comms
- **Quick Win**: Yes
- **Key Points**:
  - Tie decisions to user impact and risk
  - Define minimal hotfix scope
  - Document rationale
- **→ Next**: `release-triage-hotfix-scope`
- **MCP Required**: None
- **Input**: [bug]
- **Output**: `jaan-to/outputs/release/triage/{slug}/decision.md`

### /jaan-to-release-triage-hotfix-scope

- **Logical**: `release:triage-hotfix-scope`
- **Description**: Minimal hotfix scope, test focus areas, rollback considerations
- **Quick Win**: Yes
- **Key Points**:
  - Tie decisions to user impact and risk
  - Define minimal hotfix scope
  - Document rationale
- **→ Next**: `dev-pr-review`
- **MCP Required**: None
- **Input**: [bugs]
- **Output**: `jaan-to/outputs/release/triage/{slug}/hotfix-scope.md`

### /jaan-to-release-iterate-top-fixes

- **Logical**: `release:iterate-top-fixes`
- **Description**: Next sprint improvements list, prioritization rationale, owners suggestions
- **Quick Win**: Yes
- **Key Points**:
  - Prioritize by impact + confidence
  - Keep changelog user-facing
  - Track whether fixes moved the metric
- **→ Next**: `release-iterate-changelog`
- **MCP Required**: None
- **Input**: [insights]
- **Output**: `jaan-to/outputs/release/iterate/{slug}/top-fixes.md`

### /jaan-to-release-iterate-changelog

- **Logical**: `release:iterate-changelog`
- **Description**: Changelog + user impact notes, internal notes (optional), support guidance
- **Quick Win**: Yes
- **Key Points**:
  - Prioritize by impact + confidence
  - Keep changelog user-facing
  - Track whether fixes moved the metric
- **→ Next**: `support-help-article`
- **MCP Required**: None
- **Input**: [changes]
- **Output**: `jaan-to/outputs/release/iterate/{slug}/changelog.md`

---

## Acceptance Criteria

- [ ] All 130 skills created with SKILL.md + LEARN.md
- [ ] Each skill follows `docs/extending/create-skill.md` specification
- [ ] Documentation in docs/skills/{role}/
- [ ] Registered in context/config.md
- [ ] Tested with sample inputs
- [ ] Roles covered: PM, DEV, QA, DATA, GROWTH, UX, SEC, DELIVERY, SRE, SUPPORT, RELEASE

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
12. `/jaan-to-data-cohort-analyze` - (supports funnel analysis)
