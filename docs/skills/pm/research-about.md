---
title: "pm-research-about"
sidebar_position: 3
---

# /jaan-to:pm-research-about

> Deep research on any topic, or add existing file/URL to research index.

---

## What It Does

Two modes in one command:

1. **Deep Research** — Give it a topic and it performs comprehensive 5-wave adaptive web research with parallel agents, then synthesizes findings into a structured markdown document.
2. **Add to Index** — Give it a file path or URL and it extracts metadata, indexes it into the research collection, and commits.

The mode is auto-detected from your input.

---

## Usage

```
/jaan-to:pm-research-about <topic-or-file-path-or-URL>
```

**Examples**:
- `/jaan-to:pm-research-about "Claude Code hooks best practices"` — deep research
- `/jaan-to:pm-research-about https://example.com/article` — add URL to index
- `/jaan-to:pm-research-about jaan-to/outputs/research/my-doc.md` — add file to index

---

## Mode Detection

| Input | Mode |
|-------|------|
| Starts with `http://` or `https://` | Add URL to index |
| Path exists as file | Add file to index |
| Anything else | Deep research |

---

## Deep Research Mode

### What It Asks

| Question | When |
|----------|------|
| What topic? | If not specified |
| Clarifying questions (3-5) | If topic is broad or unclear |
| Research size? | Choose: 20/60/100/200/500 sources |
| Approval mode? | Choose: Auto/Summary/Interactive |
| Approve research plan? | Interactive mode only |
| Approve document? | Before saving (all modes) |

### Research Sizes

| Size | Sources | Agents | Best For |
|------|---------|--------|----------|
| Quick (20) | ~20 | 3 | Quick overview (3 waves) |
| Standard (60) | ~60 | 7 | Solid research (default) |
| Deep (100) | ~100 | 10 | Comprehensive |
| Extensive (200) | ~200 | 14 | In-depth analysis |
| Exhaustive (500) | ~500 | 29 | Maximum coverage |

### Research Process

Uses **5 adaptive waves** where each wave's focus is determined by findings from previous waves:

1. **Wave 1: Scout** (1 agent) — Maps the research landscape
2. **Wave 2: Gaps** (1-4 agents) — Fills primary gap from Scout
3. **Wave 3: Expand** (1-10 agents) — Expands into new areas
4. **Wave 4: Verify** (1-8 agents) — Verifies claims, resolves conflicts (size >= 60)
5. **Wave 5: Deep** (2-6 agents) — Final deep dive (size >= 60)

### Output

**Path**: `jaan-to/outputs/research/{NN}-{category}-{slug}.md`

**Document sections**: Executive Summary, Background, Key Findings, Recent Developments, Best Practices, Comparisons, Open Questions, Sources, Metadata.

---

## Add to Index Mode

### What It Asks

| Question | When |
|----------|------|
| Approve proposal? | Before any changes |
| Category correct? | If auto-detected seems wrong |

### For Local Files

1. Reads first 50-100 lines
2. Extracts title and summary
3. Detects category
4. Updates README.md index

### For Web URLs

1. Fetches content via WebFetch
2. Creates `{NN}-{category}-{slug}.md`
3. Updates README.md index

---

## Categories

| Category | Keywords |
|----------|----------|
| `ai-workflow` | claude, agent, workflow, prompt, MCP |
| `dev` | code, architecture, testing, API |
| `pm` | product, PRD, roadmap, feature |
| `qa` | test, quality, CI/CD |
| `ux` | design, UI, accessibility |
| `data` | analytics, tracking, GTM |
| `growth` | SEO, content, marketing |
| `mcp` | MCP server, tool |
| `other` | Fallback |

---

## Also Does

- Updates `jaan-to/outputs/research/README.md` index
- Git commits the result
- Captures feedback via `/jaan-to:learn-add`

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to-pm-research-about.learn.md
```

Add feedback:
```
/jaan-to:learn-add pm-research-about "your feedback here"
```
