# capture-feedback

> Prompts for feedback after artifact creation.

---

## When It Runs

- **Type**: PostToolUse
- **Trigger**: Write operations
- **Matches**: `jaan-to/outputs/*`

---

## What It Does

After an artifact is written, displays a reminder:

```
Artifact created: jaan-to/outputs/pm/user-auth/prd.md

Have feedback? Run:
/learn-add pm-prd-write "your feedback here"
```

---

## Behavior

- Always exits 0 (never blocks)
- Only triggers for outputs (not internal files)
- Non-intrusive reminder

---

## Why It Exists

Creates a feedback loop. When you notice something that could be better, you're reminded how to capture it.

Good feedback improves future skill runs.

---

## Examples of Good Feedback

After the prompt, you might add:

```
/learn-add pm-prd-write "Ask about rollback strategy"
```

```
/learn-add pm-prd-write "Include accessibility section"
```

```
/learn-add pm-prd-write "Don't assume mobile support"
```
