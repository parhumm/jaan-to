---
title: "humanize"
sidebar_position: 11
---

# /humanize

> Rewrite or audit English and Persian text that sounds AI-written, keeping every fact.

---

## What It Does

Finds the language of the text (not of your request), loads the English or Persian rules, and lists the AI-writing signs it sees. After you approve the plan, it rewrites the text for its reader and runs a bundled checker that fails on leftover strong signs, clusters of medium signs, dropped or invented numbers, names and links, changed quotations, and added hidden characters.

Persian text also gets an orthography pass (half-spaces, Persian digits and punctuation) and a register check (official, human formal, semi-formal, colloquial). Arabic and other languages are declined in one line.

---

## Usage

```
/humanize {text or file path}
/humanize {text or file path} --audit
```

| Mode | What you get |
|------|--------------|
| rewrite (default) | The rewritten text, checked against the original, plus Flags for missing facts and assumptions |
| audit | A report of strong signs, medium clusters and the top fixes. Nothing is rewritten unless you ask |

---

## Examples

**English email**:
```
/humanize ./drafts/client-update.md
```

**Persian post**:
```
/humanize «این متن را طبیعی‌تر کن: …»
```

**Audit only**:
```
/humanize ./README.md --audit
```

---

## Workflow

1. **Analysis (read-only)**: language, reader, genre and register; the checker runs on the source.
2. **HARD STOP**: you see the plan or audit, the top problems, what stays as written, and the missing facts.
3. **Rewrite and verify**: up to three check rounds, then a manual checklist.
4. **Approve and save**: the text is written only after you keep it.

---

## Output

```
jaan-to/outputs/writing/humanize/{id}-{slug}/
├── {id}-{slug}.md    # the rewrite only, ready to paste
├── source.md         # the original (skipped when you passed a file)
└── facts.md          # facts you confirmed, if any
```

Bilingual text is split, checked per language and joined back in its original order.

---

## Limits

- Better writing, not evasion. It doesn't change any duty to disclose AI use.
- No invisible characters, homoglyphs, deliberate typos or "AI humanizer" services.
- A detector's "AI %" is never the goal, and an audit is style evidence, not proof of who wrote the text.
- Missing details are marked `[ADD: …]`, never invented.

The checker needs Python 3 only. For Persian spellcheck, set `PERSIAN_WORDS=/path/to/persian_words.txt`.
