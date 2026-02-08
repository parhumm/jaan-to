---
title: "PM Skills (24)"
sidebar_position: 5
---

# PM Skills (24)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4 + Phase 6

**Chains**: Discovery → Market → User → Metrics → Prioritize → Scope → PRD → Roadmap → Post-launch

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-pm-interview-guide["pm-interview-guide<br>Interview Guide<br>Script + hypotheses + bias reminders"] --> jaan-to-pm-insights-synthesis["pm-insights-synthesis<br>Insights Synthesis<br>Pains ranked + quote bank"]
    jaan-to-pm-insights-synthesis["pm-insights-synthesis<br>Insights Synthesis<br>Pains ranked + quote bank"] --> jaan-to-pm-problem-statement["pm-problem-statement<br>Problem Statement<br>1-3 statements + non-goals"]
    jaan-to-pm-problem-statement["pm-problem-statement<br>Problem Statement<br>1-3 statements + non-goals"] --> jaan-to-pm-competitor-matrix["pm-competitor-matrix<br>Competitor Matrix<br>Comparison table + gaps"]
    jaan-to-pm-problem-statement["pm-problem-statement<br>Problem Statement<br>1-3 statements + non-goals"] -.-> pm-prd-write["pm-prd-write<br>PRD Write ★"]
    jaan-to-pm-competitor-matrix["pm-competitor-matrix<br>Competitor Matrix<br>Comparison table + gaps"] --> jaan-to-pm-positioning-brief["pm-positioning-brief<br>Positioning Brief<br>Statement + differentiators"]
    jaan-to-pm-positioning-brief["pm-positioning-brief<br>Positioning Brief<br>Statement + differentiators"] --> jaan-to-pm-persona-card["pm-persona-card<br>Persona Card<br>Goals, pains, channels"]
    jaan-to-pm-persona-card["pm-persona-card<br>Persona Card<br>Goals, pains, channels"] --> jaan-to-pm-jtbd-map["pm-jtbd-map<br>JTBD Map<br>Functional/emotional/social jobs"]
    jaan-to-pm-jtbd-map["pm-jtbd-map<br>JTBD Map<br>Functional/emotional/social jobs"] --> jaan-to-pm-success-criteria["pm-success-criteria<br>Success Criteria<br>Measurable done-means + guardrails"]
    jaan-to-pm-success-criteria["pm-success-criteria<br>Success Criteria<br>Measurable done-means + guardrails"] --> jaan-to-pm-north-star["pm-north-star<br>North Star<br>Metric + drivers + cadence"]
    jaan-to-pm-success-criteria["pm-success-criteria<br>Success Criteria<br>Measurable done-means + guardrails"] -.-> pm-prd-write["pm-prd-write<br>PRD Write ★"]
    jaan-to-pm-north-star["pm-north-star<br>North Star<br>Metric + drivers + cadence"] --> jaan-to-pm-kpi-tree["pm-kpi-tree<br>KPI Tree<br>Input metrics + guardrails"]
    jaan-to-pm-kpi-tree["pm-kpi-tree<br>KPI Tree<br>Input metrics + guardrails"] --> jaan-to-pm-measurement-plan["pm-measurement-plan<br>Measurement Plan<br>Events + triggers + validation"]
    jaan-to-pm-measurement-plan["pm-measurement-plan<br>Measurement Plan<br>Events + triggers + validation"] -.-> jaan-to-data-event-spec["data-event-spec<br>DATA: event-spec"]
    jaan-to-pm-feedback-synthesize["pm-feedback-synthesize<br>Feedback Synthesize<br>Themes + prioritized pains"] --> jaan-to-pm-priority-score["pm-priority-score<br>Priority Score<br>Ranked backlog + rationale"]
    jaan-to-pm-decision-brief["pm-decision-brief<br>Decision Brief<br>Options + risks + recommendation"] --> jaan-to-pm-priority-score["pm-priority-score<br>Priority Score<br>Ranked backlog + rationale"]
    jaan-to-pm-priority-score["pm-priority-score<br>Priority Score<br>Ranked backlog + rationale"] --> jaan-to-pm-bet-sizing["pm-bet-sizing<br>Bet Sizing<br>Effort bands + risk + sequencing"]
    jaan-to-pm-bet-sizing["pm-bet-sizing<br>Bet Sizing<br>Effort bands + risk + sequencing"] --> jaan-to-pm-scope-slice["pm-scope-slice<br>Scope Slice<br>MVP vs Later + milestones"]
    jaan-to-pm-scope-slice["pm-scope-slice<br>Scope Slice<br>MVP vs Later + milestones"] --> jaan-to-pm-experiment-plan["pm-experiment-plan<br>Experiment Plan<br>Hypothesis + thresholds + rollout"]
    jaan-to-pm-scope-slice["pm-scope-slice<br>Scope Slice<br>MVP vs Later + milestones"] -.-> pm-prd-write["pm-prd-write<br>PRD Write ★"]
    jaan-to-pm-experiment-plan["pm-experiment-plan<br>Experiment Plan<br>Hypothesis + thresholds + rollout"] -.-> jaan-to-data-experiment-design["data-experiment-design<br>DATA: experiment-design"]
    jaan-to-pm-acceptance-criteria["pm-acceptance-criteria<br>Acceptance Criteria<br>Testable AC + edge cases"] --> pm-story-write["pm-story-write<br>Story Write<br>Given/When/Then stories"]
    jaan-to-pm-acceptance-criteria["pm-acceptance-criteria<br>Acceptance Criteria<br>Testable AC + edge cases"] -.-> qa-test-cases["qa-test-cases<br>QA: test-cases"]
    pm-story-write["pm-story-write<br>Story Write<br>Given/When/Then stories"] -.-> dev-fe-task-breakdown["dev-fe-task-breakdown<br>DEV: fe-task-breakdown"]
    pm-story-write["pm-story-write<br>Story Write<br>Given/When/Then stories"] -.-> dev-be-task-breakdown["dev-be-task-breakdown<br>DEV: be-task-breakdown"]
    pm-prd-write["pm-prd-write<br>PRD Write ★"] --> jaan-to-pm-trace-links["pm-trace-links<br>Trace Links<br>Traceability matrix + coverage"]
    pm-story-write["pm-story-write<br>Story Write<br>Given/When/Then stories"] --> jaan-to-pm-trace-links["pm-trace-links<br>Trace Links<br>Traceability matrix + coverage"]
    jaan-to-pm-trace-links["pm-trace-links<br>Trace Links<br>Traceability matrix + coverage"] -.-> qa-test-cases["qa-test-cases<br>QA: test-cases"]
    jaan-to-pm-release-notes-draft["pm-release-notes-draft<br>Release Notes Draft<br>User-facing changes + support notes"] -.-> jaan-to-support-help-article["support-help-article<br>SUPPORT: help-article"]
    jaan-to-pm-release-notes-draft["pm-release-notes-draft<br>Release Notes Draft<br>User-facing changes + support notes"] -.-> jaan-to-growth-launch-announcement["growth-launch-announcement<br>GROWTH: launch-announcement"]
    jaan-to-pm-now-next-later["pm-now-next-later<br>Now/Next/Later<br>Board + outcomes + confidence"] --> jaan-to-pm-milestones["pm-milestones<br>Milestones<br>Owners + deps + critical path"]
    jaan-to-pm-milestones["pm-milestones<br>Milestones<br>Owners + deps + critical path"] -.-> jaan-to-delivery-plan-milestones["delivery-plan-milestones<br>DELIVERY: plan-milestones"]
    jaan-to-pm-release-review["pm-release-review<br>Release Review<br>KPI deltas + learnings"] --> jaan-to-pm-feedback-synthesize["pm-feedback-synthesize<br>Feedback Synthesize<br>Themes + prioritized pains"]
    jaan-to-pm-release-review["pm-release-review<br>Release Review<br>KPI deltas + learnings"] -.-> jaan-to-release-iterate-top-fixes["release-iterate-top-fixes<br>RELEASE: iterate-top-fixes"]

    style pm-prd-write fill:#e8f5e9,stroke:#4caf50
    style jaan-to-data-event-spec fill:#f0f0f0,stroke:#999
    style jaan-to-data-experiment-design fill:#f0f0f0,stroke:#999
    style qa-test-cases fill:#f0f0f0,stroke:#999
    style dev-fe-task-breakdown fill:#f0f0f0,stroke:#999
    style dev-be-task-breakdown fill:#f0f0f0,stroke:#999
    style jaan-to-support-help-article fill:#f0f0f0,stroke:#999
    style jaan-to-growth-launch-announcement fill:#f0f0f0,stroke:#999
    style jaan-to-delivery-plan-milestones fill:#f0f0f0,stroke:#999
    style jaan-to-release-iterate-top-fixes fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### /jaan-to:pm-interview-guide

