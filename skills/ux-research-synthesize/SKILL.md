---
name: ux-research-synthesize
description: Synthesize UX research findings into themed insights, executive summaries, and prioritized recommendations.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/research/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [study-name] [data-sources?]
---

# ux-research-synthesize

> Synthesize UX research findings into themed insights, executive summaries, and prioritized recommendations.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:ux-research-synthesize.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:ux-research-synthesize.template.md` - Synthesis report template
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration (if applicable)

## Input

**Study Name & Data Sources**: $ARGUMENTS

- If file paths provided → Read transcripts directly
- If directory provided → Scan for all research files
- If empty → Interactive wizard (ask for study name and data sources)

**Accepted data sources**:
- Transcripts (interview notes, session recordings)
- Survey responses
- Observation notes
- Existing research files
- URLs to research repositories

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:ux-research-synthesize.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 3
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_ux-research-synthesize` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Input Collection & Validation

Parse $ARGUMENTS to identify:
1. **Study name** - First argument or ask if not provided
2. **Data sources** - Remaining arguments (file paths, directories, URLs)

For each data source:
- **If file path**: Use Read to validate file exists and is readable
- **If directory**: Use Glob to find all `.txt`, `.md`, `.docx`, `.pdf` files
- **If URL**: Note for later retrieval
- **If empty**: Ask: "Please provide file paths, directory path, or paste transcript text"

Build data summary:
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

If any file is missing or unparseable, report error and ask for correction.

## Step 2: Synthesis Mode Selection

Present three synthesis modes:

> "Which synthesis mode?
>
> **[1] Speed (1-2 hours)**
>   - Top findings from 3-5 sessions
>   - Critical issues only
>   - Bullet-format output
>   - Best for: Quick usability tests with clear tasks
>
> **[2] Standard (1-2 days)** ← Recommended
>   - Full 6-phase thematic analysis
>   - 3-8 themes with evidence
>   - Audience-tailored report
>   - Best for: Interview studies, exploratory research
>
> **[3] Cross-Study (meta-analysis)**
>   - Aggregate themes across multiple studies
>   - Longitudinal tracking
>   - Strategic recommendations
>   - Best for: Research repositories, quarterly synthesis
>
> Choose mode: [1/2/3]"

Store selection as `{synthesis_mode}`.

Show expected deliverables:
> "**Mode**: {synthesis_mode}
> **Time estimate**: {time_estimate}
> **Output**: {deliverables_description}"

## Step 3: Research Questions Clarification

Ask: "What are your research questions? (1-3 max)"

If unclear, provide common templates:
> "Select or customize:
> [1] What usability issues exist in [feature]?
> [2] How do users perceive [concept]?
> [3] What are user needs around [topic]?
> [4] What motivates users to [action]?
> [5] Custom - Let me write my own"

Confirm 1-3 research questions maximum.

**Critical**: Every theme must tie back to these questions.

## Step 4: Data Familiarization (AI-Assisted)

**For Speed mode**: Read first 200 lines of each transcript
**For Standard/Cross-Study**: Read complete transcripts

Use Task tool to launch AI familiarization agent:

**Prompt**:
```
Read all provided transcripts. Identify:
1. Recurring topics mentioned by multiple participants
2. Strong emotional reactions (frustration, delight, confusion)
3. Contradictory statements between participants
4. Participant language patterns and terminology

Do NOT generate themes yet — only familiarize with the data landscape.

Return:
- Summary of data landscape (5-7 sentences)
- Participant count identified
- Session types observed
- Data quality notes (any transcription issues, missing context)
```

**Human reviews AI summary**:
- Check for accuracy
- Note any missed patterns
- Confirm participant count matches expectations

## Step 5: Initial Coding (AI-Assisted with Human Validation)

Use Task tool for AI coding agent:

**Prompt**:
```
Generate descriptive codes for meaningful data segments from the transcripts.
Use both semantic (surface) and latent (underlying) codes.

For each code provide:
- Label (2-4 words)
- Brief definition
- Supporting quote with participant ID
- Line reference

Return codebook with 30-40 codes maximum.
Format: Table with Code | Definition | Supporting Quote | Participant ID | Line Reference
```

**Human validates codebook**:

Display AI-generated codebook in conversation.

Check for:
- [ ] Vague codes without clear definition
- [ ] Overlapping codes that should be merged
- [ ] Codes without examples/quotes
- [ ] Every code has at least 2 participant quotes

Ask: "**Codebook Review**
```
{display codebook}
```

Approve this codebook or refine? [Approve/Refine/Restart]"

**If Refine**: Ask "What should be changed?" and regenerate
**If Restart**: Start Step 5 over with different approach
**If Approve**: Continue to Step 6

