---
name: frontend-story-generate
description: Generate CSF3 Storybook stories for components with variant coverage and state matrices. Use when creating component stories.
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(mkdir:*), Bash(stat:*), mcp__storybook-mcp__get-ui-building-instructions, mcp__storybook-mcp__list-all-components, mcp__storybook-mcp__get-component-documentation, mcp__shadcn__get_component_details, mcp__shadcn__list_shadcn_components, Write($JAAN_OUTPUTS_DIR/frontend/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[component-path or frontend-design/frontend-scaffold output]"
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
disable-model-invocation: true
---

# frontend-story-generate

> Generate CSF3 Storybook stories for components with variant coverage and state matrices.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional)
- `$JAAN_CONTEXT_DIR/design.md` - Design system guidelines (optional, `#storybook` and `#conventions` sections)
- `$JAAN_TEMPLATES_DIR/jaan-to-frontend-story-generate.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-frontend-story-generate.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md` - Shared reference (CSF3 format, CVA detection, MCP degradation)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Arguments**: $ARGUMENTS

Accepts any of:
- **Component file path** — Direct path to a `.tsx`/`.jsx`/`.vue` component file
- **frontend-design output** — Path to design output folder (reads code file + preview)
- **frontend-scaffold output** — Path to scaffold output folder (reads components file)
- **Empty** — Scan project for components missing stories

If no input provided, ask: "Which component should I generate stories for? (path, or 'scan' to find components without stories)"

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `frontend-story-generate`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/design.md` — Storybook conventions, component library info

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_frontend-story-generate`

> **Language exception**: Generated code output remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing component props, variants, and states
- Planning story coverage matrix
- Detecting CVA variant patterns
- Mapping prop types to argTypes controls

## Step 1: Parse Input

Determine input type and extract component information:

**If component path**: Read the file, extract component name, props interface, exports
**If frontend-design/scaffold output**: Read the output folder, find code files
**If empty (scan mode)**:
1. `Glob: src/**/*.tsx` to find all components
2. `Glob: src/**/*.stories.tsx` to find existing stories
3. Compute difference — list components without stories
4. Present list and ask which to generate

Present input summary:
```
STORY GENERATION INPUT
──────────────────────
Component(s):     {list with file paths}
Existing Stories: {count found / count missing}
Framework:        {React/Vue detected from extension and imports}
```

## Step 2: Analyze Component

For each target component:

1. **Read component source** — Extract:
   - Component name and export type (default/named)
   - Props interface or type definition
   - Default prop values
   - Imported types and dependencies

2. **Detect variant system**:

   > **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
   > section "CVA Variant Detection" for grep patterns.

   - `Grep: "cva(" {component_path}` — CVA usage
   - `Grep: "variants:" {component_path}` — Variant definitions
   - `Grep: "defaultVariants:" {component_path}` — Defaults
   - Extract variant keys and possible values

3. **MCP enrichment** (optional, graceful degradation):
   - Try `mcp__storybook-mcp__get-ui-building-instructions` for project CSF conventions
   - Try `mcp__storybook-mcp__get-component-documentation` for existing docs
   - If MCP unavailable: read existing `*.stories.tsx` files to infer conventions
   - Log: "Storybook MCP not available — using source file analysis"

4. **Check existing stories**: `Glob: {component_dir}/*.stories.tsx`
   - If stories exist: analyze for convention patterns (meta format, naming, args style)
   - Note conventions to maintain consistency

## Step 3: Plan Story Coverage

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "Component State Coverage Matrix" for required states.

Build coverage matrix per component:

```
STORY COVERAGE PLAN
───────────────────
Component: {ComponentName}
Props: {count} ({list})
Variants: {count from CVA} ({list})

Stories to Generate:
  Default         — Base state with default props
  Loading         — {yes/N/A} — Skeleton or spinner
  Error           — {yes/N/A} — Error message state
  Empty           — {yes/N/A} — No-data state
  Disabled        — {yes/N/A} — Disabled form elements
  {Variant1}      — CVA variant: {value}
  {Variant2}      — CVA variant: {value}
  {EdgeCase}      — Long text / RTL / etc.

Total: {count} stories
```

