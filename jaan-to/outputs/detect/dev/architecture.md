# Architecture Audit — claude-code

---
title: "Architecture Audit — claude-code"
id: "AUDIT-2026-002"
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
  medium: 0
  low: 1
  informational: 7
overall_score: 9.9
lifecycle_phase: post-build
---

## Executive Summary

The **claude-code** plugin architecture is **well-designed** with clear separation of concerns:

- **Plugin Layer**: Markdown-based skills (26), agents (2), hooks (4)
- **Automation Layer**: Shell scripts (14) for validation, building, deployment
- **Documentation Layer**: Static site (React + Docusaurus)
- **Distribution**: Clean dist/ folder for plugin marketplace

**Key Strengths**:
- Clean separation: plugin logic vs. documentation site
- Event-driven hooks system for lifecycle automation
- Template-based output generation (customizable)
- Two-phase workflow pattern (analyze → approve → generate)

**Key Observations**:
- No backend — fully client-side execution in Claude Code runtime
- Skills use YAML frontmatter + Markdown for configuration
- Auto-discovery of skills/agents/hooks from standard directories

**Overall Assessment**: **Excellent** — Architecture follows Claude Code best practices with strong modularity and extensibility.

---

## Scope and Methodology

**Analysis Methods**:
- Directory structure analysis
- Configuration file parsing (plugin.json, hooks.json)
- Skill definition inspection (SKILL.md files)
- Build script analysis

**Scope**:
- ✅ Plugin architecture patterns
- ✅ Skill and agent definitions
- ✅ Hook system and automation
- ✅ Build and distribution process
- ⚠️ Runtime behavior (not analyzed — requires execution)

---

## Findings

### F-ARCH-001: Plugin Architecture — Skills, Agents, Hooks Pattern

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-013
  type: code-location
  confidence: 1.00
  location:
    uri: "."
    analysis: |
      Directory structure:
      ├── skills/               # 26 skill definitions
      │   ├── pm-prd-write/
      │   ├── data-gtm-datalayer/
      │   ├── detect-dev/
      │   └── ... (23 more)
      ├── agents/               # 2 specialized agents
      │   ├── quality-reviewer.md
      │   └── context-scout.md
      ├── hooks/
      │   └── hooks.json        # 4 lifecycle hooks
      ├── scripts/              # 14 automation scripts
      └── .claude-plugin/
          └── plugin.json       # Minimal manifest
  method: static-analysis
```

**Description**:
The plugin follows **Claude Code plugin architecture** with three core components:

1. **Skills** (26): User-invocable commands for specific workflows (e.g., `/jaan-to:pm-prd-write`)
2. **Agents** (2): Autonomous subagents for complex tasks (quality-reviewer, context-scout)
3. **Hooks** (4): Lifecycle automation (Setup, SessionStart, PostToolUse, Stop)

**Pattern**: Auto-discovery from standard directories. `plugin.json` deliberately excludes component paths to allow Claude Code's built-in discovery mechanism.

**Impact**: **Positive** — Follows official best practices, easy to extend (add new skills by creating folder + SKILL.md).

---

### F-ARCH-002: Two-Phase Workflow Pattern in Skills

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-014
  type: pattern-match
  confidence: 0.98
  location:
    uri: "skills/pm-prd-write/SKILL.md"
    startLine: 80
    endLine: 95
    snippet: |
      # PHASE 1: Analysis (Read-Only)
      ## Step 1: Read Context
      ## Step 2: Gather Requirements
      ## Step 3: Structure PRD

      # HARD STOP — Summary & User Approval
      > "Proceed with writing PRD to $JAAN_OUTPUTS_DIR/...? [y/n]"

      # PHASE 2: Generation
      ## Step 4: Write Output Files
  method: pattern-match
```

**Description**:
Skills implement a **two-phase workflow**:

**Phase 1 (Analysis)**:
- Read-only operations (Glob, Grep, Read)
- Analyze codebase and gather context
- Plan the output structure
- **HARD STOP**: Present summary to user

**Phase 2 (Generation)**:
- User approves the plan
- Write files with Write tool
- Validate outputs
- Capture feedback

**Impact**: **Positive** — Ensures human oversight before making changes. Prevents unwanted file writes.

---

