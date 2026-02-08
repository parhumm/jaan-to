---
name: ux-microcopy-write
description: Generate multi-language microcopy packs for UI components with cultural adaptation and RTL/LTR handling.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/**), Write($JAAN_CONTEXT_DIR/localization.md), Write($JAAN_CONTEXT_DIR/tone-of-voice.md), WebSearch, Task, AskUserQuestion, Bash, Edit(jaan-to/config/settings.yaml)
argument-hint: [initiative-or-feature-description]
---

# ux-microcopy-write

> Generate multi-language microcopy packs for UI components.

## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_CONTEXT_DIR/localization.md` - Language preferences (auto-created if missing)
- `$JAAN_CONTEXT_DIR/tone-of-voice.md` - Tone guidelines (auto-created if missing)
- `$JAAN_TEMPLATES_DIR/jaan-to:ux-microcopy-write.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:ux-microcopy-write.learn.md` - Past lessons (loaded in Pre-Execution)

## Input

**Initiative**: $ARGUMENTS

IMPORTANT: The initiative/feature description above is your input. Use it directly. Do NOT ask for the initiative again.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:ux-microcopy-write.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Phase 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_ux-microcopy-write` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

> **Language exception**: This setting controls only plugin conversation language. The multi-language microcopy output is independently controlled by `$JAAN_CONTEXT_DIR/localization.md` and this skill's own Language Selection step.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Language Selection

Check if language preferences already exist:

Use Read tool on: `$JAAN_CONTEXT_DIR/localization.md`

**If file exists**:
- Show current enabled languages
- Use AskUserQuestion:
  - Question: "Use saved language preferences or modify?"
  - Header: "Languages"
  - Options:
    - "Use saved" — Use languages from localization.md
    - "Modify" — Let me change the language selection

**If file does NOT exist OR user selected "Modify"**:

Show available languages:
- **EN** (English) - LTR, Latin
- **FA** (فارسی / Persian) - RTL, Perso-Arabic
- **TR** (Türkçe / Turkish) - LTR, Latin
- **DE** (Deutsch / German) - LTR, Latin (+30-35% text expansion)
- **FR** (Français / French) - LTR, Latin (+15-25% text expansion)
- **RU** (Русский / Russian) - LTR, Cyrillic (3-form pluralization)
- **TG** (Тоҷикӣ / Tajik) - LTR, Cyrillic

Use AskUserQuestion:
- Question: "Which languages do you need microcopy for?"
- Header: "Language Selection"
- Options:
  - "All 7" — Generate for all languages
  - "Common Set (EN, FA, TR)" — Most requested trio
  - "Custom" — Let me select specific languages

If "Custom" selected:
- Ask: "Enter comma-separated language codes (e.g., en,fa,de,ru)"
- Parse and validate codes
- Show selected languages for confirmation

**Write language preferences to**: `$JAAN_CONTEXT_DIR/localization.md`
- Use template structure from seed file
- Mark enabled languages
- Include RTL handling notes for Persian

## Step 2: Tone-of-Voice Discovery

Check if tone preferences already exist:

Use Read tool on: `$JAAN_CONTEXT_DIR/tone-of-voice.md`

**If file exists**:
- Show current tone profile
- Use AskUserQuestion:
  - Question: "Use saved tone-of-voice or modify?"
  - Header: "Tone"
  - Options:
    - "Use saved" — Use tone from tone-of-voice.md
    - "Modify" — Let me change the tone profile

**If file does NOT exist OR user selected "Modify"**:

Use AskUserQuestion:
- Question: "What tone should the microcopy have?"
- Header: "Tone Profile"
- Options:
  - "Professional & Formal" — Banking, B2B, enterprise (Sie, Вы, شما formal pronouns)
  - "Friendly & Conversational" — Consumer apps, social (du, ты, تو informal pronouns)
  - "Sample-based" — I'll provide example text to match

If "Sample-based" selected:
- Ask: "Provide 2-3 example sentences from your current UI"
- Analyze tone characteristics:
  - Formality level (formal/semi-formal/informal)
  - Warmth (warm/neutral/direct)
  - Directness (specific/general)
  - Emotion (empathetic/neutral/celebratory)
- Show extracted tone profile:
  ```
  TONE PROFILE DETECTED
  ─────────────────────
  Formality: {level}
  Warmth: {level}
  Directness: {level}
  Emotion: {level}

  Language-specific pronouns:
  - Persian: {شما/تو}
  - Russian: {Вы/ты}
  - German: {Sie/du}
  - Turkish: {Siz/sen}
  - French: {Vous/tu}
  ```
- Ask: "Use this tone profile? [y/n]"
- If no, ask again for refinement

**Write tone profile to**: `$JAAN_CONTEXT_DIR/tone-of-voice.md`
- Use template structure from seed file
- Include language-specific formality rules
- Add example microcopy for reference

## Step 3: Category Detection & Selection

Analyze initiative/feature description for microcopy needs using keyword detection:

**Smart detection rules**:
- Keywords: "form", "validation", "input" → **Error Messages**, **Helper Text**, **Labels**
- Keywords: "modal", "dialog", "confirm" → **Confirmation Dialogs**, **CTAs**
- Keywords: "empty", "first-time", "no data" → **Empty States**
- Keywords: "notification", "toast", "alert" → **Toast Notifications**, **Success Messages**
- Keywords: "button", "action", "submit" → **CTAs**, **Labels**
- Keywords: "loading", "progress" → **Loading States**

Show detected categories + additional common ones:
```
SMART CATEGORY DETECTION
────────────────────────
Based on your initiative, I detected these categories:
✓ {detected category 1}
✓ {detected category 2}
✓ {detected category 3}

Additional common categories:
○ {suggested category 1}
○ {suggested category 2}
```

**Available microcopy categories** (11 total):
1. Labels & Buttons
2. Helper Text
3. Error Messages (with recovery instructions)
4. Success Messages
5. Toast Notifications
6. Confirmation Dialogs
7. Empty States
8. Loading States
9. Tooltips
10. Placeholders
11. Call-to-Action buttons

Use AskUserQuestion:
- Question: "Which categories do you need?"
- Header: "Categories"
- Options:
  - "Detected set" — Use auto-detected categories
  - "Core set" — Labels, Errors, CTAs, Success (4 categories)
  - "Full set" — All 11 categories
  - "Custom" — Let me select specific categories

If "Custom" selected:
- Show checklist of all 11 categories
- Ask for comma-separated list or numbered selection
- Confirm selected categories

## Step 4: Item Inventory

For each selected category, build inventory of items needed:

**For each category**, show common examples and ask:

**Example for Labels & Buttons**:
> "How many button labels do you need?
>
> Common examples:
> - Save, Save changes, Save draft
> - Cancel, Close, Dismiss
> - Delete, Remove, Clear
> - Confirm, Yes, No
> - Submit, Send, Share
> - Edit, Update, Modify
>
> Enter number of items (or 'skip' for none):"

**Example for Error Messages**:
> "How many error messages do you need?
>
> Common examples:
> - Email validation (invalid format)
> - Password requirements (too short, weak)
> - Network errors (no connection, timeout)
> - Required field (empty field)
> - File upload (too large, wrong type)
>
> Enter number of items (or 'skip' for none):"

After gathering counts, build complete inventory list:
```
ITEM INVENTORY
──────────────
Labels & Buttons: 8 items
Error Messages: 5 items
Success Messages: 3 items
CTAs: 6 items

Total: 22 items across 4 categories
```

---

# HARD STOP - Human Review Check

Show complete plan before proceeding:

```
MICROCOPY GENERATION PLAN
──────────────────────────
Languages: {list with native names} ({n} languages)
Tone Profile: {tone summary}
Categories: {selected categories} ({n} categories)
Total Items: {count} items

Process:
1. Generate 3 English options per item
2. Iterate up to 5 rounds if needed
3. Support custom user input
4. Translate to all {n} languages
5. Cultural adaptation per language
6. RTL handling for Persian
7. Quality validation checklist

Output Files:
- $JAAN_OUTPUTS_DIR/ux/content/{id}-{slug}/{id}-microcopy-{slug}.md
- $JAAN_OUTPUTS_DIR/ux/content/{id}-{slug}/{id}-microcopy-{slug}.json
```

Use AskUserQuestion:
- Question: "Proceed with microcopy generation?"
- Header: "Proceed"
- Options:
  - "Yes" — Start generating microcopy
  - "Edit" — Let me modify the plan
  - "No" — Cancel

If "Edit": Return to appropriate step based on user feedback

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 5: Generate Microcopy (Per Item, Per Category)

For each item in inventory:

### 5.1: Show Context

```
GENERATING ITEM {current}/{total}
──────────────────────────────────
Category: {category_name}
Item Type: {item_description}
Tone: {tone_profile}
```

### 5.2: Initial English Generation

Generate 3 options in English following best practices:

**For Error Messages**:
- Structure: What happened + How to fix
- Use verbs, be specific
- No blame language
- Example: "Email address is required. Please enter your email to continue."

**For CTAs/Labels**:
- Action verb, specific
- 1-3 words max
- Example: "Save changes", "Delete item", "Send message"

**For Empty States**:
- 3-part structure: Headline + Motivation + CTA
- Example: "No projects yet" + "Create your first project to get started" + "Create project"

**For Success Messages**:
- Celebrate (minimal) + Confirm
- Example: "Email verified! Welcome aboard."

Show 3 options to user:
```
Option 1: {text1}
Option 2: {text2}
Option 3: {text3}
```

### 5.3: Options Iteration Loop

Use AskUserQuestion:
- Question: "Which option do you prefer?"
- Header: "Select Option"
- Options:
  - "Option 1" — Use first option
  - "Option 2" — Use second option
  - "Option 3" — Use third option
  - "My own" — I'll write my own version
  - "More" — Show 3 more options

**If "My own" selected**:
1. Ask: "Enter your custom text:"
2. Show: "Your text: {user_text}"
3. Generate 3 more options in same style/tone
4. Show: "Here are 3 variations in the same style:"
   - Option A: {variation1}
   - Option B: {variation2}
   - Option C: {variation3}
5. Use AskUserQuestion with 5 options:
   - "Use my text" — Use exact user text
   - "Option A/B/C" — Use variation
   - "More" — Generate 3 more variations
6. Loop back to selection

**If "More" selected**:
1. Increment round counter
2. If round <= 5:
   - Generate 3 NEW options (different from previous)
   - Show options
   - Loop back to selection
3. If round > 5:
   - Show: "⚠️ Last round of suggestions"
   - Generate 3 final options
   - Add emphasis: "Or select 'My own' to write your own text"
   - Loop back to selection

**If "Option 1/2/3" selected**:
- Save as approved English version
- Proceed to Step 5.4

### 5.4: Multi-Language Translation

For each selected language, translate approved English text with cultural adaptation:

**Persian (FA)**:
- Use formal شما pronoun (unless tone is informal → تو)
- Warm, polite tone
- Add ZWNJ (Zero-Width Non-Joiner) for plurals: کاربرها‌
- Use Persian punctuation: ؟ ، ؛ « »
- Mark as RTL
- Western numerals (0-9) for UI pragmatism

**Russian (RU)**:
- Use formal Вы pronoun (unless tone is informal → ты)
- Direct, factual tone
- Minimize apologies—focus on solution
- Handle 3-form pluralization
- Mark as LTR, Cyrillic script

**German (DE)**:
- Use formal Sie pronoun (or du if tone is informal)
- Precise, non-blaming language
- Expect +30-35% text expansion
- No overapologizing

**Turkish (TR)**:
- Use formal Siz pronoun (or sen if tone is informal)
- Polite, respectful
- Agglutinative language—single words can be long
- Expect +22-33% text expansion

**French (FR)**:
- Use formal Vous pronoun (or tu if tone is informal)
- Elegant phrasing
- Apologetic conditional for errors
- Expect +15-25% text expansion

**Tajik (TG)**:
- Use formal Шумо pronoun
- Cyrillic script handling
- Similar to Persian culturally
- Mark as LTR

Store translations in memory for output generation.

### 5.5: Track Progress

After each item completed, show:
```
✓ Item {current}/{total} completed
  Category: {category}
  EN: {english_text}
  Translated to {n} languages
```

Continue loop until all items completed.

## Step 6: Quality Validation Checklist

Before writing output, validate all generated microcopy:

**Universal Checks**:
- [ ] All {n} items have all {n} languages
- [ ] Tone consistency across all items (formal/informal pronouns consistent)
- [ ] Grammar check for each language (use WebSearch if uncertain)
- [ ] Reading level 7-8th grade (English baseline)
- [ ] No ambiguous language
- [ ] Error messages include recovery instructions

**Language-Specific Checks**:
- [ ] **Persian**: شما consistency, Persian punctuation (؟ ، ؛), ZWNJ for plurals, RTL flag set
- [ ] **Russian**: Вы consistency, factual tone, no blame language
- [ ] **German**: Sie/du consistency, precise language, no overapologies
- [ ] **Turkish**: Siz/sen consistency, politeness markers
- [ ] **French**: Vous/tu consistency, elegant phrasing
- [ ] **All RTL languages**: Direction metadata correct (rtl for FA)

**Cultural Adaptation**:
- [ ] No literal translations—culturally adapted per language
- [ ] Formality level matches tone profile for each language
- [ ] Longest text (German/Turkish/Persian) noted for UI constraints

If any check fails:
- Fix issues
- Re-validate
- Continue when all checks pass

## Step 7: Preview Output

Source ID generator and generate next ID:

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/ux/content"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

Generate slug from feature name:
- Lowercase
- Replace spaces/special chars with hyphens
- Max 50 characters
- Example: "User Authentication" → "user-authentication"

Generate executive summary:
```
Multi-language microcopy pack for {feature_name} covering {n} categories ({category_list}) in {n} languages ({language_list}). Includes culturally-adapted copy with RTL support for Persian/Farsi and tone-of-voice consistency across all languages.
```

Show complete output preview:

```markdown
OUTPUT PREVIEW
──────────────
ID: {NEXT_ID}
Folder: $JAAN_OUTPUTS_DIR/ux/content/{NEXT_ID}-{slug}/
Main File: {NEXT_ID}-microcopy-{slug}.md
JSON File: {NEXT_ID}-microcopy-{slug}.json

# Microcopy Pack: {Feature Name}

## Executive Summary

{executive_summary}

---

## Metadata
- Languages: {EN, FA, TR, ...}
- Tone Profile: {tone_summary}
- Categories: {category_list}
- Generated: {YYYY-MM-DD}

⚠️ **Native Speaker Review Required**
AI achieves ~88-92% accuracy on culturally-nuanced microcopy.
Please have native speakers review all non-English content before production use.

---

## Category: {Category 1}

### {Item 1 Name}

- **EN** (LTR): {text}
- **FA** (RTL): {text}
- **TR** (LTR): {text}
- **DE** (LTR): {text}
- **FR** (LTR): {text}
- **RU** (LTR): {text}
- **TG** (LTR): {text}

**Context**: {usage_notes}

**Character Counts**:
- EN: {n} chars
- FA: {n} chars
- TR: {n} chars
- DE: {n} chars
- FR: {n} chars
- RU: {n} chars
- TG: {n} chars

---

[Show first 3 items from each category as preview]

Full output will contain {total_items} items across {category_count} categories.
```

Use AskUserQuestion:
- Question: "Write these output files?"
- Header: "Write"
- Options:
  - "Approve" — Write output files
  - "Revise" — Let me modify specific items
  - "Cancel" — Don't write

If "Revise": Loop back to Step 5 for specific items

## Step 8: Write Output Files

If approved:

### 8.1: Create Folder Structure

```bash
OUTPUT_FOLDER="$JAAN_OUTPUTS_DIR/ux/content/${NEXT_ID}-${slug}"
mkdir -p "$OUTPUT_FOLDER"
```

### 8.2: Write Main File

Write to: `$OUTPUT_FOLDER/${NEXT_ID}-microcopy-${slug}.md`

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:ux-microcopy-write.template.md`

Fill all sections:
- Title: Feature name
- Executive Summary: Generated summary from Step 7
- Metadata: Languages, tone, categories, date
- Native Speaker Warning
- Localization Settings: RTL languages list
- Tone-of-Voice: Import from `$JAAN_CONTEXT_DIR/tone-of-voice.md`
- Usage instructions
- All categories with all items
- Character counts per language
- Export formats (React i18next, Vue i18n, ICU MessageFormat)
- Quality validation confirmation

### 8.3: Write JSON File

Write to: `$OUTPUT_FOLDER/${NEXT_ID}-microcopy-${slug}.json`

Structure:
```json
{
  "metadata": {
    "feature": "{feature_name}",
    "languages": ["en", "fa", "tr", "de", "fr", "ru", "tg"],
    "tone_profile": "{profile}",
    "categories": ["{list}"],
    "generated": "{ISO-8601-date}",
    "version": "1.0.0",
    "warnings": ["Native speaker review required"]
  },
  "microcopy": [
    {
      "id": "{category}-{item-slug}",
      "category": "{category}",
      "item": "{item_name}",
      "context": "{usage_notes}",
      "translations": {
        "en": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 12
        },
        "fa": {
          "text": "{text}",
          "direction": "rtl",
          "chars": 15,
          "script": "Perso-Arabic"
        },
        "tr": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 18
        },
        "de": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 20
        },
        "fr": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 16
        },
        "ru": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 17,
          "script": "Cyrillic"
        },
        "tg": {
          "text": "{text}",
          "direction": "ltr",
          "chars": 19,
          "script": "Cyrillic"
        }
      }
    }
  ]
}
```

### 8.4: Update Subdomain Index

Source index updater:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
```

Add to index:
```bash
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature Name}" \
  "{Executive Summary from Step 7}"
```

### 8.5: Confirm Write

Show confirmation:
```
✅ MICROCOPY PACK CREATED
─────────────────────────
ID: {NEXT_ID}
Folder: $JAAN_OUTPUTS_DIR/ux/content/{NEXT_ID}-{slug}/
Main: {NEXT_ID}-microcopy-{slug}.md
JSON: {NEXT_ID}-microcopy-{slug}.json
Index: Updated $JAAN_OUTPUTS_DIR/ux/content/README.md

Total Items: {n} items across {n} categories in {n} languages
```

## Step 9: Export Formats (Optional)

Show i18n framework integration formats:

### React i18next

```json
{
  "labels": {
    "save": "Save changes",
    "cancel": "Cancel",
    "delete": "Delete item"
  },
  "errors": {
    "emailRequired": "Email address is required. Please enter your email to continue.",
    "passwordWeak": "Password is too weak. Use at least 8 characters with numbers and symbols."
  }
}
```

**Installation**:
```bash
npm install react-i18next i18next
```

**Usage**:
```javascript
import { useTranslation } from 'react-i18next';

function MyComponent() {
  const { t } = useTranslation();
  return <button>{t('labels.save')}</button>;
}
```

### Vue i18n

```json
{
  "en": {
    "labels": {
      "save": "Save changes"
    }
  },
  "fa": {
    "labels": {
      "save": "ذخیره تغییرات"
    }
  }
}
```

**Installation**:
```bash
npm install vue-i18n
```

**Usage**:
```vue
<template>
  <button>{{ $t('labels.save') }}</button>
</template>
```

### ICU MessageFormat (for Russian plurals)

```
{itemCount, plural,
  =0 {нет элементов}
  =1 {один элемент}
  few {# элемента}
  many {# элементов}
  other {# элементов}
}
```

Show to user:
```
📤 EXPORT FORMATS

Copy the format you need:

**React i18next**: [show JSON above]
**Vue i18n**: [show JSON above]
**ICU MessageFormat**: [show example above]

Import the JSON file into your i18n system or copy the formats above.
```

## Step 10: Feedback Capture

Use AskUserQuestion:
- Question: "Any feedback on the microcopy pack?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update specific items
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

**If "Fix now" or "Both"**:
1. Ask: "Which items need changes? (Specify by category + item name)"
2. For each item:
   - Show current text in all languages
   - Loop back to Step 5 for that item
   - Regenerate translations
   - Update output files
3. Show updated output
4. Re-ask for feedback

**If "Learn" or "Both"**:
1. Ask: "What lesson should I remember for future microcopy generations?"
2. Run: `/jaan-to:learn-add ux-microcopy-write "{feedback}"`
3. Confirm: "Lesson saved to LEARN.md"

**If "No"**:
- Confirm completion

---

## Definition of Done

- [ ] Language preferences saved to `$JAAN_CONTEXT_DIR/localization.md`
- [ ] Tone-of-voice saved to `$JAAN_CONTEXT_DIR/tone-of-voice.md`
- [ ] All selected categories covered
- [ ] All items have all selected languages
- [ ] Quality validation checklist completed
- [ ] Executive Summary included in output
- [ ] Sequential ID generated and used
- [ ] Folder structure created: `{id}-{slug}/`
- [ ] Main file written: `{id}-microcopy-{slug}.md`
- [ ] JSON file written: `{id}-microcopy-{slug}.json`
- [ ] Index updated with `add_to_index()`
- [ ] Native speaker review warning included
- [ ] Export formats shown to user
- [ ] User has approved final result
