# Design System

> Project: {project-name}
> Last updated: {date}

**TIP**: Run `/jaan-to:detect-design` to audit your design system with evidence-backed findings, or `/jaan-to:detect-pack` for a full repo analysis.

---

## Component Library {#component-library}

| Setting | Value |
|---------|-------|
| Library | {shadcn/ui, Radix, MUI, Ant Design, custom} |
| Source Path | {src/components/ui/} |
| Registry | {default, custom URL} |
| Style System | {CVA + Tailwind, CSS Modules, styled-components} |
| Icon Library | {lucide, heroicons, phosphor} |

---

## Design Tokens {#tokens}

### Colors
- **Primary**: {color value}
- **Secondary**: {color value}
- **Accent**: {color value}
- **Destructive**: {color value}
- **Muted**: {color value}

### Typography
- **Font Family**: {Inter, system-ui, custom}
- **Base Size**: {16px}
- **Scale**: {1.25 major third}

### Spacing
- **Unit**: {4px, 0.25rem}
- **Scale**: {4, 8, 12, 16, 24, 32, 48, 64}

### Radius
- **Default**: {0.5rem}
- **Card**: {0.75rem}
- **Button**: {0.5rem}

---

## Storybook {#storybook}

| Setting | Value |
|---------|-------|
| Installed | {yes/no} |
| Version | {9.x, 8.x} |
| Config Path | {.storybook/} |
| Stories Pattern | {../src/**/*.stories.@(js\|jsx\|mjs\|ts\|tsx)} |
| Story Format | {CSF3} |
| Dev URL | {http://localhost:6006} |
| Addons | {docs, a11y, interactions, mcp} |
| RSC Support | {yes/no} |

---

## Component Conventions {#conventions}

### File Structure
```
{src/components/}
  ui/              # Base components (from library)
  shared/          # Shared composite components
  features/        # Feature-specific components
  layouts/         # Layout components
```

### Naming
- **Components**: {PascalCase}
- **Files**: {kebab-case.tsx, PascalCase.tsx}
- **Stories**: {ComponentName.stories.tsx}
- **Tests**: {ComponentName.test.tsx}

### Variant System
- **Approach**: {CVA (class-variance-authority), manual props, compound variants}
- **Default Variants**: {outline, filled, ghost}
- **Size Scale**: {sm, default, lg}

---

## MCP Servers {#mcp}

> Optional MCP servers that enhance frontend skills. Skills work without them.

### shadcn MCP
- **Command**: `npx shadcn@latest mcp`
- **Purpose**: Browse and install components from registries via natural language
- **Configured**: {yes/no}

### Storybook MCP
- **Addon**: `@anthropic-ai/storybook-mcp`
- **Purpose**: Component documentation, story URLs, build instructions
- **Configured**: {yes/no}

### Playwright MCP
- **Command**: `npx @playwright/mcp@latest`
- **Purpose**: Visual verification via accessibility snapshots and screenshots
- **Network**: localhost-only by default
- **Configured**: {yes/no}

---

## Visual Standards {#visual-standards}

### Responsive Breakpoints
| Name | Width |
|------|-------|
| sm | {640px} |
| md | {768px} |
| lg | {1024px} |
| xl | {1280px} |

### Accessibility
- **Target**: {WCAG 2.1 AA}
- **Color Contrast**: {4.5:1 minimum}
- **Focus Indicators**: {visible ring}
- **Screen Reader**: {aria-labels on interactive elements}

### Animation
- **Approach**: {Framer Motion, CSS transitions, none}
- **Duration**: {150ms default, 300ms enter, 200ms exit}
- **Reduce Motion**: {respects prefers-reduced-motion}

---

**Delete this section after customizing:**

This file is read by:
- `/jaan-to:frontend-design` - Generates components matching design system
- `/jaan-to:frontend-scaffold` - Scaffolds component structure with stories
- `/jaan-to:frontend-story-generate` - Generates CSF3 stories with correct conventions
- `/jaan-to:frontend-visual-verify` - Verifies visual output against standards
- `/jaan-to:frontend-component-fix` - Fixes UI bugs within design constraints
- `/jaan-to:detect-design` - Audits design system consistency

Edit sections above to match your project. Use `#section-id` anchors for imports.
