# UX Microcopy Writing Skill: Comprehensive Research Document
## Production-Ready Skill: `/jaan-to-ux-microcopy-write` (logical: `ux:microcopy-write`)

---

# 1. Executive Summary

**The UX microcopy writing skill generates complete microcopy packs—labels, helper text, errors, toasts, confirmations, empty states, and tone rules—across seven languages with Persian (فارسی) as the primary focus.** This research establishes the frameworks, cultural norms, and technical architecture required for production-ready implementation.

Three critical findings emerged from this research. First, **formality systems vary dramatically** across target languages: Persian's شما/تو distinction, German's Sie/du divide, and Russian's Вы/ты system each require explicit handling. Second, **text expansion rates demand flexible design**—German expands 30-35% over English while Persian expands 10-25%, making rigid character limits problematic. Third, **cultural tone expectations differ fundamentally**: Russian favors direct, factual error messages without apologies, while Persian prefers formal apology patterns with warm professional tone.

The recommended approach combines industry-standard frameworks (Google Material Design, Apple HIG, Shopify Polaris) with language-specific tone matrices. The skill should generate microcopy organized by component type, with all five UI states (loading, empty, error, partial, success) pre-populated for each element. Native speaker validation remains essential—AI achieves only 88-92% accuracy on culturally-nuanced microcopy.

**Key deliverables for implementation:**
- Structured microcopy pack schema with 11 component categories
- Tone matrices for all 7 languages with formality selection criteria
- ICU MessageFormat templates for pluralization (especially Russian's 3-form system)
- RTL handling specifications for Persian and Tajik (Perso-Arabic script)
- Quality validation checklists per language

---

# 2. Standards Reference

## Industry frameworks establish consistent microcopy principles

The major design systems converge on four core principles for UX writing: **concise** (scannable segments, limited ideas), **simple and direct** (plain language, no jargon), **purposeful** (text complements design), and **conversational** (second person "you" preferred). These principles appear consistently across Google Material Design, Apple Human Interface Guidelines, Microsoft Fluent UI, IBM Carbon, and Shopify Polaris.

**Google Material Design** emphasizes sentence-style capitalization, numerals over words, and presenting information positively. The system explicitly states that when things break, the app takes responsibility—never blame users. Apple's Human Interface Guidelines add device-awareness requirements: writing adapts to screen size and context, with mobile favoring extreme brevity.

**IBM Carbon Design System** specifies sentences under 25 words and avoiding slang, jargon, sarcasm, and emoticons. The system permits contractions when they improve flow and reserves exclamation marks for positive messages only. Shopify Polaris goes further with its "weigh every word" principle—each word adds noise, so unnecessary content must be removed.

## Required fields per microcopy category

Each microcopy type requires specific metadata for proper implementation:

### Labels (field, button, navigation)
| Field | Description |
|-------|-------------|
| `label_text` | Primary displayed text |
| `label_type` | field_label, button_label, navigation_label |
| `character_limit` | Maximum characters (buttons: 1-3 words ideal) |
| `capitalization` | sentence_case (standard) or title_case |
| `state_variations` | default, hover, active, disabled, loading |
| `accessibility_label` | Screen reader text if different from visible |

### Error messages
| Field | Description |
|-------|-------------|
| `error_id` | Unique identifier |
| `error_type` | inline, form_level, system |
| `trigger` | What causes error (empty, invalid_format, etc.) |
| `message_text` | User-facing message |
| `recovery_instruction` | How to fix (required) |
| `severity` | error, warning |
| `a11y_announcement` | ARIA live region text |

### Toast notifications
| Field | Description |
|-------|-------------|
| `notification_id` | Unique identifier |
| `message_text` | Primary message (1-2 lines maximum) |
| `notification_type` | info, success, warning, error |
| `duration` | Display time in milliseconds (4000-10000 typical) |
| `action_label` | Optional action ("Undo", "View") |
| `dismissible` | Can user manually dismiss? |
| `priority` | low, medium, high, urgent |

### Empty states
| Field | Description |
|-------|-------------|
| `state_type` | first_use, no_results, user_cleared, error |
| `headline` | Primary message |
| `description` | Explanation and guidance |
| `illustration` | Optional visual asset reference |
| `primary_cta` | Main action to get started |
| `secondary_cta` | Alternative action |

### Confirmation dialogs
| Field | Description |
|-------|-------------|
| `dialog_type` | destructive, informational, decision |
| `title` | Clear description of action |
| `body_text` | Consequences explanation |
| `primary_action` | Action verb label (not "OK") |
| `primary_action_style` | destructive/danger or standard |
| `secondary_action` | Cancel/escape label |
| `reversibility` | Can this action be undone? |

## Professional certifications and foundational texts

**UX Writing Hub** offers the UX Writing Academy 2.0—an 8-week certification program covering core principles, product thinking, AI integration, and Figma workflows. **UX Content Collective** provides specialized certifications including Fundamentals of UX Writing, Microcopy, and Brand Voice & Tone.

The two foundational books for UX writing methodology are Torrey Podmajersky's *Strategic Writing for UX* (O'Reilly, 2019) and Kinneret Yifrah's *Microcopy: The Complete Guide* (2nd Edition, 2019). Podmajersky introduces the Content Matrix for tracking phrases consistently and the four quality criteria: **purposeful, concise, conversational, and clear**. Yifrah provides detailed patterns for every microcopy type with emphasis on voice/tone design methodology.

