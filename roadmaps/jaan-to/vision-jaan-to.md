# jaan.to: Modular Workflow Layer for Claude Code

> Simple. Learnable. Extensible.

---

## Philosophy

### 1. Minimal by Default
Start with what you need. Add as you grow. Every component is optional except core safety.

### 2. Separation of Concerns
- **Skills** know *what* to do
- **Stacks** know *how* your team works
- **Templates** know *what* outputs look like
- **Learning** knows *what went wrong before*

### 3. Documentation as the Map
Documentation is the single source of truth. Practical. Short. To the point. It's a map of the system, not a long essay. If you can't find it in the docs, it doesn't exist.

### 4. Connected to Real Systems
jaan.to works best when it can read the real codebase and platform APIs. No guessing. No hallucinating file structures. Skills read actual code, actual designs, actual analytics. This reduces errors and improves reliability.

### 5. Human-Centered by Design

This is not replacing teams.

This is standardizing execution and reducing waste. The repetitive parts—formatting PRDs, writing test matrices, generating boilerplate—get automated. The human parts stay human.

Humans become more senior:
- **Clarity** — Defining the right problem
- **Judgment** — Making trade-off decisions
- **Customer empathy** — Understanding real needs
- **Quality** — Knowing when "done" means done

We measure impact and iterate like a product. If a skill isn't helping, we fix it or remove it.

### 6. MCP as the Bridge to Reality
MCP connectors safely provide trusted context from your tools—design files, delivery status, analytics data, codebase structure. Skills stay generic. MCP provides per-product context. This means one skill definition works across teams because the real context comes from the connected systems.

### 7. Learning System
Every skill remembers. When something fails, when users give feedback, when bugs are fixed—it's captured. Next time, the skill reads its lessons first.

### 8. Extensible Everything
- Add roles without touching core
- Add skills without changing existing ones
- Override any template at any layer
- Customize any stack for your team

### 9. Practical Over Perfect
Ship working outputs. Iterate based on feedback. The system learns and improves.

### 10. Tested and Complete
All skills have end-to-end tests and a clear Definition of Done (DoD). The job is completed fully. No half-finished outputs. No "you'll need to also do X manually."

---

## Core Concepts

### Commands
```
/ROLE-DOMAIN:ACTION [input]
```

That's it. Every command follows this pattern.

### Layers

```
YOU USE:     /pm:prd-write "user import feature"
                    │
SKILL READS: ├── skills/pm/spec/SKILL.md        (what to do)
             ├── skills/pm/spec/LEARN.md        (past lessons)
             ├── context/current.md              (your tech context)  
             ├── templates/prd.md               (output format)
             └── MCP: Figma, Jira, GitLab       (real system data)
                    │
OUTPUT:      .jaan-to/outputs/pm/spec/user-import/prd.md
```

---

## Which MCP Powers Which Skill Cluster

Skills stay generic. MCP provides real context.

| Skill Cluster | MCP Connectors |
|---------------|----------------|
| **PRD + Planning** | Figma, GA4, Clarity, Jira, GitLab, Filesystem |
| **Backlog + Delivery** | Jira, GitLab, OpenAPI (dependency visibility) |
| **UX + Research** | Figma, Clarity, GSC (web/SEO insights) |
| **Data + Analytics** | GA4, GTM, Clarity, GSC, BigQuery |
| **Engineering** | GitLab, OpenAPI→MCP, Filesystem, Sentry |
| **QA + Testing** | GitLab, Postman, Playwright, Sentry, Filesystem |
| **Growth + SEO** | GSC, GA4, GTM, Ahrefs/SEMrush (if available) |
| **DevOps + Infra** | GitLab, AWS/GCP APIs, Terraform state, Datadog |

### How It Works

```
Skill: /dev-plan:tech-approach "payment service"
                │
                ├── MCP: GitLab → reads current repo structure
                ├── MCP: OpenAPI → reads existing API contracts
                ├── MCP: Sentry → reads recent error patterns
                │
                └── Skill generates plan with REAL context
```

