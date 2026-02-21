# detect-writing Reference Material

> Extracted reference tables, scoring rubrics, and detection patterns for the `detect-writing` skill.

---

## UI Copy Classification — Category Detection Patterns

Classify discovered strings into 8 categories using component-name glob patterns:

| Category | Component Patterns | Props to Extract |
|----------|-------------------|-----------------|
| **Buttons/CTAs** | `*Button*`, `*Btn*`, `*CTA*`, `*Submit*`, `*Action*` | `children`, `label`, `text` |
| **Error messages** | `*Error*`, `*ValidationError*`, `*ErrorBoundary*`, `*ErrorState*` | `message`, `errorMessage`, `description` |
| **Empty states** | `*EmptyState*`, `*NoData*`, `*NoResults*`, `*ZeroState*`, `*BlankState*` | `title`, `description`, `message` |
| **Confirmation dialogs** | `*Dialog*`, `*Modal*`, `*Confirm*`, `*AlertDialog*` | `title`, `message`, `confirmText`, `cancelText` |
| **Notifications/toasts** | `*Toast*`, `*Notification*`, `*Snackbar*`, `*Banner*`, `*Flash*` | `message`, `title`, `description` |
| **Onboarding** | `*Onboarding*`, `*Tour*`, `*Walkthrough*`, `*Welcome*`, `*Wizard*`, `*Stepper*` | `title`, `description`, `step` |
| **Form labels/helper** | `*FormField*`, `*Label*`, `*HelperText*`, `*HintText*`, `*TextField*` | `label`, `helperText`, `placeholder` |
| **Loading states** | `*Loading*`, `*Spinner*`, `*Skeleton*`, `*Progress*`, `*Shimmer*` | `loadingText`, `message`, `label` |

Also inspect variant/severity props (`variant="error"`, `severity="warning"`, `isLoading`, `isEmpty`, `isDestructive`) to classify ambiguous components.

---

## NNg Tone Dimension Scoring

### 4 Primary Dimensions (NNg)

| Dimension | Scale | Detection Signals |
|-----------|-------|------------------|
| **Formality** | 1(formal)-5(casual) | Contraction ratio, avg sentence length, passive voice %, Flesch-Kincaid grade, Latin-derived word ratio |
| **Humor** | 1(serious)-5(funny) | Exclamation frequency, emoji presence, metaphor/wordplay, dry/factual ratio |
| **Respectfulness** | 1(irreverent)-5(respectful) | Politeness markers ("please"/"thank you"), hedging frequency, commands vs requests |
| **Enthusiasm** | 1(matter-of-fact)-5(enthusiastic) | Exclamation marks, superlatives ("amazing"/"great"), intensifiers ("very"/"extremely") |

### 5 Extended Dimensions

| Dimension | Scale | Detection Signals |
|-----------|-------|------------------|
| **Technical complexity** | 1(simple)-5(complex) | Flesch-Kincaid score, jargon density, acronym frequency |
| **Verbosity** | 1(terse)-5(verbose) | Words per string, chars per string, information density |
| **Directness** | 1(indirect)-5(direct) | Imperative verb ratio, hedging words, sentence-initial verbs |
| **Empathy** | 1(detached)-5(empathetic) | Second-person pronoun density, emotional vocabulary, apology patterns |
| **Confidence** | 1(uncertain)-5(assertive) | Modal verb distribution ("should" vs "will"), definitive statements |

### Consistency Score

Calculate standard deviation per dimension across all strings. Flag strings deviating >1.5 standard deviations from mean on any dimension as outliers.

---

## Error Message Quality Scoring

Apply 5-dimension weighted rubric to each error message found:

| Dimension | Weight | Scoring Criteria |
|-----------|--------|-----------------|
| **Clarity** | 25% | Flesch-Kincaid grade, jargon presence, visible error codes |
| **Specificity** | 20% | Problem field identification, exact issue description |
| **Actionability** | 25% | Fix-it actions, format examples, corrective guidance |
| **Tone** | 15% | Blame language, positive/empathetic phrasing |
| **Accessibility** | 15% | ARIA association, multiple indicators, screen reader support |