---

# 3. Methodologies & Techniques

## The error message formula everyone should follow

The golden formula for error messages combines four elements: **what happened** + **why it happened** (if helpful) + **how to fix it** + **what to do next**. Write at 7-8th grade reading level, be concise AND precise, never blame the user, and frontload important content for scanning.

| ❌ Avoid | ✅ Use Instead |
|----------|---------------|
| "Invalid input" | "Phone number should include area code (e.g., 555-123-4567)" |
| "Error: Password requirements not met" | "Password needs at least 8 characters with 1 number" |
| "Authentication failed" | "That password doesn't match. Try again or reset your password" |
| "Form not submitted. ERROR 1234" | "Please fill in the required Name field to submit" |

Never use toast messages for form errors—users can't read and fix simultaneously. Place inline validation adjacent to the problematic field, highlight in error state, and use `aria-describedby` to connect the error message to the input for screen readers.

## Toast duration and confirmation dialog best practices

Toast notification duration depends on content complexity:

| Content Type | Duration | Auto-dismiss? |
|--------------|----------|---------------|
| Simple confirmation | 3 seconds | Yes |
| Longer message | 5 seconds max | Yes |
| Contains link/action | Persistent until dismissed | No |
| Critical information | Persistent | No |

Never stack toasts side-by-side—display sequentially in order of importance. Fixed width is essential; don't expand to fit content.

For confirmation dialogs, **structure matters**: title states action clearly ("Delete project?"), body explains consequences briefly, primary button uses action verb matching the title ("Delete"), secondary button provides safe exit ("Keep project", not generic "Cancel"). Reserve confirmation dialogs for rare or dangerous actions—overuse leads to confirmation fatigue.

## Empty state formula: headline → motivation → CTA

Kinneret Yifrah's formula for empty states:
1. **Heading**: What's happening ("You haven't set up any alerts yet")
2. **Motivation**: Why this matters ("Alerts keep you updated so you won't miss important updates")
3. **CTA**: Action to take ("Set up your first alert")

Four types require different approaches:

| Type | Purpose | Approach |
|------|---------|----------|
| **First-use** | Onboarding | Explain purpose, show how to start, include CTA |
| **User-cleared** | Completion | Celebrate ("Inbox zero!"), suggest what's next |
| **No results** | Search/filter | Explain no results, suggest alternatives |
| **Error state** | System failure | Explain problem, provide troubleshooting |

