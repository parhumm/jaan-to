# Microcopy Reference Material

> Reference data for `ux-microcopy-write` skill. This file contains per-language translation rules,
> export format templates, JSON structure schemas, and validation checklists extracted from the skill
> definition for token optimization.

---

## Per-Language Translation Rules

Rules for culturally-adapted translation of approved English microcopy.

### Persian (FA)

- Use formal شما pronoun (unless tone is informal → تو)
- Warm, polite tone
- Add ZWNJ (Zero-Width Non-Joiner) for plurals: کاربرها‌
- Use Persian punctuation: ؟ ، ؛ « »
- Mark as RTL
- Western numerals (0-9) for UI pragmatism

### Russian (RU)

- Use formal Вы pronoun (unless tone is informal → ты)
- Direct, factual tone
- Minimize apologies—focus on solution
- Handle 3-form pluralization
- Mark as LTR, Cyrillic script

### German (DE)

- Use formal Sie pronoun (or du if tone is informal)
- Precise, non-blaming language
- Expect +30-35% text expansion
- No overapologizing

### Turkish (TR)

- Use formal Siz pronoun (or sen if tone is informal)
- Polite, respectful
- Agglutinative language—single words can be long
- Expect +22-33% text expansion

### French (FR)

- Use formal Vous pronoun (or tu if tone is informal)
- Elegant phrasing
- Apologetic conditional for errors
- Expect +15-25% text expansion

### Tajik (TG)

- Use formal Шумо pronoun
- Cyrillic script handling
- Similar to Persian culturally
- Mark as LTR

---

## Quality Validation: Language-Specific Checks

Checklist items for per-language validation before writing output.

- [ ] **Persian**: شما consistency, Persian punctuation (؟ ، ؛), ZWNJ for plurals, RTL flag set
- [ ] **Russian**: Вы consistency, factual tone, no blame language
- [ ] **German**: Sie/du consistency, precise language, no overapologies
- [ ] **Turkish**: Siz/sen consistency, politeness markers
- [ ] **French**: Vous/tu consistency, elegant phrasing
- [ ] **All RTL languages**: Direction metadata correct (rtl for FA)

### Cultural Adaptation Checks

- [ ] No literal translations—culturally adapted per language
- [ ] Formality level matches tone profile for each language
- [ ] Longest text (German/Turkish/Persian) noted for UI constraints

---

## JSON Output Structure

Schema for the JSON export file (`{id}-microcopy-{slug}.json`).

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

---

## Export Format Templates

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

### How to Use Export Formats

Copy the format matching your i18n framework. Import the JSON file into your i18n system or use the templates above as a starting point for each language namespace.

---

## Tone Profile Detection Template

When analyzing sample-based tone from user-provided text, display the detected profile using this template:

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

---

## Category Detection Rules

Keyword-based rules for automatically detecting which microcopy categories are needed from an initiative/feature description:

| Keywords | Detected Categories |
|----------|-------------------|
| "form", "validation", "input" | Error Messages, Helper Text, Labels |
| "modal", "dialog", "confirm" | Confirmation Dialogs, CTAs |
| "empty", "first-time", "no data" | Empty States |
| "notification", "toast", "alert" | Toast Notifications, Success Messages |
| "button", "action", "submit" | CTAs, Labels |
| "loading", "progress" | Loading States |

---

## Microcopy Categories Catalog

Complete list of available microcopy categories (11 total):

1. **Labels & Buttons** — UI element labels and button text
2. **Helper Text** — Instructional text near form fields
3. **Error Messages** — With recovery instructions
4. **Success Messages** — Confirmation of completed actions
5. **Toast Notifications** — Temporary status messages
6. **Confirmation Dialogs** — User decision prompts
7. **Empty States** — Zero-data screens
8. **Loading States** — Progress/wait indicators
9. **Tooltips** — Hover/focus explanations
10. **Placeholders** — Input field placeholder text
11. **Call-to-Action buttons** — Conversion-focused button text

---

## Category Item Examples

Common examples to show users when building item inventory per category.

### Labels & Buttons

Common examples:
- Save, Save changes, Save draft
- Cancel, Close, Dismiss
- Delete, Remove, Clear
- Confirm, Yes, No
- Submit, Send, Share
- Edit, Update, Modify

### Error Messages

Common examples:
- Email validation (invalid format)
- Password requirements (too short, weak)
- Network errors (no connection, timeout)
- Required field (empty field)
- File upload (too large, wrong type)

---

## Generation Best Practices

Guidelines for generating high-quality English microcopy options per category.

### Error Messages
- Structure: What happened + How to fix
- Use verbs, be specific
- No blame language
- Example: "Email address is required. Please enter your email to continue."

### CTAs / Labels
- Action verb, specific
- 1-3 words max
- Example: "Save changes", "Delete item", "Send message"

### Empty States
- 3-part structure: Headline + Motivation + CTA
- Example: "No projects yet" + "Create your first project to get started" + "Create project"

### Success Messages
- Celebrate (minimal) + Confirm
- Example: "Email verified! Welcome aboard."
