---
name: jaan-to-ux-heatmap-analyze
description: |
  Analyze heatmap data from CSV exports and screenshots to generate prioritized UX research reports.
  Auto-triggers on: heatmap analysis, click analysis, ux heatmap, clarity export, interaction patterns, click patterns, scroll analysis, tap analysis.
  Maps to: ux:heatmap-analyze
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/**)
argument-hint: [csv-path] [screenshot-path] [html-path?] [problem?]
---

# jaan-to-ux-heatmap-analyze

> Analyze heatmap CSV exports and screenshots to generate prioritized UX research reports with cross-validated findings.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to-ux-heatmap-analyze.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-ux-heatmap-analyze.template.md` - Report template
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (helpful for CSS selector resolution)

## Input

**Analysis Request**: $ARGUMENTS

- If CSV path + screenshot path provided → Full analysis mode
- If directory path provided → Scan for CSV/image pairs
- If empty → Interactive wizard (ask for file paths)

**Accepted file types:**
- CSV: Click/tap data exports from analytics tools (aggregated or raw)
- Screenshots: Heatmap images (PNG, JPEG) — color-coded interaction overlays
- HTML: Page source for element cross-reference (optional)
- Problem statement: Research question or UX concern (optional, as text)

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-ux-heatmap-analyze.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Validate Inputs and Detect Data Format

Parse $ARGUMENTS to identify file paths. For each CSV file, read the first 15 lines to detect its format:

**Format A — Aggregated Element Data:**
If lines contain metadata keys like `Project name`, `Date range`, `Page views`, `Total clicks`, or the data table has columns `Rank`, `Button`, `Clicks`, `% of clicks`:
- This is an aggregated export (e.g., from analytics tools that rank elements by interaction count)
- Parse metadata section: project name, date range, URL pattern, page views, total interactions, metric type (Click/Tap), behavior segment (if present)
- Parse data table: rank, CSS selector, interaction count, percentage

**Format B — Raw Coordinate Data:**
If column headers contain `timestamp`, `session_id`, `x_coordinate`, `y_coordinate`, `viewport_width`:
- This is raw event-level data
- Parse all columns, note available fields

**Format Unknown:**
If neither pattern matches, use AskUserQuestion:
- Question: "Cannot auto-detect CSV format. What type of data is this?"
- Header: "Format"
- Options:
  - "Aggregated" — Ranked elements with click counts (e.g., analytics tool export)
  - "Raw events" — Individual click events with coordinates and timestamps
  - "Other" — Let me describe the format

For each file, validate:
- CSV is parseable with consistent columns
- Screenshot files exist and are readable image formats
- HTML file exists (if provided)

If any required file is missing or unparseable, report the error and ask for correction.

## Step 2: Extract and Display Data Summary

Build and display a data summary for user confirmation:

```
DATA SUMMARY
════════════════════════════════════════

Format: {Aggregated | Raw Events}
Files:
  CSV:        {filename} ({row_count} elements, {total_interactions} interactions)
  Screenshot: {filename} ({width}x{height}px)
  HTML:       {filename | "Not provided"}

Metadata:
  Date Range:        {date_range}
  URL:               {url_pattern}
  Device:            {desktop | mobile | both}
  Behavior Segment:  {quick backs | excessive scrolling | all traffic}
  Page Views:        {count}
  Total Interactions: {count}

{If multiple CSV files:}
Additional Files:
  CSV 2: {filename} ({details})
  CSV 3: {filename} ({details})

════════════════════════════════════════
```

**Important for Format A (aggregated data):**
State clearly what analysis IS and IS NOT possible:

> **Analysis scope**: Element click distribution, CTA effectiveness, navigation patterns, desktop/mobile comparison, behavior segment analysis, HTML element mapping.
>
> **Not available with this data format**: Rage click detection, scroll depth analysis, hesitation timing, session flow reconstruction (these require raw event data with timestamps and coordinates).

## Step 3: Clarify Analysis Goal

Use AskUserQuestion:
- Question: "What is the primary question this analysis should answer?"
- Header: "Goal"
- Options:
  - "Find friction" — Identify frustration points and conversion barriers
  - "Optimize CTA" — Evaluate button/link placement and visibility
  - "Compare" — Desktop vs mobile or behavior segment differences
  - "Other" — Let me describe my specific question

If "Other" selected, ask: "What specific question should this analysis answer?"

If multiple CSV files provided (different devices or behavior segments), ask:

Use AskUserQuestion:
- Question: "You provided {N} CSV files. How should they be analyzed?"
- Header: "Multi-file"
- Options:
  - "Compare" — Side-by-side comparison across files
  - "Separate" — Independent analysis for each file
  - "Combined" — Merge all data into single analysis

## Step 4: Visual Analysis (Screenshots)

**IMPORTANT**: Read screenshot files BEFORE the CSV analysis to avoid anchoring bias.

For each screenshot, read the image file and analyze:

Prompt structure (image placed first, then analysis request):
1. Read the heatmap image
2. Then analyze with these questions:
   - What page zones show high interaction intensity (red/orange)?
   - What page zones show low or no interaction (blue/green/no overlay)?
   - Are there cold zones on elements that appear interactive (buttons, links, CTAs)?
   - What reading/scanning pattern is visible (F-pattern, Z-pattern, concentrated, scattered)?
   - Are there hot zones on non-interactive areas (text, images, decorative elements)?
   - What is the overall content engagement pattern (above fold vs below fold)?

Record each observation with:
- Page zone (header, navigation, hero, content area N, sidebar, footer)
- Intensity level (high/medium/low/none)
- Notable elements in that zone
- Inferred user behavior

**Note on large screenshots**: If image height exceeds 5000px, note that findings for below-fold sections may have reduced confidence. Very tall captures (>10000px) should be flagged as "reduced vision confidence for lower page sections."

## Step 5: CSV Data Analysis

### For Format A (Aggregated Element Data):

1. **Pareto analysis**: Calculate what percentage of total clicks the top 10% of elements receive. If top 10% captures >60% of clicks, there is high click concentration.

2. **Top elements breakdown**: List top 15-20 elements by click count. For each:
   - CSS selector (shortened for readability)
   - Click count and percentage
   - Element type inference from selector (navigation, button, link, image, form, text)

3. **Low-engagement elements**: Identify elements below 0.5% of total clicks. These may indicate dead elements or poor visibility.

4. **Element type distribution**: Group all elements by inferred type and calculate aggregate clicks per type:
   - Navigation (nav, menu, arrow, slider, carousel)
   - CTAs (button, submit, cta, action)
   - Content (image, thumbnail, card, article)
   - Links (a, href, link)
   - Form (input, select, form)
   - Other

5. **Behavior segment analysis** (if metadata includes behavior flags):
   - What elements are clicked more by users exhibiting this behavior?
   - Are navigation elements overrepresented (suggesting orientation issues)?
   - Are back/close buttons prominent (suggesting content mismatch)?

6. **Multi-file comparison** (if multiple CSVs):
   - Normalize by page views before comparing (clicks per 1000 page views)
   - Identify elements with significantly different engagement across files
   - Note: Do NOT compare absolute click counts between files with vastly different page view totals

### For Format B (Raw Coordinate Data):

1. **Rage click detection**: Find 3+ clicks within 2-3 seconds at same location (10-20px radius)
2. **Scroll depth analysis**: Calculate scroll percentage distribution, identify drop-off cliffs
3. **Coordinate clustering**: Use density analysis to identify hotspot zones
4. **Session flow patterns**: Trace click sequences per session
5. **Device segmentation**: Separate desktop vs mobile before analysis
6. **Hesitation zones**: Identify locations with long pre-click pauses (>3 seconds)

## Step 6: HTML Cross-Reference (If HTML Provided)

For the top 30 elements from the CSV:

1. Extract the CSS selector from the CSV
2. Search the HTML for matching elements
3. For each match, extract:
   - Element tag name (button, a, div, img, etc.)
   - Visible text content (innerText)
   - `href`, `aria-label`, `data-*`, `title` attributes
   - Parent context (what section/component contains this element)

4. Build a mapping table:

```
ELEMENT MAPPING
════════════════════════════════════════
Rank | Clicks | %     | Element Description
─────┼────────┼───────┼──────────────────────
1    | 1,444  | 9.73% | Next arrow (carousel navigation)
2    | 1,290  | 8.69% | Previous arrow (carousel navigation)
3    | 528    | 3.56% | Thumbnail image (content card)
...
════════════════════════════════════════
```

5. **Dead element detection**: Search HTML for interactive elements (buttons, links, inputs) that appear in the DOM but have zero or near-zero clicks in the CSV. These may indicate:
   - Below-fold placement (not visible without scrolling)
   - Poor visual affordance (users don't recognize them as interactive)
   - Hidden behind overlays or conditional rendering

6. **Opaque selector handling**: If CSS selectors contain only generated class names (e.g., `css-1a2b3c`, `sc-dkzDqf`) with no semantic meaning:
   - Attempt to identify by element tag, nesting context, and attributes
   - If unresolvable, label as "Unresolved: {selector fragment}" in the mapping table
   - Note this as a limitation in the report

## Step 7: Two-Pass Cross-Reference Validation

**Pass 1 — Collect Candidate Findings:**

Gather all observations from Steps 4, 5, and 6 into a candidate list. For each finding, note its source:
- [V] = Vision analysis (screenshot)
- [C] = CSV data analysis
- [H] = HTML cross-reference

**Pass 2 — Cross-Reference and Score:**

For each candidate finding, check if it is supported by multiple sources:

| Validation Status | Criteria | Confidence Range |
|-------------------|----------|------------------|
| **Corroborated** | Finding supported by 2+ sources | 0.85 — 0.95 |
| **Single-source** | Finding from one source only | 0.70 — 0.80 |
| **Contradicted** | Sources disagree | Flag for investigation |

Examples:
- Vision shows hot zone at top → CSV confirms top elements have 40%+ of clicks → **Corroborated** (0.90)
- CSV shows element has 12% of clicks → Vision shows no visible hotspot there → **Contradicted** (investigate: overlay issue? dynamic element?)
- Vision shows cold zone on CTA → No CTA found in CSV top 50 → **Corroborated** (0.88)

**Discard findings below 0.70 confidence.**
**Flag all contradictions for explicit mention in report.**

## Step 8: Prioritize and Plan Report

Organize validated findings by severity:

```
Priority = Likelihood × Impact

Severity Levels:
- CRITICAL (≥0.95): High likelihood + High impact → Immediate action needed
- HIGH     (≥0.90): High in one dimension → Sprint planning
- MEDIUM   (≥0.85): Moderate both → Backlog consideration
- LOW      (≥0.80): Low both → Monitor
```

Draft action summary: top 3-5 actions as bullets (action, impact, one-line evidence).

For each finding, prepare:
- Title (concise, action-oriented)
- Evidence from each source (CSV data, vision observation, HTML context)
- Confidence score and validation status
- Recommended action with ICE score (Impact 1-10 × Confidence 1-10 × Ease 1-10)

For each high-confidence finding (≥0.85), draft one A/B test or UX research idea:
- A/B test: What variation to test, what metric to measure, which finding it validates
- UX research: What method (usability test, survey, card sort, tree test), what question to answer

---

# HARD STOP - Human Review Gate

Present the analysis plan summary:

```
ANALYSIS SUMMARY
════════════════════════════════════════

Data:    {format} | {device} | {behavior segment}
Goal:    {analysis goal}
Sources: CSV ✓ | Screenshot ✓ | HTML {✓ | ✗}

VALIDATED FINDINGS: {total}
  Corroborated:  {n} (high confidence)
  Single-source: {n} (medium confidence)
  Contradicted:  {n} (flagged)

TOP FINDINGS:
1. {finding_title} — {severity} ({confidence})
2. {finding_title} — {severity} ({confidence})
3. {finding_title} — {severity} ({confidence})

REPORT SECTIONS:
  ✓ Action Summary (top 3-5 actions)
  ✓ {N} Findings & Actions (insight + action + evidence)
  ✓ {N} Test Ideas (A/B tests + UX research)
  {✓ | ✗} Device/Segment Comparison
  ✓ Element Mapping Table
  ✓ Limitations & Method (footer)

════════════════════════════════════════
```

Use AskUserQuestion:
- Question: "Proceed with full report generation?"
- Header: "Proceed"
- Options:
  - "Yes" — Generate the report
  - "Edit" — Let me adjust the analysis focus
  - "No" — Cancel

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 9: Generate Report

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to-ux-heatmap-analyze.template.md`

Fill all template sections. Report must be **insightful, practical, and actionable** — lead with why it matters and what to do. Minimize descriptive narrative.

1. **Header metadata**: URL, device, date range, page views, file paths — single-line format from Step 2
2. **Action Summary**: Top 3-5 actions as bullets. Each bullet format:
   - **Action** (what to change) — expected impact — one-line evidence with source tag [V], [C], or [H]
   - No narrative paragraphs. Bullets only.
3. **Findings & Actions**: Each finding as a self-contained card, ordered by ICE score descending:
   - **Insight**: Why this matters — draw a deeper conclusion, don't just restate the number (e.g., "Users are hunting for navigation" not "40% of clicks go to arrows")
   - **Do this**: Specific, implementable action (1-2 sentences max)
   - ICE score table (Impact, Confidence, Ease, total) and confidence/validation status
   - **Evidence**: 2-4 bullets citing specific data (CSV values, vision observations, HTML context) with source tags [V], [C], [H]
   - No observation-only findings — every finding MUST have a concrete action
4. **Test Ideas**: 3-5 suggested experiments derived from findings:
   - **A/B Tests**: What variation to test, what metric to measure, which finding it validates (e.g., "Test sticky nav vs current: measure carousel arrow clicks — validates Finding #1")
   - **UX Research**: What method + what question (e.g., "5-user usability test: Can users find the filter without scrolling? — explores Finding #3")
   - Each idea: 1-2 lines, linked to a finding number
5. **Element Mapping**: Full table from Step 6 (or note "HTML not provided" if skipped)
6. **Comparison**: Desktop vs mobile or segment differences (if applicable, keep concise)
7. **Footer notes**: Limitations as one-line list + methodology as one-line summary (both in blockquote)

## Step 10: Quality Check

Before preview, verify every item:

- [ ] Action summary contains top 3-5 actions as bullets (no narrative paragraphs)
- [ ] Every finding has an "Insight" line that explains WHY, not just WHAT
- [ ] Every finding has a concrete "Do this" action (no observation-only findings)
- [ ] Every finding has a confidence score and at least one evidence citation
- [ ] Every finding attributes evidence to its source: [V], [C], or [H]
- [ ] Contradictions between vision and CSV are explicitly flagged and explained
- [ ] Recommendations include ICE scores (Impact × Confidence × Ease)
- [ ] Data limitations are stated clearly (what was NOT analyzable and why)
- [ ] Device type and behavior segment labels match the source data exactly
- [ ] CSS selectors are resolved to human-readable descriptions (or marked "unresolved")
- [ ] No hallucinated findings — every claim is traceable to a CSV row or screenshot observation
- [ ] Click counts are normalized by page views when comparing across files
- [ ] Test Ideas section has 3-5 suggested A/B tests or UX research methods linked to findings

If any check fails, revise the report before preview.

## Step 11: Preview & Approval

Show the complete report in conversation.

Use AskUserQuestion:
- Question: "Write report to `$JAAN_OUTPUTS_DIR/ux/heatmap/{slug}/report.md`?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "No" — Cancel

## Step 12: Write Output

If approved:
1. Generate slug from URL or page name: lowercase, hyphens, no special characters, max 50 chars
   - Example: "Product Detail Page" → `product-detail-page`
   - Example: "https://example.com/checkout" → `checkout`
2. Create path: `$JAAN_OUTPUTS_DIR/ux/heatmap/{slug}/`
3. Write file: `$JAAN_OUTPUTS_DIR/ux/heatmap/{slug}/report.md`
4. Confirm: "Report written to {path}"

## Step 13: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on the heatmap analysis?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update this report
  - "Learn" — Save lesson for future analyses
  - "Both" — Fix now AND save lesson

- **Fix now**: Revise report, re-preview, re-write
- **Learn**: Run `/to-jaan-learn-add jaan-to-ux-heatmap-analyze "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] CSV data parsed and format correctly detected
- [ ] Screenshot(s) analyzed with vision capabilities
- [ ] Cross-reference validation completed (if multiple data sources)
- [ ] Report includes prioritized findings with evidence attribution
- [ ] Data limitations documented explicitly
- [ ] All quality checks pass
- [ ] Report written to `$JAAN_OUTPUTS_DIR/ux/heatmap/{slug}/report.md`
- [ ] User has approved the report