### Automated Heuristic Flags

Flag messages that match:
- Flesch-Kincaid > 8 (too complex for error messages)
- Sentences > 25 words
- Messages > 40 words
- Passive voice > 10%
- Blame language: "you failed", "your error", "invalid input"
- Visible error codes: `ERR_*`, `0x[0-9A-F]+`, `HTTP \d{3}`
- Missing action verbs (no guidance on how to fix)

---

## i18n Maturity Assessment — Detection Details

### ICU MessageFormat Detection

Grep for ICU patterns indicating plural/gender-aware i18n:
- Plural: `\{\s*\w+\s*,\s*plural\s*,\s*(?:zero|one|two|few|many|other|=\d+)\s*\{`
- Select: `\{\s*\w+\s*,\s*select\s*,\s*\w+\s*\{`
- Format: `\{\s*\w+\s*,\s*(?:number|date|time)\s*(?:,\s*(?:short|medium|long|full))?\s*\}`

### RTL Support Detection

- Grep: `dir="rtl"` or `dir="auto"` in HTML templates
- Grep: CSS logical properties (`margin-inline-start`, `padding-inline-end`, `inset-inline-start`)
- Grep: `[dir="rtl"]` CSS selectors
- Check for RTL locale codes in supported locales (ar, he, fa, ur, ps)

### Hardcoded String Detection

- Grep in JSX/TSX for inline text: `>[^{<]*[A-Za-z]{3,}[^}<]*<`
- Exclude: UPPER_CASE constants, import paths, CSS class names, test IDs, `console.log` arguments

### String Interpolation Quality

- Named parameters (`{userName}`) = high maturity
- Positional with index (`%1$s`) = medium maturity
- Unnamed positional (`%s`, `%d`) = low maturity

### Centralization Scoring

**Positive signals** (+1 each): single `locales/` directory at root, consistent naming, single import source, i18n config file, namespaced dot-notation keys, CODEOWNERS entry for locale files.

**Negative signals** (-1 each): inline strings in components, multiple unrelated i18n directories, mixed hardcoded/translated in same component, no key naming convention, no i18n config.

Scores <= -2 cap maturity at Level 1 regardless of other signals.

### i18n Maturity Scale (0-5)

| Level | Name | Key Indicators |
|-------|------|---------------|
| **0** | None | No locale files, no i18n library, all strings hardcoded |
| **1** | Basic | i18n library installed but <30% externalized; single locale |
| **2** | Partial | 1-2 locales; 30-70% externalized; simple interpolation |
| **3** | Functional | 3+ locales; >70% externalized; pluralization; locale-aware formatting |
| **4** | Mature | 5+ locales; >95% externalized; ICU plural+select; RTL support; CLDR; governance |
| **5** | Excellence | 10+ locales; 100% externalized with lint; full ICU; bidi CSS; automated pipeline |

---

## Terminology Extraction

Build a glossary using ISO-704-inspired methodology:

### Term Discovery
- Apply TF-IDF across string corpus (treat each file/module as a document)
- High TF-IDF terms in specific modules = domain-specific candidates
- For multi-word terms, use C-value method to penalize nested terms that mostly appear as parts of longer terms

### Inconsistency Detection
- **Semantic**: Same concept, different terms (e.g., "Delete" vs "Remove" vs "Erase")
- **Syntactic**: Near-identical strings with minor wording differences
- **Frequency-based**: Most frequent variant = "preferred"; alternatives = "admitted" or "deprecated"

### Glossary Entry Format

```yaml
terms:
  - preferred: "workspace"
    admitted: ["project", "space"]
    deprecated: ["folder"]
    definition: "A container for organizing related files and settings"
    occurrences: 47
    files: ["src/components/Workspace.tsx", "locales/en/common.json"]
    status: preferred    # preferred | admitted | deprecated | forbidden
```

---

## Content Governance Detection

- Glob: `CODEOWNERS` — check for locale file ownership
- Check dependencies for content linting: `alex`, `write-good`, `vale`, `cspell`, `textlint`
- Check for i18n-related keywords in PR templates
- Check CI for missing translation checks
