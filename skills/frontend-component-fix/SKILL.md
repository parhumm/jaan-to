---
name: frontend-component-fix
description: Diagnose and fix UI bugs by generating patch artifacts routed through dev-output-integrate. Use when fixing component issues.
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(mkdir:*), Bash(stat:*), Bash(diff:*), mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__storybook-mcp__get-component-documentation, mcp__storybook-mcp__get-story-urls, Write($JAAN_OUTPUTS_DIR/frontend/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[bug-description] [--component path] [--screenshot path]"
license: PROPRIETARY
disable-model-invocation: true
---

# frontend-component-fix

> Diagnose and fix UI bugs by generating patch artifacts routed through dev-output-integrate.

**Safety model**: This skill generates patched component files to `$JAAN_OUTPUTS_DIR` only. It does NOT edit project source directly. Patches are applied via `/jaan-to:dev-output-integrate`.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional)
- `$JAAN_CONTEXT_DIR/design.md` - Design system guidelines (optional)
- `$JAAN_TEMPLATES_DIR/jaan-to-frontend-component-fix.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-frontend-component-fix.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md` - Shared reference (MCP degradation, visual scoring, network policy)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Arguments**: $ARGUMENTS

Accepts any of:
- **Bug description** — "Button hover state doesn't show on mobile"
- **Bug description + component path** — "Color contrast too low --component src/components/ui/Button.tsx"
- **Bug description + screenshot** — "Layout broken --screenshot /path/to/screenshot.png"
- **frontend-visual-verify output** — Path to verification report with failing checks
- **Empty** — Interactive wizard

| Argument | Effect |
|----------|--------|
| `[bug-description]` | What's wrong (required unless empty) |
| `--component path` | Component file to fix |
| `--screenshot path` | Screenshot showing the bug |

If no input provided, ask: "What UI issue should I fix? (describe the bug, optionally add --component path)"

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `frontend-component-fix`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/design.md` — Visual standards for fix validation

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_frontend-component-fix`

> **Language exception**: Generated code output remains in the project's programming language.

---

# PHASE 1: Diagnosis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Root cause analysis of visual/functional bugs
- Determining minimal fix scope
- Planning patch that preserves component API
- Assessing fix impact on other components

## Step 1: Parse Input

Extract from arguments:
1. **Bug description** — What is broken?
2. **Component path** — Which file? (If not provided, ask or infer from description)
3. **Screenshot** — Visual evidence of the bug (read if image path provided)

If verification report provided:
- Read report, extract failing checks
- Identify component and specific issues

## Step 2: Read Component Source

1. **Read the component file** — Full source code
2. **Read stories file** (if exists) — Understand component states
3. **Read related files**:
   - CSS/style files imported by component
   - Parent components that use this component
   - Shared utilities (cn(), CVA config)
4. **Check design.md** — Relevant visual standards

## Step 3: Capture Before State (Optional)

If Playwright MCP available AND Storybook running:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "Playwright Network Policy" for URL validation.

1. Validate URL is localhost-only
2. `mcp__playwright__browser_navigate` to component story
3. `mcp__playwright__browser_snapshot` — Accessibility tree before fix
4. `mcp__playwright__browser_take_screenshot` — Visual before state

If MCP unavailable: skip, note "Before screenshot not available without Playwright MCP"

## Step 4: Root Cause Analysis

Analyze the bug:

```
ROOT CAUSE ANALYSIS
───────────────────
Bug:          {description}
Component:    {name} at {path}
Symptoms:     {what the user sees}
Root Cause:   {technical explanation}
Fix Scope:    {which files need patching}
Impact:       {what else might be affected}
Confidence:   {high/medium/low}
```

If confidence is low, ask clarifying questions before proceeding.

## Step 5: Plan Fix

Outline the minimal patch needed:

```
FIX PLAN
────────
Component(s) to Patch:
  1. {file_path} — {what changes}
  2. {file_path} — {what changes (if multi-file)}

Changes:
  - {specific change 1}
  - {specific change 2}

Preserved:
  - Component API (props interface unchanged)
  - Existing tests compatibility
  - Design system consistency
```

