# Naming Conventions

## Skills
- Role-based: `{role}-{domain}-{action}` → `/{role}-{domain}-{action}`
  Roles: pm, data, ux, qa, dev, devops
  Example: `pm-prd-write` → `/jaan-to:pm-prd-write`
- Internal: `{domain}-{action}` → `/jaan-to:{domain}-{action}`
  For plugin development and maintenance
  Example: `docs-create` → `/jaan-to:docs-create`
- Directory: `skills/{skill-name}/`

## Learn & Template Files
- Learn files: `jaan-to-{skill-name}.learn.md`
- Template files: `jaan-to-{skill-name}.template.md`
- Located in: `$JAAN_LEARN_DIR/` and `$JAAN_TEMPLATES_DIR/` respectively
- Prefix `jaan-to-` uses a **dash** (not colon) for cross-platform compatibility (Windows NTFS forbids colons in filenames)
