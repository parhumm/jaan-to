# Documentation Templates

> Templates for all doc types. Copy the appropriate section.

---

## Skill Template

Use for: `$JAAN_DOCS_DIR/skills/{role}/{name}.md`

```markdown
---
title: {title}
doc_type: skill
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# /{command-name}

> {description}

---

## What It Does

{explanation}

---

## Usage

```
/{command-name} "{input}"
```

---

## What It Asks

| Question | Why |
|----------|-----|
| {question1} | {reason1} |
| {question2} | {reason2} |

---

## Output

**Path**: `{output_path}`

**Contains**:
- {section1}
- {section2}

---

## Example

**Input**:
```
/{command-name} "{example_input}"
```

**Output** (`{example_path}`):
```
{example_output_snippet}
```

---

## Tips

- {tip1}
- {tip2}
```

---

## Hook Template

Use for: `$JAAN_DOCS_DIR/hooks/{name}.md`

```markdown
---
title: {title}
doc_type: hook
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# {hook-name}

> {description}

---

## When It Runs

- **Type**: {PreToolUse|PostToolUse}
- **Trigger**: {trigger_operation}
- **Matches**: `{file_pattern}`

---

## What It Does

{explanation}

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|
| Success | 0 | {action} |
| Warning | 1 | {action} |
| Block | 2 | {action} |

---

## What You See

**When {condition}**:
```
{example_output}
```

---

## Why It Exists

{rationale}
```

---

## Config Template

Use for: `$JAAN_DOCS_DIR/config/{name}.md`

```markdown
---
title: {title}
doc_type: config
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# {topic}

> {description}

---

## What Is It?

{explanation}

---

## File Location

`{file_path}`

---

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| {option1} | {type} | {default} | {description} |
| {option2} | {type} | {default} | {description} |

---

## How to Configure

{step_by_step_instructions}

---

## Examples

**Example 1: {scenario}**
```
{example_config}
```

**Example 2: {scenario}**
```
{example_config}
```
```

---

## Guide Template

Use for: `$JAAN_DOCS_DIR/extending/{name}.md`

```markdown
---
title: {title}
doc_type: guide
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# {title}

> {description}

---

## Overview

{what_you_will_learn}

---

## Prerequisites

- {prereq1}
- {prereq2}

---

## Step 1: {step_title}

{step_content}

---

## Step 2: {step_title}

{step_content}

---

## Step 3: {step_title}

{step_content}

---

## Verification

How to verify it worked:
- {check1}
- {check2}

---

## Tips

- {tip1}
- {tip2}

---

## Troubleshooting

**Issue: {problem}**
Solution: {solution}
```

---

## Concept Template

Use for: `$JAAN_DOCS_DIR/{name}.md`

```markdown
---
title: {title}
doc_type: concept
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# {title}

> {description}

---

## What Is It?

{explanation}

---

## Key Points

- **{point1}** - {explanation}
- **{point2}** - {explanation}
- **{point3}** - {explanation}

---

## How It Works

{detailed_explanation}

---

## Examples

{examples_with_context}

---

## Related

- [{related1}]({path1})
- [{related2}]({path2})
```

---

## Index Template

Use for: `$JAAN_DOCS_DIR/{section}/README.md`

```markdown
---
title: {title}
doc_type: index
created_date: {date}
updated_date: {date}
tags: [{tags}]
related: []
---

# {section_title}

> {description}

---

## Overview

{what_this_section_covers}

---

## Contents

| Document | Description |
|----------|-------------|
| [{doc1}]({path1}) | {desc1} |
| [{doc2}]({path2}) | {desc2} |
| [{doc3}]({path3}) | {desc3} |

---

## Quick Reference

{quick_summary_or_table}
```

---

## Metadata Reference

All templates use this YAML frontmatter:

```yaml
---
title: Document Title           # Required
doc_type: skill|hook|config|guide|concept|index  # Required
created_date: YYYY-MM-DD        # Required, set on creation
updated_date: YYYY-MM-DD        # Required, update on changes
tags: [tag1, tag2]              # Required, relevant keywords
related: [path/to/related.md]   # Optional, related docs
---
```

---

## Length Limits

| Type | Target | Max |
|------|--------|-----|
| skill | 80-120 | 150 |
| hook | 40-60 | 80 |
| config | 60-100 | 120 |
| guide | 100-150 | 200 |
| concept | 60-100 | 120 |
| index | 50-70 | 100 |
