# Coding Standards Audit — claude-code

---
title: "Coding Standards Audit — claude-code"
id: "AUDIT-2026-003"
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
  informational: 2
overall_score: 8.5
lifecycle_phase: post-build
---

## Executive Summary

Coding standards in the **claude-code** plugin are **partially enforced**:

**Strengths**:
- TypeScript configured for documentation site
- JSON schema validation via scripts
- EditorConfig in dependencies (not root)

**Gaps**:
- No root-level linting configuration
- Shell scripts lack ShellCheck linting
- No Prettier/formatting enforcement

**Assessment**: **Adequate** for a markdown-based plugin, but could benefit from shell script linting and consistent formatting rules.

---

## Scope and Methodology

**Analysis Methods**:
- Configuration file scanning (.eslintrc, .prettierrc, editorconfig)
- Validation script inspection
- TypeScript configuration analysis

---

## Findings

### F-STD-001: TypeScript Configuration (Docs Site Only)

**Severity**: Informational
**Confidence**: Confirmed (0.99)

```yaml
evidence:
  id: E-DEV-022
  type: config-pattern
  confidence: 0.99
  location:
    uri: "website/docs/tsconfig.json"
    startLine: 1
    endLine: 8
    snippet: |
      {
        "extends": "@docusaurus/tsconfig",
        "compilerOptions": {
          "baseUrl": "."
        },
        "exclude": [".docusaurus", "build"]
      }
  method: manifest-analysis
```

**Description**: TypeScript is configured for the documentation site, extending Docusaurus defaults. Provides type checking and editor IntelliSense.

**Impact**: **Positive** — Catches type errors in docs site code.

---

### F-STD-002: JSON Validation Scripts

**Severity**: Informational
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-023
  type: code-location
  confidence: 0.95
  location:
    uri: "scripts/validate-skills.sh"
    analysis: |
      Validation scripts enforce:
      - Skill description character limits
      - Version consistency across plugin.json, marketplace.json
      - CHANGELOG entry existence
      - No component path declarations in plugin.json (causes failures)
  method: static-analysis
```

**Description**: Shell scripts validate JSON structure and plugin requirements via CI (`.github/workflows/release-check.yml`).

**Impact**: **Positive** — Prevents malformed plugin manifests from being released.

---

### F-STD-003: No Root Linting Configuration

**Severity**: Medium
**Confidence**: Firm (0.85)

```yaml
evidence:
  id: E-DEV-024
  type: absence
  confidence: 0.85
  location:
    uri: "."
    analysis: |
      Root directory missing:
      - .eslintrc / eslint.config.js
      - .prettierrc / prettier.config.js
      - .editorconfig (present in node_modules, not root)

      Only documentation site (website/docs/) has inherited configs
      from Docusaurus dependencies.
  method: pattern-match
```

**Description**: The root directory lacks **linting and formatting configuration**. This means:
- Shell scripts are not linted (no ShellCheck)
- Markdown files are not formatted consistently
- JSON/YAML files lack validation

**Impact**: **Moderate** — Can lead to style inconsistencies and shell script bugs.

**Remediation**:
1. Add `.editorconfig` to root for basic formatting (indent size, line endings)
2. Add ShellCheck to CI for shell script linting
3. Consider adding markdownlint for skill documentation consistency

---

### F-STD-004: No Shell Script Linting

**Severity**: Medium
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-025
  type: absence
  confidence: 0.95
  location:
    uri: ".github/workflows/"
    analysis: |
      GitHub Actions workflows do not run ShellCheck.
      14 shell scripts (1,407 lines) are unvalidated.

      Common shell script issues ShellCheck catches:
      - Unquoted variables
      - Missing error handling
      - Unsafe temp file creation
  method: pattern-match
```

**Description**: The 14 shell scripts (1,407 lines) lack **automated linting** via ShellCheck, a static analysis tool for shell scripts.

**Impact**: **Moderate** — Risk of shell script bugs (quoting errors, unsafe patterns).

**Remediation**:
```yaml
# Add to .github/workflows/release-check.yml
- name: Lint shell scripts
  run: |
    sudo apt-get install -y shellcheck
    find scripts -name "*.sh" -exec shellcheck {} +
```

---

### F-STD-005: Mixed Line Ending Configuration

**Severity**: Low
**Confidence**: Tentative (0.70)

```yaml
evidence:
  id: E-DEV-026
  type: config-pattern
  confidence: 0.70
  location:
    uri: ".gitattributes"
    startLine: 1
    endLine: 1
    snippet: |
      *.sh text eol=lf
  method: manifest-analysis
```

**Description**: `.gitattributes` enforces **LF line endings** for shell scripts, which is good. However, no EditorConfig at root means editors may not automatically apply this.

**Impact**: **Minor** — Developers on Windows may commit CRLF line endings for non-.sh files.

**Remediation**: Add `.editorconfig`:
```ini
root = true

[*]
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
max_line_length = 100

[*.{json,yml,yaml}]
indent_size = 2
```

---

## Recommendations

### Priority 1 (High)
None identified.

### Priority 2 (Medium)
1. **Add ShellCheck linting** — Lint 14 shell scripts in CI (F-STD-004)
2. **Add root EditorConfig** — Ensure consistent formatting across editors (F-STD-003)

### Priority 3 (Low)
3. **Add markdownlint** — Enforce consistent markdown style in skill definitions (F-STD-003)

---

*Generated by jaan.to detect-dev | 2026-02-09*
