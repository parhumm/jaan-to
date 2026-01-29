# Interactive Mode

> Official reference for keyboard shortcuts, input modes, built-in commands, and interactive features in Claude Code sessions.
> Source: https://code.claude.com/docs/en/interactive-mode.md
> Added: 2026-01-29

---

## Keyboard Shortcuts

### General Controls

| Shortcut | Description |
|----------|-------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Left/Right` | Cycle dialog tabs |
| `Up/Down` | Navigate command history |
| `Esc + Esc` | Rewind code/conversation |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |

### Text Editing

| Shortcut | Description |
|----------|-------------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history |
| `Alt+B` | Back one word |
| `Alt+F` | Forward one word |

### Multiline Input

| Method | Shortcut |
|--------|----------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |
| Paste mode | Paste directly |

### Quick Commands

| Prefix | Description |
|--------|-------------|
| `/` | Command or skill |
| `!` | Bash mode (run directly) |
| `@` | File path mention |

---

## Built-in Commands

| Command | Purpose |
|---------|---------|
| `/clear` | Clear conversation history |
| `/compact [instructions]` | Compact with optional focus |
| `/config` | Settings interface |
| `/context` | Visualize context usage |
| `/cost` | Token usage statistics |
| `/doctor` | Installation health check |
| `/exit` | Exit REPL |
| `/export [filename]` | Export conversation |
| `/help` | Usage help |
| `/init` | Initialize CLAUDE.md |
| `/mcp` | Manage MCP servers |
| `/memory` | Edit CLAUDE.md files |
| `/model` | Select model |
| `/permissions` | View/update permissions |
| `/plan` | Enter plan mode |
| `/rename <name>` | Rename session |
| `/resume [session]` | Resume conversation |
| `/rewind` | Rewind conversation/code |
| `/stats` | Daily usage, streaks, model preferences |
| `/status` | Version, model, account, connectivity |
| `/statusline` | Status line UI setup |
| `/copy` | Copy last response to clipboard |
| `/tasks` | List background tasks |
| `/teleport` | Resume remote session |
| `/theme` | Change color theme |
| `/todos` | List TODO items |
| `/usage` | Plan usage limits and rate limits |

---

## Vim Editor Mode

Enable with `/vim` or permanently via `/config`.

### Mode Switching
- `Esc` → NORMAL mode
- `i/I/a/A/o/O` → INSERT mode

### Navigation (NORMAL)
`h/j/k/l`, `w/e/b`, `0/$`, `^`, `gg/G`, `f/F/t/T`, `;/,`

### Editing (NORMAL)
`x`, `dd/D`, `dw/de/db`, `cc/C`, `cw/ce/cb`, `yy/Y`, `yw/ye/yb`, `p/P`, `>>/<<`, `J`, `.`

### Text Objects
`iw/aw`, `iW/aW`, `i"/a"`, `i'/a'`, `i(/a(`, `i[/a[`, `i{/a{`

---

## Background Bash Commands

Commands can run asynchronously while you continue working.

- Prompt Claude to "run in the background"
- Press `Ctrl+B` to background a running command
- Output buffered, retrieved via TaskOutput tool
- Cleaned up when Claude Code exits

### Bash Mode (`!` prefix)
```bash
! npm test
! git status
```
Adds command + output to conversation context without Claude interpreting it.

---

## Task List

Claude creates task lists for complex, multi-step work.

- `Ctrl+T` to toggle view (up to 10 tasks)
- Tasks persist across context compactions
- `CLAUDE_CODE_TASK_LIST_ID=my-project claude` for shared task list
- `CLAUDE_CODE_ENABLE_TASKS=false` to revert to TODO list

---

## PR Review Status

Clickable PR link in footer with colored underline:
- Green: approved
- Yellow: pending review
- Red: changes requested
- Gray: draft

Updates every 60 seconds. Requires `gh` CLI.
