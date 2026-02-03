# Documentation Style Guide

> Rules for writing jaan.to documentation.

---

## Audience

| Document | Audience | Focus |
|----------|----------|-------|
| `docs/*` | Humans | Usage, examples, how-to |
| `CLAUDE.md` | AI | Behavioral rules, paths |
| `vision.md` | Developers | Architecture concepts |

---

## What to Document

### DO Document

- **What it does** - Purpose in 1-2 sentences
- **How to use it** - Command/usage example
- **What to expect** - Output location, format
- **Real examples** - Input → Output walkthrough
- **Common tips** - Best practices, gotchas

### DON'T Document

- Implementation details (how code works internally)
- Full code blocks (show structure, not implementation)
- Edge cases users won't encounter
- Version history or changelog
- Future plans (belongs in roadmap)
- Duplicate information (link instead)

---

## Tone of Voice

### Be

- **Direct** - Say what it does, not what it might do
- **Concise** - One idea per sentence
- **Active** - "The skill generates..." not "A PRD is generated..."
- **Practical** - Focus on doing, not explaining

### Avoid

- Jargon without explanation
- Marketing language ("powerful", "seamless")
- Hedging ("might", "could", "possibly")
- Long paragraphs (max 3 sentences)

### Examples

| Bad | Good |
|-----|------|
| "This powerful skill might help you create PRDs" | "Generates a PRD from your feature idea" |
| "The system will attempt to validate" | "Validates required sections before writing" |
| "You could potentially use this for..." | "Use this when..." |

---

## Structure Rules

### Every File Must Have

1. **H1 title** - Name of the thing
2. **Tagline** - One sentence in `>` blockquote
3. **Separator** - `---` after tagline
4. **Sections** - Logical groupings with H2

### Section Separators

Use `---` between major sections:

```markdown
# Title

> Tagline here.

---

## Section 1

Content...

---

## Section 2

Content...
```

### Heading Levels

| Level | Use For |
|-------|---------|
| H1 | Document title (once) |
| H2 | Major sections |
| H3 | Subsections (sparingly) |
| H4+ | Never use |

---

## Formatting Patterns

### Tables

Use for reference data and comparisons:

```markdown
| Command | Description | Output |
|---------|-------------|--------|
| `/skill` | What it does | Where it writes |
```

### Lists

- **Bullets** - Unordered items
- **Numbers** - Sequential steps

### Bold

Use for:
- Key terms on first use
- Labels in descriptions
- Important warnings

### Code Blocks

Use for:
- Commands to run
- File paths
- Output examples

NOT for:
- Full implementation code
- Long configuration files

---

## Document Templates

### Skill Documentation

```markdown
# /command-name

> One-line description.

---

## What It Does

2-3 sentences.

---

## Usage

/command-name "input"

---

## What It Asks

| Question | Why |
|----------|-----|

---

## Output

**Path**: `jaan-to/outputs/...`

---

## Example

Input → Output

---

## Tips

- Tip 1
- Tip 2
```

### Hook Documentation

```markdown
# hook-name

> One-line description.

---

## When It Runs

- **Type**: PreToolUse/PostToolUse
- **Trigger**: What triggers it

---

## What It Does

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|

---

## What You See

Example output.
```

### Config Documentation

```markdown
# Config Topic

> One-line description.

---

## What Is It?

---

## Options

| Option | Purpose |
|--------|---------|

---

## How to Configure

---

## Examples
```

---

## Length Guidelines

| Type | Target | Max |
|------|--------|-----|
| README/Index | 50-70 | 100 |
| Skill doc | 80-120 | 150 |
| Hook doc | 40-60 | 80 |
| Config doc | 60-100 | 120 |
| Guide | 100-150 | 200 |

---

## Links

### Internal

Use relative paths:
```markdown
[Learn more](../config/context.md)
```

### Cross-References

End sections with related links:
```markdown
[Learn more](hooks/README.md)
```

---

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Index | `README.md` | `docs/skills/README.md` |
| Skill | `{action}.md` | `prd-write.md` |
| Hook | `{hook-name}.md` | `validate-prd.md` |
| Guide | `{verb}-{noun}.md` | `create-skill.md` |

---

## What NOT to Include

1. **No implementation code** - Show structure only
2. **No version numbers** - Unless critical
3. **No dates** - Except LEARN.md
4. **No author names** - Project-owned
5. **No TODOs** - Use roadmap
6. **No opinions** - Facts and usage only

---

## Quality Checklist

- [ ] Has H1 title and tagline
- [ ] Sections separated with `---`
- [ ] Under line limit
- [ ] No duplicate info (linked instead)
- [ ] All links work
- [ ] Examples are concrete
- [ ] No implementation code
- [ ] Direct, active tone
