# sec-audit-remediate — Reference Material

> Extracted reference tables, code templates, and patterns for the `sec-audit-remediate` skill.
> This file is loaded by `sec-audit-remediate` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## CWE-to-Fix Category Mapping

| CWE Category | Fix Strategy | Complexity | Auto-fixable |
|-------------|-------------|-----------|-------------|
| CWE-79 (XSS) | DOMPurify sanitization / output encoding | Low | Yes |
| CWE-89 (SQL Injection) | Parameterized queries / ORM safe patterns | Medium | Partial |
| CWE-78 (Command Injection) | execFile with array args / input validation | Medium | Yes |
| CWE-918 (SSRF) | URL allowlist validation / private IP blocking | Medium | Yes |
| CWE-327 (Weak Crypto) | Replace algorithm (md5/sha1 -> sha256+) | Low | Yes |
| CWE-352 (CSRF) | CSRF middleware / token validation | Medium | Yes |
| CWE-502 (Deserialization) | Zod/schema validation | Medium | Partial |
| CWE-1321 (Prototype Pollution) | Safe merge / Object.create(null) | Low | Yes |
| CWE-611 (XXE) | Disable external entities in parser config | Low | Yes |
| CWE-862 (Missing AuthZ) | Auth middleware / RBAC guards | High | No (needs design) |
| CWE-798 (Hardcoded Credentials) | Environment variable extraction | Low | Partial |

Reference: `${CLAUDE_PLUGIN_ROOT}/docs/research/73-dev-sarif-security-remediation-automation.md` section "CWE-to-Remediation Mapping Patterns".

## Triage Matrix

| Confidence \ Severity | Critical | High | Medium | Low |
|----------------------|----------|------|--------|-----|
| Confirmed/Firm | Auto-fix + test | Auto-fix + test | Fix + test | Fix, batch |
| Tentative | Fix + escalate | Fix + review note | Queue for review | Document only |
| Uncertain | Escalate only | Log recommendation | Skip | Skip |

## Per-CWE Fix Generation Patterns

**CWE-79 (XSS)**: Generate sanitization wrapper
- Import DOMPurify or equivalent
- Wrap vulnerable output points with sanitization
- Handle both stored XSS and reflected XSS patterns

**CWE-89 (SQL Injection)**: Generate parameterized query replacement
- Replace string concatenation with parameterized queries
- Use ORM safe patterns (Prisma `.findMany()`, Drizzle tagged templates)
- Never use `$queryRaw` with interpolation

**CWE-78 (Command Injection)**: Generate safe execution wrapper
- Replace `exec()` with `execFile()` and array arguments
- Add input validation for command arguments
- Block shell metacharacters

**CWE-918 (SSRF)**: Generate URL validation utility
- Validate against allowlist of permitted hosts
- Block private IP ranges (169.254.x.x, 10.x.x.x, 127.x.x.x, etc.)
- Enforce HTTPS-only for external requests

**CWE-327 (Weak Crypto)**: Generate algorithm replacement
- Replace `md5`/`sha1` with `sha256` or stronger
- Replace `DES`/`RC4` with `aes-256-gcm`
- Use `crypto.randomBytes()` for secure randomness

**CWE-352 (CSRF)**: Generate CSRF middleware
- Add CSRF token validation middleware
- Configure double-submit cookie pattern
- Handle SPA vs server-rendered architectures
- Reference: `${CLAUDE_PLUGIN_ROOT}/docs/research/72-dev-secure-backend-scaffold-hardening.md` section "CSRF Protection Patterns"

**CWE-502 (Deserialization)**: Generate schema validation wrapper
- Add Zod or JSON Schema validation before processing untrusted data
- Reject unexpected fields and types

**CWE-1321 (Prototype Pollution)**: Generate safe merge utility
- Replace vulnerable deep merge/clone with safe version
- Block `__proto__`, `constructor`, `prototype` keys

**CWE-862 (Missing Authorization)**: Generate auth middleware
- Add route-level authorization guards
- Implement RBAC decorator pattern
- Reference: `${CLAUDE_PLUGIN_ROOT}/docs/research/72-dev-secure-backend-scaffold-hardening.md` section "Security-First Code Generation Patterns"

## CWE-Specific Test Patterns

**CWE-79 (XSS)**: Test with script tags, event handlers, javascript: URIs, encoded payloads
**CWE-89 (SQL Injection)**: Test with OR 1=1, UNION SELECT, DROP TABLE, comment injection
**CWE-78 (Command Injection)**: Test with semicolons, pipes, backticks, $() subshells
**CWE-918 (SSRF)**: Test with metadata endpoints (169.254.169.254), localhost, file:// protocol
**CWE-327 (Weak Crypto)**: Verify source code does not contain weak algorithm references
**CWE-352 (CSRF)**: Test requests without CSRF token are rejected, with token are accepted
