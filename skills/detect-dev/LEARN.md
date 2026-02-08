# Lessons: detect-dev

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before auditing to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve detection quality:

- Ask "Is this a monorepo?" when multiple package.json files found at different depths
- Ask about cloud provider when CI/CD detected but no infrastructure config files found
- Confirm "Which packages should I focus on?" in large monorepos (>10 packages)
- Check if docker-compose services are dev-only vs production (look for `profiles:` or file naming)

## Edge Cases

Special cases to check and handle:

- **Migration in progress**: Multiple versions of same framework detected (e.g., React 17 + React 18) — flag as migration, report both versions with separate evidence
- **Test vs prod dependencies**: devDependencies are dev tools, not production stack. Don't list Jest as a "framework" — it goes under Testing findings
- **Example/demo directories**: Ignore files in `examples/`, `samples/`, `demo/`, `template/` directories — these are not the project's actual stack
- **Lockfile-only deps**: Don't extract versions from lockfiles (package-lock.json, yarn.lock) — they contain transitive deps that aren't part of the stack
- **Docker dev vs prod**: `docker-compose.override.yml` may have different services than base. Prefer base compose file for evidence
- **Nested configs**: Monorepo packages may have their own tsconfig, eslint configs — scan subdirectories
- **Git submodules**: Don't scan submodule directories as part of the main project stack

## Workflow

Process improvements learned from past runs:

- Scan docker-compose.yml first — it's the most reliable source for databases and services
- For monorepos: detect the monorepo tool first (nx, turbo, lerna, pnpm), then scan individual packages
- Group detections by confidence before presenting — high confidence items first builds trust
- Read the existing context files BEFORE scanning — knowing what's already documented saves work
- Run CI/CD security checks in a dedicated pass after pipeline detection — don't mix with general detection

## Common Mistakes

Things to avoid based on past feedback:

- Don't auto-fill monitoring/observability tools with low confidence — rarely in config files
- Don't detect framework version from lockfile comments or transitive dependencies
- Don't assume Kubernetes from kubectl mentions in CI scripts alone
- Don't list the seed template defaults (Python 3.11, FastAPI 0.104, etc.) as "detected" — those are placeholders
- Don't report databases from test fixtures or mock data as production databases
- Don't present absence of security features as Critical severity — use appropriate severity with Uncertain confidence
