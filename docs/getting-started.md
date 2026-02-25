---
title: "Getting Started"
sidebar_position: 2
---

# Getting Started

> Run your first skill in 5 minutes.

---

## Install

```
claude
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to
```

---

## Activate for Your Project

jaan-to is opt-in per project. Run this once in each project you want to use it:

```
/jaan-init
```

This creates the `jaan-to/` directory with config, context, templates, outputs, and learning subdirectories. Projects without `jaan-to/` are not affected by the plugin.

---

## Step 1: Run a Skill

Type this command:

```
/pm-prd-write "user login feature"
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
jaan-to/outputs/pm/user-login/prd.md
```

Pattern: `jaan-to/outputs/{role}/{domain}/{slug}/`

---

## Step 5: Give Feedback (Optional)

If something could be better, add a lesson:

```
/learn-add pm-prd-write "Always ask about password requirements"
```

Next time, the skill remembers.

---

## Next Steps

- [Concepts](concepts.md) - Understand how it works
- [Skills](skills/README.md) - See all available commands
- [Config](config/README.md) - Customize for your team
