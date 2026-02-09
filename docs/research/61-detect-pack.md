# Best practices for automated repo-analysis skill output and content detection

**Automated codebase audit reports should follow a hybrid schema synthesizing SARIF evidence linking, CycloneDX confidence scoring, MADR frontmatter conventions, and Diátaxis document structure, while content/writing system detection requires a multi-signal approach combining glob-based file discovery, NLP-driven tone analysis, and industry-standard UI copy taxonomies.** This report provides spec-level standards backed by ISO, OWASP, NIST, and W3C frameworks alongside implementation-ready glob patterns, regex rules, decision trees, and scoring rubrics. The two topics interconnect: the output document schema defines *how* findings are reported, while the writing system detection methodology defines *what* gets detected and scored. Together, they form a complete specification for Claude Code skills that scan codebases and produce structured markdown documentation.

---

## Topic 1: The output document standard

### A synthesized frontmatter schema for audit reports

The strongest metadata schemas in industry all share common structural DNA. SARIF 2.1.0 requires `version`, `runs[].tool.driver.name`, and `runs[].results[]` as its core skeleton. CycloneDX mandates `bomFormat`, `specVersion`, and `metadata.timestamp`. OpenSSF Scorecard outputs include `repo.name`, `repo.commit`, `scorecard.version`, and per-check `score` (0–10). MADR 4.0.0 uses YAML frontmatter with `status`, `date`, `decision_makers`, and `tags`. Backstage TechDocs requires `catalog-info.yaml` with `apiVersion`, `kind`, `metadata.name`, and the critical `backstage.io/techdocs-ref` annotation.

The following synthesized YAML frontmatter schema draws from all five:

```yaml
---
# Document identity (SARIF run.automationDetails + MADR)
title: "Architecture Assessment: Project Name"
id: "AUDIT-2024-001"
version: "1.0.0"                         # Semver (SARIF tool.driver.semanticVersion)
status: draft                            # draft | review | final | superseded (MADR)

# Timestamps (SARIF invocations + CycloneDX metadata)
date: 2024-01-15
last_modified: 2024-01-20T14:30:00Z      # ISO 8601
analysis_start: 2024-01-08T09:00:00Z
analysis_end: 2024-01-08T09:45:00Z

# Target (CycloneDX metadata.component + SARIF versionControlProvenance)
target:
  name: "my-application"
  version: "2.3.1"
  repository: "https://github.com/org/repo"
  commit: "abc123def456"
  branch: "main"
  scope:                                  # Files analyzed (SARIF artifacts)
    - "src/**"
    - "lib/**"

# Tool metadata (SARIF tool.driver)
tool:
  name: "repo-analysis-skill"
  version: "1.0.0"
  rules_version: "2024.1"

# Classification (Backstage spec.type + CycloneDX lifecycle)
type: architecture-review               # security-audit | code-review | architecture-review | content-audit | writing-system
confidence_scheme: "four-level"          # Confirmed | Firm | Tentative | Uncertain
tags: [react, typescript, monorepo]

# Summary (OpenSSF Scorecard aggregate)
findings_summary:
  critical: 0
  high: 2
  medium: 5
  low: 8
  informational: 3
  overall_score: 7.2                     # 0-10 (OpenSSF style)

# Lifecycle (CycloneDX v1.5 lifecycles)
lifecycle_phase: post-build

# Related documents (MADR related)
related:
  - type: previous-audit
    ref: "audits/2023-q3-review.md"
supersedes: null
---
```

**Key design decisions**: The `confidence_scheme` field declares upfront which confidence model the document uses, following CycloneDX's approach of making evidence methodology explicit. The `target.commit` field is mandatory—Trail of Bits and OpenZeppelin both require exact commit hashes for reproducibility. The `findings_summary` mirrors OpenSSF Scorecard's per-check scoring rolled into severity buckets, while `lifecycle_phase` uses CycloneDX's vocabulary (design, pre-build, build, post-build, operations, discovery, decommission).

### Evidence citation format bridging SARIF and markdown

SARIF's `physicalLocation` object is the gold standard for evidence linking. It provides `artifactLocation.uri` (file path), `region.startLine`/`endLine`/`startColumn`/`endColumn` (precise location), and `region.snippet.text` (code excerpt), plus an optional `contextRegion` for surrounding context. Trail of Bits cites code as `Wrapper.sol::finalizeUnwrap`, while OpenZeppelin uses `src/Token.sol:L42-L55`. Semgrep outputs include `start.line`, `start.col`, `end.line`, `end.col` plus the matched source line.

