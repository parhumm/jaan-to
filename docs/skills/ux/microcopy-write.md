---
title: "Microcopy Write"
sidebar_position: 3
---

# Microcopy Write

> Generate multi-language microcopy packs for UI components with cultural adaptation.

---

## Overview

The `/jaan-to:ux-microcopy-write` skill generates production-ready microcopy for UI components in up to 7 languages with full cultural adaptation, tone-of-voice consistency, and RTL/LTR support.

**Supported Languages**:
- **EN** (English) - LTR, Latin
- **FA** (فارسی / Persian) - RTL, Perso-Arabic
- **TR** (Türkçe / Turkish) - LTR, Latin
- **DE** (Deutsch / German) - LTR, Latin
- **FR** (Français / French) - LTR, Latin
- **RU** (Русский / Russian) - LTR, Cyrillic
- **TG** (Тоҷикӣ / Tajik) - LTR, Cyrillic

**Key Features**:
- ✅ Smart category detection from feature description
- ✅ Iterative options (3-5 rounds with custom text support)
- ✅ Cultural adaptation (not literal translation)
- ✅ Tone-of-voice management with language-specific formality
- ✅ RTL handling for Persian/Farsi (ZWNJ, punctuation, bidirectional text)
- ✅ Text expansion warnings (German +35%, Turkish +33%)
- ✅ Dual output: markdown + JSON for i18n frameworks
- ✅ Native speaker review warnings
- ✅ Optional UI screenshot embedding to show where copy appears

---

## When to Use

Use this skill when you need microcopy for:

| Use Case | Example |
|----------|---------|
| **Multi-language apps** | SaaS platform expanding to Middle East and Europe |
| **Form validation** | Error messages, helper text, field labels |
| **Modals & dialogs** | Confirmation messages, destructive action warnings |
| **Empty states** | First-time use, no data scenarios |
| **Success notifications** | Toast messages, confirmations |
| **Button labels** | CTAs, navigation, actions |
| **Loading states** | Progress indicators, "please wait" messages |

**Don't use for**:
- Long-form content (blog posts, documentation)
- Marketing copy (use copywriting specialists)
- Legal text (requires legal review)
- Technical documentation (use docs skills)

---

## Usage

### Basic Usage

```bash
/jaan-to:ux-microcopy-write "user authentication feature"
```

### With Feature Description

```bash
/jaan-to:ux-microcopy-write "Login form with email/password, forgot password link, and sign up CTA. Need error messages for invalid credentials and empty fields."
```

### Multi-Category Example

```bash
/jaan-to:ux-microcopy-write "E-commerce checkout flow: payment form, shipping address, order summary, empty cart state, success confirmation"
```

---

## Workflow

### Phase 1: Configuration (Read-Only)

**Step 1: Language Selection**

The skill checks if you have saved language preferences in `jaan-to/context/localization.md`:

- **If saved preferences exist**: Option to use or modify
- **If not**: Choose from:
  - All 7 languages
  - Common set (EN, FA, TR)
  - Custom selection

Your selection is saved for future runs.

**Step 2: Tone-of-Voice**

The skill checks if you have saved tone guidelines in `jaan-to/context/tone-of-voice.md`:

- **If saved preferences exist**: Option to use or modify
- **If not**: Choose from:
  - Professional & Formal (Banking, B2B, enterprise)
  - Friendly & Conversational (Consumer apps, social)
  - Sample-based (Provide 2-3 examples to match)

Your tone profile is saved for future runs with language-specific formality (Sie/du, شما/تو, Вы/ты, etc.).

**Step 3: Category Detection**

Smart detection based on your feature description:

| Keywords Detected | Categories Suggested |
|-------------------|---------------------|
| "form", "validation" | Error Messages, Helper Text, Labels |
| "modal", "dialog" | Confirmation Dialogs, CTAs |
| "empty", "no data" | Empty States |
| "notification", "toast" | Toast Notifications, Success Messages |
| "button", "action" | CTAs, Labels |

You can accept detected categories or choose:
- Core set (Labels, Errors, CTAs, Success)
- Full set (all 11 categories)
- Custom selection

**Step 4: Item Inventory**

For each category, specify how many items you need. The skill shows common examples to guide you.

**Step 5: Review & Approve**

Preview the complete plan before generation starts.

### Phase 2: Generation

**Per-Item Process**:

