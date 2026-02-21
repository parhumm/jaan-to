# Naming Conventions

## Skills
- Role-based: `{role}-{domain}-{action}` → `/{role}-{domain}-{action}`
  Roles: pm, data, ux, qa, dev, devops
  Example: `pm-prd-write` → `/jaan-to:pm-prd-write`
- Internal: `{domain}-{action}` → `/jaan-to:{domain}-{action}`
  For plugin development and maintenance
  Example: `docs-create` → `/jaan-to:docs-create`
- Directory: `skills/{skill-name}/`
