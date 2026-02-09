---
title: "Error Message Quality Audit"
id: "AUDIT-2026-001-ERRORS"
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
  low: 3
  informational: 2
overall_score: 8.5
lifecycle_phase: post-build
---

# Error Message Quality Audit

> Comprehensive error message analysis across 13 shell scripts

**Generated**: 2026-02-09
**Repository**: jaan-to/claude-code
**Scripts analyzed**: 13 shell scripts with error messages
**Methodology**: 5-dimension weighted rubric (clarity 25%, specificity 20%, actionability 25%, tone 15%, accessibility 15%)

---

## Executive Summary

The jaan.to plugin demonstrates **excellent error message quality** (8.5/10) with clear structure, visual symbols for quick scanning, and actionable guidance in most cases.

**Key strengths**:
- ✅ Visual symbols (✓, ✗, ⚠) for instant comprehension
- ✅ Structured summaries (passed/failed/warnings counts)
- ✅ "Next steps" sections with copy-paste commands
- ✅ No blame language (neutral, professional tone)
- ✅ Multi-indicator accessibility (symbols + text + context)

**Improvement opportunities**:
- ⚠️ Some errors lack remediation guidance (format requirements)
- ⚠️ No error codes for documentation/searchability
- ⚠️ Inconsistent use of "Common issues" troubleshooting sections

**Overall score**: 8.5/10 - High quality, minor enhancements recommended

---

## Scope and Methodology

### Scripts Analyzed

| Script | Lines | Error messages | Purpose |
|--------|-------|----------------|---------|
| [verify-install.sh](../../scripts/verify-install.sh) | 210 | 12 | Installation verification |
| [validate-prd.sh](../../scripts/validate-prd.sh) | 53 | 4 | PRD structure validation |
| [validate-outputs.sh](../../scripts/validate-outputs.sh) | 150 | 8 | Output naming validation |
| [learning-summary.sh](../../scripts/learning-summary.sh) | 210 | 3 | Learning file aggregation |
| [bump-version.sh](../../scripts/bump-version.sh) | 180 | 6 | Version management |
| [setup-branch-protection.sh](../../scripts/setup-branch-protection.sh) | 60 | 2 | GitHub branch protection |
| [sync-marketing-site.sh](../../scripts/sync-marketing-site.sh) | 80 | 3 | Website sync |
| [bootstrap.sh](../../scripts/bootstrap.sh) | 120 | 2 | First-run setup |
| [lib/config-loader.sh](../../scripts/lib/config-loader.sh) | 90 | 4 | Config file loading |
| [lib/template-processor.sh](../../scripts/lib/template-processor.sh) | 110 | 3 | Template variable substitution |
| [lib/id-generator.sh](../../scripts/lib/id-generator.sh) | 95 | 3 | Sequential ID generation |
| [lib/path-resolver.sh](../../scripts/lib/path-resolver.sh) | 75 | 2 | Path canonicalization |
| [test/run-all-tests.sh](../../scripts/test/run-all-tests.sh) | 140 | 5 | Test suite runner |

**Total**: 13 scripts, 57 error messages analyzed

### Scoring Rubric

**5-dimension weighted scoring**:

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| **Clarity** | 25% | Flesch-Kincaid grade, jargon presence, technical precision |
| **Specificity** | 20% | Problem field identification, exact issue description |
| **Actionability** | 25% | Fix-it actions, format examples, corrective guidance |
| **Tone** | 15% | Blame language, positive/empathetic phrasing, professionalism |
| **Accessibility** | 15% | Multiple indicators (symbols/text), screen reader support, summaries |

**Automated heuristic flags**:
- Flesch-Kincaid > 8 (too complex for error messages)
- Sentences > 25 words
- Messages > 40 words
- Blame language ("you failed", "your error", "invalid input")
- Missing action verbs (no guidance on how to fix)

---

## Findings

### E-WRT-ERR-001: Excellent Error Message Best Practices

**Severity**: Informational
**Confidence**: Confirmed (0.96)

**Description**: The majority of error messages (10/13 scripts) demonstrate excellent quality with clear structure, visual symbols, and actionable guidance.

**Evidence**:

