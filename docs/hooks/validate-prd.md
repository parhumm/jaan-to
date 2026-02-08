---
title: "validate-prd"
sidebar_position: 5
---

# validate-prd

> Validates PRD files have required sections before writing.

---

## When It Runs

- **Type**: PreToolUse
- **Trigger**: Write operations
- **Matches**: `jaan-to/outputs/pm/*/prd.md`

---

## What It Checks

| Section | Required |
|---------|----------|
| Problem Statement | Yes |
| Success Metrics | Yes |
| Scope | Yes |
| User Stories | Yes |

---

## Behavior

| Result | Exit Code | Action |
|--------|-----------|--------|
| All sections present | 0 | Write proceeds |
| Missing sections | 2 | Write blocked |

---

## What You See

**When validation passes**: Nothing. Write proceeds silently.

**When validation fails**:
```
PRD validation failed. Missing sections:
- Problem Statement
- Success Metrics

Please add required sections before writing.
```

---

## Why It Exists

Ensures every PRD meets minimum quality standards. Prevents incomplete outputs from being saved.

---

## Skipping

This hook cannot be skipped. Required sections are non-negotiable.
