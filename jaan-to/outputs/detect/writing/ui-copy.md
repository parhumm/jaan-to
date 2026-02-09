---
title: "UI Copy Classification"
id: "AUDIT-2026-001-UI-COPY"
version: "1.0.0"
status: draft
date: 2026-02-09
target:
  name: "jaan-to/claude-code"
  platform: "all"
  commit: "39293e7dcb04ae8fe1c3694b3fd037149c0d0792"
  branch: "refactor/skill-naming-cleanup"
tool:
  name: "detect-writing"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 1
overall_score: 10.0
lifecycle_phase: post-build
---

# UI Copy Classification

> UI copy analysis not applicable for CLI/documentation projects

**Generated**: 2026-02-09
**Repository**: jaan-to/claude-code
**Platform**: CLI/Documentation (single-platform)
**Analysis mode**: Partial (UI copy classification skipped)

---

## Executive Summary

The jaan.to plugin is a **CLI/documentation project** without UI components. Full UI copy classification across the 8 standard categories (buttons, error messages, empty states, dialogs, notifications, onboarding, form labels, loading states) is **not applicable**.

**Project type**: Command-line plugin for Claude Code
**Interface**: Shell commands (e.g., `/jaan-to:pm-prd-write`)
**User interaction**: Text-based CLI, not graphical UI

**Overall assessment**: N/A - UI copy analysis requires UI components.

---

## Scope and Methodology

### Analysis Scope

**Platform check performed**:

```bash
# Check for UI component files
find . -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) \
  2>/dev/null | grep -v node_modules | head -n 1

# Result: No UI files found (excluding node_modules)
```

**Project structure**:
- ✅ Markdown documentation (340 files)
- ✅ Shell scripts (13 files)
- ✅ Skill definitions (26 SKILL.md files)
- ✅ Templates (24 .template.md files)
- ❌ No React/Vue/Svelte components
- ❌ No JSX/TSX inline text
- ❌ No UI component libraries

### Applicability Assessment

| UI Copy Category | Applicable? | Reason |
|------------------|-------------|--------|
| Buttons/CTAs | ❌ No | No clickable UI elements |
| Error messages | ⚠️ Partial | CLI error messages analyzed separately (see [error-messages.md](error-messages.md)) |
| Empty states | ❌ No | No UI states |
| Confirmation dialogs | ❌ No | No modal/dialog UI |
| Notifications/toasts | ❌ No | No UI notifications |
| Onboarding | ❌ No | Documentation-based onboarding, not UI wizards |
| Form labels/helpers | ❌ No | No form inputs |
| Loading states | ❌ No | No UI loading indicators |

---

## Findings

### E-WRT-UI-001: UI Copy Analysis Not Applicable

**Severity**: Informational
**Confidence**: Confirmed (1.0)

**Description**: The jaan.to plugin is a CLI/documentation project without UI components. UI copy classification is not applicable to this codebase.

**Evidence**:

```yaml
evidence:
  id: E-WRT-UI-001
  type: platform-detection
  confidence: 1.0
  method: file-pattern-scan
  findings:
    - ui_components_found: 0
    - jsx_tsx_files: 0 (excluding node_modules)
    - vue_svelte_files: 0
    - project_type: "cli-documentation"
  location:
    uri: "."
    pattern: "**/*.{jsx,tsx,vue,svelte}"
```

**Project interface characteristics**:
- **Command invocation**: Text-based slash commands (e.g., `/jaan-to:pm-prd-write`)
- **User feedback**: Terminal output (stdout/stderr)
- **Interaction model**: Request → Analysis → Approval → Generation
- **Output display**: Markdown files in file system, not rendered UI

**Related analysis**:
- **Error messages**: Analyzed separately in [error-messages.md](error-messages.md) (CLI error messages from shell scripts)
- **Documentation tone**: Analyzed in [writing-system.md](writing-system.md) (README, CONTRIBUTING, skills)

---

## Alternative: CLI Interface Copy

While traditional UI copy is not present, the plugin has **CLI interface text** that serves similar functions:

### Command Help Text

**Location**: Skill descriptions in YAML frontmatter
**Example**: [skills/pm-prd-write/SKILL.md](../../skills/pm-prd-write/SKILL.md)

```yaml
name: pm-prd-write
description: Generate a Product Requirements Document from an initiative description.
argument-hint: [initiative-description]
```

**Tone**: Direct, imperative, under 100 characters
**Quality**: High - clear purpose and expected input

### Confirmation Prompts

**Location**: Throughout skill execution (HARD STOP phase)
**Example**: [skills/pm-prd-write/SKILL.md:95](../../skills/pm-prd-write/SKILL.md#L95)

```markdown
> "I have all the information needed. Ready to generate the PRD for '{initiative}'? [y/n]"
```

**Tone**: Conversational, respectful, seeking explicit approval
**Pattern**: Question + context + [y/n] options

### Output Messages

**Location**: Script stdout/stderr
**Example**: [scripts/verify-install.sh:194](../../scripts/verify-install.sh#L194)

```bash
echo "✅ All checks passed! Plugin is installed correctly."
```

**Tone**: Encouraging, celebratory (emojis + exclamation), informative
**Pattern**: Symbol + statement + context

---

## Recommendations

### High Priority

1. **Continue focusing on CLI copy quality**
   **Action**: Current approach is excellent - maintain standards for:
   - Command descriptions (concise, under 100 chars)
   - Confirmation prompts (conversational, clear options)
   - Output messages (symbols + text + context)

### Medium Priority

2. **Document CLI copy patterns**
   **Action**: Add CLI copy section to [docs/STYLE.md](../../docs/STYLE.md)
   **Content**: Codify patterns for command descriptions, prompts, and output messages

### Low Priority

3. **If UI is added in future, apply standards**
   **Action**: Re-run `/jaan-to:detect-writing` to perform full UI copy classification
   **Trigger**: If React/Vue components are added for web-based configuration UI

---

## Appendix: CLI Copy Examples

**Command descriptions** (from 26 skills):

| Skill | Description | Character count | Quality |
|-------|-------------|-----------------|---------|
| pm-prd-write | Generate a Product Requirements Document from an initiative description. | 76 | ✅ Clear |
| data-gtm-datalayer | Generate production-ready GTM tracking code (dataLayer pushes and HTML attributes). | 89 | ✅ Clear |
| detect-writing | Writing system extraction with NNg tone dimensions, UI copy classification, and i18n maturity scoring. | 115 | ⚠️ Long |

**Recommendation**: Keep descriptions under 100 characters for better readability.

---

**Generated by**: jaan.to detect-writing v1.0.0
**Analysis date**: 2026-02-09
**Commit**: 39293e7dcb04ae8fe1c3694b3fd037149c0d0792
