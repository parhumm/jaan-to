# /jaan-to:skill-create

> Create new jaan.to skills with interactive wizard and web research.

---

## What It Does

Guides you through creating new skills step-by-step. Performs web research to gather best practices, generates compliant skill files, creates documentation, and handles git workflow including PR creation.

---

## Usage

```
/jaan-to:skill-create [optional-skill-idea]
```

If an idea is provided, uses it as starting context. Otherwise, starts with identity questions.

---

## What It Asks

| Step | Questions |
|------|-----------|
| Identity | Role, domain, action |
| Research | (automated web search) |
| Purpose | Description, trigger phrases |
| Input/Output | Arguments, file format |
| Quality | Questions to ask, checks, done criteria |

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Duplicate Detection** | Checks existing skills, suggests reuse if >70% overlap |
| **Web Research** | Searches for domain best practices, templates, methodologies |
| **Smart Defaults** | Pre-fills suggestions from research findings |
| **Specification Compliant** | Validates against `docs/extending/create-skill.md` |
| **Git Workflow** | Creates branch, commits, offers PR creation |
| **Auto-Documentation** | Invokes `/jaan-to:docs-create` automatically |

---

## Workflow

```
1. Check for duplicate skills
2. Ask identity questions (role, domain, action)
3. Web research for best practices
4. Gather purpose, input/output, quality criteria
5. HARD STOP - preview skill structure
6. Generate SKILL.md, LEARN.md, template.md
7. Register in .jaan-to/context/config.md
8. Create documentation
9. User testing
10. Create PR
```

---

## Output

| File | Path |
|------|------|
| SKILL.md | `skills/{name}/SKILL.md` |
| LEARN.md | `.jaan-to/learn/{name}.learn.md` |
| template.md | `.jaan-to/templates/{name}.template.md` |
| Documentation | `docs/skills/{role}/{name}.md` |

---

## Example

**Input**:
```
/jaan-to:skill-create
```

**Interaction**:
```
What role does this skill serve? → ux
What domain/area? → heatmap
What action? → analyze

Skill name: ux-heatmap-analyze
Command: /ux-heatmap-analyze

Researching "heatmap analysis best practices"...

Found best practices:
1. Compare click vs scroll vs attention maps
2. Segment by device type
3. Look for rage clicks and dead clicks
...

Create this skill? [y/n]
```

---

## When NOT to Use

Skip the wizard for:
- Single-purpose skills with obvious structure
- Skills that wrap an existing command
- Internal/utility skills with <50 lines

The skill offers a fast-track option for simple cases.

---

## Tips

- Have a clear idea of role/domain/action before starting
- Accept research suggestions unless you have specific requirements
- Test the skill thoroughly before creating PR
- Use `/jaan-to:skill-update` for modifications after creation