The recommended evidence citation format for markdown audit documents:

**Inline reference syntax** (for use within prose):
```
See `src/auth/login.py:42-58` (evidence E001)
```

**Structured evidence block** (for formal findings):
```yaml
evidence:
  id: E001
  type: code-location          # code-location | config-pattern | dependency | metric | absence
  confidence: 0.95             # CycloneDX 0.0-1.0 scale
  location:
    uri: "src/auth/login.py"
    startLine: 42
    endLine: 58
    snippet: |
      query = "SELECT * FROM users WHERE id=" + user_id
  method: manual-review        # manifest-analysis | static-analysis | manual-review | pattern-match | heuristic
  tool: null                   # Tool name if automated
  rule_id: null                # Rule ID if tool-detected
```

**For findings that aggregate multiple evidence points**, the `evidence` field becomes an array. This mirrors how CycloneDX v1.5+ handles `evidence.identity.methods[]`—each with its own `technique` and `confidence` score. The key principle from SARIF: every claim must link to at least one physical location. Claims without evidence get `confidence: 0.0` and `type: absence`.

### A four-level confidence scoring system

After analyzing CVSS Report Confidence (Unknown/Reasonable/Confirmed), GRADE (High/Moderate/Low/Very Low), OpenSSF Scorecard (0–10 with -1 for inconclusive), OWASP Risk Rating (likelihood × impact), and SARIF's `level` + `precision` properties, the optimal synthesis is a **four-level scale adapted from GRADE**:

| Level | Label | Numeric range | Icon | Criteria |
|-------|-------|--------------|------|----------|
| 4 | **Confirmed** | 0.95–1.00 | ⊕⊕⊕⊕ | Multiple independent verification methods agree; or vendor-acknowledged; or reproducible demonstration |
| 3 | **Firm** | 0.80–0.94 | ⊕⊕⊕◯ | Single high-precision automated tool with known low false-positive rate; or manual review with clear code evidence |
| 2 | **Tentative** | 0.50–0.79 | ⊕⊕◯◯ | Pattern matching without full path analysis; or single medium-precision heuristic; requires further investigation |
| 1 | **Uncertain** | 0.20–0.49 | ⊕◯◯◯ | Absence-of-evidence reasoning; or expert judgment without corroborating code evidence |

**Downgrade one level** if: evidence is from an outdated code version, finding is in dead/unreachable code, or the tool has a known high false-positive rate for this rule type. **Upgrade one level** if: multiple independent tools agree, the finding is confirmed by the maintainer, or a large-scale systematic pattern is detected (not isolated).

The decision tree for assignment:

```
Has direct, verified evidence from the codebase?
├─ YES → Automated AND manual review confirm?
│   ├─ YES → CONFIRMED (⊕⊕⊕⊕)
│   └─ NO → High-precision single method?
│       ├─ YES → FIRM (⊕⊕⊕◯)
│       └─ NO → TENTATIVE (⊕⊕◯◯)
└─ NO → Based on indirect inference with multiple indicators?
    ├─ YES → TENTATIVE (⊕⊕◯◯)
    └─ NO → UNCERTAIN (⊕◯◯◯) or DO NOT INCLUDE
```

This maps cleanly to SARIF's `properties.confidence` (custom property bag), CycloneDX's `evidence.identity.confidence` (0.0–1.0 float), and CVSS Report Confidence (the three CVSS levels map to Confirmed=C, Firm=R, Tentative/Uncertain=U).

### Structured markdown document schema

Drawing from Diátaxis (tutorials, how-tos, reference, explanation), MADR's section hierarchy, RFC 2119's requirements language, and Google's eng-practices review structure, the recommended document sections are:

1. **Title** (H1): Short descriptive title following MADR convention
2. **YAML Frontmatter**: As specified above
3. **Executive Summary**: BLUF paragraph answering "what did we find and why does it matter?" (Diátaxis: explanation)
4. **Scope and Methodology**: What was analyzed, what tools were used, what was excluded (Diátaxis: reference). Use RFC 2119 language: "This analysis MUST be re-run after significant code changes."
5. **Findings**: Each finding as H3 with structured fields: ID, title, severity, confidence, description, evidence blocks, impact, remediation with RFC 2119 language (Diátaxis: reference + how-to)
6. **Recommendations Summary**: Prioritized remediation roadmap (Diátaxis: how-to)
7. **Appendices**: Methodology details, tool configurations, confidence scale reference (Diátaxis: reference)

