# Stacks

> Your team and tech context. Skills read these to generate relevant outputs.

---

## What Are Stacks?

Stack files describe your environment. Instead of hardcoding context into skills, they read from context. Update once, all skills benefit.

---

## Available Stacks

| File | Purpose |
|------|---------|
| `context/tech.md` | Languages, frameworks, tools |
| `context/team.md` | Team size, ceremonies, norms |
| `context/integrations.md` | External tools config |

---

## tech.md

Describe your technology stack.

**Sections to fill**:

| Section | What to include |
|---------|-----------------|
| Languages | Backend, frontend, mobile languages |
| Frameworks | API, web, testing frameworks |
| Infrastructure | Cloud, database, cache, queue |
| Tools | CI/CD, monitoring, feature flags |
| Constraints | Rules that always apply |

**Example entries**:
- Languages: Python 3.11, TypeScript, React Native
- Database: PostgreSQL, Redis
- Constraint: "All new tables need soft delete"

---

## team.md

Describe your team context.

**Sections to fill**:

| Section | What to include |
|---------|-----------------|
| Structure | Role counts, notes |
| Ceremonies | Sprint planning, standups, retros |
| Sprint | Length, start day, estimation scale |
| Norms | Team conventions |
| Approvals | Who approves what |

**Example entries**:
- Structure: 2 backend, 2 frontend, 1 QA
- Sprint: 2 weeks, starts Monday
- Norm: "PR descriptions need Jira link"

---

## integrations.md

Describe external tool setup.

**Sections to fill**:

| Section | What to include |
|---------|-----------------|
| Issue Tracking | Jira/Linear project, board, labels |
| Source Control | GitLab/GitHub group, MR templates |
| Communication | Slack channels |
| Analytics | GA4, Mixpanel setup |
| Design | Figma, Storybook links |

**Example entries**:
- Jira project: ACME
- Slack releases: #releases
- Figma: link to design system

---

## How Skills Use Stacks

```
Skill: /jaan-to:pm-prd-write "payment feature"
       │
       ├── Reads tech.md → Knows you use PostgreSQL
       ├── Reads team.md → Knows 2-week sprints
       └── Generates PRD with relevant context
```

---

## Updating Stacks

Edit the markdown files directly. Changes apply to the next skill run.

If you learn something should always be in stack context:
```
/jaan-to:learn-add context/tech "All services need health check endpoint"
```
