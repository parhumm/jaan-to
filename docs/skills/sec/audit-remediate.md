---
title: "sec-audit-remediate"
sidebar_position: 2
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-11
tags: [sec, security, audit, remediate, sarif, cwe, owasp, fixes]
related: [detect-dev, backend-scaffold, frontend-scaffold, devops-infra-scaffold]
---

# /sec-audit-remediate

> Generate targeted security fixes from detect-dev SARIF findings with regression tests.

---

## Overview

Takes security findings from `/detect-dev` (SARIF format or security summary) and scaffold code to generate targeted fix patches, regression tests, and a remediation report. Supports CWE-mapped fix strategies with severity-based triage and confidence scoring.

---

## Usage

```
/sec-audit-remediate
/sec-audit-remediate detect-dev-output [backend-scaffold | frontend-scaffold]
```

| Argument | Required | Description |
|----------|----------|-------------|
| detect-dev-output | No | Path to detect-dev SARIF or security summary |
| scaffold type | No | backend-scaffold or frontend-scaffold for code cross-reference |

When run without arguments, searches for detect-dev outputs automatically.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Remediation report with triage decisions |
| `{id}-{slug}-fixes.patch` | Fix patches per finding |
| `{id}-{slug}-tests.ts` | Regression tests for each fix |
| `{id}-{slug}-summary.md` | Executive summary with risk scores |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Remediation scope | Always | Which findings to fix (all / critical / selected) |
| Fix aggressiveness | Multiple strategies possible | Minimal patch vs comprehensive hardening |
| Test depth | Always | Regression only vs full security test suite |

---

## CWE Coverage

Generates fixes for common vulnerability types:

| CWE | Category | Strategy |
|-----|----------|----------|
| CWE-79 | XSS | DOMPurify + CSP headers |
| CWE-89 | SQL Injection | Parameterized queries |
| CWE-352 | CSRF | Token validation middleware |
| CWE-798 | Hardcoded Credentials | Environment variable extraction |
| CWE-862 | Missing AuthZ | RBAC middleware |

---

## Workflow Chain

```
/detect-dev --> /sec-audit-remediate --> /devops-infra-scaffold (security in CI)
```

---

## Example

**Input:**
```
/sec-audit-remediate path/to/detect-dev/security.md backend-scaffold
```

**Output:**
```
jaan-to/outputs/sec/remediate/01-auth-hardening/
├── 01-auth-hardening.md
├── 01-auth-hardening-fixes.patch
├── 01-auth-hardening-tests.ts
└── 01-auth-hardening-summary.md
```

---

## Tips

- Run `/detect-dev` first to generate SARIF findings
- Start with critical/high severity findings for maximum impact
- Review fix patches before applying to your codebase
- Use `/devops-infra-scaffold` to add security scanning to CI

---

## Related Skills

- [/detect-dev](../detect/detect-dev.md) - Engineering audit with SARIF evidence
- [/backend-scaffold](../backend/scaffold.md) - Generate backend code stubs
- [/devops-infra-scaffold](../devops/infra-scaffold.md) - Generate CI/CD with security scanning

---

## Technical Details

- **Logical Name**: sec-audit-remediate
- **Command**: `/sec-audit-remediate`
- **Role**: sec
- **Output**: `$JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/`
