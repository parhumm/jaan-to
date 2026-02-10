# Lessons: sec-audit-remediate

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:sec-audit-remediate.learn.md`

## Better Questions
<!-- Questions that improve input quality -->

- Ask which SAST tool produced the findings (CodeQL, Semgrep, Snyk, manual audit) -- fix strategies differ by tool precision
- Ask whether the project has an existing test framework preference (vitest, jest, mocha) for regression test generation
- Ask about the project's deployment model (serverless, container, traditional) as it affects middleware-based fixes
- Clarify if the findings are from a fresh scan or a baseline diff -- baseline findings may have compensating controls already

## Edge Cases
<!-- Special cases to check -->

- Findings in vendored/third-party code should not be auto-fixed (flag for dependency upgrade instead)
- Findings in test files are typically false positives -- verify before generating fixes
- Multiple findings in the same file may conflict when fixes are applied -- apply bottom-to-top to preserve line numbers
- SARIF output from different tools may report the same vulnerability with different rule IDs -- deduplicate by CWE + file location
- Some CWE categories (CWE-862 Missing Authorization) cannot be reliably auto-fixed -- always flag for human design review

## Workflow
<!-- Process improvements -->

- Always parse findings sorted by severity (Critical first) to ensure highest-risk items get attention
- Generate fix files before test files -- tests import from fix modules
- For TypeScript projects, verify fix files compile before writing (check imports, types)
- When generating CSRF fixes, check if the project uses SPA or server-rendered architecture -- patterns differ significantly
- Cross-reference with tech.md to use the correct ORM, framework, and test runner in generated code

## Common Mistakes
<!-- Pitfalls to avoid -->

- Do not generate fixes that use packages not in the project's dependency tree without flagging them as new dependencies
- Do not assume all findings are in TypeScript -- check file extensions and adjust generated code language
- Do not generate fixes for CWE-862 (Missing Authorization) without explicit user design input -- these require architectural decisions
- Do not write regression tests that depend on a running database or external service -- tests should be unit-level with mocks
- Do not apply text-based search-and-replace for SQL injection fixes -- the query structure varies; use context-aware patterns
