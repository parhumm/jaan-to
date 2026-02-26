---
name: frontend-visual-verify
description: Visual verification of UI components via Storybook snapshots and Playwright MCP. Use when verifying component rendering.
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(mkdir:*), Bash(stat:*), mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_tabs, mcp__storybook-mcp__get-story-urls, Write($JAAN_OUTPUTS_DIR/frontend/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[storybook-url or component-path or frontend-design output]"
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# frontend-visual-verify

> Visual verification of UI components via Storybook accessibility snapshots and Playwright MCP.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional)
- `$JAAN_CONTEXT_DIR/design.md` - Design system guidelines (optional, `#visual-standards` and `#storybook` sections)
- `$JAAN_TEMPLATES_DIR/jaan-to-frontend-visual-verify.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-frontend-visual-verify.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md` - Shared reference (visual scoring rubric, network policy, MCP degradation)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Arguments**: $ARGUMENTS

Accepts any of:
- **Storybook URL** — `http://localhost:6006/?path=/story/{component}` (localhost only by default)
- **Component path** — Path to component file (derives Storybook URL from naming)
- **frontend-design output** — Path to design output folder (reads preview HTML)
- **Reference description** — Text describing expected visual appearance
- **Empty** — Interactive wizard

If no input provided, ask: "What component should I verify? (Storybook URL, component path, or design output path)"

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `frontend-visual-verify`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/design.md` — Visual standards, accessibility targets

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_frontend-visual-verify`

> **Language exception**: Generated code output remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Determining verification mode (visual vs static)
- Planning verification checklist from component requirements
- Analyzing accessibility tree structure
- Comparing visual output against design specs

## Step 1: Determine Output Mode

Check Playwright MCP availability:

1. Attempt to use `mcp__playwright__browser_snapshot` (any lightweight call)
2. If available: set `output_mode = visual-mode`
3. If unavailable: set `output_mode = static-mode`

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "MCP Graceful Degradation Patterns" — Playwright MCP section.

**Display mode to user:**
- `visual-mode`: "Playwright MCP detected — full visual verification available."
- `static-mode`: "Playwright MCP not available — static code analysis only. Visual score will be N/A."

## Step 2: Validate URL / Resolve Target

**URL validation** (CRITICAL — localhost-only default):

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "Playwright Network Policy" for URL validation rules.

1. If URL provided: validate against allowed patterns (`localhost:*`, `127.0.0.1:*`)
2. If external URL: require explicit per-URL user confirmation via AskUserQuestion
3. If component path: construct Storybook URL from component naming convention
4. If design output: use preview HTML path directly

**If MCP tool `mcp__storybook-mcp__get-story-urls` available:**
- Use it to get accurate story URLs for the component
- Fallback: construct URL as `http://localhost:6006/?path=/story/{component-id}--{story-name}`

Present target summary:
```
VERIFICATION TARGET
───────────────────
Component:    {name}
URL:          {storybook_url or preview_path}
Mode:         {visual-mode / static-mode}
Reference:    {design description or N/A}
```

## Step 3: Read Component Source

Regardless of mode, read the component source for code-level analysis:

1. **Read component file** — Props, structure, accessibility attributes
2. **Read stories file** (if exists) — Story states to verify
3. **Check design.md** — Visual standards (breakpoints, contrast, animation)
4. **Check for CVA variants** — `Grep: "cva(" {component_path}`

Build verification checklist:
```
VERIFICATION CHECKLIST
──────────────────────
Rendering:
  [ ] Component renders without errors
  [ ] All props/variants render correctly
  [ ] Loading/error/empty states work

Accessibility:
  [ ] ARIA attributes present and correct
  [ ] Keyboard navigation functional
  [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
  [ ] Focus indicators visible

Visual:
  [ ] Layout matches design intent
  [ ] Typography hierarchy correct
  [ ] Spacing consistent with design system
  [ ] Responsive at key breakpoints
  [ ] Dark mode (if applicable)
```

---

# HARD STOP — Review Verification Plan

Present verification plan to user.

Use AskUserQuestion:
- Question: "Proceed with verification?"
- Header: "Verify"
- Options:
  - "Yes" — Run full verification
  - "No" — Cancel
  - "Edit" — Adjust checklist items

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Verification (Execute Phase)

## Step 4: Execute Verification

### visual-mode (Playwright MCP available)

