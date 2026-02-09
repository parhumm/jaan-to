---
title: "detect-product"
sidebar_position: 4
doc_type: skill
tags: [detect, product, features, monetization, instrumentation]
related: [detect-dev, detect-design, detect-writing, detect-ux, detect-pack]
updated_date: 2026-02-08
---

# /jaan-to:detect-product

> Product reality extraction with evidence-backed features, monetization, and metrics.

---

## What It Does

Extracts the "product reality" from the repository using a 3-layer evidence model: surface (routes/screens), copy (user-facing text), and code path (business logic). Scans for features, value proposition signals, monetization/billing, entitlement enforcement, analytics instrumentation, feature flags, and technical/business constraints.

---

## Usage

```
/jaan-to:detect-product
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

### Single-Platform Project
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
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/product/overview-{platform}.md` | Product overview scoped to platform (e.g., `overview-web.md`, `overview-backend.md`) |
| ... | (same structure with platform suffix) |

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