---

# HARD STOP — Review Fix Plan

Present diagnosis and fix plan to user.

Use AskUserQuestion:
- Question: "Apply this fix?"
- Header: "Fix Plan"
- Options:
  - "Yes" — Generate patch artifacts
  - "No" — Cancel
  - "Edit" — Adjust the fix approach

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Patch Generation (Write Phase)

## Step 6: Generate Patched Files

For each file that needs fixing:

1. **Copy original source** to patch file
2. **Apply fix** to the patch copy
3. **Generate diff** showing before/after changes
4. Verify fix addresses root cause without side effects

**Output-only rule**: All patched files go to `$JAAN_OUTPUTS_DIR`. Never edit project source.

## Step 7: Generate Fix Report

Read template: `$JAAN_TEMPLATES_DIR/jaan-to-frontend-component-fix.template.md`

Fill sections:
- **Executive Summary**: Bug, root cause, fix in 1-2 sentences
- **Diagnosis**: Root cause analysis details
- **Fix Applied**: Before/after diff for each patched file
- **Impact Assessment**: What else might be affected
- **Integration Instructions**: How to apply via dev-output-integrate
- **Verification**: How to confirm the fix works
- **Metadata**: Generated date, skill version

## Step 8: Quality Check

- [ ] Patched files are syntactically valid
- [ ] Fix addresses the reported bug
- [ ] Component API preserved (no breaking changes)
- [ ] Design system consistency maintained
- [ ] Accessibility not degraded
- [ ] Before/after diff is minimal and focused
- [ ] Integration readme has correct Source → Destination table

## Step 9: Preview & Write Output

Show fix summary with diff preview.

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/frontend/component-fix"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{component-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Write files:
1. `mkdir -p "$OUTPUT_FOLDER"`
2. Write `{id}-{slug}.md` — Fix report with before/after diff
3. Write `{id}-{slug}-patch-{component}.tsx` — Patched component file(s)
4. Write `{id}-{slug}-readme.md` — Integration readme with Source → Destination table

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "dev-output-integrate Readme Format" for the required format.

5. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{ComponentName} Fix" \
  "Fix for {bug_summary}"
```

## Step 10: Guided Single-Run Mode

After writing patch artifacts, offer a streamlined next-actions flow:

Use AskUserQuestion:
- Question: "Fix artifacts ready. What next?"
- Header: "Next Action"
- Options:
  - "Integrate + Verify" — Run dev-output-integrate then frontend-visual-verify (Recommended)
  - "Integrate only" — Run dev-output-integrate with prefilled paths
  - "Save patches only" — Done, integrate manually later

**If "Integrate + Verify":**
1. Run `/jaan-to:dev-output-integrate "{OUTPUT_FOLDER}"`
2. After integration, run `/jaan-to:frontend-visual-verify "{component_path}"`
3. Report final verification result

**If "Integrate only":**
1. Run `/jaan-to:dev-output-integrate "{OUTPUT_FOLDER}"`
2. Suggest running `/jaan-to:frontend-visual-verify` afterward

**If "Save patches only":**
1. Confirm output path
2. Suggest manual integration and verification

## Step 11: Capture Feedback

Use AskUserQuestion:
- Question: "How did the fix turn out?"
- Header: "Feedback"
- Options:
  - "Fixed!" — Done
  - "Still broken" — Describe remaining issue
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add frontend-component-fix "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Output-only safety model (never edits project source)
- Guided single-run mode collapses 3-skill chain into one approval
- MCP-enhanced with graceful degradation
- Patches routed through dev-output-integrate for safe application

## Definition of Done

- [ ] Root cause identified with confidence level
- [ ] Minimal fix patch generated (no unnecessary changes)
- [ ] Component API preserved (no breaking changes)
- [ ] Patched files written to $JAAN_OUTPUTS_DIR only (never source)
- [ ] Before/after diff included in report
- [ ] Integration readme with Source → Destination table
- [ ] Guided next-action flow offered to user
- [ ] Output follows v3.0.0 structure (ID, folder, index)
- [ ] User approved final result
