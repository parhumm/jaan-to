# Technical Risks Audit — claude-code

---
title: "Technical Risks Audit — claude-code"
id: "AUDIT-2026-009"
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
  medium: 4
  low: 3
  informational: 0
overall_score: 7.5
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin has several **technical risks** that warrant attention:

**High-Priority Risks**:
- Unknown test coverage (no automated test execution)

**Medium-Priority Risks**:
- Large documentation dependency tree (600MB node_modules, 900+ packages)
- No error tracking for production docs site
- Shell scripts lack unit tests
- Manual version bump process (mitigated by script, but still manual)

**Low-Priority Risks**:
- No automated dependency updates (Renovate, Dependabot)
- Multiple package-lock.json files (root vs. docs)
- Plugin auto-discovery relies on directory structure conventions

**Overall Assessment**: **Manageable risks** with clear remediation paths. No critical showstoppers.

---

## Scope and Methodology

**Risk Assessment Criteria**:
- **Likelihood**: Probability of risk materializing (Low, Medium, High)
- **Impact**: Severity if risk occurs (Low, Medium, High, Critical)
- **Risk Score**: Likelihood × Impact

---

## Findings

### RISK-001: Unknown Test Coverage

**Severity**: High
**Confidence**: Confirmed (0.95)
**Likelihood**: High | **Impact**: High | **Risk Score**: 9/10

```yaml
evidence:
  id: E-DEV-055
  type: metric
  confidence: 0.95
  location:
    uri: "."
    analysis: |
      Test coverage is unknown:
      - No test framework (Jest, Vitest)
      - No coverage tooling (Istanbul, c8)
      - E2E tests exist but are not executed in CI

      Without coverage metrics:
      - Cannot identify untested code paths
      - Risk of regressions increases over time
      - Difficult to enforce coverage thresholds
  method: heuristic
```

**Description**: The plugin's **test coverage is unknown** because:
1. No test framework is integrated
2. No coverage instrumentation is in place
3. E2E tests exist but aren't run automatically

**Risk Scenario**: A change breaks an untested code path → bug ships to users → trust in plugin degrades.

**Remediation**:
1. **Immediate**: Run existing E2E tests in CI (add to release-check.yml)
2. **Short-term**: Add test framework (Vitest) and write unit tests for critical skills
3. **Long-term**: Set coverage threshold (70%+) and enforce in CI

**Timeline**: 2-4 weeks

---

### RISK-002: Large Documentation Dependency Tree

**Severity**: Medium
**Confidence**: Firm (0.92)
**Likelihood**: Medium | **Impact**: Medium | **Risk Score**: 6/10

```yaml
evidence:
  id: E-DEV-056
  type: metric
  confidence: 0.92
  location:
    uri: "website/docs/node_modules/"
    analysis: |
      Repository size: 627MB
      Documentation dependencies: 900+ packages
      node_modules size: ~600MB (95% of total)

      Risks:
      - Slower CI builds (npm install time)
      - Higher attack surface (more dependencies = more CVEs)
      - Dependency conflicts (900+ packages have transitive deps)
  method: static-analysis
```

**Description**: The documentation site has a **large dependency footprint** (900+ packages, 600MB).

**Risk Scenario**:
- A vulnerability in a transitive dependency goes unnoticed → CVE exploited
- npm install times increase → CI slowdown → developer frustration

**Remediation**:
1. **Audit dependencies**: Run `npm ls --depth=0` to identify top-level deps
2. **Remove unused deps**: Check for unused packages
3. **Evaluate alternatives**: Consider lighter frameworks (Nextra, Astro) if bundle size becomes critical
4. **Add npm audit**: Scan for vulnerabilities in CI

**Timeline**: 1-2 weeks for audit, longer for framework migration (if needed)

---

### RISK-003: No Error Tracking for Production Docs Site

**Severity**: Medium
**Confidence**: Firm (0.85)
**Likelihood**: Medium | **Impact**: Medium | **Risk Score**: 6/10

