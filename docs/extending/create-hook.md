---
title: "Create a Hook"
sidebar_position: 2
---

# Create a Hook

> Step-by-step guide to adding automation.

---

## Overview

A hook needs:
1. Shell script in `scripts/`
2. Registration in `hooks/hooks.json` (plugin-level) or SKILL.md frontmatter (skill-scoped)

---

## Step 1: Choose Hook Type

| Type | When | Use For |
|------|------|---------|
| PreToolUse | Before action | Validation, checks |
| PostToolUse | After action | Notifications, prompts |

---

## Step 2: Create Script

**File**: `scripts/my-hook.sh`

```bash
#!/bin/bash

# Read input (JSON with tool details)
INPUT=$(cat)

# Parse what you need
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Your logic here
if [[ "$FILE_PATH" == *"pattern"* ]]; then
    # Do something
fi

# Exit codes:
# 0 = success/allow
# 1 = warning (allow with message)
# 2 = block (PreToolUse only)
exit 0
```

---

## Step 3: Make Executable

```bash
chmod +x scripts/my-hook.sh
```

---

## Step 4: Register Hook

**Plugin-level** - Edit `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write",
      "hooks": ["scripts/my-hook.sh"],
      "timeout": 5000
    }
  ]
}
```

**Skill-scoped** - Add to SKILL.md frontmatter:

```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: Write
      hooks: ["scripts/my-hook.sh"]
      timeout: 5000
---
```

---

## Hook Input Format

Hooks receive JSON via stdin:

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.md",
    "content": "file content here"
  }
}
```

---

## Exit Codes

| Code | PreToolUse | PostToolUse |
|------|------------|-------------|
| 0 | Allow | Success |
| 1 | Warn + allow | Warning |
| 2 | Block | (same as 1) |

---

## Example: Validate Markdown

```bash
#!/bin/bash

INPUT=$(cat)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# Check for required heading
if [[ ! "$CONTENT" == *"# "* ]]; then
    echo "Missing top-level heading"
    exit 2
fi

exit 0
```

---

## Example: Notify on Write

```bash
#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

echo "File created: $FILE_PATH"
echo "Don't forget to review!"

exit 0
```

---

## Tips

- Keep hooks fast (under 5 seconds)
- Use `jq` for JSON parsing
- Test manually before registering
- Log errors for debugging
- Don't block PostToolUse hooks
