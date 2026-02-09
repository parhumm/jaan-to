# CI/CD Audit — claude-code

---
title: "CI/CD Audit — claude-code"
id: "AUDIT-2026-005"
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
  high: 1
  medium: 2
  low: 1
  informational: 3
overall_score: 7.8
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin uses **GitHub Actions** with a well-structured CI/CD pipeline:

**Pipelines**:
1. **Release Check** — Validates version consistency, CHANGELOG, skill descriptions, docs build
2. **Deploy Sites** — Deploys marketing + docs sites to Cloudflare Pages

**Strengths**:
- Good release validation workflow
- Automatic deployment on main branch
- Reproducible builds (`npm ci`)
- Secrets managed via GitHub Secrets

**Risks**:
- Unpinned GitHub Actions (supply chain risk)
- No security scanning (SAST/DAST)
- No dependency auditing

**Assessment**: **Good** CI/CD hygiene, but missing security automation.

---

## Scope and Methodology

**Analysis Methods**:
- GitHub Actions workflow parsing
- Secrets usage analysis
- Action version pinning audit

---

## Findings

### F-CICD-001: GitHub Actions Workflows (2 Detected)

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-031
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/"
    analysis: |
      Workflows:
      1. release-check.yml (on PRs to main)
         - Version consistency check
         - CHANGELOG validation
         - Skill description limits
         - Docs build test

      2. deploy-docs.yml (on push to main)
         - Deploy marketing site to Cloudflare Pages
         - Deploy docs site to Cloudflare Pages
  method: manifest-analysis
```

**Description**: The project uses **2 GitHub Actions workflows** for release validation and deployment automation.

**Impact**: **Positive** — Good separation of concerns (validation vs. deployment).

---

### F-CICD-002: Release Validation Workflow

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-032
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/release-check.yml"
    startLine: 13
    endLine: 32
    snippet: |
      - name: Check all 3 version fields match
        run: |
          V1=$(jq -r '.version' .claude-plugin/plugin.json)
          V2=$(jq -r '.version' .claude-plugin/marketplace.json)
          V3=$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)

          if [[ "$V1" != "$V2" ]] || [[ "$V1" != "$V3" ]]; then
            echo "::error::Version mismatch detected!"
            exit 1
          fi
  method: manifest-analysis
```

**Description**: The release check workflow **validates**:
- Version consistency across plugin.json, marketplace.json
- CHANGELOG entry existence
- No component path declarations in plugin.json (causes validation failure)
- Skill description character limits
- Docs site build success

**Impact**: **Positive** — Prevents malformed releases from merging to main.

---

### F-CICD-003: Unpinned GitHub Actions

**Severity**: Medium
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-033
  type: config-pattern
  confidence: 0.98
  location:
    uri: ".github/workflows/"
    analysis: |
      Unpinned actions (using tags, not commit SHAs):
      - actions/checkout@v4
      - actions/setup-node@v4
      - cloudflare/wrangler-action@v3

      Recommended: Pin to commit SHA for supply chain security
      Example: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 (v4)
  method: pattern-match
```

**Description**: GitHub Actions are **unpinned** (using version tags like `@v4` instead of commit SHAs).

**Supply Chain Risk**: If an action's tag is moved to a malicious commit, the workflow will execute malicious code.

**Impact**: **Moderate** — Supply chain attack vector.

**Remediation**:
```yaml
# Before (risky)
- uses: actions/checkout@v4

# After (secure)
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

Use [GitHub Actions Pinning Tool](https://github.com/mheap/pin-github-action) to automate.

---

### F-CICD-004: Secrets Management via GitHub Secrets

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-034
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 21
    endLine: 24
    snippet: |
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
  method: manifest-analysis
```

**Description**: Secrets are managed via **GitHub Secrets** (CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID), not hardcoded.

**Impact**: **Positive** — Follows best practices for credential management.

---

### F-CICD-005: No Security Scanning

**Severity**: High
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-035
  type: absence
  confidence: 0.95
  location:
    uri: ".github/workflows/"
    analysis: |
      No security scanning detected:
      - No CodeQL (SAST)
      - No Trivy (container/dependency scanning)
      - No Snyk
      - No Dependabot security updates
  method: pattern-match
```

**Description**: The CI pipeline lacks **automated security scanning**:
- **SAST** (Static Application Security Testing): No CodeQL or similar
- **Dependency Scanning**: No vulnerability checks for npm packages

**Impact**: **High** — Vulnerabilities in dependencies may go undetected.

**Remediation**:
```yaml
# Add to .github/workflows/
name: Security Scan
on: [push, pull_request]
jobs:
  codeql:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript
      - uses: github/codeql-action/analyze@v3

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --production --audit-level=high
        working-directory: website/docs
```

---

### F-CICD-006: No Dependency Auditing

**Severity**: Medium
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-036
  type: absence
  confidence: 0.98
  location:
    uri: ".github/workflows/release-check.yml"
    analysis: |
      Release check runs:
      - npm ci (install)
      - npm run build (build)

      Missing:
      - npm audit (check for vulnerabilities)
  method: pattern-match
```

**Description**: The CI pipeline **does not run `npm audit`** to check for known vulnerabilities in dependencies.

**Impact**: **Moderate** — Vulnerable dependencies may be deployed to production.

**Remediation**: Add to release-check.yml:
```yaml
- name: Audit dependencies
  run: npm audit --production --audit-level=moderate
  working-directory: website/docs
```

---

### F-CICD-007: No SBOM Generation

**Severity**: Low
**Confidence**: Tentative (0.70)

```yaml
evidence:
  id: E-DEV-037
  type: absence
  confidence: 0.70
  location:
    uri: ".github/workflows/"
    analysis: |
      No SBOM (Software Bill of Materials) generation detected.

      Modern supply chain security practices recommend generating SBOMs
      in SPDX or CycloneDX format for transparency.
  method: heuristic
```

**Description**: The pipeline does not generate an **SBOM** (Software Bill of Materials) for tracking dependencies.

**Impact**: **Minor** — Makes it harder to respond to supply chain incidents (e.g., Log4Shell-style events).

**Remediation**: Add SBOM generation via `syft` or `cyclonedx-npm`:
```bash
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

---

## Recommendations

### Priority 1 (High)
1. **Add security scanning** — Integrate CodeQL and dependency auditing (F-CICD-005, F-CICD-006)

### Priority 2 (Medium)
2. **Pin GitHub Actions** — Use commit SHAs instead of version tags (F-CICD-003)

### Priority 3 (Low)
3. **Generate SBOMs** — Add SBOM generation for supply chain transparency (F-CICD-007)

---

*Generated by jaan.to detect-dev | 2026-02-09*
