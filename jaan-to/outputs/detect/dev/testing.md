# Testing Audit — claude-code

---
title: "Testing Audit — claude-code"
id: "AUDIT-2026-004"
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
  low: 0
  informational: 1
overall_score: 7.1
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin has **minimal test infrastructure**:

**Current State**:
- Test scripts exist (scripts/test/)
- Shell-based E2E tests for phases 1-6
- No automated test execution in CI
- No test framework (Jest, Vitest, etc.)

**Risk**: **High** — Without automated tests in CI, regressions can slip into production.

**Assessment**: **Needs Improvement** — Test scripts are a good start, but lack automation and coverage visibility.

---

## Scope and Methodology

**Analysis Methods**:
- Test script inspection (scripts/test/)
- CI workflow analysis
- Package.json dependency scanning

---

## Findings

### F-TEST-001: E2E Test Scripts Exist

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-027
  type: code-location
  confidence: 0.98
  location:
    uri: "scripts/test/"
    analysis: |
      Test scripts found:
      - phase1-e2e.sh
      - phase2-e2e.sh
      - phase3-5-e2e.sh
      - phase6-e2e.sh
      - integration-all-phases.sh
      - run-all-tests.sh

      These are shell-based E2E tests, likely testing skill execution flows.
  method: static-analysis
```

**Description**: The project has **6 E2E test scripts** for testing different phases of the plugin lifecycle.

**Impact**: **Positive** — Shows testing discipline. However, shell-based tests are harder to maintain than framework-based tests.

---

### F-TEST-002: No Test Framework in Dependencies

**Severity**: High
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-028
  type: absence
  confidence: 1.00
  location:
    uri: "package.json"
    analysis: |
      Root package.json missing (by design).

      Documentation site (website/docs/package.json) has no test framework:
      - No Jest
      - No Vitest
      - No Mocha
      - No Playwright/Cypress

      Only test-related dev dependency: TypeScript compiler (for type checking).
  method: manifest-analysis
```

**Description**: The project lacks a **test framework** for unit/integration testing. All tests are shell-based E2E scripts.

**Impact**: **High** — Makes it hard to:
- Test individual functions or skills
- Get code coverage metrics
- Write fast, isolated unit tests

**Remediation**:
1. Add Vitest for unit testing shell script logic (if migrated to Node.js)
2. Add Playwright for E2E testing of the documentation site
3. Add a test coverage threshold (e.g., 70% minimum)

---

### F-TEST-003: No CI Test Execution

**Severity**: Medium
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-029
  type: absence
  confidence: 0.95
  location:
    uri: ".github/workflows/release-check.yml"
    analysis: |
      Release check workflow validates:
      - Version consistency
      - CHANGELOG entry
      - Skill description limits
      - Docs site build

      Missing:
      - Test execution (run-all-tests.sh)
      - Code coverage reporting
  method: manifest-analysis
```

**Description**: The GitHub Actions release check workflow **does not run tests**. The `run-all-tests.sh` script exists but is not invoked in CI.

**Impact**: **Moderate** — Regressions can slip through code review if tests aren't automated.

**Remediation**:
```yaml
# Add to .github/workflows/release-check.yml
- name: Run E2E tests
  run: bash scripts/test/run-all-tests.sh
```

---

### F-TEST-004: Unknown Test Coverage

**Severity**: Medium
**Confidence**: Tentative (0.75)

```yaml
evidence:
  id: E-DEV-030
  type: metric
  confidence: 0.75
  location:
    uri: "."
    analysis: |
      Without a test framework and coverage tooling:
      - Line coverage: Unknown
      - Branch coverage: Unknown
      - Critical path coverage: Unknown

      Shell-based E2E tests likely cover happy paths only.
  method: heuristic
```

**Description**: **Test coverage is unknown**. Without instrumentation, it's impossible to know which code paths are tested.

**Impact**: **Moderate** — Makes it hard to identify untested code and prioritize test writing.

**Remediation**: Add coverage reporting once a test framework is integrated.

---

## Recommendations

### Priority 1 (High)
1. **Add test framework** — Integrate Vitest or Jest for unit/integration tests (F-TEST-002)
2. **Run tests in CI** — Execute `run-all-tests.sh` in GitHub Actions (F-TEST-003)

### Priority 2 (Medium)
3. **Add code coverage** — Integrate coverage tooling (Istanbul, c8) and set thresholds (F-TEST-004)

### Priority 3 (Low)
4. **Migrate shell tests to framework** — Gradually migrate E2E tests from shell to Playwright or Vitest

---

*Generated by jaan.to detect-dev | 2026-02-09*