Never leave empty states blank. Limit CTAs to 1-2 options (Hick's Law: more choices = slower decisions). Replace entire elements when empty—don't show empty tables with just headers.

## Voice vs. tone: the critical distinction

**Voice** is your product's consistent personality—it doesn't change. **Tone** adapts to the user's emotional state and context. Mailchimp's style guide exemplifies this with four voice principles: **plainspoken** (clarity above all), **genuine** (warm, accessible), **translators** (demystify complexity), and **dry humor** (subtle, never condescending).

The key guideline: "Clarity over entertainment—don't sacrifice understanding for jokes." Consider the reader's emotional state before writing. Frustrated users encountering errors need empathy and solutions, not cleverness.

---

# 4. Transformation Process

## From feature description to complete microcopy pack

The transformation follows six phases:

**Phase 1: User Research**
- Create or review user personas for the feature
- Map the complete user journey with all touchpoints
- Identify emotional states at each interaction point

**Phase 2: State Inventory**
- List all screens and components
- For each, identify five states: Loading, Empty (first-use and ongoing), Error, Partial, Success
- Document edge cases: permissions, network failures, partial data

**Phase 3: Voice & Tone Calibration**
- Reference brand voice guidelines
- Adjust tone per touchpoint based on user's likely emotional context
- Apply language-specific formality rules

**Phase 4: Draft Microcopy**
- Write 2-3 variations per state per component
- Include: titles, body, buttons, helper text, error messages
- Document character limits and constraints

**Phase 5: Review & Test**
- Role-play interface as dialogue between user and system
- Check if title + buttons make sense without body text (scanning test)
- A/B test key variations where possible

**Phase 6: Localization**
- Apply language-specific tone matrices
- Account for text expansion (design for +35% minimum)
- Native speaker review for cultural appropriateness

## Component-to-microcopy mapping

| Component | Microcopy Types Needed |
|-----------|----------------------|
| **Buttons** | Labels, loading states ("Saving..."), disabled states |
| **Forms** | Field labels, placeholders, helper text, validation messages |
| **CTAs** | Action labels, supporting copy ("No credit card required") |
| **Modals** | Titles, body copy, button labels |
| **Notifications** | Alert text, success/error messages |
| **Empty states** | Explanation + CTA |
| **Loading states** | Progress messaging |
| **Onboarding** | Welcome messages, tutorials, guided tours |

## Worked Example 1: User registration feature

**Input Feature Description:**
"Users can create an account with email and password. They receive a verification email and must confirm before accessing premium features."

**State Inventory:**
- Form: default, field-focus, validation-error, submit-loading, submit-success
- Email field: empty, valid, invalid-format, already-registered
- Password field: empty, too-short, valid, strength-indicator
- Submit button: default, loading, disabled (validation fails)
- Post-submit: verification-pending, verification-success, verification-expired

**Generated Microcopy Pack (English):**

```json
{
  "registration": {
    "page_title": "Create your account",
    "form": {
      "email": {
        "label": "Email address",
        "placeholder": "you@example.com",
        "helper": "We'll send a verification link to this address",
        "errors": {
          "required": "Enter your email address",
          "invalid_format": "Enter a valid email address (e.g., name@domain.com)",
          "already_registered": "This email is already registered. Sign in instead?"
        }
      },
      "password": {
        "label": "Password",
        "helper": "At least 8 characters with 1 number",
        "errors": {
          "required": "Create a password",
          "too_short": "Password must be at least 8 characters",
          "missing_number": "Include at least 1 number"
        },
        "strength": {
          "weak": "Weak",
          "fair": "Fair", 
          "strong": "Strong"
        }
      },
      "submit": {
        "default": "Create account",
        "loading": "Creating account...",
        "disabled_tooltip": "Fill in all required fields"
      }
    },
    "success": {
      "title": "Check your inbox",
      "body": "We sent a verification link to {{email}}. Click the link to activate your account.",
      "resend_cta": "Resend verification email"
    },
    "verification": {
      "success": {
        "title": "Email verified",
        "body": "Your account is ready. Welcome aboard!",
        "cta": "Go to dashboard"
      },
      "expired": {
        "title": "Link expired",
        "body": "This verification link has expired. Request a new one.",
        "cta": "Send new link"
      }
    }
  }
}
```

**Persian (فارسی) Version:**

```json
{
  "registration": {
    "page_title": "ایجاد حساب کاربری",
    "form": {
      "email": {
        "label": "آدرس ایمیل",
        "placeholder": "you@example.com",
        "helper": "لینک تأیید به این آدرس ارسال می‌شود",
        "errors": {
          "required": "آدرس ایمیل خود را وارد کنید",
          "invalid_format": "یک آدرس ایمیل معتبر وارد کنید (مثلاً name@domain.com)",
          "already_registered": "این ایمیل قبلاً ثبت شده است. می‌خواهید وارد شوید؟"
        }
      },
      "password": {
        "label": "رمز عبور",
        "helper": "حداقل ۸ کاراکتر با ۱ عدد",
        "errors": {
          "required": "رمز عبور ایجاد کنید",
          "too_short": "رمز عبور باید حداقل ۸ کاراکتر باشد",
          "missing_number": "حداقل ۱ عدد اضافه کنید"
        }
      },
      "submit": {
        "default": "ایجاد حساب",
        "loading": "در حال ایجاد حساب...",
        "disabled_tooltip": "همه فیلدهای الزامی را پر کنید"
      }
    },
    "success": {
      "title": "ایمیل خود را بررسی کنید",
      "body": "لینک تأیید به {{email}} ارسال شد. برای فعال‌سازی حساب، روی لینک کلیک کنید.",
      "resend_cta": "ارسال مجدد ایمیل تأیید"
    }
  }
}
```

## Worked Example 2: Shopping cart empty state

**Input:** "Display when user's cart has no items"

**Generated Pack (multi-language):**

| Language | Headline | Body | CTA |
|----------|----------|------|-----|
| **English** | Your cart is empty | Find something you'll love in our collection | Start shopping |
| **Persian** | سبد خرید شما خالی است | محصولات محبوب را در مجموعه ما پیدا کنید | شروع خرید |
| **Turkish** | Sepetiniz boş | Koleksiyonumuzda sevebileceğiniz bir şeyler bulun | Alışverişe başla |
| **German** | Ihr Warenkorb ist leer | Entdecken Sie unsere Kollektion | Einkauf starten |
| **French** | Votre panier est vide | Découvrez notre collection | Commencer vos achats |
| **Russian** | Ваша корзина пуста | Найдите что-нибудь интересное в нашей коллекции | Начать покупки |

## Worked Example 3: Payment error handling

**Scenario:** Credit card declined during checkout

**English:**
- **Title:** Payment declined
- **Body:** Your card was declined. Please check the card details or try a different payment method.
- **Primary CTA:** Try again
- **Secondary CTA:** Use different card

**Persian:**
- **Title:** پرداخت انجام نشد
- **Body:** کارت شما پذیرفته نشد. لطفاً اطلاعات کارت را بررسی کنید یا روش پرداخت دیگری امتحان کنید.
- **Primary CTA:** تلاش مجدد
- **Secondary CTA:** کارت دیگر

**Russian (direct tone, no excessive apology):**
- **Title:** Платёж отклонён
- **Body:** Карта отклонена. Проверьте данные карты или выберите другой способ оплаты.
- **Primary CTA:** Повторить
- **Secondary CTA:** Другая карта

## Worked Example 4: File upload states

**Complete state coverage:**

| State | English | Persian |
|-------|---------|---------|
| **Default** | Drag files here or browse | فایل‌ها را اینجا بکشید یا انتخاب کنید |
| **Hover** | Drop files to upload | فایل‌ها را رها کنید |
| **Uploading** | Uploading... {{progress}}% | در حال آپلود... {{progress}}٪ |
| **Success** | Upload complete | آپلود کامل شد |
| **Error (size)** | File exceeds 10MB limit | حجم فایل بیش از ۱۰ مگابایت است |
| **Error (type)** | Only PDF, JPG, PNG allowed | فقط فرمت‌های PDF، JPG، PNG مجاز است |
| **Error (network)** | Upload failed. Check connection and try again | آپلود انجام نشد. اتصال را بررسی کنید و دوباره تلاش کنید |

## Worked Example 5: Onboarding tooltip sequence

**Feature:** First-time user product tour for project management app

**Step 1 - Create Project:**
- **EN:** "Start here! Create your first project to organize your work."
- **FA:** "از اینجا شروع کنید! اولین پروژه خود را برای سازماندهی کارها ایجاد کنید."
- **CTA:** "Create project" / "ایجاد پروژه"

**Step 2 - Add Tasks:**
- **EN:** "Break your project into tasks. We'll help you track progress."
- **FA:** "پروژه را به وظایف تقسیم کنید. ما به شما کمک می‌کنیم پیشرفت را پیگیری کنید."
- **CTA:** "Add task" / "افزودن وظیفه"

**Step 3 - Invite Team:**
- **EN:** "Work better together. Invite your team to collaborate."
- **FA:** "بهتر با هم کار کنید. تیم خود را برای همکاری دعوت کنید."
- **CTA:** "Invite team" / "دعوت تیم"

---

# 5. Template Recommendations

## Proposed microcopy pack schema

```typescript
interface MicrocopyPack {
  metadata: {
    feature_id: string;
    feature_name: string;
    version: string;
    languages: string[];  // ["en", "fa", "tr", "de", "fr", "ru", "tg"]
    last_updated: string;
    author: string;
  };
  
  voice_and_tone: {
    voice_profile: string;  // e.g., "professional-warm"
    formality_level: "formal" | "informal" | "adaptive";
    language_specific_notes: Record<string, string>;
  };
  
  components: {
    labels: Label[];
    helper_text: HelperText[];
    error_messages: ErrorMessage[];
    success_messages: SuccessMessage[];
    toasts: ToastNotification[];
    confirmations: ConfirmationDialog[];
    empty_states: EmptyState[];
    loading_states: LoadingState[];
    tooltips: Tooltip[];
    placeholders: Placeholder[];
    ctas: CallToAction[];
  };
  
  glossary: GlossaryTerm[];  // Consistent terminology
}

interface ErrorMessage {
  id: string;
  trigger: string;  // What causes this error
  type: "inline" | "form_level" | "system";
  field_reference?: string;
  messages: Record<Language, {
    text: string;
    recovery: string;  // Required: how to fix
  }>;
  severity: "error" | "warning";
  character_limit?: number;
}

interface EmptyState {
  id: string;
  type: "first_use" | "no_results" | "user_cleared" | "error";
  context: string;  // Where this appears
  messages: Record<Language, {
    headline: string;
    body: string;
    primary_cta: string;
    secondary_cta?: string;
  }>;
  illustration_ref?: string;
}
```

## Locale file structure for i18n

```
public/
└── locales/
    ├── en/
    │   ├── common.json
    │   ├── errors.json
    │   ├── forms.json
    │   └── notifications.json
    ├── fa/  (Persian - RTL)
    │   ├── common.json
    │   ├── errors.json
    │   ├── forms.json
    │   └── notifications.json
    ├── tr/  (Turkish)
    ├── de/  (German)
    ├── fr/  (French)
    ├── ru/  (Russian - Cyrillic)
    └── tg/  (Tajik - Cyrillic)
```

## Required fields summary by microcopy type

| Type | Required Fields | Optional Fields |
|------|-----------------|-----------------|
| **Labels** | id, text, context | icon, accessibility_label, truncation_rule |
| **Errors** | id, trigger, text, recovery | error_code, support_link, severity |
| **Toasts** | id, text, type, duration | action_label, dismissible, icon |
| **Empty states** | id, type, headline, body, primary_cta | secondary_cta, illustration |
| **Confirmations** | id, title, body, primary_action, secondary_action | reversibility, input_confirm |
| **Helper text** | id, text, field_reference | timing, icon |

---

# 6. Quality Checklist

## Universal validation rules

### Linguistic accuracy
- [ ] Grammar and spelling correct for target language
- [ ] Punctuation appropriate (Persian ؟ not ?, German „" not "")
- [ ] Terminology consistent with established glossary
- [ ] Tone matches brand voice guidelines
- [ ] Reading level appropriate (7-8th grade equivalent)
- [ ] No ambiguous language or multiple interpretations
- [ ] Active voice preferred (except where passive softens tone)

### Technical correctness
- [ ] Variable interpolation works ({{name}}, {count})
- [ ] Pluralization handled properly per language rules
- [ ] Text fits within UI constraints after localization
- [ ] No truncation of critical content
- [ ] Dynamic content renders correctly
- [ ] Links and CTAs functional

### Accessibility (WCAG compliance)
- [ ] All form fields have programmatic labels (1.3.1)
- [ ] Minimum 4.5:1 contrast ratio for text (1.4.3)
- [ ] Headings and labels describe topic or purpose (2.4.6)
- [ ] Errors identified and described in text (3.3.1)
- [ ] Error suggestions provided when known (3.3.3)
- [ ] Button/link text meaningful out of context
- [ ] Visible label included in accessible name (2.5.3)

## Per-language validation checklist

### Persian (فارسی)
- [ ] شما pronoun used consistently (unless brand specifically targets youth)
- [ ] Formal verb conjugations match pronoun choice
- [ ] Persian punctuation (؟ ، ؛ « ») used correctly
- [ ] Eastern Arabic numerals (۱۲۳) used consistently OR Western numerals—no mixing
- [ ] Persian plurals used (سفارش‌ها not سفارشات)
- [ ] Line-height minimum 1.8 specified for typography
- [ ] Vazirmatn or equivalent Persian-optimized font specified
- [ ] RTL direction handling verified
- [ ] Bidirectional text (mixing Latin/Persian) renders correctly
- [ ] No blame language—passive constructions for user errors
- [ ] Warm professional tone maintained

### German (Deutsch)
- [ ] Sie/du choice consistent with brand positioning
- [ ] "Bitte" used sparingly—only when genuinely needed
- [ ] German quotation marks „ " used
- [ ] Date format DD.MM.YYYY
- [ ] Numbers use period for thousands (11.000) and comma for decimals (11,50)
- [ ] Compound words tested in narrow UI elements
- [ ] Text expansion (+30-35%) accommodated in UI
- [ ] Constructive, non-blaming error messages

### French (Français)
- [ ] Vous/tu choice consistent with brand positioning
- [ ] "Veuillez" used for formal instructions appropriately
- [ ] Guillemets « » with spaces used for quotations
- [ ] Spaces before : ; ! ? punctuation
- [ ] Currency after number with space (100 €)
- [ ] Percentage with space (40 %)
- [ ] Days and months lowercase (lundi, janvier)
- [ ] Text expansion (+15-25%) accommodated

### Russian (Русский)
- [ ] Вы pronoun used (formal standard for all professional UI)
- [ ] Formal imperatives (-те endings)
- [ ] «Guillemets» used for quotation marks
- [ ] Direct, factual tone—no excessive apologies
- [ ] Three-form pluralization implemented correctly
- [ ] Cyrillic font support verified
- [ ] Text expansion (+15-20%) accommodated

### Turkish (Türkçe)
- [ ] Siz/Sen choice consistent—never mix registers
- [ ] "Lütfen" included for imperatives
- [ ] SOV word order maintained
- [ ] Special characters (Ç, Ğ, İ, ı, Ö, Ş, Ü) render correctly
- [ ] Text expansion (+22-33%) accommodated
- [ ] Agglutinative word length tested in UI

### Tajik (Тоҷикӣ)
- [ ] Шумо pronoun used (formal standard)
- [ ] Cyrillic script with unique characters (ғ, ӣ, қ, ӯ, ҳ, ҷ)
- [ ] LTR direction (Cyrillic script)
- [ ] Russian pluralization rules applied (3 forms)

## Anti-patterns to avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Jargon | Users don't understand | Plain language |
| Passive voice in errors | Unclear cause | Active voice |
| Ambiguity | Multiple interpretations | Be specific |
| "Failed/Error/Wrong" | Creates anxiety | Neutral language |
| ALL CAPS | Reads as shouting | Sentence/title case |
| Humor in errors | Trivializes problems | Be helpful first |
| Generic messages | Useless information | Specific explanation |
| Blame language | "You entered invalid..." | "Please enter valid..." |
| Placeholder as label | Disappears, inaccessible | Visible labels always |

---

# 7. Tool Integration

## Recommended tool stack

| Use Case | Recommended Tool |
|----------|-----------------|
| Copy management (Figma) | Ditto or Frontitude |
| AI microcopy generation | Claude/GPT-4 + Frontitude AI Assistant |
| Style guide enforcement | Writer or Frontitude Guidelines |
| Readability checking | Hemingway Editor |
| Grammar/tone | Grammarly |
| Translation management | Lokalise (apps), Crowdin (community), Phrase (enterprise) |
| Dev handoff | Figma Dev Mode + Ditto/Frontitude API/CLI |

## Frontitude features and workflow

Frontitude provides AI-powered UX writing with business/design context awareness. Key capabilities:
- Figma plugin for in-context writing
- Copy component library with reusable strings
- Content guidelines integration with design system
- Automated content audits for style violations
- Translation memory and AI translation
- Developer CLI with i18next integration

**Pricing:** Free tier (2 editors, 3 projects), Team $160-200/mo, Growth $260-325/mo

## Translation management system comparison

| Feature | Crowdin | Phrase | Lokalise |
|---------|---------|--------|----------|
| **Best For** | Community/open-source | Enterprise CI/CD | Mobile apps |
| **Figma Plugin** | Extensive | Yes | Best rated |
| **ICU Support** | Yes (syntax highlighting) | Yes | Yes |
| **GitHub Integration** | 600+ integrations | Extensive API | Popular dev tools |
| **Free Tier** | Open-source only | No | No |
| **Mobile SDK** | Limited | Yes | Strong (OTA updates) |

## Export format: JSON for react-i18next

```json
{
  "auth": {
    "signup": {
      "title": "Create your account",
      "form": {
        "email": {
          "label": "Email address",
          "placeholder": "you@example.com",
          "errors": {
            "required": "Enter your email address",
            "invalid": "Enter a valid email address"
          }
        }
      }
    }
  }
}
```

## react-i18next configuration for 7 languages

```javascript
i18n
  .use(Backend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    supportedLngs: ['en', 'fa', 'tr', 'de', 'fr', 'ru', 'tg'],
    fallbackLng: {
      'tg': ['ru', 'en'],
      'fa': ['en'],
      'default': ['en']
    },
    ns: ['common', 'errors', 'forms', 'notifications'],
    defaultNS: 'common',
    backend: {
      loadPath: '/locales/{{lng}}/{{ns}}.json'
    }
  });
```

---

# 8. AI Prompt Patterns

## Effective prompt structure for microcopy

**Role + Task + Context + Constraints + Format**

```
Role: "Act as a UX writer for a fintech app targeting Iranian users"
Task: "Write inline error messages for a credit card form"
Context: "User is completing checkout, may be frustrated if errors occur"
Constraints: "Persian language, شما formality, under 60 characters, warm professional tone"
Format: "Provide JSON with error triggers and messages"
```

## Few-shot prompting for tone consistency

Few-shot examples reinforce tone more reliably than descriptions:

```
Write Persian error messages matching this tone:
Examples:
- "ایمیل وارد شده معتبر نیست" (neutral, no blame)
- "لطفاً رمز عبور قوی‌تری انتخاب کنید" (uses لطفاً, constructive)
- "اطلاعات کارت نادرست است. لطفاً بررسی کنید" (explains + guides)

Now write for: expired session, invalid phone number, file too large
```

## Language-specific prompt patterns

### Persian prompts
```
Generate microcopy in Persian (فارسی) with these requirements:
- Use شما pronoun (formal)
- Maintain professional-warm tone (حرفه‌ای-صمیمانه)
- Use Persian punctuation: ؟ for questions, ، for commas
- Include recovery instructions for all errors
- Avoid blame—use passive constructions like "اطلاعات نادرست است" not "شما اشتباه وارد کردید"
```

### Russian prompts
```
Generate microcopy in Russian (Русский) with these requirements:
- Use Вы pronoun (formal)
- Direct, factual tone—minimize "пожалуйста" and apologies
- Focus on clear problem statement + solution
- Use «guillemets» for quotations
- Implement 3-form pluralization where needed
```

### German prompts
```
Generate microcopy in German (Deutsch) with these requirements:
- Use Sie pronoun (formal) OR du for consumer brands—specify
- Precise, factual language—clarity valued over warmth
- Use „German quotation marks"
- Constructive error messages without excessive "bitte"
- Account for 30%+ text expansion from English
```

## Prompts by microcopy type

### Error messages
```
Write inline error for [scenario: email validation failure]
Language: [Persian]
Requirements:
- Explain what went wrong
- Provide specific fix instruction
- Under [50] characters
- Avoid blame language
- Use passive voice for user-caused errors

Output format: JSON with trigger, message, recovery fields
```

### Empty states
```
Write empty state for [scenario: first-time user, no projects created]
Language: [Turkish]
Requirements:
- Headline explains current state
- Body motivates action with value proposition
- Single clear CTA
- Encouraging tone appropriate for Siz formality

Output: headline, body, cta_text
```

## Common AI failure modes and mitigations

| Failure Mode | Cause | Mitigation |
|--------------|-------|------------|
| Overly formal/robotic | Default neutral tone | Move tone instructions earlier; use few-shot examples |
| Culturally inappropriate | Literal translation | Specify cultural norms explicitly; native review required |
| Inconsistent tone in batch | Drift without constraints | Process as single prompt; reference consistent examples |
| Wrong formality level | Generic language handling | Explicit pronoun and conjugation rules per language |
| Exceeds character limits | Prioritizes completeness | Strict character counts: "Under 8 words. Do not exceed." |
| Missing recovery instructions | Incomplete error pattern | Template: "Always include: what happened + how to fix" |

**Critical:** AI achieves ~88-92% accuracy—native speaker review remains essential for production microcopy. The remaining 8-12% includes cultural missteps, subtle tone errors, and occasional confabulation (~4% of outputs).

---

# 9. Multi-Language & RTL Reference

## Tone matrices by language

### Formality selection criteria

| Factor | Formal | Informal |
|--------|--------|----------|
| B2B products | ✓ All languages | — |
| Banking/finance | ✓ All languages | — |
| Healthcare | ✓ All languages | — |
| B2C young audience | — | German (du), Turkish (sen), French (tu) acceptable |
| Social apps | — | Consider informal for casual brand |
| E-commerce | Context-dependent | Youth-focused brands |

### Language-specific formality defaults

| Language | Pronoun | Imperative | "Please" Usage |
|----------|---------|------------|----------------|
| **Persian** | شما | Formal (-ید) | لطفاً common |
| **Turkish** | Siz | Formal (-iniz) | Lütfen common |
| **Russian** | Вы | Formal (-те) | Пожалуйста less common |
| **German** | Sie | Formal (-en Sie) | Bitte sparingly |
| **French** | Vous | Formal (-ez) | Veuillez for formal |
| **English** | — | — | Please optional |
| **Tajik** | Шумо | Formal | Similar to Persian |

### Error message tone by culture

| Language | Tone Approach | Apology Pattern |
|----------|---------------|-----------------|
| **Persian** | Warm, formal, helpful | Formal apology preferred: "متأسفانه" |
| **Turkish** | Polite, solution-focused | Moderate apology acceptable |
| **Russian** | Direct, factual | Minimal apology—focus on fix |
| **German** | Precise, constructive | "Entschuldigung" doesn't add empathy alone |
| **French** | Elegant, polite | Apology expected, use conditional |
| **English** | Casual, friendly | Casual apology OK: "Oops, something went wrong" |

## Text expansion rates from English

| Language | Expansion | Notes |
|----------|-----------|-------|
| **German** | +30-35% | Compound nouns can't wrap |
| **Turkish** | +22-33% | Agglutinative—single words very long |
| **French** | +15-25% | |
| **Russian** | +15-20% | Cyrillic may need more glyph space |
| **Persian** | +10-25% | RTL requires separate layout testing |
| **Spanish** | +20-25% | Reference for planning |

**Critical insight:** Shorter strings expand MORE. "FAQ" → "Preguntas frecuentes" (300%+). Design for +35% padding minimum in all text containers.

| English Characters | Expected Expansion |
|-------------------|-------------------|
| Up to 10 | 200-300% |
| 11-20 | 180-200% |
| 21-30 | 160-180% |
| 31-50 | 140-160% |
| Over 70 | 130% |

## RTL handling for Persian

### CSS logical properties (required)

```css
/* Use logical properties instead of physical */
.component {
  margin-inline-start: 1rem;   /* Not margin-left */
  padding-inline-end: 2rem;    /* Not padding-right */
  text-align: start;           /* Not text-align: left */
  border-inline-start: 2px solid blue;
}

/* Persian-specific typography */
:lang(fa) {
  font-family: 'Vazirmatn', 'Noto Sans Arabic', system-ui, sans-serif;
  line-height: 1.8;  /* Required for diacritics */
  direction: rtl;
}
```

### Bidirectional text handling

Persian text with embedded English (brand names, URLs, code) requires proper isolation:

```css
.bidi-isolate {
  unicode-bidi: isolate;
}
```

Numbers remain left-to-right even in RTL text. Use Eastern Arabic numerals (۱۲۳) for dates, prices, phone numbers in Persian context; Western numerals acceptable for technical/code contexts.

## Punctuation by language

| Element | English | Persian | German | French | Russian |
|---------|---------|---------|--------|--------|---------|
| Question mark | ? | ؟ | ? | ? (space before) | ? |
| Comma | , | ، | , | , | , |
| Semicolon | ; | ؛ | ; | ; (space before) | ; |
| Quotation marks | "..." | «...» | „..." | « ... » | «...» |
| Thousands separator | , | — | . or space | space | space |
| Decimal separator | . | — | , | , | , |

## Pluralization rules by language

| Language | Forms | Rule |
|----------|-------|------|
| **English** | 2: one, other | one = 1; other = 0, 2+ |
| **German** | 2: one, other | one = 1; other = 0, 2+ |
| **French** | 2: one, other | one = 0, 1; other = 2+ |
| **Turkish** | 2: one, other | one = 1; other = 0, 2+ |
| **Persian** | 2: one, other | one = 0, 1; other = 2+ |
| **Russian** | 4: one, few, many, other | Complex modulo rules |
| **Tajik** | 2: one, other | Same as Persian |

### Russian pluralization implementation

```javascript
// ICU MessageFormat
{
  "books": "{count, plural, one {# книга} few {# книги} many {# книг} other {# книги}}"
}

// Rule: 
// one: ends in 1 (except 11): 1, 21, 31...
// few: ends in 2-4 (except 12-14): 2, 3, 4, 22, 23, 24...
// many: ends in 0, 5-20, 11-14: 0, 5, 6...11, 12...20
// other: decimals
```

## BCP 47 locale codes

| Language | Code | Script | Direction |
|----------|------|--------|-----------|
| English | `en` | Latin | LTR |
| Persian | `fa` | Arabic (Perso-Arabic) | RTL |
| Turkish | `tr` | Latin | LTR |
| German | `de` | Latin | LTR |
| French | `fr` | Latin | LTR |
| Russian | `ru` | Cyrillic | LTR |
| Tajik | `tg` or `tg-Cyrl` | Cyrillic | LTR |

---

# 10. Bibliography

## Design System Documentation

- Google Material Design 3 Content Design: https://m3.material.io/foundations/content-design/
- Apple Human Interface Guidelines - Writing: https://developer.apple.com/design/human-interface-guidelines/writing
- Microsoft Fluent 2 Content Design: https://fluent2.microsoft.design/content-design
- IBM Carbon Design System Content: https://carbondesignsystem.com/guidelines/content/overview/
- Atlassian Design System Content: https://atlassian.design/content/
- Shopify Polaris Content Fundamentals: https://polaris-react.shopify.com/content/fundamentals

## Professional Certifications

- UX Writing Hub Academy: https://uxwritinghub.com/ux-writing-courses/
- UX Content Collective: https://uxcontent.com/

## Foundational Books

- Podmajersky, Torrey. *Strategic Writing for UX*. O'Reilly Media, 2019.
- Yifrah, Kinneret. *Microcopy: The Complete Guide*. 2nd Edition, 2019.
- Richards, Sarah. *Content Design*. 2nd Edition.
- Fenton, Nicole & Kiefer Lee, Kate. *Nicely Said*.

## Localization Resources

- W3C Internationalization Guidelines: https://www.w3.org/International/
- Unicode CLDR Pluralization Rules: https://unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
- MDN Web Docs - CSS Logical Properties: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Logical_Properties

## i18n Tools Documentation

- react-i18next: https://react.i18next.com/
- i18next: https://www.i18next.com/
- FormatJS (ICU MessageFormat): https://formatjs.io/
- Crowdin Documentation: https://support.crowdin.com/
- Lokalise Documentation: https://docs.lokalise.com/
- Phrase Documentation: https://support.phrase.com/

## UX Writing Tools

- Frontitude: https://www.frontitude.com/
- Ditto: https://www.dittowords.com/
- Writer: https://writer.com/

## Language-Specific Resources

- German UPA Error Message Guidelines (Leitfaden Fehlermeldungen v1.00, December 2023)
- Mailchimp Content Style Guide: https://styleguide.mailchimp.com/
- Persian UX Writing GitHub repositories and community resources

## Industry Standards Organizations

- UXPA International: https://uxpa.org/
- W3C Web Accessibility Initiative (WAI): https://www.w3.org/WAI/

---

*Document Version: 1.0*
*Last Updated: February 2026*
*Skill Reference: /jaan-to-ux-microcopy-write (logical: ux:microcopy-write)*