# jaan.to - Claude Code Plugin Context

> Give soul to your workflow.

---

## Documentation

| Audience | Document |
|----------|----------|
| **Humans** | [docs/](docs/README.md) - Usage, examples, how-to |
| **AI** | This file - Behavioral rules, file paths |
| **Developers** | [vision-jaan-to.md](roadmaps/jaan-to/vision-jaan-to.md) - Philosophy, architecture |
| **Progress** | [roadmap-jaan-to.md](roadmaps/jaan-to/roadmap-jaan-to.md) - Tasks, phases |

---

## Plugin Architecture

This is a Claude Code Plugin. All paths below are **relative to the plugin root** unless marked as `(project)`.

## File Locations

| Component | Location | Format |
|-----------|----------|--------|
| Skills | `skills/<name>/SKILL.md` | YAML frontmatter + markdown |
| Skill Spec | `.jaan-to/docs/create-skill.md` (project) | Specification for creating skills |
| Context | `.jaan-to/context/` (project) | Markdown templates |
| Boundaries | `.jaan-to/context/boundaries.md` (project) | Markdown |
| Templates | `.jaan-to/templates/` (project) | Markdown templates |
| Hooks | `hooks/hooks.json` | JSON |
| Scripts | `scripts/` | Shell scripts |
| Agents | `agents/` | Markdown |
| Output Styles | `outputStyles/` | Markdown |
| Output | `.jaan-to/outputs/` (project) | Generated files |
| Learning | `.jaan-to/learn/` (project) | Accumulated lessons |
| Plugin Manifest | `.claude-plugin/plugin.json` | JSON |

---

## Critical Principles

### Single Source of Truth
**No duplication or overlap allowed:**
- One command per action (use existing skills, don't duplicate)
- One location per data type (roadmap tasks → roadmap-jaan-to.md)
- One skill per capability (learning → `/jaan-to:jaan-learn-add`)
- Reference, don't copy (link to sources, don't inline)

When adding functionality, first check if a skill/command exists.

---

## AI Behavioral Rules

### Trust
1. Output writes to project's `.jaan-to/outputs/` directory (project-relative)
2. Learning files write to project's `.jaan-to/learn/` directory (project-relative)
3. Context files live in project's `.jaan-to/context/` directory (project-relative)
4. Templates live in project's `.jaan-to/templates/` directory (project-relative)
5. Always preview content before writing
6. Ask for explicit approval before file operations

### Two-Phase Workflow
1. **Phase 1 (Analysis)**: Read context, gather input, plan structure
2. **HARD STOP**: Confirm with user before proceeding
3. **Phase 2 (Generation)**: Generate, validate, preview, write

### Quality
- All PRDs must have: Problem Statement, Success Metrics, Scope, User Stories
- Validation hooks enforce required sections
- Quality check before preview
- Use available **Output Styles**: `enterprise-doc`, `concise-summary`
- Use available **Agents**: `quality-reviewer`, `context-scout`

### Human-Centered
- Ask clarifying questions, don't assume
- Use templates from skill directory
- Keep humans in decision-making loop

---

## Naming Conventions

### Skills
- Public: `{role}-{domain}-{action}` → `/jaan-to:{role}-{domain}-{action}`
  Roles: pm, data, ux, qa, dev, devops
- Internal: `jaan-{domain}-{action}` → `/jaan-to:jaan-{domain}-{action}`
  For plugin development and maintenance
- Directory: `skills/{skill-name}/`

### Output Paths (Project-Relative)
```
.jaan-to/outputs/{role}/{domain}/{slug}/
```

### File Names
- Skill definition: `SKILL.md` (uppercase)
- Templates: `template.md` (lowercase)
- Learning: `LEARN.md` (uppercase, in project's `.jaan-to/learn/`)

---

## Development Workflow

### Before Every Commit
1. Update [roadmap-jaan-to.md](roadmaps/jaan-to/roadmap-jaan-to.md) with completed tasks
2. Mark tasks as `[x]` with commit hash: `- [x] Task (\`abc1234\`)`
3. For new tasks, use `/jaan-to:jaan-roadmap-add`

---

## Available Commands

| Command | Description |
|---------|-------------|
| `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| `/jaan-to:jaan-roadmap-add` | Add task to roadmap |
| `/jaan-to:jaan-learn-add` | Add lesson to LEARN.md |
| `/jaan-to:jaan-skill-create` | Create new skill |
| `/jaan-to:jaan-skill-update` | Update existing skill |
| `/jaan-to:jaan-docs-create` | Create documentation |
| `/jaan-to:jaan-docs-update` | Audit documentation |
| `/jaan-to:jaan-research-about` | Deep research on topic |
| `/jaan-to:jaan-research-add` | Add to research index |

---

## Plugin Features

### Output Styles
- `enterprise-doc` - Formal, comprehensive documentation format
- `concise-summary` - Brief, executive-level summaries

### Agents
- `quality-reviewer` - Reviews outputs for completeness and quality
- `context-scout` - Gathers relevant context before generation

---

> Give soul to your workflow.