```yaml
evidence:
  id: E-DEV-057
  type: absence
  confidence: 0.85
  location:
    uri: "website/docs/"
    analysis: |
      Documentation site lacks error tracking:
      - No Sentry, Rollbar, or similar
      - JavaScript errors occur silently (no telemetry)
      - Bug reports rely on users filing GitHub issues

      Example scenario:
      - Search widget breaks in Safari due to polyfill issue
      - Users silently encounter errors
      - Developers unaware until multiple users report
  method: pattern-match
```

**Description**: **Client-side errors** in the documentation site go undetected.

**Risk Scenario**: A React error breaks the search widget → users can't find documentation → support burden increases.

**Remediation**:
1. Integrate Sentry (free tier: 5K events/month)
2. Add error boundaries in React components
3. Set up alerts for high error rates

**Timeline**: 1 day

---

### RISK-004: Shell Scripts Lack Unit Tests

**Severity**: Medium
**Confidence**: Firm (0.80)
**Likelihood**: Medium | **Impact**: Medium | **Risk Score**: 6/10

```yaml
evidence:
  id: E-DEV-058
  type: absence
  confidence: 0.80
  location:
    uri: "scripts/"
    analysis: |
      14 shell scripts (1,407 lines) have no unit tests:
      - bootstrap.sh
      - validate-skills.sh
      - bump-version.sh
      - post-commit-roadmap.sh
      - (10 more)

      Risks:
      - Bugs in edge cases (e.g., file paths with spaces)
      - Regressions when modifying scripts
      - Difficult to refactor confidently
  method: static-analysis
```

**Description**: The 14 shell scripts lack **unit tests**, making them fragile and hard to refactor.

**Risk Scenario**: A change to `bootstrap.sh` breaks project setup → users encounter cryptic errors → plugin adoption drops.