### F-ARCH-003: Markdown-Based Skill Definitions

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-015
  type: config-pattern
  confidence: 1.00
  location:
    uri: "skills/*/SKILL.md"
    analysis: |
      Each skill has:
      - YAML frontmatter (metadata, input schema)
      - Markdown body (instructions for LLM)
      - Context file references
      - Output templates

      Example structure:
      skills/pm-prd-write/
      ├── SKILL.md              # Main definition
      └── template.md           # Output template
  method: static-analysis
```

**Description**:
Skills are defined in **SKILL.md** files with:
- **YAML frontmatter**: Metadata (name, description, input schema, version)
- **Markdown body**: Step-by-step instructions for the LLM to execute
- **Context references**: Point to learning files, templates, configuration

**Benefits**:
- Human-readable and version-controllable
- LLM-friendly format (Markdown is natural for Claude)
- Easy to customize (just edit Markdown)

**Impact**: **Positive** — Excellent developer experience, low barrier to creating new skills.

---

### F-ARCH-004: Event-Driven Hooks System

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-016
  type: config-pattern
  confidence: 1.00
  location:
    uri: "hooks/hooks.json"
    startLine: 1
    endLine: 72
    snippet: |
      {
        "hooks": {
          "Setup": [{ "command": "scripts/bootstrap.sh" }],
          "SessionStart": [{ "command": "scripts/bootstrap.sh" }],
          "PostToolUse": [
            { "matcher": "Write", "command": "scripts/capture-feedback.sh" },
            { "matcher": "Write", "command": "scripts/docs-sync-check.sh" },
            { "matcher": "Bash", "command": "scripts/post-commit-roadmap.sh" }
          ],
          "Stop": [{ "command": "scripts/session-end.sh" }]
        }
      }
  method: manifest-analysis
```

**Description**:
The plugin uses **4 lifecycle hooks** for automation:

| Hook | Trigger | Action | Purpose |
|------|---------|--------|---------|
| **Setup** | Plugin install | bootstrap.sh | Create jaan-to/ folder structure |
| **SessionStart** | Session start | bootstrap.sh | Ensure project setup |
| **PostToolUse** | After Write tool | capture-feedback.sh | Record user feedback |
| **PostToolUse** | After Write tool | docs-sync-check.sh | Validate docs changes |
| **PostToolUse** | After Bash (git commit) | post-commit-roadmap.sh | Update roadmap |
| **Stop** | Session end | session-end.sh | Cleanup and summary |

**Impact**: **Positive** — Automated setup, continuous learning, roadmap sync without user intervention.

---

### F-ARCH-005: Separation of Concerns — Plugin vs. Documentation

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-DEV-017
  type: code-location
  confidence: 1.00
  location:
    uri: "."
    analysis: |
      Clear boundaries:

      Plugin code (distributed):
      - skills/, agents/, hooks/, scripts/
      - .claude-plugin/
      - No runtime dependencies

      Documentation site (not distributed):
      - website/docs/
      - Node.js dependencies
      - Build artifacts excluded from plugin
  method: static-analysis
```

**Description**:
The repository maintains **clear separation** between:

1. **Plugin code** (distributed to users):
   - Markdown-based skills/agents
   - Shell scripts
   - No runtime dependencies
   - Lives in dist/ for distribution

2. **Documentation site** (developer-facing):
   - React + Docusaurus
   - Heavy npm dependencies (900+ packages)
   - Not included in plugin distribution
   - Deployed separately to Cloudflare Pages

**Impact**: **Positive** — Keeps plugin lightweight (only markdown + scripts). Documentation can use heavyweight tooling without affecting plugin users.

---

### F-ARCH-006: Shell Script Orchestration Layer

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-018
  type: code-location
  confidence: 0.98
  location:
    uri: "scripts/"
    analysis: |
      Automation scripts (14):

      Validation:
      - validate-skills.sh     # Skill definition validation
      - validate-prd.sh        # PRD output validation
      - validate-outputs.sh    # General output validation
      - verify-install.sh      # Installation verification

      Building:
      - build-dist.sh          # Distribution packaging
      - bump-version.sh        # Version management
      - sync-marketing-site.sh # Marketing site sync

      Lifecycle:
      - bootstrap.sh           # Project setup
      - capture-feedback.sh    # Learning capture
      - docs-sync-check.sh     # Docs validation
      - post-commit-roadmap.sh # Roadmap sync
      - session-end.sh         # Session cleanup
      - learning-summary.sh    # Learning report
      - setup-branch-protection.sh # Git config
  method: static-analysis
```

