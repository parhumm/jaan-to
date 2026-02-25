---
title: "docs-create"
sidebar_position: 2
---

# /docs-create

> Create new documentation with standard templates.

---

## What It Does

Creates documentation files following STYLE.md standards. Includes templates for all doc types, adds proper metadata, checks for duplicates, and commits the result.

---

## Usage

```
/docs-create {type} "{name}"
```

**Types**: `skill | hook | config | guide | concept | index`

---

## What It Asks

| Question | When |
|----------|------|
| What type of doc? | If not specified |
| What's the name/title? | If not specified |
| Which role? | For skill docs |
| What does it do? | For content |
| What are the steps? | For guides |

---

## Output

| Type | Path |
|------|------|
| skill | `$JAAN_DOCS_DIR/skills/{role}/{name}.md` |
| hook | `$JAAN_DOCS_DIR/hooks/{name}.md` |
| config | `$JAAN_DOCS_DIR/config/{name}.md` |
| guide | `$JAAN_DOCS_DIR/extending/{name}.md` |
| concept | `$JAAN_DOCS_DIR/{name}.md` |
| index | `$JAAN_DOCS_DIR/{section}/README.md` |

---

## Example

**Input**:
```
/docs-create skill "test-runner"
```

**Questions**:
- Which role? → "qa"
- What does this command do? → "Runs test suites"

**Output** (`$JAAN_DOCS_DIR/skills/qa/test-runner.md`):
```markdown
---
title: Test Runner
doc_type: skill
created_date: 2026-01-26
updated_date: 2026-01-26
tags: [qa, testing]
---

# /qa-test-runner

> Runs test suites for quality assurance.

---

## What It Does
...
```

---

## Features

- **Templates** for all doc types
- **YAML metadata** with dates and tags
- **Duplicate check** before creating
- **STYLE.md validation** before writing
- **Auto-commit** with summary
- **Calls /docs-update** for related docs

---

## Tips

- Be specific with the name to avoid duplicates
- For skills, know the role beforehand
- Check the preview carefully before approving
- Use tags that help with searchability