## Step 6: Theme Development (Human-Led with AI Support)

Ask: "Should themes be generated:
[1] **Inductively** - From data patterns (let themes emerge organically)
[2] **Deductively** - From framework (e.g., UX mental models, needs, pain points, workarounds)
[3] **Hybrid** - Start with framework + add emergent codes ← Recommended"

Use Task tool for AI theme clustering:

**Prompt**:
```
Group the approved codes into 4-6 candidate themes.

For each theme provide:
1. Descriptive name
2. Codes belonging to theme (list all relevant codes)
3. 2-3 sentence narrative explaining the pattern
4. Tensions or contradictions within theme (if any)

Be explicit about reasoning for each grouping.
```

**Human reviews themes**:

Display candidate themes in conversation.

Check for:
- **Coherence**: Do codes fit together logically?
- **Distinctness**: Are themes overlapping or duplicative?
- **Coverage**: Do themes answer research questions?
- **Count**: 3-8 themes total (optimal)

**Rename themes** from descriptive to interpretive:
- ❌ Bad: "Navigation Issues" (topic label)
- ✅ Good: "Users Navigate by Trial and Error, Not Design Cues" (interpretive insight)

Ask: "**Theme Review**
```
{display themes with codes}
```

Theme count: {N} {optimal: 3-8 | ⚠️ flag if outside range}

Approve themes or refine? [Approve/Split/Merge/Rename]"

**Options**:
- **Approve**: Continue to Step 7
- **Split**: "Which theme to split?" → Human selects → Ask for split criteria
- **Merge**: "Which themes to merge?" → Human selects → Create combined theme
- **Rename**: "Which theme to rename?" → Human provides new interpretive name

## Step 7: Evidence Linking & Participant Coverage Check

For each approved theme, compile supporting evidence:

1. **Extract quotes** - Minimum 2-3 quotes from different participants
2. **Include context**:
   - Task participant was performing
   - Timing in session (early/mid/late)
   - Non-verbal cues (hesitation, frustration, emphasis)
   - Preceding/following discussion summary

3. **Build traceability matrix**: Theme → Codes → Quotes → Participant IDs

4. **Track participant contribution**:
   - Count quotes per participant per theme
   - Flag if any participant contributes >25% of quotes for a theme

Display participant coverage matrix:

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

If any theme has imbalanced coverage (>25% from single participant):
> "Theme {N} quotes are dominated by P{X}. Options:
> [1] Find more evidence from other participants
> [2] Reframe as edge case instead of theme
> [3] Discard this theme
> Choose: [1/2/3]"

## Step 8: Prioritization & Recommendation Planning

For each theme, apply **Nielsen severity framework** (0-4 scale):

Ask for each theme: "Rate severity for '{theme_name}':
[0] Not a usability problem
[1] Cosmetic problem only (fix if time permits)
[2] Minor usability problem (low priority)
[3] Major usability problem (high priority)
[4] Usability catastrophe (fix before release)"

Calculate **priority score**:
- Frequency: `(Participants encountering issue / Total participants) × 100`
- Impact: Severity rating (0-4)
- Priority Score: `Severity × Frequency`

Apply **Impact × Effort matrix**:

Ask for each theme: "Estimate effort to address '{theme_name}':
[Low] 1-2 sprints, minimal resources
[Medium] 1-2 months, small team
[High] 3-6+ months, cross-functional effort"

Classify into quadrants:
- **High Impact + Low Effort** = Quick Wins (do first)
- **High Impact + High Effort** = Big Bets (plan carefully)
- **Low Impact + Low Effort** = Fill-Ins (if time permits)
- **Low Impact + High Effort** = Money Pits (avoid)

Generate **draft recommendations** using template:
`[Action Verb] + [Specific Element] + [To Achieve Outcome] + [Because Evidence]`

Example:
> "Redesign the settings menu with clearer labeling and top-level placement to reduce support tickets by 20% because 80% of new admins couldn't locate settings without assistance (Theme 2, P1, P4, P7, P9)."

---

# HARD STOP - Human Review Gate

Present analysis summary for approval:

