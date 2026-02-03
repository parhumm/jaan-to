# post-commit-roadmap

> Reminds you to sync the roadmap after significant commits.

---

## When It Runs

- **Type**: PostToolUse
- **Trigger**: Bash operations
- **Matches**: Commands containing `git commit`

---

## What It Does

After a significant git commit (feat/fix/refactor), displays a reminder:

```
---
Commit: abc1234 — feat(skill): Add new skill

Consider syncing the roadmap:
  /to-jaan-roadmap-update
  /to-jaan-roadmap-update mark "<task>" done abc1234
---
```

---

## Behavior

- Always exits 0 (never blocks)
- Only triggers for `feat:`, `fix:`, and `refactor:` commits
- Skips `docs(roadmap):` and `docs(changelog):` commits (already roadmap work)
- Skips `release:` commits (handled by `/to-jaan-roadmap-update release`)
- Non-intrusive reminder via stderr

---

## Why It Exists

Creates a feedback loop between commits and roadmap tracking. When you make a significant change, you're reminded to record it in the roadmap.

Works with `/to-jaan-roadmap-update` to keep the roadmap in sync with actual development.

---

## Script Location

```
scripts/post-commit-roadmap.sh
```
