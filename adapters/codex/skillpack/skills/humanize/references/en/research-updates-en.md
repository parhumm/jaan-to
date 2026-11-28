# Research updates to the English guide (Nov 2026)

This file holds findings from a later audit of `signs-of-ai-writing-en.md`. It covers four strands: practitioner catalogs, corpus stylometry, detection reliability and genre-specific tells. Where this file and the guide disagree, follow this file. Each section is short, so read only the one you need.

## Contents
1. Corrections to signal strength
2. New patterns
3. New over-correction traps
4. Limits and ethics
5. New genre examples (fiction, PR, abstract, forum reply, product review)
6. Genre notes without a full example
7. Citation fixes

---

## 1. Corrections to signal strength

| Guide item | Change | Why |
|---|---|---|
| F1 em dash | **Weak to Medium, contested.** Never act on dash count alone. | Mainstream 2025–26 commentary treats the em dash as a debunked folk tell. Many careful writers use it, and an instruction removes it. Current models differ: Claude was still above the professional-writer rate in mid-2026, while ChatGPT had dropped. |
| C7 monotone rhythm, low burstiness | **Weak to Medium.** Near zero when no other sign is present. | Detectors flag autistic writers' posts more often (Chambers & Kelley, arXiv:2607.14729). Non-native writers are flagged at a 61.22% false-positive rate (Liang et al. 2023). |
| B1 single words (delve, tapestry, boasts) | **Weak** alone; only clusters count. | A word loses diagnostic value within about a year of going viral. Writers and models adapt, and humans start using the word (Geng & Trotta, arXiv:2502.09606; Yakura et al., arXiv:2409.01754). |
| B1 newer-era rows (GPT-4o, GPT-5, mid-2026) | Unverified author observation, not measured data. | No primary source was found for the mapping from era to word. Treat the table as a snapshot that goes stale, not a fixed reference. |
| B1 Grok-specific words | Unsupported, so don't use them. | Sun et al. give no n-grams for Grok, DeepSeek or Llama. |
| A3 vague attribution, C1 copula avoidance, D1 restating summaries | Add the era caveat: rarer in frontier 2025–26 models, still common in budget or legacy models. | Wikipedia now lists these under "Historical indicators". |
| G2 model self-reference | Keep it **Strong** and add an era note. The form is rare in current chat products. It still shows up in cached or legacy text and in raw API output. | Wikipedia dates the classic form to 2022–23. |
| G6 abrupt cut-off | Weigh it with other signs. | Copy-paste errors and truncation cause it too. |
| B2 Latinate words, C9 wordy phrases | Weak in isolation. | Wikipedia's "Signs of human writing" notes that careful human writers also use complex synonyms, hedges and "in order to". |

**Confirmed as current and accurate, no change:** A2, A4, A5, A7, C2, C3, C6, D5, F5 and G5. As of Oct 2026, Wikipedia names Markdown in the wrong destination (F5) as the most common sign, and A4, A5 and G3 are in its top five. F6 curly vs. straight quotes stays Weak.

## 2. New patterns

**N1. Fake candor: "genuinely", "honestly", "And honestly?" (Medium).** This is a rhetorical bid for authenticity. In the Graphite study, Opus 5 used "is genuinely" 26 times as often as Opus 5.5.
- ❌ "And honestly? This changes everything about how we onboard users."
- ✅ "This changes how we onboard users."
- Fix: delete the word. Keep "honestly" only if the writer is conceding something surprising.

**N2. Bare dramatic declaratives: "This matters." "It matters." (Medium).** A short sentence with almost no subject, used as a dramatic beat. The Graphite study measured it as heavily over-represented in Opus 5.5 output. That is one vendor study of one model family, reported by five outlets.
- ❌ "This matters. It changes how teams plan their week."
- ✅ "Teams can now plan a week ahead instead of a day ahead."
- Fix: fold the claim into the sentence that supports it with a fact.

**N3. Nominalization (Medium).** LLMs turn verbs into noun phrases at 1.5–2 times the human rate (Reinhart et al., PNAS 2025, arXiv:2410.16107).
- ❌ "The implementation of the new policy resulted in a reduction in complaints."
- ✅ "The new policy cut complaints."
- Fix: look for a -tion, -ment, -ance or -sis noun after a weak carrier verb (conduct, perform, achieve, result in, carry out, provide). Restore the verb.

