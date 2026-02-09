---
title: "detect-product"
sidebar_position: 4
doc_type: skill
tags: [detect, product, features, monetization, instrumentation]
related: [detect-dev, detect-design, detect-writing, detect-ux, detect-pack]
updated_date: 2026-02-09
---

# /jaan-to:detect-product

> Product reality extraction with evidence-backed features, monetization, and metrics.

---

## What It Does

Extracts the "product reality" from the repository with evidence-backed detection. Supports **light mode** (default, 1 summary file with Tentative-confidence features) and **full mode** (`--full`, 7 detailed files with 3-layer evidence model).

---

## Usage

```
/jaan-to:detect-product [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (7 detection steps, 7 output files). Default is light mode. |

**Light mode** (default): Scans routes/screens and business logic/monetization, produces 1 summary file with feature inventory (Tentative confidence) and monetization summary.

**Full mode** (`--full`): Runs all steps including copy layer, instrumentation audit, feature flags, and constraint analysis. Produces 7 detailed output files with 3-layer evidence linking.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/product/summary{suffix}.md` | Feature inventory (Tentative), monetization + entitlements, top-5 findings |

### Full Mode (`--full`) — 7 files
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/product/overview.md` | Product overview with feature summary |
| `$JAAN_OUTPUTS_DIR/detect/product/features.md` | Feature inventory with 3-layer evidence |
| `$JAAN_OUTPUTS_DIR/detect/product/value-prop.md` | Value proposition signals from copy |
| `$JAAN_OUTPUTS_DIR/detect/product/monetization.md` | Monetization model with evidence |
| `$JAAN_OUTPUTS_DIR/detect/product/entitlements.md` | Entitlement enforcement mapping |
| `$JAAN_OUTPUTS_DIR/detect/product/metrics.md` | Instrumentation reality (analytics, flags, events) |
| `$JAAN_OUTPUTS_DIR/detect/product/constraints.md` | Technical/business constraints and risks |

### Multi-Platform Monorepo
Files use platform suffix: `overview-{platform}.md`, `summary-{platform}.md`, etc.

---

## What It Scans

| Category | Patterns |
|----------|---------|
| Routes/screens | `**/pages/**/*.{tsx,jsx,vue}`, `**/app/**/page.{tsx,jsx}`, React Router, API routes |
| Value proposition | Landing pages, hero sections, taglines, CTA text |
| Pricing copy | `**/pricing.*`, `**/tiers.*`, `$X/month`, tier names (free/starter/pro/enterprise) |
| Billing code | Stripe (`stripe.subscriptions`, `stripe.checkout`), PayPal, custom billing gates |
| Entitlements | `canAccess`, `hasFeature`, `user.plan`, `user.tier`, middleware guards |
| Analytics SDKs | GA4 (`gtag`), Mixpanel, Segment, PostHog, Amplitude, Plausible |
| Feature flags | Unleash, LaunchDarkly, Split.io, Flagsmith, custom `FEATURE_`/`FF_` patterns |
| Constraints | Rate limiting, file size limits, user limits, trial/expiration, geo-restrictions, compliance (GDPR/CCPA/HIPAA) |

---

## Multi-Platform Support

- **Platform auto-detection**: Detects web/, backend/, mobile/, etc. from folder structure
- **Evidence ID format**:
  - Single-platform: `E-PRD-NNN` (e.g., `E-PRD-001`)
  - Multi-platform: `E-PRD-{PLATFORM}-NNN` (e.g., `E-PRD-WEB-001`, `E-PRD-BACKEND-023`)
- **Cross-platform feature linking**: Use `related_evidence` field to link features spanning multiple platforms (e.g., web checkout UI → backend payment API)
- **Platform-specific features**: Separate evidence per platform (e.g., mobile push notifications vs web in-app notifications)
- **Fully applicable**: detect-product analyzes all platforms (no skip logic)

---

## Key Points

- **3-layer feature evidence**: Surface + Copy + Code Path → confidence mapping:
  - All 3 layers → Confirmed; 2/3 → Firm; 1 layer + heuristics → Tentative; Inferred only → Uncertain
- Monetization: distinguish "pricing copy" (what product claims) vs "enforcement" (what code enforces) — gates must be proven by code locations
- Absence of evidence becomes an "absence" evidence item (not a claim without proof)
- Instrumentation: event taxonomy consistency assessed (naming convention, property standardization, coverage gaps)
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
