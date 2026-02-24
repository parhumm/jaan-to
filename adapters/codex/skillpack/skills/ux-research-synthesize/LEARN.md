# Lessons: ux-research-synthesize

> Last updated: 2026-02-03
>
> Plugin-side seed lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-ux-research-synthesize.learn.md`

Accumulated lessons from research synthesis executions, seeded from comprehensive UX research methodology foundation.

---

## Better Questions

### Phase 1: Analysis

**Research Questions**:
- "What are your research questions?" - Essential for focused synthesis; every theme must tie back
- "Are these questions answerable with the data you've collected?" - Prevents scope mismatch

**Theme Development**:
- "Should themes be inductive (from data), deductive (from framework), or hybrid?" - Clarifies approach upfront
- "How many participants contributed to this theme?" - Ensures balanced representation, not single-voice themes
- "Does this theme answer one of your research questions?" - Maintains focus

**Evidence Validation**:
- "Can you trace this insight to specific participant quotes?" - Validates claims, prevents hallucination
- "What is the business impact of this finding?" - Grounds insights in value, not just observation

### Phase 2: Generation

**Recommendation Quality**:
- "Does this recommendation specify WHO, WHAT, and WHY?" - Ensures actionability
- "What metric will prove this recommendation worked?" - Forces measurable outcomes
- "Is this a Quick Win, Big Bet, Fill-In, or Money Pit?" - Clarifies prioritization

---

## Edge Cases

### Small Sample Sizes (3-5 participants)

**Language to use**:
- 3-5 users: "We observed patterns suggesting..."
- 6-12 users: "Evidence indicates..."
- 13+ users: "Our research strongly suggests..."

**Valid claims with small N**:
- Identification of usability problems
- Discovery of mental models
- Uncovering workflow patterns
- Hypothesis generation

**Avoid**:
- Percentages implying population prevalence
- Statistical significance claims
- Definitive statements about "all users"

### Contradictory Findings

**Resolution framework**:
1. Check methodology: Same participants? Same tasks? Same conditions?
2. Interpret findings: Perceived vs. objective usability; resistance to change; learning curves; peak-end effect
3. Resolution options: Beta test with new users, conduct learnability study, incremental rollout

**Reporting**:
- Do NOT hide conflicting data — it's valuable
- Present both findings transparently
- Explain potential reasons
- Recommend follow-up research
- Note confidence levels

### Missing Research Questions

**If study had no predefined questions**:
- Work backwards from data
- Identify what questions the data CAN answer
- Frame themes around answerable questions
- Note this as limitation in Methodology section

### Single-Participant Domination

**If one participant contributes >25% of evidence for a theme**:
- Flag it during Step 7 (Evidence Linking)
- Options:
  1. Find more evidence from other participants
  2. Reframe as edge case instead of theme
  3. Discard theme
- Never rely solely on single participant for a theme

### Inconclusive Research

**Structure for reporting**:
1. What we set out to learn
2. What we did learn (partial findings)
3. What remains unclear
4. Why it's inconclusive (methodology, sample, scope)
5. Recommended next steps

**Framing**:
- "Inconclusive results narrow the search space"
- "This tells us we need different questions"
- "We've learned X isn't the issue, focusing attention on Y"

---

## Common Mistakes

### Analysis Phase

❌ **Generating themes before familiarization** - Leads to confirmation bias
✅ Always read transcripts BEFORE asking AI to code

❌ **Using topic labels instead of interpretive theme names**
✅ "Users Navigate by Trial and Error" not "Navigation Issues"

❌ **Creating >10 themes** - Indicates insufficient abstraction
✅ Target 3-8 themes for coherent analysis

❌ **Creating <3 themes** - Indicates over-generalization
✅ Break down if only 1-2 themes emerge

❌ **Accepting AI-generated themes without human validation**
✅ Always review, refine, rename for interpretive insight

❌ **Skipping participant coverage check**
✅ Track quotes per participant per theme; flag if >25% from one person

❌ **Coding without a codebook**
✅ Maintain structured codebook with definitions, examples, limits

❌ **Mixing semantic and latent codes without distinction**
✅ Label codes as surface (semantic) vs. underlying (latent)

### Generation Phase

❌ **Vague recommendations** - "Improve the UI"
✅ "Reduce checkout from 5 steps to 3 by combining address and payment screens"

❌ **Executive summaries >1 page**
✅ Maximum 1 page (≈300-400 words); if longer, cut content

❌ **Findings without "Insight"** - Stating WHAT without explaining WHY
✅ Every theme must have "Insight" explaining business impact or user need

❌ **Recommendations without business context** - No "So What"
✅ Use INSIGHT/SO WHAT/NOW WHAT structure for all recommendations

❌ **Unsupported claims** - Insights without traceable quotes
✅ Every claim must link to verbatim quote with participant ID

❌ **Missing methodology limitations**
✅ Always state what was NOT analyzable and why

❌ **Hallucinated findings**
✅ Trace every claim to source; 20% manual validation sample for AI-generated content

❌ **Using percentages with small samples**
✅ "3 of 5 participants" not "60% of users"

---

## Workflow

### Best Practices

**Familiarization (Step 4)**:
- Always read transcripts BEFORE AI coding
- For Speed mode: first 200 lines only
- For Standard mode: complete transcripts
- AI summary helps but human review is mandatory

**Coding (Step 5)**:
- Use hybrid approach: start with common UX framework (mental models, needs, pain points, workarounds) + add inductive codes from data
- Limit codebook to 30-40 codes for manageability
- Every code must have at least 2 participant quotes

**Theme Development (Step 6)**:
- AI generates candidate themes → Human refines and names
- Rename themes from descriptive to interpretive before finalizing
- Theme sweet spot: 4-6 themes
- If theme has only 1 participant quote, it's an outlier not a theme

**Evidence Linking (Step 7)**:
- Track participant contribution per theme (use matrix format)
- Balance is critical: no participant >25% of quotes
- Include context: task, timing, non-verbal cues

**Prioritization (Step 8)**:
- Use Nielsen severity framework consistently (0-4 scale)
- Calculate frequency: (Participants encountering / Total) × 100
- Apply Impact × Effort matrix to classify recommendations

**Report Generation (Step 10-11)**:
- Generate executive brief automatically from main report (extract highlights/lowlights)
- Don't ask user to provide exec brief content separately
- Use same powerful quote to open both reports

### Time Savers

**For Speed mode**:
- Read first 200 lines only (don't analyze full transcripts)
- Skip appendix generation
- Use bullet format for findings

**For Standard mode**:
- Use AI for initial coding, human for theme development
- Batch quote extraction per theme instead of per participant

**For all modes**:
- Generate executive brief auto from main report sections
- Use template.md placeholders for consistent structure
- Run quality check (Step 12) before preview to avoid rework

### Quality Assurance

**Hard requirements**:
- Every theme must link to 2-3+ participant quotes
- Every recommendation must have action verb + specific element + outcome
- Theme count: 3-8 (flag if outside range)
- Executive Summary: ≤1 page, standalone
- Participant coverage: balanced across sample

**Traceability check**:
- Can you trace each insight to verbatim quotes?
- Are participant IDs consistent throughout (P1-P{N})?
- Does every theme answer a research question?

**Cross-validation** (if multiple analysts):
- 80% agreement minimum acceptable
- Cohen's Kappa 0.60+ often acceptable for exploratory UX research
- Blind coding recommended for high-stakes research

---

## Research Methodology References

This skill implements best practices from:

- **Braun & Clarke's Six-Phase Thematic Analysis** - Familiarization, coding, theme development, review, definition, reporting
- **Atomic Research Framework** (Pidcock/Sharon) - Experiments → Facts → Insights → Recommendations
- **Nielsen Norman Group's Synthesis Methodology** - Collect → Assess → Explain → Check
- **ISO 9241-11:2018** - Usability dimensions (effectiveness, efficiency, satisfaction)
- **Thomas & Harden's Three-Stage Thematic Synthesis** - Line-by-line coding, descriptive themes, analytical themes

For complete methodology foundation: `$JAAN_OUTPUTS_DIR/research/47-ux-research-synthesize.md` (877 lines)