**RFC 2119 usage rules**: Use MUST/SHOULD/MAY exclusively in the Recommendations sections for normative statements. Include the standard boilerplate: *"The key words MUST, SHOULD, and MAY in this document are to be interpreted as described in RFC 2119."* Never use RFC 2119 keywords for opinions or preferences—only for interoperability or harm-prevention requirements.

### Prohibited content and anti-patterns

Professional audit anti-patterns synthesized from SARIF false-positive handling, Trail of Bits/OpenZeppelin conventions, and technical due diligence literature:

- **Never present speculation as evidence.** Use hedging language ("This pattern is *consistent with*…") when confidence is below Firm. Prohibited: "This will definitely lead to…" or "Attackers could easily…" without quantification.
- **Never omit confidence levels.** Every finding MUST include a confidence tag. Presenting all findings with equal certainty is a critical anti-pattern in static analysis reporting.
- **Never include raw tool output without triage.** Report the true-positive rate: "Tool X reported 47 findings; manual review confirmed 31 (66% true positive rate)." SARIF's suppression model (`accepted`/`underReview`/`rejected`) provides the framework.
- **Never inflate severity.** Reserve Critical for verified, exploitable, high-impact issues. Trail of Bits uses a 2D severity×difficulty matrix; a High-severity but High-difficulty finding is less urgent than High-severity, Low-difficulty.
- **Never make scope-exceeding claims.** A code-only review cannot make authoritative infrastructure or deployment architecture claims. Distinguish "findings" (in-scope, evidence-backed) from "observations" (adjacent, lower confidence).

**Evidence language** (use when confidence ≥ Firm): "The code at `file.js:42` performs X, which demonstrates Y." **Hedging language** (use when confidence ≤ Tentative): "Based on the available evidence, it *appears that*… pending further investigation."

---

## Topic 2: Writing system and content style detection

### Canonical structure for a detected writing system

Analysis of **10 major industry style guides**—Google Material Design, Microsoft Writing Style Guide, Apple HIG, GOV.UK Content Design, Shopify Polaris, Atlassian Design System, Salesforce Lightning, Mailchimp Content Style Guide, IBM Carbon, and Nielsen Norman Group research—reveals a consistent structural pattern. Mailchimp (widely cited as the gold standard) organizes by content type and context rather than grammar rules alone. Shopify Polaris embeds content guidance at the component level. NNg provides the theoretical framework with its **four dimensions of tone**: Formality (formal↔casual), Humor (serious↔funny), Respectfulness (respectful↔irreverent), and Enthusiasm (matter-of-fact↔enthusiastic).

The detected writing system should output to this schema:

```
writing-system.md                      # Single-file output
├── Frontmatter (YAML)                 # voice dimensions, confidence, methodology
├── Voice definition                   # 3-5 traits with do/don't tables
├── Tone spectrum                      # NNg 4-dimension positioning
├── Terminology glossary               # Extracted terms with status
├── UI copy patterns                   # Per-category findings
│   ├── Buttons/CTAs
│   ├── Error messages
│   ├── Empty states
│   ├── Dialogs/confirmations
│   ├── Notifications/toasts
│   ├── Onboarding
│   ├── Form labels/helper text
│   └── Loading states
├── Plain language assessment          # Readability scores, targets
├── i18n maturity assessment           # 0-5 scale with evidence
└── Recommendations                    # Prioritized improvements
```

**Frontmatter for the writing system document:**
```yaml
---
title: "Writing System Analysis"
type: writing-system
target:
  name: "my-app"
  commit: "abc123"
voice_dimensions:
  formality: 3.2        # 1=formal, 5=casual
  humor: 1.8            # 1=serious, 5=funny
  respectfulness: 4.1   # 1=irreverent, 5=respectful
  enthusiasm: 3.5       # 1=matter-of-fact, 5=enthusiastic
confidence: Firm
strings_analyzed: 847
locales_detected: ["en", "fr", "de", "ja"]
i18n_maturity: 3        # 0-5 scale
---
```

### Voice and tone detection methodology

