# Microcopy Pack: {{title}}

## Executive Summary

Multi-language microcopy pack for {{feature_name}} covering {{category_count}} categories ({{categories_list}}) in {{language_count}} languages ({{languages_list}}). Includes culturally-adapted copy with RTL support for Persian/Farsi and tone-of-voice consistency across all languages.

---

## Metadata

| Field | Value |
|-------|-------|
| **Feature** | {{feature_name}} |
| **Languages** | {{languages_list}} |
| **Tone Profile** | {{tone_profile}} |
| **Categories** | {{categories_list}} |
| **Generated** | {{date}} |
| **ID** | {{id}} |
| **Version** | 1.0.0 |

---

## ⚠️ Native Speaker Review Required

**AI-generated microcopy achieves ~88-92% accuracy on culturally-nuanced content.**

Please have native speakers review all non-English content before production use. Key areas to verify:

- **Cultural appropriateness** - Idioms, phrases, and tone match local culture
- **Formality consistency** - Formal/informal pronouns used consistently
- **Grammar & punctuation** - Correct for each language's rules
- **Text expansion** - Longest text (German/Turkish/Persian) fits UI constraints

---

## Localization Settings

**Enabled Languages**: {{languages_list}}

**RTL Languages**: {{rtl_languages}}

**Text Expansion Rates**:
- German: +30-35% longer than English
- Turkish: +22-33% longer than English
- French: +15-25% longer than English
- Persian: +10-25% longer than English
- Russian: +15-20% longer than English

**Tone-of-Voice Profile**:

{{tone_profile_details}}

---

## Usage

### 1. Copy-Paste into Codebase

All microcopy below is ready to copy-paste into your UI code. RTL languages are marked with direction metadata.

### 2. Native Speaker Review

Have native speakers review all non-English content. Focus on cultural appropriateness and tone consistency.

### 3. Test RTL Layout

If Persian/Farsi is included, test RTL layout:
- Ensure proper text direction (right-to-left)
- Verify ZWNJ (Zero-Width Non-Joiner) renders correctly
- Test bidirectional text (Latin + Persian mix)
- Use recommended fonts: IranSans or Vazirmatn (line-height: 1.8+)

### 4. Check Text Expansion

Test UI with longest language (German/Turkish) to ensure text fits in buttons, labels, and containers.

### 5. Import JSON into i18n System

Use the JSON file (`{{id}}-microcopy-{{slug}}.json`) to import into your i18n framework. See **Export Formats** section below.

---

{{microcopy_content}}

---

## Export Formats

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
  },
  "success": {
    "emailVerified": "Email verified! Welcome aboard."
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
  return (
    <>
      <button>{t('labels.save')}</button>
      <p>{t('errors.emailRequired')}</p>
    </>
  );
}
```

### Vue i18n

```json
{
  "en": {
    "labels": {
      "save": "Save changes"
    },
    "errors": {
      "emailRequired": "Email address is required. Please enter your email to continue."
    }
  },
  "fa": {
    "labels": {
      "save": "ذخیره تغییرات"
    },
    "errors": {
      "emailRequired": "آدرس ایمیل الزامی است. لطفاً ایمیل خود را وارد کنید تا ادامه دهید."
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
  <div>
    <button>{{ $t('labels.save') }}</button>
    <p>{{ $t('errors.emailRequired') }}</p>
  </div>
</template>
```

### ICU MessageFormat (for Pluralization)

**Use for Russian 3-form plurals**:

```javascript
{
  "itemCount": "{count, plural, =0 {нет элементов} =1 {один элемент} few {# элемента} many {# элементов} other {# элементов}}"
}
```

**Use for other languages**:

```javascript
{
  "itemCount": "{count, plural, one {# item} other {# items}}"
}
```

**Installation** (react-intl):
```bash
npm install react-intl
```

**Usage**:
```javascript
import { FormattedMessage } from 'react-intl';

<FormattedMessage
  id="itemCount"
  values={{ count: 5 }}
/>
```

---

## Quality Validation Completed

✅ **Universal Checks**:
- All {{total_items}} items have all {{language_count}} languages
- Tone consistency verified across all items
- Grammar validated for each language
- Error messages include recovery instructions
- Reading level: 7-8th grade (English baseline)
- No ambiguous language

✅ **Language-Specific Checks**:
{{#each language_checks}}
- **{{language}}**: {{checks_completed}}
{{/each}}

✅ **Cultural Adaptation**:
- No literal translations—culturally adapted per language
- Formality levels matched per language ({{formality_pronouns}})
- Text expansion accounted for (German +35%, Turkish +33%)
- RTL handling verified for {{rtl_languages}}

✅ **RTL Support** (Persian/Farsi):
- Direction metadata: `rtl`
- ZWNJ (Zero-Width Non-Joiner) added for plurals and compound words
- Persian punctuation used: ؟ ، ؛ « »
- Western numerals (0-9) used for digital UI pragmatism
- Recommended fonts: IranSans, Vazirmatn (line-height: 1.8+)

---

## File Information

| Field | Value |
|-------|-------|
| Created | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/ux/content/{{id}}-{{slug}}/ |
| Skill | ux-microcopy-write |
| Command | `/jaan-to:ux-microcopy-write` |
| Version | 3.0 |
| Status | Draft |

---

> Generated with `/jaan-to:ux-microcopy-write` | [jaan.to](https://jaan.to)
