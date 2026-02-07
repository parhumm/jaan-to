# Templates: to-jaan-roadmap-update

> Templates for version sections, CHANGELOG entries, and reports.

---

## Roadmap Version Section

```markdown
### {{version}} — {{summary}} (`{{commit_hash}}`)

{{#if description}}
{{description}}

{{/if}}
{{#each changes}}
- {{this}}
{{/each}}
```

**Variables:**
- `{{version}}` — Semver version (e.g., v3.1.0)
- `{{summary}}` — One-line release summary
- `{{commit_hash}}` — Short hash of the release commit
- `{{description}}` — Optional paragraph (omit if not needed)
- `{{changes}}` — Bullet points of completed work

---

## CHANGELOG Entry

```markdown
## [{{version_number}}] - {{date}}

{{#if added}}
### Added
{{#each added}}
- {{this}}
{{/each}}
{{/if}}

{{#if changed}}
### Changed
{{#each changed}}
- {{this}}
{{/each}}
{{/if}}

{{#if fixed}}
### Fixed
{{#each fixed}}
- {{this}}
{{/each}}
{{/if}}

{{#if removed}}
### Removed
{{#each removed}}
- {{this}}
{{/each}}
{{/if}}

{{#if migration}}
### Migration
{{migration}}
{{/if}}
```

**Variables:**
- `{{version_number}}` — Semver without v prefix (e.g., 3.1.0)
- `{{date}}` — YYYY-MM-DD format
- Sections: Only include sections that have content

---

## CHANGELOG Link Reference

```markdown
[{{version_number}}]: https://github.com/parhumm/jaan-to/releases/tag/v{{version_number}}
```

---

## Overview Table Row

```markdown
| {{phase}} | {{focus}} | {{status}} |
```

**Status values:** Done, In Progress, Planned

---

## Sync Report

```markdown
# Roadmap Sync Report
**Last tag:** {{last_tag}} | **Commits since:** {{commit_count}} | **Date:** {{date}}

## Unrecorded Work
| Commit | Message | Probable Task |
|--------|---------|---------------|
{{#each unrecorded}}
| `{{this.hash}}` | {{this.message}} | {{this.task}} |
{{/each}}

## Tasks Without Commit Hashes
| Task | Phase | Suggested Hash |
|------|-------|----------------|
{{#each missing_hashes}}
| {{this.task}} | {{this.phase}} | `{{this.hash}}` |
{{/each}}

## Overview Table Corrections
| Phase | Current Status | Should Be |
|-------|---------------|-----------|
{{#each corrections}}
| {{this.phase}} | {{this.current}} | {{this.should_be}} |
{{/each}}
```

---

## Validation Report

```markdown
# Roadmap Validation Report
**Date:** {{date}} | **Issues:** {{issue_count}}

## Link Validation
| Link | Location | Status |
|------|----------|--------|
{{#each links}}
| {{this.text}} | Line {{this.line}} | {{this.status}} |
{{/each}}

## Overview Table
| Phase | Table Status | Actual Status | Match |
|-------|-------------|---------------|-------|
{{#each phases}}
| {{this.phase}} | {{this.table}} | {{this.actual}} | {{this.match}} |
{{/each}}

## Task File Cross-References
| File | Referenced | Exists |
|------|-----------|--------|
{{#each task_files}}
| {{this.file}} | {{this.referenced}} | {{this.exists}} |
{{/each}}
```
