# Humanize: English pack

> Loaded by `skills/humanize/SKILL.md`. The phases, paths and script commands live there; this pack holds the English rules.

Turn text that reads as machine-generated into text a careful person would write for this reader. The change has to be real: fix the substance, the structure and the wording, keep every fact, then **verify** with the bundled checker. Swapping synonyms barely works. Swapped text keeps 91.4% of a model's fingerprint, against 58.1% after a real restructure, and it stays just as empty.

Files in this folder:
- `signs-of-ai-writing-en.md`: the full catalog (642 lines). Read the sections you need using the map at the end.
- `research-updates-en.md`: Nov 2026 corrections, new patterns, new genres. **It wins over the guide where they differ.**
- The verifier is `scripts/check_tells.py` in the skill folder. SKILL.md Steps 4 and 7 run it.

## Limits (read first)

- **Better writing, not evasion.** If the user must disclose AI use (coursework, journalism, legal, contracts, platform rules), the rewrite doesn't change that. Say so in one line if the context suggests it. A thorough rewrite also removes any watermark or provenance signal (SynthID, C2PA).
- **No tricks.** Never insert invisible characters, homoglyphs, deliberate typos, broken grammar or random slang to "look human". They make the text worse and are deceptive. The checker fails a rewrite that adds hidden characters.
- **No humanizer tools.** Never pipe text through a paraphraser or "AI humanizer" service. They change facts or quotations in 35–65% of the documents that contain them.
- **No detector gate.** Don't use a detector's "AI %" as the goal or as proof. Detectors misfire on short, paraphrased, non-native and neurodivergent writing, with more than 60% false positives on non-native essays.
- **Audit ≠ accusation.** Signs are evidence about style, not about who wrote the text. Many human writers trigger them: formal, non-native, neurodivergent and technical writers.

## Inputs

1. **The text.** Phase 2 saves it word for word as `source.{ext}` before editing, so the checker can compare. If it came as a file, use that path.
2. **Reader, genre, destination.** Infer them from the text (an email to a client, a README, a LinkedIn post). Ask only if the guess would change the result and the text gives no clue. Otherwise state the assumption under Flags.
3. **Facts the user confirms.** Phase 2 saves anything the user adds (numbers, names, results) to `facts.md`. These are the only new details you may add.
4. **Mode.** Rewrite is the default. Use audit when the user asks "does this sound like AI?", "find the AI signs" or "review only".

## Rules

1. **Keep the meaning.** Every fact, number, name, date, link, quote and claim survives, unless it is pure filler.
2. **Never invent.** If a vague claim needs a detail you don't have, cut it or mark it `[ADD: what is missing]`. If a fact looks wrong, mark it `[VERIFY: …]`. A made-up anecdote, number or quote is worse than a vague sentence.
3. **Fix substance before surface.** Remove empty claims and padding first, then change the wording.
4. **Clusters matter, single words don't.** One "additionally" is fine. Three or more Medium signs in one paragraph is the problem.
5. **Don't swap one tell for another.** Every em dash turned into a semicolon, every "moreover" into "on top of that", is a new fingerprint. Vary the fixes and restructure.
6. **Match genre and register.** Don't make formal text chatty or chatty text formal. Keep precise hedges in medical, legal, financial, safety and research text.
7. **Keep quotes as written.** Quoted speech, quoted sources, code, commands, product names and titles stay word for word.
8. **Return only the text**, plus flags (see Output).

## Workflow

Work in this order, because each step changes what the next one finds:

1. **Strip artifacts (guide G, Strong).** Remove chat openers and closers ("Certainly!", "Here is a revised…", "I hope this helps", "Let me know if…"), model self-reference, source disclaimers, placeholders (`[Your Name]`, `2025-XX-XX`), tool tokens (`oaicite`, `turn0search0`, `【4†source】`) and tracking parameters (`utm_source=chatgpt.com`). Remove prompt echo too ("Based on the document you shared…"). Keep the clean URL.
2. **Audit substance (A).** Mark every sentence that claims something without evidence, praises without saying why, or could be pasted unchanged into a text on another subject. Make it specific with facts you have, cut it, or flag it. Moving a claim about a whole category onto the subject ("Remote work is more than a trend" → "Our team made remote work a way of life") isn't specific; it invents a fact. With no supporting fact, cut it.
3. **Break formulas (C, D).** Look for: "not X but Y", reflexive triplets, false "from X to Y" ranges, "-ing" significance tails, summary endings, uniform paragraphs, needless headings and bullets, bare "This matters." beats, and nominalizations ("conduct an evaluation of" → "evaluate").
4. **Vocabulary (B, §4 tables).** Rewrite the sentence around a fact; don't swap in a synonym. A single word from the list is Weak. Clusters are what count.
5. **Tone (E).** Look for sycophancy, generic enthusiasm, template greetings and sign-offs, fake candor ("genuinely", "And honestly?") and forced punchiness.
6. **Formatting (F) for the destination.** Email, Word, plain web text and most forms don't render Markdown, so remove `**bold**`, `#` headings and decorative emoji there. Keep Markdown in a README, docs or chat. Use em dashes sparingly and vary the replacements.
7. **Newer-model tells (H, research §2).** Look for short punchy sentences in series, abstract nouns standing in for facts, and the model fingerprints in research-updates §2 N5.
8. **Genre pass.** Check the matching example: guide §5 (stakeholder email, cover letter, blog intro, encyclopedic, LinkedIn, résumé) or research-updates §5–6 (fiction, PR or README, abstract, forum reply, product review, press release, support reply, journalism).
9. **Read it aloud.** Change anything you wouldn't say to this reader.
10. **Verify** (next section). Don't skip it. It catches dropped numbers and leftover tokens that a read-through misses.

