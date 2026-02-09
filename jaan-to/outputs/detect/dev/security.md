# Security Audit — claude-code

---
title: "Security Audit — claude-code"
id: "AUDIT-2026-007"
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
  high: 2
  medium: 3
  low: 2
  informational: 2
overall_score: 7.2
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin security posture is **moderate**:

**Strengths**:
- Secrets managed via GitHub Secrets (not hardcoded)
- Branch protection via CI validation workflow
- No known critical vulnerabilities (at analysis time)

**Critical Gaps**:
- No SAST (Static Application Security Testing)
- No dependency vulnerability scanning in CI

**Medium Risks**:
- Unpinned GitHub Actions (supply chain risk)
- No SBOM generation (supply chain transparency)
- Shell scripts execute with elevated privileges

**Assessment**: **Needs Improvement** — Good baseline practices, but missing automated security scanning.

---

## Scope and Methodology

**Analysis Methods**:
- Secret scanning (credentials, API keys)
- CI/CD security analysis
- Dependency vulnerability assessment
- OWASP Top 10 mapping

**Scope**:
- ✅ Secrets management
- ✅ CI/CD security
- ✅ Supply chain security
- ⚠️ Runtime security (N/A — CLI plugin)
- ⚠️ Network security (N/A — no network services)

---

## Findings

### F-SEC-001: Secrets Managed via GitHub Secrets

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-043
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 21
    endLine: 24
    snippet: |
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
  method: manifest-analysis
```

**Description**: Credentials are stored in **GitHub Secrets**, not hardcoded in workflows or source code.

**OWASP Mapping**: A02:2021 – Cryptographic Failures (Mitigation: Proper secret storage)

**Impact**: **Positive** — Follows best practices. Secrets are encrypted at rest and masked in logs.

---

### F-SEC-002: No SAST Scanning

**Severity**: High
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-044
  type: absence
  confidence: 0.95
  location:
    uri: ".github/workflows/"
    analysis: |
      No SAST (Static Application Security Testing) detected:
      - No CodeQL
      - No Semgrep
      - No SonarQube/SonarCloud
      - No Snyk Code

      SAST tools detect:
      - SQL injection
      - XSS vulnerabilities
      - Insecure deserialization
      - Hard-coded secrets
      - Insecure random number generation
  method: pattern-match
```

**Description**: The CI pipeline lacks **Static Application Security Testing (SAST)** to detect security vulnerabilities in code.

**OWASP Mapping**: A03:2021 – Injection (Detection gap)

**Impact**: **High** — Code vulnerabilities may go undetected until exploited.

**Remediation**:
```yaml
# Add to .github/workflows/security-scan.yml
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
      - uses: github/codeql-action/autobuild@v3
      - uses: github/codeql-action/analyze@v3
```

---

### F-SEC-003: No Dependency Vulnerability Scanning

**Severity**: High
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-045
  type: absence
  confidence: 0.98
  location:
    uri: ".github/workflows/release-check.yml"
    analysis: |
      Release check does NOT run:
      - npm audit
      - Snyk test
      - Dependabot security updates

      Documentation site has 900+ dependencies.
      Known vulnerabilities in these packages are not being tracked.
  method: pattern-match
```

**Description**: The CI pipeline **does not audit dependencies** for known vulnerabilities (CVEs).

**OWASP Mapping**: A06:2021 – Vulnerable and Outdated Components

**Impact**: **High** — Vulnerable dependencies (e.g., prototype pollution, XSS in dependencies) may be deployed.

**Remediation**:
```yaml
# Add to .github/workflows/release-check.yml
- name: Audit npm dependencies
  run: npm audit --production --audit-level=moderate
  working-directory: website/docs
```

Enable **Dependabot** for automatic security updates:
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/website/docs"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

---

### F-SEC-004: Unpinned GitHub Actions (Supply Chain Risk)

**Severity**: Medium
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-046
  type: config-pattern
  confidence: 0.98
  location:
    uri: ".github/workflows/"
    analysis: |
      Actions use version tags (not commit SHAs):
      - actions/checkout@v4
      - actions/setup-node@v4
      - cloudflare/wrangler-action@v3

      If an action maintainer is compromised, an attacker could:
      1. Move the @v4 tag to a malicious commit
      2. Execute arbitrary code in CI runners
      3. Exfiltrate secrets (CLOUDFLARE_API_TOKEN)
  method: pattern-match
```

**Description**: GitHub Actions are **not pinned to commit SHAs**, creating a supply chain attack vector.

**OWASP Mapping**: A08:2021 – Software and Data Integrity Failures

**Impact**: **Moderate** — Supply chain compromise could lead to secret theft or malicious code injection.

**Remediation**: Pin actions to commit SHAs:
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

---

### F-SEC-005: Shell Scripts Execute with Elevated Privileges

**Severity**: Medium
**Confidence**: Tentative (0.70)

```yaml
evidence:
  id: E-DEV-047
  type: code-location
  confidence: 0.70
  location:
    uri: "hooks/hooks.json"
    analysis: |
      Hooks execute shell scripts with full filesystem access:
      - bootstrap.sh (creates directories, writes files)
      - post-commit-roadmap.sh (reads/writes files)
      - capture-feedback.sh (file operations)

      These scripts run automatically without user confirmation.
  method: heuristic
```

