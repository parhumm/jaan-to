---
name: to-jaan-docs-create
description: |
  Create new documentation with templates following STYLE.md.
  Supports: skill, hook, config, guide, concept, index.
  Maps to: to-jaan-docs-create
allowed-tools: Read, Glob, Grep, Write(docs/**), Write(jaan-to/**), Bash(git add:*), Bash(git commit:*)
argument-hint: "{type} {name}"
---

# to-jaan-docs-create

> Create documentation with standard templates.

## Context Files

- `jaan-to/docs/STYLE.md` - Documentation standards
- `jaan-to/templates/to-jaan-docs-create.template.md` - All templates
- `jaan-to/learn/to-jaan-docs-create.learn.md` - Past lessons (loaded in Pre-Execution)

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`jaan-to/learn/to-jaan-docs-create.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Parse Input & Smart Type Detection

**Arguments**: $ARGUMENTS

Expected format: `{type} "{name}"`

| Type | Description |
|------|-------------|
| skill | Skill documentation |
| hook | Hook documentation |
| config | Config documentation |
| guide | How-to guide |
| concept | Concept explanation |
| index | Section README |

### Analysis First

Analyze user input to understand their actual need:

| User Intent Signal | Recommended Type | Reasoning |
|-------------------|------------------|-----------|
| Documenting a command, `/slash`, SKILL.md | **skill** | Users run it, needs usage guide |
| Documenting automatic behavior, hook, PreToolUse/PostToolUse | **hook** | Runs on events, needs trigger/behavior docs |
| Explaining settings, options, config | **config** | Reference for what can be changed |
| Teaching how to do something, steps, tutorial | **guide** | Step-by-step walkthrough |
| Explaining what something is, overview | **concept** | Understanding-focused, not action-focused |
| README, table of contents, section overview | **index** | Navigation and overview |

### Decision Logic

**If input is clear** (high confidence):
- Auto-select type
- Confirm: "I recommend **{type}** documentation for this. Here's why: {reasoning}. Proceed? [y/n/other]"

**If input is unclear** (ambiguous signals):
- Ask up to 5 smart clarifying questions tailored to the specific ambiguity
- Questions should probe the uncertainty, not be generic
- Example smart questions:
  - "You mentioned '{term}' — is this something users invoke, or does it run automatically?"
  - "Is your goal to help users DO something, or UNDERSTAND something?"
  - "Will this document a single command, or explain a broader concept?"
  - "Does this need step-by-step instructions, or is it reference material?"
  - "Who is the primary audience — end users or developers extending the system?"

### Best Practice Recommendations

Sometimes recommend a better approach:
- If user asks for "guide" but it's really a command → suggest **skill** doc
- If topic is complex → suggest **concept** first, then **guide**
- If documenting internal behavior → suggest **hook** over **config**

> "Based on your description, I'd recommend **{type}** because {reason}.
> However, you might also want a **{alt_type}** for {alt_reason}.
> Which would you like to create first?"

After determining type, ask for name if not provided:
> "What's the name/title?"

## Step 2: Determine Output Path

| Type | Path Pattern |
|------|--------------|
| skill | `docs/skills/{role}/{name}.md` |
| hook | `docs/hooks/{name}.md` |
| config | `docs/config/{name}.md` |
| guide | `docs/extending/{name}.md` |
| concept | `docs/{name}.md` |
| index | `docs/{section}/README.md` |

For skill type, ask: "Which role? [pm/dev/qa/ux/data/core]"

## Step 3: Check for Duplicates

Search for similar docs:
```
Glob: docs/**/*{name}*.md
Grep: "{name}" in docs/
```

If potential duplicate found:
> "Similar doc exists: `{path}`. Options: [proceed/update-existing/cancel]"

## Step 4: Read STYLE.md

Read `jaan-to/docs/STYLE.md` for:
- Structure rules (H1, tagline, ---)
- Length limits
- Formatting patterns

## Step 5: Gather Content

Ask up to 5 clarifying questions if needed to gather sufficient content.

**Rules**:
- Skip questions when information is already in user input or context
- Tailor questions to gaps in current knowledge
- Questions should be specific, not generic

**Question Design**:
- Reference what you already know: "You mentioned X — can you elaborate on Y?"
- Probe for missing pieces: "I have the what, but need the why..."
- Confirm assumptions: "I'm assuming X applies here — correct?"

**For each doc type, focus on answering**:

| Type | Key Questions to Answer |
|------|------------------------|
| skill | What does it do? How to use it? What to expect? |
| hook | When does it run? What does it check? What happens? |
| config | What options exist? What are defaults? When to change? |
| guide | What's the goal? What are the steps? What can go wrong? |
| concept | What is it? Why does it matter? How does it relate? |
| index | What belongs here? How to organize? What's most important? |

---

# HARD STOP - Human Review Check

Show preview:
```markdown
Ready to Create Documentation

**Type:** {type}
**Path:** {output_path}
**Title:** {title}

## Content Preview:
{first 20 lines of content}

Proceed? [y/n/edit]
```

**Do NOT proceed without explicit approval.**

---

# PHASE 2: Generation

## Step 6: Load Template

Read template for doc type from `jaan-to/templates/to-jaan-docs-create.template.md`

## Step 7: Fill Template

Replace placeholders with gathered content:
- `{title}` - Document title
- `{description}` - One-line tagline
- `{date}` - Current date (YYYY-MM-DD)
- `{tags}` - Relevant tags
- Other type-specific placeholders

## Step 8: Add Metadata

Ensure YAML frontmatter:
```yaml
---
title: {title}
doc_type: {type}
created_date: {today}
updated_date: {today}
tags: [{tags}]
related: []
---
```

## Step 9: Validate

Check against `jaan-to/docs/STYLE.md`:
- [ ] Has H1 title
- [ ] Has tagline (`>`)
- [ ] Sections separated with `---`
- [ ] Under line limit for type
- [ ] No H4+ headings

If validation fails, fix before proceeding.

## Step 10: Preview & Write

Show full preview and ask:
> "Write to `{path}`? [y/n]"

If approved, write file.

## Step 11: Commit

```bash
git add {path}
git commit -m "docs({type}): Add {name} documentation

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 12: Follow-up

Show confirmation:
```markdown
✅ Documentation created!

**File:** {path}
**Commit:** {hash}

Run `/to-jaan-docs-update` to check related docs? [y/n]
```

If yes, suggest running `/to-jaan-docs-update --quick` for related docs.

---

## Error Handling

### Invalid Type
> "Invalid type '{type}'. Valid types: skill, hook, config, guide, concept, index"

### Path Exists
> "File already exists at `{path}`. Options: [overwrite/rename/cancel]"

### Validation Failed
> "Document doesn't meet STYLE.md standards: {issues}. Fixing..."

---

## Trust Rules

1. **NEVER** overwrite without confirmation
2. **ALWAYS** preview before writing
3. **VALIDATE** against STYLE.md
4. **CHECK** for duplicates first
5. **COMMIT** with descriptive message