1. **Navigate**: `mcp__playwright__browser_navigate` to Storybook URL
2. **Snapshot**: `mcp__playwright__browser_snapshot` — Get accessibility tree (primary, fast, deterministic)
3. **Analyze accessibility tree**:
   - Check ARIA roles and labels
   - Verify heading hierarchy
   - Check interactive element accessibility
   - Validate form labels and associations
4. **Screenshot**: `mcp__playwright__browser_take_screenshot` — Capture visual state
5. **Repeat** for each story state (Default, Loading, Error, variants)
6. **Responsive check**: Resize and re-snapshot at breakpoints (if applicable)

### static-mode (No Playwright)

1. **Read component source** — Analyze code structure
2. **Check accessibility attributes** — Grep for ARIA, semantic HTML
3. **Analyze CSS classes** — Check for responsive utilities, color tokens
4. **Review prop types** — Validate TypeScript correctness
5. **Cross-reference design.md** — Check against visual standards

**No visual score in static-mode.** Report header: "Static analysis only — visual verification requires Playwright MCP."

## Step 5: Score Results

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "Visual Scoring Rubric" for score definitions.

### visual-mode scoring (0-10)

Evaluate against rubric criteria:
- Rendering correctness (all states)
- Accessibility tree completeness
- Visual consistency with design system
- Responsive behavior
- Interactive states

### static-mode scoring

- Visual score: **N/A**
- Code quality findings only
- Cannot make visual pass/fail conclusions

## Step 6: Generate Report

Read template: `$JAAN_TEMPLATES_DIR/jaan-to-frontend-visual-verify.template.md`

Fill sections:
- **Executive Summary**: Component name, mode, score, pass/fail
- **Verification Results**: Checklist with pass/fail per item
- **Accessibility Findings**: ARIA, keyboard, contrast results
- **Visual Findings**: Layout, typography, spacing (visual-mode only)
- **Screenshots**: Captured screenshots (visual-mode only)
- **Recommendations**: Suggested fixes with severity
- **Metadata**: Generated date, skill version, mode

## Step 7: Quality Check

- [ ] All checklist items evaluated
- [ ] Score matches rubric criteria
- [ ] static-mode report does NOT claim visual pass/fail
- [ ] Recommendations are actionable
- [ ] Screenshots captured (visual-mode only)

## Step 8: Preview & Write Output

Show verification summary with score and key findings.

Use AskUserQuestion:
- Question: "Write verification report?"
- Header: "Write Report"
- Options:
  - "Yes" — Write report files
  - "No" — Cancel

## Step 9: Generate ID and Write Output

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/frontend/visual-verify"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{component-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Write files:
1. `mkdir -p "$OUTPUT_FOLDER"`
2. Write `{id}-{slug}.md` — Verification report
3. Write `{id}-{slug}-screenshots/` — Captured screenshots (visual-mode only)
4. Write `{id}-{slug}-readme.md` — Summary with pass/fail and next actions
5. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{ComponentName} Verification" \
  "{mode}: score {score}/10 — {pass_count}/{total_count} checks passed"
```

## Step 10: Suggest Next Actions

> **Verification complete!**
>
> **Results**: {score}/10 — {pass_count}/{total_count} checks passed
>
> **Next Steps:**
> - Run `/jaan-to:frontend-component-fix` to fix identified issues
> - Run `/jaan-to:frontend-story-generate` to add missing story states
> - Run `/jaan-to:qa-test-cases` to generate test cases from findings
> - Re-run `/jaan-to:frontend-visual-verify` after fixes to confirm

## Step 11: Capture Feedback

Use AskUserQuestion:
- Question: "How did the verification turn out?"
- Header: "Feedback"
- Options:
  - "Useful!" — Done
  - "Needs improvement" — What should change?
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add frontend-visual-verify "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Dual output modes: visual-mode (Playwright) vs static-mode (code-only)
- Localhost-only network default with explicit external URL confirmation
- MCP-enhanced with graceful degradation
- No false confidence in static-mode (visual score = N/A)

## Definition of Done

- [ ] Output mode determined and displayed to user
- [ ] URL validated (localhost-only by default)
- [ ] All checklist items evaluated
- [ ] Score assigned per rubric (N/A in static-mode)
- [ ] static-mode report does NOT make visual pass/fail claims
- [ ] Screenshots captured (visual-mode only)
- [ ] Recommendations are actionable
- [ ] Report written with readme for integration
- [ ] Output follows v3.0.0 structure (ID, folder, index)
- [ ] User approved final result
