# Research Methodology Reference

> Reference tables, templates, and specifications for the `pm-research-about` skill.
> This file is extracted from SKILL.md for token optimization. Do not duplicate content back into SKILL.md.

---

## Approval Mode Behaviors

| Check | Auto | Summary | Interactive |
|------|------|---------|-------------|
| After clarifications | Skip | Skip | Confirm |
| Research plan | Skip | Show | Confirm |
| After each wave | Skip | Brief status | N/A |
| HARD STOP (before write) | Skip | Skip | **Confirm** |
| Before file write | Auto-yes | Auto-yes | Confirm |

---

## Category Detection Keywords

Use this table to auto-detect research category from topic keywords:

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

---

## Agent Capacity Model

```
1 agent ~ 10 searches + 3 WebFetch = ~13 operations
```

### Workload per Wave (searches + fetches)

| Size | W1 Scout | W2 Gaps | W3 Expand | W4 Verify | W5 Deep |
|------|----------|---------|-----------|-----------|---------|
| 20   | 8+3      | 6+2     | 6+2       | -         | -       |
| 60   | 8+3      | 10+3    | 12+4      | 8+3       | 10+4    |
| 100  | 8+3      | 12+4    | 24+8      | 20+6      | 12+4    |
| 200  | 8+3      | 20+6    | 40+12     | 36+10     | 24+8    |
| 500  | 8+3      | 40+12   | 100+30    | 80+24     | 60+18   |

### Derived Agents (ceil(ops / 13))

| Size | W1 | W2 | W3 | W4 | W5 | Total |
|------|----|----|----|----|----|----|
| 20   | 1  | 1  | 1  | -  | -  | 3  |
| 60   | 1  | 1  | 2  | 1  | 2  | 7  |
| 100  | 1  | 2  | 3  | 2  | 2  | 10 |
| 200  | 1  | 2  | 4  | 4  | 3  | 14 |
| 500  | 1  | 4  | 10 | 8  | 6  | 29 |

### Wave Distribution by Size (5 Waves)

| Size | Total | W1 Scout | W2 Gaps | W3 Expand | W4 Verify | W5 Deep |
|------|-------|----------|---------|-----------|-----------|---------|
| 20   | 3     | 1        | 1       | 1         | -         | -       |
| 60   | 7     | 1        | 1       | 2         | 1         | 2       |
| 100  | 10    | 1        | 2       | 3         | 2         | 2       |
| 200  | 14    | 1        | 2       | 4         | 4         | 3       |
| 500  | 29    | 1        | 4       | 10        | 8         | 6       |

---

## Per-Wave Workload Tables

### W2 Workload by Size

| Size | Agents | Searches | WebFetch |
|------|--------|----------|----------|
| 20   | 1      | 6        | 2        |
| 60   | 1      | 10       | 3        |
| 100  | 2      | 6 each   | 2 each   |
| 200  | 2      | 10 each  | 3 each   |
| 500  | 4      | 10 each  | 3 each   |

### W3 Workload by Size

| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 20   | 1      | 6              | 2              |
| 60   | 2      | 6              | 2              |
| 100  | 3      | 8              | 3              |
| 200  | 4      | 10             | 3              |
| 500  | 10     | 10             | 3              |

### W4 Workload by Size

| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 60   | 1      | 8              | 3              |
| 100  | 2      | 10             | 3              |
| 200  | 4      | 9              | 3              |
| 500  | 8      | 10             | 3              |

### W5 Workload by Size

| Size | Agents | Searches/Agent | WebFetch/Agent |
|------|--------|----------------|----------------|
| 60   | 2      | 5              | 2              |
| 100  | 2      | 6              | 2              |
| 200  | 3      | 8              | 3              |
| 500  | 6      | 10             | 3              |

---

## Wave Results Summary Template

Use this template when consolidating all wave results (Step 4):

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

---

## Document Structure Plan Template

Use this template when planning the final document structure (Step 5):

```
DOCUMENT STRUCTURE
──────────────────
Executive Summary:
1. {insight} <- Sources: [A], [B]
2. {insight} <- Sources: [C]
3. {insight} <- Sources: [D], [E]

Subtopics:
1. {name}: {findings mapped} <- Sources: [...]
2. {name}: {findings mapped} <- Sources: [...]
3. {name}: {findings mapped} <- Sources: [...]

Best Practices:
1. {practice} <- Sources: [...]
2. {practice} <- Sources: [...]

Source Priority:
- Primary (official/authoritative): [...]
- Supporting (quality blogs): [...]
- Reference (forums/discussions): [...]
```

---

## Source Ranking Criteria

When prioritizing references for the final document:

