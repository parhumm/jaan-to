# Configuration

> Settings, context, and safety rules.

---

## Overview

| Area | File | Purpose |
|------|------|---------|
| [Seed Files](seed-files.md) | `jaan-to/` | Default files copied on first run |
| [Stacks](stacks.md) | `jaan-to/context/*.md` | Your team and tech context |
| [Context System](context-system.md) | `jaan-to/context/` | Context injection system |
| [Permissions](permissions.md) | `.claude/settings.json` | Allow/deny rules |
| [Guardrails](guardrails.md) | `jaan-to/context/boundaries.md` | Safety boundaries |

---

## Main Config

**File**: `jaan-to/context/config.md`

Contains:
- Enabled roles
- Safety settings
- Default values

---

## Quick Setup

1. Fill your context (tech, team, integrations)
2. Permissions are pre-configured
3. Guardrails are non-negotiable

Most users only need to edit stack files.
