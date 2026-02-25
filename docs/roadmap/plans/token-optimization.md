# Token Optimization Plan for jaan.to Plugin

## Context

The jaan.to plugin has 26 skills totaling **15,382 lines** across all SKILL.md files. 22 of 26 exceed the recommended 500-line limit. All 26 are auto-invocable (metadata always in context), none use `context: fork`, and ~1,400 lines of boilerplate are duplicated across skills. CLAUDE.md is 281 lines, loading fully every session. This plan applies 6 optimizations verified by 3 quality-reviewer agents to reduce token usage while preserving full functionality.

---

## Step 1: Add `disable-model-invocation: true` to 7 internal skills

**Verdict: PASS** — All confirmed as manual-only invocations.

Add `disable-model-invocation: true` to frontmatter of:
- `skills/pm-roadmap-add/SKILL.md`
- `skills/pm-roadmap-update/SKILL.md`
- `skills/skill-create/SKILL.md`
- `skills/skill-update/SKILL.md`
- `skills/learn-add/SKILL.md`
- `skills/docs-create/SKILL.md`
- `skills/docs-update/SKILL.md`

**Saves**: ~280 tokens permanently from every session.

---

## Step 2: Add `context: fork` to 6 detect skills

**Verdict: PASS** — All detect skills are self-contained. detect-pack reads other detect outputs from disk (not conversation context).

Add `context: fork` to frontmatter of:
- `skills/detect-dev/SKILL.md` (663 lines)
- `skills/detect-design/SKILL.md` (587 lines)
- `skills/detect-writing/SKILL.md` (557 lines)
- `skills/detect-product/SKILL.md` (539 lines)
- `skills/detect-ux/SKILL.md` (556 lines)
- `skills/detect-pack/SKILL.md` (801 lines)

**Saves**: ~30K-48K tokens per detect run (isolated from main context).

---

## Step 3: Extract Language Settings boilerplate

**Verdict: PASS with WARN** — 4 variants exist, not 1. Core 13 lines extractable; 7 skills need inline exception notes retained.

**Create**: `docs/extending/language-protocol.md` (~13 lines) — the core language resolution logic.

**In each SKILL.md**, replace the ~17-line Language Settings section with:
```markdown
### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_{skill-name}`
```

**For 7 skills with exception notes** (backend-api-contract, backend-task-breakdown, backend-data-model, data-gtm-datalayer, frontend-design, frontend-task-breakdown, ux-microcopy-write, detect-writing): keep their `> **Language exception**:` blockquote inline after the reference.

**Also list** `docs/extending/language-protocol.md` in each skill's `## Context Files` section to ensure reliable loading.

**Saves**: ~247 net lines (~2,500 tokens per skill invocation).

---

## Step 4: Extract Pre-Execution boilerplate (hybrid approach)

**Verdict: PASS with WARN** — 10 of 26 skills have custom additions (2-10 extra lines). Pure extraction won't work for all. Use hybrid: extract core + retain custom inline.

**Create**: `docs/extending/pre-execution-protocol.md` (~10 lines) — the standard LEARN.md loading pattern with `{SKILL_NAME}` placeholder.

**For 16 "clean" skills** (no custom additions): Replace full Pre-Execution with:
```markdown
## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `{skill-name}`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)
```

**For 10 skills with custom additions** (skill-create, qa-test-cases, pm-story-write, pm-prd-write, frontend-design, backend-api-contract, backend-data-model, backend-task-breakdown, frontend-task-breakdown, learn-add): Use the reference PLUS retain custom lines inline below it.

**Saves**: ~395 net lines total across all 26 skills (~4,600 tokens per full catalog).

---

## Step 5: Trim large skills (revised per-skill targets)

**Verdict: WARN** — Only 3/8 skills can reach <500 lines. 5 have core workflow that can't be safely extracted. Revised targets per agent verification.

### Skills targetable to <500 lines (3 skills)

| Skill | Current | Target | Strategy |
|-------|---------|--------|----------|
| `skill-update` | 970 | ~440 | Extract v3.0.0 compliance examples (V3.1-V3.8 code blocks, ~200 lines) to `docs/extending/v3-compliance-reference.md`. Keep check labels inline. Extract git/PR workflow (~60 lines) to `docs/extending/git-pr-workflow.md`. |
| `skill-create` | 924 | ~473 | Extract v3.0.0 best practices (Steps 12.1-12.8, ~317 lines) to shared `v3-compliance-reference.md`. Extract template variable examples (~59 lines). Share git/PR workflow file. |
| `detect-dev` | 663 | ~483 | Extract SARIF format reference and OpenSSF scoring tables (~180 lines) to `docs/extending/detect-dev-reference.md`. |

### Skills with revised realistic targets (5 skills)

| Skill | Current | Target | Strategy |
|-------|---------|--------|----------|
| `pm-research-about` | 947 | ~750 | Extract wave capacity tables (~96 lines) and agent dispatch formulas (~40 lines). Core 5-wave system must stay inline. |
| `backend-task-breakdown` | 833 | ~643 | Extract export format templates (Jira/Linear/JSON, ~52 lines) and master task card template (~86 lines) to reference files. Core PRD-to-task mapping stays inline. |
| `ux-microcopy-write` | 832 | ~632 | Extract per-language rules (~39 lines) and export format examples (React/Vue/ICU, ~88 lines). Core generation workflow stays. |
| `detect-pack` | 801 | ~631 | Extract multi-platform consolidation pseudocode (~117 lines) and evidence ID regex (~54 lines). Note: this skill uses `context: fork`, so body size matters less. |
| `ux-research-synthesize` | 726 | ~606 | Extract theme card templates (~60 lines) and recommendation format (~60 lines). Braun & Clarke 6-phase stays inline. |

