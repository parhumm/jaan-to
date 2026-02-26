# The Complete Stack: Storybook + shadcn/ui + Claude Code

## A Controllable, Editable, AI-Driven UI Development System

---

## Why This Stack Works

The core problem with AI-generated UIs: they're **generic, hard to edit, and break when you try to customize them**. This stack solves that because:

- **shadcn/ui** copies real component source files into your project (not hidden in `node_modules`) — every file is editable
- **Storybook** gives you a visual catalog to see and verify every component state
- **Claude Code** can read, write, and modify all these files with full project context
- **MCP servers** give Claude Code live access to component docs, your Storybook, and even a real browser

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR PROJECT                         │
│                                                         │
│  CLAUDE.md ← Project conventions for Claude Code        │
│  .mcp.json ← MCP server configurations                 │
│  .claude/commands/ ← Reusable prompt templates          │
│                                                         │
│  src/                                                   │
│  ├── components/                                        │
│  │   ├── ui/          ← shadcn primitives (editable!)   │
│  │   └── features/    ← your composed components        │
│  ├── stories/         ← Storybook stories               │
│  └── app/             ← pages & routes                  │
│                                                         │
│  MCP SERVERS (connected to Claude Code):                │
│  ├── shadcn MCP    → live component registry access     │
│  ├── Storybook MCP → component docs + story URLs        │
│  └── Playwright MCP → browser visual verification       │
└─────────────────────────────────────────────────────────┘
```

---

## Step 1: Project Setup

```bash
# Create Next.js project
npx create-next-app@latest my-app --typescript --tailwind --app
cd my-app

# Initialize shadcn/ui
npx shadcn@latest init

# Add core components
npx shadcn@latest add button card dialog input table tabs form

# Install Storybook 9+
npx storybook@latest init

# Install the Storybook MCP addon (requires Storybook 9.1.16+)
npx storybook add @storybook/addon-mcp
```

---

## Step 2: Install MCP Servers (The Critical Layer)

You need **3 MCP servers** for the full workflow. These are what make Claude Code "ecosystem-aware" instead of guessing.

### MCP Server 1: shadcn/ui (Official)

This gives Claude Code live access to the full shadcn component registry — real props, real code, no hallucinations.

**Setup in `.mcp.json` at your project root:**

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/claude-code-mcp", "shadcn"]
    }
  }
}
```

**Or via Claude Code CLI:**

```bash
# Official shadcn MCP (from ui.shadcn.com/docs/mcp)
claude mcp add shadcn
```

**What it gives Claude:**
- Browse all available components, blocks, and templates
- Search across registries (including private ones)
- Install components via natural language ("add a login form")
- Access real TypeScript props and implementation patterns

### MCP Server 2: Storybook Addon MCP (Official)

This lets Claude Code read your component catalog, get documentation, and generate story URLs for visual verification.

**Ensure your Storybook config enables the component manifest:**

```js
// .storybook/main.js
export default {
  // ... other config
  addons: ['@storybook/addon-mcp'],
  features: {
    experimentalComponentsManifest: true,
  },
};
```

**Connect to Claude Code:**

```bash
# Make sure Storybook is running first: npm run storybook
claude mcp add storybook-mcp --transport http http://localhost:6006/mcp --scope project
```

**What it gives Claude:**
- `list-all-components` — discover every component in your library
- `get-component-docs` — retrieve props, arg types, documentation
- Story URLs for visual review after changes
- Build instructions specific to your project

### MCP Server 3: Playwright (for Visual Verification)

This gives Claude "eyes" — it can open a browser, navigate to your Storybook, see the UI, and verify its changes visually.

```bash
claude mcp add playwright --transport stdio -- npx @playwright/mcp@latest
```

**What it gives Claude:**
- Navigate to Storybook URLs and take screenshots
- Visually verify components after making changes
- Click, fill forms, test interactions in a real browser
- Compare visual output against requirements

