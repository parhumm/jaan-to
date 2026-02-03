# Lessons: to-jaan-roadmap-update

> Last updated: 2026-02-03

Accumulated lessons from past executions. Seeded from the manual v3.0.0 roadmap restructure.

---

## Better Questions

- Ask which phase a version belongs to before creating the section — versions can span phase boundaries
- When marking tasks done, ask if subtasks should also be marked (some top-level tasks have sub-bullets)
- Before restructuring phases, ask if the user wants to preserve original phase numbering or realign

## Edge Cases

- Commits on feature branches may not appear in main's git log — check for merged PRs too
- Some releases bundle work from multiple phases (e.g., v3.0.0 included migration + docs + tests)
- The "Unreleased" section in both CHANGELOG and roadmap needs special handling — no tags
- Tasks with "details" links like `[details](tasks/file.md)` — preserve the link when marking done
- Overview table status values are not standardized — "Done", "Planned", "In Progress" all appear

## Workflow

- Always update the overview table AFTER updating individual task sections, not before
- When creating a version section, place it chronologically within its phase (ascending order)
- CHANGELOG entries go in reverse chronological order (newest first), but roadmap sections go chronologically within phases
- After a release, check if the phase status in the overview table needs changing to "Done"
- The commit hash in version headings like `### v3.0.0 — Title (\`ae91303\`)` uses the release commit, not the first commit

## Common Mistakes

- Don't assume every commit maps to exactly one roadmap task — one task may span many commits
- Don't create duplicate CHANGELOG link references at the bottom of CHANGELOG.md
- Don't change the phase numbering for future phases without explicit approval — they are referenced elsewhere
- Don't modify the "Quick Reference" section at the bottom of the roadmap — it's manually curated
- Don't rewrite existing version section prose — only append or mark tasks done
