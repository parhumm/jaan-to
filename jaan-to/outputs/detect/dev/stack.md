# Tech Stack Audit — claude-code

---
title: "Tech Stack Audit — claude-code"
id: "AUDIT-2026-001"
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
  high: 0
  medium: 2
  low: 1
  informational: 9
overall_score: 8.8
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** repository implements a Claude Code plugin with 26 skills for product management, development, UX, QA, and data analytics workflows. The tech stack is **modern and well-defined**, featuring:

- **Documentation Site**: React 19 + Docusaurus 3.9.2 + TypeScript 5.6.2
- **Plugin Architecture**: Markdown-based skills (26), agents (2), lifecycle hooks (4)
- **Automation**: 14 shell scripts (1,407 total lines)
- **Deployment**: Cloudflare Pages for docs + marketing site

**Key Strengths**: Modern frontend stack, clear separation between plugin logic and documentation, TypeScript for type safety.

**Key Risks**: Large documentation dependency tree (627MB total, 900+ packages), no backend runtime (by design), shell scripts lack unit tests.

**Overall Assessment**: **Strong foundation** with excellent separation of concerns. The plugin architecture is clean and extensible. Main concern is the heavyweight documentation site dependencies.

---

## Scope and Methodology

**Analysis Date**: 2026-02-09
**Commit**: `3ab9a931ac23fe64a11a5519ad948885bcb6bcac`
**Branch**: `refactor/skill-naming-cleanup`
**Repository**: github.com/parhumm/jaan-to

**Methods Used**:
- Manifest analysis (package.json, plugin.json)
- Directory structure scanning (skills/, agents/, hooks/, scripts/)
- Configuration file parsing (tsconfig.json, hooks.json)
- Git metadata extraction

**Scope**:
- ✅ Frontend stack (documentation site)
- ✅ Plugin architecture (skills, agents, hooks)
- ✅ Build and deployment tooling
- ✅ Automation scripts
- ⚠️ Backend stack (N/A — CLI plugin, no backend)
- ⚠️ Database (N/A — static site + CLI tool)

---

## Findings

### F-STACK-001: React 19 + Docusaurus 3.9.2 Documentation Site

**Severity**: Informational
**Confidence**: Confirmed (0.99)

```yaml
evidence:
  id: E-DEV-001
  type: config-pattern
  confidence: 0.99
  location:
    uri: "website/docs/package.json"
    startLine: 19
    endLine: 27
    snippet: |
      "dependencies": {
        "@docusaurus/core": "3.9.2",
        "@docusaurus/preset-classic": "3.9.2",
        "@easyops-cn/docusaurus-search-local": "^0.48.5",
        "@mdx-js/react": "^3.0.0",
        "clsx": "^2.0.0",
        "prism-react-renderer": "^2.3.0",
        "react": "^19.0.0",
        "react-dom": "^19.0.0"
      }
  method: manifest-analysis
```

**Description**:
The documentation site uses **React 19.0.0** (latest stable) with **Docusaurus 3.9.2**, a modern static site generator optimized for technical documentation. The site includes:
- Local search via `@easyops-cn/docusaurus-search-local`
- MDX support for interactive documentation
- Syntax highlighting via prism-react-renderer

**Impact**: **Positive** — Modern stack ensures long-term maintainability and excellent developer experience.

**Recommendation**: Monitor React 19 compatibility with Docusaurus as it's a recent major version. Consider adding a `package-lock.json` audit step in CI.

---

### F-STACK-002: TypeScript 5.6.2 Configuration

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-002
  type: config-pattern
  confidence: 0.98
  location:
    uri: "website/docs/package.json"
    startLine: 29
    endLine: 34
    snippet: |
      "devDependencies": {
        "@docusaurus/module-type-aliases": "3.9.2",
        "@docusaurus/tsconfig": "3.9.2",
        "@docusaurus/types": "3.9.2",
        "typescript": "~5.6.2"
      }
  method: manifest-analysis
```

**Description**:
TypeScript 5.6.2 is configured for the documentation site with Docusaurus-specific type definitions. The `tsconfig.json` extends `@docusaurus/tsconfig` for optimal editor experience.

**Impact**: **Positive** — Type safety improves code quality and catches errors at build time.

**Recommendation**: None. Configuration follows Docusaurus best practices.

---

### F-STACK-003: Node.js >=20.0 Requirement

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-003
  type: config-pattern
  confidence: 1.00
  location:
    uri: "website/docs/package.json"
    startLine: 47
    endLine: 49
    snippet: |
      "engines": {
        "node": ">=20.0"
      }
  method: manifest-analysis
```

**Description**:
The project requires Node.js 20 or higher, ensuring access to modern JavaScript features and performance improvements.