## Step 4: Map Props to Controls

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "argTypes Controls" for type mapping table.

Map each prop to appropriate Storybook control type based on TypeScript type.

---

# HARD STOP — Review Story Plan

Present coverage plan to user.

Use AskUserQuestion:
- Question: "Generate these stories?"
- Header: "Story Plan"
- Options:
  - "Yes" — Generate all planned stories
  - "No" — Cancel
  - "Edit" — Adjust coverage (add/remove stories)

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 5: Generate CSF3 Stories

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/frontend-ui-workflow-reference.md`
> section "CSF3 Story Format Spec" for the base template and rules.

For each component, generate a CSF3 story file:

1. Create `meta` with `Meta<typeof ComponentName>`
2. Set `tags: ['autodocs']` for automatic documentation
3. Define `argTypes` from Step 4 mapping
4. Generate each story from coverage plan as `StoryObj<typeof meta>`
5. Use declarative `args` objects (not render functions)
6. Add `includeStories` / `excludeStories` if data exports needed
7. Match existing project conventions (from Step 2.4)

## Step 6: Generate Documentation

Read template: `$JAAN_TEMPLATES_DIR/jaan-to-frontend-story-generate.template.md`

Fill sections:
- **Executive Summary**: Component name, story count, variant coverage
- **Coverage Matrix**: Table of all stories with state and description
- **Props API**: Props table with types and controls
- **Integration**: How to add stories to project
- **Metadata**: Generated date, skill version

## Step 7: Quality Check

- [ ] CSF3 format valid (`Meta<typeof Component>` + `StoryObj<typeof meta>`)
- [ ] All coverage matrix states included
- [ ] CVA variants each have a story
- [ ] argTypes controls match prop types
- [ ] Declarative args only (no render functions)
- [ ] Import paths are correct
- [ ] Component name matches source export
- [ ] `tags: ['autodocs']` present

If any check fails, fix before proceeding.

## Step 8: Preview & Approval

Show generated stories code preview and coverage summary.

Use AskUserQuestion:
- Question: "Write story files to output?"
- Header: "Write Files"
- Options:
  - "Yes" — Write the files
  - "No" — Cancel
  - "Refine" — Make adjustments first

## Step 9: Generate ID and Write Output

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/frontend/story"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{component-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Write files:
1. `mkdir -p "$OUTPUT_FOLDER"`
2. Write `{id}-{slug}.md` — Documentation
3. Write `{id}-{slug}-stories.tsx` — CSF3 stories
4. Write `{id}-{slug}-readme.md` — Integration readme with Source → Destination table
5. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{ComponentName} Stories" \
  "{Executive summary — stories for ComponentName covering N states}"
```

Confirm:
> Files written to: `$JAAN_OUTPUTS_DIR/frontend/story/{NEXT_ID}-{slug}/`

## Step 10: Suggest Next Actions

> **Stories generated successfully!**
>
> **Next Steps:**
> - Run `/jaan-to:dev-output-integrate` to copy stories into your project
> - Run `/jaan-to:frontend-visual-verify` to visually verify components via Storybook
> - Start Storybook: `npm run storybook` to see stories in the catalog
> - Run `/jaan-to:frontend-component-fix` if any visual issues found

## Step 11: Capture Feedback

Use AskUserQuestion:
- Question: "How did the stories turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" — Done
  - "Needs fixes" — What should I improve?
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add frontend-story-generate "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- MCP-enhanced with graceful degradation (works without MCP)
- Shared reference extraction avoids token duplication
- Output to standardized `$JAAN_OUTPUTS_DIR` path with dev-output-integrate compatibility

## Definition of Done

- [ ] CSF3 stories generated for all target components
- [ ] Coverage matrix fully addressed (Default, Loading, Error, Empty, variants)
- [ ] CVA variants detected and covered
- [ ] argTypes controls mapped correctly
- [ ] Integration readme with Source → Destination table
- [ ] Output follows v3.0.0 structure (ID, folder, index)
- [ ] Index updated with executive summary
- [ ] User approved final result
