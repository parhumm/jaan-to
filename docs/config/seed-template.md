---
title: Template Seeding Script
sidebar_position: 7
doc_type: config
created_date: 2026-02-12
updated_date: 2026-02-12
tags: [config, templates, seeding, scripts]
related: [seed-files.md, ../extending/pre-execution-protocol.md, ../guides/customization.md]
---

# Template Seeding Script

> Copies a skill's plugin template into the project for customization.

---

## What Is It?

A helper script called by the [pre-execution protocol Step C](../extending/pre-execution-protocol.md#step-c-offer-template-seeding). When a skill resolves its template from the plugin source fallback, the protocol asks if you want a local copy. This script handles the file copy.

---

## File Location

`scripts/seed-template.sh`

---

## How It Works

1. The pre-execution protocol resolves a skill's template using the 3-tier fallback
2. If the template came from the plugin source (tier 3), the protocol asks: "Copy to project? [y/n]"
3. If you accept, the protocol runs `seed-template.sh {skill-name}`
4. The script copies `skills/{skill}/template.md` to `$JAAN_TEMPLATES_DIR/jaan-to:{skill}.template.md`
5. Future runs find the project copy at tier 1 and skip the offer

---

## Usage

```
scripts/seed-template.sh <skill-name>
```

You don't call this directly. The pre-execution protocol invokes it when you accept the seeding offer.

---

## Output

The script returns JSON to stdout:

| Status | Meaning |
|--------|---------|
| `{"status": "seeded", "path": "..."}` | Template copied to project |
| `{"status": "skipped", "path": "..."}` | Project template already exists |
| `{"status": "error", "message": "..."}` | Plugin template not found |

---

## Examples

**First run of a skill** (no project template):
```
$ scripts/seed-template.sh pm-prd-write
{"status": "seeded", "path": "jaan-to/templates/jaan-to:pm-prd-write.template.md"}
```

**Second run** (project template exists):
```
$ scripts/seed-template.sh pm-prd-write
{"status": "skipped", "path": "jaan-to/templates/jaan-to:pm-prd-write.template.md"}
```

---

## Tips

- Delete a seeded template to re-trigger the offer on next skill run
- Edit the seeded file to customize how a skill structures its output
- The script respects `paths_templates` from `settings.yaml` for custom template directories

---

## Related

- [Seed Files](seed-files.md) -- What gets seeded during bootstrap
- [Pre-Execution Protocol](../extending/pre-execution-protocol.md) -- Step C that triggers this script
- [Customization Guide](../guides/customization.md) -- Template override options
