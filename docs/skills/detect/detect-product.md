---
title: "detect-product"
sidebar_position: 4
doc_type: skill
tags: [detect, product, features, monetization, instrumentation]
related: [detect-dev, detect-design, detect-writing, detect-ux, pack-detect]
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

| File | Content |
|------|---------|
| `docs/current/product/overview.md` | Product overview with feature summary |
| `docs/current/product/features.md` | Feature inventory with 3-layer evidence |
| `docs/current/product/value-prop.md` | Value proposition signals from copy |
| `docs/current/product/monetization.md` | Monetization model with evidence |
| `docs/current/product/entitlements.md` | Entitlement enforcement mapping |
| `docs/current/product/metrics.md` | Instrumentation reality (analytics, flags, events) |
| `docs/current/product/constraints.md` | Technical/business constraints and risks |

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

## Key Points

- Evidence IDs use namespace `E-PRD-NNN` (prevents collisions in pack-detect aggregation)
- **3-layer feature evidence**: Surface + Copy + Code Path → confidence mapping:
  - All 3 layers → Confirmed; 2/3 → Firm; 1 layer + heuristics → Tentative; Inferred only → Uncertain
- Monetization: distinguish "pricing copy" (what product claims) vs "enforcement" (what code enforces) — gates must be proven by code locations
- Absence of evidence becomes an "absence" evidence item (not a claim without proof)
- Instrumentation: event taxonomy consistency assessed (naming convention, property standardization, coverage gaps)
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
