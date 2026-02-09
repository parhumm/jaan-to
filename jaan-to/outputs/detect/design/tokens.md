# Design Tokens Audit — claude-code

---
title: "Design Tokens Audit — claude-code"
id: "AUDIT-2026-011"
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
  informational: 3
overall_score: 8.9
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** docs site uses **Docusaurus CSS custom properties** (`--ifm-*` namespace) with custom overrides:

**Token Categories**:
- Colors: 13 tokens (primary variants, backgrounds)
- Typography: 4 tokens (font families, weights)
- Spacing: 3 tokens (border-radius, code font size)

**Drift Detected**: 6 hardcoded color values bypass the token system.

**Assessment**: **Good** — Leverages Docusaurus tokens effectively, but inconsistent use of hardcoded values introduces drift.

---

## Findings

### F-TOKEN-001: Color Tokens — 13 Defined

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-006
  type: token-definition
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 3
    endLine: 19
    snippet: |
      :root {
        --ifm-color-primary: #dd2e44;
        --ifm-color-primary-dark: #b52538;
        --ifm-color-primary-darker: #a02232;
        --ifm-color-primary-darkest: #841c29;
        --ifm-color-primary-light: #e24d60;
        --ifm-color-primary-lighter: #e6636e;
        --ifm-color-primary-lightest: #ed8a92;
        --ifm-background-color: #fafaf8;
        --ifm-background-surface-color: #f5f5f3;
      }
  method: pattern-match
```

**Description**: 13 color tokens defined, including primary variants and background colors.

---

### F-TOKEN-002: Hardcoded Color Drift

**Severity**: Medium
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  - id: E-DSN-007a
    type: token-definition
    confidence: 1.00
    location:
      uri: "website/docs/src/css/custom.css"
      startLine: 18
      endLine: 19
      snippet: |
        --ifm-background-color: #fafaf8;
        --ifm-background-surface-color: #f5f5f3;
  - id: E-DSN-007b
    type: conflicting-usage
    confidence: 0.95
    location:
      uri: "website/docs/src/css/custom.css"
      startLine: 97
      endLine: 98
      snippet: |
        .hero__subtitle {
          color: #6b6b6b;  /* Hardcoded, no token */
        }
  - id: E-DSN-007c
    type: conflicting-usage
    confidence: 0.95
    location:
      uri: "website/docs/src/css/custom.css"
      startLine: 108
      endLine: 111
      snippet: |
        .button--primary {
          background: #111111;  /* Hardcoded black */
          border-color: #111111;
        }
  - id: E-DSN-007d
    type: conflicting-usage
    confidence: 0.95
    location:
      uri: "website/docs/src/css/custom.css"
      startLine: 159
      endLine: 161
      snippet: |
        .feature-card p {
          color: #6b6b6b;  /* Hardcoded gray, duplicates E-DSN-007b */
        }
```

**Description**: **6 hardcoded color values** found that bypass the token system:
- `#111111` (black) — used in buttons, footer, code blocks
- `#6b6b6b` (gray) — used in subtitles and feature cards
- `#a0a0a0` (light gray) — dark mode text
- `#d2d2d7` (border gray) — secondary button borders

**Impact**: **Moderate** — Creates maintenance burden. Changing brand colors requires updating multiple files.

**Remediation**:
```css
/* Define semantic tokens */
:root {
  --jaan-color-text-muted: #6b6b6b;
  --jaan-color-background-inverse: #111111;
  --jaan-color-border-subtle: #d2d2d7;
}

[data-theme='dark'] {
  --jaan-color-text-muted: #a0a0a0;
}

/* Use tokens */
.hero__subtitle {
  color: var(--jaan-color-text-muted);
}

.button--primary {
  background: var(--jaan-color-background-inverse);
}
```

---

### F-TOKEN-003: Typography Tokens

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-008
  type: token-definition
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 12
    endLine: 16
    snippet: |
      --ifm-font-family-base: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
        Helvetica, Arial, sans-serif;
      --ifm-font-family-monospace: 'SF Mono', 'Cascadia Code', 'Fira Code', Monaco,
        Consolas, monospace;
      --ifm-heading-font-family: 'Fraunces', Georgia, 'Times New Roman', serif;
  method: pattern-match
```

**Description**: 3 font family tokens + weight tokens (500, 600) defined.

---

### F-TOKEN-004: Inconsistent Border-Radius Values

**Severity**: Low
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DSN-009
  type: pattern-match
  confidence: 0.85
  location:
    uri: "website/docs/src/css/custom.css"
    analysis: |
      Border-radius values:
      - 5px: search input, --ifm-border-radius token
      - 12px: code blocks (.prism-code)
      - 16px: feature cards (.feature-card)

      No unified spacing scale.
  method: pattern-match
```

**Description**: **3 different border-radius values** without a unified scale. Should use a spacing token scale (e.g., 4px, 8px, 12px, 16px).

**Impact**: **Minor** — Creates visual inconsistency.

**Remediation**:
```css
:root {
  --jaan-radius-sm: 5px;
  --jaan-radius-md: 12px;
  --jaan-radius-lg: 16px;
}
```

---

### F-TOKEN-005: Spacing Tokens — Limited

**Severity**: Informational
**Confidence**: Tentative (0.70)

```yaml
evidence:
  id: E-DSN-010
  type: absence
  confidence: 0.70
  location:
    uri: "website/docs/src/css/custom.css"
    analysis: |
      Spacing values hardcoded:
      - padding: 4rem, 2rem, 32px
      - gap: 12px
      - margin-bottom: 8px, 12px, 2rem

      No spacing scale tokens defined.
  method: pattern-match
```

**Description**: No **spacing scale tokens**. All padding/margin values are hardcoded.

**Impact**: **Minor** — Acceptable for small sites, but scaling requires refactoring.

**Recommendation**: Define spacing scale if site grows:
```css
:root {
  --jaan-space-1: 0.25rem;  /* 4px */
  --jaan-space-2: 0.5rem;   /* 8px */
  --jaan-space-3: 0.75rem;  /* 12px */
  --jaan-space-4: 1rem;     /* 16px */
  --jaan-space-6: 1.5rem;   /* 24px */
  --jaan-space-8: 2rem;     /* 32px */
}
```

---

## Recommendations

### Priority 1 (High)
None identified.

### Priority 2 (Medium)
1. **Replace hardcoded colors with tokens** — Define semantic color tokens for muted text, inverse backgrounds (F-TOKEN-002)

### Priority 3 (Low)
2. **Unify border-radius values** — Define radius scale tokens (F-TOKEN-004)
3. **Add spacing scale** — If site complexity grows (F-TOKEN-005)

---

*Generated by jaan.to detect-design | 2026-02-09*