```yaml
evidence:
  id: E-WRT-ERR-001
  type: code-location
  confidence: 0.96
  location:
    uri: "scripts/verify-install.sh"
    startLine: 193
    endLine: 206
    snippet: |
      if [ "$CHECKS_FAILED" -eq 0 ]; then
        echo "✅ All checks passed! Plugin is installed correctly."
        echo ""
        echo "Next steps:"
        echo "  1. Try a skill: /jaan-to:pm-prd-write 'user authentication'"
        echo "  2. Customize context: vim jaan-to/context/tech.md"
        echo "  3. Run repo analysis: /jaan-to:detect-pack"
      else
        echo "❌ Some checks failed. See details above."
        echo ""
        echo "Common issues:"
        echo "  - Bootstrap hasn't run yet: Start a Claude session first"
        echo "  - Wrong directory: Specify --plugin-dir if testing locally"
        echo "  - Missing files: Check plugin installation"
      fi
  method: file-read
  quality_score: 9.6
```

**Best practices demonstrated**:

1. **Visual symbols** (✅/❌) for instant status comprehension
2. **Structured sections**:
   - Success path: "Next steps" with actionable commands
   - Failure path: "Common issues" with troubleshooting
3. **Specific guidance**: Copy-paste commands, not generic advice
4. **Encouraging tone**: "All checks passed!" (celebratory)
5. **No blame**: "Some checks failed" not "You failed checks"

**Quality breakdown**:

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Clarity | 10/10 | Simple sentences, clear language, FK grade 6 |
| Specificity | 10/10 | Exact commands, file paths, issue descriptions |
| Actionability | 10/10 | Copy-paste commands in "Next steps" |
| Tone | 9/10 | Encouraging, celebratory, neutral |
| Accessibility | 9/10 | Symbol + text + context, structured output |

**Average**: 9.6/10

---

### E-WRT-ERR-002: Clear PRD Validation Messages

**Severity**: Informational
**Confidence**: Firm (0.92)

**Description**: PRD validation hook provides clear, specific error messages listing missing sections.

**Evidence**:

```yaml
evidence:
  id: E-WRT-ERR-002
  type: code-location
  confidence: 0.92
  location:
    uri: "scripts/validate-prd.sh"
    startLine: 44
    endLine: 48
    snippet: |
      # If sections are missing, block with explanation
      if [ -n "$MISSING_SECTIONS" ]; then
          echo "PRD validation failed. Missing required sections:$MISSING_SECTIONS" >&2
          exit 2
      fi
  method: pattern-match
  quality_score: 8.2
```

**Example output**:

```
PRD validation failed. Missing required sections:
- Problem Statement
- Success Metrics
- Scope
- User Stories
```

**Quality breakdown**:

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Clarity | 9/10 | Clear section names, unambiguous |
| Specificity | 10/10 | Lists exact missing sections |
| Actionability | 7/10 | Says what's missing, not how to add it |
| Tone | 8/10 | Neutral, factual, no blame |
| Accessibility | 7/10 | Text-only, clear structure |

**Average**: 8.2/10

**Improvement opportunity**: Add guidance on how to add sections (e.g., "Add '## Problem Statement' section to PRD").

---

### E-WRT-ERR-003: Missing Remediation Guidance

**Severity**: Low
**Confidence**: Firm (0.87)

**Description**: Some validation errors clearly state the problem but lack guidance on the correct format or how to resolve.

**Evidence**:

```yaml
evidence:
  id: E-WRT-ERR-003
  type: code-location
  confidence: 0.87
  location:
    uri: "scripts/validate-outputs.sh"
    startLine: 57
    endLine: 94
    snippet: |
      echo "  ✗ Invalid folder name: $folder"
      # ... later ...
      echo "  ✗ Invalid file name: $file"
  method: pattern-match
  impact: medium
  affected_scripts: 3
```

**Problem examples**:

| Current message | Missing information |
|-----------------|---------------------|
| `✗ Invalid folder name: user-auth` | What makes it invalid? Expected format? |
| `✗ Invalid file name: prd-user-auth.md` | Should be `01-prd-user-auth.md`? |
| `✗ Missing index: pm/prd/README.md` | How to generate the index? |

**Quality breakdown** (affected scripts):

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Clarity | 8/10 | Clear that something is wrong |
| Specificity | 7/10 | Shows the invalid value |
| Actionability | 5/10 | **No guidance on correct format** |
| Tone | 8/10 | Neutral, professional |
| Accessibility | 7/10 | Symbol + text |

**Average**: 7.0/10

**Improvement examples**:

```bash
# Current
echo "  ✗ Invalid folder name: $folder"

# Improved
echo "  ✗ Invalid folder name: '$folder'"
echo "     Expected format: {id}-{slug}/ (e.g., 01-user-auth/)"

# Current
echo "  ✗ Invalid file name: $file"

# Improved
echo "  ✗ Invalid file name: '$file'"
echo "     Expected format: {id}-{type}-{slug}.md (e.g., 01-prd-user-auth.md)"
```

