---
title: "Role Skills Catalog"
sidebar_position: 9
---

# Role Skills Catalog

> Phase 4 (Quick Wins) + Phase 6 (Advanced) | Status: pending | 140 skills across 12 roles

## Overview

Skills split into two phases by effort:
- **Phase 4**: Quick Win skills — No MCP required, ordered by research rank
- **Phase 6**: Advanced skills — Require MCP connectors

Skills within each role are **sorted by workflow dependency order** (topological). Skills you call first in a workflow appear first. Chains flow top-to-bottom.

**Research source**: [AI-Assisted Product Operations](https://github.com/parhumm/jaan-to/blob/main/docs/deepresearches/ai-assisted-product-operations-The-60-highest-leverage-tasks-across-SaaS-teams.md) - 60 highest-leverage tasks across SaaS teams. Skills marked with **Rank #N** are from the Top 20 list.

## v3.0.0 Implementation Requirements

**All 137 skills MUST use v3.0.0 patterns when implemented:**

### Creation
- Use `/jaan-to:skill-create {skill-name}` (generates v3.0.0-compliant skills)
- Follow [docs/extending/create-skill.md](../../extending/create-skill.md)
- Validate with `/jaan-to:skill-update {skill-name}` before committing

### Paths (Environment Variables)
- **Outputs**: `$JAAN_OUTPUTS_DIR/{role}/{domain}/{slug}/`
- **Templates**: `$JAAN_TEMPLATES_DIR/{skill-name}.template.md`
- **Learning**: `$JAAN_LEARN_DIR/{skill-name}.learn.md`
- **Context**: `$JAAN_CONTEXT_DIR/*.md`

❌ **Never** use hardcoded `jaan-to/` paths

### Tech-Aware Skills
Skills that generate code/specs/PRDs should:
1. Read `$JAAN_CONTEXT_DIR/tech.md` in Pre-Execution
2. Use `{{import:$JAAN_CONTEXT_DIR/tech.md#section}}` in templates
3. Reference frameworks from tech stack in outputs

**Examples**: pm-prd-write, dev-*, qa-test-cases, data-event-spec

### Template Variables
Use v3.0.0 syntax in all template.md files:
- `{{title}}`, `{{date}}`, `{{author}}` - Field variables
- `{{env:JAAN_OUTPUTS_DIR}}` - Environment variables
- `{{import:$JAAN_CONTEXT_DIR/tech.md#current-stack}}` - Section imports

### Validation Checklist
- [ ] Uses `$JAAN_*` variables (not `jaan-to/` paths)
- [ ] Has SKILL.md + template.md + LEARN.md seed
- [ ] Passes `/jaan-to:skill-update` v3.0.0 validation
- [ ] Documented in `docs/skills/{role}/{skill-name}.md`
- [ ] Tested with sample inputs

---

## Roles

| Role | Skills | Quick Wins | File |
|------|--------|------------|------|
| PM | 24 | 18 | [pm.md](role-skills/pm.md) |
| DEV | 19 | 15 | [dev.md](role-skills/dev.md) |
| QA | 12 | 8 | [qa.md](role-skills/qa.md) |
| DATA | 14 | 8 | [data.md](role-skills/data.md) |
| GROWTH | 15 | 9 | [growth.md](role-skills/growth.md) |
| UX | 20 | 15 | [ux.md](role-skills/ux.md) |
| SEC | 4 | 4 | [sec.md](role-skills/sec.md) |
| DELIVERY | 8 | 8 | [delivery.md](role-skills/delivery.md) |
| SRE | 9 | 5 | [sre.md](role-skills/sre.md) |
| SUPPORT | 8 | 8 | [support.md](role-skills/support.md) |
| RELEASE | 8 | 8 | [release.md](role-skills/release.md) |
| DETECT | 6 | 6 | [detect.md](role-skills/detect.md) |

---

## Cross-Role Workflow Chains

Key dependency flows across roles:

- **Discovery → Build**: PM (interview → problem → PRD) → DEV (tech-plan → tasks) → QA (test-cases)
- **Metrics → Tracking**: PM (measurement-plan) → DATA (event-spec → gtm-datalayer)
- **Launch → Monitor**: DELIVERY (release-readiness) → RELEASE (prod-runbook) → SUPPORT (launch-monitor)
- **Feedback Loop**: SUPPORT (weekly-digest) → PM (feedback-synthesize → priority-score)
- **Security Gate**: SEC (threat-model → pii-map) feeds into DEV and DELIVERY
- **Reliability**: DEV (observability-alerts) → SRE (slo-setup → alert-tuning)
- **Beta**: GROWTH (beta-cohort-plan) → RELEASE (beta-rollout-plan → issue-log)
- **Detect → Knowledge**: DETECT (dev-detect + detect-design + detect-writing + detect-product + detect-ux) → pack-detect

---

## Acceptance Criteria

- [ ] All 147 skills created with SKILL.md + LEARN.md seed
- [ ] Each skill follows `docs/extending/create-skill.md` v3.0.0 specification
- [ ] **All skills use `$JAAN_*` environment variables (zero hardcoded paths)**
- [ ] **Tech-aware skills integrate with `$JAAN_CONTEXT_DIR/tech.md`**
- [ ] **All skills pass `/jaan-to:skill-update` v3.0.0 validation (7 checks)**
- [ ] Documentation in docs/skills/{role}/
- [ ] Registered in jaan-to/context/config.md
- [ ] Tested with sample inputs in v3.0.0 environment
- [ ] Roles covered: PM, DEV, QA, DATA, GROWTH, UX, SEC, DELIVERY, SRE, SUPPORT, RELEASE, DETECT

## Domain-Specific Catalogs

| Domain | Skills | File |
|--------|--------|------|
| WordPress Plugin Development | 25 | [roles-wp-skills.md](roles-wp-skills.md) |

## Dependencies

- MCP connectors required for many skills (Phase 3 infrastructure)
- Quick win skills can be built without MCPs

## Priority Order (by research rank)

1. `/jaan-to:qa-test-cases` - Rank #1
2. `/jaan-to:data-sql-query` - Rank #2
3. `/jaan-to:pm-story-write` - Rank #6
4. `/jaan-to:ux-research-synthesize` - Rank #8
5. `/jaan-to:qa-bug-report` - Rank #10
6. `/jaan-to-growth-meta-write` - Rank #12
7. `/jaan-to:dev-docs-generate` - Rank #14
8. `/jaan-to:pm-feedback-synthesize` - Rank #15
9. `/jaan-to:ux-persona-create` - Rank #16
10. `/jaan-to-growth-content-optimize` - Rank #18
11. `/jaan-to:data-dbt-model` - Rank #19
12. `/jaan-to:data-cohort-analyze` - (supports funnel analysis)
