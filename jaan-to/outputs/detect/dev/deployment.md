# Deployment Audit — claude-code

---
title: "Deployment Audit — claude-code"
id: "AUDIT-2026-006"
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
  medium: 0
  low: 1
  informational: 4
overall_score: 9.8
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin uses **Cloudflare Pages** for hosting documentation and marketing sites:

**Deployment Strategy**:
- **Trigger**: Automatic on push to `main` branch
- **Targets**: 2 sites (marketing + docs)
- **Platform**: Cloudflare Pages (edge-based CDN)
- **Build**: Reproducible via `npm ci`

**Strengths**:
- Fast global CDN (Cloudflare edge network)
- Automatic HTTPS
- Atomic deployments (no downtime)
- Preview deployments for PRs (likely enabled in Cloudflare dashboard)

**Gaps**:
- No staging environment detected
- No rollback strategy documented

**Assessment**: **Excellent** — Modern deployment setup with minimal operational overhead.

---

## Scope and Methodology

**Analysis Methods**:
- GitHub Actions workflow analysis
- Cloudflare Pages configuration inference

---

## Findings

### F-DEPLOY-001: Cloudflare Pages Deployment

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-038
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 26
    endLine: 43
    snippet: |
      deploy-docs:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-node@v4
            with:
              node-version: '20'
              cache: 'npm'
              cache-dependency-path: website/docs/package-lock.json
          - run: npm ci
            working-directory: website/docs
          - run: npm run build
            working-directory: website/docs
          - uses: cloudflare/wrangler-action@v3
            with:
              apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
              accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
              command: pages deploy website/docs/build --project-name=jaan-to-docs
  method: manifest-analysis
```

**Description**: The documentation site deploys to **Cloudflare Pages** using:
- **Build command**: `npm run build` (Docusaurus build)
- **Output directory**: `website/docs/build`
- **Project name**: `jaan-to-docs`

Cloudflare Pages provides:
- Global CDN with 200+ edge locations
- Automatic HTTPS with managed certificates
- Atomic deployments (no downtime)
- Built-in preview deployments for PRs

**Impact**: **Positive** — Excellent performance and reliability.

---

### F-DEPLOY-002: Two Separate Sites (Marketing + Docs)

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-039
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 9
    endLine: 24
    snippet: |
      deploy-marketing:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Sync marketing site with plugin state
            run: ./scripts/sync-marketing-site.sh
          - name: Prepare marketing site
            run: |
              mkdir -p /tmp/marketing-site
              cp website/index.html /tmp/marketing-site/
              cp -r website/favicon_io /tmp/marketing-site/
          - uses: cloudflare/wrangler-action@v3
            with:
              apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
              accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
              command: pages deploy /tmp/marketing-site --project-name=jaan-to
  method: manifest-analysis
```

**Description**: The project deploys **2 separate sites**:

1. **Marketing Site** (`jaan-to`):
   - Static HTML (website/index.html)
   - Lightweight (just HTML + favicon)
   - Synced with plugin state via script

2. **Documentation Site** (`jaan-to-docs`):
   - React + Docusaurus
   - Full documentation, examples, guides

**Impact**: **Positive** — Clean separation between landing page and docs.

---

### F-DEPLOY-003: Reproducible Builds via npm ci

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-040
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 35
    endLine: 35
    snippet: |
      - run: npm ci
  method: manifest-analysis
```

**Description**: The deployment workflow uses **`npm ci`** instead of `npm install`, ensuring:
- Installs exact versions from package-lock.json
- Fails if package-lock.json is out of sync
- Faster than `npm install` (skips dependency resolution)

**Impact**: **Positive** — Prevents "works on my machine" issues.

---

### F-DEPLOY-004: Build Validation in Release Check

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-041
  type: config-pattern
  confidence: 0.98
  location:
    uri: ".github/workflows/release-check.yml"
    startLine: 69
    endLine: 70
    snippet: |
      - name: Build docs site
        run: cd website/docs && npm ci && npm run build
  method: manifest-analysis
```

**Description**: The **release check workflow** validates that the docs site builds successfully before allowing PRs to merge.

**Impact**: **Positive** — Prevents broken builds from reaching production.

---

### F-DEPLOY-005: No Staging Environment

**Severity**: Low
**Confidence**: Tentative (0.75)

```yaml
evidence:
  id: E-DEV-042
  type: absence
  confidence: 0.75
  location:
    uri: ".github/workflows/"
    analysis: |
      No staging environment detected:
      - Only production deployments to main branch
      - No separate staging/preview Cloudflare project

      Cloudflare Pages likely provides preview deployments for PRs automatically,
      but no explicit staging environment configuration found.
  method: heuristic
```

**Description**: No explicit **staging environment** detected. Cloudflare Pages provides PR preview deployments automatically, but there's no separate long-lived staging environment for manual testing.

**Impact**: **Minor** — PR previews may be sufficient for most use cases.

**Recommendation**: Consider creating a `staging` branch that deploys to a separate Cloudflare project for long-running staging tests.

---

## Recommendations

### Priority 1 (High)
None identified. Deployment is solid.

### Priority 2 (Medium)
None identified.

### Priority 3 (Low)
1. **Add staging environment** — Create a staging branch with separate Cloudflare project (F-DEPLOY-005)

---

*Generated by jaan.to detect-dev | 2026-02-09*