**Remediation**:
1. **Add ShellCheck linting**: Catches 80% of common shell bugs
2. **Add BATS tests**: [Bash Automated Testing System](https://github.com/bats-core/bats-core) for unit testing shell scripts
3. **Run in CI**: Execute shell tests on every PR

**Timeline**: 1-2 weeks

---

### RISK-005: Manual Version Bump Process

**Severity**: Medium
**Confidence**: Firm (0.85)
**Likelihood**: Low | **Impact**: High | **Risk Score**: 5/10

```yaml
evidence:
  id: E-DEV-059
  type: code-location
  confidence: 0.85
  location:
    uri: "scripts/bump-version.sh"
    analysis: |
      Version bumping is scripted but still manual:
      1. Developer runs: ./scripts/bump-version.sh X.Y.Z
      2. Script updates: plugin.json, marketplace.json, CHANGELOG.md
      3. Developer commits and pushes

      Risks:
      - Forgotten CHANGELOG entry (mitigated by CI check)
      - Incorrect version format
      - Accidental skip of version number
  method: static-analysis
```

**Description**: Version bumping uses a **manual script**, which is error-prone.

**Risk Scenario**: Developer forgets to run bump-version.sh → CI fails → workflow disrupted.

**Remediation**:
1. **Short-term**: Current script + CI validation is adequate
2. **Long-term**: Consider semantic-release for fully automated versioning

**Timeline**: Current process is acceptable; no urgent action needed.

---

### RISK-006: No Automated Dependency Updates

**Severity**: Low
**Confidence**: Confirmed (0.90)
**Likelihood**: High | **Impact**: Low | **Risk Score**: 3/10

```yaml
evidence:
  id: E-DEV-060
  type: absence
  confidence: 0.90
  location:
    uri: ".github/"
    analysis: |
      No automated dependency updates configured:
      - No Renovate
      - No Dependabot (dependabot.yml missing)

      Without automation:
      - Dependencies become stale
      - Security patches require manual updates
      - Upgrade burden accumulates
  method: pattern-match
```

**Description**: Dependencies are **manually updated**, leading to staleness.

**Risk Scenario**: A security vulnerability in React → manual update required → takes days/weeks instead of automated PR.

**Remediation**:
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/website/docs"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

**Timeline**: 30 minutes to configure

---

### RISK-007: Multiple package-lock.json Files

**Severity**: Low
**Confidence**: Tentative (0.70)
**Likelihood**: Low | **Impact**: Low | **Risk Score**: 2/10

```yaml
evidence:
  id: E-DEV-061
  type: code-location
  confidence: 0.70
  location:
    uri: "."
    analysis: |
      Multiple lock files:
      - website/docs/package-lock.json (exists)
      - Root package-lock.json (missing, by design)

      Risk:
      - Confusion about which lock file to use
      - Accidental commits of incorrect lock files
  method: static-analysis
```

**Description**: The repository has **documentation-specific** lock files, but no root lock file (by design, since the plugin has no Node.js deps).

**Risk**: **Minimal** — Current structure is intentional and documented.

**Recommendation**: Add a comment in root README explaining why there's no root package.json.

---

### RISK-008: Plugin Auto-Discovery Relies on Convention

**Severity**: Low
**Confidence**: Confirmed (0.90)
**Likelihood**: Low | **Impact**: Medium | **Risk Score**: 3/10

```yaml
evidence:
  id: E-DEV-062
  type: pattern-match
  confidence: 0.90
  location:
    uri: ".claude-plugin/plugin.json"
    analysis: |
      plugin.json deliberately omits component paths:
      {
        "name": "jaan-to",
        "version": "3.24.0",
        "description": "..."
      }

      Claude Code auto-discovers:
      - skills/ directory
      - agents/ directory
      - hooks/hooks.json

      Risk: If directory structure changes (e.g., skills renamed to
      commands), auto-discovery breaks.
  method: manifest-analysis
```

**Description**: The plugin relies on **Claude Code's auto-discovery** of skills/agents/hooks from standard directories.

**Risk**: If the directory convention changes in a future Claude Code version, the plugin breaks.

**Mitigation**: This is a **documented feature** of Claude Code. The CI validation (`release-check.yml`) explicitly checks that `plugin.json` does NOT declare component paths, because doing so causes validation failures.

**Recommendation**: Monitor Claude Code release notes for breaking changes to auto-discovery.

---

## Recommendations

### Priority 1 (High)
1. **Add test coverage measurement** — Integrate test framework and coverage tooling (RISK-001)

### Priority 2 (Medium)
2. **Reduce documentation dependencies** — Audit and remove unused packages (RISK-002)
3. **Add error tracking** — Integrate Sentry for docs site (RISK-003)
4. **Add shell script tests** — Use ShellCheck + BATS (RISK-004)

### Priority 3 (Low)
5. **Enable Dependabot** — Automate dependency updates (RISK-006)
6. **Document version process** — Add runbook for releases (RISK-005)

---

## Appendices

### A. Risk Matrix

| Risk ID | Description | Likelihood | Impact | Score |
|---------|-------------|------------|--------|-------|
| RISK-001 | Unknown test coverage | High | High | 9 |
| RISK-002 | Large dependency tree | Medium | Medium | 6 |
| RISK-003 | No error tracking | Medium | Medium | 6 |
| RISK-004 | Shell scripts untested | Medium | Medium | 6 |
| RISK-005 | Manual version process | Low | High | 5 |
| RISK-006 | No dep automation | High | Low | 3 |
| RISK-007 | Multiple lock files | Low | Low | 2 |
| RISK-008 | Auto-discovery reliance | Low | Medium | 3 |

### B. Remediation Timeline

| Week | Action |
|------|--------|
| **Week 1** | Add Sentry (RISK-003), Enable Dependabot (RISK-006) |
| **Week 2** | Add ShellCheck linting (RISK-004) |
| **Week 3** | Integrate test framework (RISK-001) |
| **Week 4** | Audit dependencies (RISK-002) |

---

*Generated by jaan.to detect-dev | 2026-02-09*
