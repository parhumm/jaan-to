# /to-jaan-roadmap-add

> Add a task to the jaan.to development roadmap.

---

## What It Does

Adds a new task to `.jaan-to/roadmap.md`:
- Checks for duplicates
- Detects appropriate phase
- Formats consistently
- Auto-commits the change

---

## Usage

```
/to-jaan-roadmap-add "Task description"
```

---

## Example

**Input**:
```
/to-jaan-roadmap-add "Add MCP Figma connector"
```

**Result**:
- Task added to Phase 3 (MCP + More Skills)
- Formatted as `- [ ] Add MCP Figma connector`
- Git commit created

---

## Phase Detection

The skill auto-detects which phase based on keywords:

| Phase | Keywords |
|-------|----------|
| 1 | foundation, setup, config |
| 2 | learning, context, stack |
| 3 | mcp, skill, connector |
| 4 | test, polish, fix |
| 5 | distribution, package |

---

## Output

Updates: `.jaan-to/roadmap.md`

Optional: Creates `.jaan-to/tasks/{slug}.md` for complex tasks.

---

## Note

This is an internal skill for jaan.to development. Most users won't need this.
