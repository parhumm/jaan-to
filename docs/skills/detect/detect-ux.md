---
title: "detect-ux"
sidebar_position: 5
doc_type: skill
tags: [detect, ux, journeys, heuristics, accessibility, pain-points]
related: [detect-dev, detect-design, detect-writing, detect-product, detect-pack]
updated_date: 2026-02-08
---

# /jaan-to:detect-ux

> Repo-driven UX audit with journey mapping and heuristic-based findings.

---

## What It Does

Performs a UX audit by mapping journeys from actual routes, screens, and state components using framework-specific route extraction. Infers personas and JTBD from code structure, maps user flows with Mermaid diagrams, detects UX pain points, evaluates Nielsen's 10 usability heuristics from code signals, and assesses repo-level accessibility.

---

## Usage

```
/jaan-to:detect-ux
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/ux/personas.md` | Inferred personas from route/auth analysis |
| `$JAAN_OUTPUTS_DIR/detect/ux/jtbd.md` | Jobs-to-be-done statements linked to features |
| `$JAAN_OUTPUTS_DIR/detect/ux/flows.md` | User flows with Mermaid diagrams |
| `$JAAN_OUTPUTS_DIR/detect/ux/pain-points.md` | UX friction signals and dead ends |
| `$JAAN_OUTPUTS_DIR/detect/ux/heuristics.md` | Nielsen 10 heuristics assessment table |
| `$JAAN_OUTPUTS_DIR/detect/ux/accessibility.md` | A11y findings (scoped to repo evidence) |
| `$JAAN_OUTPUTS_DIR/detect/ux/gaps.md` | UX gaps and improvement recommendations |

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

## Key Points

- Evidence IDs use namespace `E-UX-NNN` (prevents collisions in detect-pack aggregation)
- **Framework-specific route extraction** across React Router, Next.js, Vue Router, Angular, and Express
- **Nielsen's 10 heuristics** assessed from code signals: Visibility, Match, User control, Consistency, Error prevention, Recognition, Flexibility, Minimalist design, Error recovery, Help — each rated Strong/Adequate/Weak/Unknown
- Personas and JTBD are always marked **Tentative** (inferred from code, not validated user research)
- Multi-step flows rendered as **Mermaid** flow diagrams
- Missing code evidence does NOT equal a violation — marked "Unknown" when evidence is insufficient
- Accessibility findings scoped to repo evidence only — runtime behavior = Unknown
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
