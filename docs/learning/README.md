---
title: "Learning System"
sidebar_position: 1
---

# Learning System

> Skills improve from your feedback.

---

## How It Works

Every skill has a `LEARN.md` file. Before running, the skill reads its lessons. Your feedback shapes future behavior.

```
Run skill → Get output → Give feedback → Next run is better
```

---

## LEARN.md Structure

Four categories of lessons:

| Category | Purpose | Example |
|----------|---------|---------|
| Better Questions | Questions to ask | "Ask about i18n requirements" |
| Edge Cases | Special scenarios | "Handle multi-tenant features" |
| Workflow | Process improvements | "Generate JSON alongside PRD" |
| Common Mistakes | Things to avoid | "Don't assume single region" |

---

## Adding Lessons

Use the learn-add skill:

```
/learn-add {target} "{lesson}"
```

**Examples**:

```
/learn-add pm-prd-write "Always ask about rollback strategy"
```

```
/learn-add pm-prd-write "Check for accessibility requirements"
```

---

## Where Lessons Live

| Target | Location |
|--------|----------|
| Skills | `jaan-to/learn/{skill}.learn.md` |
| Templates | `jaan-to/learn/{skill}.learn.md` |
| Stacks | `jaan-to/learn/{skill}.learn.md` |

---

## Three Learning Layers

### 1. Skill Learning
How the skill executes.
- Better questions to ask
- Edge cases to check

### 2. Template Learning
How outputs are formatted.
- Missing sections to add
- Phrasing improvements

### 3. Stack Learning
What context matters.
- Constraints that always apply
- Team norms to remember

---

## Auto-Categorization

Lessons are categorized by keywords:

| Keywords | Category |
|----------|----------|
| ask, question, clarify | Better Questions |
| edge, special, handle | Edge Cases |
| workflow, process, step | Workflow |
| avoid, mistake, don't | Common Mistakes |

---

## Viewing Lessons

Read the LEARN.md file directly:

```
jaan-to/learn/jaan-to-pm-prd-write.learn.md
```

---

## When to Add Feedback

After any skill run where you notice:
- A question that should have been asked
- A section that was missing
- A pattern worth remembering
- A mistake to avoid

Good feedback makes the system smarter.
