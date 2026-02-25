---
title: "Skills"
sidebar_position: 1
slug: /skills
---

# Skills

> Commands that generate outputs.

---

## What is a Skill?

A skill is a slash command that:
1. Reads your context (context, past lessons)
2. Asks clarifying questions
3. Generates an artifact
4. Shows preview for approval
5. Writes to `jaan-to/outputs/`

---

## Naming Pattern

Two naming conventions based on skill type:

- **Role-based**: `/{role}-{domain}-{action}` (e.g., `/pm-prd-write`)
- **Internal**: `/{domain}-{action}` (e.g., `/docs-create`)

**Examples:**
- `/pm-prd-write`
- `/skill-create`
- `/learn-add`

---

## Available Roles

| Role | Description | Status |
|------|-------------|--------|
| [pm](pm/README.md) | Product Manager | Active |
| [core](core/README.md) | System utilities | Active |
| [data](data/README.md) | Data/Analytics | Active |
| [dev](dev/README.md) | Developer | Active |
| [backend](backend/README.md) | Backend development | Active |
| [frontend](frontend/README.md) | Frontend development | Active |
| [qa](qa/README.md) | QA Engineer | Active |
| [ux](ux/README.md) | UX Designer | Active |
| [detect](detect/README.md) | Repo audits & knowledge | Active |
| [wp](wp/README.md) | WordPress | Active |
| [sec](sec/README.md) | Security | Active |
| [devops](devops/README.md) | DevOps/Infrastructure | Active |
| [release](release/README.md) | Release management | Active |
| growth | Growth/SEO | Planned |

---

## Skill Workflow

Every skill follows this flow:

```
1. LOAD
   - Read skill definition
   - Read LEARN.md (past lessons)
   - Read context (tech, team context)

2. INTERVIEW
   - Ask only necessary questions
   - Use context to reduce questions

3. GENERATE
   - Create content from template
   - Apply lessons learned

4. PREVIEW
   - Show output to user
   - Wait for approval

5. WRITE
   - Save to jaan-to/outputs/
   - Trigger post-write hooks
```

---

## Output Location

All outputs go to:

```
jaan-to/outputs/{role}/{domain}/{id}-{slug}/{id}-{slug}.md
```

Example: `jaan-to/outputs/pm/prd/01-user-auth/01-user-auth.md`