1. **English Generation**: 3 options shown, tone-matched
2. **Iteration**: Up to 5 rounds or use custom text
3. **Translation**: Culturally-adapted to all selected languages
4. **Quality Check**: Grammar, tone, RTL handling, text expansion

**Output Preview**: Complete microcopy pack with ID, folder structure, file paths

**Write**: Two files created:
- `{id}-microcopy-{slug}.md` - Human-readable with usage notes
- `{id}-microcopy-{slug}.json` - Machine-readable for i18n import

---

## Microcopy Categories

### 1. Labels & Buttons
Short, clear text for form fields and buttons (1-3 words).

**Examples**:
- Save, Save changes, Save draft
- Cancel, Close, Dismiss
- Email address, Password, Confirm password

### 2. Helper Text
Contextual guidance for form fields.

**Examples**:
- "We'll never share your email"
- "At least 8 characters with numbers and symbols"

### 3. Error Messages
4-element structure: What happened + Why (optional) + How to fix + What's next

**Examples**:
- "Email address is required. Please enter your email to continue."
- "Password must be at least 8 characters. Update your password."

### 4. Success Messages
Brief celebration + confirmation (3-6 words ideal).

**Examples**:
- "Email verified! Welcome aboard."
- "Changes saved."
- "Message sent."

### 5. Toast Notifications
Temporary notifications (4-10 second duration).

**Examples**:
- "Item added to cart"
- "Copied to clipboard"
- "Settings updated"

### 6. Confirmation Dialogs
Clear consequences for destructive actions.

**Examples**:
- "Delete this item? This action cannot be undone."
- "Remove Sarah from the team? She will lose access to all projects."

### 7. Empty States
3-part structure: Headline + Motivation + CTA

**Examples**:
- "No projects yet" + "Create your first project to get started" + "Create project"

### 8. Loading States
Progress indicators.

**Examples**:
- "Loading..."
- "Uploading... 45%"
- "Processing payment..."

### 9. Tooltips
Additional guidance on hover.

**Examples**:
- "Learn more about two-factor authentication"
- "Premium feature"

### 10. Placeholders
Non-accessible but contextual hints (use with labels).

**Examples**:
- "name@company.com"
- "Enter your address"

### 11. Call-to-Action Buttons
Action verb labels, specific, 1-3 words.

**Examples**:
- "Get started"
- "Download now"
- "Send message"

---

## Cultural Adaptation

The skill applies language-specific cultural rules:

### Persian (فارسی)
- **Formality**: Formal شما (or informal تو based on tone)
- **Tone**: Warm, polite
- **ZWNJ**: Auto-added for plurals (کاربرها‌) and compounds
- **Punctuation**: Persian-specific (؟ ، ؛ « »)
- **Numerals**: Western (0-9) for digital UI pragmatism
- **Direction**: RTL with bidirectional text handling
- **Font**: IranSans, Vazirmatn (line-height: 1.8+)

### Russian (Русский)
- **Formality**: Formal Вы (or informal ты based on tone)
- **Tone**: Direct, factual, minimal apologies
- **Focus**: Solution-oriented (not "Sorry!")
- **Pluralization**: 3-form system (=0, =1, few, many, other)
- **ICU MessageFormat**: Recommended for counts

### German (Deutsch)
- **Formality**: Formal Sie (or du for consumer brands)
- **Tone**: Precise, non-blaming, constructive
- **Text Expansion**: +30-35% longer than English
- **Compounds**: Single words can't wrap (plan UI space)

### Turkish (Türkçe)
- **Formality**: Formal Siz (or sen for youth apps)
- **Tone**: Polite, respectful
- **Agglutination**: Single words can be very long
- **Text Expansion**: +22-33% longer than English

### French (Français)
- **Formality**: Formal Vous (or tu for consumer brands)
- **Tone**: Elegant, apologetic conditional for errors
- **Text Expansion**: +15-25% longer than English

### Tajik (Тоҷикӣ)
- **Formality**: Formal Шумо
- **Script**: Cyrillic
- **Cultural**: Similar to Persian
- **Direction**: LTR

---

## Output Format

### Markdown File

Human-readable format with:
- Executive Summary
- Metadata (languages, tone, categories, date)
- Native Speaker Review Warning
- Localization Settings (RTL languages, text expansion rates)
- Tone-of-Voice import from context file
- Usage instructions
- All categories with all items
- Character counts per language
- i18n framework export formats (React i18next, Vue i18n, ICU MessageFormat)
- Quality validation checklist