- **Logical**: `pm-interview-guide`
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
- **Output**: `$JAAN_OUTPUTS_DIR/pm/discovery/{slug}/interview-guide.md`

### /jaan-to:pm-insights-synthesis

- **Logical**: `pm-insights-synthesis`
- **Description**: Top pains ranked by frequency/impact, quote bank by theme, frequency table + unknowns
- **Quick Win**: Yes
- **Reference**: [Product Manager User Research Synthesis: Implementation Guide/jaan-to/outputs/research/45-pm-insights-synthesis.md)
- **Key Points**:
  - Keep questions open + behavioral ("tell me about the last time…")
  - Capture verbatim quotes + context (who/when/where)
  - Tag notes into pain / workaround / trigger / desired outcome
- **→ Next**: `pm-problem-statement`
- **MCP Required**: None
- **Input**: [notes]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/discovery/{slug}/insights-synthesis.md`

### /jaan-to:pm-problem-statement

- **Logical**: `pm-problem-statement`
- **Description**: 1–3 crisp problem statements (who/what/why) with explicit non-goals and assumptions to validate
- **Quick Win**: Yes
- **Key Points**:
  - Keep questions open + behavioral ("tell me about the last time…")
  - Capture verbatim quotes + context (who/when/where)
  - Tag notes into pain / workaround / trigger / desired outcome
- **→ Next**: `pm-competitor-matrix`, `pm-prd-write`
- **MCP Required**: None
- **Input**: [insights]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/discovery/{slug}/problem-statement.md`

