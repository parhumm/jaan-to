---
title: "Token Strategy"
doc_type: concept
created_date: 2026-02-11
updated_date: 2026-02-11
tags: [tokens, optimization, architecture, performance]
related: [docs/extending/create-skill.md, docs/roadmap/roadmap.md]
---

# Token Strategy

> How jaan.to manages token efficiency across skills, sessions, and invocations.

---

## What Is It?

Token strategy is jaan.to's system-wide approach to minimizing context window usage while preserving full skill capabilities. Every skill loaded into a Claude Code session consumes tokens from a finite context window. Without active management, skill definitions, descriptions, and reference material would quickly exhaust the available budget — degrading performance or silently dropping skills.

jaan.to addresses this at three levels: **session-level** (what gets loaded), **invocation-level** (how skills run), and **skill-level** (how SKILL.md files are structured).

---

## Key Points

- **Description Budget** — All skill descriptions share a 15,000-character budget in the system prompt. Exceeding it causes skills to be silently dropped. Each skill costs ~109 chars XML overhead plus description length.
- **Reference Extraction** — Large skills split into a compact SKILL.md (execution instructions) and a reference file (templates, tables, patterns). The AI loads the reference file on demand via inline pointers.
- **Frontmatter Flags** — Two flags control when and how skills load: `disable-model-invocation` removes internal skills from auto-suggestions (~280 tokens/session saved), and `context: fork` runs heavy skills in isolated subagents (30-48K tokens saved per invocation).

---

## How It Works

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

---

## Related

- [Token Optimization Strategy (Builder Reference)](extending/create-skill.md) — Implementation details for skill authors
- [Roadmap](roadmap/roadmap.md) — Version history with optimization milestones
- [Research #18: Token Optimization](research/18-token-optimization.md) — Original research
- [Research #62: Claude Code Token Optimization](research/62-ai-workflow-claude-code-token-optimization.md) — Deep research
