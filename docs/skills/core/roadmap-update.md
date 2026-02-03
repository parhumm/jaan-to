# /to-jaan-roadmap-update

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
/to-jaan-roadmap-update
/to-jaan-roadmap-update mark "<task>" done <hash>
/to-jaan-roadmap-update release vX.Y.Z "<summary>"
/to-jaan-roadmap-update sync
/to-jaan-roadmap-update validate
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
/to-jaan-roadmap-update mark "Add post-commit hook" done 2f4483d
```

**Result**:
- Task found in roadmap via fuzzy match
- Changed `- [ ] Add post-commit hook` to `- [x] Add post-commit hook (`2f4483d`)`
- Overview table updated if phase complete
- Git commit created

---

## Release Mode

A release is an atomic operation:

1. Write CHANGELOG entry (Keep a Changelog format)
2. Write roadmap version section
3. Update `.claude-plugin/plugin.json` version
4. Update `.claude-plugin/marketplace.json` version
5. Commit: `release: vX.Y.Z — summary`
6. Tag: `git tag vX.Y.Z`
7. Optional push

All steps succeed or none are applied.

---

## Output

Updates:
- `roadmaps/jaan-to/roadmap.md`
- `CHANGELOG.md` (release mode)
- `.claude-plugin/plugin.json` (release mode)
- `.claude-plugin/marketplace.json` (release mode)

---

## Note

This is an internal skill for jaan.to development. Complements `/to-jaan-roadmap-add` which creates new tasks.
