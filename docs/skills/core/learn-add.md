# /learn-add

> Add a lesson to a skill's LEARN.md file.

---

## What It Does

Routes your feedback to the appropriate learning file. The lesson is categorized and stored so the skill can apply it in future runs.

---

## Usage

```
/learn-add {target} "{lesson}"
```

**Target options**:
- Skill name: `pm-prd-write`
- Template: `templates/prd`
- Stack: `context/tech`

---

## Examples

**Add to skill**:
```
/learn-add pm-prd-write "Always ask about API versioning"
```

**Add to template**:
```
/learn-add templates/prd "Add rollback plan section"
```

**Add to stack**:
```
/learn-add context/tech "All new services need health check"
```

---

## Categories

Lessons are auto-categorized based on keywords:

| Category | Keywords | Example |
|----------|----------|---------|
| Better Questions | ask, question, clarify | "Ask about i18n early" |
| Edge Cases | edge, special, handle | "Handle multi-tenant" |
| Workflow | workflow, process, step | "Generate JSON export" |
| Common Mistakes | avoid, mistake, don't | "Don't assume single region" |

---

## Output

Updates the target's `LEARN.md` file:
```
jaan-to/learn/{skill}.learn.md
```

---

## When to Use

After any skill run where:
- You wished it asked a different question
- The output missed an important section
- You found a common pattern to remember
- Something went wrong that should be avoided