The extraction process follows a five-phase methodology synthesized from Kristina Halvorson's content audit framework, Torrey Podmajersky's "Strategic Writing for UX" voice chart method, and NNg's tone measurement research.

**Phase 1: String inventory.** Extract all user-facing strings from i18n files, component props (`label`, `title`, `message`, `description`, `placeholder`, `helperText`, `errorMessage`), and inline text. Classify each by type: button, label, error, success, empty state, tooltip, notification, heading, body.

**Phase 2: Quantitative linguistic analysis.** For each string, compute: Flesch-Kincaid grade level, average word count, contraction frequency (casual signal), active vs. passive voice ratio, person usage distribution (first/second/third), capitalization pattern (title vs. sentence case), punctuation density (exclamation marks signal enthusiasm), and sentiment polarity (VADER or AFINN scores).

**Phase 3: Dimension scoring.** Map computational signals to NNg's four dimensions plus five extended dimensions:

| Dimension | Key detection signals |
|-----------|---------------------|
| **Formality** (1–5) | Contraction ratio, average sentence length, passive voice %, Flesch-Kincaid grade, Latin-derived word ratio |
| **Humor** (1–5) | Exclamation frequency, emoji presence, metaphor/wordplay detection, dry/factual phrasing ratio |
| **Respectfulness** (1–5) | Politeness markers ("please"/"thank you"), hedging frequency, direct commands vs. requests |
| **Enthusiasm** (1–5) | Exclamation marks, superlatives ("amazing"/"great"), intensifiers ("very"/"extremely"), celebratory language |
| **Technical complexity** (1–5) | Flesch-Kincaid score, jargon density, acronym frequency |
| **Verbosity** (1–5) | Words per string, characters per string, information density |
| **Directness** (1–5) | Imperative verb ratio, hedging words ("might"/"could"), sentence-initial verbs |
| **Empathy** (1–5) | Second-person pronoun density, emotional vocabulary, apology patterns |
| **Confidence** (1–5) | Modal verb distribution ("should" vs. "will"), definitive statements |

**Phase 4: Voice trait derivation.** From the quantitative analysis, identify **3–5 dominant voice traits** (e.g., "Direct," "Helpful," "Professional"). For each trait, generate a do/don't table in Podmajersky's format:

```markdown
## Voice trait: Direct

**Definition**: We say exactly what the user needs to know, without filler.
**Spectrum position**: Formality 3.2 (mid-casual), Directness 4.1 (high)

| ✅ Do | ❌ Don't | Why |
|-------|---------|-----|
| "Save changes?" | "Would you like to save the changes you've made?" | Conciseness |
| "3 files uploaded" | "Your files have been successfully uploaded to the server" | Brevity |
```

**Phase 5: Consistency scoring.** Calculate the standard deviation of each dimension across all strings. High variance indicates inconsistent voice—a key finding in itself. Flag strings that deviate more than 1.5σ from the mean on any dimension.

### Terminology extraction adapted for codebases

The methodology draws from ISO 704:2022 (Objects→Concepts→Designations framework), ANSI/NISO Z39.19 controlled vocabulary construction, C-value/NC-value algorithms, and the CodeAmigo identifier inconsistency detector.

**Step 1: Extract candidate terms.** Mine all user-facing strings from i18n files and component text. Apply TF-IDF across the corpus, treating each file/module as a document. Terms with high TF-IDF scores in specific modules are domain-specific candidates. For multi-word terms, apply the C-value method: `C-value(a) = log₂|a| × (f(a) - (1/P(Tₐ)) × Σf(b))` where nested terms are penalized when they mostly appear as parts of longer terms.

**Step 2: Detect inconsistencies.** Using CodeAmigo's methodology (85.4% precision in empirical studies), detect three inconsistency types:
- **Semantic inconsistency**: Same concept, different terms. Cluster strings by embedding similarity (sentence transformers), then flag clusters where semantically similar strings use different vocabulary. Example: "Delete" vs. "Remove" vs. "Erase" for the same action.
- **Syntactic inconsistency**: Near-identical strings with minor spelling/wording differences. Flag string pairs with Levenshtein edit distance < 3 and different content.
- **Frequency-based canonicalization**: For synonym groups, the most frequent variant is "preferred" (ISO 704 term status); alternatives are "admitted" or "deprecated."

**Step 3: Build the glossary entry format** (per ISO 704):
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

