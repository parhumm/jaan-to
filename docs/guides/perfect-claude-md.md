# The Perfect CLAUDE.md — Best Practices, Anti-Patterns & Checklist

> A synthesized reference for writing high-quality `CLAUDE.md` files.
> Source: deep read of 12 internal research summaries (01, 05, 06, 07, 08, 11, 14, 24, 33, 40, 62, 82).

---

## The One Principle Everything Else Follows From

**CLAUDE.md loads into context at the start of *every* session — with no lazy loading.**

It is a permanent token tax and a permanent instruction budget. Every level of the hierarchy loads (enterprise → project → user → local), plus anything pulled in via `@path` imports (recursive up to 5 levels deep). Two hard limits flow from this:

1. **Token budget** — A bloated CLAUDE.md (2,800+ lines is a documented anti-pattern) wastes up to **62% of tokens per session**. Optimized files cut initial context consumption by **54–62%**.
2. **Instruction budget** — Frontier models reliably follow only **~150–200 instructions**, and Claude Code's own system prompt already consumes ~50 of them. Past that, *Claude starts ignoring rules* — including important ones lost in the noise.

So the golden rule is: **Document only what Claude gets *wrong* or *can't guess*. Link or defer everything else.** Context quality beats context quantity.

For every single line, apply this filter:

> **"Would removing this line cause Claude to make a mistake?"** If no → delete it.

---

## What to Include vs. Exclude