No guessing. No "assuming you have a typical setup." Real data.

---

## Directory Structure

```
jaan-to/
│
├── skills/                    # What to do (by role)
│   ├── pm/
│   │   ├── spec/
│   │   │   ├── SKILL.md       # Skill definition
│   │   │   └── LEARN.md       # Accumulated lessons
│   │   └── .../
│   ├── dev/
│   ├── qa/
│   └── [add-your-role]/       # Extensible
│
├── context/                    # Tech & team context (shared)
│   ├── tech.md                # Languages, frameworks, tools
│   ├── team.md                # Team structure, ceremonies
│   ├── integrations.md        # Jira, GitLab, Slack config
│   └── [add-your-stack].md    # Extensible
│
├── templates/                 # Output formats (shared)
│   ├── prd.md
│   ├── test-plan.md
│   ├── api-contract.md
│   ├── LEARN.md               # Template-level lessons
│   └── [add-your-template].md # Extensible
│
├── boundaries/                # Safety (don't touch)
│   ├── safe-paths.md
│   └── secrets.md
│
├── tests/                     # End-to-end skill tests
│   └── [skill-name].test.md
│
└── config.md                  # Simple settings
```

---

## The Learning System

Learning happens at three layers. Each layer improves different aspects.

### Layer 1: Skill Learning

**What it improves:** How execution happens

Every skill has a `LEARN.md` file that captures:
- Better questions to ask
- Edge cases to check
- Workflow improvements
- Common mistakes to avoid

```markdown
# Lessons: pm:prd-write

## Better Questions
- Always ask about internationalization requirements
- Ask "who else needs to approve this?" early

## Edge Cases
- Multi-tenant features need tenant isolation section
- API changes need versioning strategy

## Workflow
- Generate metrics JSON alongside PRD for data team handoff
```

### Layer 2: Template Learning

**What it improves:** How outputs are written

Templates have their own `LEARN.md`:
- Missing sections that users always add
- Phrasing that causes confusion
- Structure improvements
- Consistency patterns

```markdown
# Lessons: templates/prd.md

## Missing Sections
- Added "Accessibility Considerations" — always needed
- Added "Rollback Plan" — requested 3x

## Phrasing
- Changed "Requirements" to "What We're Building" — clearer
- Error messages need to say what TO DO, not just what failed

## Structure
- Put "Out of Scope" right after "In Scope" — reduces questions
```

### Layer 3: Stack Learning

**What it improves:** Which context matters

Stacks learn what's actually relevant for your team:
- Tech constraints that always apply
- Team norms that affect output
- Integration quirks to remember

```markdown
# Lessons: context/tech.md

## Constraints That Always Apply
- All new tables need soft delete (company policy)
- React components must have Storybook stories

## Team Norms
- PR descriptions need Jira link in first line
- QA needs 2 days notice for any release

## Integration Quirks
- Jira API rate limits at 100 req/min — batch updates
- GitLab MR approvals reset on force push
```

### How Learning Updates

```
┌─────────────────────────────────────────────────────────────┐
│  BEFORE EXECUTION                                           │
│  ───────────────────────────────────────────────────────    │
│  1. Read skills/[role]/[domain]/LEARN.md                    │
│  2. Read templates/[output].LEARN.md (if exists)            │
│  3. Read context/LEARN.md (if exists)                        │
│  4. Apply all lessons to current execution                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  EXECUTION                                                  │
│  ───────────────────────────────────────────────────────    │
│  Skill runs with all lessons applied                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  AFTER EXECUTION                                            │
│  ───────────────────────────────────────────────────────    │
│  User feedback → routes to appropriate LEARN.md:            │
│  • "Ask this earlier" → Skill learning                      │
│  • "Missing section" → Template learning                    │
│  • "Didn't know about X" → Stack learning                   │
└─────────────────────────────────────────────────────────────┘
```

