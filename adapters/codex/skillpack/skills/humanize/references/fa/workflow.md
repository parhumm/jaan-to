# Humanize: Persian pack

> Loaded by `skills/humanize/SKILL.md`. The phases, paths and script commands live there; this pack holds the Persian rules.

Turn Persian text that reads as machine-generated or translated into text a careful Iranian writer would produce for this reader. AI Persian is usually "too correct": too formal, too bookish, full of ceremony no working writer uses. The fix is not "write casually everywhere". **Pick the right register, then remove the tells.** Keep every fact, verify with the bundled tools, and never touch quotations, poetry, Quranic verses or proper names.

Files in this folder:
- `signs-of-ai-writing-fa.md`: the full Persian catalog (960 lines, right-to-left, written in Persian). Read the sections you need using the map at the end.
- `research-updates-fa.md`: Nov 2026 corrections, new patterns, new genres. **It wins over the guide where they differ.**
Scripts in the skill's `scripts/` folder (SKILL.md Steps 4 and 7 run them):
- `persian_cleanup.py`: conservative editorial pass for ZWNJ, ی/ک, spacing and punctuation.
- `fa_lint.py`: reports orthography and register issues; `--rhythm` adds sentence-length variation.
- `check_tells.py`: AI tells, fact drift, quotes kept, hidden characters. Stdlib Python 3.
- The two Persian scripts come from the `persian-writing` project, MIT licensed (`scripts/LICENSE-persian-writing.txt`). Local fixes are marked `humanize-fa change` (this pack's original name); `persian_cleanup.py --self-test` and `check_tells.py --self-test` guard them. Spellcheck is optional and needs its 7 MB word list. Set `PERSIAN_WORDS=/path/to/persian_words.txt` or install the persian-writing skill. Everything else works without it.

## Limits (read first)

- **Better writing, not evasion.** No invisible characters, homoglyphs, watermark removal or injected errors. Where AI use must be disclosed (thesis, journal article, contract, employer policy), it still must be. A thorough rewrite removes SynthID-style watermarks, so mention this in one line when the context is academic or professional.
- **No humanizer tools.** Paraphrasing services change facts and quotations in 35–65% of the documents that contain them. For Persian text, that includes verses.
- **No detector gate.** Persian AI detectors are unreliable (only one tool in the Zoomit test caught Persian AI text). Never use a score as the goal.
- **Audit ≠ accusation.** Bureaucratic phrasing (می‌باشد, در راستای, نقش بسزایی) is an old habit of Persian administrative writing and journalism, learned by models from the Persian web. It always makes text worse, but alone it never proves a machine wrote it. Formality alone is Weak, because Persian has a wide formal–colloquial gap.

## Inputs

1. **The text.** Phase 2 saves it word for word as `source.{ext}` before editing.
2. **Register clues.** Note any explicit instruction, the document type, the reader and the channel (step 1 below).
3. **Facts the user confirms** go in `facts.md`. They are the only new details you may add.
4. **Mode.** Rewrite is the default. Use audit when the user asks «ماشینی است؟», «نشانه‌ها را پیدا کن» or "review only".

## Rules

1. **Keep the meaning.** Every fact, number, name, date and claim survives, unless it is pure filler.
2. **Never invent.** Cut a vague claim or mark it `[ADD: …]`. Mark a doubtful fact `[VERIFY: …]`. A made-up anecdote is worse than a vague sentence. Don't turn a description into a first-person visit, a taste verdict or a "popular lately" claim unless the user says so.
3. **Fix substance before surface.** Changing می‌باشد to است fixes nothing if the paragraph still says nothing.
4. **Clusters matter, single words don't.** One «همچنین» is fine. «همچنین» plus «می‌باشد» plus «در دنیای امروز» in one paragraph is a confession.
5. **Don't swap one tell for another.** Every em dash turned into «؛», every «همچنین» into «علاوه بر این», is a new fingerprint. Restructure instead.
6. **Set the register before writing**, and keep one register per document. Don't mix «میشه» and «می‌شود» outside quotations.
7. **No fake errors.** Don't add typos, drop a ZWNJ, break grammar or add slang the writer wouldn't use.
8. **Don't touch quotations, poetry, Quranic verses, titles or proper names.** If a decorative Hafez or Rumi line looks fake or misattributed, flag it `[VERIFY: attribution]` or suggest cutting it. Never "improve" it.
9. **Return only the text**, plus flags (see Output).

## Workflow

1. **Register (guide §3, lines 89–115).** Decide it first, because everything else depends on it:

   | Context | Register |
   |---|---|
   | proposal, invoice, contract, report, formal or company email, website copy | **human formal** (رسمیِ انسانی): full written forms, «شما», direct and alive |
   | administrative letter to an organization or official | **administrative formal** (رسمیِ اداری): formal plus letter conventions |
   | blog, newsletter, product page, LinkedIn | **semi-formal** (نیمه‌رسمی): written forms, warm voice, direct address |
   | Instagram, Telegram, chat reply, friendly email | **written colloquial** (محاوره‌ی نوشتاری): میشه، می‌خوام، «رو» |
   | paper, thesis, academic report | **academic** (علمی): measured and careful; the passive is allowed |

   Decide in this order: an explicit instruction wins, then the document type (not the tone of the request), then the reader and channel. With no clue at all, use human formal. In colloquial text, rewrite literal leftovers of the formal draft («تجربه‌ای … رقم می‌زند» → a plain claim) and drop formal fragments such as «شما عزیزان». **Warmth trap:** "human" means fluent, not casual. Keep conversational idioms out of contracts and formal letters. **Administrative-letter conventions are correct, not tells:** موضوع, «با سلام و احترام؛», جناب آقای / سرکار خانم, «خواهشمند است…», «با تشکر و احترام». Trim only stacked ceremony: «با سلام و احترام؛» followed by «احتراماً،» is two greetings, so keep one; a «پیشاپیش … کمال تشکر را دارم» line before «با تشکر و احترام» thanks twice, so cut it. Body verbs stay است and شود, not می‌باشد or گردد, also inside the request formula («خواهشمند است دستور فرمایید … تمدید شود»).
2. **Strip ط artifacts (Strong).** Remove chat phrases (حتماً!، این هم متن…، امیدوارم مفید باشد، اگر بخواهید می‌توانم…), model self-reference, prompt echo (طبق درخواست شما), source disclaimers, placeholders ([نام شرکت]), tool tokens and `utm_source=chatgpt.com`.
3. **Substance (الف).** Look for claims without evidence, praise without a reason, and sentences that could be pasted into a text on another subject. Make them specific with the facts you have, cut them, or flag them. Judge the whole sentence, not the phrase: «کافه‌ها دیگر فقط جایی برای نوشیدن قهوه نیستند» is still a stock opener after «در دنیای امروز» is gone. Moving a claim about cafes in general onto this café («این کافه از همان ابتدا جایی شد که آدم‌ها برای گفتگو می‌روند») doesn't make it specific; it invents a fact. With no supporting fact, cut it. In letters, cut sentences that tell the official what they already know («تمدید به‌موقع اهمیت دارد»، «هدف ما رعایت ضوابط است»).
4. **Formulas (ج, د).** Look for: نه تنها…بلکه, reflexive triplets, false «از … گرفته تا …» ranges, «که نشان‌دهنده‌ی …» tails, summary endings, uniform paragraphs, needless headings and lists, and the repeated glossary-section template (research N1). «هم … و هم …» or «فقط X نیست؛ Y هم هست» in place of نه تنها…بلکه is the same formula, whatever words fill it; write two plain sentences, or keep only the half the facts support. A last sentence that only re-lists qualities («… ترکیبی از کیفیت، آرامش و اصالت است») is a summary ending: cut it, or end on a concrete fact.
5. **Bureaucratic phrasing and vocabulary (ب, §5 tables).** Restructure the sentence; don't just swap a synonym. می‌باشد becomes است, or attaches to the word before it («محبوب‌ترین سیستم مدیریت محتوا می‌باشد» → «محبوب‌ترین سیستم مدیریت محتواست»). **Never write هست for است in formal text.** Single ب۱ words are Weak, because that table was extrapolated from English lists.
6. **Calques (و).** Look for: در پایان روز, بیایید نگاهی بیندازیم, نقش کلیدی بازی کردن, a redundant یک or شما, and به‌عنوان یک. Replace passive constructions with توسط by an active verb. توسط is native Persian, but heavy and rare in good prose.
7. **Orthography (ز) with the tools.** SKILL.md Step 7 runs `persian_cleanup.py --edit` (ZWNJ, ی/ک, spacing, punctuation), then `fa_lint.py --check --rhythm` (remaining issues and rhythm).

   Use Persian digits in prose and Latin digits only in URLs, codes and versions. Use «» quotation marks and the Persian marks «،» «؛» «؟». Persian style guides prefer «،» «؛», parentheses or a new sentence over the em dash. After a silent ه, keep the source's form (خانه‌ی or خانهٔ), one form for the whole document; `--edit` converts to هٔ only when the text already prefers it. **ZWNJ is required orthography. Never strip a correct one.** Afterwards, re-read any quotation or verse the automated pass touched, and restore it if it changed.
8. **Cultural fit (ح).** Use toman or rial, not dollars, unless the source says otherwise. Use Iranian examples. Friday is the weekend holiday, never Saturday–Sunday. **Don't assume the second weekly holiday (Thursday or Saturday);** it was legally unsettled in 1404–1405, so write `[VERIFY: …]` if the text depends on it. Check decorative verses and proverbs.
9. **Newer-model tells (ی).** Look for chains of short sentences, «اهمیت دارد», «بی‌سروصدا», «قابل اتکا». These were observed in English and not measured on Persian, so weigh them lightly.
10. **Genre pass.** Check the matching example: guide §6 (service page, stakeholder email, administrative letter, Instagram caption, translated blog, résumé, LinkedIn) or research-updates §4 (Telegram post, Digikala product page, student assignment).
11. **Screenshot test.** Would an Iranian reader screenshot this and caption it «کار هوش مصنوعی است»? Read it aloud and change anything you wouldn't say to a colleague.
12. **Verify** (next section).

## Signal strength

| Level | Examples | Action |
|---|---|---|
| **Strong** | ط chat phrases, model self-reference, prompt echo, source disclaimers, placeholders, tool tokens, tracking parameters | Always remove |
| **Medium** | ب۲ bureaucratic verbs, ب۳ filler (لازم به ذکر است), ب۴ stock openers (در دنیای امروز), ب۶ inflated prepositions, ب۱ clusters, ج۲, ج۴, و۱/و۲ calques, em dashes, the glossary template | Fix when 3+ in a paragraph; always fix bureaucratic phrasing outside administrative letters |
| **Weak** | single ب۱ words, formality alone, uniform rhythm, unusual length, a lone calque, a tone-formalizer result, perfect orthography | Context only |

## Verify

SKILL.md Step 7 runs `fa_lint.py --check` (no real orthography errors left) and `check_tells.py` against the original and any confirmed facts.

`check_tells.py` exits 0 on PASS and 1 on FAIL. It fails on:
- any Strong tell;
- a paragraph with 3+ Medium tells;
- fact drift (a number, URL or Latin name missing or new; Persian and Latin digits are treated as equal; `[ADD]` and `[VERIFY]` markers are ignored);
- a «…» quotation or `>` blockquoted verse of 4+ words that is no longer verbatim;
- hidden characters the rewrite added. ZWNJ and RLM are exempt.

It normalizes ZWNJ and ی/ک before matching, and doesn't scan quoted or blockquoted text for tells. Persian names in Persian script are **not** checked automatically, so compare them by eye.

Loop until both tools are clean, up to 3 rounds. Explain anything kept on purpose under Flags. Then check by hand:

- [ ] One register from start to finish, and it fits the document type and reader
- [ ] Hedges and scope kept; «رابطه» didn't become «تأثیر»; no new claims
- [ ] Quotations, verses, titles and proper names unchanged
- [ ] Administrative conventions kept where they belong; no هست for است
- [ ] Currency, calendar, holidays and examples are local; verses checked
- [ ] The guide's §9 checklist (lines 877–895)

## Output

**Rewrite mode:** output the Persian text with nothing before it. If needed, add after it:

```
---
Flags:
- [ADD: …] / [VERIFY: …] items
- Register chosen and why (one line), anything deliberately kept
Check: fa_lint clean · check_tells PASS
```

If you write the text to a file, the file holds only the text: put the Flags block in your reply, never in the file, because the user will paste the file as is. If the user wrote in Persian, write the Flags block in Persian too.

**Audit mode:** don't rewrite. Report the detected register, Strong signs, Medium clusters by paragraph, Weak or context signs, and the top 3 fixes. Say that these are style signs, not evidence of who wrote the text. Use the `check_tells.py` and `fa_lint.py --check` evidence from SKILL.md Step 4, then add the substance and register problems that only reading finds.

## Reference map

`signs-of-ai-writing-fa.md` (Persian). Read the section, not the whole file:

| Lines | Section |
|---|---|
| 17–39 | ۰ rules · 43–73 ۱ workflow · 77–85 ۲ strength |
| 89–115 | ۳ register detection, warmth trap, letter conventions |
| 121–202 | الف content |
| 204–277 | ب vocabulary and bureaucratic phrasing (ب۲ verbs, ب۷ fake tanvin) |
| 279–371 | ج sentence structure |
| 373–404 | د paragraph and document structure |
| 406–444 | هـ tone and voice |
| 446–486 | و calques and translationese |
| 488–526 | ز orthography and punctuation |
| 528–556 | ح cultural fit |
| 558–581 | ط chat and tool artifacts |
| 583–598 | ی newer-model tells |
| 600–685 | ۵ replacement tables (verbs 602, prepositions 634, adjectives 649, phrases 664) |
| 687–839 | ۶ examples: service page 689, email 721, administrative letter 748, Instagram 782, translated blog 801, résumé 815, LinkedIn 827 |
| 841–858 | ۷ over-correction traps · 862–873 ۸ weak signs · 877–895 ۹ checklist |

`research-updates-fa.md`: §1 evidence status, §2 corrections (61.22%, ز۱, ب۲, توسط, ح۲ weekend, ه‌ی/هٔ), §3 new patterns, §4 genre examples, §5 shared English findings.
