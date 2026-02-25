# pm-roadmap Reference

> Extracted reference material for `pm-roadmap-add` and `pm-roadmap-update` skills.
> Contains prioritization system details, report templates, and quality checklists.
> This file is extracted from SKILL.md files for token optimization.

---

## Prioritization System Details

### Value-Effort Matrix

**How it works**: Plot items on a 2D grid with Value (Y-axis) and Effort (X-axis).

| Quadrant | Value | Effort | Action | Priority Order |
|----------|-------|--------|--------|----------------|
| Quick Win | High | Low | Do first | 1st |
| Strategic Bet | High | High | Plan carefully | 2nd |
| Fill-In | Low | Low | Do if capacity allows | 3rd |
| Time Sink | Low | High | Avoid or defer | 4th |

**Scoring criteria:**
- **Value**: Business impact, customer demand, strategic alignment, revenue potential
- **Effort**: Development time, complexity, dependencies, risk

**Best for**: Initial roadmap sketching, stakeholder alignment, small/early teams.

### MoSCoW Method

**How it works**: Categorize each item into one of four buckets.

| Category | Criteria | Questions to Ask |
|----------|----------|------------------|
| Must-Have | Product fails or is unusable without it | "Will the product work without this?" If no → Must |
| Should-Have | Important but product works without it | "Will users be significantly impacted?" If yes → Should |
| Could-Have | Desirable improvement, nice to have | "Would users notice if this was missing?" If maybe → Could |
| Won't-Have | Explicitly excluded from current scope | "Can this wait for the next cycle?" If yes → Won't |

**Distribution guideline**: ~60% Must, ~20% Should, ~20% Could (by effort).

**Best for**: Fixed-deadline projects, scope control, preventing scope creep.

### RICE Scoring Model

**Formula**: `RICE Score = (Reach × Impact × Confidence) ÷ Effort`

| Factor | Description | Scale |
|--------|-------------|-------|
| Reach | How many users/events per period | Number (e.g., 500 users/month) |
| Impact | How much each user is affected | Massive=3, High=2, Medium=1, Low=0.5, Minimal=0.25 |
| Confidence | How sure are we about estimates | High=100%, Medium=80%, Low=50% |
| Effort | Person-weeks to complete | Number (e.g., 4 person-weeks) |

**Example**: Reach=500, Impact=2, Confidence=80%, Effort=4 → Score = (500 × 2 × 0.8) ÷ 4 = 200

**Best for**: Data-driven organizations, large backlogs, comparing diverse initiatives.

---

## Review Report Template

```
ROADMAP REVIEW
──────────────
Date: {YYYY-MM-DD}
Roadmap: {path}

STATUS SUMMARY
──────────────
Total: {n} items
To Do: {n} | In Progress: {n} | Done: {n} | Blocked: {n}

FINDINGS ({n} total)
────────────────────

Completion Candidates:
  {item} — evidence: {PRD/story exists, deps met}

Stale Items:
  {item} — last activity: {date}, status: {status}

Past-Due Items:
  {item} — target: {date}, current status: {status}

Blocked Items:
  {item} — blocked by: {dependency} (status: {dep_status})

Missing from Roadmap:
  {PRD/story title} — source: {path}

SUGGESTED ACTIONS ({n})
───────────────────────
1. {action description}
2. {action description}
```

---

## Reprioritization Report Template

```
REPRIORITIZATION ANALYSIS
─────────────────────────
Date: {YYYY-MM-DD}
System: {Value-Effort | MoSCoW | RICE}

CONTEXT CHANGES
───────────────
- {what changed since last prioritization}

PRIORITY CHANGES ({n} items)
────────────────────────────
{item}: {current} → {suggested} — reason: {why}
{item}: {current} → {suggested} — reason: {why}

UNCHANGED ({n} items)
─────────────────────
{items with no change needed}
```

---

## Validation Report Template

```
ROADMAP VALIDATION
──────────────────
Date: {YYYY-MM-DD}

RESULTS
───────
Completeness: {PASS|FAIL} ({n} issues)
Consistency:  {PASS|FAIL} ({n} issues)
Dependencies: {PASS|FAIL} ({n} issues)
Staleness:    {PASS|FAIL} ({n} issues)

ISSUES ({n} total)
──────────────────
[HIGH]   {description} — fix: {proposed fix}
[MEDIUM] {description} — fix: {proposed fix}
[LOW]    {description} — fix: {proposed fix}

Auto-fixable: {n}
Manual review: {n}
```

---

## Quality Checklists

### Roadmap Item Quality (pm-roadmap-add)

Before writing a roadmap item, verify:
- [ ] Has clear, concise title (≤100 characters)
- [ ] Has description explaining what and why (≤500 characters)
- [ ] Has priority assigned using chosen framework
- [ ] Has status set (default: To Do)
- [ ] Has target timeframe (Now/Next/Later or date)
- [ ] Dependencies listed (or "None")
- [ ] No duplicate of existing item (keyword check passed)

### Roadmap Document Quality (pm-roadmap-add bootstrap)

Before writing a new roadmap document, verify:
- [ ] Has Vision section
- [ ] Has Prioritization System with legend
- [ ] Has Roadmap Items section with at least one item
- [ ] Has Completed Items section (even if empty)
- [ ] Has Metadata section with creation date

### Update Quality (pm-roadmap-update)

Before writing updates, verify:
- [ ] Changes match what was approved at HARD STOP
- [ ] Metadata (last updated date, status counts) updated
- [ ] No unintended changes to other items
- [ ] File structure preserved (sections not reordered)

---

## Error Handling

| Error | Message | Resolution |
|-------|---------|------------|
| No roadmap found | "No roadmap found. Create one with `/pm-roadmap-add`" | Redirect to add skill |
| Item not found (mark mode) | "Item not found. Available items: {list}" | Show available items |
| Duplicate detected | "Similar item exists: '{item}'. Proceed / Merge / Cancel" | User chooses |
| Empty input | "No item description. Usage: `/pm-roadmap-add Add user auth`" | Show usage |
| Description too long | "Description exceeds 500 characters. Please shorten or split into multiple items" | Ask to shorten |
| Secret detected in content | "BLOCKED: Content contains potential credentials. Remove before writing" | Block write |