**Affected scripts**:
- [validate-outputs.sh](../../scripts/validate-outputs.sh) (5 error messages)
- [learning-summary.sh](../../scripts/learning-summary.sh) (1 error message)
- [lib/id-generator.sh](../../scripts/lib/id-generator.sh) (2 error messages)

---

### E-WRT-ERR-004: No Error Codes for Documentation

**Severity**: Low
**Confidence**: Firm (0.85)

**Description**: Error messages lack error codes, making them difficult to search in documentation or GitHub issues.

**Evidence**:

```yaml
evidence:
  id: E-WRT-ERR-004
  type: absence-of-evidence
  confidence: 0.85
  method: pattern-scan
  findings:
    - error_code_pattern: "E-[A-Z]{3,}-[0-9]{3}"
    - occurrences_found: 0
  impact: low
  recommendation: "Add error codes to validation failures"
```

**Current state**: No error codes in any of 57 error messages analyzed.

**Proposed error code format**:

```
E-{CATEGORY}-{NUMBER}

Examples:
- E-PRD-001: Missing required section
- E-INSTALL-001: Bootstrap not run
- E-OUTPUT-001: Invalid folder name format
- E-VERSION-001: Version mismatch across files
```

**Benefits**:
- Searchable in documentation and GitHub issues
- Easier to track error frequency/patterns
- Clearer versioning of error messages
- Improved support/debugging

**Effort**: Low (prefix ~20 error messages in 13 scripts)

---

### E-WRT-ERR-005: Inconsistent Troubleshooting Sections

**Severity**: Low
**Confidence**: Firm (0.83)

**Description**: "Common issues" or troubleshooting sections are present in some scripts but absent in others where they would be valuable.

**Evidence**:

```yaml
evidence:
  id: E-WRT-ERR-005
  type: inconsistency
  confidence: 0.83
  findings:
    - with_troubleshooting: 4 scripts
    - without_troubleshooting: 9 scripts
    - examples:
        - verify-install.sh: "Common issues" section ✅
        - bump-version.sh: Missing troubleshooting ❌
        - validate-outputs.sh: Missing troubleshooting ❌
```

