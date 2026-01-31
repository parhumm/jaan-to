# /to-jaan-research-add

> Add research document to deepresearch index (from file or URL).

---

## What It Does

Indexes an existing research document (local file or web URL) into the deepresearches collection. Extracts metadata, detects category, updates README index, and commits.

---

## Usage

```
/to-jaan-research-add <file-path-or-URL>
```

**Examples**:
- `/to-jaan-research-add jaan-to/outputs/research/my-research.md`
- `/to-jaan-research-add https://example.com/article`

---

## What It Asks

| Question | When |
|----------|------|
| Approve proposal? | Before any changes |
| Category correct? | If auto-detected seems wrong |

---

## Input Types

| Type | Detection | Action |
|------|-----------|--------|
| Local file | Contains `.md` | Extract metadata, add to index |
| Web URL | Starts with `http` | Fetch content, create file, add to index |

---

## For Local Files

1. Reads first 50-100 lines
2. Extracts title (H1 or YAML title)
3. Extracts summary (first paragraph)
4. Detects category from keywords
5. Updates README.md index

---

## For Web URLs

1. Fetches content via WebFetch
2. Extracts title, summary, key topics
3. Determines category
4. Creates `{NN}-{category}-{slug}.md`
5. Updates README.md index

---

## Output

**For URLs**: Creates `jaan-to/outputs/research/{NN}-{category}-{slug}.md`

**File format**:
```markdown
# {Title}

> {Brief description}
> Source: {URL}
> Added: {YYYY-MM-DD}

---

{Full content}
```

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
- Adds to Quick Topic Finder section
- Git commits the result
- Captures feedback via `/to-jaan-learn-add`

---

## Related

- [/to-jaan-research-about](research-about.md) - Deep research on new topics
