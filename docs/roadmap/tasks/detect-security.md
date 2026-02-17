---
title: "Dedicated Security Detection"
sidebar_position: 21
---

# Dedicated Security Detection

> Phase 6 | Status: pending

## Problem

Security and vulnerability findings are currently embedded within `/detect-dev`, `/detect-pack`, and other `/detect-*` skills. This mixes security concerns with general development issues, making it impossible to:
- Restrict security findings to authorized personnel only
- Run security-focused audits independently
- Route security outputs to a separate access-controlled location (gitsubmodule)

## Solution

Create `/detect-security` as a dedicated security/vulnerability detection skill. Extract all security scope from existing detect skills, consolidate into one security-focused skill with SARIF-like evidence format and 4-level confidence scoring (same patterns as `detect-dev`).

### Security Scope Distribution

| Finding Type | Currently In | Moves To |
|-------------|-------------|----------|
| Dependency vulnerabilities (CVEs) | `detect-dev` | `detect-security` |
| Secret/credential detection | `detect-dev` | `detect-security` |
| Injection risks (SQL, XSS, command) | `detect-dev` | `detect-security` |
| Authentication/authorization issues | `detect-dev` | `detect-security` |
| OWASP Top 10 coverage | `detect-dev` | `detect-security` |
| Supply chain security | `detect-pack` | `detect-security` |
| Code quality (complexity, duplication) | `detect-dev` | stays in `detect-dev` |
| Performance patterns | `detect-dev` | stays in `detect-dev` |
| Error handling patterns | `detect-dev` | stays in `detect-dev` |

### Finding Categories (OWASP-Aligned)

1. **A01 Broken Access Control** — Missing auth checks, IDOR, privilege escalation
2. **A02 Cryptographic Failures** — Weak algorithms, hardcoded secrets, missing encryption
3. **A03 Injection** — SQL, XSS, command, LDAP, template injection
4. **A04 Insecure Design** — Missing threat modeling, trust boundary violations
5. **A05 Security Misconfiguration** — Default credentials, verbose errors, missing headers
6. **A06 Vulnerable Components** — Outdated dependencies, known CVEs
7. **A07 Auth Failures** — Brute force, weak passwords, session management
8. **A08 Data Integrity Failures** — Unsigned updates, deserialization, CI/CD tampering
9. **A09 Logging Failures** — Missing audit logs, sensitive data in logs
10. **A10 SSRF** — Server-side request forgery vectors

## Scope

**In-scope:**
- All security findings currently in `detect-dev` and `detect-pack`
- SARIF-like evidence format with file paths, line numbers, confidence
- 4-level confidence scoring (high/medium/low/info)
- OWASP Top 10 category mapping
- OpenSSF scorecard metrics (where applicable)

**Out-of-scope:**
- Dynamic analysis (DAST) — static analysis only
- Penetration testing automation
- Compliance frameworks (SOC2, HIPAA) — future enhancement

## Implementation Steps

1. Create skill via `/jaan-to:skill-create detect-security`
2. Define SKILL.md following `detect-dev` patterns:
   - Same SARIF-like evidence format
   - Same 4-level confidence scoring
   - Same light/full detection modes
   - Two-phase workflow with HARD STOP
3. Implement security-specific scanners:
   - Dependency audit (`npm audit`, `pip-audit`, `composer audit`)
   - Secret detection (regex patterns for API keys, tokens, passwords)
   - Injection pattern matching (SQL, XSS, command injection patterns)
   - Auth/authz pattern analysis
   - Security header checks (CSP, HSTS, X-Frame-Options)
4. Update `/detect-dev` to remove security scope:
   - Remove security finding categories
   - Add reference: "For security findings, use `/detect-security`"
5. Update `/detect-pack` to reference security by link:
   - Don't inline security findings
   - Add summary section: "Security: See `/detect-security` output"
6. Output at `$JAAN_OUTPUTS_DIR/detect/security/{NEXT_ID}-{slug}/`

## Skills Affected

- `/detect-dev` — remove security findings, add cross-reference
- `/detect-pack` — reference security summary by link, don't inline
- `/detect-design` — remove any security-adjacent findings
- `/sec-audit-remediate` — downstream consumer of findings
- `/detect-writing` — no change
- `/detect-product` — no change
- `/detect-ux` — no change

## Acceptance Criteria

- [ ] New `detect-security` skill with SKILL.md following v3.0.0 patterns
- [ ] SARIF-like evidence format (same as other detect skills)
- [ ] 4-level confidence scoring (same as detect-dev)
- [ ] Security-specific finding categories (OWASP-aligned)
- [ ] `detect-dev` updated to exclude security scope
- [ ] `detect-pack` updated to reference (not inline) security findings
- [ ] Output at `$JAAN_OUTPUTS_DIR/detect/security/{id}-{slug}/`
- [ ] Light and full detection modes supported

## Dependencies

- None for creation (standalone new skill)
- Must be implemented **before** Security Output Proxy (#131)

## References

- [#126](https://github.com/parhumm/jaan-to/issues/126)
- Sibling skill: `skills/detect-dev/SKILL.md`
- Aggregator: `skills/detect-pack/SKILL.md`
- Downstream: `skills/sec-audit-remediate/SKILL.md`
- OWASP Top 10 2021: https://owasp.org/Top10/
