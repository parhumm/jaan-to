---
title: "WP Role Skills Catalog"
sidebar_position: 10
---

# WP Role Skills Catalog

> Phase 4 (Quick Wins) + Phase 6 (Advanced) | Status: pending | 25 skills across 5 WP roles

## Overview

WordPress-specific skills for plugin development. These skills extend generic role skills with WordPress conventions, APIs, and ecosystem requirements.

Skills are split by effort:
- **Phase 4**: Quick Win skills — No MCP required, ordered by workflow dependency
- **Phase 6**: Advanced skills — Require deeper WP integration or external tooling

Skills within each role are **sorted by workflow dependency order** (topological). Skills you call first in a workflow appear first.

**Research source**: [54-roles-wp-details.md](docs/research/58-role-wp-dev.md) — WordPress Plugin Development: Complete Role-Based Skills Guide

## v3.0.0 Implementation Requirements

**All 25 skills MUST use v3.0.0 patterns when implemented:**

### Paths (Environment Variables)
- **Outputs**: `$JAAN_OUTPUTS_DIR/wp/{role}/{domain}/{id}-{slug}/`
- **Templates**: `$JAAN_TEMPLATES_DIR/{skill-name}.template.md`
- **Learning**: `$JAAN_LEARN_DIR/{skill-name}.learn.md`
- **Context**: `$JAAN_CONTEXT_DIR/*.md`

❌ **Never** use hardcoded `jaan-to/` paths

### Creation
- Use `/jaan-to:skill-create {skill-name}` (generates v3.0.0-compliant skills)
- Follow [docs/extending/create-skill.md](../../extending/create-skill.md)
- Validate with `/jaan-to:skill-update {skill-name}` before committing

---

## Roles

| Role | Skills | Quick Wins | File |
|------|--------|------------|------|
| WP-PM | 3 | 3 | [wp-pm.md](role-wp-skills/wp-pm.md) |
| WP-DEV | 11 | 9 | [wp-dev.md](role-wp-skills/wp-dev.md) |
| WP-SEC | 5 | 4 | [wp-sec.md](role-wp-skills/wp-sec.md) |
| WP-RELEASE | 4 | 3 | [wp-release.md](role-wp-skills/wp-release.md) |
| WP-QA | 2 | 2 | [wp-qa.md](role-wp-skills/wp-qa.md) |

---

## Cross-Role Workflow Chain

```
PM (problem-brief → slug → guideline-scan)
  → DEV (architecture → hooks → data → settings → uninstall → admin → assets → block/rest → cron → cache)
    → SEC (capability → nonce → escaping → db-safety → privacy)
      → QA (compat-matrix)
        → RELEASE (coding-standards → readme → assets → svn-release)
          → QA (support-triage)
            → PM (problem-brief) [feedback loop]
```

Key dependency flows:

- **Discovery → Build**: WP-PM (problem-brief → slug → guideline-scan) → WP-DEV (architecture → hooks → data)
- **Build → Secure**: WP-DEV (rest-endpoint → uninstall) → WP-SEC (capability → nonce → escaping → db-safety)
- **Secure → Ship**: WP-SEC (privacy-eraser) → WP-RELEASE (coding-standards → readme → assets → svn-release)
- **Ship → Support**: WP-RELEASE (svn-release) → WP-QA (triage-rules)
- **Feedback Loop**: WP-QA (triage-rules) → WP-PM (problem-brief)

---

## Relationship to Generic Role Skills

WP skills are WordPress-specific specializations. They do NOT duplicate generic skills — they add WordPress conventions on top of generic patterns.

### HIGH Overlap (3 skills — cross-referenced, not duplicated)

| WP Skill | Generic Skill | Relationship |
|----------|---------------|-------------|
| `wp-pm-problem-brief` | `pm-problem-statement` | WP narrows to plugin surface (admin/front/editor) + interop risks |
| `wp-rest-endpoint-spec` | `backend-api-contract` | WP uses `register_rest_route()` patterns + permission callbacks |
| `wp-support-triage-rules` | `support-triage-priority` | WP adds WP/PHP env diagnostics + plugin conflict isolation steps |

### MEDIUM Overlap (6 skills — justified by WP-specific conventions)

| WP Skill | Generic Skill | WP-Specific Addition |
|----------|---------------|---------------------|
| `wp-dev-architecture-map` | `dev-arch-proposal` | Action/filter design + collision prevention |
| `wp-hooks-feature-hook-map` | `dev-integration-plan` | WP hook timing, priorities, recursion risks |
| `wp-data-storage-decision` | `backend-data-model` | Options vs meta vs CPT vs custom tables + multisite scope |
| `wp-admin-menu-ia` | `ux-sitemap` | WP admin menu conventions + capability gating |
| `wp-sec-capability-map` | `sec-threat-model-lite` | WP capabilities system + meta-capabilities |
| `wp-qa-compat-matrix` | `qa-test-matrix` | WP/PHP version targets + plugin/theme conflict testing |

### NO Overlap (10 skills — purely WP-specific)

`wp-pm-slug-textdomain`, `wp-org-guideline-scan`, `wp-dev-uninstall-policy`, `wp-sec-nonce-plan`, `wp-sec-escaping-checklist`, `wp-perf-transients-cache-plan`, `wp-cron-job-plan`, `wp-release-coding-standards`, `wp-org-readme-draft`, `wp-org-assets-plan`, `wp-org-svn-release-plan`

### LOW Overlap (6 skills — minor generic overlap)

`wp-settings-settings-api-plan`, `wp-assets-enqueue-plan`, `wp-block-block-json-spec`, `wp-sec-db-safety-plan`, `wp-org-svn-release-plan`, `wp-privacy-eraser-exporter-plan`

---

## Acceptance Criteria

- [ ] All 25 skills created with SKILL.md + LEARN.md seed
- [ ] Each skill follows `docs/extending/create-skill.md` v3.0.0 specification
- [ ] **All skills use `$JAAN_*` environment variables (zero hardcoded paths)**
- [ ] **Cross-ref fields link to generic skills where overlap exists**
- [ ] **All skills pass `/jaan-to:skill-update` v3.0.0 validation (7 checks)**
- [ ] Documentation in docs/skills/wp/
- [ ] Tested with sample inputs in v3.0.0 environment
- [ ] Roles covered: WP-PM, WP-DEV, WP-SEC, WP-RELEASE, WP-QA

## Dependencies

- Generic [Role Skills Catalog](role-skills.md) skills should exist first for cross-references
- Quick win skills can be built without MCPs
