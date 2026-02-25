---
title: "Seed Reconciliation Reference"
sidebar_position: 10
---

# Seed Reconciliation Reference

> Shared reference for post-detect seed reconciliation across all detect skills.

This document defines the comparison rules, discrepancy format, and seed update protocol used by detect skills to keep project seed files aligned with detection findings.

---

## Domain-to-Seed Mapping

| Detect Skill | Seed Files to Check | What to Compare |
|---|---|---|
| detect-dev | `$JAAN_CONTEXT_DIR/tech.md` | Framework versions, languages, infrastructure, CI/CD, patterns, constraints, tech debt |
| detect-design | `$JAAN_CONTEXT_DIR/tone-of-voice.template.md` | Brand colors, typography if referenced in design tokens |
| detect-product | `$JAAN_CONTEXT_DIR/tech.md`, `$JAAN_CONTEXT_DIR/integrations.md` | Feature references, analytics tools, external integrations |
| detect-ux | `$JAAN_CONTEXT_DIR/tone-of-voice.template.md` | UX tone patterns, error message guidelines |
| detect-writing | `$JAAN_CONTEXT_DIR/tone-of-voice.template.md`, `$JAAN_CONTEXT_DIR/localization.template.md` | Tone dimensions, i18n maturity, voice characteristics |
| detect-pack | All context/ files | Cross-domain contradictions, stale entries across all seeds |

---

## Comparison Rules

When comparing detection results against seed file content, classify each discrepancy:

- **Version drift**: Seed says X.Y, detection found X.Z (or different major version)
- **Contradiction**: Seed says technology A, detection found technology B (e.g., seed says "React 18", repo uses vanilla HTML/CSS)
- **Missing reference**: Detection found tech/tool/pattern not mentioned in seeds
- **Stale pattern**: Seed documents patterns, tools, or infrastructure not found in the codebase
- **Absent infrastructure**: Seed lists CI/CD tools, monitoring, or services not detected in the repo

---

## Discrepancy Report Format

Display discrepancies as a table:

```markdown
| # | Seed File | Section | Issue | Detected Value | Seed Value | Severity |
|---|-----------|---------|-------|----------------|------------|----------|
| 1 | tech.md | Current Stack > Frontend | Version drift | React 19.1 | React 18 | Medium |
| 2 | tech.md | Current Stack > Backend | Missing | Express.js 4.18 | (not listed) | High |
| 3 | tech.md | Infrastructure > CI/CD | Contradiction | GitLab CI | GitHub Actions | High |
```

### Severity Levels

| Severity | Meaning | Action |
|----------|---------|--------|
| **High** | Contradiction — seed says X, detection found Y | Recommend update or manual review |
| **Medium** | Version drift — same tech, different version | Offer auto-update |
| **Low** | Missing reference — detection found something seed omits | Offer to add |
| **Info** | Stale entry — seed mentions something not detected | Flag for user decision (may be intentional) |

---

## Change Categories (detect-pack)

When detect-pack builds proposed seed updates, classify each change:

- **[UPDATE]**: Detected value differs from seed — propose replacement
- **[ADD]**: Detected tech/pattern not in seed — propose addition
- **[STALE]**: Seed lists something not detected — flag for user decision (keep or remove)

### Diff-Style Summary Format

```
tech.md — 12 changes proposed:
  [UPDATE] Backend > Language: Python 3.11 → Python 3.12
  [UPDATE] Frontend > Framework: React 18 + Next.js 14 → React 19 + Next.js 15
  [ADD]    Infrastructure > Container: Kubernetes (not previously listed)
  [STALE]  Mobile > iOS: Swift 5.9 — not detected in repo (keep? [y/n])
```

### User Approval Options

Prompt: `"Apply these seed updates? [y/all/n/pick]"`

| Option | Behavior |
|--------|----------|
| `y` / `all` | Apply all [UPDATE] + [ADD] changes; keep [STALE] entries unchanged |
| `n` | Skip seed updates entirely |
| `pick` | Let user approve each change individually |

---

## Auto-Update Rules

1. Only offer auto-updates for **non-destructive** changes:
   - Version number updates (e.g., `React 18` → `React 19`)
   - Adding new entries under existing sections
   - Updating tool versions in existing list items
2. **NEVER auto-delete** seed content — stale entries may be intentional or aspirational
3. Always **preview changes** before writing
4. Require **explicit user approval** before any edits
5. For [STALE] items: present as a separate decision — user chooses keep or remove per item

---

## `/learn-add` Suggestion Format

For detection findings worth documenting as lessons:

```
Suggested lessons from detection:
1. /learn-add detect-dev "Project uses Express.js 4.18, not FastAPI — update tech.md"
2. /learn-add detect-dev "No CI/CD pipeline detected — tech.md lists GitHub Actions"
3. /learn-add detect-ux "Primary user flow has 7 steps — consider reducing"
```

Suggest `/learn-add` for:
- Detection findings that don't map to any seed file (e.g., UX journey insights)
- Patterns worth documenting for future skill executions
- Architectural decisions discovered during detection

---

## Seed Update Templates (detect-pack)

Section-to-detect-output mapping for building proposed seed file rewrites:

| Seed File | Section Anchor | Detection Source |
|-----------|---------------|-----------------|
| tech.md | `{#current-stack}` | detect/dev/stack*.md — languages, frameworks, versions |
| tech.md | `{#frameworks}` | detect/dev/stack*.md — framework details, testing tools |
| tech.md | `{#constraints}` | detect/dev/architecture*.md — enforced patterns |
| tech.md | `{#patterns}` | detect/dev/architecture*.md, security*.md — auth, error handling, data access |
| tech.md | `{#tech-debt}` | detect/dev/risks*.md — identified tech debt items |
| integrations.md | External tools | detect/product/features*.md, monetization*.md — analytics, payment, third-party |
| tone-of-voice.template.md | Tone Characteristics | detect/writing/writing-system*.md — NNg tone dimensions |
| tone-of-voice.template.md | Error Message Tone | detect/writing/writing-system*.md — error quality scores |
| localization.template.md | i18n maturity | detect/writing/i18n*.md — detected languages, maturity level |

---

## Preservation Rules

When rewriting seed files, preserve:

1. **Section anchors** — Keep all `{#anchor-name}` markers intact (e.g., `{#current-stack}`, `{#constraints}`)
2. **User-added custom sections** — Any section not in the original seed template must be preserved
3. **Keep markers** — Content marked with `<!-- keep -->` HTML comments must not be modified
4. **Header timestamps** — Update `> Last updated:` header with current date
5. **Footer notes** — Keep the "Delete this section after customizing" footer if still present
6. **File structure** — Maintain the same heading hierarchy and markdown formatting

---

## Reconciliation Report Output

detect-pack writes a reconciliation report to `$JAAN_OUTPUTS_DIR/detect/seed-reconciliation.md` containing:

1. **Summary** — Count of changes applied, skipped, and flagged
2. **Changes applied** — Per-file list of [UPDATE] and [ADD] changes made
3. **Stale entries** — Per-file list of [STALE] items with user's decision (kept/removed)
4. **`/learn-add` suggestions** — Commands for non-seed findings
5. **Metadata** — Timestamp, detect output versions used (from frontmatter `target.commit`)
