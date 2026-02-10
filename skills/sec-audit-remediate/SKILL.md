---
name: sec-audit-remediate
description: Generate security fixes from detect-dev findings with regression tests.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/sec/remediate/**), Task, WebSearch, Edit(jaan-to/config/settings.yaml)
argument-hint: "[detect-dev-output] [backend-scaffold | frontend-scaffold]"
---

# sec-audit-remediate

> Generate targeted security fixes from detect-dev SARIF findings with regression tests.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:sec-audit-remediate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:sec-audit-remediate.template.md` - Output template
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#patterns`
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- `${CLAUDE_PLUGIN_ROOT}/docs/research/73-dev-sarif-security-remediation-automation.md` - SARIF 2.1.0 parsing, CWE-to-fix mapping, remediation patterns
- `${CLAUDE_PLUGIN_ROOT}/docs/research/72-dev-secure-backend-scaffold-hardening.md` - jose JWT, httpOnly cookies, CSRF, rate limiting, OWASP Top 10

**Output path**: `$JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/`

**DAG position**: detect-dev + backend-scaffold + frontend-scaffold --> sec-audit-remediate --> devops-infra-scaffold (security in CI)

## Input

**Arguments**: $ARGUMENTS

Parse arguments to identify:
1. **detect-dev output path** -- Path to detect-dev SARIF/findings output (e.g., `$JAAN_OUTPUTS_DIR/detect/dev/security.md` or a `.sarif` file)
2. **scaffold type** -- `backend-scaffold` or `frontend-scaffold` (determines which code to cross-reference for fixes)

If no arguments provided, search for detect-dev outputs:
- Glob: `$JAAN_OUTPUTS_DIR/detect/dev/security*.md`
- Glob: `$JAAN_OUTPUTS_DIR/detect/dev/summary*.md`
- If not found, ask user for the path.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** -- Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:sec-audit-remediate.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for relevant fixes

### Language Settings

Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_sec-audit-remediate`

> **Language exception**: Generated code output (fix files, test files, code blocks, schemas) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Parsing SARIF findings and mapping to CWE categories
- Determining root cause analysis for each finding
- Planning fix strategies by vulnerability type
- Assessing fix complexity and regression risk

## Step 1: Parse Detect-Dev Output

Read the detect-dev output file(s) provided in $ARGUMENTS.

### 1.1: Extract Findings

For each finding, extract:
- **Rule ID** / **Finding ID** (e.g., E-DEV-001)
- **Severity**: Critical / High / Medium / Low / Info
- **Confidence**: Confirmed / Firm / Tentative / Uncertain
- **CWE ID(s)**: e.g., CWE-79, CWE-89, CWE-352
- **File path** and **line range**: Where the vulnerability exists
- **Description**: What the vulnerability is
- **Evidence block**: SARIF evidence or detect-dev evidence
- **OWASP Top 10 mapping**: Which OWASP category it falls under

### 1.2: Sort by Severity

Sort all findings by severity (Critical first, then High, Medium, Low):

```
FINDINGS PARSED
---------------
Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}

ID          Severity    CWE         File                    Description
E-DEV-001   Critical    CWE-89      src/api/users.ts:42     SQL injection in query
E-DEV-003   High        CWE-79      src/views/profile.tsx:18 XSS in user content
...
```

### 1.3: Map Findings to CWE Fix Categories

Group findings by CWE category and assign fix strategy:

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

## Step 2: Cross-Reference with Scaffold Code

If scaffold output is provided (backend-scaffold or frontend-scaffold):

1. **Read scaffold code files** that correspond to finding locations
2. **Identify vulnerable code patterns** in the scaffold output
3. **Map each finding to the specific scaffold file and code block** that needs fixing
4. **Note any findings that are NOT in scaffold code** (pre-existing vulnerabilities vs scaffold-introduced)

If no scaffold reference, work directly with finding file paths.

## Step 3: Generate Remediation Plan

For each finding, determine:

| Field | Description |
|-------|-------------|
| Finding ID | From detect-dev output |
| Fix Type | Code replacement / New middleware / Config change / Dependency update |
| Fix File | Path to the fix file to generate |
| Test File | Path to the regression test to generate |
| Dependencies | New packages needed (e.g., dompurify, csurf) |
| Breaking Changes | Whether the fix changes API behavior |
| Complexity | Low / Medium / High |

### Triage Matrix

Apply the severity/confidence triage matrix:

| Confidence \ Severity | Critical | High | Medium | Low |
|----------------------|----------|------|--------|-----|
| Confirmed/Firm | Auto-fix + test | Auto-fix + test | Fix + test | Fix, batch |
| Tentative | Fix + escalate | Fix + review note | Queue for review | Document only |
| Uncertain | Escalate only | Log recommendation | Skip | Skip |

## Step 4: Ask User Which Findings to Remediate

Present the remediation plan and ask:

```
REMEDIATION PLAN
----------------
Total findings: {n}
  Auto-fix eligible: {n} (Critical/High + Confirmed/Firm confidence)
  Manual review needed: {n} (Medium confidence or complex fixes)
  Skipped: {n} (Low confidence or informational)

FINDINGS TO REMEDIATE:

[x] E-DEV-001  Critical  CWE-89   SQL injection       -> parameterized query    [auto-fix]
[x] E-DEV-003  High      CWE-79   XSS vulnerability   -> DOMPurify sanitize     [auto-fix]
[x] E-DEV-007  High      CWE-352  Missing CSRF         -> csrf middleware        [auto-fix]
[x] E-DEV-012  High      CWE-327  Weak hash (MD5)     -> SHA-256 replacement    [auto-fix]
[ ] E-DEV-015  Medium    CWE-862  Missing auth check   -> RBAC guard            [needs design]
[ ] E-DEV-018  Low       CWE-798  Hardcoded API key   -> env variable           [manual]

New dependencies needed: dompurify, @types/dompurify, csurf
Estimated fix files: {n}
Estimated test files: {n}
```

> "Which findings should I remediate? [all-auto / select / all]"

- **all-auto**: Fix only auto-fix eligible findings (default)
- **select**: Let user pick specific findings
- **all**: Attempt all findings including manual-review ones

---

# HARD STOP - Human Review Gate

Present complete remediation summary:

```
REMEDIATION SUMMARY
-------------------
Findings to fix: {n}
Fix files to generate: {n}
Test files to generate: {n}
New dependencies: {list}
Breaking changes: {yes/no, details}

OUTPUT STRUCTURE:
  $JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/
    {id}-{slug}.md                        <- Remediation report
    {id}-{slug}-readme.md                 <- Integration instructions
    fixes/
      auth-middleware.ts                   <- Fix: missing auth
      rate-limiter.ts                     <- Fix: rate limiting
      csrf-protection.ts                  <- Fix: CSRF
      sanitize-input.ts                   <- Fix: XSS/injection
      ...
    tests/
      auth-security.test.ts              <- Test: auth fixes
      rate-limit.test.ts                 <- Test: rate limiting
      csrf.test.ts                       <- Test: CSRF
      xss-prevention.test.ts             <- Test: XSS
      ...
```

> "Proceed with generating {n} fix files and {n} test files? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 5: Generate ID and Folder Structure

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate next ID and output paths:
```bash
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/sec/remediate"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
```

3. Create subdirectories:
```bash
mkdir -p "$OUTPUT_FOLDER/fixes"
mkdir -p "$OUTPUT_FOLDER/tests"
```

4. Preview for user:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/sec/remediate/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{slug}.md
> - Fixes dir: fixes/
> - Tests dir: tests/

## Step 6: Generate Fix Files

For each finding selected for remediation, generate a targeted fix file in `fixes/`.

### Fix Generation by CWE Category

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

### Fix File Naming Convention

Name fix files descriptively based on the vulnerability type:
- `{vulnerability-type}.ts` (e.g., `sql-injection-fix.ts`, `csrf-protection.ts`, `xss-sanitizer.ts`)
- If multiple findings share the same CWE, generate one consolidated fix file

### Fix File Structure

Each fix file includes:
1. File header comment with finding ID(s) and CWE reference
2. Imports (including any new dependencies)
3. The fix code (replacement function, middleware, utility)
4. Usage example as JSDoc comment
5. Integration notes as comments

## Step 7: Generate Regression Tests

For each Critical and High finding that was fixed, generate a regression test in `tests/`.

### Test Generation Strategy

For each fix, generate tests covering:

1. **Attack-replay tests** -- Reproduce the original attack vector and verify it is blocked
2. **Negative tests** -- Verify malicious input is rejected or sanitized
3. **Positive tests** -- Verify legitimate input still works after the fix
4. **Boundary tests** -- Edge cases around input limits and encoding

Reference: `${CLAUDE_PLUGIN_ROOT}/docs/research/73-dev-sarif-security-remediation-automation.md` section "Regression Test Generation for Security Fixes".

### Test File Naming Convention

- `{vulnerability-type}.test.ts` (e.g., `sql-injection.test.ts`, `xss-prevention.test.ts`)
- Match test file name to corresponding fix file name

### Test File Structure

Each test file includes:
1. Import from the fix file
2. Describe block referencing finding ID and CWE
3. Attack payload arrays (XSS payloads, SQL injection strings, SSRF URLs, etc.)
4. "should block malicious input" tests with payload iteration
5. "should allow legitimate input" tests with safe data
6. Comment linking back to finding ID for traceability

### CWE-Specific Test Patterns

**CWE-79 (XSS)**: Test with script tags, event handlers, javascript: URIs, encoded payloads
**CWE-89 (SQL Injection)**: Test with OR 1=1, UNION SELECT, DROP TABLE, comment injection
**CWE-78 (Command Injection)**: Test with semicolons, pipes, backticks, $() subshells
**CWE-918 (SSRF)**: Test with metadata endpoints (169.254.169.254), localhost, file:// protocol
**CWE-327 (Weak Crypto)**: Verify source code does not contain weak algorithm references
**CWE-352 (CSRF)**: Test requests without CSRF token are rejected, with token are accepted

## Step 8: Generate Remediation Report

Write the main report file: `{id}-{slug}.md`

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:sec-audit-remediate.template.md`

Fill template variables:
- `{{title}}` - "Security Remediation Report" + project name
- `{{date}}` - Current date (YYYY-MM-DD)
- `{{executive_summary}}` - BLUF of findings fixed, risk reduction estimate
- `{{findings_table}}` - All findings with status (fixed/pending/skipped)
- `{{fixes_generated}}` - List of fix files with descriptions
- `{{tests_generated}}` - List of test files with descriptions
- `{{new_dependencies}}` - Dependencies to install
- `{{risk_reduction}}` - Estimated risk reduction percentage
- `{{remaining_findings}}` - Findings not addressed and why

## Step 9: Generate Integration Instructions

Write the readme file: `{id}-{slug}-readme.md`

Include:
1. **Prerequisites** -- Dependencies to install
2. **Fix Application Order** -- Which fixes to apply first (auth before route-level)
3. **Per-Fix Instructions** -- For each fix file:
   - What it does
   - Where to integrate it (which file/module)
   - Code snippet showing integration point
   - Before/after comparison
4. **Test Execution** -- How to run the regression tests
5. **CI Integration** -- How to add security tests to CI pipeline
6. **Verification Checklist** -- Steps to verify each fix is working
7. **Rollback Plan** -- How to revert each fix if issues arise

## Step 10: Quality Check

Before writing, verify:

**Coverage**:
- [ ] Every Critical finding has a fix file AND a test file
- [ ] Every High finding has a fix file AND a test file
- [ ] Medium findings have fix files (tests optional)
- [ ] No finding is left without a status (fixed/pending/skipped with reason)

**Fix Quality**:
- [ ] Fix files compile (valid TypeScript/JavaScript syntax)
- [ ] No hardcoded credentials or secrets in fix files
- [ ] Fixes use the project's tech stack (from tech.md if available)
- [ ] Fixes follow the project's coding patterns (from scaffold if available)
- [ ] Fix files include proper imports

**Test Quality**:
- [ ] Tests include both positive (safe input) and negative (attack payload) cases
- [ ] Test file names match fix file names
- [ ] Tests reference finding IDs for traceability
- [ ] Attack payloads cover OWASP test vectors

**Report Quality**:
- [ ] Executive Summary present
- [ ] All findings listed with status
- [ ] Risk reduction estimate provided
- [ ] Integration instructions are actionable

**Output Structure**:
- [ ] ID generated using scripts/lib/id-generator.sh
- [ ] Folder created: sec/remediate/{id}-{slug}/
- [ ] Main file named: {id}-{slug}.md
- [ ] Subdirectories: fixes/, tests/
- [ ] Index updated

If any check fails, revise before preview.

## Step 11: Preview and Write

Show file listing with sizes:

```
OUTPUT FILES
------------
$JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/
  {id}-{slug}.md                    (remediation report)
  {id}-{slug}-readme.md             (integration instructions)
  fixes/
    {fix-file-1}.ts                 (CWE-89: SQL injection fix)
    {fix-file-2}.ts                 (CWE-79: XSS sanitization)
    ...
  tests/
    {test-file-1}.test.ts           (SQL injection regression)
    {test-file-2}.test.ts           (XSS prevention regression)
    ...

Total: {n} files
```

> "Write all {n} files to $JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/? [y/n]"

If approved:

1. Create output folder and subdirectories
2. Write all fix files to `fixes/`
3. Write all test files to `tests/`
4. Write remediation report
5. Write integration instructions

6. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Title}" \
  "{Executive summary text}"
```

7. Confirm:
> Output written to: $JAAN_OUTPUTS_DIR/sec/remediate/{NEXT_ID}-{slug}/
> Index updated: $JAAN_OUTPUTS_DIR/sec/remediate/README.md
> Fix files: {n} | Test files: {n} | Report: 1 | Readme: 1

## Step 12: Capture Feedback

> "Any feedback on the security remediation? [y/n]"

If yes:
> "[1] Fix now  [2] Learn for future  [3] Both"

- **Option 1**: Update output, re-preview, re-write
- **Option 2**: Run `/jaan-to:learn-add sec-audit-remediate "{feedback}"`
- **Option 3**: Do both

---

## Definition of Done

- [ ] Detect-dev output parsed and findings extracted
- [ ] Findings sorted by severity with CWE mapping
- [ ] Remediation plan generated and user approved scope
- [ ] Fix files generated for all selected findings
- [ ] Regression tests generated for all Critical and High findings
- [ ] Every Critical finding has both fix AND test
- [ ] Remediation report written with executive summary
- [ ] Integration instructions written with per-fix guidance
- [ ] Output written to correct path with ID-based folder structure
- [ ] Index updated
- [ ] User approved final result
