# Roadmap Review Report

> Generated: {YYYY-MM-DD}
> Mode: {review | mark | reprioritize | validate}
> Roadmap: {roadmap_path}

---

## Review Report Template

### Summary

| Metric | Count |
|--------|-------|
| Total Items | {n} |
| To Do | {n} |
| In Progress | {n} |
| Done | {n} |
| Blocked | {n} |
| Findings | {n} |

### Completion Candidates

Items with evidence of completion (related PRDs/stories exist, dependencies met):

| # | Item | Evidence | Suggested Action |
|---|------|----------|------------------|
| 1 | {item} | {evidence} | Mark as Done |

### Stale Items

Items with no evidence of progress:

| # | Item | Status | Last Activity | Suggested Action |
|---|------|--------|---------------|------------------|
| 1 | {item} | {status} | {date or "Unknown"} | {Review / Deprioritize / Remove} |

### Past-Due Items

Items with target timeframe in the past:

| # | Item | Target | Current Status | Suggested Action |
|---|------|--------|----------------|------------------|
| 1 | {item} | {target} | {status} | {Reschedule / Complete / Remove} |

### Blocked Items

Items blocked by incomplete dependencies:

| # | Item | Blocked By | Blocker Status |
|---|------|------------|----------------|
| 1 | {item} | {dependency} | {dep_status} |

### Missing from Roadmap

PRDs or stories that exist but have no corresponding roadmap item:

| # | Source | Title | Suggested Action |
|---|--------|-------|------------------|
| 1 | {PRD/Story} | {title} | Add to roadmap |

---

## Reprioritization Report Template

### Priority Changes

| # | Item | Current Priority | Suggested Priority | Reason |
|---|------|-----------------|-------------------|--------|
| 1 | {item} | {current} | {suggested} | {reason for change} |

### Context Changes

- {what changed in the project context that affects priorities}

---

## Validation Report Template

### Results

| Check | Status | Count |
|-------|--------|-------|
| Completeness | {Pass/Fail} | {n} issues |
| Consistency | {Pass/Fail} | {n} issues |
| Dependencies | {Pass/Fail} | {n} issues |
| Staleness | {Pass/Fail} | {n} issues |

### Issues Found

| # | Severity | Category | Description | Fix |
|---|----------|----------|-------------|-----|
| 1 | {High/Medium/Low} | {category} | {description} | {proposed fix} |

### Summary

- **Total Issues**: {n}
- **Auto-fixable**: {n}
- **Manual Review Needed**: {n}
