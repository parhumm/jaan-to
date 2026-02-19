# ux-research-synthesize — Reference Material

> Extracted from `skills/ux-research-synthesize/SKILL.md` for token optimization.
> Contains scoring rubrics, format specifications, lookup tables, and checklists.

---

## Nielsen Severity Framework (0-4 Scale)

Rate severity for each theme:

| Rating | Level | Description |
|--------|-------|-------------|
| 0 | Not a usability problem | No action needed |
| 1 | Cosmetic problem only | Fix if time permits |
| 2 | Minor usability problem | Low priority |
| 3 | Major usability problem | High priority |
| 4 | Usability catastrophe | Fix before release |

---

## Priority Score Calculation

- **Frequency**: `(Participants encountering issue / Total participants) x 100`
- **Impact**: Severity rating (0-4)
- **Priority Score**: `Severity x Frequency`

---

## Impact x Effort Matrix

### Effort Estimation Scale

| Effort Level | Description |
|--------------|-------------|
| Low | 1-2 sprints, minimal resources |
| Medium | 1-2 months, small team |
| High | 3-6+ months, cross-functional effort |

### Quadrant Definitions

| Quadrant | Impact | Effort | Action |
|----------|--------|--------|--------|
| **Quick Wins** | High | Low | Do first |
| **Big Bets** | High | High | Plan carefully |
| **Fill-Ins** | Low | Low | If time permits |
| **Money Pits** | Low | High | Avoid |

---

## Draft Recommendation Template

Use the following structure for generating recommendations:

**Format**: `[Action Verb] + [Specific Element] + [To Achieve Outcome] + [Because Evidence]`

**Example**:
> "Redesign the settings menu with clearer labeling and top-level placement to reduce support tickets by 20% because 80% of new admins couldn't locate settings without assistance (Theme 2, P1, P4, P7, P9)."

---

## Synthesis Mode Descriptions

### [1] Speed (1-2 hours)
- Top findings from 3-5 sessions
- Critical issues only
- Bullet-format output
- Best for: Quick usability tests with clear tasks

### [2] Standard (1-2 days) — Recommended
- Full 6-phase thematic analysis
- 3-8 themes with evidence
- Audience-tailored report
- Best for: Interview studies, exploratory research

### [3] Cross-Study (meta-analysis)
- Aggregate themes across multiple studies
- Longitudinal tracking
- Strategic recommendations
- Best for: Research repositories, quarterly synthesis

---

## Research Question Templates

Common research question templates for participant clarification:

| # | Template |
|---|----------|
| 1 | What usability issues exist in [feature]? |
| 2 | How do users perceive [concept]? |
| 3 | What are user needs around [topic]? |
| 4 | What motivates users to [action]? |
| 5 | Custom - Let me write my own |

---

## Data Source Summary Format

Use this format when displaying identified data sources:

```
DATA SOURCES IDENTIFIED
════════════════════════════════════════
Study: {study_name}
Total files: {N}
  Transcripts: {n} files
  Notes: {n} files
  Surveys: {n} files
  Other: {n} files
════════════════════════════════════════
```

---

## Participant Coverage Matrix Format

Use this format to display participant coverage per theme:

```
PARTICIPANT COVERAGE
────────────────────────────────────────
Theme 1: {theme_name}
  Participants: {n} total (P1, P3, P4, P7, P9)
  Quotes: {n} quotes ({quotes_per_participant breakdown})

Theme 2: {theme_name}
  Participants: {n} total (P2, P5, P8, P10)
  Quotes: {n} quotes
  ⚠️ P5 contributed 40% of quotes - validate representativeness

Theme 3: {theme_name}
  Participants: {n} total (P1, P2, P4, P6, P8, P9)
  Quotes: {n} quotes
────────────────────────────────────────

Coverage quality: {Balanced | ⚠️ Imbalanced}
```

### Imbalanced Coverage Handling

If any theme has imbalanced coverage (>25% from single participant), present:

> "Theme {N} quotes are dominated by P{X}. Options:
> [1] Find more evidence from other participants
> [2] Reframe as edge case instead of theme
> [3] Discard this theme
> Choose: [1/2/3]"

---

## Methodology Note Structure

Brief overview (5-7 sentences) covering:
- Research type (interviews, usability tests, surveys)
- Participant count and recruitment method
- Analysis approach (Braun & Clarke 6-phase, Atomic Research, hybrid)
- Synthesis mode used (Speed/Standard/Cross-Study)
- **Limitations** (one-line list):
  - Sample size constraints
  - What was NOT analyzable and why
  - Confidence caveats
  - Scope limitations

### Appendix Sections (Standard+ mode only)

Optional sections to include:
- **Participant Profiles**: Demographics, segments represented
- **Codebook Summary**: Top 20 codes with definitions
- **Methodology Details**: Full Braun & Clarke 6-phase process walkthrough

---

## Definition of Done Checklist

- [ ] Study name and data sources collected
- [ ] Synthesis mode selected (Speed/Standard/Cross-Study)
- [ ] Research questions clarified (1-3 max)
- [ ] All data sources read and validated
- [ ] Initial coding completed (30-40 codes max)
- [ ] Themes developed (3-8 themes optimal)
- [ ] Evidence linked to themes (2-3+ quotes per theme)
- [ ] Participant coverage validated (balanced across participants)
- [ ] Prioritization completed (Nielsen severity × frequency)
- [ ] Recommendations generated (INSIGHT/SO WHAT/NOW WHAT)
- [ ] Quality checks passed (14-point checklist)
- [ ] Main synthesis report written with Executive Summary
- [ ] Executive brief written (1-page standalone)
- [ ] Index updated with add_to_index()
- [ ] User approved final result
