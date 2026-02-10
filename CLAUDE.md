# jaan.to - Claude Code Plugin Context

> Give soul to your workflow.

---

## Documentation

| Audience | Document |
|----------|----------|
| **Humans** | [docs/](docs/README.md) - Usage, examples, how-to |
| **AI** | This file - Behavioral rules, file paths |
| **Developers** | [vision.md](docs/roadmap/vision.md) - Philosophy, architecture |
| **Progress** | [roadmap.md](docs/roadmap/roadmap.md) - Tasks, phases |

---

## Plugin Architecture

This is a Claude Code Plugin. All paths below are **relative to the plugin root** unless marked as `(project)`.

### Per-Project Activation
jaan-to is opt-in per project. Run `/jaan-to:jaan-init` to activate for a project.
Projects without a `jaan-to/` directory are not affected by the plugin.

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

### Language
Read and apply language protocol: `docs/extending/language-protocol.md`
Always keep technical terms, code, file paths, YAML keys in English.
Per-skill overrides via `language_{skill-name}` in settings.yaml.

---

## References

- **Naming Conventions**: `docs/extending/naming-conventions.md`
- **Output Structure**: `docs/extending/output-structure.md`
- **Development Workflow**: `docs/extending/dev-workflow.md`
- **Customization**: `docs/guides/customization.md`

---

> Give soul to your workflow.