- **Authority**: Official docs > research papers > quality blogs > forums
- **Recency**: Recent (2024-2025) > older
- **Verification**: Findings supported by 2+ sources marked as "verified"
- **Conflict resolution**: If sources disagree, note both perspectives; prefer recent over older, official docs over blogs

---

## Quality Checklist

Before previewing the final document, verify all items:

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

---

## Completion Report Template

```
RESEARCH COMPLETE

Category: {category}
Document: $JAAN_OUTPUTS_DIR/research/{filename}
Sources: {N} unique sources consulted
Queries: {M} search queries used
Date: {YYYY-MM-DD}

ADAPTIVE WAVES (5)
------------------
W1 Scout:  {N1} sources - mapped landscape
W2 Gaps:   {N2} sources - filled {gap}
W3 Expand: {N3} sources - expanded {areas}
W4 Verify: {N4} sources - verified {claims}
W5 Deep:   {N5} sources - deep dived {final}

README.md updated with new entry.
```

---

## Add-to-Index: File Template (URLs only)

Path: `$JAAN_OUTPUTS_DIR/research/{NN}-{category}-{slug}.md`

```markdown
# {Title}

> {Brief description}
> Source: {URL}
> Added: {YYYY-MM-DD}

---

{Full content from WebFetch}
```

---

## Add-to-Index: Completion Template

```
Research Document Added

Category: {category}
File: {filename}

Files modified:
- $JAAN_OUTPUTS_DIR/research/README.md
- $JAAN_OUTPUTS_DIR/research/{filename} (if URL)
```

---

## Definition of Done (Research)

- [ ] Topic clarified (if needed)
- [ ] Research size selected
- [ ] Wave 1 Scout completed and analyzed
- [ ] Wave 2 filled primary gap based on Scout
- [ ] Wave 3 expanded coverage based on W1+W2
- [ ] Wave 4 verified claims and resolved conflicts (if size >= 60)
- [ ] Wave 5 deep dived remaining areas (if size >= 60)
- [ ] All 5 wave findings merged and deduplicated
- [ ] Document structure planned
- [ ] Research document created with all sections
- [ ] Quality checks pass
- [ ] README.md updated with new entry
- [ ] Git committed
- [ ] User approved final result

## Definition of Done (Add to Index)

- [ ] Source analyzed, metadata extracted
- [ ] User approved proposal
- [ ] File created (if URL)
- [ ] README.md updated
- [ ] Git committed

---

## Research Summary Display Format

Use this template for the HARD STOP human review check (when `{approval_mode}` = Interactive):

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

---

## Research Plan Display Template

Use this when outputting the initial research plan (Step 2):

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

## Wave Agent Prompt Templates

### Generic Structure

Each wave agent receives a Task prompt following this pattern:

```
Task prompt: "Research {wave_focus} of {topic}:

Wave {N} - {wave_description}.
{context_from_previous_waves}

Perform {search_count} searches:
1. WebSearch: '{query_pattern}'
... (continue to {search_count})

Then WebFetch {fetch_count} authoritative sources.

Return:
{return_fields}"

subagent_type: Explore
run_in_background: {true for W3-5, false for W1-2}
```

### Per-Wave Configuration

| Wave | Focus | Context Input | Sync Mode | Return Fields |
|------|-------|--------------|-----------|---------------|
| W1 Scout | Broad landscape mapping | None | sync (wait) | Key findings, sources, subtopics discovered, coverage gaps, recommended W2 directions, source quality assessment |
| W2 Gaps | Fill primary gap from Scout | Scout summary + identified gap | sync (wait) | Gap findings, sources, NEW gaps for W3, recommended direction |
| W3 Expand | Expand into new areas | W1+W2 summary + new areas | parallel | Expanded findings, sources, conflicts/controversies, questions for W4 |
| W4 Verify | Verify claims, resolve conflicts | W1-3 claims + conflicts list | parallel | Verification status per claim, resolved conflicts, expert opinions, remaining uncertainties |
| W5 Deep | Final deep dive on priorities | All waves summary + remaining priorities | parallel | Deep findings, sources, advanced insights, future directions |

### W1 Scout Default Queries

```
1. '{topic} overview fundamentals explained'
2. '{topic} best practices {year}'
3. '{topic} recent developments news'
4. '{topic} vs alternatives comparison'
5. '{topic} common challenges problems'
6. '{topic} tutorial getting started'
7. '{topic} expert analysis deep dive'
8. '{topic} implementation examples'
```

W2-5 queries are generated adaptively based on previous wave results (gaps, new areas, claims to verify, remaining priorities).

### Add-to-Index HARD STOP Template

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