```
SYNTHESIS ANALYSIS SUMMARY
════════════════════════════════════════
Mode: {Speed | Standard | Cross-Study}
Study: {study_name}
Research Questions:
  1. {question_1}
  2. {question_2}
  3. {question_3}

Data Sources: {N} files
  Participants: {n} total
  Transcripts analyzed: {n}

THEMES IDENTIFIED: {N} themes {optimal: 3-8 | ⚠️ flag if outside}

  Priority 1 (High Severity × High Frequency):
    - {theme_name} — Severity {0-4}, {frequency}%, {n} participants
      Quick Win / Big Bet / Fill-In / Money Pit: {quadrant}

  Priority 2:
    - {theme_name} — Severity {0-4}, {frequency}%, {n} participants
      {quadrant}

  Priority 3:
    - {theme_name} — Severity {0-4}, {frequency}%, {n} participants
      {quadrant}

QUALITY CHECKS:
  ✓ Theme count: {N} (optimal: 3-8)
  ✓ Participant coverage: {Balanced | ⚠️ Imbalanced}
  ✓ Evidence traceability: {Complete | ⚠️ Gaps in Theme X}
  ✓ Research questions addressed: {N}/{total}
  {⚠️ Any warnings or issues}

REPORT SECTIONS TO GENERATE:
  ✓ Executive Summary (1 page max)
  ✓ {N} Themed Findings with evidence
  ✓ Prioritized Recommendations ({N} total)
  ✓ Methodology Note with limitations
  {✓ Appendix (if Standard+ mode)}

════════════════════════════════════════
```

> "Proceed with synthesis report generation? [y/edit/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

**If edit**: Ask "What should be changed?" and return to appropriate step
**If n**: Stop and ask for next steps

---

# PHASE 2: Generation (Write Phase)

