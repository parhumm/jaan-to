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
