---
title: "Token Strategy"
doc_type: concept
created_date: 2026-02-11
updated_date: 2026-02-16
tags: [tokens, optimization, architecture, performance]
related: [docs/extending/create-skill.md, docs/roadmap/roadmap.md, docs/research/75-token-optimization-aggressive-safe.md]
---

# Token Strategy

> How jaan.to manages token efficiency across skills, sessions, and invocations.

---

## What Is It?

Token strategy is jaan.to's system-wide approach to minimizing context window usage while preserving full skill capabilities. Every skill loaded into a Claude Code session consumes tokens from a finite context window. Without active management, skill definitions, descriptions, and reference material would quickly exhaust the available budget — degrading performance or silently dropping skills.

jaan.to addresses this at four levels: **CLAUDE.md** (always loaded), **session-level** (what gets loaded), **invocation-level** (how skills run), **skill-level** (how SKILL.md files are structured), plus **CI enforcement** to prevent regression.

---

## Key Points

- **Description Budget** — All skill descriptions share a 15,000-character budget in the system prompt. Exceeding it causes skills to be silently dropped. Each skill costs ~109 chars XML overhead plus description length.
- **Reference Extraction** — Large skills split into a compact SKILL.md (execution instructions) and a reference file (templates, tables, patterns). The AI loads the reference file on demand via inline pointers.
- **Frontmatter Flags** — Two flags control when and how skills load: `disable-model-invocation` removes internal skills from auto-suggestions (~280 tokens/session saved), and `context: fork` runs heavy skills in isolated subagents (30-48K tokens saved per invocation).

---

## How It Works

### Layer 0: CLAUDE.md (Always Loaded)

The plugin's root `CLAUDE.md` loads in every session where the plugin is active. It contains behavioral rules, trust boundaries, file locations, and the Skill-First Decision Tree. All content here is "always-on" cost.

| Constraint | Value |
|------------|-------|
| Target size | ≤ 130 lines |
| Hard cap | ≤ 150 lines |
| Current size | ~119 lines |

**Why most content must stay in CLAUDE.md**: Claude Code's path-scoped `.claude/rules/` files do not ship with plugins — they are project-local. Skills are invoked from arbitrary directories, so even project-level scoped rules (e.g., `paths: ["jaan-to/**"]`) would not load when a user invokes `/pm-prd-write` from `/src/app/`. Therefore, all universal behavioral rules (Two-Phase Workflow, Trust boundaries, Skill-First Decision Tree) must remain in CLAUDE.md.

**Tightening strategy**: Consolidate redundant wording and compress prose while preserving all behavioral semantics. No content removal — only reformulation.

### Layer 1: Session-Level (System Prompt)

When a Claude Code session starts, every skill's `description` field from its YAML frontmatter is injected into the system prompt. This is the **description budget**:

| Constraint | Value |
|------------|-------|
| Total budget | 15,000 characters |
| Per-skill overhead | ~109 chars XML |
| Max description | 120 chars |
| Validation | `scripts/validate-skills.sh` |

Skills with `disable-model-invocation: true` are excluded from auto-suggestions, saving ~280 tokens per session. These are internal skills (like `detect-*` infrastructure) that users don't invoke directly.

### Layer 2: Invocation-Level (Skill Execution)

When a skill runs, its full SKILL.md is loaded into context. Two mechanisms control this cost:

**Fork isolation** (`context: fork`): Heavy analysis skills (like `detect-dev`, `detect-design`) run in an isolated subagent. The parent conversation never sees the full skill definition — only the bounded output. This saves 30-48K tokens per invocation.

**Reference file loading**: Skills with inline pointers load reference material only when needed. The AI reads the pointer and fetches the specific section from the reference file, rather than having the entire reference pre-loaded.

### Layer 3: Skill-Level (SKILL.md Structure)

Each SKILL.md has a line target based on complexity:

| Complexity | Target | Max |
|------------|--------|-----|
| Simple (single-phase) | 150-300 | 400 |
| Standard (two-phase) | 300-500 | 500 |
| Complex (multi-stack) | 400-500 | 600 |

