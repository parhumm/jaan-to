# /to-jaan-research-about

> Deep research on any topic with structured markdown output.

---

## What It Does

Performs comprehensive web research on any topic using adaptive 5-wave research with parallel agents, synthesizes findings into a structured markdown document, and adds it to the deepresearches index.

---

## Usage

```
/to-jaan-research-about <topic>
```

**Examples**:
- `/to-jaan-research-about Claude Code hooks best practices`
- `/to-jaan-research-about React state management 2025`
- `/to-jaan-research-about MCP server authentication patterns`

---

## What It Asks

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

### Approval Modes

| Mode | Description |
|------|-------------|
| Auto | Run all waves automatically, show final document only |
| Summary | Show brief progress after each wave, no approval needed |
| Interactive | Ask for approval at each major step (default) |

---

## Research Process

Uses **5 adaptive waves** where each wave's focus is determined by findings from previous waves:

1. **Wave 1: Scout** (1 agent) - Maps the research landscape, identifies subtopics and gaps
2. **Wave 2: Gaps** (1-4 agents) - Fills the primary gap identified by Scout
3. **Wave 3: Expand** (1-10 agents) - Expands coverage into new areas based on W1+W2
4. **Wave 4: Verify** (1-8 agents) - Verifies claims, resolves conflicts (size ≥60)
5. **Wave 5: Deep** (2-6 agents) - Final deep dive on remaining priorities (size ≥60)

### Wave Distribution by Size

| Size | W1 | W2 | W3 | W4 | W5 | Total |
|------|----|----|----|----|----|----|
| 20   | 1  | 1  | 1  | -  | -  | 3  |
| 60   | 1  | 1  | 2  | 1  | 2  | 7  |
| 100  | 1  | 2  | 3  | 2  | 2  | 10 |
| 200  | 1  | 2  | 4  | 4  | 3  | 14 |
| 500  | 1  | 4  | 10 | 8  | 6  | 29 |

### Adaptive Behavior

- **Scout results** → determine Wave 2 gap focus
- **Wave 2 findings** → determine Wave 3 expansion areas
- **Conflicts found** → targeted in Wave 4 verification
- **Remaining weak areas** → prioritized for Wave 5 deep dive

---

## Output

**Path**: `jaan-to/outputs/research/{NN}-{category}-{slug}.md`

**Naming**: `21-ai-workflow-topic-name.md`

**Categories**:
- `ai-workflow` - Claude, agents, prompts, MCP
- `dev` - Code, architecture, APIs
- `pm` - Product, PRDs, roadmaps
- `qa` - Testing, CI/CD
- `ux` - Design, UI, accessibility
- `data` - Analytics, tracking
- `growth` - SEO, marketing
- `mcp` - MCP servers
- `other` - Fallback

---

## Document Structure

```markdown
# {Title}
> Research conducted: {date}

## Executive Summary
## Background & Context
## Key Findings
### {Subtopic 1}
### {Subtopic 2}
## Recent Developments (2024-2025)
## Best Practices & Recommendations
## Comparisons (if relevant)
## Open Questions
## Sources
## Research Metadata
```

---

## Also Does

- Updates `jaan-to/outputs/research/README.md` index
- Git commits the result
- Captures feedback via `/to-jaan-learn-add`

---

## Related

- [/to-jaan-research-add](research-add.md) - Add existing file or URL to index