**N4. Prompt echo: "Based on the document you shared…" (Strong if the reader never saw the prompt).** The text refers to the prompt instead of stating the content. Sun et al. found Claude overuses "here", "according to" and "based on" in this way.
- ❌ "Based on the document you shared, here is a summary of the three main points."
- ✅ "The document lists three main points: …"
- It is Weak when it naturally refers to a cited source.

**N5. Model fingerprints (Medium together, Weak alone).** A classifier can tell ChatGPT, Claude, Grok, Gemini and DeepSeek apart with 97.1% accuracy, even after paraphrase or translation (Sun et al., ICML 2025, arXiv:2502.12150).
- **ChatGPT** opens with "Certainly!" or "Below is…", uses heavy bold and headers, and favors "such as" and "overall".
- **Claude** favors "here", "according to" and "based on", and often uses no bold at all.
- **Gemini** favors italics and short, direct openings.
- If you know which assistant wrote the draft, remove that model's own habit, not just the generic word list.

**N6. Invisible characters (Weak as evidence; always strip them).** Watch for U+00A0 no-break space, U+200B zero-width space and U+202F narrow no-break space. Vendor sources call them near-watermarks, but the evidence is thin and the narrow no-break space had mostly vanished by April 2025. Strip them before publishing. Never add them, and don't treat their presence or absence as proof. `check_tells.py` fails a rewrite that adds any.

