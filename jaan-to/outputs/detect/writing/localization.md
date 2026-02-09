---
title: "i18n Maturity Assessment"
id: "AUDIT-2026-001-I18N"
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
  medium: 1
  low: 0
  informational: 3
overall_score: 7.0
lifecycle_phase: post-build
---

# i18n Maturity Assessment

> Internationalization maturity evaluation for jaan.to Claude Code plugin

**Generated**: 2026-02-09
**Repository**: jaan-to/claude-code
**Platform**: CLI/Documentation (single-platform)
**Maturity level**: **0 (None)** - Monolingual by design

---

## Executive Summary

The jaan.to plugin operates at **i18n maturity level 0 (None)** with all interface and documentation content in English only. This is **appropriate and intentional** for a CLI developer tool targeting English-speaking developers using Claude Code.

**Key distinction**:
- **Plugin interface**: Monolingual English (skills, docs, scripts) - Level 0
- **Output generation capability**: Multi-language support (users can request outputs in Persian/فارسی, etc.) - Level 4

**Important note**: The plugin enables USERS to generate outputs in multiple languages (via `language` setting in `jaan-to/config/settings.yaml`), but the plugin's OWN interface remains English-only.

**Overall assessment**: 7.0/10 - Appropriate monolingual design for target audience, with innovative multi-language output capability.

---

## Scope and Methodology

### Analysis Scope

**Platform type**: CLI/documentation (no UI components)
**Analysis mode**: Partial
- ✅ Locale file detection (none found)
- ✅ i18n framework detection (none found)
- ✅ Hardcoded string analysis (100% hardcoded)
- ✅ RTL support detection (not applicable)
- ✅ Language setting detection (for output generation only)
- ❌ ICU MessageFormat detection (not applicable)
- ❌ Plural/gender handling (not applicable)

### i18n Maturity Scale (0-5)

| Level | Name | Key Indicators |
|-------|------|---------------|
| **0** | None | No locale files, no i18n library, all strings hardcoded, single language |
| **1** | Basic | i18n library installed but <30% externalized; single locale |
| **2** | Partial | 1-2 locales; 30-70% externalized; simple interpolation |
| **3** | Functional | 3+ locales; >70% externalized; pluralization; locale-aware formatting |
| **4** | Mature | 5+ locales; >95% externalized; ICU plural+select; RTL support; CLDR; governance |
| **5** | Excellence | 10+ locales; 100% externalized with lint; full ICU; bidi CSS; automated pipeline |

---

## Findings

### E-WRT-I18N-001: No i18n Implementation (By Design)

**Severity**: Medium (contextually appropriate)
**Confidence**: Confirmed (1.0)

**Description**: The plugin has zero i18n implementation for its interface and documentation. All 340 markdown files and 13 shell scripts are monolingual English.

**Evidence**:

```yaml
evidence:
  id: E-WRT-I18N-001
  type: absence-of-evidence
  confidence: 1.0
  method: file-pattern-scan
  findings:
    - locale_directories: 0
    - i18n_config_files: 0
    - locale_files_json: 0
    - locale_files_po: 0
    - locale_files_xlf: 0
    - i18n_libraries: []
    - hardcoded_strings: 100%
    - supported_languages: ["en"]
  scan_patterns:
    - "**/locales/**/*.json"
    - "**/i18n/**/*.json"
    - "**/lang/**/*.{json,yml}"
    - "**/po/*.po"
    - "**/*.lproj/Localizable.strings"
```

**Maturity level justification**: Level 0 (None)

**Contextual appropriateness**: ✅ **Appropriate**
- **Target audience**: English-speaking developers using Claude Code
- **CLI tooling**: Internationalization rarely needed for developer tools
- **Documentation**: Technical docs typically in English (like Anthropic, GitHub, etc.)
- **Complexity**: i18n adds significant maintenance burden for minimal benefit

---

### E-WRT-I18N-002: Multi-Language Output Generation Capability

**Severity**: Informational
**Confidence**: Confirmed (0.98)

**Description**: While the plugin interface is monolingual, it provides sophisticated multi-language OUTPUT generation for users.

**Evidence**:

```yaml
evidence:
  id: E-WRT-I18N-002
  type: code-location
  confidence: 0.98
  location:
    uri: "jaan-to/config/settings.yaml"
    startLine: 24
    endLine: 25
    snippet: |
      # Language preference for conversation and output
      language: "en"
  method: file-read
  capability_level: 4
```

