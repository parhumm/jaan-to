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
- One skill per capability (learning → `/to-jaan-learn-add`)
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
- Role-based: `jaan-to-{role}-{domain}-{action}` → `/jaan-to-{role}-{domain}-{action}`
  Roles: pm, data, ux, qa, dev, devops
  Example: `jaan-to-pm-prd-write` → `/jaan-to-pm-prd-write`
- Internal: `to-jaan-{domain}-{action}` → `/to-jaan-{domain}-{action}`
  For plugin development and maintenance
  Example: `to-jaan-docs-create` → `/to-jaan-docs-create`
- Directory: `skills/{skill-name}/`

### Output Paths (Project-Relative)
```
jaan-to/outputs/{role}/{domain}/{slug}/
```

### File Names
- Skill definition: `SKILL.md` (uppercase)
- Templates: `template.md` (lowercase)
- Learning: `LEARN.md` (uppercase, in project's `jaan-to/learn/`)

---

## Development Workflow

### Before Every Commit
1. Update [roadmap.md](roadmaps/jaan-to/roadmap.md) with completed tasks
2. Mark tasks as `[x]` with commit hash: `- [x] Task (\`abc1234\`)`
3. For new tasks, use `/to-jaan-roadmap-add`

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
| `/jaan-to-pm-prd-write` | Generate PRD from initiative |
| `/jaan-to-data-gtm-datalayer` | Generate GTM tracking code |
| `/to-jaan-roadmap-add` | Add task to roadmap |
| `/to-jaan-learn-add` | Add lesson to LEARN.md |
| `/to-jaan-skill-create` | Create new skill |
| `/to-jaan-skill-update` | Update existing skill |
| `/to-jaan-docs-create` | Create documentation |
| `/to-jaan-docs-update` | Audit documentation |
| `/jaan-to-pm-research-about` | Deep research or add file/URL to index |
| `/to-jaan-roadmap-update` | Maintain and sync roadmap |

---

## Customization

### Quick Start
All customization happens in the project's `jaan-to/config/settings.yaml`:
```yaml
# Customize output paths
paths_outputs: "artifacts/generated"

# Customize templates
templates_jaan_to_pm_prd_write_path: "./docs/templates/enterprise-prd.md"

# Merge learning from plugin + project
learning_strategy: "merge"
```

### Tech Stack
Edit `jaan-to/context/tech.md` to define:
- Languages and frameworks
- Technical constraints
- Architecture patterns

Skills like `/jaan-to-pm-prd-write` will automatically reference your stack in generated PRDs.

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
