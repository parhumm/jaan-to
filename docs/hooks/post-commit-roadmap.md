---
title: "post-commit-roadmap (Removed)"
sidebar_position: 4
---

# post-commit-roadmap (Removed)

> **This hook has been removed.** The `post-commit-roadmap.sh` script and its PostToolUse hook entry were deleted when the internal `roadmap-add` and `roadmap-update` skills were replaced by the generic `pm-roadmap-add` and `pm-roadmap-update` skills.

---

## Replacement

Roadmap maintenance is now handled explicitly via user-invoked commands:

- `/pm-roadmap-update review` — Cross-reference roadmap against PRDs, stories, and code changes
- `/pm-roadmap-update mark "<item>" done` — Mark a specific item as complete
- `/pm-roadmap-add "description"` — Add a new prioritized item

---

## Why It Was Removed

The automatic post-commit reminder coupled with the internal `roadmap-update` skill had excessive git permissions (`git push`, `git checkout`, `git merge`) and was tightly coupled to the jaan-to plugin's own roadmap structure. The new generic skills are user-facing, security-hardened (no git operations), and work with any project's roadmap.
