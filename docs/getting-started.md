# Getting Started

> Run your first skill in 5 minutes.

---

## Prerequisites

- Claude Code installed and working
- This repository cloned

---

## Step 1: Run a Skill

Type this command:

```
/jaan-to-pm-prd-write "user login feature"
```

---

## Step 2: Answer Questions

The skill asks clarifying questions:

- What problem does this solve?
- How will you measure success?
- What's explicitly NOT included?

Answer each one. The skill uses your answers to generate a better PRD.

---

## Step 3: Review Preview

Before writing, you see a preview:

```
Preview of PRD:
---
# User Login Feature
## Problem Statement
...
---
Write this PRD? [y/n]
```

Type `y` to approve.

---

## Step 4: Find Your Output

Output location:

```
.jaan-to/outputs/pm/spec/user-login/prd.md
```

Pattern: `.jaan-to/outputs/{role}/{domain}/{slug}/`

---

## Step 5: Give Feedback (Optional)

If something could be better, add a lesson:

```
/to-jaan-learn-add pm-prd-write "Always ask about password requirements"
```

Next time, the skill remembers.

---

## Next Steps

- [Concepts](concepts.md) - Understand how it works
- [Skills](skills/README.md) - See all available commands
- [Config](config/README.md) - Customize for your team
