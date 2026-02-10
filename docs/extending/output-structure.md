# Output Structure

All skills follow the standardized ID-based folder output pattern:

```
jaan-to/outputs/{role}/{subdomain}/{id}-{slug}/
  ├── {id}-{slug}.md                  # Main file
  └── {id}-{slug}-{type}.{ext}        # Optional companion files
```

**Components:**
- **ID**: Sequential per subdomain (01, 02, 03...) - Generated automatically
- **Slug**: lowercase-kebab-case from title (max 50 chars)
- **Index**: Each subdomain has README.md with executive summaries

**Key Features:**
- **Per-subdomain IDs**: Each subdomain (pm/prd, pm/stories, data/gtm) has independent ID sequences
- **Slug reusability**: Same slug can exist across different role/subdomain combinations
  - Example: "user-auth" can appear in `pm/prd/01-user-auth/`, `data/gtm/01-user-auth/`, and `frontend/design/01-user-auth/`
- **Automatic indexing**: Skills update README.md indexes automatically after each output

**Examples:**
```
jaan-to/outputs/pm/prd/01-user-auth/
  ├── 01-user-auth.md               # Main PRD
  └── 01-user-auth-tasks.md         # Optional task breakdown

jaan-to/outputs/data/gtm/01-user-auth/
  └── 01-user-auth.md               # GTM tracking for same feature

jaan-to/outputs/pm/stories/01-login-validation/
  └── 01-login-validation.md        # User story
```

**Exceptions:**
- **Research outputs**: Use flat files (`research/{id}-{category}-{slug}.md`) instead of folders
- **Detect outputs**: Use flat files with platform-scoped filenames (`detect/{domain}/{aspect}-{platform}.md`) instead of ID-based folders
  - Rationale: Detect skills produce system state snapshots (overwritten each run), not versioned reports (archived)
  - Single-platform: `detect/dev/stack.md` (no platform suffix)
  - Multi-platform: `detect/dev/stack-web.md`, `detect/dev/stack-backend.md` (platform suffix)

See [jaan-to/outputs/README.md](jaan-to/outputs/README.md) for complete documentation.

### File Names
- Skill definition: `SKILL.md` (uppercase)
- Templates: `template.md` (lowercase)
- Learning: `LEARN.md` (uppercase, in project's `jaan-to/learn/`)