**Description**: Lifecycle hooks execute **shell scripts with filesystem access** without explicit user approval.

**Impact**: **Moderate** — Malicious or buggy scripts could overwrite important files.

**Recommendation**:
1. Add ShellCheck linting to catch unsafe patterns
2. Use `set -euo pipefail` in all scripts for error handling
3. Document what each script does in hook descriptions

---

### F-SEC-006: No SBOM Generation (Supply Chain Transparency)

**Severity**: Medium
**Confidence**: Tentative (0.70)

```yaml
evidence:
  id: E-DEV-048
  type: absence
  confidence: 0.70
  location:
    uri: ".github/workflows/"
    analysis: |
      No SBOM (Software Bill of Materials) generation.

      SBOMs provide transparency for:
      - Dependency tracking
      - Vulnerability response (e.g., Log4Shell)
      - License compliance
  method: heuristic
```

**Description**: The project does not generate an **SBOM** in SPDX or CycloneDX format.

**Impact**: **Moderate** — Harder to respond to supply chain incidents quickly.

**Remediation**:
```bash
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

---

### F-SEC-007: Branch Protection via CI Validation

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-049
  type: config-pattern
  confidence: 0.98
  location:
    uri: ".github/workflows/release-check.yml"
    startLine: 4
    endLine: 5
    snippet: |
      on:
        pull_request:
          branches: [main]
  method: manifest-analysis
```

**Description**: The **release check workflow** runs on all PRs to `main`, enforcing:
- Version consistency
- CHANGELOG entry
- Docs build success

This provides a form of **branch protection** (CI must pass before merge).

**Impact**: **Positive** — Prevents malformed releases from reaching main.

---

### F-SEC-008: No Signed Commits Enforcement

**Severity**: Low
**Confidence**: Tentative (0.65)

```yaml
evidence:
  id: E-DEV-050
  type: absence
  confidence: 0.65
  location:
    uri: ".github/"
    analysis: |
      No branch protection rule enforcing GPG-signed commits detected.

      Signed commits provide:
      - Identity verification (commit author is who they claim to be)
      - Non-repudiation (cannot deny authorship)
      - Protection against history rewriting attacks
  method: heuristic
```

**Description**: The project does not enforce **GPG-signed commits**.

**Impact**: **Minor** — An attacker with GitHub account access could impersonate legitimate contributors.

**Recommendation**: Enable "Require signed commits" in GitHub branch protection settings for `main` branch.

---

### F-SEC-009: No Penetration Testing or Security Audits

**Severity**: Low
**Confidence**: Tentative (0.60)

```yaml
evidence:
  id: E-DEV-051
  type: absence
  confidence: 0.60
  location:
    uri: "docs/"
    analysis: |
      No evidence of:
      - Security audits (SECURITY.md missing)
      - Penetration testing
      - Bug bounty program
      - Responsible disclosure policy
  method: heuristic
```

**Description**: No **security audit records** or **disclosure policy** found.

**Impact**: **Minor** — Security researchers may not know how to report vulnerabilities responsibly.

**Recommendation**: Add `SECURITY.md` with:
- Supported versions
- How to report vulnerabilities (email, security advisory)
- Expected response timeline

---

## Recommendations

### Priority 1 (High)
1. **Add SAST scanning** — Integrate CodeQL for automatic vulnerability detection (F-SEC-002)
2. **Add dependency auditing** — Run `npm audit` in CI and enable Dependabot (F-SEC-003)

### Priority 2 (Medium)
3. **Pin GitHub Actions** — Use commit SHAs instead of version tags (F-SEC-004)
4. **Generate SBOMs** — Add CycloneDX SBOM generation (F-SEC-006)
5. **Add ShellCheck linting** — Lint shell scripts for security issues (F-SEC-005)

### Priority 3 (Low)
6. **Enforce signed commits** — Enable GPG signature requirement (F-SEC-008)
7. **Add SECURITY.md** — Document vulnerability disclosure process (F-SEC-009)

---

## Appendices

### A. OWASP Top 10 2021 Coverage

| OWASP Category | Mitigation Status | Finding Reference |
|----------------|-------------------|-------------------|
| **A01: Broken Access Control** | N/A (no backend) | - |
| **A02: Cryptographic Failures** | ✅ Good (GitHub Secrets) | F-SEC-001 |
| **A03: Injection** | ⚠️ No SAST | F-SEC-002 |
| **A04: Insecure Design** | N/A | - |
| **A05: Security Misconfiguration** | ⚠️ Unpinned actions | F-SEC-004 |
| **A06: Vulnerable Components** | ❌ No scanning | F-SEC-003 |
| **A07: Authentication Failures** | N/A (no auth) | - |
| **A08: Data Integrity Failures** | ⚠️ Supply chain risk | F-SEC-004, F-SEC-006 |
| **A09: Logging Failures** | ⚠️ No monitoring | See observability.md |
| **A10: SSRF** | N/A (no network) | - |

---

*Generated by jaan.to detect-dev | 2026-02-09*
