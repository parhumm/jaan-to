# UI Patterns Audit — claude-code

---
title: "UI Patterns Audit — claude-code"
id: "AUDIT-2026-013"
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
  medium: 0
  low: 0
  informational: 4
overall_score: 10.0
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** docs site implements **4 key UI patterns**:

1. **Feature Cards** — Content cards with label + heading + description
2. **Button Styles** — Primary (black) and secondary (outlined) variants
3. **Dark Mode** — `[data-theme='dark']` CSS selector pattern
4. **Responsive Layout** — Docusaurus grid with breakpoints

**Assessment**: **Strong** — Consistent patterns with good dark mode support.

---

## Findings

### F-PATTERN-001: Feature Card Pattern

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DSN-013
  type: code-location
  confidence: 0.98
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 133
    endLine: 167
    snippet: |
      .feature-card {
        background: #fafaf8;
        border-radius: 16px;
        padding: 32px;
      }

      [data-theme='dark'] .feature-card {
        background: #1a1a1a;
      }

      .feature-card__label {
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: var(--ifm-color-primary);
      }
  method: pattern-match
```

**Description**: **Feature cards** use a consistent pattern:
- Light background with border-radius
- Label (uppercase, primary color)
- Heading (Fraunces serif)
- Description (gray text)
- Dark mode adaptation

**Impact**: **Positive** — Reusable pattern for highlighting features.

---

### F-PATTERN-002: Button Variants — Primary & Secondary

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-014
  type: code-location
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 108
    endLine: 130
    snippet: |
      .button--primary {
        background: #111111;
        border-color: #111111;
        color: white;
      }

      .button--primary:hover {
        background: #2a2a2a;
        transform: translateY(-1px);
      }

      .button--secondary {
        background: transparent;
        border: 1.5px solid #d2d2d7;
        color: var(--ifm-font-color-base);
      }

      .button--secondary:hover {
        border-color: var(--ifm-font-color-base);
        transform: translateY(-1px);
      }
  method: pattern-match
```

**Description**: **Two button variants**:
- **Primary**: Black background, white text, hover lift effect
- **Secondary**: Transparent with border, hover darkens border

Both use `translateY(-1px)` hover effect for tactile feedback.

**Impact**: **Positive** — Clear visual hierarchy between primary and secondary actions.

---

### F-PATTERN-003: Dark Mode Implementation

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-015
  type: pattern-match
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 28
    endLine: 39
    snippet: |
      [data-theme='dark'] {
        --ifm-color-primary: #e24d60;
        --ifm-background-color: #111111;
        --ifm-background-surface-color: #1a1a1a;
      }

      [data-theme='dark'] .navbar {
        border-bottom-color: #222;
      }

      [data-theme='dark'] .prism-code {
        background: #111111 !important;
      }
  method: pattern-match
```

**Description**: Dark mode uses **`[data-theme='dark']` selector** (Docusaurus convention) to:
- Override CSS custom properties
- Adjust component-specific styles (navbar, code blocks, cards)
- Use true black backgrounds (`#111111`, `#1a1a1a`)

**Impact**: **Positive** — Proper dark mode implementation with scoped overrides.

---

### F-PATTERN-004: Responsive Layout Grid

**Severity**: Informational
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DSN-016
  type: code-location
  confidence: 0.95
  location:
    uri: "website/docs/src/pages/index.tsx"
    startLine: 67
    endLine: 76
    snippet: |
      <div className="row">
        {features.map(({label, title, description}) => (
          <div key={label} className={clsx('col col--4')}>
            <div className="feature-card">
              {/* ... */}
            </div>
          </div>
        ))}
      </div>
  method: static-analysis
```

**Description**: Uses **Docusaurus grid system** (`.row` + `.col-*` classes):
- 3-column layout (`col--4` = 4/12 columns)
- Responsive breakpoints (collapses on mobile)
- Gap spacing via Docusaurus defaults

**Impact**: **Positive** — Responsive layout without custom CSS.

---

## Recommendations

None. UI patterns are well-implemented.

---

*Generated by jaan.to detect-design | 2026-02-09*
