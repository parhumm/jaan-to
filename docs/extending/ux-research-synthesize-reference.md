# ux-research-synthesize — Reference Material

> Extracted from `skills/ux-research-synthesize/SKILL.md` for token optimization.
> Contains Nielsen severity framework, priority scoring, and impact-effort matrix.

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