### JSON File

Machine-readable format with:
- Metadata (feature, languages, tone, categories, version, warnings)
- Microcopy array with:
  - Item ID, category, name, context
  - Translations object per language with:
    - text, direction (ltr/rtl), character count, script (optional)

**Example JSON structure**:
```json
{
  "metadata": {
    "feature": "user-authentication",
    "languages": ["en", "fa", "tr"],
    "tone_profile": "Professional & Formal",
    "categories": ["Labels", "Error Messages", "CTAs"],
    "generated": "2026-02-03",
    "version": "1.0.0",
    "warnings": ["Native speaker review required"]
  },
  "microcopy": [
    {
      "id": "labels-email-field",
      "category": "Labels & Buttons",
      "item": "Email field label",
      "context": "Login form email input label",
      "translations": {
        "en": {
          "text": "Email address",
          "direction": "ltr",
          "chars": 13
        },
        "fa": {
          "text": "آدرس ایمیل",
          "direction": "rtl",
          "chars": 10,
          "script": "Perso-Arabic"
        },
        "tr": {
          "text": "E-posta adresi",
          "direction": "ltr",
          "chars": 15
        }
      }
    }
  ]
}
```

---

## Best Practices

### 1. Run Once Per Feature

Generate a complete microcopy pack for each feature/flow. Avoid piecemeal generation.

### 2. Save Your Preferences

First run takes longer (language + tone setup). Subsequent runs are faster with saved preferences.

### 3. Use Custom Text Wisely

If you have brand-specific phrases, use the "My own" option to provide them. The skill will generate style-matched variations.

### 4. Test Text Expansion

Always test UI with German/Turkish text (longest languages) to ensure proper spacing.

### 5. Native Speaker Review

**Critical**: AI achieves ~88-92% accuracy. Always have native speakers review non-English content before production.

### 6. Import JSON to i18n Framework

Use the JSON file for React i18next, Vue i18n, or other i18n systems. The skill provides pre-formatted exports.

### 7. Update Tone Profile

As your brand voice evolves, update `jaan-to/context/tone-of-voice.md` manually or re-run the skill to modify it.

---

## Example Output

**Command**:
```bash
/jaan-to:ux-microcopy-write "Login form with email and password fields"
```

**Generated Files**:
```
jaan-to/outputs/ux/content/01-login-form/
├── 01-microcopy-login-form.md    # Human-readable
└── 01-microcopy-login-form.json  # Machine-readable
```

**Markdown Preview**:
```markdown
# Microcopy Pack: Login Form

## Executive Summary

Multi-language microcopy pack for login-form covering 3 categories (Labels, Error Messages, CTAs) in 3 languages (English, فارسی, Türkçe). Includes culturally-adapted copy with RTL support for Persian/Farsi and tone-of-voice consistency across all languages.

## Category: Labels & Buttons

### Email Field
- **EN** (LTR): Email address
- **FA** (RTL): آدرس ایمیل
- **TR** (LTR): E-posta adresi

**Context**: Login form email input label
**Character Counts**: EN: 13, FA: 10, TR: 15

### Password Field
- **EN** (LTR): Password
- **FA** (RTL): رمز عبور
- **TR** (LTR): Şifre

**Context**: Login form password input label
**Character Counts**: EN: 8, FA: 8, TR: 5

## Category: Error Messages

### Invalid Email
- **EN** (LTR): Email address is required. Please enter your email to continue.
- **FA** (RTL): آدرس ایمیل الزامی است. لطفاً ایمیل خود را وارد کنید تا ادامه دهید.
- **TR** (LTR): E-posta adresi gereklidir. Devam etmek için lütfen e-postanızı girin.

**Context**: Error when email field is empty
**Character Counts**: EN: 62, FA: 66, TR: 72
```

---

## Related

- [UX Heatmap Analyze](heatmap-analyze.md) - Analyze user behavior to inform microcopy
- [PM Story Write](../pm/story-write.md) - Reference user stories for microcopy context
- [Skill Specification](../../extending/create-skill.md) - How this skill was built

---

**Tags**: ux, microcopy, multi-language, i18n, localization, rtl, cultural-adaptation

**Created**: 2026-02-03
**Updated**: 2026-02-16