### /jaan-to:pm-competitor-matrix

- **Logical**: `pm-competitor-matrix`
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
- **Output**: `$JAAN_OUTPUTS_DIR/pm/market/{slug}/competitor-matrix.md`

### /jaan-to:pm-positioning-brief

- **Logical**: `pm-positioning-brief`
- **Description**: Positioning statement + core promise, differentiators + proof points, risks and open questions
- **Quick Win**: Yes
- **Key Points**:
  - Compare against user alternatives, not just direct competitors
  - Use consistent criteria (pricing, UX, coverage, latency, trust, etc.)
  - Look for differentiation wedges (distribution, content, workflow fit)
- **→ Next**: `pm-persona-card`
- **MCP Required**: None
- **Input**: [product] [audience]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/market/{slug}/positioning-brief.md`

### /jaan-to:pm-persona-card

- **Logical**: `pm-persona-card`
- **Description**: Persona card (goals, pains, constraints, channels) with top jobs/gains and recognition signals
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-jtbd-map`
- **MCP Required**: None
- **Input**: [segment]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/user/{slug}/persona-card.md`

### /jaan-to:pm-jtbd-map

- **Logical**: `pm-jtbd-map`
- **Description**: JTBD map (functional/emotional/social) with triggers, current workarounds, desired outcomes
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-success-criteria`
- **MCP Required**: None
- **Input**: [use-case]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/user/{slug}/jtbd-map.md`

### /jaan-to:pm-success-criteria

- **Logical**: `pm-success-criteria`
- **Description**: Measurable "done means" criteria with key guardrails and edge cases to include/exclude
- **Quick Win**: Yes
- **Key Points**:
  - Personas should include context + constraints, not demographics only
  - JTBD should include trigger → job → desired outcome
  - Success criteria should be measurable, not "users like it"
- **→ Next**: `pm-north-star`, `pm-prd-write`
- **MCP Required**: None
- **Input**: [persona] [goal]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/user/{slug}/success-criteria.md`

