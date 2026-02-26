# AI-driven UI development with Storybook, shadcn/ui, and Claude Code

**The convergence of MCP servers, Claude Code Skills, and Storybook 9's AI integration creates a fundamentally new UI development paradigm — one where AI agents don't guess at component APIs but access live, authoritative design system context in real time.** This strategic overview covers the complete architecture for "jaan-to," a shared-folder convention enabling both solo developers and teams to achieve repeatable, high-quality AI-assisted UI workflows. The core philosophy — "Skills stay generic, MCP provides real context" — shapes every layer of the system: Skills encode portable expertise (how to build UI well), while MCP servers connect agents to the living truth of your component registries, Storybook instances, and design tools. Built on research from Anthropic's engineering blog, Storybook's agentic UI research (issue #32276), production case studies from Palo Alto Networks and others, and the latest Claude Code features through early 2026, this report provides the strategic blueprint for a system that turns AI from an unreliable code generator into a governed, visually verified UI development partner.

---

## The MCP foundation: four servers, one coherent context layer

The entire workflow rests on a carefully curated set of MCP servers configured in a project-scoped `.mcp.json` at the repo root. Each server serves a distinct purpose, and **keeping the total count low is critical** — every MCP tool definition consumes 200–850 tokens, and exceeding ~20k tokens of tool definitions measurably degrades Claude's reasoning quality.

The recommended `.mcp.json` for jaan-to projects:

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    },
    "storybook-mcp": {
      "transport": "http",
      "url": "http://localhost:6006/mcp"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

The **shadcn MCP server** (`npx shadcn@latest mcp`) bridges Claude to the official component registry plus any private registries configured in `components.json`. Without it, Claude hallucinates props — suggesting `<Button loading={true}>` when shadcn's Button has no `loading` prop. With it, Claude receives actual TypeScript definitions from the live registry, producing correct code aligned with the latest specs. The server supports multi-registry setups for enterprise teams with private component libraries, using environment variable expansion for authentication tokens.

The **Storybook MCP addon** (`@storybook/addon-mcp`, requiring Storybook **9.1.16+**) runs an MCP endpoint at `localhost:6006/mcp` when the dev server is active. It exposes four tools across two toolsets: `get-ui-building-instructions` provides project-specific conventions for component creation, `get-story-urls` returns direct links to rendered stories, and when `experimentalComponentsManifest` is enabled, `list-all-components` and `get-component-documentation` give agents structured access to your entire component catalog. The autonomous correction loop built into this system — where agents run interaction tests, see failures, and self-heal — is the key enabler of reduced human oversight.

**Playwright MCP** (`@playwright/mcp@latest`) gives Claude literal "eyes" with 25 browser automation tools including `browser_take_screenshot`, `browser_navigate`, and `browser_snapshot`. This enables the screenshot → compare → fix loop that transforms AI output quality. For CI environments, add the `--headless` flag.

**Figma's Dev Mode MCP server** is optional but powerful for design-to-code workflows. Available as a remote endpoint (`https://mcp.figma.com/mcp`) or local desktop server (`http://127.0.0.1:3845/mcp`), its `get_code` tool generates React + Tailwind markup from selected Figma frames. The critical integration point is **Code Connect**, which maps Figma design components directly to your codebase components — telling the AI agent exactly which real component to use rather than generating generic markup.

Three scope levels govern MCP configuration: **local** (personal, project-specific in `~/.claude.json`), **project** (shared via `.mcp.json` in git), and **user** (personal, all projects). Local overrides project, which overrides user. Teams should put the core four servers in `.mcp.json` for shared access while individual developers add personal servers at the user scope.

### Token budget management prevents context collapse

MCP context bloat is the **single most destructive anti-pattern** in AI-driven development. Real-world measurements show 7 MCP servers consuming 67,300 tokens (33.7% of the 200k context window) before any conversation begins. One developer documented 82,000 tokens from MCP tools alone, leaving just 12k tokens for actual work.

Claude Code v2.1.7+ introduced **MCP Tool Search**, a lazy-loading system that automatically activates when tool definitions exceed 10% of the context window. It builds a lightweight search index and fetches full schemas on-demand, achieving **85% reduction** in tool definition overhead and improving accuracy from 49% to 74% on Opus 4. Teams should write clear `serverInstructions` in their MCP configs to optimize Tool Search discovery.

Practical token budget targets for the 200k window: system prompt ~4k tokens, system tools ~15k, **MCP tools under 25k**, reserved for autocompact + output ~45k, leaving **110k+ tokens** for conversation and code. Use `/context` regularly to monitor and `/compact` proactively at 70% usage.

---

## CLAUDE.md and the progressive disclosure architecture

The CLAUDE.md file is Claude's only persistent memory between sessions — it loads at the start of every conversation. Research from academic papers on LLM instruction-following shows that **frontier models follow ~150–200 instructions reliably**, and Claude Code's system prompt already consumes ~50 of those. This means CLAUDE.md must be ruthlessly concise.

A UI-focused CLAUDE.md for jaan-to should follow three axes — WHAT (stack, structure), WHY (purpose), HOW (commands, tooling) — in under 100 lines:

```markdown
# Project: [Name]
Next.js 15 + App Router, TypeScript strict, shadcn/ui (Tailwind v4)

## Commands
- `pnpm dev` — Dev server (port 3000)
- `pnpm storybook` — Storybook (port 6006)
- `pnpm test` — Vitest tests
- `pnpm lint` — ESLint + Biome check

## Architecture
- `/app` — Next.js App Router pages
- `/components/ui` — shadcn/ui primitives (DO NOT manually edit, use CLI)
- `/components/custom` — Project components built from shadcn primitives
- `/jaan-to/` — AI workflow configs, skills, agent docs

## Critical Rules
- Use shadcn MCP server to check component APIs before generating code
- Always call Storybook MCP get-ui-building-instructions before frontend work
- Run `pnpm type:check` after every TypeScript change
- NEVER use `git reset --hard` without explicit confirmation
- See @jaan-to/agent-docs/ for detailed context on specific domains
```

For each line, apply the filter: "Would removing this cause Claude to make mistakes?" If not, cut it. **Prefer pointers to copies** — inline code snippets become stale as the codebase evolves. Instead, use `@path/to/file` references that point Claude to authoritative source code.

### Path-scoped rules create targeted guardrails

The `.claude/rules/` directory supports modular markdown files with YAML frontmatter for conditional loading:

```yaml
---
paths:
  - "components/custom/**/*.tsx"
---
# Component Development Rules
- All components must use CVA for variants
- Export buttonVariants-style cva() separately from component
- Include Storybook story file alongside every new component
- Use cn() utility for class merging, never raw string concatenation
```

Rules without a `paths:` field load unconditionally as global rules. This creates a layered system: global rules in `rules/general.md`, component-specific patterns in `rules/frontend/react.md`, API conventions in `rules/backend/api.md`. Note that path-scoped rules have known edge-case bugs (GitHub issues #16299, #16853) — glob patterns starting with `{` or `*` must be quoted in YAML.

### The agent_docs/ folder enables progressive disclosure

Rather than cramming everything into CLAUDE.md, maintain a `jaan-to/agent-docs/` directory:

```
jaan-to/
├── agent-docs/
│   ├── component-patterns.md
│   ├── design-tokens.md
│   ├── testing-strategy.md
│   ├── accessibility-standards.md
│   └── api-conventions.md
├── skills/
│   └── [project skills]
└── commands/
    └── [project commands]
```

Then reference these files in CLAUDE.md with brief descriptions. Claude reads them on-demand only when relevant. This pattern — **static upfront context in CLAUDE.md + dynamic just-in-time retrieval from agent_docs/** — is Anthropic's recommended "hybrid strategy" for context engineering. John Lindquist (egghead.io) further recommends using Mermaid diagrams for architecture context: "A few hundred tokens of Mermaid syntax can convey what would take thousands in prose."

For teams, CLAUDE.md lives in git. Personal preferences go in `CLAUDE.local.md` (auto-gitignored) or `~/.claude/CLAUDE.md` for cross-project defaults.

---

## Skills architecture: portable expertise with zero upfront cost

Claude Code Skills use a **three-level progressive disclosure** system that makes them remarkably token-efficient. At startup, only the `name` and `description` from YAML frontmatter are loaded — approximately **100 tokens per skill**. When Claude determines a skill is relevant, it reads the full SKILL.md body (recommended under 5k tokens). Bundled resources — scripts, templates, reference docs — consume **zero context tokens** until actually accessed via bash reads.

The canonical skill structure for jaan-to:

```
jaan-to/skills/
├── ui-component/
│   ├── SKILL.md
│   ├── scripts/
│   │   └── scaffold.sh
│   └── references/
│       └── component-template.tsx
├── design-review/
│   ├── SKILL.md
│   └── references/
│       └── review-checklist.md
└── a11y-audit/
    └── SKILL.md
```

Two Anthropic-provided skills are essential for UI work. The **web-artifacts-builder** skill enables React + Tailwind + shadcn/ui development beyond Claude's default single-HTML-file limitation. It bundles initialization scripts and Parcel-based bundling, teaching Claude component composition patterns and responsive design. Install it with `npx skills add https://github.com/anthropics/skills --skill web-artifacts-builder`.

The **frontend-design** skill (~400 tokens) combats **distributional convergence** — the tendency for AI to produce homogeneous "AI slop" aesthetics. It enforces distinctive typography (never Inter, Roboto, or Arial — use JetBrains Mono, Playfair Display, IBM Plex instead), cohesive color systems with dominant colors and sharp accents, purposeful CSS-only animations, and atmospheric backgrounds with layered gradients. It explicitly bans purple gradients on white, cookie-cutter layouts, and convergence on common "safe" choices. This skill auto-activates when Claude detects frontend work.

The interaction model between Skills and MCP embodies the core philosophy: **Skills encode generic, reusable expertise** (how to structure a component, how to avoid AI slop, how to run an accessibility audit), while **MCP provides real-time project context** (actual component APIs from your registry, live Storybook URLs, current design tokens from Figma). A skill can reference MCP outputs — the `sentry-code-review` skill uses Sentry's MCP for live error data — but the skill itself remains portable across projects.

---

## The Storybook feedback loop: prompt, generate, verify, iterate

Storybook's role in this architecture extends far beyond component documentation. With the MCP addon, it becomes an **active participant in the AI development loop** — providing structured context at generation time and visual verification at review time.

The workflow unfolds in four phases. First, the agent calls `get-ui-building-instructions` to receive project-specific conventions: CSF syntax preferences, import patterns, language settings. Second, it queries `list-all-components` and `get-component-documentation` (via the Component Manifest) to understand what building blocks exist. Third, it generates the component and companion story in CSF3 format. Fourth, it calls `get-story-urls` to provide clickable links for immediate visual verification.

**CSF3 (Component Story Format 3)** is significantly more AI-friendly than CSF2. Stories are defined as plain objects rather than functions, which are more parseable by language models. Automatic title inference from file paths eliminates hardcoding. The `args` pattern makes stories fully declarative:

```typescript
const meta = { component: Button } satisfies Meta<typeof Button>;
export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: { variant: "default", size: "md", children: "Click me" },
};

export const Destructive: Story = {
  args: { variant: "destructive", children: "Delete" },
};
```

The **Component Manifest** (`experimentalComponentsManifest: true` in `.storybook/main.js`) is the strategic enabler for design system governance. It generates structured JSON containing component names, validated prop types, design token bindings, story args, and usage examples — served dynamically at `localhost:6006/manifests/components.json`. This lets agents parse a component's full interface in a fraction of the tokens needed to read source files. For teams distributing design systems, Chromatic hosts MCP servers automatically — publish via `npx chromatic` and consumers connect to `https://your-storybook-url.chromatic.com/mcp` without running Storybook locally.

The **autonomous correction loop** is perhaps the most impactful feature: agents run interaction tests (play functions) and accessibility checks, see failures, and fix their own bugs before a human reviews. From the Storybook team: "No more prompt babysitting." This emerged from the research project tracked in GitHub issue #32276, which produced two RFCs — one for the agentic workflow (addon-mcp) and one for design systems with agents (Component Manifests + DS MCP Server).

---

## Why shadcn/ui is the ideal component library for AI workflows

shadcn/ui's "open code" architecture — where `npx shadcn@latest add button` copies a full `button.tsx` into your project rather than installing an npm package — creates a fundamentally different relationship between AI agents and components. **AI can read the complete implementation, modify any Tailwind class, restructure variant logic, and compose components** without hitting the opaque abstraction boundaries that plague traditional libraries like Material UI or Chakra.

CVA (class-variance-authority) amplifies this advantage. Each component's variants are defined as a declarative JavaScript object — base classes, named variant groups, compound variants, default variants — that AI can read, understand, and extend as structured data rather than parsing conditional logic. The pattern is consistent across all 60+ shadcn components, so Claude learns it once and applies it universally. Best practice: always export the `cva()` call separately from the component (`export const buttonVariants = cva(...)`) so agents and consumers can reuse or inspect variant definitions independently.

The "all shadcn sites look the same" problem has been addressed. In December 2025, shadcn introduced `npx shadcn create` with **five visual styles** — Vega (classic), Nova (compact), Maia (soft/rounded), Lyra (boxy/sharp), and Mira (dense) — that rewrite component code, not just CSS variables. For further customization, **TweakCN** (tweakcn.com) provides a visual no-code editor with theme presets, AI-powered theme generation from images or text prompts, and Tailwind v4 support. The combination of a distinctive shadcn style + the frontend-design skill + project-specific design tokens effectively eliminates generic AI output.

For AI starting points, **shadcn blocks** — pre-built compositions combining multiple components into functional sections like login forms, sidebar layouts, and dashboard scaffolds — are installable via CLI (`npx shadcn@latest add login-01`) and serve as reference patterns that AI can extend. The ecosystem includes 1,350+ third-party blocks from sources like shadcnblocks.com and Cult UI.

---

## Commands, hooks, and multi-agent orchestration

Custom slash commands (`.claude/commands/` or equivalently `.claude/skills/`) create reusable workflows for common UI tasks. The most impactful commands for jaan-to:

**`/new-component $COMPONENT_NAME`** — Scaffolds a React component with TypeScript props interface, CVA variants, Storybook story, test file, and barrel export, following patterns from existing components.

**`/design-review $FILE_PATH`** — Launches a subagent that takes screenshots via Playwright MCP, compares against project design tokens, checks accessibility with axe-core, and produces a scored review with specific improvement suggestions.

**`/qa-verify`** — Black-box testing: spawns a subagent with only browser tools (no source code access) that navigates the running app, interacts as a user would, captures screenshots of bugs, and reports findings.

**Hooks** provide deterministic enforcement where CLAUDE.md instructions are merely advisory. Configured in `.claude/settings.json`, they fire on lifecycle events and are **guaranteed to execute**:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write 2>/dev/null; exit 0"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "python3 -c \"import json, sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if 'components/ui/' in p and not p.endswith('.stories.tsx') else 0)\""
      }]
    }]
  }
}
```

This example auto-formats every file edit with Prettier and blocks direct edits to shadcn primitive components (enforcing use of the CLI instead). The hierarchy of control is: **Hooks (deterministic) > Rules (high-priority, path-scoped) > CLAUDE.md (advisory) > Skills (on-demand) > User prompts (per-session)**.

For multi-agent patterns, the **Plan → Execute → Verify** workflow is the single highest-impact practice. Use Plan Mode (Shift+Tab twice) before any task touching more than three files. Claude analyzes the codebase with read-only operations, produces a structured plan, and waits for approval. Research indicates this pattern **reduces architecture errors by 45% on multi-file tasks** and correction iterations by up to 60%. Write plans to external files (`plan.md`) for persistent working memory that survives session restarts.

Subagents should be used for isolated, parallel tasks — component generation, QA review, accessibility audits — each with their own context window. The preferred approach is the "master-clone" architecture: put all key context in CLAUDE.md and let the main agent dynamically spawn clones via `Task(...)` rather than predefining rigid specialist agents. Git worktrees (`claude --worktree feature-auth`) enable fully isolated parallel work sessions, each with their own branch and files.

---

## Visual verification closes the quality gap

Without visual verification, AI-generated code contains an estimated **1.75× more logic errors** than human-written code (ACM 2025). The screenshot → compare → fix loop using Playwright MCP transforms this equation.

The practical pattern: Claude generates a component, navigates to the Storybook story URL, takes a screenshot, compares it against the design intent (Figma reference, existing component, or verbal description), identifies discrepancies, modifies code, and repeats. Custom commands like `/review-component` can accept a component path, live URL, and reference image, then rate the visual match 0–10 with specific correction instructions.

For automated regression testing, **Chromatic** (built by the Storybook team) captures pixel-perfect snapshots of every story across Chrome, Firefox, Safari, and Edge on each build. Its anti-flake algorithm eliminates false positives from animations and minor DOM shifts. Chromatic's "Frontend Workflow for AI" guide — developed with Priceline, Spotify, Monday.com, and MongoDB — defines two loops: a **local loop** (fast feedback, agent self-healing) and a **CI loop** (comprehensive, pre-merge certainty). Percy by BrowserStack complements Chromatic for full-page, cross-device testing on real iOS and Android hardware.

Accessibility testing integrates at three levels: **Axe MCP Server** brings accessibility expertise directly into Claude Code sessions, running real browser analysis and providing AI-powered code-level fix guidance from the Deque University knowledge base. **`@storybook/addon-a11y`** runs axe-core on each story with an inline accessibility panel and color blindness emulator. **axe-playwright** in CI runs automated WCAG checks across all stories via `npx test-storybook`.

Production results validate this approach: Palo Alto Networks reported **20–30% increases in feature development speed** across 6,000 engineers, with junior developers completing integration tasks **70% faster**. NZR Gym, a solo developer project, produced 360,000 lines of production code in 40 days across 5 platforms using Claude Code as the primary development partner.

---

## Ten anti-patterns that undermine AI-driven UI development

The most destructive patterns are well-documented across community and official sources. These represent hard-won lessons from production teams:

- **Context bloat from MCP servers** — Seven servers consumed 67,300 tokens (34% of context) before any conversation. Keep MCP tool tokens under 20k. Use MCP Tool Search (v2.1.7+), consolidate tools, prefer lite server profiles, and toggle servers with McPick between sessions.

- **Overly complex slash commands** — As practitioner Shrivu Shankar notes: "If you have a long list of complex custom slash commands, you've created an anti-pattern. The entire point is to type almost whatever you want and get useful results." Put context in CLAUDE.md and let Claude orchestrate dynamically.

- **Generic AI aesthetics ("AI slop")** — Distributional convergence produces Inter font, purple gradients, rounded corners, three-box-with-icons layouts. Install the frontend-design skill, specify bold aesthetic directions in prompts, and enforce distinctive typography and color systems through design tokens.

- **Skipping plan mode** — Without planning, Claude modifies 14+ files, breaks existing endpoints, and conflicts with migration history. Always use Plan Mode for tasks touching more than three files.

- **Trusting without verifying** — AI-generated code contains significantly more logic errors than human code. Use the Playwright screenshot loop, run automated tests, and add to CLAUDE.md: "Before completing any task, describe how you would verify the work."

- **Stale code snippets in CLAUDE.md** — Inline code examples become outdated as the codebase evolves. Use `file:line` references to authoritative source code instead.

---

## The jaan-to folder convention ties everything together

The `jaan-to/` directory at the repo root serves as the single coordination point for all AI workflow configuration, shared across solo developers and teams:

```
jaan-to/
├── agent-docs/                # Progressive disclosure context
│   ├── component-patterns.md  # How we build components
│   ├── design-tokens.md       # Token-to-code mappings
│   ├── testing-strategy.md    # Testing expectations
│   └── architecture.md        # System architecture (Mermaid)
├── skills/                    # Project-specific skills
│   ├── new-component/
│   │   └── SKILL.md
│   ├── design-review/
│   │   └── SKILL.md
│   └── a11y-audit/
│       └── SKILL.md
└── commands/                  # Reusable slash commands
    ├── qa-verify.md
    └── component-scaffold.md
```

This convention works alongside `.mcp.json` (MCP server configs), `.claude/rules/` (path-scoped standards), `.claude/settings.json` (hooks), and root `CLAUDE.md` (entry point). The separation is deliberate: `.claude/` holds Claude Code–specific configuration while `jaan-to/` holds the knowledge layer that could serve any AI agent.

## Conclusion: systems over prompts

The strategic insight underpinning this entire architecture is that **the system, not the prompt, drives quality**. When design tokens align 1:1 between Figma and CSS variables, AI output becomes deterministic. When MCP servers provide live component APIs, hallucination disappears. When hooks enforce formatting automatically, style consistency becomes guaranteed rather than hoped-for. When Storybook's autonomous correction loop runs interaction tests, the agent self-heals before a human ever reviews.

The most novel finding across this research is the emerging pattern of **code execution with MCP** — where agents interact with MCP servers via code rather than direct tool calls, reducing token usage from 150,000 tokens to 2,000 in Anthropic's measurements (a 98.7% savings). This suggests the current MCP architecture, while powerful, is transitional — the future likely involves even more efficient agent-tool interaction patterns.

For teams adopting this system, the recommended sequence is: start with CLAUDE.md + shadcn MCP server (immediate accuracy gains), add Storybook MCP addon (visual feedback loop), introduce Playwright MCP (visual verification), then layer in skills and hooks as patterns stabilize. Resist the temptation to configure everything at once — context efficiency demands starting minimal and adding only what demonstrates measurable improvement. The jaan-to convention provides the scaffold; the specific contents should evolve through iteration, treated like prompt engineering: test, measure, refine.