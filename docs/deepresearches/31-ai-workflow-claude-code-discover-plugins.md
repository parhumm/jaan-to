# Discover and Install Plugins

> Guide for finding and installing Claude Code plugins from marketplaces, including official plugins, code intelligence, and external integrations.
> Source: /Users/parhumm/Projects/jaan-to/website/discover-plugins.md
> Added: 2026-01-29

---

Plugins extend Claude Code with skills, agents, hooks, and MCP servers. Plugin marketplaces are catalogs that help you discover and install these extensions without building them yourself.

## How Marketplaces Work

A marketplace is a catalog of plugins that someone else has created and shared. Using a marketplace is a two-step process:

1. **Add the marketplace** — registers the catalog with Claude Code so you can browse what's available. No plugins are installed yet.
2. **Install individual plugins** — browse the catalog and install the plugins you want.

Think of it like adding an app store: adding the store gives you access to browse its collection, but you still choose which apps to download individually.

## Official Anthropic Marketplace

The official Anthropic marketplace (`claude-plugins-official`) is automatically available when you start Claude Code. Run `/plugin` and go to the **Discover** tab to browse.

```shell
/plugin install plugin-name@claude-plugins-official
```

### Code Intelligence Plugins

Code intelligence plugins enable Claude Code's built-in LSP tool, giving Claude the ability to jump to definitions, find references, and see type errors immediately after edits.

These plugins require the language server binary to be installed on your system.

| Language | Plugin | Binary required |
|:--|:--|:--|
| C/C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |

#### What Claude Gains from Code Intelligence Plugins

- **Automatic diagnostics**: after every file edit, the language server analyzes changes and reports errors/warnings automatically. Claude sees type errors, missing imports, and syntax issues without needing to run a compiler or linter. If Claude introduces an error, it notices and fixes the issue in the same turn.
- **Code navigation**: Claude can jump to definitions, find references, get type info on hover, list symbols, find implementations, and trace call hierarchies. More precise than grep-based search.

### External Integrations

Pre-configured MCP servers to connect Claude to external services:

- **Source control**: `github`, `gitlab`
- **Project management**: `atlassian` (Jira/Confluence), `asana`, `linear`, `notion`
- **Design**: `figma`
- **Infrastructure**: `vercel`, `firebase`, `supabase`
- **Communication**: `slack`
- **Monitoring**: `sentry`

### Development Workflows

- **commit-commands**: Git commit workflows including commit, push, and PR creation
- **pr-review-toolkit**: Specialized agents for reviewing pull requests
- **agent-sdk-dev**: Tools for building with the Claude Agent SDK
- **plugin-dev**: Toolkit for creating your own plugins

### Output Styles

- **explanatory-output-style**: Educational insights about implementation choices
- **learning-output-style**: Interactive learning mode for skill building

## Demo Marketplace

Anthropic maintains a demo plugins marketplace (`claude-code-plugins`) with example plugins:

```shell
/plugin marketplace add anthropics/claude-code
```

Then browse with `/plugin` → **Discover** tab.

Example install:

```shell
/plugin install commit-commands@anthropics-claude-code
```

Plugin commands are namespaced by plugin name, e.g. `/commit-commands:commit`.

## Add Marketplaces

### From GitHub

```shell
/plugin marketplace add anthropics/claude-code
```

### From Other Git Hosts

```shell
# HTTPS
/plugin marketplace add https://gitlab.com/company/plugins.git

# SSH
/plugin marketplace add git@gitlab.com:company/plugins.git

# Specific branch or tag
/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0
```

### From Local Paths

```shell
/plugin marketplace add ./my-marketplace
/plugin marketplace add ./path/to/marketplace.json
```

### From Remote URLs

```shell
/plugin marketplace add https://example.com/marketplace.json
```

## Install Plugins

Install directly (defaults to user scope):

```shell
/plugin install plugin-name@marketplace-name
```

Choose scope via interactive UI (`/plugin` → **Discover** tab → **Enter** on plugin):

- **User scope** (default): install for yourself across all projects
- **Project scope**: install for all collaborators on this repository (`.claude/settings.json`)
- **Local scope**: install for yourself in this repository only (not shared)
- **Managed scope**: installed by administrators via managed settings (read-only)

> Make sure you trust a plugin before installing it. Anthropic does not control what MCP servers, files, or other software are included in plugins.

## Manage Installed Plugins

Run `/plugin` → **Installed** tab to view, enable, disable, or uninstall.

```shell
# Disable without uninstalling
/plugin disable plugin-name@marketplace-name

# Re-enable
/plugin enable plugin-name@marketplace-name

# Completely remove
/plugin uninstall plugin-name@marketplace-name

# Target specific scope
claude plugin install formatter@your-org --scope project
claude plugin uninstall formatter@your-org --scope project
```

## Manage Marketplaces

### Interactive Interface

Run `/plugin` → **Marketplaces** tab to view, add, update, or remove marketplaces.

### CLI Commands

```shell
# List all configured marketplaces
/plugin marketplace list

# Refresh plugin listings
/plugin marketplace update marketplace-name

# Remove a marketplace (also uninstalls its plugins)
/plugin marketplace remove marketplace-name
```

**Shortcut**: `/plugin market` instead of `/plugin marketplace`, `rm` instead of `remove`.

### Configure Auto-Updates

Toggle auto-update per marketplace:

1. Run `/plugin` → **Marketplaces** tab
2. Choose a marketplace
3. Select **Enable auto-update** or **Disable auto-update**

- Official Anthropic marketplaces: auto-update enabled by default
- Third-party/local marketplaces: auto-update disabled by default

To disable all automatic updates: set `DISABLE_AUTOUPDATER` environment variable.

To keep plugin auto-updates while disabling Claude Code auto-updates:

```shell
export DISABLE_AUTOUPDATER=true
export FORCE_AUTOUPDATE_PLUGINS=true
```

## Configure Team Marketplaces

Team admins can add marketplace configuration to `.claude/settings.json`. When team members trust the repository folder, Claude Code prompts them to install these marketplaces and plugins.

Use `extraKnownMarketplaces` and `enabledPlugins` in settings.

## Troubleshooting

### /plugin Command Not Recognized

1. Check version: `claude --version` (requires 1.0.33+)
2. Update Claude Code (Homebrew: `brew upgrade claude-code`, npm: `npm update -g @anthropic-ai/claude-code`)
3. Restart Claude Code

### Common Issues

- **Marketplace not loading**: Verify URL is accessible and `.claude-plugin/marketplace.json` exists
- **Plugin installation failures**: Check plugin source URLs are accessible
- **Files not found after installation**: Plugins are copied to cache; paths outside plugin directory won't work
- **Plugin skills not appearing**: Clear cache with `rm -rf ~/.claude/plugins/cache`, restart, reinstall

### Code Intelligence Issues

- **Language server not starting**: Verify binary is installed and in `$PATH`. Check `/plugin` Errors tab.
- **High memory usage**: Language servers can consume significant memory on large projects. Disable with `/plugin disable <name>`.
- **False positive diagnostics in monorepos**: Language servers may report unresolved import errors for internal packages.

## Sources

- Anthropic Claude Code Documentation: [Discover and Install Plugins](https://docs.anthropic.com/en/docs/claude-code/discover-plugins)