### Updating Lessons

After any skill run:
```
/learn:add "pm:prd-write" "Always ask about internationalization requirements"
```

Or route to template:
```
/learn:add "templates/prd" "Add rollback plan section"
```

Or route to stack:
```
/learn:add "context/tech" "All new services need health check endpoint"
```

---

## Stacks: Separate Context from Skills

Skills don't hardcode your tech stack. They read from `context/`.

### context/tech.md

```markdown
# Tech Stack

## Languages
- Backend: Python 3.11, FastAPI
- Frontend: TypeScript, React 18
- Mobile: React Native

## Infrastructure
- Cloud: AWS
- Database: PostgreSQL, Redis
- Queue: SQS

## Tools
- CI/CD: GitHub Actions
- Monitoring: Datadog
- Feature Flags: LaunchDarkly
```

### context/team.md

```markdown
# Team Context

## Structure
- 2 Backend engineers
- 2 Frontend engineers  
- 1 QA
- 1 Designer (part-time)

## Ceremonies
- Sprint: 2 weeks
- Planning: Mondays
- Retro: Every other Friday

## Estimation
- Scale: 1, 2, 3, 5, 8
- Unit: Story points
```

### context/integrations.md

```markdown
# Integrations

## Jira
- Project: ACME
- Board: Sprint Board
- Default labels: from-aios

## GitLab
- Group: acme/backend
- MR Template: .gitlab/merge_request_templates/default.md

## Slack
- Releases: #releases
- Alerts: #engineering-alerts
```

### Why Separate?

| Before (Hardcoded) | After (Stacks) |
|--------------------|----------------|
| Every skill knows your tech | One place to update |
| Change framework = edit 40 skills | Change framework = edit 1 file |
| New team = copy & modify everything | New team = new stack file |

---

## Templates: Separate Format from Logic

Skills generate content. Templates define format.

### How It Works

```
Skill: "I need to output a PRD"
        │
        ├── Check: templates/prd.md exists?
        │   ├── Yes → Use it
        │   └── No → Use built-in default
        │
        └── Fill template with generated content
```

### Template Override Priority

```
1. .jaan-to/templates/prd.md        (repo-local, highest priority)
2. templates/prd.md              (plugin-level)
3. Built-in default              (fallback)
```

### Custom Templates

Want PRDs in a different format? Create `.jaan-to/templates/prd.md`:

```markdown
# {title}

## TL;DR
{summary}

## The Problem
{problem}

## The Solution
{solution}

## How We'll Know It Works
{metrics}

## What's NOT Included
{out_of_scope}
```

That's it. Skill uses your format automatically.

---

## Skill Catalog

### Core Roles (Built-in)

| Role | Domain | Skills |
|------|--------|--------|
| **pm** | Product Manager | spec, metrics, discovery, plan, release |
| **po** | Product Owner | backlog, stories, sprint, delivery, release |
| **ux** | UX/Design | research, spec, content, review, benchmark |
| **data** | Analytics | events, metrics, insights, experiment, monitoring |
| **dev** | Engineering | plan, contract, test, review, release |
| **qa** | Quality | plan, automation, regression, bugs, signoff |
| **growth** | Growth/SEO | seo, content, experiment, analytics, report |

### Adding a New Role

Create folder, add skills:

```
skills/
└── devops/                    # New role
    ├── infra/
    │   ├── SKILL.md
    │   └── LEARN.md
    └── pipeline/
        ├── SKILL.md
        └── LEARN.md
```

Register in `config.md`:

```markdown
## Roles
- pm
- dev
- qa
- devops  # Added
```

Done. Commands like `/devops-infra:provision` now work.

---

## Skill Definition (SKILL.md)

Keep it simple:

