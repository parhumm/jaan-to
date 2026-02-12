---
title: "dev-output-integrate"
sidebar_position: 4
doc_type: skill
created_date: 2026-02-12
updated_date: 2026-02-12
tags: [dev, output, integrate, wiring, entry-points, merge, validation]
related: [dev-project-assemble, devops-deploy-activate, backend-scaffold, frontend-scaffold]
---

# /jaan-to:dev-output-integrate

> Bridge generated outputs from jaan-to/outputs/ into operational project locations.

---

## Overview

Reads generated jaan-to output files, parses their README placement instructions, and copies them into the correct project locations. Handles config file merging (package.json, tsconfig.json), entry point wiring (plugin registration, imports), dependency installation, and post-integration validation. Always shows diffs and gets approval before overwriting.

---

## Usage

```
/jaan-to:dev-output-integrate
/jaan-to:dev-output-integrate [output-path...]
```

| Argument | Required | Description |
|----------|----------|-------------|
| output-path | No | One or more paths to jaan-to output folders |

When run without arguments, scans all outputs interactively.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/dev/output-integrate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Integration log with file manifest and rollback instructions |

Also writes files directly into the project (src/, configs, etc.).

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Output selection | No arguments provided | Choose which outputs to integrate |
| Overwrite approval | File already exists | Prevent accidental data loss |
| Merge confirmation | Config files differ | Review merged content |
| Install approval | New dependencies found | User controls package installation |

---

## Workflow Chain

```
/jaan-to:backend-scaffold + /jaan-to:frontend-scaffold + /jaan-to:devops-infra-scaffold --> /jaan-to:dev-output-integrate --> /jaan-to:devops-deploy-activate
```

---

## Example

**Input:**
```
/jaan-to:dev-output-integrate jaan-to/outputs/backend/scaffold/01-my-api/
```

**Output:**
```
Files copied:        12 files
Entry points edited: 3 files (app.ts, providers.tsx, package.json)
Dependencies added:  8 packages
Validation:          TypeScript ✓, Lint ✓, Tests ✓

Integration log: jaan-to/outputs/dev/output-integrate/01-my-api-integration/01-my-api-integration.md
```

---

## Tips

- Run after all scaffold and service skills have generated their outputs
- Review the integration plan carefully before approving — especially replacements and merges
- Keep a clean git state before running so you can easily roll back with `git stash`
- Use `/jaan-to:devops-deploy-activate` next if CI/CD configs were integrated

---

## Related Skills

- [/jaan-to:dev-project-assemble](project-assemble.md) - Assemble project from scaffolds
- [/jaan-to:devops-deploy-activate](../devops/deploy-activate.md) - Activate deployment pipeline
- [/jaan-to:backend-scaffold](../backend/scaffold.md) - Generate backend code
- [/jaan-to:frontend-scaffold](../frontend/scaffold.md) - Generate frontend components

---

## Technical Details

- **Logical Name**: dev-output-integrate
- **Command**: `/jaan-to:dev-output-integrate`
- **Role**: dev
- **Output**: `$JAAN_OUTPUTS_DIR/dev/output-integrate/{id}-{slug}/`
