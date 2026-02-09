---
title: "detect-ux"
sidebar_position: 5
doc_type: skill
tags: [detect, ux, journeys, heuristics, accessibility, pain-points]
related: [detect-dev, detect-design, detect-writing, detect-product, detect-pack]
updated_date: 2026-02-09
---

# /jaan-to:detect-ux

> Repo-driven UX audit with journey mapping and heuristic-based findings.

---

## What It Does

Performs a UX audit by mapping journeys from actual routes, screens, and state components. Supports **light mode** (default, 1 summary file with screen inventory and flows) and **full mode** (`--full`, 7 detailed files with persona inference, heuristics, and accessibility).

---

## Usage

```
/jaan-to:detect-ux [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (7 detection steps, 7 output files). Default is light mode. |

**Light mode** (default): Maps routes/screens and user flows, produces 1 summary file with screen inventory and key flows as Mermaid diagrams.

**Full mode** (`--full`): Runs all steps including persona inference, JTBD, pain points, Nielsen heuristics, and accessibility audit. Produces 7 detailed output files.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/ux/summary{suffix}.md` | Screen inventory, key user flows (Mermaid), top-5 findings |

### Full Mode (`--full`) — 7 files
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/ux/personas.md` | Inferred personas from route/auth analysis |
| `$JAAN_OUTPUTS_DIR/detect/ux/jtbd.md` | Jobs-to-be-done statements linked to features |
| `$JAAN_OUTPUTS_DIR/detect/ux/flows.md` | User flows with Mermaid diagrams |
| `$JAAN_OUTPUTS_DIR/detect/ux/pain-points.md` | UX friction signals and dead ends |
| `$JAAN_OUTPUTS_DIR/detect/ux/heuristics.md` | Nielsen 10 heuristics assessment table |
| `$JAAN_OUTPUTS_DIR/detect/ux/accessibility.md` | A11y findings (scoped to repo evidence) |
| `$JAAN_OUTPUTS_DIR/detect/ux/gaps.md` | UX gaps and improvement recommendations |

### Multi-Platform Monorepo
Files use platform suffix: `personas-{platform}.md`, `summary-{platform}.md`, etc.

---

## What It Scans

| Category | Patterns |
|----------|---------|
| React Router | `useRoutes()`, `<Route`, `<Outlet`, `createBrowserRouter` |
| Next.js | `app/**/page.{tsx,jsx}`, `pages/**/*.{tsx,jsx}`, dynamic `[slug]`, route groups `(group)/`, layouts |
| Vue Router | `routes` array definitions, `<RouterView`, `**/router/**/*.{ts,js}` |
| Angular | `**/*routing.module.ts`, `**/*-routes.ts`, `canActivate` guards |
| Express / API | `app.get(`, `router.post(`, NestJS `@Get(`, `@Post(` decorators |
| Navigation | `<Link`, `<NavLink`, `useNavigate`, `router.push` |
| Pain points | `<ErrorBoundary`, `isLoading`, `<Skeleton`, form complexity, dead-end detection |
| Accessibility | ARIA attributes, semantic HTML, keyboard navigation, skip links, a11y testing tools |

---

## Multi-Platform Support

- **Platform auto-detection**: Detects web/, backend/, mobile/, etc. from folder structure
- **Evidence ID format**:
  - Single-platform: `E-UX-NNN` (e.g., `E-UX-001`)
  - Multi-platform: `E-UX-{PLATFORM}-NNN` (e.g., `E-UX-WEB-001`, `E-UX-MOBILE-023`)
- **"Detect and Report N/A" pattern**: For non-UI platforms (backend, CLI), produces minimal output with informational finding ("No User-Facing UI Detected")
- **Skip criteria**: Platforms without routes/screens automatically get N/A treatment with perfect score (10.0)
- **Platform-specific journeys**: Mobile vs web navigation patterns differ (tabs vs sidebar, gestures vs clicks)

---

## Key Points

- **Framework-specific route extraction** across React Router, Next.js, Vue Router, Angular, and Express
- **Nielsen's 10 heuristics** assessed from code signals: Visibility, Match, User control, Consistency, Error prevention, Recognition, Flexibility, Minimalist design, Error recovery, Help — each rated Strong/Adequate/Weak/Unknown
- Personas and JTBD are always marked **Tentative** (inferred from code, not validated user research)
- Multi-step flows rendered as **Mermaid** flow diagrams
- Missing code evidence does NOT equal a violation — marked "Unknown" when evidence is insufficient
- Accessibility findings scoped to repo evidence only — runtime behavior = Unknown
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](docs/skills/detect/README.md) | [Back to All Skills](../README.md)