```markdown
# pm:prd-write

## Purpose
Generate a PRD from initiative description.

## Input
- initiative: What to build (required)

## Output
- .jaan-to/outputs/pm/spec/{slug}/prd.md
- .jaan-to/outputs/pm/spec/{slug}/prd.json

## MCP Context
- Figma: Read linked designs
- Jira: Check existing related tickets
- GA4: Pull relevant baseline metrics

## Process
1. Read context/tech.md for technical context
2. Read context/team.md for team context
3. Read LEARN.md for past lessons
4. Connect MCP for real system data
5. Ask for missing info (minimal questions)
6. Generate PRD using templates/prd.md
7. Run quality checks
8. Show preview, get approval
9. Write files

## Quality Checks
- [ ] Has problem statement
- [ ] Has success metrics with numbers
- [ ] Has "out of scope" section
- [ ] Has user stories

## Definition of Done
- [ ] PRD written and approved
- [ ] JSON export created for data team
- [ ] Linked to Jira epic (if configured)
- [ ] Stakeholders notified (if configured)

## Questions (only if needed)
- "What problem does this solve?"
- "How will you measure success?"
- "What's explicitly NOT included?"
```

---

## Testing Skills

Every skill has tests. Tests live in `tests/`.

### Test Structure

```markdown
# Test: pm:prd-write

## Setup
- Input: "user import feature"
- Stacks: test fixtures
- MCP: mocked responses

## Expected Output
- File created: .jaan-to/outputs/pm/spec/user-import/prd.md
- Contains: Problem statement
- Contains: Success metrics with numbers
- Contains: Out of scope section

## Edge Cases
- Empty input → prompts for initiative
- No Figma linked → skips design section gracefully
- Jira unavailable → continues without ticket link

## Definition of Done Verification
- [ ] All output files exist
- [ ] Quality checks pass
- [ ] No manual steps remain
```

### Running Tests

```
/aios:test pm:prd-write
/aios:test --all
```

---

## Execution Flow

```
USER: /pm:prd-write "user import feature"

1. LOAD
   ├── skills/pm/spec/SKILL.md
   ├── skills/pm/spec/LEARN.md (3 lessons)
   ├── templates/prd.md
   ├── templates/LEARN.md (2 lessons)
   ├── context/tech.md (Python, FastAPI, PostgreSQL)
   ├── context/team.md (2 BE, 2 FE, 2-week sprints)
   └── context/LEARN.md (1 lesson)

2. MCP CONNECT
   ├── Figma: Found 2 linked designs
   ├── Jira: Found related epic ACME-123
   └── GA4: Pulled baseline metrics

3. INTERVIEW (only missing info)
   └── "How will you measure success?"

4. GENERATE
   └── Create PRD content with real context

5. CHECK
   ├── ✓ Has problem statement
   ├── ✓ Has metrics (from GA4 baseline)
   ├── ✓ Has out of scope
   └── ✓ Has user stories

6. PREVIEW
   └── "Write this PRD? [y/n]"

7. WRITE
   └── .jaan-to/outputs/pm/spec/user-import/prd.md

8. COMPLETE DoD
   ├── ✓ JSON export created
   ├── ✓ Linked to ACME-123
   └── ✓ Notified #product-specs

9. LEARN
   └── "Any feedback? (optional)"
```

---

## Trust

### Non-Negotiable (Core)

| Rule | Description |
|------|-------------|
| **Safe Paths** | Only write to `.jaan-to/` by default |
| **No Secrets** | Scan all output for credentials |
| **Preview First** | Always show before writing |
| **Approval for External** | Jira/GitLab/Slack needs explicit yes |

### Configurable (Team)

Add to `config.md`:

```markdown
## Trust Overrides
- safe_paths: [".jaan-to/", "docs/"]
- skip_preview: false
- auto_approve_internal: true
```

---

## Configuration

One file: `config.md`