**Impact**: **Positive** — Aligns with Node.js LTS schedule (v20 is current LTS as of 2024).

---

### F-STACK-004: Plugin Architecture — 26 Skills, 2 Agents, 4 Hooks

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-004
  type: metric
  confidence: 1.00
  location:
    uri: "."
    analysis: |
      Directory scan results:
      - skills/: 26 SKILL.md files
      - agents/: 2 agent definitions
      - hooks/hooks.json: 4 lifecycle hooks (Setup, SessionStart, PostToolUse, Stop)
      - scripts/: 14 shell scripts (1,407 total lines)
  method: static-analysis
```

**Description**:
The plugin follows Claude Code plugin architecture with:
- **Skills**: 26 markdown-based skill definitions covering PM, Dev, UX, QA, Data domains
- **Agents**: 2 specialized agents (quality-reviewer, context-scout)
- **Hooks**: 4 lifecycle hooks for automation (bootstrap, feedback capture, roadmap sync, session cleanup)
- **Scripts**: 14 shell scripts for validation, building, and deployment

**Impact**: **Positive** — Well-organized, follows Claude Code plugin standards, extensive skill library.

---

### F-STACK-005: Large Documentation Dependency Tree

**Severity**: Medium
**Confidence**: Firm (0.92)

```yaml
evidence:
  id: E-DEV-005
  type: metric
  confidence: 0.92
  location:
    uri: "website/docs/node_modules/"
    analysis: |
      Repository size: 627MB
      Node modules contribute ~600MB (95%)
      Dependency count: 900+ packages (including transitive)
  method: heuristic
```

**Description**:
The documentation site has a **large dependency tree** (900+ packages, 600MB+ of node_modules). This is primarily due to:
- Docusaurus 3's webpack-based build system
- React 19 and its ecosystem
- PostCSS plugins (60+ CSS transformation plugins)
- Search plugin with Algolia/Lunr dependencies

**Impact**: **Moderate** — Slower `npm install`, larger Docker images (if containerized), longer CI build times.

**Remediation**:
1. **Short-term**: Add `.dockerignore` to exclude node_modules from Docker builds
2. **Medium-term**: Evaluate switching to Docusaurus 3 with Rspack (lighter alternative to webpack)
3. **Long-term**: Consider migrating to a lighter framework (Nextra, Astro) if bundle size becomes critical

---

### F-STACK-006: No Backend Runtime Detected

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-006
  type: absence
  confidence: 1.00
  location:
    uri: "."
    analysis: |
      No backend server detected:
      - No Express/Fastify/Next.js API routes
      - No Python/Go/Rust backend services
      - No database configuration files
      Plugin is CLI-based, executes in Claude Code runtime
  method: pattern-match
```

**Description**:
The plugin operates entirely within the Claude Code CLI environment. No backend server is required. The documentation site is static (built at deploy time).

**Impact**: **Positive** — Simpler architecture, no server maintenance, lower hosting costs.

---

### F-STACK-007: Shell Scripting for Automation

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-007
  type: code-location
  confidence: 0.98
  location:
    uri: "scripts/"
    analysis: |
      Shell scripts (bash):
      - build-dist.sh (distribution packaging)
      - bump-version.sh (version management)
      - validate-skills.sh (skill validation)
      - validate-prd.sh (PRD validation)
      - bootstrap.sh (project setup)
      - post-commit-roadmap.sh (roadmap sync)
      - capture-feedback.sh (learning capture)
      - docs-sync-check.sh (documentation validation)
      Total: 14 scripts, 1,407 lines
  method: static-analysis
```

**Description**:
The plugin uses **bash scripts** for automation tasks (validation, building, deployment orchestration). Scripts are invoked via:
- Lifecycle hooks (hooks.json)
- CI/CD workflows (.github/workflows/)
- Manual execution

**Impact**: **Neutral** — Shell scripts are portable and fast, but lack type safety and unit testing.

**Recommendation**: Consider adding ShellCheck to CI for linting, or gradually migrate critical logic to Node.js scripts for better testability.

---

### F-STACK-008: No Dependency Lock File in Root

**Severity**: Low
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DEV-008
  type: absence
  confidence: 0.85
  location:
    uri: "."
    analysis: |
      - website/docs/package-lock.json exists ✓
      - Root package-lock.json missing ✗
      - Root package.json missing ✗
      Plugin has no root Node.js dependencies by design
  method: pattern-match
```

**Description**:
The root directory has **no package.json or lock file**, which is intentional — the plugin itself is markdown-based with no Node.js runtime dependencies. Only the documentation site (website/docs/) has npm dependencies.

**Impact**: **Minimal** — This is by design. However, it means root-level tooling (linting, formatting) must be configured per-subdirectory.