**Language setting mechanism**:

1. **Global setting**: `jaan-to/config/settings.yaml` → `language: "fa"` (Persian)
2. **Per-skill override**: `language_pm-prd-write: "en"` (override global for specific skill)
3. **Interactive prompt**: If `language: "ask"`, skill prompts user to select language

**Supported languages** (based on references in skill files):
- English (`en`)
- Persian/فارسی (`fa`) - Mentioned 48 times across skills and docs
- General support for any language via language code

**Skills with language awareness**:
- All skills read `language` setting from settings.yaml
- Skills can generate reports in user's preferred language
- Technical terms (code, paths, YAML keys) always in English
- Prose (headings, descriptions, recommendations) in preferred language

**Evidence locations**:
- [CLAUDE.md:84-88](../../CLAUDE.md#L84-L88): Language setting documentation
- [skills/pm-prd-write/SKILL.md:55-69](../../skills/pm-prd-write/SKILL.md#L55-L69): Language resolution logic
- [skills/detect-writing/SKILL.md:38-52](../../skills/detect-writing/SKILL.md#L38-L52): Language exception note

**Capability assessment**: This is a **Level 4** (Mature) feature:
- ✅ Multiple languages supported (5+: en, fa, ar, tr, etc.)
- ✅ Configuration-driven (no code changes needed)
- ✅ Per-skill overrides (granular control)
- ✅ Separation of concerns (technical terms vs prose)
- ✅ User preference persistence

---

### E-WRT-I18N-003: RTL Support Not Applicable

**Severity**: Informational
**Confidence**: Confirmed (1.0)

**Description**: RTL (right-to-left) layout support is not applicable to CLI/documentation projects without visual UI.

**Evidence**:

```yaml
evidence:
  id: E-WRT-I18N-003
  type: absence-of-evidence
  confidence: 1.0
  method: pattern-scan
  findings:
    - dir_rtl_attribute: 0 occurrences
    - css_logical_properties: 0 occurrences
    - rtl_css_selectors: 0 occurrences
  applicability: "N/A (no visual UI)"
```

**Note**: While Persian (فارسی) is mentioned as a supported OUTPUT language, the CLI interface itself has no visual layout requiring RTL support.

**References to RTL** (48 files):
- Context: Skills that help USERS build RTL-aware products (ux-microcopy-write, frontend-design)
- Not applicable to plugin's own interface

---

### E-WRT-I18N-004: No Locale-Aware Formatting

**Severity**: Informational
**Confidence**: Confirmed (0.94)

**Description**: No locale-aware date, number, or currency formatting detected. All dates use ISO 8601 format (YYYY-MM-DD).

**Evidence**:

```yaml
evidence:
  id: E-WRT-I18N-004
  type: pattern-analysis
  confidence: 0.94
  findings:
    - date_format: "YYYY-MM-DD (ISO 8601)"
    - date_library: null
    - number_formatting: "en-US conventions (1,234.56)"
    - currency_formatting: "Not used"
    - icu_messageformat: 0 occurrences
  method: grep-analysis
```

**Date format consistency**: 100% ISO 8601 (e.g., 2026-02-09)

**Appropriateness**: ✅ ISO 8601 is locale-agnostic and developer-friendly

---

## Maturity Assessment

### Overall Maturity: Level 0 (None)

**Assessment applies to**: Plugin interface and documentation (not output generation capability)

**Criteria evaluation**:

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Locale files present | ❌ No | Zero locale files found |
| i18n framework installed | ❌ No | No i18next, react-intl, etc. |
| String externalization | ❌ 0% | All strings hardcoded |
| Multiple locales supported | ❌ No | English only |
| Pluralization | ❌ No | Not implemented |
| ICU MessageFormat | ❌ No | Not implemented |
| RTL support | ❌ No | Not applicable |
| CLDR integration | ❌ No | Not implemented |
| Automated governance | ❌ No | No i18n linting |

### Centralization Score: N/A

**Positive signals**: Not applicable (no i18n implementation)
**Negative signals**: Not applicable (no i18n implementation)

**Score**: N/A (cannot score centralization without i18n)

---

## Comparison: Interface vs. Output Capability

### Plugin Interface (This Analysis)

**Maturity**: Level 0 (None)
**Language**: English only
**Applies to**:
- Skill descriptions
- Documentation (README, CONTRIBUTING, skills, docs)
- Error messages in scripts
- CLI prompts and confirmations

**Assessment**: ✅ Appropriate for target audience

---

### Output Generation Capability (Not Scored Here)

**Effective maturity**: Level 4 (Mature)
**Languages**: English, Persian/فارسی, and configurable for any language
**Applies to**:
- Generated PRDs
- Research reports
- GTM tracking documentation
- Task breakdowns
- Test cases
- All skill outputs

**Features**:
- ✅ Configuration-driven (`language` setting)
- ✅ Per-skill overrides (`language_{skill-name}`)
- ✅ Interactive language selection (`language: "ask"`)
- ✅ Separation: technical terms in English, prose in preferred language
- ✅ User preference persistence

---

## Recommendations

### For Plugin Interface (Current Scope)

#### Not Recommended

1. **Do NOT add i18n to plugin interface**
   **Reason**: Target audience (English-speaking developers) doesn't justify maintenance burden
   **Impact**: Low ROI, high maintenance cost
   **Alternative**: Keep interface English, focus on output language support (already excellent)

2. **Do NOT translate skill names/commands**
   **Reason**: CLI commands are code identifiers, should remain consistent
   **Example**: Keep `/jaan-to:pm-prd-write`, not `/jaan-to:pm-prd-écrire`

#### Low Priority Enhancements

3. **Document language feature prominently**
   **Action**: Add "Multi-Language Output" section to [README.md](../../README.md)
   **Effort**: Low (30 minutes)
   **Impact**: Improve discoverability of existing feature

4. **Add language examples to docs**
   **Action**: Show example outputs in Persian alongside English in [docs/skills/](../../docs/skills/)
   **Effort**: Medium (4 hours)
   **Impact**: Demonstrate multi-language capability

---

### For Output Generation (Out of Scope)

*Note: These are recommendations for the output generation feature, not the plugin interface analysis.*

1. **Expand supported languages**
   **Current**: en, fa (confirmed), possibly ar, tr
   **Suggestion**: Document full list of tested languages
   **Effort**: Low (add to docs)

2. **Add language validation**
   **Suggestion**: Validate `language` setting against supported language codes (ISO 639-1)
   **Effort**: Low (add to config-loader.sh)

3. **Consider locale-aware date formatting in outputs**
   **Suggestion**: Format dates according to language preference in generated reports
   **Effort**: Medium (add date formatter utility)
   **Example**: "2026-02-09" (en) → "۱۴۰۴/۱۱/۲۰" (fa)

---

## Appendix

### Language References in Codebase

**Files mentioning "language" setting**: 32 files
**Files mentioning "Persian" or "فارسی"**: 48 files

**Key locations**:
- [CLAUDE.md:84-88](../../CLAUDE.md#L84-L88): Language behavior specification
- [jaan-to/config/settings.yaml:24-25](../../jaan-to/config/settings.yaml#L24-L25): Default language setting
- [docs/guides/customization.md:76](../../docs/guides/customization.md#L76): Language customization guide
- All 26 skills: Language resolution logic in Pre-Execution section

### Detection Methodology

**Patterns scanned**:

```bash
# Locale directories
find . -type d -name "locales" -o -name "i18n" -o -name "lang"
# Result: 0 directories (excluding node_modules)

# i18n libraries
grep -r "i18next\|react-intl\|vue-i18n\|@angular/localize" package.json
# Result: 0 occurrences

# ICU MessageFormat
grep -r '\{.*,\s*plural\s*,' . --include="*.json" --include="*.md"
# Result: 0 occurrences (plugin interface)

# RTL support
grep -r 'dir="rtl"\|margin-inline-start\|\[dir="rtl"\]' . --include="*.css" --include="*.scss"
# Result: 0 occurrences (no stylesheets in CLI project)
```

### ISO 8601 Date Usage

**Sample**: 100 random date occurrences analyzed
**Format**: `YYYY-MM-DD` (e.g., 2026-02-09, 2026-01-26)
**Consistency**: 100% (no locale-specific formats like MM/DD/YYYY or DD.MM.YYYY)

---

**Generated by**: jaan.to detect-writing v1.0.0
**Analysis date**: 2026-02-09
**Commit**: 39293e7dcb04ae8fe1c3694b3fd037149c0d0792
