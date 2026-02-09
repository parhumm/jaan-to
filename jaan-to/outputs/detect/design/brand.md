# Brand Identity Audit — claude-code

---
title: "Brand Identity Audit — claude-code"
id: "AUDIT-2026-010"
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
  low: 1
  informational: 4
overall_score: 9.8
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** documentation site has a **lightweight brand identity** with consistent color and typography:

**Brand Colors**:
- Primary: `#dd2e44` (red) with 6 tonal variants
- Dark mode adaptation

**Typography**:
- Headings: Fraunces serif (distinctive, humanist)
- Body: System font stack (performance-optimized)
- Monospace: SF Mono, Cascadia Code, Fira Code

**Brand Assets**:
- 3 favicon sizes
- No logo SVG detected

**Assessment**: **Strong** — Clear brand identity with distinctive typography. Lacks logo assets but appropriate for documentation site.

---

## Scope and Methodology

**Analysis Methods**:
- CSS custom property extraction
- Font file scanning
- Brand asset inventory

---

## Findings

### F-BRAND-001: Primary Brand Color — #dd2e44 (Red)

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-001
  type: token-definition
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 3
    endLine: 10
    snippet: |
      :root {
        --ifm-color-primary: #dd2e44;
        --ifm-color-primary-dark: #b52538;
        --ifm-color-primary-darker: #a02232;
        --ifm-color-primary-darkest: #841c29;
        --ifm-color-primary-light: #e24d60;
        --ifm-color-primary-lighter: #e6636e;
        --ifm-color-primary-lightest: #ed8a92;
      }
  method: pattern-match
```

**Description**: The brand uses **#dd2e44** (warm red) as the primary color with 6 tonal variants (3 darker, 3 lighter). This creates a complete color scale for UI elements.

**Impact**: **Positive** — Distinctive brand color with proper tonal variations for different UI states.

---

### F-BRAND-002: Dark Mode Brand Adaptation

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-002
  type: token-definition
  confidence: 1.00
  location:
    uri: "website/docs/src/css/custom.css"
    startLine: 28
    endLine: 39
    snippet: |
      [data-theme='dark'] {
        --ifm-color-primary: #e24d60;
        --ifm-color-primary-dark: #dd2e44;
        --ifm-color-primary-darker: #b52538;
        --ifm-color-primary-darkest: #841c29;
        --ifm-color-primary-light: #e6636e;
        --ifm-color-primary-lighter: #ed8a92;
        --ifm-color-primary-lightest: #f5b8bf;
        --ifm-background-color: #111111;
        --ifm-background-surface-color: #1a1a1a;
      }
  method: pattern-match
```

**Description**: Dark mode shifts the primary color to **#e24d60** (lighter red) for better contrast against dark backgrounds. Background colors use true black (`#111111`, `#1a1a1a`).

**Impact**: **Positive** — Proper dark mode adaptation ensures readability.

---

### F-BRAND-003: Typography Hierarchy — Fraunces Serif

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-003
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

**Description**: The brand uses **Fraunces** serif for headings, which is:
- Distinctive (humanist serif with soft features)
- Contrasts with system sans-serif body text
- Falls back to Georgia/Times New Roman if unavailable

**Impact**: **Positive** — Distinctive typography creates brand personality while maintaining readability.

---

### F-BRAND-004: Favicon Assets Detected

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DSN-004
  type: code-location
  confidence: 1.00
  location:
    uri: "website/docs/static/img/"
    analysis: |
      Brand assets found:
      - favicon-16x16.png
      - favicon-32x32.png
      - apple-touch-icon.png

      Missing:
      - favicon.svg (modern vector format)
      - Logo files (logo.svg, logo.png)
  method: glob-pattern
```

**Description**: The site includes **3 favicon sizes** but lacks:
- Vector favicon (SVG format for modern browsers)
- Standalone logo assets for documentation

**Impact**: **Neutral** — Adequate for documentation site, but logo assets would improve brand consistency across docs.

**Recommendation**: Add `favicon.svg` for modern browsers and `logo.svg` for use in documentation headers/footers.

---

### F-BRAND-005: No Web Font Loading Detected

**Severity**: Low
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DSN-005
  type: absence
  confidence: 0.85
  location:
    uri: "website/docs/"
    analysis: |
      Fraunces serif is referenced but no font files detected:
      - No .woff2 files in static/fonts/
      - No @font-face declarations
      - No <link rel="preload"> for fonts

      Likely relies on system fallback (Georgia, Times New Roman).
  method: glob-pattern
```

**Description**: The **Fraunces** font is declared but not loaded via web fonts. This means:
- Users without Fraunces installed see Georgia/Times New Roman
- Inconsistent brand presentation across devices

**Impact**: **Minor** — Fallback fonts are reasonable, but brand consistency suffers.

**Recommendation**: Add Fraunces web font via Google Fonts or self-hosted:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Fraunces:wght@400;500;600&display=swap">
```

---

## Recommendations

### Priority 1 (High)
None identified.

### Priority 2 (Medium)
None identified.

### Priority 3 (Low)
1. **Add Fraunces web font** — Self-host or use Google Fonts for consistent typography (F-BRAND-005)
2. **Add vector favicon** — Create `favicon.svg` for modern browsers (F-BRAND-004)
3. **Add logo assets** — Create `logo.svg` for documentation headers (F-BRAND-004)

---

## Appendices

### A. Brand Color Palette

| Shade | Hex | Usage |
|-------|-----|-------|
| Primary Darkest | `#841c29` | Pressed states |
| Primary Darker | `#a02232` | Hover states |
| Primary Dark | `#b52538` | Active states |
| **Primary** | **#dd2e44** | **Default** |
| Primary Light | `#e24d60` | Highlights |
| Primary Lighter | `#e6636e` | Backgrounds |
| Primary Lightest | `#ed8a92` | Tints |

### B. Typography Stack

| Element | Family | Fallback |
|---------|--------|----------|
| **Headings** | Fraunces | Georgia, Times New Roman, serif |
| **Body** | System | -apple-system, Roboto, Arial, sans-serif |
| **Code** | SF Mono | Cascadia Code, Fira Code, Monaco, monospace |

---

*Generated by jaan.to detect-design | 2026-02-09*
