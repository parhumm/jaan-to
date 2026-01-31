---
name: to-jaan-research-add
description: |
  Add research document to deepresearch index (from file or URL).
  Auto-triggers on: add research, index research, add to research
  Maps to: to-jaan-research-add
allowed-tools: Read, Glob, Grep, Edit, Write(.jaan-to/outputs/research/**), WebFetch, Bash(git add:*), Bash(git commit:*)
argument-hint: <file-path-or-URL>
---

# to-jaan-research-add

> Add research document to deepresearch index (from file or URL).

## Context Files

Read these before execution:
- `.jaan-to/learn/to-jaan-research-add.learn.md` - Past lessons
- `.jaan-to/outputs/research/README.md` - Current index structure

## Input

**Source**: $ARGUMENTS

---

# PHASE 0: Input Validation

## Step 0.1: Parse Input

Extract the input from `$ARGUMENTS`:

1. **If empty:** Show usage
   ```
   ❌ No input provided.

   Usage: /to-jaan-research-add <file-path-or-URL>

   Examples:
   - /to-jaan-research-add .jaan-to/outputs/research/my-research.md
   - /to-jaan-research-add https://example.com/article
   ```

2. **Detect input type:**

   | Input Type | Detection |
   |------------|-----------|
   | Local file | Contains `.md` or path exists in repo |
   | Web URL | Starts with `http://` or `https://` |

---

# PHASE 1: Analysis (Read-Only)

## Step 0: Apply Past Lessons

Read `.jaan-to/learn/to-jaan-research-add.learn.md` if it exists:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

## Step 1: Extract Content Info

### For Local Files:

1. Verify file exists using Read tool
2. Read first 50-100 lines
3. Extract:
   - **Title:** First H1 heading (`# Title`) or YAML `title:` field
   - **Summary:** First paragraph or executive summary section
4. Detect category from content keywords:

   | Category | Keywords |
   |----------|----------|
   | `ai-workflow` | claude, agent, workflow, prompt, token, MCP, LLM |
   | `dev` | code, architecture, testing, API, backend, frontend |
   | `pm` | product, PRD, roadmap, feature, requirement |
   | `qa` | test, quality, automation, CI/CD |
   | `ux` | design, UI, UX, accessibility, user |
   | `data` | analytics, tracking, GTM, metrics |
   | `growth` | SEO, content, marketing |
   | `mcp` | MCP server, tool server |
   | `other` | (fallback) |

### For Web URLs:

1. Use WebFetch with prompt:
   ```
   Extract from this page:
   1. Title (main heading)
   2. Brief summary (2-3 sentences)
   3. 3-5 key topics covered
   4. Full content as clean markdown
   ```
2. Determine category from content keywords
3. Generate kebab-case filename from title
4. Prepare content for new .md file

## Step 2: Generate Filename (if needed)

For URLs or files not already in research outputs:

1. Count existing files in `.jaan-to/outputs/research/` matching `[0-9][0-9]-*.md`
2. Next number = count + 1 (pad to 2 digits)
3. Slugify title: lowercase, replace spaces with hyphens, max 50 chars
4. Format: `{NN}-{category}-{slug}.md`

---

# HARD STOP - Human Review Check

Present the proposal:

```
📋 RESEARCH DOCUMENT PROPOSAL
─────────────────────────────

Source: {file-path or URL}
Type: {local file / web URL}
Category: {category}
Title: {extracted title}

{If URL: Filename: {NN}-{category}-{slug}.md}

Summary:
{2-3 sentence description}

FILES TO MODIFY
───────────────
□ .jaan-to/outputs/research/README.md (add to index)
{If URL: □ .jaan-to/outputs/research/{filename} (new file)}
```

> "Proceed with adding to index? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution (Write Phase)

## Step 3: Create .md File (URLs Only)

If the source is a web URL, create the new markdown file:

**File path:** `.jaan-to/outputs/research/{NN}-{category}-{slug}.md`

**File structure:**
```markdown
# {Title}

> {Brief description}
> Source: {URL}
> Added: {YYYY-MM-DD}

---

{Full content from WebFetch}
```

Use the Write tool to create this file.

## Step 4: Update README.md Index

Edit `.jaan-to/outputs/research/README.md`:

### 4.1: Add to Summary Index Table

Find the table under `## Summary Index` and add new row at the end:

```markdown
| [{NN}]({filename}) | {Title} | {Brief one-line description} |
```

### 4.2: Add to Quick Topic Finder

Find the most relevant section based on category:

| Category | Section |
|----------|---------|
| ai-workflow | Claude Code Setup & Configuration OR AI-Powered Workflows |
| dev | Tech Stack Best Practices |
| pm | Documentation & Architecture |
| qa | PR Review Automation |
| data | Token & Cost Optimization |
| other | Documentation & Architecture |

Add link to the section:
```markdown
- [{filename}]({filename})
```

Use the Edit tool for both updates.

## Step 5: Quality Check

Before committing, verify:
- [ ] README.md has new entry in Summary Index
- [ ] README.md has link in Quick Topic Finder
- [ ] New file exists (if URL source)
- [ ] No duplicate entries

## Step 6: Git Commit

```bash
git add .jaan-to/outputs/research/README.md
git add .jaan-to/outputs/research/{filename}  # if URL source
git commit -m "$(cat <<'EOF'
docs(research): Add {title} to index

{If URL: Fetched from: {URL}}
Category: {category}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Step 7: Verify Commit

```bash
git status
```

## Step 8: Completion Report

```
✅ Research Document Added

Commit: {hash}
Category: {category}
File: {filename}

Files modified:
- .jaan-to/outputs/research/README.md
{If URL: - .jaan-to/outputs/research/{filename} (new)}

Summary:
{Brief description of what was added}
```

## Step 9: Capture Feedback

> "Any feedback on adding this research? [y/n]"

If yes:
- Run `/to-jaan-learn-add to-jaan-research-add "{feedback}"`

---

## Error Handling

| Error | Response |
|-------|----------|
| No argument | Show usage with examples |
| File not found | `❌ File not found: {path}. Check the path and try again.` |
| URL fetch fails | Retry once, then: `❌ Could not fetch URL. Check connectivity.` |
| README parse fails | `❌ Could not parse README structure. Manual intervention needed.` |
| Git commit fails | Show error, suggest manual commit |

---

## Definition of Done

- [ ] Source analyzed and metadata extracted
- [ ] User approved the proposal
- [ ] New file created (if URL source)
- [ ] README.md updated with new entry
- [ ] Git committed
- [ ] User confirmed result
