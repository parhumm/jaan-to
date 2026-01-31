---
name: jaan-to-data-gtm-datalayer
description: |
  Generate production-ready GTM tracking code (dataLayer pushes and HTML attributes).
  Auto-triggers on: gtm tracking, datalayer push, tracking code, impression tracking, click tracking gtm, al_tracker.
  Maps to: jaan-to-data-gtm-datalayer
allowed-tools: Read, Glob, Grep, Write(.jaan-to/**)
argument-hint: [prd-path | tracking-description | (interactive)]
---

# jaan-to-data-gtm-datalayer

> Generate production-ready GTM tracking code with enforced naming conventions.

## Context Files

- `.jaan-to/learn/jaan-to-data-gtm-datalayer.learn.md` - Past lessons (loaded in Pre-Execution)
- `.jaan-to/templates/jaan-to-data-gtm-datalayer.template.md` - Output template

## Input

**Tracking Request**: $ARGUMENTS

- If PRD path provided → Read and suggest tracking points
- If text description provided → Design tracking based on input
- If empty → Start interactive wizard

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`.jaan-to/learn/jaan-to-data-gtm-datalayer.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Determine Input Mode

Check $ARGUMENTS:

**Mode A - PRD Input:**
If path to `.jaan-to/outputs/` or PRD text provided:
1. Read/parse the PRD
2. Identify trackable interactions (buttons, forms, modals, etc.)
3. Suggest tracking points with types:
   - Impressions: modal displays, section visibility
   - Clicks: buttons, links, interactive elements
   - Include non-happy paths (close, dismiss, cancel)
4. Ask user to confirm/modify suggestions

**Mode B - Description Input:**
If text description of what to track:
1. Parse the description
2. Ask clarifying questions if needed
3. Suggest tracking structure

**Mode C - Interactive Wizard:**
If no arguments, ask questions in order:

### Question 1: Tracking Type
> "What type of tracking do you need?"
> 1. **click-html** - HTML attributes (data-al-*) for simple clicks
> 2. **click-datalayer** - dataLayer.push for flow-based clicks
> 3. **impression** - dataLayer.push for visibility/exposure events

### Question 2: Feature Name
> "What is the feature name? (e.g., player, checkout, onboarding)"

Apply naming rules:
- Convert to lowercase-kebab-case: "Play Button" → "play-button"
- If unclear (e.g., "btn1", "x"), ask: "What does '{input}' represent?"
- Suggest better name if abbreviated: "nav" → suggest "navigation" or "navbar"
- Confirm conversion: "Feature 'Play Button' → 'play-button' - OK? [y/edit]"

### Question 3: Item Name
> "What is the item name? (e.g., play, pause, submit, modal-purchase)"

Apply same naming rules as feature.

### Question 4: Action (click-datalayer only)
> "What is the action? (default: Click)"

If user provides custom action, apply naming rules.
If empty/skipped, use "Click".

### Question 5: Additional Params (optional)
> "Any additional params? Enter as key=value, one per line. (or 'skip')"

Example:
```
source=modal
count=3
active=true
```

Parse into object with **ES5 type detection**:
- `true` / `false` → bool (no quotes): `true`
- Numeric values (e.g., `3`, `42`) → int (no quotes): `3`
- Everything else → string (with quotes): `"modal"`

If none provided, omit params entirely from output.

## Step 2: Confirm Values

Show full dataLayer preview before generating:

**For click-html:**
```
TRACKING SUMMARY
────────────────────────────────────────

<button data-al-feature="{feature}" data-al-item="{item}">...</button>

────────────────────────────────────────
```

**For click-datalayer (without params):**
```
TRACKING SUMMARY
────────────────────────────────────────

dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "{feature}",
    item: "{item}",
    action: "{action}"
  },
  _clear: true
});

────────────────────────────────────────
```

**For click-datalayer (with params):**
```
TRACKING SUMMARY
────────────────────────────────────────

dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "{feature}",
    item: "{item}",
    action: "{action}",
    params: {
      source: "modal",
      count: 3,
      active: true,
    }
  },
  _clear: true
});

────────────────────────────────────────
```
Values are typed: strings in `"quotes"`, ints/bools without quotes.

**For impression (without params):**
```
TRACKING SUMMARY
────────────────────────────────────────

dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "{feature}",
    item: "{item}"
  },
  _clear: true
});

────────────────────────────────────────
```

**For impression (with params):**
```
TRACKING SUMMARY
────────────────────────────────────────

dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "{feature}",
    item: "{item}",
    params: {
      variant: "A",
      position: 1,
      visible: true,
    }
  },
  _clear: true
});

────────────────────────────────────────
```

> "Generate tracking code with these values? [y/edit]"

---

# HARD STOP - Human Review Check

Show the full dataLayer preview above (not just field summary).

> "Proceed with code generation? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate Code

Based on tracking type, generate the appropriate code:

### Type: click-html

```html
<element data-al-feature="{feature}" data-al-item="{item}">{element content}</element>
```

Example output:
```html
<button data-al-feature="player" data-al-item="pause">Pause</button>
```

### Type: click-datalayer

Without params:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "{feature}",
    item: "{item}",
    action: "{action}"
  },
  _clear: true
});
```

With params (ES5 typed values):
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "{feature}",
    item: "{item}",
    action: "{action}",
    params: {
      {key1}: {value1},  // string: "value", int: 3, bool: true
      {key2}: {value2},
    }
  },
  _clear: true
});
```

### Type: impression

Without params:
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "{feature}",
    item: "{item}"
  },
  _clear: true
});
```

With params (ES5 typed values):
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "{feature}",
    item: "{item}",
    params: {
      {key1}: {value1},  // string: "value", int: 3, bool: true
      {key2}: {value2},
    }
  },
  _clear: true
});
```

## Step 4: Quality Check

Before preview, verify:
- [ ] `event` key present in all dataLayer pushes
- [ ] Feature and item are non-empty strings
- [ ] Feature/item/action are lowercase-kebab-case
- [ ] No abbreviations without user clarification
- [ ] Names are descriptive and understandable
- [ ] User-provided strings preserved (after kebab conversion)
- [ ] `_clear: true` included in all dataLayer pushes
- [ ] No empty `params: {}` (omit entirely if no params)
- [ ] Param values use correct ES5 types (string in `"quotes"`, int/bool without)
- [ ] Output is deterministic (same input → same code)

If any check fails, fix before preview.

## Step 5: Preview & Approval

Display the generated code in conversation:

```
GENERATED TRACKING CODE
───────────────────────

{code block}

EXAMPLE WITH VALUES
───────────────────
{example showing real values based on user input}
```

> "Save to `.jaan-to/outputs/data/gtm/{slug}/tracking.md`? [y/n]"

## Step 6: Write Output

If approved:
1. Generate slug from feature-item (e.g., "player-pause")
2. Create path: `.jaan-to/outputs/data/gtm/{slug}/tracking.md`
3. Use template from `.jaan-to/templates/jaan-to-data-gtm-datalayer.template.md`
4. Write file
5. Confirm: "Written to {path}"

## Step 7: Capture Feedback

> "Any feedback? [y/n]"

If yes:
> "[1] Fix now  [2] Learn for future  [3] Both"

- **Option 1**: Update output, re-preview, re-write
- **Option 2**: Run `/to-jaan-learn-add jaan-to-data-gtm-datalayer "{feedback}"`
- **Option 3**: Do both

---

## Definition of Done

- [ ] User confirmed tracking values
- [ ] Code generated and displayed in conversation
- [ ] Markdown file written to `.jaan-to/outputs/data/gtm/{slug}/`
- [ ] User can copy-paste and use immediately