### /jaan-to:pm-north-star

- **Logical**: `pm-north-star`
- **Description**: North star metric + drivers + boundaries + cadence (weekly/monthly)
- **Quick Win**: No - needs baseline data
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `pm-kpi-tree`
- **MCP Required**: GA4 (baselines/segments)
- **Input**: [product]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/metrics/{slug}/north-star.md`

### /jaan-to:pm-kpi-tree

- **Logical**: `pm-kpi-tree`
- **Description**: KPI tree: input metrics + leading indicators + guardrails (quality, latency, churn, cost)
- **Quick Win**: Yes
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `pm-measurement-plan`
- **MCP Required**: None
- **Input**: [north-star]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/metrics/{slug}/kpi-tree.md`

### /jaan-to:pm-measurement-plan

- **Logical**: `pm-measurement-plan`
- **Description**: Events/properties to track + triggers, source of truth per event, validation checklist (QA for analytics)
- **Quick Win**: Yes
- **Key Points**:
  - North Star = value delivered, not vanity
  - KPI tree: inputs → outputs with guardrails
  - Measurement plan must define event/property ownership
- **→ Next**: `data-event-spec`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/metrics/{slug}/measurement-plan.md`

### /jaan-to:pm-feedback-synthesize

- **Logical**: `pm-feedback-synthesize`
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
- **Output**: `$JAAN_OUTPUTS_DIR/pm/feedback/{slug}/synthesis.md`
- **Failure Modes**: Feedback silos; recency bias; loud customers over-represented
- **Quality Gates**: Multiple sources triangulated; connected to segments

### /jaan-to:pm-decision-brief

- **Logical**: `pm-decision-brief`
- **Description**: 1-page decision record with options, recommendation, risks, open questions
- **Quick Win**: Yes - simple artifact, minimal MCP
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-priority-score`
- **MCP Required**: GA4, Clarity (optional for evidence)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/decision/{slug}/brief.md`

### /jaan-to:pm-priority-score

- **Logical**: `pm-priority-score`
- **Description**: Ranked backlog with scoring, rationale per item (drivers + uncertainty), sensitivity notes
- **Quick Win**: Yes
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-bet-sizing`
- **MCP Required**: None
- **Input**: [ideas] [framework]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/priority/{slug}/priority-score.md`

### /jaan-to:pm-bet-sizing

- **Logical**: `pm-bet-sizing`
- **Description**: Effort bands (S/M/L or weeks), risk notes + unknowns, suggested sequencing
- **Quick Win**: Yes
- **Key Points**:
  - Separate impact vs confidence vs effort
  - Include learning value (risk reduction)
  - Document why something is not prioritized
- **→ Next**: `pm-scope-slice`
- **MCP Required**: None
- **Input**: [top-ideas]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/priority/{slug}/bet-sizing.md`

### /jaan-to:pm-scope-slice

- **Logical**: `pm-scope-slice`
- **Description**: MVP vs Later slicing with milestones and dependency list
- **Quick Win**: No - pairs with PRD
- **Key Points**:
  - MVP = smallest slice that tests core assumption
  - Include must-have states (empty/error/loading)
  - Define exit criteria (iterate/kill/scale)
- **→ Next**: `pm-experiment-plan`, `pm-prd-write`
- **MCP Required**: Jira (backlog), GitLab (complexity)
- **Input**: [idea]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/plan/{slug}/scope.md`

### /jaan-to:pm-experiment-plan

- **Logical**: `pm-experiment-plan`
- **Description**: What to learn + hypothesis, success thresholds + guardrails, timeline + segments + rollout plan
- **Quick Win**: Yes
- **Key Points**:
  - MVP = smallest slice that tests core assumption
  - Include must-have states (empty/error/loading)
  - Define exit criteria (iterate/kill/scale)
- **→ Next**: `data-experiment-design`
- **MCP Required**: None
- **Input**: [mvp]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/plan/{slug}/experiment-plan.md`

