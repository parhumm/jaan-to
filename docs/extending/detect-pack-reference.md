# detect-pack Reference Material

> Extracted reference tables, format specifications, consolidation logic templates, and scoring details for the `detect-pack` skill.
> This file is loaded by `detect-pack` SKILL.md via inline pointers.

---

## Evidence Index Table Format

The evidence index (source map) uses this table structure:

```markdown
| Evidence ID | Platform | Domain | File | Location | Type | Confidence |
|-------------|----------|--------|------|----------|------|------------|
| E-DEV-001   | all      | dev    | src/auth/login.py | L42-58 | code-location | Confirmed |
| E-DEV-WEB-001 | web    | dev    | web/src/auth/login.py | L42-58 | code-location | Confirmed |
| E-DSN-MOBILE-001a | mobile | design | mobile/src/tokens/colors.json | L15 | token-definition | Firm |
| ...         | ...      | ...    | ...  | ...      | ...  | ...        |
```

---

## Evidence ID Parsing

Handle both legacy and multi-platform formats:

```python
import re

# Regex pattern: E-{DOMAIN}-({PLATFORM}-)?{NUMBER}
evidence_id_pattern = r'^E-([A-Z]+)-(([A-Z]+)-)?(\d{3}[a-z]?)$'

# Examples:
#   E-DEV-001        → groups: ('DEV', None, None, '001')
#   E-DEV-WEB-001    → groups: ('DEV', 'WEB-', 'WEB', '001')
#   E-DSN-001a       → groups: ('DSN', None, None, '001a')  # Drift finding with suffix

# Parsing logic:
match = re.match(evidence_id_pattern, evidence_id)
if match:
  domain = match.group(1)          # DEV, DSN, WRT, PRD, UX
  platform = match.group(3) or 'all'  # WEB, BACKEND, MOBILE, or 'all' for legacy
  sequence = match.group(4)        # 001, 002, 001a, etc.
```

---

## Evidence Validation Rules

- No duplicate evidence IDs (flag if found)
- All IDs follow namespace convention (E-{DOMAIN}-NNN or E-{DOMAIN}-{PLATFORM}-NNN)
- Domain codes valid: DEV, DSN, WRT, PRD, UX
- Platform names match detected platforms from Step 0
- All IDs resolve to actual file locations

---

## Cross-Platform Evidence Linking

For findings with `related_evidence` field, track bidirectional links:

```python
# Build evidence graph
evidence_links = {}
for evidence_id, evidence in all_evidence.items():
  if evidence.get('related_evidence'):
    for related_id in evidence['related_evidence']:
      if evidence_id not in evidence_links:
        evidence_links[evidence_id] = set()
      evidence_links[evidence_id].add(related_id)

# Identify cross-platform finding groups
cross_platform_groups = find_connected_components(evidence_links)
# Example: [{E-DEV-WEB-042, E-DEV-BACKEND-038}, ...] = same issue in web + backend
```

---

## Per-Platform Aggregation Logic

For each detected platform, aggregate findings across all domains:

```python
platform_findings = {}
for platform in platforms:
  findings_summary = {
    'critical': 0, 'high': 0, 'medium': 0, 'low': 0, 'informational': 0
  }

  # Read all domain outputs for this platform
  for domain in ['dev', 'design', 'writing', 'product', 'ux']:
    for aspect in DOMAIN_ASPECTS[domain]:  # e.g., dev → [stack, architecture, ...]
      # Try platform-specific file first
      file_path = f"$JAAN_OUTPUTS_DIR/detect/{domain}/{aspect}-{platform}.md"
      if file_exists(file_path):
        frontmatter = parse_frontmatter(file_path)
        # Aggregate severity counts
        for severity in ['critical', 'high', 'medium', 'low', 'informational']:
          findings_summary[severity] += frontmatter['findings_summary'][severity]

  # Calculate overall score for this platform
  total_findings = sum(findings_summary.values())
  overall_score = 10 - (
    findings_summary['critical'] * 2.0 +
    findings_summary['high'] * 1.0 +
    findings_summary['medium'] * 0.4 +
    findings_summary['low'] * 0.1
  ) / max(total_findings, 1)

  platform_findings[platform] = {
    'summary': findings_summary,
    'score': overall_score
  }
```

---

## Cross-Platform Risk Heatmap Logic

```python
heatmap_table = []
for platform, data in platform_findings.items():
  row = {
    'platform': platform,
    'dev': format_severity(get_domain_findings(platform, 'dev')),
    'design': format_severity(get_domain_findings(platform, 'design')),
    'writing': format_severity(get_domain_findings(platform, 'writing')),
    'product': format_severity(get_domain_findings(platform, 'product')),
    'ux': format_severity(get_domain_findings(platform, 'ux')),
    'score': data['score']
  }
  heatmap_table.append(row)

# Add totals row
totals = aggregate_all_platforms(platform_findings)
heatmap_table.append({'platform': 'TOTAL', ...totals})
```

**Example cross-platform heatmap:**