| ✅ Include (Claude can't infer these) | ❌ Exclude (prune ruthlessly) |
|---------------------------------------|-------------------------------|
| Bash/make commands Claude can't guess (esp. how to run **one** test) | Anything Claude can learn by reading the code |
| Code-style rules that **differ** from language defaults | Standard language conventions / self-evident practices |
| Testing instructions & conventions | Detailed API docs → **link instead** |
| Repo etiquette (branch naming, PR/commit format) | File-by-file descriptions |
| Architectural decisions & non-obvious boundaries | Information that changes frequently |
| Developer-environment quirks (ports, services, setup gotchas) | Entire files via `@import` (loads every session) |
| A "What NOT to do" section | Long lists of complex custom slash commands |

---

## Recommended Structure

Keep the **root file under 200 lines** (hard cap 500 / ~10,000 words — beyond that Claude ignores sections). Organize along three axes: **WHAT** (stack, structure), **WHY** (purpose), **HOW** (commands, tooling).

```markdown
# <Project Name>
> One-line description.

## Project Overview
2–3 sentences: what it does, who it's for, the core domain concept.

## Tech Stack
- Language/runtime + version (only if non-obvious)
- Key frameworks + the architectural *why*
- Package manager (the thing Claude can't guess)

## Commands
| Command | What it does |
|---------|-------------|
| `make dev` | Start dev server (port 3000) |
| `pnpm test` | Run tests — ALWAYS run before commit |
| `pnpm test path/to/one.test` | Run a single test |
| `make lint` | Lint + format |

## Architecture
- Key patterns (e.g. "feature-based folders under src/features/")
- Non-obvious data flow / boundaries
- See @docs/architecture.md for the full picture   ← pointer, not inline

## Code Style (deltas from defaults only)
- IMPORTANT: <rule Claude gets wrong>, e.g. "No default exports"
- Follow existing patterns — `HotDogWidget.tsx` is a good example

## Testing
- How to run a single test
- Conventions: "avoid mocks", "co-locate *.test.ts"

## Repository Etiquette
- Branch naming: `feature/`, `fix/`
- Commit format (Conventional Commits); PR conventions

## What NOT to Do
- YOU MUST NOT edit generated files in `src/gen/`
- NEVER run `git reset --hard` without explicit confirmation
- Don't add dependencies without asking

## Verification
- Before completing any task, describe how you'd verify the work
- Run `pnpm type:check` after every TypeScript change

## Skill / Domain Triggers   ← only for large frameworks
| Triggers | Skill | Domain |
|----------|-------|--------|
| deploy, release, ship | deployment | Dev |
| wireframe, mockup | ux-design | UX |
```

---

## Best Practices

### Content
1. **Generate, then refine.** Run `/init` for a starter file, then prune by hand — don't hand-author from scratch, don't ship the raw `/init` output.
2. **Pointers over copies.** Inline code snippets go stale as the codebase evolves. Use `@path/to/file` or `file:line` references to authoritative source instead.
3. **Give Claude a way to verify its work.** Tests, lint, expected outputs, screenshots. This is repeatedly called **the single highest-leverage practice** — it closes the "trust-then-verify gap" where AI produces plausible code that fails edge cases (AI code carries ~1.75× more logic errors without visual/test verification).
4. **Emphasis for critical rules only.** `IMPORTANT`, `YOU MUST`, `NEVER` measurably improve adherence — but overusing them dilutes the signal. Reserve for the rules that actually matter.
5. **Check into git.** A shared, committed CLAUDE.md lets the whole team contribute and benefit. Personal preferences go in `CLAUDE.local.md` (auto-gitignored) or `~/.claude/CLAUDE.md`.

### Token discipline (the always-loaded tax)
6. **Use the skill-trigger-table pattern.** Replace verbose per-skill protocols with a compact lookup table (~800 tokens vs. 3,000+). Detailed protocols live in the individual `SKILL.md` files, loaded only when triggered.
7. **Nest CLAUDE.md files in subdirectories.** These are **lazily loaded** — they enter context only when Claude touches files in that subtree. Put React conventions in `packages/frontend/CLAUDE.md`, API rules in `packages/backend/CLAUDE.md`, etc. (ideal for monorepos).
8. **Use path-scoped rules** in `.claude/rules/` with a `paths:` YAML frontmatter field — they load only when Claude works on matching files. Rules *without* `paths:` load unconditionally, so keep those minimal.
9. **Progressive disclosure.** Pair a lean CLAUDE.md (static upfront context) with an `agent-docs/` folder (dynamic, just-in-time retrieval). Reference the docs with one-line descriptions; Claude reads them on demand. This is Anthropic's recommended "hybrid strategy."
10. **Mermaid for architecture.** A few hundred tokens of Mermaid can convey what would take thousands in prose.

### Configuration layering
11. **Know the hierarchy** (precedence high → low): Managed → CLI args → Local → Project → User.

    | Layer | Location | Scope |
    |-------|----------|-------|
    | Managed (enterprise) | system `managed-settings.json` | Org-wide, can't override |
    | User | `~/.claude/settings.json` + `~/.claude/CLAUDE.md` | You, all projects |
    | Project (shared) | `.claude/settings.json` + root `CLAUDE.md` | Team, committed to git |
    | Project (local) | `.claude/settings.local.json` + `CLAUDE.local.md` | You, this repo, gitignored |

12. **When a rule must be *guaranteed*, use a hook — not a CLAUDE.md line.** CLAUDE.md is *advisory*; hooks are *deterministic*. The control hierarchy is:
    **Hooks (deterministic) > Rules (path-scoped) > CLAUDE.md (advisory) > Skills (on-demand) > User prompts (per-session).**
13. **Consider a SessionStart hook for dynamic context** (current git branch, running services, environment state) instead of baking volatile facts into static CLAUDE.md. One team cut session-start tokens 62% (2,100 → 800) this way.
14. **Customize compaction behavior** in CLAUDE.md so long sessions summarize the way you want.

---

## Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|--------------|-----|
| **CLAUDE.md overload** (2,800+ lines / >10k words) | Wastes ~62% of tokens; Claude ignores rules lost in noise | Ruthlessly prune; if Claude already does it right, delete the rule |
| **Embedding files via `@import`** | Loads entire file contents on *every* session start | Use pointers ("see Skill('deployment')") to defer loading |
| **Stale inline code snippets** | Drift out of sync with the real codebase | Reference `file:line` / `@path` to authoritative source |
| **Kitchen-sink CLAUDE.md** (comprehensive manual) | Documents what Claude already knows | Document only what Claude gets *wrong* |
| **Over-using `IMPORTANT`/`YOU MUST`** | Dilutes emphasis until none of it lands | Reserve for genuinely critical rules |
| **Long list of complex custom slash commands** | "If you have a long list of complex slash commands, you've created an anti-pattern" | Put context in CLAUDE.md; let Claude route via natural language + auto-invoked skills |
| **Behavioral rules that should be hooks** | Advisory text gets skipped; can't be enforced | Convert deterministic requirements (format, file protection) to hooks |
| **No verification path** | "Trust-then-verify gap" — plausible code that fails edge cases | Add tests/lint/screenshots + "describe how you'd verify" |
| **Write-time formatting hooks** (related trap) | One case burned 160K tokens in 3 rounds | Format via pre-commit git hooks, not Claude Code hooks |

---

## The Checklist

**Scope & content**
- [ ] Root file is **< 200 lines** (hard cap 500 / ~10k words)
- [ ] Every line passes the test: *"Would removing this cause a mistake?"*
- [ ] Includes non-guessable commands — especially **how to run a single test**
- [ ] Includes only code-style rules that **differ from defaults**
- [ ] Includes repo etiquette (branch naming, commit/PR format)
- [ ] Includes architectural decisions & non-obvious boundaries
- [ ] Includes dev-environment quirks (ports, services, setup gotchas)
- [ ] Has an explicit **"What NOT to do"** section
- [ ] Has a **verification** instruction (tests/lint/screenshots)
- [ ] **Excludes** anything inferable from the code, frequently-changing info, and detailed API docs (linked instead)

**Token & instruction discipline**
- [ ] Uses **trigger tables**, not inlined per-skill protocols
- [ ] Domain rules pushed to **nested CLAUDE.md** / `.claude/rules/` with `paths:`
- [ ] Pointers (`@path`, `file:line`) instead of inlined snippets or `@import`-ed full files
- [ ] `IMPORTANT`/`YOU MUST` used sparingly, on critical rules only
- [ ] Volatile facts injected via **SessionStart hook**, not hardcoded

**Setup & hygiene**
- [ ] Generated via `/init`, then manually pruned
- [ ] **Checked into git**; personal prefs in `CLAUDE.local.md` / `~/.claude/CLAUDE.md`
- [ ] Guaranteed rules implemented as **hooks**, not advisory text
- [ ] Verified with `/context` that it isn't bloating the session
- [ ] Reviewed periodically — delete rules Claude now follows without them

---

## Token Budget Reference (200K window)

For a heavily-loaded setup, an optimized CLAUDE.md should cost **~1,500 tokens (0.75%)** of context. Compare with the costs it competes against:

| Component | Tokens | Note |
|-----------|--------|------|
| CLAUDE.md (optimized, trigger table) | ~1,500 | Target |
| CLAUDE.md (bloated, 2,800+ lines) | ~tens of thousands | Wastes up to 62% per session |
| Auto-invocable skill metadata | ~40–100 / skill | Progressive disclosure |
| MCP tools (no Tool Search) | 48K–134K | The biggest hidden cost — keep under ~20–25K |
| System prompt + built-in tools | ~15K | Fixed |

**Rule of thumb:** keep CLAUDE.md + rules in the low thousands of tokens, monitor with `/context`, and compact proactively at **60–70%** usage rather than waiting for auto-compact.

---

## TL;DR

A perfect CLAUDE.md is **short, git-committed, and full of only what Claude can't infer or routinely gets wrong.** It links rather than inlines, uses trigger tables and nested files to defer cost, reserves emphasis for what matters, hands off guaranteed rules to hooks, and always gives Claude a way to verify its own work. It loads every session — so every line has to earn its place.