### /jaan-to:pm-acceptance-criteria

- **Logical**: `pm-acceptance-criteria`
- **Description**: Testable acceptance criteria with edge cases + failure handling and analytics requirements
- **Reference**: [Acceptance Criteria Best Practices: A Production-Ready Research Guide/jaan-to/outputs/research/49-pm-acceptance-criteria.md)
- **Quick Win**: Yes
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `qa-test-cases`, `pm-story-write`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/prd/{slug}/acceptance-criteria.md`

### /jaan-to:pm-story-write

- **Logical**: `pm-story-write`
- **Description**: User stories in standard format with Given/When/Then acceptance criteria
- **Reference**: [Production-Ready PM Story-Write Skill: A Comprehensive Framework/jaan-to/outputs/research/45-pm-insights-synthesis.md)
- **Quick Win**: Yes - highly structured, template-based
- **AI Score**: 5 | **Rank**: #6
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `dev-fe-task-breakdown`, `dev-be-task-breakdown`
- **MCP Required**: Jira (optional backlog context)
- **Input**: [feature] [persona] [goal]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/stories/{slug}/stories.md`
- **Failure Modes**: Too technical; missing "so that"; AC not testable
- **Quality Gates**: INVEST criteria met; QA confirms testability

### /jaan-to:pm-trace-links

- **Logical**: `pm-trace-links`
- **Description**: Generate traceability matrix linking PRD requirements → User Stories → Tasks → Tests with bi-directional references
- **Quick Win**: Yes
- **Key Points**:
  - Parse and extract IDs from existing artifacts (US-01, TASK-BE-01, etc.)
  - Build dependency graph with forward/backward links
  - Detect orphaned items (tasks with no story, tests with no task)
  - Generate coverage metrics (% requirements with tests)
  - Include Mermaid diagrams for visual traceability
- **→ Next**: `qa-test-cases`
- **MCP Required**: None
- **Input**: [prd, stories, tasks, test-cases]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/trace/{slug}/traceability-matrix.md`

### /jaan-to:pm-release-notes-draft

- **Logical**: `pm-release-notes-draft`
- **Description**: User-facing release notes, what changed + who benefits, support notes / known limitations
- **Quick Win**: Yes
- **Key Points**:
  - Start from problem + success metrics, not solutions
  - Make scope explicit: in/out
  - Acceptance criteria must be testable and include edge cases
- **→ Next**: `support-help-article`, `growth-launch-announcement`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/prd/{slug}/release-notes.md`

### /jaan-to:pm-now-next-later

- **Logical**: `pm-now-next-later`
- **Description**: Now/Next/Later board with outcome per initiative and confidence level notes
- **Quick Win**: Yes
- **Key Points**:
  - Prefer outcome-based initiatives, not feature lists
  - Include dependencies + constraints
  - Keep a "Now/Next/Later" to reduce false certainty
- **→ Next**: `pm-milestones`
- **MCP Required**: None
- **Input**: [initiatives]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/roadmap/{slug}/now-next-later.md`

### /jaan-to:pm-milestones

- **Logical**: `pm-milestones`
- **Description**: Milestones + owners, dependencies + critical path, risks + mitigation plan
- **Quick Win**: Yes
- **Key Points**:
  - Prefer outcome-based initiatives, not feature lists
  - Include dependencies + constraints
  - Keep a "Now/Next/Later" to reduce false certainty
- **→ Next**: `delivery-plan-milestones`
- **MCP Required**: None
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/roadmap/{slug}/milestones.md`

### /jaan-to:pm-release-review

- **Logical**: `pm-release-review`
- **Description**: Post-release review: KPI deltas, unexpected outcomes, learnings, follow-ups
- **Quick Win**: No - needs post-launch data
- **Key Points**:
  - Compare to expected impact + guardrails
  - Combine quant + qual (tickets, comments, usability)
  - Output should drive next actions, not just insights
- **→ Next**: `pm-feedback-synthesize`, `release-iterate-top-fixes`
- **MCP Required**: GA4 (KPI deltas), Clarity (UX regressions), Sentry (optional)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/pm/release/{slug}/review.md`
