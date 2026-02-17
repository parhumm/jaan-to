---
title: "PM Role Gap Completion"
sidebar_position: 22
---

# PM Role Gap Completion

> Phase 6 | Status: pending

## Problem

The PM role has 24 skills defined in the catalog but only 3 shipped (`pm-prd-write`, `pm-research-about`, `pm-story-write`). 21 skills remain pending, leaving gaps in the discovery → metrics → prioritization → roadmap pipeline. This means PMs can write PRDs and stories but cannot run the full research-to-release workflow.

## Solution

Ship remaining PM skills in priority order — Quick Win skills first (no MCP required), then advanced skills that need MCP connectors.

### Current State

| Status | Count | Skills |
|--------|-------|--------|
| Shipped | 3 | `pm-prd-write`, `pm-research-about`, `pm-story-write` |
| Quick Win (no MCP) | 17 | See priority list below |
| Needs MCP | 4 | `pm-north-star`, `pm-scope-slice`, `pm-release-review`, `pm-release-notes-draft` |

### Priority Order (Quick Wins)

| Priority | Skill | Chain Position | Description |
|----------|-------|---------------|-------------|
| 1 | `pm-problem-statement` | Discovery | Refine raw idea into structured problem statement |
| 2 | `pm-interview-guide` | Discovery | 30-min interview script with open + behavioral questions |
| 3 | `pm-insights-synthesis` | Discovery | Synthesize interview/research data into themed insights |
| 4 | `pm-competitor-matrix` | Market | Competitive analysis with feature comparison matrix |
| 5 | `pm-positioning-brief` | Market | Market positioning and differentiation strategy |
| 6 | `pm-persona-card` | User | User persona cards with demographics, goals, pain points |
| 7 | `pm-jtbd-map` | User | Jobs-to-be-done mapping with hiring/firing criteria |
| 8 | `pm-success-criteria` | Metrics | Define measurable success criteria for initiatives |
| 9 | `pm-kpi-tree` | Metrics | KPI decomposition tree (north star → driver metrics) |
| 10 | `pm-measurement-plan` | Metrics | Measurement plan with data sources and collection methods |
| 11 | `pm-feedback-synthesize` | Prioritization | Synthesize user feedback into actionable themes |
| 12 | `pm-decision-brief` | Prioritization | Decision brief with options, trade-offs, recommendation |
| 13 | `pm-priority-score` | Prioritization | Priority scoring (RICE/ICE/custom) with ranking |
| 14 | `pm-bet-sizing` | Prioritization | Bet sizing for resource allocation decisions |
| 15 | `pm-experiment-plan` | Scope | Experiment design (hypothesis, metrics, duration) |
| 16 | `pm-acceptance-criteria` | Scope | Detailed acceptance criteria from requirements |
| 17 | `pm-trace-links` | Tracing | Bidirectional traceability: requirement → implementation |
| 18 | `pm-now-next-later` | Roadmap | Now/Next/Later roadmap format |
| 19 | `pm-milestones` | Roadmap | Milestone planning with dependencies and dates |

### PM Workflow Chain

```
Discovery: problem-statement → interview-guide → insights-synthesis
     ↓
Market: competitor-matrix → positioning-brief
     ↓
User: persona-card → jtbd-map
     ↓
Metrics: success-criteria → kpi-tree → measurement-plan
     ↓
Prioritization: feedback-synthesize → decision-brief → priority-score → bet-sizing
     ↓
Scope: experiment-plan → acceptance-criteria → trace-links
     ↓
Specification: prd-write → story-write (already shipped)
     ↓
Roadmap: now-next-later → milestones
     ↓
Release: release-notes-draft → release-review (needs MCP)
```

## Scope

**In-scope:**
- Ship 17-19 Quick Win PM skills (no MCP required)
- Each skill: SKILL.md + LEARN.md seed + template
- Follow v3.0.0 patterns (`$JAAN_*` environment variables)
- PM workflow chain documentation

**Out-of-scope:**
- MCP-dependent skills (pm-north-star, pm-scope-slice, pm-release-review, pm-release-notes-draft)
- Batch PM skill (that's #135)
- OKR controller (that's #128)

## Implementation Steps

1. Gap analysis: verify 17 Quick Win skills against PM catalog in `docs/roadmap/tasks/role-skills/pm.md`
2. Create skills in workflow chain order (discovery → market → user → metrics → prioritization → scope → roadmap)
3. For each skill:
   - Create via `/jaan-to:skill-create {skill-name}`
   - Reference upstream skill outputs as inputs
   - Follow two-phase workflow pattern
   - Add LEARN.md seed with initial lessons
4. Validate each skill passes `/jaan-to:skill-update` checks
5. Update PM workflow chain documentation
6. Verify chain: run discovery → market → user → specification as end-to-end test

## Skills Affected

- All 17-19 new PM skills (creation)
- `/pm-prd-write` — may add cross-references to new upstream skills
- `/pm-story-write` — may add cross-references to new upstream skills

## Acceptance Criteria

- [ ] Gap analysis completed: identify which skills to prioritize
- [ ] Ship Quick Win PM skills (no MCP required)
- [ ] All new skills follow v3.0.0 patterns
- [ ] Each skill has SKILL.md + LEARN.md seed
- [ ] PM workflow chain documented (discovery → ship)
- [ ] All skills pass `/jaan-to:skill-update` validation
- [ ] Skills reference upstream/downstream in chain

## Dependencies

- None for Quick Win skills
- Phase 7 MCP connectors for: GA4 (pm-north-star), Jira/GitLab (pm-scope-slice), GA4+Clarity+Sentry (pm-release-review)

## References

- [#134](https://github.com/parhumm/jaan-to/issues/134)
- PM role catalog: `docs/roadmap/tasks/role-skills/pm.md`
- Existing PM skills: `skills/pm-prd-write/`, `skills/pm-research-about/`, `skills/pm-story-write/`
