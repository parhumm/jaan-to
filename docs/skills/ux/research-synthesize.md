---
title: "ux-research-synthesize"
sidebar_position: 4
---

# /ux-research-synthesize

> Synthesize UX research findings into themed insights, executive summaries, and prioritized recommendations.

---

## What It Does

Transforms raw UX research data (interviews, usability tests, surveys) into actionable insights using validated methodologies. Supports three synthesis modes with different depth levels: Speed (1-2h quick findings), Standard (1-2d full thematic analysis), and Cross-Study (meta-analysis across multiple studies).

Implements Braun & Clarke's 6-phase thematic analysis, Atomic Research framework, and Nielsen severity ratings for prioritization.

---

## Usage

```
/ux-research-synthesize "{study-name}" {data-sources}
```

**Examples**:
```
/ux-research-synthesize "Mobile Checkout Study" transcripts/
/ux-research-synthesize "User Onboarding" interview1.txt interview2.txt interview3.txt
/ux-research-synthesize "Q1 Research Review"
```

---

## What It Asks

| Question | Why |
|----------|-----|
| Which synthesis mode? | Determines depth (Speed/Standard/Cross-Study) and deliverables |
| What are your research questions (1-3 max)? | Ensures themes tie back to objectives |
| Should themes be inductive/deductive/hybrid? | Clarifies analysis approach |
| Rate severity for each theme (Nielsen 0-4) | Prioritizes findings by impact |
| Estimate effort to address (Low/Medium/High)? | Classifies into Quick Wins, Big Bets, etc. |

---

## Synthesis Modes

| Mode | Time | Output | Best For |
|------|------|--------|----------|
| **Speed** | 1-2 hours | Top findings, bullet format | 3-5 usability tests with clear tasks |
| **Standard** | 1-2 days | Full thematic analysis, 3-8 themes | Interview studies, exploratory research |
| **Cross-Study** | Variable | Meta-analysis, longitudinal themes | Research repositories, quarterly synthesis |

---

## Output

**Path**: `jaan-to/outputs/ux/research/{id}-{slug}/`

**Files**:
- `{id}-synthesis-{slug}.md` - Full synthesis report with themes, evidence, recommendations
- `{id}-exec-brief-{slug}.md` - 1-page executive brief (standalone)

**Report Structure**:
1. **Executive Summary** (1 page max) - Powerful quote + highlights/lowlights + next steps
2. **Key Findings** - Themed cards with insight/evidence/severity/participant coverage
3. **Recommendations** - INSIGHT/SO WHAT/NOW WHAT format with priority/effort
4. **Methodology Note** - Brief analysis approach + limitations
5. **Appendix** (Standard+ mode) - Participant profiles, codebook, methodology details

---

## Workflow

**Phase 1: Analysis (AI-Assisted + Human Validation)**
1. Input collection & validation
2. Mode selection
3. Research questions clarification
4. Data familiarization (AI summary → human review)
5. Initial coding (AI generates 30-40 codes → human validates)
6. Theme development (AI clusters → human refines/names, 3-8 themes)
7. Evidence linking (2-3 quotes per theme, participant coverage check)
8. Prioritization (Nielsen severity × frequency, Impact/Effort matrix)

**Phase 2: Generation**
9. Generate ID and output paths
10. Generate main synthesis report
11. Generate executive brief (auto from main report)
12. Quality check (14-point validation)
13. Preview & approval
14. Write outputs + update index

---

## Quality Gates

Before writing, validates:
- [ ] Executive Summary ≤ 1 page and standalone
- [ ] Every theme has interpretive name (not topic label)
- [ ] Every theme has "Insight" explaining WHY (not just WHAT)
- [ ] Every theme has 2-3+ quotes from different participants
- [ ] Participant coverage balanced (no single >25%)
- [ ] Theme count 3-8 (optimal range)
- [ ] Every recommendation has concrete action
- [ ] All claims trace to verbatim quotes with participant IDs

---

## Example

**Input**:
```
/ux-research-synthesize "Mobile Checkout Study" interviews/
```

**Process**:
- Mode: Standard (1-2 days)
- Research questions: "What prevents users from completing checkout?"
- 8 interview transcripts analyzed
- 35 initial codes generated
- 5 themes identified with 80% participant coverage
- 12 prioritized recommendations (4 Quick Wins, 3 Big Bets)

**Output**:
- `jaan-to/outputs/ux/research/01-mobile-checkout-study/01-synthesis-mobile-checkout-study.md` (115 lines)
- `jaan-to/outputs/ux/research/01-mobile-checkout-study/01-exec-brief-mobile-checkout-study.md` (1 page)

**Top Finding** (example):
> Theme: "Users Abandon When Progress Is Invisible"
> Insight: Lack of checkout progress indicators causes 40% drop-off at payment step
> Recommendation: Add 3-step progress bar → Expected 15-20% reduction in abandonment
> Priority: CRITICAL (Severity 4, 67% frequency)
> Quadrant: Quick Win (High Impact, Low Effort)

---

## Tips

- **Use Standard mode** for most research - Speed is only for quick usability tests with <5 sessions
- **Define research questions upfront** - Every theme must tie back to objectives
- **Let AI generate initial codes** - But always validate and refine manually
- **Rename themes to be interpretive** - "Users Navigate by Trial and Error" not "Navigation Issues"
- **Balance participant coverage** - If one person dominates quotes (>25%), find more evidence or discard theme
- **Auto-generated exec brief** - Main report's highlights/lowlights are extracted automatically
- **Track traceability** - Every claim must link to verbatim quote with participant ID

---

## Methodologies Used

- **Braun & Clarke's Six-Phase Thematic Analysis** - Familiarization, coding, theme development, review, definition, reporting
- **Atomic Research Framework** (Pidcock/Sharon) - Experiments → Facts → Insights → Recommendations
- **Nielsen Severity Ratings** - 0-4 scale for prioritization (frequency × impact × persistence)
- **Impact × Effort Matrix** - Quick Wins, Big Bets, Fill-Ins, Money Pits classification
- **ISO 9241-11:2018** - Usability dimensions (effectiveness, efficiency, satisfaction)

For complete methodology foundation: `jaan-to/outputs/research/47-ux-research-synthesize.md` (877 lines)

---

**See Also**: [Heatmap Analysis](heatmap-analyze.md) | [Research Discovery](../pm/research-about.md)
