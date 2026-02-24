# team-ship — Seed Lessons

> Plugin-side seed. Project-specific lessons accumulate in `$JAAN_LEARN_DIR/jaan-to-team-ship.learn.md`.

## Better Questions

- Ask about team size preference early — some users prefer fewer teammates for cost control
- Confirm entity list before spawning Backend (data-model + api-contract depend on accurate entities)
- For --detect mode, ask if user wants full or light detect scans

## Edge Cases

- User may not have `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set — check before any team operations
- PRD approval gate may need multiple revision cycles — PM should stay alive until approval
- Backend api-contract may take longer than Frontend task-breakdown — Frontend must wait, not fail
- Integration may fail if scaffolds use incompatible patterns — present both scaffold READMEs to user
- Checkpoint resume may find stale output paths if user moved/deleted files between sessions

## Workflow

- Always shut down PM after Phase 1 — no reason to keep that context alive
- Phase 2 teammates should message each other directly (Backend→Frontend), not through lead
- For detect mode, all 5 teammates are independent — no dependency coordination needed
- Update checkpoint after every skill completion, not just phase completion
- Fast track skips UX, Security — don't spawn them even if roles.md includes them

## Common Mistakes

- Spawning all 7 teammates at once instead of phased — wastes tokens on idle teammates
- Forgetting to message QA when scaffolds are ready — QA waits indefinitely
- Running dev-project-assemble as a teammate instead of lead — it touches multiple output dirs
- Not cleaning up team after completion — leaves orphaned tmux sessions
- Setting --track fast but expecting UX outputs — fast track does not include UX role