When a SKILL.md exceeds ~500 lines, **reference extraction** splits it:

**Stays in SKILL.md** (needed every invocation):
- Phase structure and step headings
- User interaction flows (AskUserQuestion)
- Compact detection tables (< 10 rows)
- Quality checklists and Definition of Done

**Moves to reference file** (loaded on demand):
- Code template blocks
- Multi-stack comparison tables
- CWE/OWASP mapping tables
- Configuration file examples
- Anti-pattern lists (> 10 items)
- Directory layout trees (> 10 lines)

Reference files live at `docs/extending/{skill-name}-reference.md` and are linked via inline pointers:

```
> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/{skill-name}-reference.md`
> section "{Section Name}" for {description}.
```

### Layer 4: CI Enforcement

Automated gates prevent token budget regression:

| Gate | Target | Enforcement |
|------|--------|-------------|
| SKILL.md hard cap | ≤ 600 lines | `validate-skills.sh` — fail |
| Reference coverage | >500 lines → must have reference file | `validate-skills.sh` — warn |
| Auto-invocable count | ≤ 35 skills | `validate-skills.sh` — warn |
| CLAUDE.md size | ≤ 150 lines | `release-check.yml` — fail |
| Description budget | ≤ 15,000 chars | `validate-skills.sh` — fail |
| Hook stdout cap | ≤ 1,200 chars (~300 tokens) | `release-check.yml` — fail |

---

## Examples

### v5.0.0 Optimization Results

Body-trimmed 8 large skills with reference extraction. Extracted language settings and pre-execution boilerplate from 31 skills. Added `disable-model-invocation` to 7 internal skills and `context: fork` to 6 detect skills.

**Savings**: ~2,000 tokens/session permanently, ~7K-48K tokens per skill invocation.

### v6.0.0 Spec-to-Ship Skills

5 new skills created at 3,351 total lines, then token-optimized to 2,507 lines (~25% reduction) via reference extraction:

| Skill | Before | After | Saved |
|-------|--------|-------|-------|
| dev-project-assemble | 726 | 489 | 33% |
| backend-service-implement | 731 | 521 | 29% |
| qa-test-generate | 735 | 556 | 24% |
| sec-audit-remediate | 518 | 452 | 13% |
| devops-infra-scaffold | 641 | 489 | 24% |

### v7.0.0 Token Optimization (Research #75)

Aggressive but quality-safe optimization based on [Research #75](research/75-token-optimization-aggressive-safe.md). Applied extraction safety checklist to distinguish safe-to-extract content (lookup tables, templates, scoring rubrics) from unsafe content (decision tables coupled to procedures, entity extraction algorithms).

| Phase | Optimization | Baseline savings | Per-invocation savings |
|-------|-------------|-----------------|----------------------|
| 1 | Reference extraction (16 skills) | — | ~2,000-8,000 tokens/invocation |
| 1 | Shared detect reference (5 skills) | — | ~1,500 tokens/invocation |
| 1B | Prose tightening (safe patterns, 15 skills) | — | ~150-225 tokens/invocation |
| 2 | CLAUDE.md tightening (~18 lines) | ~50 tokens/session | — |
| 3 | bootstrap.sh compact mode | ~100-200 tokens/session | — |
| 4 | 5 skills → manual-only | ~200 tokens/session | — |
| **Total** | | **~250-450 tokens/session** | **~3,650-9,725 tokens/invocation** |

**Safe prose tightening rules** (verified via deep analysis of 4 skills):
- Pattern 1: Kill preambles that only restate headings (safe)
- Pattern 5 (selective): Abbreviate informational placeholders only (safe for semantic IDs, unsafe for function params)
- Patterns 2-4 rejected: telegraphic instructions lose ordering constraints, compressed boolean lists lose mutual-exclusivity signaling, trimmed "Show user" blocks lose behavioral gates

**Representative skills after extraction** (lines extracted → current SKILL.md size):

| Skill | Lines Extracted | Current Size |
|-------|----------------|--------------|
| pm-research-about | 230 | 547 |
| roadmap-update | 175 | 465 |
| jaan-issue-report | 149 | 598 |
| backend-data-model | 134 | 464 |
| qa-test-cases | 124 | 478 |
| ux-flowchart-generate | 114 | 482 |
| detect-design | 100 | 497 |
| detect-ux | 97 | 498 |
| detect-writing | 93 | 532 |
| ux-microcopy-write | 82 | 553 |
| + 12 more skills | — | — |

23 reference files created at `docs/extending/*-reference.md`, including `detect-shared-reference.md` shared across 5 detect skills. Total: 44 files changed, 2,211 insertions, 1,858 deletions (net reduction ~938 lines).

**Post-v7 budget state** (updated after Agent Skills compatibility, v8):

| Metric | Value | Headroom |
|--------|-------|----------|
| Description budget | 10,282 / 15,000 chars | 31% remaining (~19 more skills) |
| Auto-invocable skills | 30 / 35 cap | 5 more before cap |
| CLAUDE.md | 119 / 150 lines | 31 lines free |
| Largest SKILL.md | ~507 lines / 600 cap | 93 lines before cap |
| Total skill lines | ~19,800 across 49 skills | Median ~440 lines |

> **Note:** Description budget increased from 8,409 to 10,282 chars due to Agent Skills enrichment (adding "Use when" trigger phrases to all 44 descriptions). 13 overlong SKILL.md files were refactored below 500 lines via reference extraction.

---

## Cumulative Impact

Token optimization across three major versions:

| Version | Session Savings | Per-Invocation Savings | Method |
|---------|----------------|----------------------|--------|
| v5.0.0 | ~2,000 tokens | ~7K-48K tokens | Fork isolation (6 detect), body trimming (8 skills), `disable-model-invocation` (7 skills) |
| v6.0.0 | — | ~25% body reduction | Reference extraction at creation time (5 new skills) |
| v7.0.0 | +~350 tokens | +~2K-8K tokens | Aggressive extraction (22 skills), CLAUDE.md tightening, bootstrap compact mode |
| **Cumulative** | **~2,400 tokens/session** | **Up to ~56K per invocation** | **49 skills, 26 reference files, 6 CI gates** |

**Practical effect:** A typical skill invocation loads ~450-500 lines of execution instructions instead of the ~600-700 lines that would exist without extraction. This saves roughly 500-2,000 tokens per call. For skills using `context: fork` (6 detect skills), the parent session never sees these tokens — the full 30-48K cost is isolated to a disposable subagent. Combined, a session that invokes 3 skills and 1 detect analysis saves approximately 5,000-52,000 tokens versus an unoptimized plugin of equivalent capability.

---

## Future Skill Compliance

All new skills must follow token strategy from creation:

1. **Description**: ≤ 120 chars, no colons
2. **Body size tiers**: Simple 150-300 (max 400), Standard 300-500 (max 500), Complex 400-500 (max 600)
3. **Reference extraction trigger**: If >500 lines during authoring, extract lookup/template content using the extraction safety checklist
4. **Prose rules**: Kill preambles (don't restate headings), abbreviate informational placeholders (not function params)
5. **Frontmatter checklist**: Consider `disable-model-invocation` for narrow-domain skills, `context: fork` for >30K token skills
6. **CI validation**: Run `scripts/validate-skills.sh` after adding any skill

Reference: `docs/extending/create-skill.md` for the enforced template.

---

## Related

- [Token Optimization Strategy (Builder Reference)](extending/create-skill.md) — Implementation details for skill authors
- [Roadmap](roadmap/roadmap.md) — Version history with optimization milestones
- [Research #18: Token Optimization](research/18-token-optimization.md) — Original research
- [Research #62: Claude Code Token Optimization](research/62-ai-workflow-claude-code-token-optimization.md) — Deep research
- [Research #75: Aggressive Token Optimization](research/75-token-optimization-aggressive-safe.md) — v7.0.0 research basis
- [Extraction Safety Checklist](extending/extraction-safety-checklist.md) — What to extract vs. keep inline