## Step 9: Generate ID and Output Paths

Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/ux/research"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Generate slug from study name
slug=$(echo "{study_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c1-50)

# Create folder and file paths
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-synthesis-${slug}.md"
EXEC_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-exec-brief-${slug}.md"
```

Preview output configuration:
> "**Output Configuration**
> - ID: {NEXT_ID}
> - Folder: jaan-to/outputs/ux/research/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-synthesis-{slug}.md
> - Exec brief: {NEXT_ID}-exec-brief-{slug}.md"

## Step 10: Generate Main Synthesis Report

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:ux-research-synthesize.template.md`

Fill all template sections:

### Header
- Study name: {study_name}
- Date: {current_date YYYY-MM-DD}
- Participants: {n} total
- Method: {research_method from data familiarization}
- Mode: {synthesis_mode}
- Research Questions: {list 1-3 questions}

### Executive Summary (1 page max)
Structure:
1. **Open with powerful user quote** - Select most emotionally resonant quote
2. **Highlights** (what's working well) - 2-3 bullets of positive findings
3. **Lowlights** (top 3-5 issues) - Prioritized by severity × frequency
4. **How to turn lowlights into highlights** - Clear next steps (actionable bullets)

### Key Findings
For each theme (ordered by Priority Score descending):

**Theme Card Structure**:
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
| Severity | {Nielsen 0-4} ({frequency}% × {impact description} × {persistence: one-time/repeated}) |
| Confidence | {High/Medium/Low} |
| Validation | {Corroborated/Single-source} |
```

**Priority Badges**:
- 🔴 **CRITICAL** (Severity 4, High Frequency)
- 🟠 **HIGH** (Severity 3+, Medium+ Frequency)
- 🟡 **MEDIUM** (Severity 2, any Frequency)
- 🟢 **LOW** (Severity 0-1)

### Recommendations
For each theme with actionable recommendation:

**Problem-Solution Format**:
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

### Methodology Note
Brief overview (5-7 sentences):
- Research type (interviews, usability tests, surveys)
- Participant count and recruitment method
- Analysis approach (Braun & Clarke 6-phase, Atomic Research, hybrid)
- Synthesis mode used (Speed/Standard/Cross-Study)
- **Limitations** (one-line list):
  - Sample size constraints
  - What was NOT analyzable and why
  - Confidence caveats
  - Scope limitations

### Appendix (Standard+ mode only)
Optional sections:
- **Participant Profiles**: Demographics, segments represented
- **Codebook Summary**: Top 20 codes with definitions
- **Methodology Details**: Full Braun & Clarke 6-phase process walkthrough

## Step 11: Generate Executive Brief

Auto-generate 1-page standalone summary from main report.

**Extract from main report**:
1. **Opening quote**: Use same powerful quote from Executive Summary
2. **Highlights**: Copy from Executive Summary (2-3 bullets)
3. **Lowlights**: Copy top 3-5 issues from Executive Summary
4. **Next steps**: Copy action items from Executive Summary
5. **Visual** (if applicable): Add simple table showing priority breakdown

**Constraints**:
- Maximum 1 page (≈300-400 words)
- No methodology details
- No raw data
- No jargon
- Standalone (reader needs no other context)

**Format**:
```markdown
# {Study Name} — Executive Brief

> "{Powerful user quote from most impactful finding}"

## Highlights ✓

- {What's working well — finding 1}
- {What's working well — finding 2}

## Lowlights ⚠️

1. **{Issue 1 title}** — {Impact description}
2. **{Issue 2 title}** — {Impact description}
3. **{Issue 3 title}** — {Impact description}

## Next Steps →

- **{Action 1}** — {Expected impact} — {Timeline: Quick Win/Big Bet}
- **{Action 2}** — {Expected impact} — {Timeline}
- **{Action 3}** — {Expected impact} — {Timeline}

---

| Priority | Count |
|----------|-------|
| Critical (🔴) | {n} findings |
| High (🟠) | {n} findings |
| Medium (🟡) | {n} findings |

Full report: `{path_to_main_file}`
```

## Step 12: Quality Check (Pre-Write Validation)

Before preview, verify every item:

**Executive Summary**:
- [ ] Executive Summary ≤ 1 page and stands alone
- [ ] Opens with powerful user quote (emotionally resonant)
- [ ] Has highlights (what's working) AND lowlights (issues)
- [ ] Has clear next steps (actionable bullets)

**Themes**:
- [ ] Every theme has interpretive name (not just topic label)
- [ ] Every theme has "Insight" explaining WHY (not just WHAT observed)
- [ ] Every theme has 2-3+ quotes from different participants
- [ ] Every theme has participant coverage noted (IDs listed)
- [ ] Theme count: 3-8 (flag if outside optimal range)

**Recommendations**:
- [ ] Every recommendation has concrete action (not vague "improve UX")
- [ ] Every recommendation links to specific finding/theme
- [ ] Recommendations include priority + effort estimates
- [ ] Recommendations include Impact/Effort quadrant classification
- [ ] Every recommendation has "INSIGHT/SO WHAT/NOW WHAT" structure
- [ ] Every recommendation has success metric (how to measure)

**Evidence & Traceability**:
- [ ] All research questions have corresponding findings
- [ ] Participant coverage balanced (no single participant >25% of evidence)
- [ ] Every claim traces to verbatim quote with participant ID
- [ ] Participant IDs are consistent throughout (P1-P{N})
- [ ] Quotes include context (task, timing, source tag)

**Methodology & Limitations**:
- [ ] Methodology note states analysis approach clearly
- [ ] Limitations stated clearly (sample size, scope, confidence caveats)
- [ ] No hallucinated findings (all claims sourced from data)

**Cross-Study Mode Only**:
- [ ] Temporal validity checked (when were studies conducted)
- [ ] Methodology consistency noted across studies
- [ ] Contradictory findings across studies are flagged and explained

If any check fails, revise report before preview.

## Step 13: Preview & Approval

Show both reports in conversation:

1. **Main Synthesis Report** (full markdown)
2. **Executive Brief** (1-page summary)

> "**Preview: Synthesis Outputs**
>
> {display full main report}
>
> ---
>
> {display executive brief}
>
> ---
>
> Write these outputs? [y/n]"

**If n**: Ask "What should be changed?" and return to Step 10/11

## Step 14: Write Outputs

If approved, write files:

1. **Create output folder**:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. **Write main synthesis report**:
```bash
cat > "$MAIN_FILE" <<'EOF'
{generated synthesis report with Executive Summary, Key Findings, Recommendations, Methodology, Appendix}
EOF
```

3. **Write executive brief**:
```bash
cat > "$EXEC_FILE" <<'EOF'
{generated 1-page executive brief}
EOF
```

4. **Update subdomain index**:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"

# Extract 1-2 sentence summary from Executive Summary section
EXEC_SUMMARY="{extract first 1-2 sentences from Executive Summary of main report}"

add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Study Name}" \
  "$EXEC_SUMMARY"
```

5. **Confirm completion**:
> "✓ Synthesis report written to: jaan-to/outputs/ux/research/{NEXT_ID}-{slug}/{NEXT_ID}-synthesis-{slug}.md
> ✓ Executive brief written to: jaan-to/outputs/ux/research/{NEXT_ID}-{slug}/{NEXT_ID}-exec-brief-{slug}.md
> ✓ Index updated: jaan-to/outputs/ux/research/README.md"

## Step 15: Capture Feedback

> "Any feedback or improvements needed? [y/n]"

**If yes**:
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this?
   > [1] Fix now - Update this synthesis
   > [2] Learn - Save for future syntheses
   > [3] Both - Fix now AND save lesson"

**Options**:
- **[1] Fix now**: Revise reports, re-preview, re-write to same paths
- **[2] Learn**: Run `/jaan-to:learn-add ux-research-synthesize "{feedback}"`
- **[3] Both**: Do both

---

## Definition of Done

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
