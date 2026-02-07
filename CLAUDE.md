# jaan.to - Claude Code Plugin Context

> Give soul to your workflow.

---

## Documentation

| Audience | Document |
|----------|----------|
| **Humans** | [docs/](docs/README.md) - Usage, examples, how-to |
| **AI** | This file - Behavioral rules, file paths |
| **Developers** | [vision.md](roadmaps/jaan-to/vision.md) - Philosophy, architecture |
| **Progress** | [roadmap.md](roadmaps/jaan-to/roadmap.md) - Tasks, phases |

---

## Plugin Architecture

This is a Claude Code Plugin. All paths below are **relative to the plugin root** unless marked as `(project)`.

## File Locations

| Component | Location | Format | Customizable |
|-----------|----------|--------|--------------|
| Skills | `skills/<name>/SKILL.md` | YAML frontmatter + markdown | No |
| Skill Spec | `jaan-to/docs/create-skill.md` (project) | Specification for creating skills | No |
| Config | `jaan-to/config/settings.yaml` (project) | YAML | Yes |
| Context | `jaan-to/context/` (project) | Markdown templates | Yes |
| Boundaries | `jaan-to/context/boundaries.md` (project) | Markdown | Yes |
| Templates | `jaan-to/templates/` (project) | Markdown templates | Yes |
| Hooks | `hooks/hooks.json` | JSON | No |
| Scripts | `scripts/` | Shell scripts | No |
| Agents | `agents/` | Markdown | No |
| Output | `jaan-to/outputs/` (project) | Generated files | Via config |
| Learning | `jaan-to/learn/` (project) | Accumulated lessons | Via config |
| Plugin Manifest | `.claude-plugin/plugin.json` | JSON | No |
| Plugin Defaults | `config/defaults.yaml` | YAML | No |

---

## Critical Principles

### Single Source of Truth
**No duplication or overlap allowed:**
- One command per action (use existing skills, don't duplicate)
- One location per data type (roadmap tasks → roadmap.md)
- One skill per capability (learning → `/jaan-to:learn-add`)
- Reference, don't copy (link to sources, don't inline)

When adding functionality, first check if a skill/command exists.

---

## AI Behavioral Rules

### Trust
1. Output writes to project's `jaan-to/outputs/` directory (project-relative)
2. Learning files write to project's `jaan-to/learn/` directory (project-relative)
3. Context files live in project's `jaan-to/context/` directory (project-relative)
4. Templates live in project's `jaan-to/templates/` directory (project-relative)
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
- Use available **Agents**: `quality-reviewer`, `context-scout`

### Human-Centered
- Ask clarifying questions, don't assume
- Use templates from skill directory
- Keep humans in decision-making loop

---

## Naming Conventions

### Skills
- Role-based: `{role}-{domain}-{action}` → `/jaan-to:{role}-{domain}-{action}`
  Roles: pm, data, ux, qa, dev, devops
  Example: `pm-prd-write` → `/jaan-to:pm-prd-write`
- Internal: `{domain}-{action}` → `/jaan-to:{domain}-{action}`
  For plugin development and maintenance
  Example: `docs-create` → `/jaan-to:docs-create`
- Directory: `skills/{skill-name}/`

### Output Structure

All skills follow the standardized ID-based folder output pattern:

```
jaan-to/outputs/{role}/{subdomain}/{id}-{slug}/
  ├── {id}-{report-type}-{slug}.md    # Main file
  └── {id}-{aux-type}-{slug}.md       # Optional auxiliary files
```

**Components:**
- **ID**: Sequential per subdomain (01, 02, 03...) - Generated automatically
- **Slug**: lowercase-kebab-case from title (max 50 chars)
- **Report type**: Subdomain name (prd, story, gtm, tasks, etc.)
- **Index**: Each subdomain has README.md with executive summaries

**Key Features:**
- **Per-subdomain IDs**: Each subdomain (pm/prd, pm/stories, data/gtm) has independent ID sequences
- **Slug reusability**: Same slug can exist across different role/subdomain combinations
  - Example: "user-auth" can appear in `pm/prd/01-user-auth/`, `data/gtm/01-user-auth/`, and `dev/frontend/01-user-auth/`
