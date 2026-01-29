# Permissions

> Allow and deny rules for Claude Code operations.

---

## File Location

`.claude/settings.json`

---

## How It Works

Permissions control what Claude Code can do:
- **Allow**: Operations permitted without asking
- **Deny**: Operations blocked entirely

---

## Default Permissions

**Allowed**:
| Permission | Meaning |
|------------|---------|
| `Read(context/**)` | Read context files |
| `Read(skills/**)` | Read skill definitions |
| `Write(.jaan-to/**)` | Write to outputs |
| `Write(roadmaps/**)` | Update roadmaps |
| `Glob` | Search file patterns |
| `Grep` | Search file contents |

**Denied**:
| Permission | Meaning |
|------------|---------|
| `Write(src/**)` | No source code changes |
| `Write(.env*)` | No env file changes |
| `Bash(rm:*)` | No delete commands |

---

## Why These Defaults?

- Skills generate outputs, not source code
- Environment files contain secrets
- Destructive commands need explicit approval

---

## Customizing

Edit `.claude/settings.json` to add permissions:

**Add allowed path**:
```json
"allow": ["Write(docs/**)"]
```

**Add denied operation**:
```json
"deny": ["Bash(git push:*)"]
```

---

## Permission Syntax

| Pattern | Meaning |
|---------|---------|
| `Read(path/**)` | Read files under path |
| `Write(path/**)` | Write files under path |
| `Bash(command:*)` | Run bash commands starting with |
| `Glob` | File pattern search |
| `Grep` | Content search |

---

## Note

Guardrails take precedence over permissions. Even if you allow a path, boundaries may still restrict it.