### New shared reference files (in `docs/extending/`)

- `language-protocol.md` — core language resolution (~13 lines)
- `pre-execution-protocol.md` — standard LEARN.md loading (~10 lines)
- `v3-compliance-reference.md` — v3.0.0 detection patterns and examples (~200 lines, shared by skill-update + skill-create)
- `git-pr-workflow.md` — branch setup, commit, PR creation (~60 lines, shared by skill-update + skill-create)
- `detect-dev-reference.md` — SARIF format + OpenSSF scoring (~180 lines)

### Skill-specific reference files

- `research-methodology.md` — wave capacity tables + dispatch formulas (~136 lines)
- `backend-export-formats.md` — Jira/Linear/JSON templates (~138 lines)
- `microcopy-reference.md` — per-language rules + export formats (~127 lines)
- `detect-pack-reference.md` — consolidation pseudocode + regex (~171 lines)
- `ux-research-templates.md` — theme card + recommendation formats (~120 lines)

---

## Step 6: Trim CLAUDE.md from 281 to ~110 lines

**Verdict: PASS** — All sections verified. No skills reference CLAUDE.md for output paths. Available Commands table is redundant and incomplete.

### Sections to keep (CRITICAL, ~65 lines)
- Header + tagline (5 lines)
- Documentation table (9 lines)
- Plugin Architecture (2 lines)
- Single Source of Truth (11 lines)
- Trust rules (10 lines)
- Two-Phase Workflow (4 lines)
- Quality rules (5 lines)
- Human-Centered rules (4 lines)
- Language rules — 3-line summary with pointer to `docs/extending/language-protocol.md`
- File Locations table (17 lines) — keep for navigation

### Sections to extract to `docs/extending/`
- **Output Structure** (43 lines) → `docs/extending/output-structure.md`, replace with 2-line pointer
- **Naming Conventions** (13 lines) → `docs/extending/naming-conventions.md`, replace with 1-line pointer
- **Development Workflow** (48 lines) → `docs/extending/dev-workflow.md`, replace with 1-line pointer
- **Customization** (41 lines) → already covered in `docs/guides/`, replace with 1-line pointer

### Sections to remove
- **Available Commands table** (15 lines) — incomplete (10/26 skills), auto-discovered by plugin system
- **Plugin Features: Agents** (6 lines) — auto-discovered

**Saves**: ~170 lines permanently (~1,700 tokens per session).

---

## Files Modified Summary

| Category | Count | Files |
|----------|-------|-------|
| Frontmatter-only (step 1) | 7 | roadmap-add, roadmap-update, skill-create, skill-update, learn-add, docs-create, docs-update |
| Frontmatter-only (step 2) | 6 | detect-dev, detect-design, detect-writing, detect-product, detect-ux, detect-pack |
| Boilerplate extraction (steps 3-4) | 26 | All SKILL.md files |
| Body trimming (step 5) | 8 | skill-update, skill-create, detect-dev, pm-research-about, backend-task-breakdown, ux-microcopy-write, detect-pack, ux-research-synthesize |
| CLAUDE.md trim (step 6) | 1 | CLAUDE.md |
| New shared reference files | 7 | language-protocol.md, pre-execution-protocol.md, v3-compliance-reference.md, git-pr-workflow.md, output-structure.md, naming-conventions.md, dev-workflow.md |
| New skill-specific refs | 5 | detect-dev-reference.md, research-methodology.md, backend-export-formats.md, microcopy-reference.md, detect-pack-reference.md, ux-research-templates.md |

---

## Estimated Token Savings

| Optimization | Savings | When |
|---|---|---|
| `disable-model-invocation` on 7 skills | ~280 tokens | Permanent (every session) |
| `context: fork` on 6 detect skills | ~30K-48K tokens | Per detect run (isolated context) |
| Language Settings extraction | ~2,500 tokens | Per skill invocation |
| Pre-Execution extraction | ~4,600 tokens | Per skill invocation |
| Skill body trimming (8 skills) | ~3K-5K tokens | Per invocation of trimmed skills |
| CLAUDE.md trim (281→~110 lines) | ~1,700 tokens | Permanent (every session) |
| **Total permanent per-session** | **~2,000 tokens** | |
| **Total per-skill-invocation** | **~7K-48K tokens** depending on skill | |

---

## Execution Order

1. **Step 6 first** — CLAUDE.md trim (highest leverage: permanent, every session)
2. **Steps 1-2** — Frontmatter flags (quick wins, no content changes)
3. **Steps 3-4** — Boilerplate extraction (create shared files, update all 26 skills)
4. **Step 5** — Body trimming (extract reference content from 8 skills)

---

## Verification

1. Run `scripts/validate-skills.sh` to ensure all SKILL.md files pass structural validation
2. Start a fresh session, run `/context` to verify reduced baseline overhead
3. Invoke `/pm-prd-write test` — verify language settings and pre-execution still work from referenced files
4. Invoke `/detect-dev` — verify it runs in forked context and returns summary
5. Invoke `/skill-update` by slash command — verify it still works despite `disable-model-invocation: true`
6. Check that internal skills (roadmap-add, docs-create, etc.) no longer appear in auto-invocation suggestions
7. Verify CLAUDE.md loads correctly and behavioral rules are preserved
