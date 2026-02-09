---
name: pm-research-about
description: Deep research on any topic, or add existing file/URL to research index.
allowed-tools: Task, WebSearch, WebFetch, Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/research/**), Edit, Bash(git add:*), Bash(git commit:*)
argument-hint: <topic-or-file-path-or-URL>
---

# pm-research-about

> Deep research on any topic, or add existing file/URL to research index.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:pm-research-about.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:pm-research-about.template.md` - Output format template
- `$JAAN_OUTPUTS_DIR/research/README.md` - Current index structure

## Input

**Input**: $ARGUMENTS

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:pm-research-about.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_pm-research-about` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

# PHASE 0: Input Validation

## Step 0.0: Detect Input Type

Quick-classify `$ARGUMENTS`:
- Starts with `http://` or `https://` → jump to **Add to Index** (end of file)
- Path exists as local file → jump to **Add to Index** (end of file)
- Everything else (including empty) → continue below as research topic

## Step 0.1: Check Topic

If no topic provided, ask:
> What topic would you like me to research? Examples:
> - "Claude Code hooks best practices"
> - "React state management 2025"
> - "MCP server authentication patterns"

## Step 0.2: Detect Category

Detect category from topic keywords:

| Category | Keywords |
|----------|----------|
| `ai-workflow` | claude, agent, workflow, prompt, token, MCP, LLM, GPT |
| `dev` | code, architecture, testing, API, backend, frontend, react, typescript |
| `pm` | product, PRD, roadmap, feature, requirement, spec |
| `qa` | test, quality, automation, CI/CD, coverage |
| `ux` | design, UI, UX, accessibility, user, interface |
| `data` | analytics, tracking, GTM, metrics, dashboard |
| `growth` | SEO, content, marketing, conversion |
| `mcp` | MCP server, tool server, integration |
| `other` | (fallback for non-matching) |

If ambiguous, default to `ai-workflow` for AI topics or `dev` for technical topics.

## Step 0.3: Generate Filename

1. Count existing files in `$JAAN_OUTPUTS_DIR/research/` matching pattern `[0-9][0-9]-*.md`
2. Next number = count + 1 (pad to 2 digits)
3. Slugify topic: lowercase, replace spaces with hyphens, remove special chars
4. Format: `{NN}-{category}-{slug}.md`
5. Path: `$JAAN_OUTPUTS_DIR/research/{filename}`

**Show user:**
> **Research Setup**
> - Topic: {topic}
> - Category: {category}
> - Filename: {filename}
> - Path: $JAAN_OUTPUTS_DIR/research/{filename}

---

# PHASE 1: Clarify & Plan

## Step 1: Clarify Research Scope

**Assess topic clarity:**
- Is the topic specific enough? (e.g., "React" → too broad, "React Server Components" → specific)
- Does it have clear boundaries?
- Is the intent clear (learning, comparison, implementation)?

**If topic is unclear or broad, ask 3-5 clarifying questions.**

Each question offers **3 options + 1 recommendation**:

> **Q1: What's your primary goal?**
> - [A] Learning fundamentals ← *Recommended for beginners*
> - [B] Implementation guide
> - [C] Comparison with alternatives
>
> **Q2: What depth level?**
> - [A] Overview (high-level concepts)
> - [B] Intermediate (patterns & practices) ← *Recommended*
> - [C] Advanced (internals & edge cases)
>
> **Q3: What's the context?**
> - [A] New project
> - [B] Existing codebase ← *Recommended if migration mentioned*
> - [C] General knowledge
>
> **Q4: Which aspect matters most?**
> - [A] Performance
> - [B] Developer experience ← *Recommended*
> - [C] Ecosystem & community
>
> **Q5: Include comparisons?**
> - [A] Yes, with {X} and {Y} ← *Recommended*
> - [B] Brief mentions only
> - [C] No comparisons needed

**Skip questions if:**
- Topic is already specific (e.g., "Claude Code hooks for pre-commit validation")
- User provided context with the topic
- Topic is a well-defined term or technology

**After clarifications, confirm refined topic:**
> "I'll research: {refined topic with specifics}"
> "Focus: {selected options summary}"

## Step 1.5: Choose Research Size

> **How comprehensive should the research be?**
>
> | Size | Sources | Agents | Best For |
> |------|---------|--------|----------|
> | [A] Quick (20) | ~20 sources | 3 agents | Quick overview ← *Recommended for simple topics* |
> | [B] Standard (60) | ~60 sources | 7 agents | Solid research ← *Recommended* |
> | [C] Deep (100) | ~100 sources | 10 agents | Comprehensive coverage |
> | [D] Extensive (200) | ~200 sources | 14 agents | In-depth analysis |
> | [E] Exhaustive (500) | ~500 sources | 29 agents | Maximum coverage |

**Default**: Standard (60) if user doesn't specify or just presses enter.

**Agent Capacity:**
```
1 agent ≈ 10 searches + 3 WebFetch = ~13 operations
```

**Workload per Wave (searches + fetches):**

| Size | W1 Scout | W2 Gaps | W3 Expand | W4 Verify | W5 Deep |
|------|----------|---------|-----------|-----------|---------|
| 20   | 8+3      | 6+2     | 6+2       | -         | -       |
| 60   | 8+3      | 10+3    | 12+4      | 8+3       | 10+4    |
| 100  | 8+3      | 12+4    | 24+8      | 20+6      | 12+4    |
| 200  | 8+3      | 20+6    | 40+12     | 36+10     | 24+8    |
| 500  | 8+3      | 40+12   | 100+30    | 80+24     | 60+18   |

**Derived Agents (ceil(ops / 13)):**

| Size | W1 | W2 | W3 | W4 | W5 | Total |
|------|----|----|----|----|----|----|
| 20   | 1  | 1  | 1  | -  | -  | 3  |
| 60   | 1  | 1  | 2  | 1  | 2  | 7  |
| 100  | 1  | 2  | 3  | 2  | 2  | 10 |
| 200  | 1  | 2  | 4  | 4  | 3  | 14 |
| 500  | 1  | 4  | 10 | 8  | 6  | 29 |

**Confirm selection:**
> "Research size: {selected} (~{N} sources, {M} agents)"

## Step 1.6: Choose Approval Mode

> **How much oversight do you want?**
>
> | Mode | Description |
> |------|-------------|
> | [A] Auto | Run all waves automatically, show final document only ← *Faster* |
> | [B] Summary | Show brief progress after each wave, no approval needed |
> | [C] Interactive | Ask for approval at each major step ← *Default* |

**Default**: Interactive (C) if user doesn't specify.

**Mode Behaviors:**

| Check | Auto | Summary | Interactive |
|------|------|---------|-------------|
| After clarifications | Skip | Skip | Confirm |
| Research plan | Skip | Show | Confirm |
| After each wave | Skip | Brief status | N/A |
| HARD STOP (before write) | Skip | Skip | **Confirm** |
| Before file write | Auto-yes | Auto-yes | Confirm |

**If Auto or Summary selected:**
> "Auto mode enabled. Will show final document for review before writing."

**Store selection as `{approval_mode}` for use in later steps.**

## Step 2: Plan Initial Research Strategy

ultrathink

Plan the **Scout Agent** (Wave 1) approach only:

1. **Identify 3-5 high-level aspects** of the topic
2. **Create broad queries** covering fundamentals, recent developments, and comparisons
3. **Target diverse source types** (official docs, expert blogs, research)

**Scout Agent Assignment:**
- Focus: Broad overview of {topic}
- Queries: 5-8 broad searches covering multiple aspects
- Goal: Map the landscape, identify key subtopics, find authoritative sources

**DO NOT plan Wave 2-3 queries yet** - they will be determined by Scout results.

**Wave Distribution by Size (5 Waves):**

| Size | Total | W1 Scout | W2 Gaps | W3 Expand | W4 Verify | W5 Deep |
|------|-------|----------|---------|-----------|-----------|---------|
| 20   | 3     | 1        | 1       | 1         | -         | -       |
| 60   | 7     | 1        | 1       | 2         | 1         | 2       |
| 100  | 10    | 1        | 2       | 3         | 2         | 2       |
| 200  | 14    | 1        | 2       | 4         | 4         | 3       |
| 500  | 29    | 1        | 4       | 10        | 8         | 6       |

**Output initial plan:**

```
RESEARCH PLAN (Adaptive Waves)
──────────────────────────────
Topic: {refined topic}
Size: {selected} ({N} total agents, ~{M} sources target)

WAVE 1: Scout
─────────────
Agent: 1 Scout Agent
Focus: Broad landscape mapping
Queries:
1. "{topic} overview fundamentals"
2. "{topic} best practices {year}"
3. "{topic} recent developments"
4. "{topic} vs alternatives"
5. "{topic} common challenges"

Goal: Identify subtopics, gaps, and promising directions

WAVE 2-5: To be determined adaptively based on each wave's results
```

---

# PHASE 2: Adaptive Wave Research

## Step 3: Wave 1 - Scout Research

Launch **1 Scout Agent** to map the research landscape.

**W1 Workload:** 8 searches + 3 WebFetch = 11 ops (all sizes)

```
Task prompt: "Research broad overview of {topic}:

Perform 8 web searches covering multiple aspects:
1. WebSearch: '{topic} overview fundamentals explained'
2. WebSearch: '{topic} best practices {year}'
3. WebSearch: '{topic} recent developments news'
4. WebSearch: '{topic} vs alternatives comparison'
5. WebSearch: '{topic} common challenges problems'
6. WebSearch: '{topic} tutorial getting started'
7. WebSearch: '{topic} expert analysis deep dive'
8. WebSearch: '{topic} implementation examples'

Then WebFetch 3 most authoritative sources for deeper content.

Return in structured format:
- Key findings with specific facts/stats
- Sources: [{title}, {url}, {credibility note}] for EACH result
- Subtopics discovered (list ALL you found)
- Coverage gaps (what aspects had weak or no results)
- Recommended search directions for Wave 2
- Source quality assessment (which were most authoritative)"

subagent_type: Explore
run_in_background: false  # WAIT for results before Wave 2
```

**Collect Scout results.**

**If `{approval_mode}` = Summary:** Show brief status:
> "✓ Wave 1 complete: {N} sources, {subtopics_count} subtopics found"

**Proceed to Wave 2 planning.**

## Step 3.5: Wave 2 - Fill Primary Gaps

ultrathink

Analyze Scout results to identify the **biggest gap**:

1. **What subtopic had weakest coverage?** → Primary gap
2. **What source types are missing?** → Source gap
3. **What questions remain unanswered?** → Knowledge gap

**Wave 2 Focus:** Fill the single biggest gap identified by Scout.

**W2 Workload by Size:**
| Size | Agents | Searches | WebFetch |
|------|--------|----------|----------|
| 20   | 1      | 6        | 2        |
| 60   | 1      | 10       | 3        |
| 100  | 2      | 6 each   | 2 each   |
| 200  | 2      | 10 each  | 3 each   |
| 500  | 4      | 10 each  | 3 each   |

```
Task prompt: "Research {primary_gap} of {topic}:

Wave 2 - Filling primary gap from Scout.
Scout coverage: {scout_summary}
Gap to fill: {primary_gap}

Perform {W2_searches} focused searches:
1. WebSearch: '{gap_specific_query_1}'
2. WebSearch: '{gap_specific_query_2}'
... (continue to {W2_searches})

Then WebFetch {W2_fetches} authoritative sources.

Return:
- Key findings for {gap_area}
- Sources with URLs
- NEW gaps discovered (for Wave 3)
- Recommended next direction"

subagent_type: Explore
run_in_background: false  # Wait to analyze before Wave 3
```

**Collect Wave 2 results.**

**If `{approval_mode}` = Summary:** Show brief status:
> "✓ Wave 2 complete: {N} sources, gap '{primary_gap}' filled"

**Proceed to Wave 3 planning.**

## Step 3.6: Wave 3 - Expand Coverage

ultrathink

Analyze Scout + Wave 2 results:

1. **Coverage so far** - {current_sources} of {target_sources}
2. **New gaps from Wave 2** - What did Wave 2 reveal?
3. **Subtopics needing expansion** - Which areas need more depth?

**Wave 3 Focus:** Expand into new areas based on Wave 2 discoveries.

**W3 Workload by Size:**
| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 20   | 1      | 6              | 2              |
| 60   | 2      | 6              | 2              |
| 100  | 3      | 8              | 3              |
| 200  | 4      | 10             | 3              |
| 500  | 10     | 10             | 3              |

```
For each Wave 3 agent:

Task prompt: "Expand research on {expansion_area} of {topic}:

Wave 3 - Expanding coverage.
Current findings: {waves_1_2_summary}
Your expansion focus: {new_area}

Perform {W3_searches} searches:
1. WebSearch: '{expansion_query_1}'
2. WebSearch: '{expansion_query_2}'
... (continue to {W3_searches})

Then WebFetch {W3_fetches} authoritative sources.

Return:
- Expanded findings for {area}
- Sources with URLs
- Conflicts or controversies found
- Questions for Wave 4 verification"

subagent_type: Explore
run_in_background: true
```

**Launch Wave 3 agents in parallel, then collect with TaskOutput.**

**If `{approval_mode}` = Summary:** Show brief status:
> "✓ Wave 3 complete: {N} sources, expanded {areas}"

## Step 3.7: Wave 4 - Verify & Cross-Reference (if size ≥ 60)

**Skip Wave 4 if size = 20.**

ultrathink

Analyze Waves 1-3 results:

1. **Conflicting information** - Which findings disagree?
2. **Unverified claims** - What needs confirmation?
3. **Missing perspectives** - Expert opinions, case studies?

**Wave 4 Focus:** Verify key claims and resolve conflicts.

**W4 Workload by Size:**
| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 60   | 1      | 8              | 3              |
| 100  | 2      | 10             | 3              |
| 200  | 4      | 9              | 3              |
| 500  | 8      | 10             | 3              |

```
For each Wave 4 agent:

Task prompt: "Verify and cross-reference {verification_area} for {topic}:

Wave 4 - Verification phase.
Claims to verify: {claims_list}
Conflicts to resolve: {conflicts_list}

Perform {W4_searches} verification searches:
1. WebSearch: '{claim} evidence research'
2. WebSearch: '{claim} counter arguments'
3. WebSearch: '{topic} expert opinion {area}'
... (continue to {W4_searches})

Then WebFetch {W4_fetches} authoritative sources.

Return:
- Verification status for each claim
- Resolved conflicts with explanation
- Expert opinions found
- Remaining uncertainties"

subagent_type: Explore
run_in_background: true
```

**Launch Wave 4 agents in parallel, then collect with TaskOutput.**

**If `{approval_mode}` = Summary:** Show brief status:
> "✓ Wave 4 complete: {N} sources, verified {claims_count} claims"

## Step 3.8: Wave 5 - Deep Dive Final (if size ≥ 60)

**Skip Wave 5 if size = 20.**

ultrathink

Analyze all previous waves:

1. **Coverage status** - {current_sources} of {target_sources} ({percentage}%)
2. **Remaining weak areas** - What still needs depth?
3. **Final priorities** - Edge cases, advanced topics, future trends

**Wave 5 Focus:** Final deep dive on remaining priorities.

**W5 Workload by Size:**
| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 60   | 2      | 5              | 2              |
| 100  | 2      | 6              | 2              |
| 200  | 3      | 8              | 3              |
| 500  | 6      | 10             | 3              |

```
For each Wave 5 agent:

Task prompt: "Final deep dive on {final_area} of {topic}:

Wave 5 - Final research wave.
Full coverage so far: {all_waves_summary}
Final focus: {remaining_priority}

Perform {W5_searches} deep searches:
1. WebSearch: '{topic} {area} advanced'
2. WebSearch: '{topic} {area} edge cases'
3. WebSearch: '{topic} {area} future trends'
... (continue to {W5_searches})

Then WebFetch {W5_fetches} authoritative sources.

Return:
- Deep findings for {area}
- All sources with URLs
- Advanced insights
- Future directions identified"

subagent_type: Explore
run_in_background: true
```

**Launch Wave 5 agents in parallel, then collect with TaskOutput.**

**If `{approval_mode}` = Summary:** Show brief status:
> "✓ Wave 5 complete: {N} sources, deep dived {areas}"

## Step 4: Consolidate All Wave Results

Merge findings from all completed waves:

```
WAVE RESULTS SUMMARY (5 Waves)
──────────────────────────────
Wave 1 (Scout):  {N1} sources - Mapped landscape
Wave 2 (Gaps):   {N2} sources - Filled primary gap
Wave 3 (Expand): {N3} sources - Expanded coverage
Wave 4 (Verify): {N4} sources - Verified claims
Wave 5 (Deep):   {N5} sources - Final deep dive
──────────────────────────────────────────────
Total: {N} unique sources

ADAPTIVE RESEARCH FLOW
──────────────────────
W1 Scout → identified: {subtopics}
W2 Gaps  → filled: {primary_gap}
W3 Expand → expanded: {expansion_areas}
W4 Verify → confirmed: {verified_claims}
W5 Deep  → explored: {final_areas}
```

For consolidation:
1. Combine all findings from all 5 waves
2. Deduplicate sources (same URL → merge)
3. Note confidence levels per finding
4. Mark verified claims (confirmed in Wave 4)
5. Flag any unresolved conflicts

---

# PHASE 3: Synthesis & Planning

## Step 5: Plan Document Structure

ultrathink

Analyze all gathered research and plan the final document:

1. **Executive Summary** - Identify 3-5 most important insights
   - Must be supported by multiple sources
   - Prioritize actionable insights

2. **Subtopic Organization** - Group findings logically
   - Map each finding to a subtopic
   - Ensure no orphan findings

3. **Best Practices** - Extract recommendations
   - Cross-reference across agents
   - Prioritize by source authority

4. **Comparisons** - If relevant
   - Build comparison table from Agent 3 findings

5. **Open Questions** - Note gaps
   - Areas with conflicting info
   - Topics needing deeper research

6. **Source Ranking** - Prioritize references
   - Official docs > research papers > quality blogs > forums
   - Recent (2024-2025) > older

**Output structure plan with source mappings:**

```
DOCUMENT STRUCTURE
──────────────────
Executive Summary:
1. {insight} ← Sources: [A], [B]
2. {insight} ← Sources: [C]
3. {insight} ← Sources: [D], [E]

Subtopics:
1. {name}: {findings mapped} ← Sources: [...]
2. {name}: {findings mapped} ← Sources: [...]
3. {name}: {findings mapped} ← Sources: [...]

Best Practices:
1. {practice} ← Sources: [...]
2. {practice} ← Sources: [...]

Source Priority:
- Primary (official/authoritative): [...]
- Supporting (quality blogs): [...]
- Reference (forums/discussions): [...]
```

## Step 6: Merge Findings

1. **Combine all findings** from all agents into unified list
2. **Deduplicate sources:**
   - Same URL → merge descriptions
   - Keep best description
3. **Resolve conflicts:**
   - If sources disagree → note both perspectives
   - Prefer recent over older
   - Prefer official docs over blogs
4. **Cross-reference facts:**
   - Mark findings supported by 2+ sources as "verified"
5. **Calculate totals:**
   - {N} unique sources
   - {N} search queries used
   - {N}% coverage of planned subtopics

---

# HARD STOP - Human Review Check

**If `{approval_mode}` = Auto or Summary:** Skip this check, proceed directly to Phase 4.

**If `{approval_mode}` = Interactive:** Present research summary:

```
RESEARCH SUMMARY
────────────────
Topic: {refined topic}
Category: {category}
Filename: {filename}
Size: {selected size} (~{M} target sources)

ADAPTIVE RESEARCH WAVES (5)
───────────────────────────
Wave 1 (Scout):  {N1} sources | Mapped landscape
Wave 2 (Gaps):   {N2} sources | Filled {primary_gap}
Wave 3 (Expand): {N3} sources | Expanded {areas}
Wave 4 (Verify): {N4} sources | Verified {claims}
Wave 5 (Deep):   {N5} sources | Deep dived {final}
───────────────────────────────────────────────────
Total:           {N} unique sources

ADAPTATION DECISIONS
────────────────────
✓ W1 Scout identified: {key_subtopics}
✓ W2 Gaps targeted: {primary_gap}
✓ W3 Expand added: {expansion_areas}
✓ W4 Verify confirmed: {verified_claims}
✓ W5 Deep explored: {final_areas}

SOURCES CONSULTED
─────────────────
{actual} unique sources from {queries} search queries
Target: {target} | Achieved: {percentage}%
- Primary sources: {N}
- Supporting sources: {N}

KEY INSIGHTS (Preview)
──────────────────────
1. {insight 1} [verified by 2+ sources]
2. {insight 2}
3. {insight 3}

SUBTOPICS DISCOVERED
────────────────────
- {subtopic 1}
- {subtopic 2}
- {subtopic 3}

WILL CREATE
───────────
□ $JAAN_OUTPUTS_DIR/research/{filename}
□ Update $JAAN_OUTPUTS_DIR/research/README.md
```

> "Generate full research document? [y/n]"

**Do NOT proceed to Phase 4 without explicit approval.**

---

# PHASE 4: Generation (Write Phase)

## Step 7: Generate Document

Use template from `$JAAN_TEMPLATES_DIR/jaan-to:pm-research-about.template.md`:

1. Fill all sections with researched content
2. Include specific facts, statistics, and citations
3. Add comparison tables if relevant
4. List all sources with descriptions
5. Mark verified facts (supported by 2+ sources)

## Step 8: Quality Check

Before preview, verify:
- [ ] Has executive summary with 3-5 key insights
- [ ] Has background context (2-3 paragraphs)
- [ ] Has at least 2 key findings sections
- [ ] Has recent developments section
- [ ] Has best practices with 3-5 recommendations
- [ ] Has open questions section
- [ ] Has sources with descriptions and URLs
- [ ] Has research metadata (date, category, queries used)
- [ ] Sources are properly attributed to findings

If any check fails, revise before preview.

## Step 9: Preview & Approval

**If `{approval_mode}` = Auto or Summary:**
- Show brief summary (title, source count, key insights)
- Auto-proceed to write

**If `{approval_mode}` = Interactive:**
- Show complete document
- Ask: > "Write to `$JAAN_OUTPUTS_DIR/research/{filename}`? [y/n]"

## Step 10: Write Output

If approved (or auto-mode):
1. Write the research document
2. Confirm: "Research written to `$JAAN_OUTPUTS_DIR/research/{filename}`"

## Step 11: Update README Index

Edit `$JAAN_OUTPUTS_DIR/research/README.md`:

1. **Add to Summary Index table:**
   Find the table under `## Summary Index` and add new row:
   ```markdown
   | [{NN}]({filename}) | {Title} | {Brief one-line description} |
   ```

2. **Add to Quick Topic Finder:**
   Find the most relevant section and add link:
   ```markdown
   - [{filename}]({filename})
   ```

## Step 12: Git Commit

```bash
git add $JAAN_OUTPUTS_DIR/research/{filename} $JAAN_OUTPUTS_DIR/research/README.md
git commit -m "$(cat <<'EOF'
docs(research): Add {title}

Research on {topic} covering:
- {key point 1}
- {key point 2}
- {key point 3}

Sources: {N} sources consulted
Research method: Adaptive 5-wave approach

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Step 13: Completion Report

```
✅ Research Complete

📁 Category: {category}
📄 Document: $JAAN_OUTPUTS_DIR/research/{filename}
📊 Sources: {N} unique sources consulted
🔍 Queries: {M} search queries used
📅 Date: {YYYY-MM-DD}

ADAPTIVE WAVES (5)
──────────────────
🔭 W1 Scout:  {N1} sources - mapped landscape
🎯 W2 Gaps:   {N2} sources - filled {gap}
📈 W3 Expand: {N3} sources - expanded {areas}
✅ W4 Verify: {N4} sources - verified {claims}
🔬 W5 Deep:   {N5} sources - deep dived {final}

README.md updated with new entry.
```

## Step 14: Capture Feedback

> "Any feedback on this research? [y/n]"

If yes:
- Run `/jaan-to:learn-add pm-research-about "{feedback}"`

---

## Definition of Done

- [ ] Topic clarified (if needed)
- [ ] Research size selected
- [ ] Wave 1 Scout completed and analyzed
- [ ] Wave 2 filled primary gap based on Scout
- [ ] Wave 3 expanded coverage based on W1+W2
- [ ] Wave 4 verified claims and resolved conflicts (if size ≥ 60)
- [ ] Wave 5 deep dived remaining areas (if size ≥ 60)
- [ ] All 5 wave findings merged and deduplicated
- [ ] Document structure planned
- [ ] Research document created with all sections
- [ ] Quality checks pass
- [ ] README.md updated with new entry
- [ ] Git committed
- [ ] User approved final result

---

# ════════════════════════════════════════════════════
# Add to Index (file path or URL input)
# ════════════════════════════════════════════════════

> Jump here when input is a file path or URL (detected in Step 0.0)

## Extract Content

**For local files:**
1. Read first 50-100 lines
2. Extract title (H1 or YAML `title:`) and summary
3. Detect category using keywords table above

**For URLs:**
1. WebFetch: "Extract: 1) Title 2) Brief summary (2-3 sentences) 3) Key topics 4) Full markdown content"
2. Detect category from keywords
3. Generate filename: `{NN}-{category}-{slug}.md`

## Generate Filename

1. Count files matching `[0-9][0-9]-*.md` in `$JAAN_OUTPUTS_DIR/research/`
2. Next number = count + 1 (pad to 2 digits)
3. Slugify title: lowercase, hyphens, max 50 chars
4. Format: `{NN}-{category}-{slug}.md`

---

## HARD STOP - Approval

```
RESEARCH DOCUMENT PROPOSAL

Source: {file-path or URL}
Type: {local file / web URL}
Category: {category}
Title: {extracted title}
Filename: {NN}-{category}-{slug}.md (if URL)

Summary: {2-3 sentences}

WILL MODIFY:
□ $JAAN_OUTPUTS_DIR/research/README.md (add to index)
□ $JAAN_OUTPUTS_DIR/research/{filename} (if URL: create new file)
```

> "Proceed with adding to index? [y/n]"

Do NOT proceed without approval.

---

## Create File (URLs only)

Path: `$JAAN_OUTPUTS_DIR/research/{NN}-{category}-{slug}.md`

```markdown
# {Title}

> {Brief description}
> Source: {URL}
> Added: {YYYY-MM-DD}

---

{Full content from WebFetch}
```

## Update README.md

1. Add to Summary Index table: `| [{NN}]({filename}) | {Title} | {Brief description} |`
2. Add to Quick Topic Finder under relevant category section

## Git Commit

```bash
git add $JAAN_OUTPUTS_DIR/research/README.md $JAAN_OUTPUTS_DIR/research/{filename}
git commit -m "$(cat <<'COMMITMSG'
docs(research): Add {title} to index

{If URL: Fetched from: {URL}}
Category: {category}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
COMMITMSG
)"
```

## Completion

```
✅ Research Document Added

Category: {category}
File: {filename}

Files modified:
- $JAAN_OUTPUTS_DIR/research/README.md
- $JAAN_OUTPUTS_DIR/research/{filename} (if URL)
```

> "Any feedback? [y/n]"

If yes: Run `/jaan-to:learn-add pm-research-about "{feedback}"`

---

## Definition of Done (Add to Index)

- [ ] Source analyzed, metadata extracted
- [ ] User approved proposal
- [ ] File created (if URL)
- [ ] README.md updated
- [ ] Git committed
