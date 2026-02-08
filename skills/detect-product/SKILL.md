---
name: detect-product
description: Product reality extraction with evidence-backed features, monetization, and metrics.
allowed-tools: Read, Glob, Grep, Write(docs/current/product/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# detect-product

> Evidence-based product reality extraction: features, monetization, instrumentation, and constraints.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-product.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (for framework-aware scanning)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-product.template.md` - Output template

**Output path exception**: This skill writes to `docs/current/product/` in the target project, NOT to `$JAAN_OUTPUTS_DIR`. Detect outputs are living project documentation (overwritten each run), not versioned artifacts.

## Input

**Repository**: $ARGUMENTS

If a repository path is provided, scan that repo. Otherwise, scan the current working directory.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:detect-product.learn.md`

If the file exists, apply its lessons throughout this execution.

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_detect-product` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, evidence blocks.

---

## Standards Reference

### Evidence Format (SARIF-compatible)

```yaml
evidence:
  id: E-PRD-001
  type: code-location
  confidence: 0.85
  location:
    uri: "src/billing/stripe.ts"
    startLine: 42
    snippet: |
      const subscription = await stripe.subscriptions.create(...)
  method: pattern-match
```

Evidence IDs use namespace `E-PRD-NNN` to prevent collisions in pack-detect.

### Feature Evidence Linking — 3-Layer Model

"Feature exists" requires evidence across up to 3 layers:

| Layer | What | Example |
|-------|------|---------|
| **Surface** | Route, page, or screen | `/pricing` route, `PricingPage.tsx` |
| **Copy** | User-facing text | "Upgrade to Pro", pricing table copy |
| **Code path** | Business logic | `checkSubscription()`, Stripe API call |

**Confidence mapping**:
- All 3 layers found -> **Confirmed**
- 2/3 layers -> **Firm**
- 1 layer + heuristics -> **Tentative**
- Inferred only -> **Uncertain**

### Confidence Levels (4-level)

| Level | Label | Range | Criteria |
|-------|-------|-------|----------|
| 4 | **Confirmed** | 0.95-1.00 | Multiple independent methods agree |
| 3 | **Firm** | 0.80-0.94 | Single high-precision method with clear evidence |
| 2 | **Tentative** | 0.50-0.79 | Pattern match without full analysis |
| 1 | **Uncertain** | 0.20-0.49 | Absence-of-evidence reasoning |

### Frontmatter Schema (Universal)

```yaml
---
title: "{document title}"
id: "{AUDIT-YYYY-NNN}"
version: "1.0.0"
status: draft
date: {YYYY-MM-DD}
target:
  name: "{repo-name}"
  commit: "{git HEAD hash}"
  branch: "{current branch}"
tool:
  name: "detect-product"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 0
overall_score: 0.0
lifecycle_phase: post-build
---
```

### Document Structure (Diataxis)

1. Executive Summary
2. Scope and Methodology
3. Findings (ID/severity/confidence/evidence)
4. Recommendations
5. Appendices

---

# PHASE 1: Detection (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Feature evidence linking across 3 layers
- Monetization model inference
- Instrumentation taxonomy analysis
- Constraint and risk assessment

## Step 1: Scan Routes and Screens (Surface Layer)

Identify all user-facing surfaces:

### Route Detection
- Glob: `**/pages/**/*.{tsx,jsx,vue}` — file-based routing (Next.js, Nuxt)
- Glob: `**/app/**/page.{tsx,jsx,ts,js}` — Next.js app router
- Grep for route definitions: `<Route`, `useRoutes`, `createBrowserRouter`
- Grep for API routes: `app.get(`, `router.post(`, `@Get(`, `@Post(`

### Screen/Page Inventory
For each route/page, extract:
- Route path
- Page/component name
- Public vs authenticated (look for auth guards, middleware)
- Feature domain (billing, settings, dashboard, etc.)

## Step 2: Scan User-Facing Copy (Copy Layer)

Extract product-relevant text:

### Value Proposition Signals
- Grep: `**/landing*`, `**/home*`, `**/marketing*` for taglines and value statements
- Grep for hero sections: `<Hero`, `hero-section`, `landing-hero`
- Extract: headlines, subheadlines, CTA button text

### Pricing Copy
- Glob: `**/pricing.*`, `**/tiers.*`, `**/plans.*`
- Grep for pricing patterns: `\$\d+`, `/month`, `/year`, `per seat`, `upgrade`, `downgrade`
- Grep for tier names: `free`, `starter`, `pro`, `enterprise`, `premium`, `basic`

### Feature Descriptions
- Grep for feature lists: `features`, `capabilities`, `benefits`
- Extract feature names and descriptions from marketing/product pages

## Step 3: Scan Business Logic (Code Path Layer)

### Monetization / Billing
- Grep for Stripe: `stripe.subscriptions`, `stripe.invoices`, `stripe.checkout`, `stripe.prices`
- Grep for PayPal: `paypal`, `braintree`
- Grep for custom billing: `checkSubscription()`, `requiresPremium`, `userTier`, `planId`
- Grep for entitlement gates: `canAccess`, `hasFeature`, `isAllowed`, `checkPermission`
- Grep for usage limits: `rateLimited`, `usageCount`, `quota`, `limit`

### Entitlement Enforcement
- Grep for tier checks: `user.plan`, `user.tier`, `subscription.status`
- Grep for feature flags as gates: `isFeatureEnabled`, `featureToggle`
- Grep for middleware/guards: `requiresAuth`, `requiresPlan`, `checkEntitlement`

Distinguish "pricing copy" (what the product claims) from "enforcement" (what the code actually enforces). Gates must be proven by code locations; absence = "absence" evidence item.

## Step 4: Scan Instrumentation / Analytics

### Analytics SDKs
- Grep: `gtag('event'` — Google Analytics 4
- Grep: `mixpanel.track` — Mixpanel
- Grep: `analytics.track` — Segment
- Grep: `posthog.capture` — PostHog
- Grep: `amplitude.track` — Amplitude
- Grep: `plausible` — Plausible Analytics

### Feature Flags
- Grep: `unleash.isEnabled` — Unleash
- Grep: `launchdarkly.variation`, `ldClient` — LaunchDarkly
- Grep: `splitio`, `getTreatment` — Split.io
- Grep: `flagsmith` — Flagsmith
- Grep: `FEATURE_`, `FF_` — custom feature flag patterns

### Event Taxonomy
For each analytics call found, extract:
- Event name
- Properties/parameters
- Location (file:line)

Assess taxonomy consistency: naming convention, property standardization, coverage gaps.

## Step 5: Scan Product Constraints

### Technical Constraints
- Grep for rate limiting: `rateLimit`, `throttle`, `rateLimiter`
- Grep for file size limits: `maxFileSize`, `MAX_UPLOAD`, `fileSizeLimit`
- Grep for user limits: `maxUsers`, `seatLimit`, `teamSize`

### Business Rules
- Grep for trial/expiration: `trialEnd`, `expiresAt`, `gracePeriod`
- Grep for geo-restrictions: `allowedCountries`, `blockedRegions`, `geoRestrict`
- Grep for compliance: `GDPR`, `CCPA`, `HIPAA`, `SOC2`, `PCI`

### Risk Signals
- Features with routes but no tests
- Pricing copy without enforcement code
- Analytics events without consistent naming
- Entitlement checks with hardcoded values

---

# HARD STOP — Detection Summary & User Approval

## Step 6: Present Detection Summary

```
PRODUCT DETECTION COMPLETE
---------------------------

FEATURES DETECTED: {n}
  Confirmed (3-layer): {n}
  Firm (2-layer):      {n}
  Tentative (1-layer): {n}
  Inferred:            {n}

MONETIZATION
  Model:        {free|freemium|subscription|usage-based|one-time|none detected}
  Tiers:        {tier names or "none detected"}
  Enforcement:  {n} code gates found    [Confidence: {level}]

INSTRUMENTATION
  Analytics:    {tool names or "none detected"}
  Feature flags: {tool names or "none detected"}
  Events:       {n} tracked events

SEVERITY SUMMARY
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10

OUTPUT FILES (7):
  docs/current/product/overview.md       - Product overview
  docs/current/product/features.md       - Feature inventory
  docs/current/product/value-prop.md     - Value proposition signals
  docs/current/product/monetization.md   - Monetization model
  docs/current/product/entitlements.md   - Entitlement enforcement
  docs/current/product/metrics.md        - Instrumentation reality
  docs/current/product/constraints.md    - Constraints and risks
```

> "Proceed with writing 7 output files to docs/current/product/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 7: Write to docs/current/product/

Create directory `docs/current/product/` if it does not exist.

Write 7 output files:

| File | Content |
|------|---------|
| `docs/current/product/overview.md` | Product overview with feature summary |
| `docs/current/product/features.md` | Feature inventory with 3-layer evidence |
| `docs/current/product/value-prop.md` | Value proposition signals from copy |
| `docs/current/product/monetization.md` | Monetization model with evidence |
| `docs/current/product/entitlements.md` | Entitlement enforcement mapping |
| `docs/current/product/metrics.md` | Instrumentation reality (analytics, flags, events) |
| `docs/current/product/constraints.md` | Technical/business constraints and risks |

Each file MUST include:
1. Universal YAML frontmatter
2. Executive Summary
3. Scope and Methodology
4. Findings with evidence blocks (using E-PRD-NNN IDs)
5. Recommendations

---

## Step 8: Capture Feedback

> "Any feedback on the product detection? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-product "{feedback}"`

---

## Definition of Done

- [ ] All 7 output files written to `docs/current/product/`
- [ ] Universal YAML frontmatter in every file
- [ ] Every finding has evidence block with E-PRD-NNN ID
- [ ] Feature evidence uses 3-layer model with confidence mapping
- [ ] Monetization distinguishes "copy" from "enforcement"
- [ ] Absence evidence used where appropriate (not claims without evidence)
- [ ] Instrumentation taxonomy consistency assessed
- [ ] Confidence scores assigned to all findings
- [ ] User approved output
