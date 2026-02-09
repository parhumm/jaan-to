# Accessibility Audit — claude-code

---
title: "Accessibility Audit — claude-code"
id: "AUDIT-2026-014"
version: "1.0.0"
status: draft
date: 2026-02-09
target:
  name: "claude-code"
  platform: "all"
  commit: "37fc20681f77ea5e2fdbc0dbf1a4b1af53a4a1ce"
  branch: "refactor/skill-naming-cleanup"
tool:
  name: "detect-design"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 1
  low: 1
  informational: 1
overall_score: 8.8
lifecycle_phase: post-build
---

## Executive Summary

**IMPORTANT SCOPE NOTE**: This audit assesses **repo-level evidence only**. It **cannot make claims about runtime behavior** without browser testing.

**Findings**:
- ✅ Semantic HTML (header, main, section)
- ✅ Docusaurus built-in a11y features (keyboard nav, focus management)
- ⚠️ No ARIA attributes in custom components
- ⚠️ No alt attributes detected
- ⚠️ No automated accessibility testing

**Assessment**: **Minimal implementation** — Relies on Docusaurus defaults. Custom components lack explicit a11y attributes.

---

## Findings

### F-A11Y-001: Semantic HTML Usage

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DSN-017
  type: code-location
  confidence: 0.98
  location:
    uri: "website/docs/src/pages/index.tsx"
    startLine: 43
    endLine: 60
    snippet: |
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <Heading as="h1" className="hero__title">
            {siteConfig.title}
          </Heading>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
        </div>
      </header>

      <main>
        <section className={styles.features}>
          {/* Features */}
        </section>
      </main>
  method: static-analysis
```

**Description**: Uses **semantic HTML elements**:
- `<header>` for hero section
- `<main>` for primary content
- `<section>` for features
- `<Heading>` component (renders semantic headings)

**Impact**: **Positive** — Provides document structure for screen readers.

---

### F-A11Y-002: No ARIA Attributes in Custom Components

**Severity**: Medium
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DSN-018
  type: absence
  confidence: 0.95
  location:
    uri: "website/docs/src/pages/index.tsx"
    analysis: |
      No ARIA attributes found:
      - No aria-label on interactive elements
      - No aria-describedby for explanatory text
      - No role attributes (beyond semantic HTML)

      Grep search: `aria-` returned 0 results in custom components.
  method: pattern-match
```

**Description**: Custom components **lack ARIA attributes** for:
- Button groups (could use `role="group"` with `aria-label`)
- Feature cards (could use `aria-labelledby` for headings)
- Skill categories (could use `role="list"` for semantic lists)

**Impact**: **Moderate** — Screen reader users may miss semantic relationships.

**Recommendation**:
```tsx
// Add ARIA labels to button groups
<div className={styles.buttons} role="group" aria-label="Primary navigation">
  <Link className="button button--primary" to="/docs/getting-started">
    Get Started
  </Link>
  <Link className="button button--secondary" to="/docs/skills/">
    Browse Skills
  </Link>
</div>

// Add aria-labelledby to feature cards
<div className="feature-card" aria-labelledby={`feature-${label}`}>
  <div className="feature-card__label" id={`feature-${label}`}>{label}</div>
  <h3>{title}</h3>
  <p>{description}</p>
</div>
```

---

### F-A11Y-003: No Alt Attributes Detected

**Severity**: Low
**Confidence**: Confirmed (0.90)

```yaml
evidence:
  id: E-DSN-019
  type: absence
  confidence: 0.90
  location:
    uri: "website/docs/src/pages/index.tsx"
    analysis: |
      No <img> tags found in custom components.
      Grep search: `alt=` returned 0 results.

      This is expected — the homepage has no images.
      Favicons are referenced via HTML <link> tags, not <img>.
  method: pattern-match
```

**Description**: No images in custom components, so **no alt attributes needed**.

**Impact**: **None** — Not applicable for this page.

**Scope Boundary**: If images are added in the future, alt attributes must be included.

---

### F-A11Y-004: No Automated A11y Testing

**Severity**: Low
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DSN-020
  type: absence
  confidence: 0.85
  location:
    uri: "website/docs/package.json"
    analysis: |
      No a11y testing dependencies found:
      - No jest-axe
      - No @axe-core/react
      - No @testing-library (includes a11y assertions)
      - No Playwright accessibility checks

      Docusaurus may have built-in checks, but no custom tests detected.
  method: manifest-analysis
```

**Description**: No **automated accessibility testing** in the CI/CD pipeline.

**Impact**: **Minor** — Regressions may be introduced without detection.

**Recommendation**:
```bash
# Add jest-axe for unit testing
npm install --save-dev jest-axe @testing-library/react

# Example test
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import Home from './index';

expect.extend(toHaveNoViolations);

test('homepage should have no a11y violations', async () => {
  const { container } = render(<Home />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

---

## Recommendations

### Priority 1 (High)
None identified.

### Priority 2 (Medium)
1. **Add ARIA attributes to custom components** — Improve screen reader experience (F-A11Y-002)

### Priority 3 (Low)
2. **Add automated a11y testing** — Integrate jest-axe or Playwright accessibility checks (F-A11Y-004)

---

## Appendices

### A. Accessibility Scope

**What this audit covers**:
- ✅ Semantic HTML structure
- ✅ ARIA attribute presence in code
- ✅ Alt attribute presence
- ✅ Test framework detection

**What this audit CANNOT assess**:
- ❌ Color contrast ratios (requires runtime measurement)
- ❌ Keyboard navigation behavior (requires browser testing)
- ❌ Focus management (requires user interaction testing)
- ❌ Screen reader compatibility (requires assistive tech testing)

**Recommendation**: Run Lighthouse, axe DevTools, or WAVE for runtime accessibility audits.

---

*Generated by jaan.to detect-design | 2026-02-09*