### Final `.mcp.json` (all three):

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/claude-code-mcp", "shadcn"]
    },
    "storybook-mcp": {
      "url": "http://localhost:6006/mcp",
      "type": "http"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

---

## Step 3: Create Your CLAUDE.md (The "Brain" File)

This is the **single most impactful thing** you can do. Claude Code reads this file automatically and follows it for every task.

Create `CLAUDE.md` in your project root:

```markdown
# Project: My App

## Tech Stack
- Next.js 15 (App Router)
- TypeScript strict mode
- Tailwind CSS v4
- shadcn/ui components

## Architecture
- `/src/app/` — pages and API routes
- `/src/components/ui/` — shadcn primitives (DO NOT modify directly unless customizing)
- `/src/components/features/` — composed feature components
- `/src/lib/` — utilities, helpers
- `/src/stories/` — Storybook stories

## MCP Servers
### shadcn UI MCP
When working with shadcn/ui components, ALWAYS use the shadcn MCP server to:
- Browse available components before building
- Install components (never run CLI commands directly)
- Check real prop types and patterns

### Storybook MCP
Before doing any UI or frontend development, ALWAYS call the Storybook MCP server
to get component documentation and existing patterns.

### Playwright MCP
After making UI changes, use Playwright to open Storybook and visually verify.

## Component Conventions
- Every feature component MUST have a `.stories.tsx` file
- Use CVA (class-variance-authority) for component variants
- Props must use explicit TypeScript interfaces (not inline types)
- Use `cn()` utility for conditional class merging
- Tailwind classes only — no CSS modules, no inline styles
- shadcn/ui components for all primitives (Button, Card, Input, Dialog, etc.)

## Story Conventions
- Use CSF3 format
- Include at least: Default, Loading, Error, and Edge Case stories
- Add argTypes with controls for interactive props
- Co-locate stories: `ComponentName.stories.tsx` next to `ComponentName.tsx`

## Commands
- Dev: `npm run dev`
- Storybook: `npm run storybook`
- Build: `npm run build`
- Lint: `npm run lint`
- Test: `npm run test`
```

---

## Step 4: Create Reusable Slash Commands

Create `.claude/commands/` directory with reusable workflows:

### `.claude/commands/new-component.md`

```markdown
Create a new feature component:

1. Use the Storybook MCP to check if a similar component already exists
2. Use the shadcn MCP to check what primitives are available
3. Create the component in `src/components/features/`
4. Use CVA for variants, explicit TypeScript interfaces for props
5. Create a Storybook story with Default, variants, and edge cases
6. Use Playwright MCP to open the new story and verify it renders correctly
7. Report the Storybook URL for review

Component name: $ARGUMENTS
```

### `.claude/commands/fix-ui.md`

```markdown
Fix a UI issue in a component:

1. Use Playwright MCP to open the current component in Storybook
2. Take a screenshot to understand the current state
3. Read the component source code
4. Make the fix
5. Use Playwright to take a new screenshot and verify
6. Update the story if needed

Target: $ARGUMENTS
```

### `.claude/commands/design-review.md`

```markdown
Review UI quality for a component:

1. Use Storybook MCP to get component documentation
2. Use Playwright to open the component in Storybook
3. Take screenshots of all story variants
4. Analyze for: visual consistency, spacing, typography, accessibility
5. Suggest improvements with specific code changes
6. Implement fixes if approved

Component: $ARGUMENTS
```

---

## Step 5: The Daily Workflow

### Creating a new component

```bash
# In Claude Code:
/project:new-component UserProfileCard

# Or in plain language:
"Create a UserProfileCard component with avatar, name, role, and a 
'compact' variant. Use shadcn Card and Avatar. Make it look great."
```

Claude Code will:
1. Query the shadcn MCP for available primitives (Card, Avatar, Badge)
2. Check Storybook MCP for existing similar components
3. Create the component with CVA variants
4. Create the Storybook story
5. Open Playwright to verify it renders

### Editing / fixing UI

```bash
"The spacing between the avatar and name in UserProfileCard is too tight. 
Fix it and add a subtle border to the compact variant."
```

Claude Code will:
1. Read the component file
2. Make changes
3. Open Storybook via Playwright to verify visually
4. Report back with a screenshot or story URL

### Building from a design / screenshot

```bash
"Here's a screenshot of what I want. Build this as a PricingSection 
component using shadcn Card, Badge, and Button. Make 3 tiers: Basic, Pro, 
Enterprise. The Pro tier should be highlighted."
```

---

## Step 6: Optional Extras for Even Better Results

### Figma MCP (if you use Figma)
Allows Claude to read your Figma designs directly:
```bash
# Requires Figma Dev Mode MCP Server
claude mcp add figma -- npx @anthropic-ai/claude-code-mcp figma
```

### TweakCN (for unique theming)
Avoid "all shadcn sites look the same" — customize the theme:
- Visit https://tweakcn.com to generate a custom shadcn theme
- Copy the CSS variables into your `globals.css`
- Add to CLAUDE.md: "Use our custom theme variables, never override them"

### Custom Claude Code Rules (`.claude/rules/`)
For domain-specific patterns:

```
.claude/rules/
├── forms.md       # "Always use react-hook-form + zod with shadcn Form"
├── layouts.md     # "Use CSS Grid for page layouts, Flex for component internals"
├── animations.md  # "Use framer-motion for page transitions, CSS for micro-interactions"
```

---

## Why This Approach Makes Output Controllable & Editable

| Problem | How This Stack Solves It |
|---|---|
| AI generates wrong props | shadcn MCP gives real-time access to actual component APIs |
| Can't see what AI built | Storybook stories + Playwright screenshots = visual verification |
| Output is generic / ugly | CLAUDE.md conventions + frontend-design skill + TweakCN theming |
| Hard to edit AI output | shadcn components are plain files in your repo — edit anything |
| AI forgets your patterns | CLAUDE.md + .claude/rules/ persist across sessions |
| No visual feedback loop | Playwright MCP lets Claude "see" the browser and self-correct |

---

## Quick Reference: All Commands

```bash
# Setup
npx create-next-app@latest my-app --typescript --tailwind --app
npx shadcn@latest init
npx storybook@latest init
npx storybook add @storybook/addon-mcp

# MCP Servers
claude mcp add shadcn                                                          # shadcn registry
claude mcp add storybook-mcp --transport http http://localhost:6006/mcp --scope project  # Storybook
claude mcp add playwright --transport stdio -- npx @playwright/mcp@latest      # Browser

# Verify MCPs are connected
/mcp

# Daily use
npm run storybook              # Start Storybook (port 6006)
claude                         # Start Claude Code
/project:new-component MyThing # Use custom commands
```

---

## Summary

The final approach is a **4-layer system**:

1. **shadcn/ui** — editable component source files in your repo
2. **Storybook 9 + addon-mcp** — visual component catalog with MCP integration
3. **Claude Code + CLAUDE.md** — AI that understands your project conventions
4. **3 MCP servers** (shadcn + Storybook + Playwright) — real-time component registry, documentation, and visual verification

This gives you UI output that is **accurate** (real component data, not hallucinated), **controllable** (conventions in CLAUDE.md), **visually verifiable** (Playwright + Storybook), and **easy to edit** (every component is a plain file you own).