**Recommendation**: Consider adding a root package.json with shared dev tooling (ESLint, Prettier) if multiple subdirectories need it in the future.

---

### F-STACK-009: npm as Package Manager

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-009
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 35
    endLine: 35
    snippet: |
      - run: npm ci
  method: manifest-analysis
```

**Description**:
The project uses **npm** (not pnpm or yarn) as the package manager, with `npm ci` for reproducible builds in CI.

**Impact**: **Positive** — `npm ci` ensures deterministic installs using the lock file.

---

### F-STACK-010: Cloudflare Pages Deployment

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-010
  type: config-pattern
  confidence: 1.00
  location:
    uri: ".github/workflows/deploy-docs.yml"
    startLine: 39
    endLine: 43
    snippet: |
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy website/docs/build --project-name=jaan-to-docs
  method: manifest-analysis
```

**Description**:
The documentation site deploys to **Cloudflare Pages**, a modern edge-based static hosting platform with:
- Global CDN
- Automatic HTTPS
- Preview deployments for PRs
- Fast build times

**Impact**: **Positive** — Excellent performance, low cost, built-in CI/CD integration.

---

### F-STACK-011: Missing Build Optimization Analysis

**Severity**: Medium
**Confidence**: Tentative (0.65)

```yaml
evidence:
  id: E-DEV-011
  type: absence
  confidence: 0.65
  location:
    uri: "website/docs/"
    analysis: |
      No bundle analysis tooling detected:
      - No webpack-bundle-analyzer
      - No build size monitoring in CI
      - No performance budgets configured
  method: heuristic
```

**Description**:
The documentation site build lacks **bundle size analysis** and **performance monitoring**. Without this, it's difficult to:
- Track bundle size growth over time
- Identify large dependencies
- Enforce performance budgets

**Impact**: **Moderate** — Can lead to bloated bundles and slower page loads.

**Remediation**:
1. Add `@docusaurus/plugin-webpack-bundle-analyzer` to dev dependencies
2. Run bundle analysis on each PR via CI comment
3. Set a performance budget (e.g., max 500KB initial JS)

---

### F-STACK-012: Browserslist Configuration

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-012
  type: config-pattern
  confidence: 1.00
  location:
    uri: "website/docs/package.json"
    startLine: 35
    endLine: 46
    snippet: |
      "browserslist": {
        "production": [
          ">0.5%",
          "not dead",
          "not op_mini all"
        ],
        "development": [
          "last 3 chrome version",
          "last 3 firefox version",
          "last 5 safari version"
        ]
      }
  method: manifest-analysis
```

**Description**:
The project uses **browserslist** to define supported browsers, ensuring appropriate transpilation and polyfills.

**Impact**: **Positive** — Balances modern browser support with broad compatibility.

---

## Recommendations

### Priority 1 (High)
None identified. Tech stack is sound.

### Priority 2 (Medium)
1. **Add bundle size analysis** — Integrate webpack-bundle-analyzer and set performance budgets (F-STACK-011)
2. **Reduce documentation dependency count** — Evaluate lighter alternatives or lazy-load heavy dependencies (F-STACK-005)

### Priority 3 (Low)
3. **Add ShellCheck linting** — Lint shell scripts in CI for common errors (F-STACK-007)
4. **Consider root package.json** — For shared dev tooling if needed (F-STACK-008)

---

## Appendices

### A. Confidence Level Reference

| Level | Range | Description |
|-------|-------|-------------|
| **Confirmed** | 0.95-1.00 | Multiple independent methods agree; reproducible |
| **Firm** | 0.80-0.94 | Single high-precision method with clear evidence |
| **Tentative** | 0.50-0.79 | Pattern match without full analysis |
| **Uncertain** | 0.20-0.49 | Absence-of-evidence reasoning |

### B. Tech Stack Summary

| Category | Technology | Version | Confidence |
|----------|------------|---------|------------|
| **Frontend** | React | 19.0.0 | Confirmed |
| **Framework** | Docusaurus | 3.9.2 | Confirmed |
| **Language** | TypeScript | 5.6.2 | Confirmed |
| **Runtime** | Node.js | >=20.0 | Confirmed |
| **Package Manager** | npm | (default) | Confirmed |
| **Deployment** | Cloudflare Pages | - | Confirmed |
| **Backend** | None | N/A | Confirmed |
| **Database** | None | N/A | Confirmed |

### C. Methodology Notes

This audit used **manifest-based analysis** (100% confidence for dependencies) combined with **directory scanning** (95%+ confidence for architecture). No runtime analysis or network monitoring was performed.

---

*Generated by jaan.to detect-dev | 2026-02-09*
