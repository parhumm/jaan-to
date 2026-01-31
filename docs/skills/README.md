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

- **Role-based**: `/jaan-to-{role}-{domain}-{action}` (e.g., `/jaan-to-pm-prd-write`)
- **Internal**: `/to-jaan-{domain}-{action}` (e.g., `/to-jaan-docs-create`)

**Examples:**
- `/jaan-to-pm-prd-write`
- `/to-jaan-skill-create`
- `/to-jaan-learn-add`

---

## Available Roles

| Role | Description | Status |
|------|-------------|--------|
| [pm](pm/README.md) | Product Manager | Active |
| [core](core/README.md) | System utilities | Active |
| [data](data/README.md) | Data/Analytics | Active |
| dev | Developer | Planned |
| qa | QA Engineer | Planned |
| ux | UX Designer | Planned |
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
jaan-to/outputs/{role}/{domain}/{slug}/
```

Example: `jaan-to/outputs/pm/user-auth/prd.md`