```markdown
# jaan.to Configuration

## Enabled Roles
- pm
- dev
- qa

## Language
- output: en
- rtl: false

## MCP Connections
- figma: enabled
- jira: enabled
- gitlab: enabled
- ga4: enabled

## Trust
- safe_paths: [".jaan-to/", "docs/"]
- require_preview: true
- require_approval_external: true

## Defaults
- estimation_unit: points
- estimation_scale: [1, 2, 3, 5, 8]
```

That's the entire configuration. No JSON schemas. No nested objects. Just markdown.

---

## Extending jaan.to

### Add a Role

```
1. Create skills/[role]/
2. Add skill folders with SKILL.md
3. Add role to config.md
```

### Add a Skill

```
1. Create skills/[role]/[domain]/SKILL.md
2. Add LEARN.md (starts empty)
3. Add test in tests/
4. Done (auto-discovered)
```

### Add a Template

```
1. Create templates/[name].md
2. Reference in SKILL.md output section
3. Done
```

### Add a Stack

```
1. Create context/[name].md
2. Reference in skills that need it
3. Done
```

### Add MCP Connection

```
1. Configure in config.md under MCP Connections
2. Reference in SKILL.md under MCP Context
3. Done
```

### Override Anything

```
1. Create .jaan-to/[path]/[file].md in your repo
2. It takes priority over plugin version
3. Done
```

---

## Example: Full Flow

### 1. User Runs Command

```
/dev-plan:tech-approach "payment service"
```

### 2. System Loads Context

```
Loading:
  ✓ skills/dev/plan/SKILL.md
  ✓ skills/dev/plan/LEARN.md (3 lessons)
  ✓ templates/tech-approach.md
  ✓ context/tech.md (Python, FastAPI, PostgreSQL)
  ✓ context/team.md (2 BE, 2 FE, 2-week sprints)

MCP connecting:
  ✓ GitLab: Read repo structure
  ✓ OpenAPI: Found 3 existing API contracts
  ✓ Sentry: Pulled recent error patterns
```

### 3. Lessons Applied

```
From LEARN.md:
  • Always consider database migrations
  • Include rollback strategy
  • Check for feature flag requirements
```

### 4. Minimal Interview

```
Q: "Any specific constraints?"
A: "Must be backward compatible with v1 API"
```

### 5. Output Generated

```
.jaan-to/outputs/dev/plan/payment-service/
├── tech-approach.md
├── architecture.mermaid
└── tasks.json
```

### 6. Definition of Done Completed

```
✓ Tech approach document written
✓ Architecture diagram generated
✓ Tasks exported to JSON
✓ Linked to GitLab epic
```

### 7. Feedback Captured

```
User: "Good, but add performance testing section"
→ Added to skills/dev/plan/LEARN.md
```

---

## Quick Reference

### All Commands Pattern

```
/[role]-[domain]:[action] [input]
```

### Key Paths

| Path | Purpose |
|------|---------|
| `skills/` | What to do |
| `context/` | Your context |
| `templates/` | Output formats |
| `boundaries/` | Safety rules |
| `tests/` | Skill tests |
| `.jaan-to/outputs/` | All outputs |
| `*/LEARN.md` | Accumulated lessons |

### Key Files

| File | Purpose |
|------|---------|
| `config.md` | Global settings |
| `context/tech.md` | Your technology |
| `context/team.md` | Your team |
| `context/integrations.md` | External tools |

---

## Summary

**jaan.to is:**

- ✅ **Modular** — Skills, context, templates are separate
- ✅ **Connected** — MCP bridges skills to real systems
- ✅ **Learnable** — Three layers of learning (skill, template, stack)
- ✅ **Tested** — Every skill has tests and Definition of Done
- ✅ **Extensible** — Add roles, skills, templates easily
- ✅ **Customizable** — Override anything at any layer
- ✅ **Safe** — Non-negotiable boundaries, configurable everything else
- ✅ **Human-centered** — Standardizes execution, humans stay senior
- ✅ **Simple** — Markdown files, no complex schemas

**This is not replacing teams. This is making teams faster.**

Start minimal. Learn fast. Extend as needed.