**Leads with thin sourcing (Weak, so don't flag them):** "load-bearing", "scaffolding" and "broader" as metaphors.

## 3. New over-correction traps

- **Adding agentless passive voice to sound human.** GPT-4o uses agentless passives at about half the human rate (Reinhart et al.), so active voice is not a tell. Don't rewrite into "Mistakes were made."
- **Synonym swapping.** Swapping words keeps 91.4% of a model's fingerprint, while restructuring brings it down to 58.1% (Sun et al.). Rewrite the sentence around a fact; don't swap words.
- **Running the text through a "humanizer" or paraphrasing tool.** These tools change facts or quotations in 35–65% of the documents that contain them (arXiv:2611.00359). This is worse than the typo trap, because the person doing the rewrite often can't see the change.
- **Treating a detector's "AI %" as a pass/fail gate.** Top tools (Pangram, Binoculars) claim under 1% false positives on curated test sets. Accuracy collapses on paraphrased text, short passages and non-native writing, where misclassification can pass 60%. Chasing a lower score on non-native text "fixes" text that was never AI-written.
- **Applying a long ban list mechanically.** Accuracy drops sharply once the list passes about 100–1000 items (arXiv:2509.24090). Banning a contrast construction can also delete a contrast the text actually needed. Use the §4 tables case by case.

## 4. Limits and ethics

- The goal is better writing. Do not use this skill to dodge a disclosure requirement, whether academic, journalistic, legal or contractual. Where AI use must be declared, it must be declared however the prose reads.
- A thorough rewrite will likely remove any watermark (SynthID) or provenance signal (C2PA). Say so when it matters, for example in coursework or a newsroom with a disclosure policy.
- Never insert invisible characters, homoglyphs, deliberate typos or other tricks against detectors. They make the text worse and are deceptive.
- People spot AI text at little better than chance. Heavy LLM users do much better: 92.7% true positives (arXiv:2501.15654). Audit mode reports **signs**, never a verdict on who wrote the text.
- Non-native, neurodivergent and very formal human writers trigger many signs. The non-native bias is measured. The neurodivergent bias rests on one 2026 preprint plus anecdotes. Treat it as real but unmeasured.

## 5. New genre examples

All five keep every fact. They are illustrations written for the audit, not real quotes.

**5.7 Fiction paragraph.** Facts: Mara comes back to her childhood home after her mother's death. A chipped blue mug is in the sink. It is autumn.
- ❌ "Mara stood at the threshold, a wave of emotions washing over her. The house, steeped in nostalgia, seemed to whisper secrets of a life long gone. Her eyes fell upon a chipped blue mug resting in the sink — a silent testament to the countless mornings they had shared. She hadn't realized how much she'd missed this feeling until now, the weight of unspoken grief settling over her like the autumn leaves outside."
- ✅ "Mara stood in the kitchen doorway. The blue mug was still in the sink, chipped on the handle. Outside, the leaves had started to fall."
- Why: it cuts the theme over-explanation and the emotion-naming (A11), and trusts one concrete detail. Fiction tells also include recurring names and stock scenarios, body-language clichés with no variation, and stacked similes.

**5.8 Pull request description.** Facts: fixes a null-pointer crash in `parseConfig()` when the config file is empty. Adds a check and a unit test. No other files touched.
- ❌ "This pull request addresses a critical issue in the configuration parsing logic that could lead to unexpected application crashes. By implementing a robust null-check mechanism, we ensure that the system gracefully handles edge cases, significantly improving overall application stability and reliability. A comprehensive test has been added to validate this fix and prevent future regressions."
- ✅ "Fix crash in parseConfig() when the config file is empty. Added a null check and a test for the empty-file case. Nothing else changed."
- Why: maintainers (curl, Godot) filter out verbose PRs that restate instead of describe. In technical writing the real tell is whether the submitter can explain the change. Name the function, the trigger and the scope.

**5.9 Academic abstract.** Facts: 42 participants. A 10-minute breathing exercise before exams. Cortisol measured from saliva. Self-reported anxiety fell 15% (p<0.05). No effect on exam scores.
- ❌ "This study investigates the multifaceted impact of mindfulness-based interventions on student well-being, exploring the intricate relationship between stress reduction techniques and academic performance. Our findings underscore the significant potential of brief interventions in fostering resilience among student populations, highlighting promising avenues for future research."
- ✅ "Forty-two students did a 10-minute breathing exercise before an exam. Self-reported anxiety fell 15% (p<0.05); exam scores did not change. Cortisol was measured from saliva samples."
- Why: it removes the cluster of reviewer adjectives (multifaceted, intricate, commendable, meticulous) and restores the null result the AI draft dropped. In academic writing, also look for leftover chat artifacts such as "As an AI language model…" and for fabricated references.

**5.10 Forum or Reddit reply.** Facts: the poster asks whether to replace a laptop battery. It's a 2019 MacBook with 72% battery health, already out of warranty. A third-party battery costs $40.
- ❌ "Great question! It's not just about replacing a battery — it's about extending the life of a device you clearly care about. At 72% health, your battery is indeed showing signs of wear, but don't worry, you have options! A third-party replacement is often a cost-effective solution, and since your 2019 MacBook is out of warranty, you have nothing to lose. Hope this helps!"
- ✅ "72% is low enough that you'll notice it. A 2019 model is out of warranty anyway, so a $40 third-party battery has nothing to void."
- Why: it removes the sycophantic opener, the "not X, it's Y" contrast and the "Hope this helps!" sign-off.

**5.11 Product review.** Facts: a $25 kitchen scale, accurate to 1 g. The display is hard to read in direct sunlight. Batteries are included. Used daily for six weeks of baking.
- ❌ "This kitchen scale exceeded my expectations in every way! The build quality is outstanding, and the precision is simply unmatched. I've been using it for all my cooking and baking needs, and it has truly transformed my kitchen experience. Highly recommend to anyone looking to elevate their culinary journey!"
- ✅ "Used this daily for six weeks of baking. It's accurate to the gram, which is what I needed. Only complaint: the display washes out in direct sunlight. Batteries are included, which is nice at $25."
- Why: generic praise that could describe anything is the top fake-review tell. Real reviews have a specific, slightly negative detail. Readers can't reliably tell AI reviews apart, so fix the content and don't guess who wrote it.

## 6. Genre notes without a full example

- **Press releases:** headlines in title case, heavy bold, empty bullets, no contact details. Fix with a dateline, real numbers and a named contact, written as `[ADD: contact]` if it's missing.
- **Customer support replies:** tie the sympathy line to the customer's specific problem and history, not a generic "I understand your frustration".
- **Journalism:** the real incidents are fabricated people and quotes. Verify every quote and person. Prose edits don't fix this.
- **Résumés and cover letters:** recruiters feel confident they can spot AI, but controlled tests put them near chance. The fix is specific achievements, not avoiding certain words.

## 7. Citation fixes

- A2 "2–5x participial clauses": the figure comes from Reinhart et al., PNAS 2025 (arXiv:2410.16107), not The Augmented Educator.
- The em-dash figures in the Graphite study come from a vendor and are unverified.
- The 61.22% false-positive rate for non-native writers comes from Liang et al. 2023.
