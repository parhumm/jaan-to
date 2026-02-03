# Localization Preferences {#localization}

> Auto-generated for EduStream Academy integration testing
> Created: 2026-02-03

---

## Enabled Languages {#enabled-languages}

| Code | Language | Native Name | Direction | Script | Expansion | Status |
|------|----------|-------------|-----------|--------|-----------|--------|
| **EN** | English | English | LTR | Latin | Baseline | ✅ Enabled |
| **FA** | Persian/Farsi | فارسی | RTL | Perso-Arabic | +10-15% | ✅ Enabled |
| **TR** | Turkish | Türkçe | LTR | Latin | +22-33% | ✅ Enabled |
| **DE** | German | Deutsch | LTR | Latin | +30-35% | ✅ Enabled |
| **FR** | French | Français | LTR | Latin | +15-25% | ✅ Enabled |
| **RU** | Russian | Русский | LTR | Cyrillic | +10-15% | ✅ Enabled |
| **TG** | Tajik | Тоҷикӣ | LTR | Cyrillic | +10-15% | ✅ Enabled |

**Total Enabled**: 7 languages

---

## RTL Language Handling {#rtl-handling}

### Persian (FA) - RTL Configuration

**Direction**: Right-to-left (RTL)

**CSS Requirements**:
```css
[lang="fa"], [dir="rtl"] {
  direction: rtl;
  text-align: right;
}

/* Mirror layout for RTL */
.container-rtl {
  padding-right: 1rem; /* instead of padding-left */
  margin-right: auto; /* instead of margin-left */
}
```

**Text Formatting**:
- Use ZWNJ (Zero-Width Non-Joiner) for Persian plurals: کاربر‌ها
- Persian punctuation: ؟ (question mark), ، (comma), ؛ (semicolon), « » (quotes)
- Western numerals (0-9) for UI pragmatism (not Eastern Arabic numerals ۰-۹)

**Pronoun Guidelines**:
- Formal: شما (shomā) - Use for professional/educational contexts
- Informal: تو (to) - Use for casual/social contexts

---

## Text Expansion Guidelines {#text-expansion}

When designing UI components, account for text expansion in translated languages:

| Language | Typical Expansion | UI Impact |
|----------|-------------------|-----------|
| English (EN) | Baseline (100%) | Reference |
| Persian (FA) | +10-15% | Slightly longer |
| Turkish (TR) | +22-33% | Significantly longer (agglutinative) |
| German (DE) | +30-35% | Longest (compound words) |
| French (FR) | +15-25% | Moderately longer |
| Russian (RU) | +10-15% | Slightly longer |
| Tajik (TG) | +10-15% | Slightly longer |

**Design Recommendations**:
- Button labels: Reserve 35% extra width for German
- Form labels: Test with longest language (German)
- Tooltips: Allow text wrapping or dynamic sizing
- Navigation items: Prefer icons + text over text-only

---

## Pluralization Rules {#pluralization}

### Russian 3-Form Pluralization

Russian requires 3 plural forms based on numeric context:

```
{count, plural,
  one {# элемент}       // 1, 21, 31, 41, ...
  few {# элемента}      // 2-4, 22-24, 32-34, ...
  many {# элементов}    // 0, 5-20, 25-30, ...
  other {# элементов}
}
```

**Implementation**: Use ICU MessageFormat for Russian plurals.

---

## Font Recommendations {#fonts}

| Language | Script | Recommended Fonts |
|----------|--------|------------------|
| EN, TR, DE, FR | Latin | Inter, Roboto, Open Sans |
| FA | Perso-Arabic | Vazirmatn, IRANSans, Estedad |
| RU, TG | Cyrillic | Roboto, Open Sans (Cyrillic subset) |

---

## Quality Assurance {#qa}

### Pre-Deployment Checklist

- [ ] All enabled languages present in all microcopy packs
- [ ] RTL layout tested for Persian (visual QA with native speaker)
- [ ] Text expansion tested at 200% zoom (no overflow)
- [ ] Pronoun formality consistent across all items (formal for EduStream)
- [ ] Persian ZWNJ used for plurals
- [ ] Russian pluralization uses ICU MessageFormat
- [ ] German text doesn't break button layouts
- [ ] Native speaker review completed for all non-English languages

---

## Update History {#history}

- **2026-02-03**: Initial configuration (all 7 languages enabled)