**Description**:
The plugin uses **shell scripts** as an orchestration layer for:
- Validation (skills, outputs, installation)
- Building and distribution
- Lifecycle automation (bootstrap, cleanup)
- Learning and feedback capture

**Impact**: **Neutral** — Shell scripts are portable but lack type safety. Consider adding ShellCheck linting.

---

### F-ARCH-007: Distribution via dist/ Folder

**Severity**: Informational
**Confidence**: Confirmed (0.95)

```yaml
evidence:
  id: E-DEV-019
  type: code-location
  confidence: 0.95
  location:
    uri: "scripts/build-dist.sh"
    analysis: |
      Build process:
      1. Clean dist/jaan-to/
      2. Copy plugin files (skills, agents, hooks, scripts)
      3. Exclude documentation site (website/)
      4. Exclude development files (.git, node_modules)
      5. Generate clean plugin.json

      Result: Lightweight distribution package
  method: static-analysis
```

**Description**:
The `build-dist.sh` script creates a **clean distribution** in dist/jaan-to/ by:
- Copying only plugin-essential files
- Excluding documentation site (website/)
- Excluding development files (.git, .github)
- Generating minimal plugin.json

Users can install via:
```bash
claude --plugin-dir ./dist/jaan-to
```

**Impact**: **Positive** — Clean separation between development repo and distributed plugin.

---

### F-ARCH-008: Template-Based Output Generation

**Severity**: Informational
**Confidence**: Confirmed (0.98)

```yaml
evidence:
  id: E-DEV-020
  type: pattern-match
  confidence: 0.98
  location:
    uri: "skills/*/template.md"
    analysis: |
      Each skill references templates:
      - $JAAN_TEMPLATES_DIR/jaan-to:{skill-name}.template.md
      - Customizable via project's jaan-to/templates/
      - Falls back to plugin defaults

      Example: pm-prd-write uses template.md for PRD structure
  method: pattern-match
```

**Description**:
Skills use **template files** for output generation:
- Plugin ships with default templates
- Users can override via jaan-to/templates/ in their project
- Templates use markdown with placeholders

**Impact**: **Positive** — Users can customize output formats without modifying skills.

---

### F-ARCH-009: No Architecture Documentation Diagram

**Severity**: Low
**Confidence**: Firm (0.80)

```yaml
evidence:
  id: E-DEV-021
  type: absence
  confidence: 0.80
  location:
    uri: "docs/"
    analysis: |
      Documentation includes:
      - Usage guides
      - Skill references
      - Migration guides

      Missing:
      - Architecture diagram (skills → agents → hooks flow)
      - Data flow diagrams
      - Component interaction diagrams
  method: heuristic
```

**Description**:
The plugin lacks **architecture diagrams** showing:
- How skills invoke agents
- Hook execution flow
- Data flow (context → skills → outputs)

**Impact**: **Minor** — Makes onboarding slower for new contributors.

**Remediation**: Add Mermaid diagrams to docs/architecture.md showing:
1. Plugin component interaction
2. Two-phase workflow sequence
3. Hook lifecycle

---

## Recommendations

### Priority 1 (High)
None identified. Architecture is solid.

### Priority 2 (Medium)
None identified.

### Priority 3 (Low)
1. **Add architecture diagrams** — Create visual documentation of plugin architecture (F-ARCH-009)

---

## Appendices

### A. Architecture Patterns Identified

| Pattern | Usage | Benefit |
|---------|-------|---------|
| **Two-Phase Workflow** | All generation skills | Human oversight before writes |
| **Auto-Discovery** | Skills/agents/hooks | Easy to extend |
| **Event-Driven Hooks** | Lifecycle automation | Passive learning and sync |
| **Template Override** | Output customization | User-specific formats |
| **Clean Distribution** | Plugin packaging | Lightweight installs |

### B. Component Counts

| Component | Count | Confidence |
|-----------|-------|------------|
| Skills | 26 | Confirmed |
| Agents | 2 | Confirmed |
| Hooks | 4 | Confirmed |
| Scripts | 14 | Confirmed |

---

*Generated by jaan.to detect-dev | 2026-02-09*
