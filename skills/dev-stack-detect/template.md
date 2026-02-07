# Stack Detection Report

> Generated: {{date}}
> Project: {{project_name}}
> Overall Confidence: {{confidence_score}}%

---

## Detection Summary

| Category | Detected | Confidence |
|----------|----------|------------|
| Backend | {{backend_summary}} | {{backend_confidence}}% |
| Frontend | {{frontend_summary}} | {{frontend_confidence}}% |
| Database | {{database_summary}} | {{database_confidence}}% |
| Infrastructure | {{infra_summary}} | {{infra_confidence}}% |
| CI/CD | {{cicd_summary}} | {{cicd_confidence}}% |
| Source Control | {{source_control_summary}} | {{source_control_confidence}}% |
| Monorepo | {{monorepo_summary}} | {{monorepo_confidence}}% |

---

## High Confidence Detections (95-100%)

{{high_confidence_items}}

## Medium Confidence Detections (80-95%)

{{medium_confidence_items}}

## Low Confidence Detections (60-80%)

{{low_confidence_items}}

---

## Context File Updates Applied

### tech.md
{{tech_updates}}

### integrations.md
{{integrations_updates}}

### boundaries.md
{{boundaries_updates}}

### config.md
{{config_updates}}

---

## Detection Sources

| Source File | Detections Found |
|------------|-----------------|
{{source_files_table}}

---

## Manual Review Required

These sections cannot be auto-detected and need manual input:

- [ ] Technical Constraints (compliance, latency, architecture decisions)
- [ ] Common Patterns (auth, error handling, data access conventions)
- [ ] Versioning & Deprecation policies
- [ ] Tech Debt items
- [ ] Issue Tracking tool configuration
- [ ] Communication channels
- [ ] Analytics tools
- [ ] Design tools
- [ ] Team structure (team.md)

---

**Skill**: dev:stack-detect
**Merge Mode**: {{merge_mode}}
**Files Updated**: {{files_updated}}