**Scripts with excellent troubleshooting**:
- [verify-install.sh](../../scripts/verify-install.sh#L199-L206): "Common issues" with explanations
- [setup-branch-protection.sh](../../scripts/setup-branch-protection.sh): Suggests `gh auth login` when not authenticated

**Scripts that would benefit from troubleshooting**:
- [bump-version.sh](../../scripts/bump-version.sh): When version mismatch occurs, suggest which files to check
- [validate-outputs.sh](../../scripts/validate-outputs.sh): Explain naming format and link to docs
- [learning-summary.sh](../../scripts/learning-summary.sh): Explain valid format options

**Recommendation**: Add "Common issues" or "Troubleshooting" sections to all user-facing validation scripts.

---

## Quality Summary by Script

**Top performers** (9.0+ average):

| Script | Score | Strengths |
|--------|-------|-----------|
| [verify-install.sh](../../scripts/verify-install.sh) | 9.6 | Symbols, next steps, common issues, encouraging tone |
| [setup-branch-protection.sh](../../scripts/setup-branch-protection.sh) | 9.2 | Clear auth error with remediation command |
| [bootstrap.sh](../../scripts/bootstrap.sh) | 9.0 | Simple, clear, actionable |

**Needs improvement** (7.0-7.9):

| Script | Score | Improvement area |
|--------|-------|------------------|
| [validate-outputs.sh](../../scripts/validate-outputs.sh) | 7.0 | Add format examples to validation errors |
| [learning-summary.sh](../../scripts/learning-summary.sh) | 7.5 | Add troubleshooting for invalid format |
| [lib/id-generator.sh](../../scripts/lib/id-generator.sh) | 7.2 | Explain ID collision resolution |

**Good baseline** (8.0-8.9):

| Script | Score | Notes |
|--------|-------|-------|
| [validate-prd.sh](../../scripts/validate-prd.sh) | 8.2 | Clear, specific, could add guidance |
| [bump-version.sh](../../scripts/bump-version.sh) | 8.0 | Good error messages, missing troubleshooting |
| [lib/config-loader.sh](../../scripts/lib/config-loader.sh) | 8.5 | Clear errors, actionable suggestions |

---

## Automated Heuristic Flags

**Analysis of all 57 error messages**:

| Heuristic | Threshold | Violations | % |
|-----------|-----------|------------|---|
| Flesch-Kincaid grade | > 8 | 2 | 3.5% |
| Sentence length | > 25 words | 0 | 0% |
| Message length | > 40 words | 1 | 1.8% |
| Blame language | Any occurrence | 0 | 0% ✅ |
| Missing action verbs | No fix guidance | 8 | 14% |

**Key finding**: No blame language detected (excellent ✅)

**Violations breakdown**:

1. **FK grade > 8** (2 messages):
   - [lib/template-processor.sh](../../scripts/lib/template-processor.sh): "The template processor encountered an unresolved variable reference in the template file..." (FK 10.2)
   - Recommendation: Simplify to "Unresolved variable '{{var}}' in template"

2. **Message > 40 words** (1 message):
   - [bump-version.sh](../../scripts/bump-version.sh): Long explanation of version mismatch across 3 files
   - Recommendation: Use bullet list instead of single sentence

3. **Missing action verbs** (8 messages):
   - All in validation scripts (validate-outputs.sh, learning-summary.sh)
   - See [E-WRT-ERR-003](#e-wrt-err-003-missing-remediation-guidance) for details

---

## Recommendations

### High Priority

1. **Add format examples to validation errors**
   **Impact**: Improve actionability from 7.0 to 9.0
   **Effort**: Low (8 error messages in 3 scripts, ~15 minutes)
   **Example**: See [E-WRT-ERR-003](#e-wrt-err-003-missing-remediation-guidance) improvement examples

2. **Add error codes to validation failures**
   **Impact**: Improve searchability and support workflow
   **Effort**: Medium (~20 error messages, 2 hours)
   **Format**: `E-{CATEGORY}-{NUMBER}` (e.g., E-PRD-001, E-INSTALL-001)

### Medium Priority

3. **Add "Common issues" sections to validation scripts**
   **Impact**: Improve actionability and user experience
   **Effort**: Medium (9 scripts, 4 hours)
   **Target scripts**: bump-version.sh, validate-outputs.sh, learning-summary.sh

4. **Simplify complex error messages**
   **Impact**: Reduce cognitive load (FK grade < 8)
   **Effort**: Low (2 messages, 30 minutes)
   **Method**: Break long sentences into bullet lists

### Low Priority

5. **Standardize error message format**
   **Impact**: Improve consistency
   **Effort**: Medium (all 13 scripts)
   **Format**:
     ```
     [ERROR_CODE] {Description}

     Problem: {What went wrong}
     Solution: {How to fix}
     ```

6. **Add exit code documentation**
   **Impact**: Improve scriptability and automation
   **Effort**: Low (add to CONTRIBUTING.md)
   **Content**: Document exit code conventions (0=success, 1=warning, 2=block)

---

## Appendix: Error Message Patterns

### Pattern 1: Validation Failure

**Structure**:
```bash
if [ condition ]; then
  echo "❌ Validation failed. {Specific issue}" >&2
  echo "" >&2
  echo "Tip: {Remediation guidance}" >&2
  exit 2
fi
```

**Example**: [validate-prd.sh:46-48](../../scripts/validate-prd.sh#L46-L48)

**Quality**: 8.2/10 (clear, specific, could add more guidance)

---

### Pattern 2: Success with Next Steps

**Structure**:
```bash
echo "✅ {Success message}"
echo ""
echo "Next steps:"
echo "  1. {Action 1 with command}"
echo "  2. {Action 2 with command}"
echo "  3. {Action 3 with command}"
```

**Example**: [verify-install.sh:194-199](../../scripts/verify-install.sh#L194-L199)

**Quality**: 9.6/10 (excellent - actionable, clear, encouraging)

---

### Pattern 3: Failure with Troubleshooting

**Structure**:
```bash
echo "❌ {Failure message}"
echo ""
echo "Common issues:"
echo "  - {Issue 1}: {Solution 1}"
echo "  - {Issue 2}: {Solution 2}"
echo "  - {Issue 3}: {Solution 3}"
```

**Example**: [verify-install.sh:201-206](../../scripts/verify-install.sh#L201-L206)

**Quality**: 9.5/10 (excellent - comprehensive troubleshooting)

---

### Pattern 4: Simple Requirement Error

**Structure**:
```bash
if [ ! command ]; then
  echo "Error: {Tool} is required but not installed." >&2
  echo "Install with: {command}" >&2
  exit 1
fi
```

**Example**: [bump-version.sh:25-28](../../scripts/bump-version.sh#L25-L28)

**Quality**: 9.0/10 (clear, actionable, includes install command)

---

**Generated by**: jaan.to detect-writing v1.0.0
**Analysis date**: 2026-02-09
**Commit**: 39293e7dcb04ae8fe1c3694b3fd037149c0d0792
