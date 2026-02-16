# frontend-task-breakdown — Reference Material

> Extracted from `skills/frontend-task-breakdown/SKILL.md` for token optimization.
> Contains component taxonomy, coverage checklists, and validation criteria.

---

## Atomic Design Taxonomy

| Level | Examples | Estimate Band | Typical Tasks |
|-------|----------|---------------|---------------|
| **Atoms** | Button, Input, Icon, Badge, Label, Avatar | XS (< 1h) | Create + variants + tests |
| **Molecules** | Search form, Form field, Card, Nav item, Tooltip | S (1-2h) | Compose atoms + state handling |
| **Organisms** | Header, Product grid, Footer, Modal, Sidebar, Form | M (2-4h) | Complex composition + data + a11y |
| **Templates** | Page layouts, Dashboard shells, Auth layout | L (4-8h) | Layout + responsive + routing |
| **Pages** | Specific page instances with data integration | XL (1-2d) | Full integration + all states |

---

## Coverage Checklist

Apply the coverage checklist based on scope selected in Step 2.

**Accessibility (10 items):**
- [ ] Skip navigation links
- [ ] Focus management after dialogs/modals close
- [ ] Visible focus indicators (not just outline: none)
- [ ] Keyboard trap prevention
- [ ] ARIA landmarks (nav, main, aside, footer)
- [ ] Screen reader text alternatives for images/icons
- [ ] Heading hierarchy (h1 > h2 > h3, no skipping)
- [ ] Form labels and error announcements
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] Reduced motion support (`prefers-reduced-motion`)

**Responsive (7 items):**
- [ ] Mobile breakpoint (320-480px)
- [ ] Tablet breakpoint (768px)
- [ ] Desktop breakpoint (1024px+)
- [ ] Touch targets minimum 44x44px
- [ ] No horizontal scroll at any breakpoint
- [ ] Content reflow at 200% zoom
- [ ] Responsive images with srcset

**Interaction states (8 items):**
- [ ] Hover states
- [ ] Active/pressed states
- [ ] Disabled states
- [ ] Loading states (per component)
- [ ] Error states (per component)
- [ ] Success/confirmation states
- [ ] Empty states
- [ ] Skeleton/partial loading states

**Performance (7 items):**
- [ ] Code splitting (route-level at minimum)
- [ ] Image optimization (WebP/AVIF, lazy loading)
- [ ] Font loading strategy (next/font or font-display: swap)
- [ ] Critical CSS / above-fold optimization
- [ ] Bundle size budget
- [ ] Core Web Vitals targets (LCP ≤2.5s, INP ≤200ms, CLS ≤0.1)
- [ ] Third-party script management

**SEO (7 items)** — if applicable:
- [ ] Meta tags (title, description)
- [ ] Open Graph tags
- [ ] Semantic HTML
- [ ] Canonical URLs
- [ ] Structured data (JSON-LD)
- [ ] Robots.txt consideration
- [ ] Sitemap inclusion

**Infrastructure (7 items):**
- [ ] Environment variables for API URLs
- [ ] Feature flags (if gradual rollout)
- [ ] Error monitoring integration (Sentry/Rollbar)
- [ ] Analytics events
- [ ] CSP headers consideration
- [ ] CORS configuration
- [ ] CI/CD pipeline updates

**Testing (7 items):**
- [ ] Unit tests for utility functions
- [ ] Integration tests for component interactions
- [ ] E2E tests for critical user flows
- [ ] Visual regression tests (Chromatic/Percy)
- [ ] Accessibility automated tests (axe-core)
- [ ] Cross-browser testing plan
- [ ] Storybook stories for component documentation

For each item, mark: **Included** / **Not applicable** / **Deferred**

Count coverage:
```
COVERAGE SUMMARY
────────────────
Included:       {n} tasks
Not applicable: {n} items
Deferred:       {n} items (list reasons)
```

---

## Definition of Ready

- [ ] Visual designs for all screens provided
- [ ] All interaction states designed (or documented as TBD)
- [ ] Responsive designs for required breakpoints
- [ ] API contracts defined (or mock strategy agreed)
- [ ] Blocking dependencies resolved
- [ ] Acceptance criteria specific and testable

## Definition of Done

- [ ] All component states implemented
- [ ] Accessibility audit passed (WCAG AA)
- [ ] Performance budget met (Lighthouse ≥90)
- [ ] Tests passing (unit + integration)
- [ ] Cross-browser tested (Chrome, Safari, Firefox)
- [ ] Responsive verified (375px, 768px, 1440px)
- [ ] No console errors or warnings
- [ ] Storybook stories created for shared components
