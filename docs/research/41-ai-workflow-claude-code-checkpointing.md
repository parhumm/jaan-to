# Checkpointing

> Official guide for Claude Code's automatic checkpoint system that tracks file edits and enables quick rewind to previous states.
> Source: https://code.claude.com/docs/en/checkpointing.md
> Added: 2026-01-29

---

## How Checkpoints Work

Claude Code automatically captures code state before each edit, creating a safety net for ambitious, wide-scale tasks.

### Automatic Tracking
- Every user prompt creates a new checkpoint
- Checkpoints persist across sessions (accessible in resumed conversations)
- Automatically cleaned up after 30 days (configurable)

---

## Rewinding

Press `Esc` twice (`Esc + Esc`) or use `/rewind` to open the rewind menu.

### Restore Options

| Option | Effect |
|--------|--------|
| **Conversation only** | Rewind to a user message, keep code changes |
| **Code only** | Revert file changes, keep conversation |
| **Both** | Restore code and conversation to prior point |

---

## Common Use Cases

- **Exploring alternatives**: Try different approaches without losing your starting point
- **Recovering from mistakes**: Quickly undo changes that introduced bugs
- **Iterating on features**: Experiment knowing you can revert to working states

---

## Limitations

### Bash Changes Not Tracked
File modifications via bash commands cannot be undone:
```bash
rm file.txt
mv old.txt new.txt
cp source.txt dest.txt
```
Only direct file edits through Claude's editing tools are tracked.

### External Changes Not Tracked
Manual changes outside of Claude Code and edits from other concurrent sessions are not captured (unless they modify the same files).

### Not a Replacement for Version Control
- Checkpoints = "local undo" (session-level recovery)
- Git = "permanent history" (commits, branches, long-term)
- They complement each other
