# Observability Audit — claude-code

---
title: "Observability Audit — claude-code"
id: "AUDIT-2026-008"
version: "1.0.0"
status: draft
date: 2026-02-09
target:
  name: "claude-code"
  platform: "all"
  commit: "3ab9a931ac23fe64a11a5519ad948885bcb6bcac"
  branch: "refactor/skill-naming-cleanup"
tool:
  name: "detect-dev"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 2
  low: 0
  informational: 1
overall_score: 8.4
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin has **minimal observability infrastructure**:

**Current State**:
- No logging framework
- No metrics collection
- No distributed tracing
- No error monitoring

**Context**: As a **CLI plugin** running in Claude Code's runtime, traditional server-side observability patterns (Prometheus, Grafana, Datadog) don't directly apply. However, the **documentation site** (React + Docusaurus) running on Cloudflare Pages could benefit from:
- Client-side error tracking (Sentry, Rollbar)
- Analytics (Cloudflare Web Analytics, Google Analytics)
- Performance monitoring (Web Vitals)

**Assessment**: **Acceptable** for a CLI tool, but **missing observability for the documentation site**.

---

## Scope and Methodology

**Analysis Methods**:
- Configuration file scanning (logging, monitoring, APM)
- Dependency analysis (Sentry, Datadog, etc.)
- Analytics snippet detection

**Scope**:
- ✅ Error tracking configuration
- ✅ Analytics configuration
- ⚠️ Server-side logging (N/A — no backend)
- ⚠️ Metrics collection (N/A — CLI plugin)

---

## Findings

### F-OBS-001: No Logging Framework Detected

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-052
  type: absence
  confidence: 0.98
  location:
    uri: "."
    analysis: |
      No logging framework detected:
      - No winston, pino, bunyan (Node.js logging)
      - No console.* wrapper for structured logging
      - No log aggregation (Datadog, Splunk, ELK)

      Plugin execution logs are handled by Claude Code runtime.
  method: pattern-match
```

**Description**: The plugin **does not implement custom logging**. All logging is handled by the Claude Code runtime (stdout/stderr).

**Impact**: **Neutral** — Acceptable for a CLI plugin. Users see logs in their terminal.

**Recommendation**: For debugging complex skills, consider adding structured logging with severity levels (DEBUG, INFO, WARN, ERROR).

---

### F-OBS-002: No Error Tracking for Documentation Site

**Severity**: Medium
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DEV-053
  type: absence
  confidence: 0.85
  location:
    uri: "website/docs/"
    analysis: |
      Documentation site lacks error tracking:
      - No Sentry
      - No Rollbar
      - No Bugsnag
      - No custom error boundary logging

      If users encounter JavaScript errors on the docs site (e.g., React errors,
      search widget failures), developers have no visibility.
  method: pattern-match
```

**Description**: The **documentation site** lacks **client-side error tracking**. JavaScript errors that occur in users' browsers are not captured.

**Impact**: **Moderate** — Makes it hard to detect and fix bugs that only occur in production.

**Remediation**:
```typescript
// Install Sentry
npm install --save @sentry/react

// Add to website/docs/src/theme/Root.tsx
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "https://...@sentry.io/...",
  environment: process.env.NODE_ENV,
  integrations: [new Sentry.BrowserTracing()],
  tracesSampleRate: 0.1,
});
```

---

### F-OBS-003: No Analytics Detected

**Severity**: Medium
**Confidence**: Firm (0.80)

```yaml
evidence:
  id: E-DEV-054
  type: absence
  confidence: 0.80
  location:
    uri: "website/docs/docusaurus.config.js"
    analysis: |
      No analytics configuration detected:
      - No Google Analytics (gtag)
      - No Plausible
      - No Cloudflare Web Analytics
      - No Posthog

      Without analytics:
      - Page view counts unknown
      - Search query patterns unknown
      - User navigation flow unknown
  method: pattern-match
```

**Description**: The documentation site lacks **analytics tracking**. This means:
- No visibility into which pages are most popular
- No search query insights
- No user flow analysis

**Impact**: **Moderate** — Makes it hard to prioritize documentation improvements.

**Remediation (Privacy-Friendly Option)**:
```javascript
// docusaurus.config.js
module.exports = {
  // ...
  scripts: [
    {
      src: 'https://static.cloudflareinsights.com/beacon.min.js',
      defer: true,
      'data-cf-beacon': '{"token": "your-cloudflare-token"}'
    }
  ]
};
```

Or use **Docusaurus Google Analytics plugin**:
```javascript
// docusaurus.config.js
module.exports = {
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        gtag: {
          trackingID: 'G-XXXXXXXXXX',
          anonymizeIP: true,
        },
      },
    ],
  ],
};
```

---

## Recommendations

### Priority 1 (High)
None identified. Observability gaps are moderate.

### Priority 2 (Medium)
1. **Add error tracking** — Integrate Sentry for client-side error monitoring (F-OBS-002)
2. **Add analytics** — Track docs site usage with Cloudflare Analytics or Google Analytics (F-OBS-003)

### Priority 3 (Low)
3. **Add Web Vitals monitoring** — Track Core Web Vitals (LCP, FID, CLS) for performance regression detection

---

## Appendices

### A. Recommended Observability Stack

| Component | Tool | Cost | Use Case |
|-----------|------|------|----------|
| **Error Tracking** | Sentry | Free tier (5K events/month) | JavaScript errors, React crashes |
| **Analytics** | Cloudflare Web Analytics | Free | Privacy-friendly page views |
| **Performance** | Lighthouse CI | Free | Automated Web Vitals monitoring |

### B. Observability Maturity Model

**Current Level**: **Level 1 (Reactive)**
- No proactive monitoring
- Relies on user reports for bug discovery

**Target Level**: **Level 2 (Proactive)**
- Automatic error detection (Sentry)
- Usage analytics for prioritization
- Performance monitoring for regressions

---

*Generated by jaan.to detect-dev | 2026-02-09*