### Eight categories of UI copy with detection heuristics

Each category includes component name patterns (glob-ready for codebase scanning), quality criteria, and best-practice structures from NNg, Microsoft, Apple, Google Material Design, and major design systems.

**1. Buttons/CTAs.** Best practice: verb + noun, 1–3 words, action describes the outcome. Component patterns: `*Button*`, `*Btn*`, `*CTA*`, `*Submit*`, `*Action*`, `*PrimaryAction*`. Quality signals: starts with action verb, ≤3 words, not generic ("Submit"/"OK"/"Go"). Anti-pattern: noun-only labels, >"Click Here", inconsistent verb usage across the app.

**2. Error messages.** Best practice (PatternFly/NNg three-part formula): Description (what happened) + Reason (why) + Resolution (how to fix). Component patterns: `*Error*`, `*ErrorMessage*`, `*ValidationError*`, `*ErrorBoundary*`, `*ErrorState*`, `*ErrorSummary*`. Quality scoring uses five weighted dimensions: Clarity (25%), Specificity (20%), Actionability (25%), Tone/Blame (15%), Accessibility (15%). NNg's 12-guideline rubric provides the detailed scoring: **7–8th grade reading level** target, accountability on the system (never blame the user), ≤40 words for inline errors.

**3. Empty states.** Best practice (Kinneret Yifrah formula): Heading + Motivation/Explanation + CTA. Types: first-use, user-cleared, no-results, error, completion (Inbox Zero). Component patterns: `*EmptyState*`, `*NoData*`, `*NoResults*`, `*ZeroState*`, `*BlankState*`, `*NothingFound*`. Quality signal: includes both explanation AND actionable CTA. Critical anti-pattern: literally empty screen with no guidance.

**4. Confirmation dialogs.** Best practice: Specific action title ("Delete invoice #4839?") + consequence description + action-specific buttons (never "Yes/No"). Component patterns: `*Dialog*`, `*Modal*`, `*Confirm*`, `*AlertDialog*`, `*ConfirmDialog*`, `*ConfirmModal*`. Quality signal: button labels match the triggering action; destructive action visually distinct. Critical anti-pattern: "Are you sure?" with Yes/No.

**5. Notifications/toasts.** Best practice: under 10 words, auto-dismiss in **500ms × word count + 1000ms buffer** for informational; persist for errors. Component patterns: `*Toast*`, `*Notification*`, `*Snackbar*`, `*Banner*`, `*Flash*`, `*StatusMessage*`, `*Callout*`. Severity types: success (green), warning (yellow), error (red), info (blue). Critical anti-pattern: auto-dismissing toasts containing actionable buttons.

**6. Onboarding.** Best practice: ≤100 characters per step, single CTA per step, progress indicator. Component patterns: `*Onboarding*`, `*Tour*`, `*Walkthrough*`, `*Welcome*`, `*GettingStarted*`, `*Stepper*`, `*Wizard*`, `*CoachMark*`, `*Hotspot*`. Quality signal: focuses on user benefit, not feature description.

**7. Form labels/helper text.** Best practice: label above field (always visible), helper text below field (persistent, not hidden), placeholder for format examples only. Component patterns: `*FormField*`, `*Label*`, `*HelperText*`, `*HintText*`, `*TextField*`, `*FormControl*`, `*FieldDescription*`. Critical anti-pattern: placeholder text as the only label.

**8. Loading states.** Best practice by duration: <300ms no indicator, 300ms–2s spinner, 2s–10s skeleton screen, >10s progress bar with time estimate. Component patterns: `*Loading*`, `*Spinner*`, `*Skeleton*`, `*Progress*`, `*Shimmer*`, `*Suspense*`, `*LoadingFallback*`. Quality signal: loading copy specifies WHAT is loading. Critical anti-pattern: infinite loading with no timeout/error handling.

**Detection strategy across all categories**: Search for component names matching the glob patterns above. Extract text from props: `children`, `label`, `title`, `message`, `description`, `placeholder`, `helperText`, `errorMessage`, `successMessage`, `confirmText`, `loadingText`, `emptyText`. Inspect variant/severity props (`variant="error"`, `severity="warning"`, `isLoading`, `isEmpty`, `isDestructive`) to classify ambiguous components.

### Error message quality scoring rubric