| Platform | Dev | Design | Writing | Product | UX | Score |
|----------|-----|--------|---------|---------|-----|-------|
| web      | C:2 H:5 M:8 | C:0 H:2 M:4 | C:0 H:1 M:3 | C:0 H:2 M:5 | C:1 H:3 M:6 | 7.2 |
| backend  | C:1 H:3 M:6 | - | C:0 H:0 M:2 | C:0 H:1 M:4 | - | 8.1 |
| mobile   | C:0 H:4 M:7 | C:0 H:3 M:5 | C:0 H:2 M:4 | C:0 H:2 M:6 | C:0 H:2 M:5 | 7.8 |
| **Total**| **3 12 21** | **5 9** | **3 7** | **4 15** | **1 5 11** | **7.7** |

---

## Cross-Platform Findings Extraction

```python
# Extract findings with related_evidence (cross-platform links)
cross_platform_findings = []
for platform in platforms:
  for domain in ['dev', 'design', 'writing', 'product', 'ux']:
    findings = extract_findings_with_related_evidence(platform, domain)
    for finding in findings:
      if finding.get('related_evidence'):  # Has cross-platform links
        cross_platform_findings.append(finding)
```

---

## Cross-Platform Deduplication Logic

```python
deduplicated = []
seen_groups = set()

for finding in cross_platform_findings:
  # Create canonical group ID from related_evidence chain
  group_id = frozenset([finding['id']] + finding['related_evidence'])

  if group_id not in seen_groups:
    seen_groups.add(group_id)

    # Collect all platforms affected
    affected_platforms = []
    for evidence_id in group_id:
      # Extract platform from evidence ID: E-DEV-WEB-001 → 'web'
      match = re.match(r'E-[A-Z]+-([A-Z]+)-\d+', evidence_id)
      if match:
        affected_platforms.append(match.group(1).lower())
      else:
        affected_platforms.append('all')  # Legacy format

    deduplicated.append({
      'title': finding['title'],
      'severity': max_severity([get_finding_by_id(eid)['severity'] for eid in group_id]),
      'platforms': list(set(affected_platforms)),
      'evidence_ids': list(group_id),
      'description': finding['description']
    })
```

**Store consolidated data** for use in Step 8 (Writing phase):
- `platform_findings`: per-platform aggregates
- `heatmap_table`: cross-platform risk table
- `deduplicated`: cross-platform findings with deduplication

---

## README.md Structure (Single-Platform)

```markdown
# Knowledge Index: {repo-name}

> Generated by jaan.to detect-pack | {date}

## Overview

- **Domains analyzed**: {n}/5
- **Overall score**: {score}/10
- **Total findings**: {n}
- **Evidence items**: {n}

## Domain Summaries

### Dev — {score}/10
{executive summary from dev outputs}

### Design — {score}/10
{executive summary from design outputs}

### Writing — {score}/10
{executive summary from writing outputs}

### Product — {score}/10
{executive summary from product outputs}

### UX — {score}/10
{executive summary from ux outputs}

## Quick Links
- [Risk Heatmap](risk-heatmap.md)
- [Unknowns Backlog](unknowns-backlog.md)
- [Source Map](source-map.md)
- [Dev Audit](dev/)
- [Design Audit](design/)
- [Writing Audit](writing/)
- [Product Audit](product/)
- [UX Audit](ux/)
```

---

## README.md Structure (Multi-Platform Merged Pack)

```markdown
# Knowledge Index: {repo-name} (All Platforms)

> Generated by jaan.to detect-pack | {date}

## Overview

- **Mode**: Multi-Platform
- **Platforms analyzed**: {n} ({list})
- **Domains analyzed**: {n}/5
- **Overall score**: {weighted_avg_score}/10
- **Total findings**: {n} (across all platforms)
- **Evidence items**: {n}

## Platform Summary

| Platform | Score | Domains | Critical | High | Medium | Low | Info |
|----------|-------|---------|----------|------|--------|-----|------|
| web      | 7.2   | 5/5     | 2        | 12   | 25     | 8   | 3    |
| backend  | 8.1   | 3/5     | 1        | 5    | 15     | 3   | 2    |
| mobile   | 7.8   | 5/5     | 0        | 10   | 22     | 6   | 4    |
| **Total**| **7.7**| -      | **3**    | **27**| **62** | **17**| **9**|

## Cross-Platform Findings

{n} findings appear across multiple platforms:

1. **TypeScript Not Configured** (High) — Affects: web, backend
   - Evidence: E-DEV-WEB-042, E-DEV-BACKEND-038
   - Impact: Type safety missing in both frontend and backend

2. ... (list other cross-platform findings)

## Per-Platform Details

- [Web Platform Pack](README-web.md) — Score: 7.2/10
- [Backend Platform Pack](README-backend.md) — Score: 8.1/10
- [Mobile Platform Pack](README-mobile.md) — Score: 7.8/10

## Quick Links

- [Cross-Platform Risk Heatmap](risk-heatmap.md)
- [Unknowns Backlog (All Platforms)](unknowns-backlog.md)
- [Source Map (All Evidence IDs)](source-map.md)
```
