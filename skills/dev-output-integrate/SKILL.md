---
name: dev-output-integrate
description: Copy generated jaan-to outputs into project locations with entry point wiring and validation.
allowed-tools: Read, Glob, Grep, Write(src/**), Write(apps/**), Write(prisma/**), Write(test/**), Write(tests/**), Write(.github/**), Write(docker/**), Write(deploy/**), Write(package.json), Write(tsconfig.json), Write(vitest.config.*), Write(playwright.config.*), Write(next.config.*), Write(tailwind.config.*), Write(.env.example), Write(.env.test), Write(.gitignore), Write(.dockerignore), Write(Dockerfile*), Write(docker-compose*), Write(turbo.json), Write($JAAN_OUTPUTS_DIR/dev/output-integrate/**), Bash(pnpm:*), Bash(npm:*), Bash(npx tsc:*), Bash(ls:*), Bash(mkdir:*), Task, AskUserQuestion, Edit(src/**), Edit(apps/**), Edit(package.json), Edit(tsconfig.json), Edit(next.config.*), Edit(turbo.json)
argument-hint: [output-path...] or (interactive scan)
---

# dev-output-integrate

> Bridge generated outputs from jaan-to/outputs/ into operational project locations.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` — Tech stack (determines package manager, monorepo tool)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:dev-output-integrate.template.md` — Integration log template
- `$JAAN_LEARN_DIR/jaan-to:dev-output-integrate.learn.md` — Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` — Language resolution protocol

## Input

**Output Paths**: $ARGUMENTS

- One or more paths to jaan-to output folders to integrate
- Or empty for interactive scan of all outputs

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `dev-output-integrate`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Know the tech stack for framework-specific integration
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_dev-output-integrate`

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing output folder structures and README placement instructions
- Cross-referencing destinations with existing project files
- Planning conflict resolution for replacements and merges
- Determining entry point modification order

## Step 1: Discover Outputs

If `$ARGUMENTS` provided:
- Validate each path exists
- Read the output README for placement instructions

If empty (interactive mode):
- Scan `$JAAN_OUTPUTS_DIR/**/*-readme.md` for available outputs
- Group by domain (backend, frontend, devops, qa)
- Present discovery table

Use AskUserQuestion:
- Question: "Which outputs do you want to integrate?"
- Header: "Select"
- Options: list discovered outputs (up to 4 most recent)

## Step 2: Parse README Instructions

For each selected output:
1. Read `{id}-{slug}-readme.md`
2. Extract file placement instructions:
   - `cp` commands → source and destination pairs
   - Arrow notation (`file.ts → src/file.ts`) → mapping pairs
   - Tables with Source/Destination columns
3. If parsing fails: present file list, ask user for destination mappings via AskUserQuestion

## Step 3: Detect Conflicts

For each destination file:
1. Check if destination exists
2. Classify as: **NEW** (does not exist) / **REPLACE** (exists, will overwrite) / **MERGE** (package.json, tsconfig.json — selective changes)
3. For replacements: load existing file content for diff preview
4. For merges: plan selective changes using deep merge strategy

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-output-integrate-reference.md` section "Config Merge Strategies" for package.json deep merge and tsconfig.json extends patterns.

## Step 4: Detect Entry Point Modifications

Parse READMEs for required modifications to existing files:
- Plugin registration statements
- Import additions
- Config property changes
- Script additions to package.json

Build ordered list of Edit operations needed.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-output-integrate-reference.md` section "Entry Point Wiring Patterns" for Fastify plugin order, Next.js config, and provider registration.

## Step 5: Present Integration Plan

Group operations by type:

```
INTEGRATION PLAN
================

NEW FILES ({count})
-------------------
{list with destination paths}

REPLACEMENTS ({count}) ⚠ will overwrite existing files
------------------------------------------------------
{list with source → destination + conflict note}

MERGES ({count})
----------------
{list with merge strategy description}

ENTRY POINT MODIFICATIONS ({count})
------------------------------------
{list with file + description of change}

DIRECTORIES TO CREATE ({count})
-------------------------------
{list}

TOTAL: {count} operations
```

---

# HARD STOP — Review Integration Plan

Use AskUserQuestion:
- Question: "Proceed with integrating {n} files into the project?"
- Header: "Integrate"
- Options:
  - "Yes" — Proceed with integration
  - "No" — Cancel
  - "Edit" — Let me revise the plan first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Copy Files to Project

1. Create all required directories (`mkdir -p`)
2. Write NEW files directly to destinations
3. For REPLACEMENTS:
   - Show diff between existing and new content
   - Use AskUserQuestion: "Overwrite {filename}?" — "Yes" / "No" / "Approve all remaining"
4. For MERGES:
   - Generate merged content using appropriate strategy
   - Show diff of merged result
   - Ask confirmation before writing

## Step 7: Modify Entry Points

For each entry point modification:
1. Read the target file
2. Show the proposed Edit with context
3. Ask approval (or batch if user chose "Approve all")
4. Apply Edit

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-output-integrate-reference.md` section "Security Plugin Registration Order" for the required order: helmet → CORS → rate-limit → session → CSRF → sensible.

Modification order:
1. Security plugins first (following registration order)
2. Route registrations
3. Config file modifications
4. Package.json script additions

## Step 8: Install Dependencies

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-output-integrate-reference.md` section "Package Manager Detection" for lockfile-based detection table.

1. Detect package manager from lockfile
2. Show list of new dependencies to install
3. Use AskUserQuestion:
   - Question: "Install {n} new dependencies with {package_manager}?"
   - Header: "Install"
   - Options: "Yes" — "No" — "Manual (show command only)"

If approved: run `{package_manager} install`

## Step 9: Validate Integration

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-output-integrate-reference.md` section "Bootstrap Validation Sequence" for the install → generate → migrate → seed → build → verify sequence.

Run validation checks based on what was integrated:
- **TypeScript**: `npx tsc --noEmit` (if .ts files copied)
- **Lint**: `pnpm run lint` (if lint script available)
- **Test**: `pnpm run test` (if test files copied)

Present results:
```
VALIDATION RESULTS
==================
TypeScript:  ✓ Pass / ✗ {error count} errors
Lint:        ✓ Pass / ✗ {warning count} warnings
Tests:       ✓ Pass / ✗ {failure count} failures / ⊘ Skipped
```

## Step 10: Quality Check

**File Operations:**
- [ ] All selected output files copied to correct destinations
- [ ] No existing files overwritten without user approval
- [ ] All parent directories created before writing

**Entry Points:**
- [ ] All plugin registrations applied
- [ ] All import statements added
- [ ] All config modifications applied
- [ ] All package.json script additions applied

**Validation:**
- [ ] TypeScript check passes (or errors explained)
- [ ] No hardcoded paths in copied files

If any check fails, fix before proceeding.

## Step 11: Generate ID and Folder Structure

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/dev/output-integrate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{integration-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/dev/output-integrate/{NEXT_ID}-{slug}/`
> - Main file: `{NEXT_ID}-{slug}.md`

## Step 12: Write Integration Log

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:dev-output-integrate.template.md`

Write `{NEXT_ID}-{slug}.md` with:
- Executive Summary
- Source outputs integrated (with IDs and paths)
- Files copied (full manifest with destinations)
- Entry points modified (with description of each change)
- Dependencies added
- Validation results
- Rollback instructions (git-based: `git stash` or `git checkout -- {files}`)

Update index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Integration Title}" \
  "{Executive summary — 1-2 sentences}"
```

Confirm:
> Integration log written to: `$JAAN_OUTPUTS_DIR/dev/output-integrate/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> Index updated: `$JAAN_OUTPUTS_DIR/dev/output-integrate/README.md`

## Step 13: Suggest Next Actions

> **Output integration complete!**
>
> **Immediate Steps:**
> - Run `pnpm dev` to verify the application starts
> - Run `pnpm test` for the full test suite
> - Review any validation warnings above
> - Commit your changes
>
> **Next Skills in Pipeline:**
> - Run `/jaan-to:devops-deploy-activate` if CI/CD configs were integrated
> - Run `/jaan-to:qa-test-generate` to generate tests for integrated code
> - Run `/jaan-to:release-iterate-changelog` to document the integration

## Step 14: Capture Feedback

Use AskUserQuestion:
- Question: "How did the output integration turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" — Done
  - "Needs fixes" — What should I adjust?
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add dev-output-integrate "{feedback}"`

---

## Scope Boundaries

- Does NOT deploy to external services (that's `/jaan-to:devops-deploy-activate`)
- Does NOT modify output files (copies as-is)
- Does NOT auto-commit changes
- Does NOT overwrite without showing diffs and getting approval
- Does NOT generate new code

---

## DAG Position

```
backend-scaffold + frontend-scaffold + backend-service-implement + qa-test-generate + devops-infra-scaffold + sec-audit-remediate
  |
  v
dev-output-integrate
  |
  v
devops-deploy-activate
```

---

## Definition of Done

- [ ] All selected output files copied to operational project locations
- [ ] Entry points modified (plugins registered, configs updated)
- [ ] Dependencies installed
- [ ] Validation passes (typecheck, lint, test)
- [ ] Integration log written to output directory
- [ ] Index updated with executive summary
- [ ] User approved final result