Synthesized from NNg's 12 guidelines, Microsoft's three-part structure, Apple HIG's three questions, WCAG SC 3.3.1/3.3.3, and Material Design error patterns:

| Dimension | Weight | 9–10 score | 5–6 score | 0–2 score |
|-----------|--------|------------|-----------|-----------|
| **Clarity** | 25% | ≤7th grade Flesch-Kincaid; no jargon; no visible error codes | Somewhat readable but includes some jargon | Incomprehensible, pure technical jargon |
| **Specificity** | 20% | Precisely identifies problem field AND exact issue | Describes general problem, lacks specificity | No problem description, or only error code |
| **Actionability** | 25% | Specific, low-effort corrective action (fix-it button, exact format) | Suggests direction but lacks specific steps | No guidance; dead-end error |
| **Tone** | 15% | Positive/empathetic; accountability on system; no blame | Neutral; doesn't blame user | Explicitly blames user; hostile or shaming |
| **Accessibility** | 15% | WCAG AA+; 3+ redundant indicators; proper ARIA; announced to screen readers | Partially accessible; relies on color + one other indicator | Invisible, inaccessible, or premature |

**Automated heuristics** for CI/scoring: flag Flesch-Kincaid > 8, sentences > 25 words, error messages > 40 words, passive voice > 10%, banned complex words ("utilize"→"use", "facilitate"→"help"), visible error code patterns (`ERR_*`, `0x[0-9A-F]+`, `HTTP \d{3}`), blame language ("you failed", "your error", "invalid input"), and missing action verbs.

### Plain language readability targets by UI copy type

Based on the US Plain Writing Act (average 20 words/sentence), GOV.UK (target reading age of 9), NNg (7–8th grade for errors), and Federal Plain Language Guidelines:

| Copy type | Flesch-Kincaid max | Max words | Key constraint |
|-----------|-------------------|-----------|----------------|
| Button labels | Grade 4 | 3 | Verb-first; describe the result |
| Validation messages | Grade 6 | 20 | Brief, inline |
| Toast notifications | Grade 6 | 15 | Glanceable in 5–8 seconds |
| Form labels | Grade 6 | 15 | Clear, direct |
| Onboarding steps | Grade 6 | 30 per step | Progressive disclosure |
| Error messages | Grade 7–8 | 40 | Must include problem + action |
| Empty states | Grade 7 | 40 | Explain + suggest action |
| Helper/tooltip text | Grade 7 | 25 | Contextual guidance |
| Modal dialog body | Grade 8 | 60 | Consequence + action |

**Important caveat**: Readability formulas (Flesch-Kincaid, SMOG, Gunning Fog, Coleman-Liau) are designed for prose of 100+ words and produce unreliable results for short UI strings. They measure surface features (word/sentence length), not comprehension. Use them as one signal among many, not a pass/fail gate. The gold standard remains usability testing with representative users.

### i18n maturity detection with implementation-ready patterns

**Glob patterns for locale file discovery** (the most critical implementation artifact):

| Framework | Glob patterns |
|-----------|--------------|
| React i18next | `**/locales/**/*.json`, `**/i18n/**/*.json`, `**/public/locales/{locale}/*.json` |
| Vue i18n | `**/locales/*.json`, `**/i18n/**/*.json`, `**/lang/**/*.{json,yml}` |
| Angular | `**/src/locale/messages.*.xlf`, `**/src/locale/messages.*.xlf2` |
| Next.js | `**/public/locales/{locale}/*.json`, `**/messages/{locale}.json` |
| Flutter/Dart | `**/lib/l10n/*.arb`, `**/l10n/app_*.arb` |
| Android | `**/res/values/strings.xml`, `**/res/values-*/strings.xml` |
| iOS/macOS | `**/*.lproj/Localizable.strings`, `**/*.lproj/Localizable.stringsdict` |
| Rails | `**/config/locales/**/*.yml` |
| Django | `**/locale/*/LC_MESSAGES/django.po` |
| Java | `**/resources/messages*.properties`, `**/resources/*_*.properties` |
| .NET | `**/Resources/*.resx`, `**/Resources/*.*.resx` |
| PHP/Laravel | `**/resources/lang/*/*.php`, `**/lang/*/*.php`, `**/resources/lang/*.json` |
| GNU gettext | `**/po/*.po`, `**/po/*.pot`, `**/locale/*/LC_MESSAGES/*.po` |

