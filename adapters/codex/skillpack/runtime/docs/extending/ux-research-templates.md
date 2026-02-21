# UX Research Synthesis — Templates & Reference

> Reference material for `ux-research-synthesize` skill.
> This file contains format specifications, templates, and checklists extracted from SKILL.md for token optimization.

---

## Theme Card Structure

Use this structure for each theme in the Key Findings section (ordered by Priority Score descending):

```markdown
### {Priority Badge} {Interpretive Theme Name}

**Insight**: {WHY this matters — business impact, user need, strategic implication}

**Evidence**:
- "{Quote 1}" — P{ID}, {context}, {source tag}
- "{Quote 2}" — P{ID}, {context}, {source tag}
- "{Quote 3}" — P{ID}, {context}, {source tag}

**Participant Coverage**: {n} participants ({participant_ids})

| Metric | Value |
|--------|-------|
| Severity | {Nielsen 0-4} ({frequency}% x {impact description} x {persistence: one-time/repeated}) |
| Confidence | {High/Medium/Low} |
| Validation | {Corroborated/Single-source} |
```

### Priority Badges

| Badge | Criteria |
|-------|----------|
| Red CRITICAL | Severity 4, High Frequency |
| Orange HIGH | Severity 3+, Medium+ Frequency |
| Yellow MEDIUM | Severity 2, any Frequency |
| Green LOW | Severity 0-1 |

---

## Recommendation Format (Problem-Solution)

Use this structure for each theme with actionable recommendation:

```markdown
### {Priority Badge} {Recommendation Title}

**INSIGHT**: {User problem discovered from theme}

**SO WHAT**: {Why this matters to business — ROI, user impact, strategic value}

**NOW WHAT**: {Specific, implementable action — 1-2 sentences max}

**SUCCESS METRIC**: {How to measure improvement — concrete KPI}

| Metric | Value |
|--------|-------|
| Priority | {Must-have / Need / Nice} |
| Effort | {Low / Medium / High} |
| Impact/Effort | {Quick Win / Big Bet / Fill-In / Money Pit} |
| Theme | {Link to theme number} |
```

---

## Executive Brief Format

Auto-generated 1-page standalone summary from main report. Maximum ~300-400 words, no methodology details, no raw data, no jargon, standalone (reader needs no other context).

```markdown
# {Study Name} — Executive Brief

> "{Powerful user quote from most impactful finding}"

## Highlights

- {What's working well — finding 1}
- {What's working well — finding 2}

## Lowlights

1. **{Issue 1 title}** — {Impact description}
2. **{Issue 2 title}** — {Impact description}
3. **{Issue 3 title}** — {Impact description}

## Next Steps

- **{Action 1}** — {Expected impact} — {Timeline: Quick Win/Big Bet}
- **{Action 2}** — {Expected impact} — {Timeline}
- **{Action 3}** — {Expected impact} — {Timeline}

---

| Priority | Count |
|----------|-------|
| Critical | {n} findings |
| High | {n} findings |
| Medium | {n} findings |

Full report: `{path_to_main_file}`
```

---

## Quality Checklist (Pre-Write Validation)

Verify every item before preview. If any check fails, revise report before preview.

### Executive Summary
- [ ] Executive Summary <= 1 page and stands alone
- [ ] Opens with powerful user quote (emotionally resonant)
- [ ] Has highlights (what's working) AND lowlights (issues)
- [ ] Has clear next steps (actionable bullets)

### Themes
- [ ] Every theme has interpretive name (not just topic label)
- [ ] Every theme has "Insight" explaining WHY (not just WHAT observed)
- [ ] Every theme has 2-3+ quotes from different participants
- [ ] Every theme has participant coverage noted (IDs listed)
- [ ] Theme count: 3-8 (flag if outside optimal range)

### Recommendations
- [ ] Every recommendation has concrete action (not vague "improve UX")
- [ ] Every recommendation links to specific finding/theme
- [ ] Recommendations include priority + effort estimates
- [ ] Recommendations include Impact/Effort quadrant classification
- [ ] Every recommendation has "INSIGHT/SO WHAT/NOW WHAT" structure
- [ ] Every recommendation has success metric (how to measure)

### Evidence & Traceability
- [ ] All research questions have corresponding findings
- [ ] Participant coverage balanced (no single participant >25% of evidence)
- [ ] Every claim traces to verbatim quote with participant ID
- [ ] Participant IDs are consistent throughout (P1-P{N})
- [ ] Quotes include context (task, timing, source tag)

### Methodology & Limitations
- [ ] Methodology note states analysis approach clearly
- [ ] Limitations stated clearly (sample size, scope, confidence caveats)
- [ ] No hallucinated findings (all claims sourced from data)

### Cross-Study Mode Only
- [ ] Temporal validity checked (when were studies conducted)
- [ ] Methodology consistency noted across studies
- [ ] Contradictory findings across studies are flagged and explained