- **Automatic indexing**: Skills update README.md indexes automatically after each output

**Examples:**
```
jaan-to/outputs/pm/prd/01-user-auth/
  ├── 01-prd-user-auth.md           # Main PRD
  └── 01-prd-tasks-user-auth.md     # Optional task breakdown

jaan-to/outputs/data/gtm/01-user-auth/
  └── 01-gtm-user-auth.md           # GTM tracking for same feature

jaan-to/outputs/pm/stories/01-login-validation/
  └── 01-story-login-validation.md  # User story
```

**Exception:** Research outputs use flat files (`research/{id}-{category}-{slug}.md`) instead of folders.

See [jaan-to/outputs/README.md](jaan-to/outputs/README.md) for complete documentation.

### File Names
- Skill definition: `SKILL.md` (uppercase)
- Templates: `template.md` (lowercase)
- Learning: `LEARN.md` (uppercase, in project's `jaan-to/learn/`)

---

## Development Workflow

### plugin.json Rules
- **Only declare**: `name`, `version`, `description`, `author`
- **Never declare**: `skills`, `agents`, `hooks`, `commands` — these are auto-discovered from standard directories
- Official Anthropic plugins use minimal manifests; follow their pattern
- Before every release, test install on a clean machine/session
- The `agents` field specifically causes validation failure: `agents: Invalid input`

### Before Every Commit
1. Update [roadmap.md](roadmaps/jaan-to/roadmap.md) with completed tasks
2. Mark tasks as `[x]` with commit hash: `- [x] Task (\`abc1234\`)`
3. For new tasks, use `/jaan-to:roadmap-add`

### Releasing a Version
Every version bump MUST be a single atomic operation:
1. Update version in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
2. Add entry to [CHANGELOG.md](CHANGELOG.md) following Keep a Changelog format
3. Commit with message: `release: vX.Y.Z — {summary}`
4. Create git tag: `git tag vX.Y.Z`
5. Push with tags: `git push origin main --tags`

**Never** bump version without a CHANGELOG entry and git tag. These three are inseparable.

---

## Available Commands

| Command | Description |
|---------|-------------|
| `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| `/jaan-to:roadmap-add` | Add task to roadmap |
| `/jaan-to:learn-add` | Add lesson to LEARN.md |
| `/jaan-to:skill-create` | Create new skill |
| `/jaan-to:skill-update` | Update existing skill |
| `/jaan-to:docs-create` | Create documentation |
| `/jaan-to:docs-update` | Audit documentation |
| `/jaan-to:pm-research-about` | Deep research or add file/URL to index |
| `/jaan-to:roadmap-update` | Maintain and sync roadmap |

---

## Customization

### Quick Start
All customization happens in the project's `jaan-to/config/settings.yaml`:
```yaml
# Customize output paths
paths_outputs: "artifacts/generated"

# Customize templates
templates_pm_prd_write_path: "./docs/templates/enterprise-prd.md"

# Merge learning from plugin + project
learning_strategy: "merge"
```

### Tech Stack
Edit `jaan-to/context/tech.md` to define:
- Languages and frameworks
- Technical constraints
- Architecture patterns

Skills like `/jaan-to:pm-prd-write` will automatically reference your stack in generated PRDs.

### Environment Variables
Override paths via `.claude/settings.json`:
```json
{
  "env": {
    "JAAN_OUTPUTS_DIR": "build/artifacts"
  }
}
```

### Examples
- [Enterprise Template](examples/custom-template-enterprise.yaml)
- [Monorepo Paths](examples/custom-paths-monorepo.yaml)
- [Learning Override](examples/custom-learning-override.yaml)

### Migration
See [Migration Guide](docs/guides/migration-v3.md) for upgrading from v2.x.

---

## Plugin Features

### Agents
- `quality-reviewer` - Reviews outputs for completeness and quality
- `context-scout` - Gathers relevant context before generation

---

> Give soul to your workflow.