## Signal strength

The checker uses these levels. They are the guide's §2 with the research corrections applied.

| Level | Examples | Action |
|---|---|---|
| **Strong** | chat phrases, model self-reference, source disclaimers, placeholders, tool tokens, `utm_source=chatgpt.com`, prompt echo, "Certainly! Below is" | Always remove |
| **Medium** | B1 word clusters, sentence-initial formal transitions, stock phrases, "serves as", negative parallelism, forced punchiness, wordy phrases, nominalizations, fake candor, "This matters." | Fix when 3+ in a paragraph; fix a lone one only if it hurts the sentence |
| **Weak** | single viral words, em dashes, uniform rhythm, Markdown and emoji, curly quotes, hidden characters as evidence, formality, perfect grammar | Context only; never act on these alone (but strip hidden characters, and fix Markdown for a destination that doesn't render it) |

Era caveats: A3 vague attribution, C1 copula avoidance, D1 restating summaries and G6 cut-offs are rarer in frontier 2025–26 models and still common in budget or legacy output. G2 ("as an AI language model") is rare now, but it is Strong whenever it appears.

## Verify

Run the checker on the rewrite with the original, and any confirmed facts, as sources (SKILL.md Step 7).

It exits 0 on PASS and 1 on FAIL. It fails on:
- any Strong tell;
- any paragraph with 3+ Medium tells;
- **fact drift**: a number, URL or name in the source that's missing from the output, or a new one that isn't in the source or facts (`[ADD: …]` and `[VERIFY: …]` markers are ignored);
- invisible characters or homoglyphs that the rewrite added;
- a quotation or `>` blockquote of 4+ words from the original that is no longer verbatim.

It also reports isolated Medium hits, Weak signs, sentence-length rhythm and your open flags. It skips anything in quotes and `>` blockquotes, since those stay as written.

Loop until it PASSES, up to 3 rounds. If an item is legitimately kept (a real product called "Pivotal", a quoted phrase, a number deliberately removed as filler), leave it and say why under Flags. A checker PASS is necessary but not sufficient. Then check by hand what a regex can't:

- [ ] Hedges, conditions and scope kept ("may", "in mice", "associated with" doesn't become "causes")
- [ ] No claim stronger or weaker than the source; no new claims
- [ ] Quotes, code, names and titles unchanged
- [ ] Every vague claim was made specific from given facts, cut, or flagged `[ADD]`
- [ ] Register fits the reader; greeting and sign-off sound like the sender
- [ ] The guide's §8 checklist (lines 595–608)

## Output

**Rewrite mode:** output the rewritten text with nothing before it. After it, only if needed:

```
---
Flags:
- [ADD: …] / [VERIFY: …] items, in order
- Assumptions (reader, genre) and anything deliberately kept
Check: check_tells PASS (0 strong, no clusters, facts intact)
```

If you write the rewrite to a file, the file holds only the text. Put the flags in your reply.

**Audit mode:** don't rewrite. Report:

```
AI-writing signs (style evidence, not a verdict on authorship)
Strong: <each, with line and fix>
Medium clusters: <paragraph: signs>
Weak / context: <brief>
Top fixes: <3 highest-value changes>
```

Run `check_tells.py` without `--source` (SKILL.md Step 4) to collect the evidence, then add the substance problems (A, D) that only reading finds.

## Reference map

`signs-of-ai-writing-en.md`. Read the section, not the whole file:

| Lines | Section |
|---|---|
| 10–23 | §0 rules · 27–36 §1 workflow · 40–46 §2 strength |
| 52–147 | A content and substance (A1–A12) |
| 149–196 | B vocabulary (B1 word-cluster table, transitions, buzzwords) |
| 198–269 | C sentence structure (copula, parallelism, triplets, rhythm, punchiness) |
| 271–302 | D paragraph and document structure |
| 304–325 | E tone and voice |
| 327–356 | F formatting and punctuation |
| 358–385 | G chat and tool artifacts |
| 387–403 | H newer-model tells |
| 409–471 | §4 replacement tables (words, phrases) |
| 477–560 | §5 before/after examples: email 477, cover letter 505, blog 515, encyclopedic 525, LinkedIn 537, résumé 551 |
| 563–576 | §6 over-correction traps · 580–591 §7 weak signs · 595–608 §8 checklist |

`research-updates-en.md`: §1 strength corrections, §2 new patterns N1–N6, §3 new traps, §4 limits, §5 genre examples (fiction, PR, abstract, forum, review), §6 genre notes, §7 citation fixes.