**ICU MessageFormat detection regex** (indicates plural/gender-aware i18n):
```regex
\{\s*\w+\s*,\s*plural\s*,\s*(?:zero|one|two|few|many|other|=\d+)\s*\{
\{\s*\w+\s*,\s*select\s*,\s*\w+\s*\{
\{\s*\w+\s*,\s*(?:number|date|time)\s*(?:,\s*(?:short|medium|long|full))?\s*\}
```

**RTL support detection**: `dir="rtl"` or `dir="auto"` in HTML templates; CSS logical properties (`margin-inline-start`, `padding-inline-end`, `inset-inline-start`); `[dir="rtl"]` CSS selectors; RTL locale codes in supported locales (ar, he, fa, ur, ps).

**Hardcoded string detection**: Use ESLint plugins `eslint-plugin-i18next` (no-literal-string rule), `react/jsx-no-literals`, or regex `>[^{<]*[A-Za-z]{3,}[^}<]*<` for JSX. False positive reduction: ignore UPPER_CASE constants, import paths, CSS class names, test IDs, `console.log` arguments.

**String interpolation quality signals**:
- Named parameters (`{userName}`) = high maturity (translators can reorder)
- Positional with index (`%1$s`) = medium maturity
- Unnamed positional (`%s`, `%d`) = low maturity (translators cannot reorder)

**Content governance detection**: CODEOWNERS entries matching locale patterns (`locales/**  @i18n-team`); content linting tools in dependencies (`alex`, `write-good`, `vale`, `cspell`, `textlint`); i18n-related keywords in PR templates; CI checks for missing translations.

**The i18n maturity scale (0–5)**:

| Level | Name | Key indicators |
|-------|------|---------------|
| **0** | None | No locale files, no i18n library, all strings hardcoded |
| **1** | Basic awareness | i18n library installed but <30% strings externalized; single locale |
| **2** | Partial | 1–2 locales; 30–70% externalized; simple interpolation; no pluralization |
| **3** | Functional | 3+ locales; >70% externalized; pluralization; locale-aware date/number formatting; fallback configured |
| **4** | Mature | 5+ locales; >95% externalized; ICU plural+select; RTL support; CLDR usage; content governance (CODEOWNERS, CI) |
| **5** | Excellence | 10+ locales; 100% externalized with lint enforcement; full ICU; bidi CSS logical properties; style linting; automated translation pipeline; pseudo-localization testing |

### How centralized vs. scattered string management maps to maturity

**Centralized indicators** (each scores +1): single `locales/` or `i18n/` directory at project root; all locale files follow consistent naming (`{locale}.json` or `{locale}/{namespace}.json`); translation function imported from a single module; i18n config file exists; translation keys use namespaced dot-notation (`pages.home.title`); CODEOWNERS entry for locale files.

**Scattered indicators** (each scores −1): translation strings defined inline in components; multiple unrelated i18n directories; mix of hardcoded and translated strings in the same component; no consistent key naming convention; no dedicated i18n config file.

The centralization score directly informs the overall i18n maturity level: scores ≤ −2 cap maturity at Level 1 regardless of other signals.

## Connecting the two topics into a unified spec

The output document standard (Topic 1) and the content detection methodology (Topic 2) connect through the evidence citation format. Every writing system finding—a voice dimension score, a terminology inconsistency, an error message quality assessment, or an i18n maturity rating—must be backed by evidence in the SARIF-compatible format described above. A finding that "error messages average grade 11 readability" cites evidence blocks pointing to specific strings in specific files with line numbers. A finding that "the codebase uses 'Delete' and 'Remove' inconsistently" cites the specific occurrences of each term.

The confidence scoring system applies universally. An i18n maturity assessment based on glob pattern file discovery and dependency analysis earns **Firm** confidence (automated detection with known high precision). A voice dimension score derived from NLP analysis of 847 strings earns **Tentative** confidence (heuristic-based, benefits from human validation). A terminology inconsistency detected by embedding similarity earns **Tentative** unless manually confirmed, at which point it upgrades to **Confirmed**.

The document structure follows the same Diátaxis-informed sections regardless of audit type. A writing system analysis uses the same frontmatter schema, the same evidence format, and the same confidence levels as a security audit or architecture review—ensuring that all repo-analysis skills produce consistent, interoperable, machine-parseable yet human-readable markdown documentation.