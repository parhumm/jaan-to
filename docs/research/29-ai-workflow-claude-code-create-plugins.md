# Create Plugins

> Official guide for creating Claude Code plugins with skills, agents, hooks, and MCP servers.
> Source: /Users/parhumm/Projects/jaan-to/website/plugins.md
> Added: 2026-01-29

---

Plugins let you extend Claude Code with custom functionality that can be shared across projects and teams. This guide covers creating your own plugins with skills, agents, hooks, and MCP servers.

## When to Use Plugins vs Standalone Configuration

Claude Code supports two ways to add custom skills, agents, and hooks:

| Approach | Skill names | Best for |
|:--|:--|:--|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases, reusable across projects |

**Use standalone configuration when**:
- You're customizing Claude Code for a single project
- The configuration is personal and doesn't need to be shared
- You're experimenting with skills or hooks before packaging them
- You want short skill names like `/hello` or `/review`

**Use plugins when**:
- You want to share functionality with your team or community
- You need the same skills/agents across multiple projects
- You want version control and easy updates for your extensions
- You're distributing through a marketplace
- You're okay with namespaced skills like `/my-plugin:hello`

> Start with standalone configuration in `.claude/` for quick iteration, then convert to a plugin when you're ready to share.

## Quickstart

### Prerequisites

- Claude Code installed and authenticated
- Claude Code version 1.0.33 or later (run `claude --version` to check)

### Create Your First Plugin

**Step 1: Create the plugin directory**

Every plugin lives in its own directory containing a manifest and your skills, agents, or hooks.

```bash
mkdir my-first-plugin
```

**Step 2: Create the plugin manifest**

The manifest file at `.claude-plugin/plugin.json` defines your plugin's identity.

```bash
mkdir my-first-plugin/.claude-plugin
```

Create `my-first-plugin/.claude-plugin/plugin.json`:

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

| Field | Purpose |
|:--|:--|
| `name` | Unique identifier and skill namespace. Skills are prefixed with this (e.g., `/my-first-plugin:hello`). |
| `description` | Shown in the plugin manager when browsing or installing plugins. |
| `version` | Track releases using semantic versioning. |
| `author` | Optional. Helpful for attribution. |

**Step 3: Add a skill**

Skills live in the `skills/` directory. Each skill is a folder containing a `SKILL.md` file. The folder name becomes the skill name, prefixed with the plugin's namespace.

```bash
mkdir -p my-first-plugin/skills/hello
```

Create `my-first-plugin/skills/hello/SKILL.md`:

```yaml
---
description: Greet the user with a friendly message
disable-model-invocation: true
---

Greet the user warmly and ask how you can help them today.
```

**Step 4: Test your plugin**

Run Claude Code with the `--plugin-dir` flag to load your plugin:

```bash
claude --plugin-dir ./my-first-plugin
```

Once Claude Code starts, try your new command:

```
/my-first-plugin:hello
```

**Step 5: Add skill arguments**

Make your skill dynamic by accepting user input. The `$ARGUMENTS` placeholder captures any text the user provides after the skill name.

```markdown
---
description: Greet the user with a personalized message
---

# Hello Command

Greet the user named "$ARGUMENTS" warmly and ask how you can help them today.
```

## Plugin Structure Overview

| Directory | Location | Purpose |
|:--|:--|:--|
| `.claude-plugin/` | Plugin root | Contains only `plugin.json` manifest (required) |
| `commands/` | Plugin root | Skills as Markdown files |
| `agents/` | Plugin root | Custom agent definitions |
| `skills/` | Plugin root | Agent Skills with `SKILL.md` files |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations for code intelligence |

> **Common mistake**: Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside the `.claude-plugin/` directory. Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root level.

## Develop More Complex Plugins

### Add Skills to Your Plugin

Plugins can include Agent Skills to extend Claude's capabilities. Skills are model-invoked: Claude automatically uses them based on the task context.

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── code-review/
        └── SKILL.md
```

Each `SKILL.md` needs frontmatter with `name` and `description` fields:

```yaml
---
name: code-review
description: Reviews code for best practices and potential issues.
---

When reviewing code, check for:
1. Code organization and structure
2. Error handling
3. Security concerns
4. Test coverage
```

### Add LSP Servers to Your Plugin

LSP plugins give Claude real-time code intelligence. Add an `.lsp.json` file to your plugin:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

Users installing your plugin must have the language server binary installed on their machine.

### Test Your Plugins Locally

```bash
claude --plugin-dir ./my-plugin
```

Load multiple plugins at once:

```bash
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Debug Plugin Issues

1. **Check the structure**: Ensure directories are at the plugin root, not inside `.claude-plugin/`
2. **Test components individually**: Check each command, agent, and hook separately
3. **Use `claude --debug`**: Shows plugin loading details, errors, and registration

### Share Your Plugins

1. Add documentation (README.md with installation and usage instructions)
2. Version your plugin (semantic versioning in `plugin.json`)
3. Create or use a marketplace for distribution
4. Test with others before wider distribution

## Convert Existing Configurations to Plugins

### Migration Steps

1. **Create the plugin structure**: `mkdir -p my-plugin/.claude-plugin` and create `plugin.json`
2. **Copy existing files**: Copy from `.claude/commands`, `.claude/agents`, `.claude/skills`
3. **Migrate hooks**: Create `hooks/hooks.json` with hooks from your `settings.json`
4. **Test**: `claude --plugin-dir ./my-plugin`

### What Changes When Migrating

| Standalone (`.claude/`) | Plugin |
|:--|:--|
| Only available in one project | Can be shared via marketplaces |
| Files in `.claude/commands/` | Files in `plugin-name/commands/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Must manually copy to share | Install with `/plugin install` |

## Next Steps

### For Plugin Users
- Discover and install plugins: browse marketplaces and install plugins
- Configure team marketplaces: set up repository-level plugins for your team

### For Plugin Developers
- Create and distribute a marketplace: package and share your plugins
- Plugins reference: complete technical specifications
- Dive deeper: Skills, Subagents, Hooks, MCP

## Sources

- Anthropic Claude Code Documentation: [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins)
