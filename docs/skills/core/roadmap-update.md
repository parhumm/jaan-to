# /roadmap-update

> Maintain and sync the jaan.to development roadmap.

---

## What It Does

Automates roadmap maintenance with 5 modes:
- Scans git history and compares to roadmap entries
- Marks tasks done with commit hashes
- Creates version sections and CHANGELOG entries
- Validates links and cross-references
- Full atomic release (version bump + tag + CHANGELOG)

---

## Usage

```
/roadmap-update
/roadmap-update mark "<task>" done <hash>
/roadmap-update release vX.Y.Z "<summary>"
/roadmap-update sync
/roadmap-update validate
```

---

## Modes

| Mode | Input | Description |
|------|-------|-------------|
| smart-default | (no args) | Scan git log since last tag, report gaps |
| mark | `mark "<task>" done <hash>` | Mark a specific task complete |
| release | `release vX.Y.Z "<summary>"` | Full atomic release |
| sync | `sync` | Cross-reference all git history vs roadmap |
| validate | `validate` | Check links, refs, version completeness |

---

## Example

**Input**:
```
/roadmap-update mark "Add post-commit hook" done 2f4483d
```

**Result**:
- Task found in roadmap via fuzzy match
- Changed `- [ ] Add post-commit hook` to `- [x] Add post-commit hook (`2f4483d`)`
- Overview table updated if phase complete
- Git commit created

---

## Release Mode

A release is an atomic operation:

1. Write CHANGELOG entry (incorporate Unreleased items, clear released items)
2. Write roadmap version section (incorporate Unreleased items, clear released items)
3. Update `.claude-plugin/plugin.json` version
4. Update `.claude-plugin/marketplace.json` version
5. Commit: `release: vX.Y.Z — summary`
6. Tag: `git tag vX.Y.Z`
7. Push and merge (branch-aware: direct push on main, merge flow on feature branches)

All steps succeed or none are applied.

Supports releasing from feature branches: pushes the branch, checks out main, merges, and pushes main with tags.

---

## Output

Updates:
- `roadmaps/jaan-to/roadmap.md`
- `CHANGELOG.md` (release mode)
- `.claude-plugin/plugin.json` (release mode)
- `.claude-plugin/marketplace.json` (release mode)

---

## Note

This is an internal skill for jaan.to development. Complements `/roadmap-add` which creates new tasks.
