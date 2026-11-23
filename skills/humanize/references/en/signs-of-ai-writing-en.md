# Signs of AI Writing: Detection and Humanization Guide (English)

> **What this is:** a reference for an AI model (or a human editor) that rewrites text so it reads as if a careful person wrote it. It lists the patterns that make text read as machine-generated, shows an example of each, and gives the fix.
> **Companion file:** `signs-of-ai-writing-fa.md` (Persian).
> **Researched:** November 2026. Model habits change every few months; section H covers the newest ones.
> **About the examples:** the ✅ rewrites use made-up details to show the shape of a good sentence. In a real rewrite, use only details from the source text or the user (Rule 2).

---

## 0. Rules for the rewriter

Read these before touching any text.

1. **Keep the meaning.** Every fact, number, name, date and claim in the source must survive unless it is pure filler. Don't add new claims.
2. **Never invent specifics.** Most AI text is vague, and the real fix is a concrete detail. If the source or the user gave you that detail, use it. If not, cut the vague claim or leave a marker such as `[ADD: which project, what result]`. A made-up anecdote is worse than a vague sentence.
3. **Fix substance before surface.** Swapping "delve" for "dig into" changes nothing if the paragraph still says nothing. Remove empty claims, check facts, tighten the argument, then fix the wording.
4. **Clusters matter, single words don't.** One "additionally" is fine. Five tells in one paragraph is the problem. Don't strip every listed word on sight.
5. **Don't swap one tell for another.** Replacing every em dash with a semicolon, or every "moreover" with "on top of that", leaves a new fingerprint. Vary the fixes.
6. **Match genre and reader.** A legal memo, a product page and a wedding toast follow different norms. Don't make formal text chatty or chatty text formal.
7. **No fake errors.** Don't add typos, broken grammar, or slang the writer wouldn't use to "look human".
8. **Return only the rewritten text** unless asked for notes. Strip all chat framing.

The goal is better writing, not beating detectors. Wikipedia's editors warn that fixing surface signs while leaving unsupported claims in place "could just make detection harder" without fixing the actual problem.

---

## 1. Workflow

1. **Strip artifacts** (section G): chat phrases, placeholders, tool tokens, model disclaimers. These are near-certain tells and always go.
2. **Audit substance** (section A): mark every sentence that claims something without evidence, praises without saying why, or could be pasted unchanged into a text about a different subject. Cut it, make it specific with facts you have, or flag it.
3. **Break formulas** (sections C and D): rule of three, "not X but Y", "from X to Y", summary endings, uniform paragraphs, needless headings and bullets.
4. **Replace vocabulary** (section B, tables in section 4): plain words for inflated ones. Rewrite the sentence rather than swapping in a synonym.
5. **Fix formatting** (section F) for the destination: email, web page, Word doc, chat, wiki.
6. **Check for newer-model tells** (section H).
7. **Read it aloud.** Change anything you wouldn't say to a colleague.
8. **Run the checklist** in section 8.

---

## 2. Signal strength

| Level | Meaning | Action |
|---|---|---|
| **Strong** | Near-proof of pasted AI output (chat phrases, placeholders, `utm_source=chatgpt.com`, "as an AI language model") | Always remove |
| **Medium** | Typical of AI, most telling in clusters | Fix when several appear together |
| **Weak** | Humans do this often | Fix only if it hurts the writing or sits next to other signs |

---

## 3. Pattern catalog

### A. Content and substance

This is the deepest tell. LLMs "regress to the mean": they replace specific, unusual facts with generic, positive statements that would fit any subject. Wikipedia's example: "inventor of the first train-coupling device" turns into "a revolutionary titan of industry."

#### A1. Inflated significance, symbolism, legacy (Medium)
Linking a small detail to a grand theme.
**Triggers:** stands/serves as a testament/reminder · plays a vital/pivotal/crucial/key role · underscores/highlights the importance of · reflects broader trends · marks a pivotal moment / key turning point · enduring/lasting legacy · indelible mark · deeply rooted · setting the stage for · evolving landscape · focal point · has shaped conversations about
- ❌ The bakery's sourdough stands as a testament to the town's enduring commitment to tradition, marking a pivotal moment in its culinary evolution.
- ✅ The bakery has used the same sourdough starter since 1962.

**Fix:** state the fact. If the significance is real, show it with evidence (a number, a quote, a consequence). If you can't, cut it.

#### A2. Superficial "-ing" analysis (Medium)
A trailing participle clause that adds a vague claim of meaning. Research cited by The Augmented Educator reports that instruction-tuned models use participial clauses at two to five times the human rate.
**Triggers:** …, highlighting / underscoring / emphasizing / showcasing / reflecting / symbolizing / ensuring / fostering / contributing to / enhancing / cultivating / aligning with …
- ❌ The city added 40 km of bike lanes in 2024, highlighting its commitment to sustainability and fostering a vibrant cycling culture.
- ✅ The city added 40 km of bike lanes in 2024. Bike counts on the main bridge rose 18% the next year.

**Fix:** delete the clause, or make it a separate sentence that states a real consequence.

#### A3. Vague attribution and weasel words (Medium)
Claims pinned on unnamed authorities, or one source inflated into "many".
**Triggers:** experts argue · observers have noted · industry reports suggest · some critics argue · many believe · studies show (no study named) · has been described as · widely regarded as · several sources (when one is cited)
- ❌ Experts argue that remote work has fundamentally reshaped corporate culture.
- ✅ Remote work changed our team more than any tool did. We dropped the daily stand-up within a month.

**Fix:** name the source, own the claim as the writer's view, or cut it.

#### A4. Vague connection (Medium; common in 2025–2026 models)
"Associated with", "connected to", "in connection with" in place of the actual relationship.
- ❌ She is closely associated with the city's jazz scene.
- ✅ She ran the Blue Door jazz club from 1988 to 2004.

**Fix:** say what the person or thing *did*.

#### A5. Notability and media-coverage padding (Medium; 2025–2026 models)
Listing *where* something was covered instead of *what was said*. Boasting about online presence. Formulaic "records identify X as".
**Triggers:** featured in · profiled by · independent coverage · national/regional media outlets · trade publications · maintains an active/strong digital presence · social media presence · is listed in · records/databases identify … as
- ❌ The startup has been featured in several national and tech media outlets and maintains a strong digital presence.
- ✅ TechWeekly called the app "the first budgeting tool I've kept using past a month."

**Fix:** quote or summarize what the coverage said and name the outlet. Drop social-media boasts.

#### A6. Generic claims (the "abstraction trap") (Medium)
Abstract nouns doing the work concrete ones should do.
**Test:** could this sentence appear unchanged in a text about a different company, city or person? If yes, it says nothing.
**Triggers:** comprehensive · foundational · holistic · nuanced · landscape · framework · ecosystem · solutions · insights · journey · experience
- ❌ Our comprehensive approach delivers innovative solutions across the evolving digital landscape.
- ✅ We rebuild checkout pages for small online shops. Most clients see fewer abandoned carts within a month.

#### A7. Promotional, brochure tone (Medium; rarer in newer models unless prompted)
**Triggers:** nestled · in the heart of · boasts · breathtaking · stunning natural beauty · rich cultural heritage · renowned · groundbreaking · must-visit · diverse array · continues to captivate · commitment to excellence · world-class
- ❌ Nestled in the heart of the valley, the town boasts breathtaking views and a rich cultural heritage.
- ✅ The town sits on the valley floor, 20 minutes from the nearest ski lift. Its church dates from 1420.

#### A8. Formulaic "challenges and future" endings (Medium)
"Despite its X, Y faces challenges…" followed by vague optimism.
**Triggers:** Despite its …, it faces several challenges · Despite these challenges · Future Outlook · Challenges and Legacy · remains to be seen · poised for growth · a bright future · continues to inspire
- ❌ Despite its success, the festival faces several challenges, including funding and rising costs. Nevertheless, its future remains bright as it continues to inspire new generations.
- ✅ Ticket sales covered 60% of the 2025 budget. The organizers plan to apply for a city grant.

**Fix:** name the specific problem and what is being done about it, or end earlier. Mentioning challenges is fine; the formula is the tell.

#### A9. Over-hedging and the equivocation seesaw (Medium)
Every claim softened, every view balanced, even when the writer has a position.
**Triggers:** generally speaking · to some extent · it could be argued · may potentially · in many cases · from a broader perspective · while X has many benefits, it is important to note that Y presents challenges · on the other hand · ultimately, it depends
- ❌ While remote work offers many benefits, it is important to note that it may also present certain challenges, and the right choice ultimately depends on individual circumstances.
- ✅ Remote work suits our senior engineers and hurts our new hires. We'll keep it for the first group and bring juniors in three days a week.

**Fix:** commit to the view. Keep a hedge only where the uncertainty is real, and say what it's about.

#### A10. Fake precision, factoids, hallucinated sources (Strong when shown false)
Oddly exact numbers with no source. Citations, DOIs, ISBNs or URLs that don't exist or lead somewhere unrelated. Book citations with no page number.
- ❌ A 2023 survey found that 73.4% of Gen Z prefer analog watches.

**Fix:** verify every number and citation. If you can't confirm it, remove it or mark `[VERIFY]`. Never "fix" a bad source by inventing a different one.

#### A11. Explaining the subtext; sensing without sensing (Medium; narrative and fiction)
The text states what should be implied, describes sensations from a textbook rather than experience, or gives objects memories.
- ❌ He looked at the door, feeling a strong desire to leave the room.
- ✅ He looked at the door.
- ❌ He picked up the pan, a pan that still remembered the last thing I burned.
- ✅ He picked up the pan, still hot from the eggs he'd made her that morning.

(Pan examples from The Algorithmic Bridge.)
**Fix:** trust the reader. Use one concrete detail a person would actually notice.

#### A12. Didactic disclaimers (Medium)
Unprompted reminders and safety notes.
**Triggers:** It's important to note/remember/consider that · It's worth noting · Keep in mind · results may vary · always consult a professional
- ❌ It's important to note that every garden is different, and results may vary.
- ✅ Clay soil drains slowly, so water it half as often.

**Fix:** delete, or replace with the specific fact the disclaimer was gesturing at.

---

### B. Vocabulary

#### B1. AI vocabulary clusters (Medium in clusters; Weak alone)
Density is the signal. Three or more of these in one paragraph reads as AI. One alone means little. Don't replace them with their nearest synonym (that's how "delve" became "dig into"); rewrite the sentence around a fact.

| Period / source | Overused words |
|---|---|
| 2023 to mid-2024 (GPT-4 era) | additionally, boasts, bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key, landscape, meticulous(ly), pivotal, underscore, tapestry, testament, valuable, vibrant |
| Mid-2024 to mid-2025 (GPT-4o era) | align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant |
| Mid-2025 to mid-2026 (GPT-5 era) | emphasizing, enhance, highlighting, showcasing, plus notability words (featured in, independent coverage, media outlets) |
| Mid-2026 onward | challenge, clearer, dependable, echoed, foster, leverage, matters, multifaceted, practical, prioritize, quietly, steady, universally |
| Grok (any period) | causal, empirical, correlate, underscore |
| General lists (multiple sources) | realm, nuanced, multifaceted, notably, seamless(ly), shed light on, streamline, underpin, harness, illuminate, facilitate, bolster, beacon, palpable, navigate, embark, ever-evolving, robust, transformative, invaluable, commendable, exemplary, adept, utmost, synergistic, thought-provoking |
| Transitions (from the Medium list) | accordingly, additionally, arguably, certainly, consequently, hence, indeed, moreover, nevertheless, nonetheless, notwithstanding, thus, undoubtedly |

Context matters: "underscore" in a music or typography text, "landscape" in a gardening text, and "key" on a keyboard are fine.

#### B2. Inflated and Latinate words (Weak to Medium)
AI favors long words that sound authoritative. People mix registers.
- ❌ We will utilize the new system to facilitate collaboration and demonstrate progress.
- ✅ We'll use the new system to work together and show progress.

See table 4.1.

#### B3. Corporate buzzwords and résumé filler (Medium)
**Triggers:** leverage · synergy · actionable insights · data-driven decisions · results-driven · track record · solid foundation · drive efficiency · innovative solutions · cross-functional · best-in-class · value-add · holistic · scalable · empower · unlock · elevate · stakeholders
- ❌ Results-driven analyst leveraging complex datasets to deliver actionable insights and drive data-driven decisions.
- ✅ Data analyst, four years at Northwind. Built the churn model that flagged 1,200 at-risk accounts in 2025; the retention team kept 400 of them.

#### B4. Empty adverbs and intensifiers (Medium)
**Triggers:** effectively · efficiently · successfully · seamlessly · consistently · flawlessly · strategically · meticulously · enthusiastically · significantly · truly · deeply · incredibly · undoubtedly · arguably
- ❌ She consistently and flawlessly executed events, efficiently managing logistics and enthusiastically collaborating with vendors.
- ✅ She ran 14 events for us last year, including a 600-person conference where the venue cancelled two weeks out. She found a new one in four days.

**Fix:** replace the adverb with the evidence that would justify it. No evidence, no adverb.

#### B5. Clichés and stock openers (Medium)
**Triggers:** In today's fast-paced world · In today's digital age · In the ever-evolving landscape of · As the world continues to evolve · In the dynamic world of · Have you ever wondered…? · Imagine a world where · Let's dive in · Buckle up · At the end of the day · In a nutshell · game-changer · cutting-edge · think outside the box · embark on a journey · navigate the complexities · unlock the power/potential of · take it to the next level · the key to success · No fluff
- ❌ In today's fast-paced digital landscape, businesses must navigate the complexities of social media to unlock their full potential.
- ✅ Most small shops post on Instagram three times a week and sell nothing from it. The ones that do sell use stories, not posts.

**Fix:** delete the opener and start with the first sentence that says something.

#### B6. Sanitized vocabulary (the "harmless filter") (Weak)
Training strips out sharp, judgmental or odd words, so everything is "crucial", "vital", "dynamic". People say "sloppy", "grubby", "a mess", "brilliant".
**Fix:** if the writer's view is strong, say it plainly in their register.

---

### C. Sentence-level structure

#### C1. Avoiding "is" and "has" (copula avoidance) (Medium)
**Triggers:** serves as · stands as · functions as · operates as · represents · marks · boasts · features · offers · maintains
- ❌ The building serves as the society's headquarters and boasts a 200-seat auditorium.
- ✅ The building is the society's headquarters. It has a 200-seat auditorium.

#### C2. Negative parallelism (Medium)
Correcting a belief the reader never held.
**Forms:** Not only X but also Y · It's not just X, it's Y · It's not X, it's Y · No X. No Y. Just Z. · What matters is X, not Y · Y rather than X (very common in 2026 models)
- ❌ It's not just a tool, it's a revolution in how teams collaborate.
- ✅ The tool replaced our weekly status meeting.
- ❌ No fluff. No jargon. Just results.
- ✅ (Cut it and show the results.)

**Fix:** state the positive claim. Keep a contrast only when readers really do hold the wrong belief.

#### C3. Rule of three (Medium)
Reflexive triplets of adjectives, nouns or clauses, often with a weak third item.
- ❌ The course is engaging, informative, and transformative.
- ✅ The course is short and practical. You ship one working app by week three.

**Fix:** keep the one or two items that carry weight. Use one, two or four items as the content demands. Don't turn every triple into a pair (that becomes the new pattern).

#### C4. False ranges (Medium)
"From X to Y" where X and Y aren't ends of one scale.
- ❌ From small startups to global enterprises, from marketing to finance, our platform empowers everyone.
- ✅ Our customers range from five-person agencies to banks with 40,000 staff.

**Test:** is there a meaningful middle between X and Y on one scale? If not, list the items or cut. Idioms like "from head to toe" are fine.

#### C5. Transition crutches (Medium in clusters)
Sentence-initial Moreover, Furthermore, Additionally, In addition, Consequently, Notably, Importantly, Indeed, Thus, Hence, Ultimately, Overall, often four or five paragraphs in a row.
- ❌ Additionally, the app supports offline mode. Furthermore, it syncs across devices. Moreover, it is free.
- ✅ The app works offline, syncs across devices, and costs nothing.

**Fix:** delete about half and let the logic connect the sentences. Where a link is needed, "and", "but", "so", "also", "still" usually do it.

#### C6. Elegant variation (synonym cycling) (Weak to Medium; older models)
Swapping in synonyms to avoid repeating a name: "the protagonist", "the young wizard", "the bespectacled hero".
**Fix:** repeat the name or use a pronoun.

#### C7. Monotone rhythm (Medium)
Every sentence 12–20 words and built the same way (subject, verb, object, participle). Low "burstiness". Mid-2026 models also produce runs of short, even 8–20-word sentences with lots of periods.
**Fix:** vary length on purpose. A four-word sentence. Then a longer one that carries a qualification, an example and a turn, the way people talk when they explain something they know well. Vary openings so not every sentence starts with the subject.

#### C8. Forced punchiness and fake suspense (Medium)
**Triggers:** Here's the thing: · But here's the truth: · The result? · The kicker? · Hot take: · And honestly? · Let that sink in. · Here's why that matters. · Here's the deal. · That's the real unlock. · Spoiler: · Plot twist:
- ❌ We tested three onboarding flows. The result? A 40% drop in churn. Let that sink in.
- ✅ We tested three onboarding flows. The shortest one cut churn by 40%.

**Fix:** usually a plain "But", or just say it.

#### C9. Wordy prepositional phrases (Weak to Medium)
| Wordy | Plain |
|---|---|
| in order to | to |
| due to the fact that | because |
| in the context of | in, for |
| with regard to / in terms of | about, for |
| taking into account | given, considering |
| at this point in time | now |
| a wide range of / a myriad of / a plethora of | many |
| serves to [verb] | [verb] |
| is able to | can |
| the fact that | (rewrite) |

#### C10. Rhetorical-question openers (Weak to Medium)
"Have you ever wondered why…?" "What makes a great leader?"
**Fix:** start with the answer.

---

### D. Paragraph and document structure

#### D1. Restating summaries (Medium)
**Triggers:** In conclusion · In summary · Overall · Ultimately · To sum up · a final sentence or section that repeats what was just said
**Fix:** cut it. End on the last new piece of information, a decision, or a next step.

#### D2. Too-perfect symmetry (Medium)
Paragraphs of nearly equal length, each opening with a topic sentence and closing with a neat moral.
**Fix:** let paragraph length follow content. A one-sentence paragraph is fine. Drop the closing moral.

#### D3. The treadmill (no thesis) (Medium)
The text circles the same idea and reveals little. Ask "where is this going?" after each paragraph.
**Fix:** write the main point in one sentence and put it near the top. Cut paragraphs that don't move it forward.

#### D4. Padding (Medium)
2,500 words for a 500-word point: background nobody asked for, restated context, definitions of common words.
**Fix:** cut 30–50% on the first pass. Keep facts, examples and decisions.

#### D5. Over-formatting (Medium)
Headings on a 300-word answer. Bullets for content that is really an argument. Inline-header lists (`- **Speed:** It's fast.`). "Key Takeaways" boxes. "X and Y" headings ("Challenges and Opportunities", "Awards and Recognition").
- ❌
  ```
  **Benefits:**
  - **Speed:** The tool is fast.
  - **Cost:** The tool is affordable.
  - **Ease of use:** The tool is easy to use.
  ```
- ✅ It's fast, it costs €8 a month, and my non-technical co-founder set it up alone.

**Fix:** prose for reasoning; lists only for steps or truly parallel items. Keep headings in long reference documents where readers need to navigate.

---

### E. Tone and voice

#### E1. No personal footprint, flat emotion (Medium)
No opinions, memories, places, people or humor. Grief and joy described in abstractions.
- ❌ Losing a parent is an incredibly difficult experience that affects us deeply.
- ✅ For a month after Dad died I kept buying his brand of coffee.

**Fix:** use details the writer gave you. If there are none, flag: `[ADD: a moment you remember]`. Never invent a memory.

#### E2. Register mismatch (Medium)
Formal in a Slack message, chummy in a legal notice, "Inquiry regarding…" as a LinkedIn subject line.
**Fix:** write the way this sender would write to this reader.

#### E3. Sycophancy (Strong in replies and comments)
**Triggers:** Great question! · You're absolutely right! · What a fantastic idea! · I completely understand your frustration.
**Fix:** delete. Answer the question.

#### E4. Template letters and emails (Medium)
**Triggers:** I hope this email finds you well · Dear Stakeholders · I am writing to express my keen interest · I am confident that my skills align with · Thank you for your time and consideration · Please don't hesitate to reach out · I look forward to hearing from you · Warm regards / Best regards on a casual note
**Fix:** use real names, open with the reason for writing, and sign off the way the writer normally does.

---

### F. Formatting and punctuation

#### F1. Em dashes (Medium; check the era)
Many models use em dashes (often with spaces around them) where people use commas, parentheses or colons. A July 2026 study found Claude still uses more em dashes than professional writers. Since late 2025 many other models suppress em dashes and overuse commas and periods instead, which is its own tell (see H).
- ❌ The update—released quietly last week—changes everything.
- ✅ The update, released last week, changes how billing works.

**Fix:** keep a dash only where it's the best mark. Replace the rest with a comma, parentheses, colon, period, or a rewrite. Don't swap them all for semicolons.

#### F2. Excessive bold (Medium)
Bold phrases scattered through prose like a slide deck.
**Fix:** no bold in running prose, or at most one phrase per section.

#### F3. Title Case Headings (Weak to Medium)
"How To Improve Your Morning Routine" where the house style is sentence case.
**Fix:** follow the house style; default to sentence case.

#### F4. Emoji as bullets or headings (Medium)
🚀 ✅ 💡 🔥 on headings or list items in professional text.
**Fix:** remove unless the writer uses emoji this way themselves.

#### F5. Markdown in the wrong place (Strong when the destination isn't Markdown)
`**bold**`, `## headings`, `---` dividers or `[text](url)` pasted into email, Word, a CMS field or wiki markup.
**Fix:** convert to the destination's format.

#### F6. Mixed curly and straight quotes (Weak)
“ ” and " " in the same text suggests pasting from different sources. Word processors create curly quotes too, so this proves little.
**Fix:** make them consistent.

---

### G. Chat and tool artifacts (always remove)

#### G1. Chatbot conversation left in (Strong)
**Triggers:** Certainly! · Of course! · Sure, here's… · Here is a revised version… · I hope this helps! · Let me know if you'd like… · Would you like me to…? · Is there anything else…? · Feel free to adjust… · more detailed breakdown
**Fix:** delete everything that isn't the content itself.

#### G2. Model self-reference and knowledge cutoff (Strong)
**Triggers:** As an AI language model · As a large language model · As of my last knowledge update · Up to my last training update · I don't have access to real-time data · I can't browse the internet · I'm sorry, but I can't…
**Fix:** delete. If the information gap is real, ask the writer or mark `[VERIFY: current figure]`.

#### G3. Source-availability disclaimers (Strong; very common in 2024–2026 models)
**Triggers:** While specific details are limited/scarce · not widely documented / not publicly available · based on available information · in the provided search results · maintains a low profile · X should be treated as Y rather than Z · this does not by itself establish · should not be confused with
- ❌ While specific details about the company's founding are limited, it is believed to have been established in the early 2000s.
- ✅ The company was founded in 2003. *(if known; otherwise cut the sentence)*

#### G4. Placeholders and fill-in templates (Strong)
**Triggers:** [Your Name] · [Company] · [insert statistic] · (Add link here) · Official Website: (If available) · 2025-XX-XX · INSERT_SOURCE_URL · example.com/source1
**Fix:** fill with real data from the user or flag it. Never ship a placeholder.

#### G5. Tool tokens and tracking parameters (Strong)
**Triggers:** `contentReference[oaicite:0]` · `turn0search0` / `citeturn0news12` · `↩` footnote returns · `?utm_source=chatgpt.com` · `utm_source=openai` · `utm_source=copilot.com` · `referrer=grok.com`
**Fix:** remove tokens; strip tracking parameters from URLs and check each link works. (A tracking parameter shows a chatbot found the source, not that it wrote the prose.)

#### G6. Abrupt cut-off (Medium)
Text stops mid-sentence, or a list ends on an odd item.
**Fix:** finish the thought or trim back to the last complete one.

---

### H. Newer-model tells (mid-2026 onward)

Newer models were tuned against the classic tells, so the fingerprint moved. Watch for:

- **No em dashes at all**, with heavy comma and period use instead.
- **Short, evenly sized sentences** (roughly 8–20 words), one idea each, in a steady beat.
- **Vocabulary:** challenge, clearer, dependable, echoed, foster, leverage, matters, multifaceted, practical, prioritize, quietly, steady, universally.
- **"Quietly" as drama:** "quietly reshaping", "quietly became the backbone of".
- **"Y rather than X"** contrasts.
- **Disclaimers:** "should be treated as X rather than Y", "does not by itself establish", "should not be confused with".
- **Source framing:** "featured in", "independent coverage", "records identify X as".

Example:
- ❌ The new intake process matters. It is clearer. It is more dependable. Requests are tracked in one place rather than lost in inboxes. Response times have improved steadily. This change quietly reshaped how we work.
- ✅ In March we replaced email requests with a ticket form. Requests now get an answer in about a day instead of four, and the two people who sorted the inbox full-time are back on project work.

---

## 4. Replacement tables

Use these as prompts to rewrite, not as find-and-replace. Often the best fix is deleting the word and stating the fact.

### 4.1 Words

| AI word | Plainer option (or rewrite) |
|---|---|
| utilize | use |
| facilitate | help, make possible |
| demonstrate | show |
| leverage | use |
| delve into | look at, examine |
| embark on | start |
| underscore / highlight / showcase | show (or state the fact) |
| garner | get, win |
| bolster | support, strengthen |
| foster | build, encourage |
| enhance / augment | improve, add to |
| align with | fit, match |
| boasts | has |
| serves as / stands as | is |
| navigate | handle, deal with |
| landscape | field, market (or name it) |
| realm | area, field |
| tapestry | mix (or name the parts) |
| robust | strong, reliable (or say how) |
| seamless | smooth (or say what doesn't break) |
| meticulous | careful |
| pivotal / crucial / vital | important (or say why) |
| vibrant | lively, busy (or describe it) |
| intricate | complex, detailed |
| multifaceted | (name the facets) |
| comprehensive | full, complete (or cut) |
| innovative / cutting-edge | new (or say what's new) |
| transformative | (say what changed) |
| invaluable | useful (or show the value) |
| commence | start |
| endeavor | try, effort |
| optimal | best |
| prior to | before |
| numerous | many |

### 4.2 Phrases

| AI phrase | Fix |
|---|---|
| It's important to note that… | delete |
| It's worth noting that… | delete |
| plays a pivotal role in | (say what it does) |
| is a testament to | shows |
| in today's fast-paced world | delete |
| at the end of the day | delete |
| a wide range of | many (or list them) |
| actionable insights | (name the finding) |
| data-driven decisions | decisions based on [what data] |
| proven track record | (give the record) |
| drive efficiency | (say what got faster or cheaper, by how much) |
| I hope this email finds you well | delete; open with the reason |
| Please don't hesitate to reach out | Questions? Reply here. (or delete) |
| In conclusion, … | delete; end on new information |
| Let's dive in! | delete |
| Not only X, but also Y | X and Y |
| From X to Y (false range) | list the items |
| Despite these challenges, … | (state the plan or stop) |

---

## 5. Full before/after examples

Each example lists the facts the rewriter had. The rewrite uses only those facts.

### 5.1 Email to stakeholders

**Facts:** Q3 campaign, three ad variants. Short variant (B): 2.4% click-through vs 1.1% average. Cost per signup fell from $14 to $9. Proposal: move 60% of Q4 budget to the short format. Decision at Thursday's meeting. Full numbers in an attached sheet. Recipients: Maya and Tom.

❌ **AI draft**
> Subject: Insights from Our Q3 Marketing Campaign Analysis
>
> Dear Stakeholders,
>
> I hope this email finds you well. I am pleased to share the results of our comprehensive analysis of the Q3 marketing campaign. Our findings underscore the importance of concise and focused messaging, highlighting key opportunities for optimizing future initiatives.
>
> Notably, the shorter ad variant consistently outperformed other formats, demonstrating significantly higher engagement. Additionally, we observed a substantial improvement in cost efficiency. These insights present valuable opportunities to strategically realign our budget.
>
> In conclusion, I look forward to collaborating with you to leverage these learnings effectively in our future marketing endeavors. Please don't hesitate to reach out if you would like to delve deeper into the implications of this analysis.
>
> Best regards,

✅ **Rewrite**
> Subject: Q3 ads: the short version won, proposing a budget shift
>
> Hi Maya, Tom,
>
> The short ad (variant B) beat the other two in Q3: 2.4% click-through against a 1.1% average, and cost per signup fell from $14 to $9.
>
> I'd like to move 60% of the Q4 budget to the short format. Can we decide at Thursday's meeting? Full numbers are in the attached sheet.

**What changed:** real names, the result in the first line, numbers instead of "significantly", one clear ask, no closing boilerplate.

### 5.2 Cover letter paragraph

**Facts:** applying for Data Analyst at Ticketline. Two years at Northwind Retail. Built the weekly sales dashboard (Looker) used by 40 store managers for staffing. SQL and Python. Automation cut report prep from six hours to 30 minutes.

❌ **AI draft**
> I am writing to express my keen interest in the Data Analyst position at Ticketline. With two years of experience leveraging complex datasets to extract meaningful insights, I am confident in my ability to contribute effectively to your dynamic team and drive data-driven decisions. My robust skill set in SQL and Python, coupled with my passion for data storytelling, aligns seamlessly with your mission.

✅ **Rewrite**
> I'd like to apply for the Data Analyst role at Ticketline. For the past two years at Northwind Retail I've run the weekly sales dashboard that 40 store managers use to plan staffing. I wrote the SQL and Python behind it, which cut report prep from six hours to thirty minutes.

### 5.3 Blog intro

**Facts:** post about meal prep for shift workers. Writer is a night-shift nurse. Cooks three base recipes every Sunday. Eats on the 3 a.m. break. Used to rely on the vending machine.

❌ **AI draft**
> In today's fast-paced world, finding time to eat healthy can feel like an uphill battle. Whether you're a busy professional, a student, or a shift worker, meal prep can be a game-changer. In this comprehensive guide, we'll delve into the art of meal prep, exploring tips, tricks, and strategies to help you unlock a healthier lifestyle. Let's dive in!

✅ **Rewrite**
> I work nights as a nurse, and for years dinner was whatever the vending machine had at 3 a.m. Now I cook three base recipes every Sunday and mix them through the week. Here's the system, including what I actually eat on that 3 a.m. break.

### 5.4 Encyclopedic paragraph

**Facts:** Valdora, population 4,200 (2021 census), on the Sella River. Wool mill operated 1871–1968; museum since 1994. Festival every August.

❌ **AI draft**
> Nestled in the heart of the picturesque Sella Valley, Valdora is a vibrant town that boasts a rich cultural heritage. The town's historic wool mill stands as a testament to its enduring industrial legacy, playing a pivotal role in shaping the region's economic landscape. Today, Valdora continues to captivate visitors with its annual festival, showcasing the community's deep-rooted traditions and commitment to preserving its unique identity.

✅ **Rewrite**
> Valdora is a town of 4,200 people (2021 census) on the Sella River. Its wool mill ran from 1871 to 1968 and has been a museum since 1994. The town holds a festival every August.

**What changed:** the rewrite is shorter because the draft's extra length was all claims with no facts behind them.

### 5.5 LinkedIn message

**Facts:** writing to Dr. Lena Park, Health Analytics unit, Riverside University. Sender read her paper on ER wait times; its finding that Monday triage queues cause most weekly delay matched the sender's hospital data. Asking for a 15-minute call about the open analyst role.

❌ **AI draft**
> Subject: Inquiry About Data Analyst Position
>
> Dear Dr. Park, I hope this message finds you well! I am reaching out to express my keen interest in the exciting work being done at your institution. With a strong background in data analysis and a passion for deriving insights from data, I would love the opportunity to contribute to a dynamic team like yours. Would you be open to connecting?
>
> Warm regards

✅ **Rewrite**
> Hi Dr. Park, I read your paper on ER wait times. The finding that Monday triage queues cause most of the weekly delay matched what I've seen in my own hospital's data. I noticed the analyst opening in Health Analytics. Could we talk for 15 minutes next week?

### 5.6 Résumé summary

**Facts:** four years as a data analyst at a university. Tools: SQL, Tableau, Python. Built enrollment forecast used in budget planning (within 2% of actual for three years). Trains staff on Tableau.

❌ **AI draft**
> Results-driven data analyst with a solid foundation in leveraging data to drive efficiency and deliver actionable insights within the University ecosystem. Proven track record of developing innovative solutions to complex challenges. Strong collaborator adept at cross-functional communication.

✅ **Rewrite**
> Data analyst, four years in university planning. Built the enrollment forecast used for budget planning, within 2% of actual three years running. SQL, Tableau, Python. Run the Tableau training for department staff.

---

## 6. Over-correction traps

| Trap | Why it fails | Do instead |
|---|---|---|
| Swapping each flagged word for a synonym ("tapestry" → "mosaic") | Same empty sentence, new tell | Rewrite the sentence around a fact |
| Replacing every em dash with a semicolon or ellipsis | New uniform pattern; semicolons are rare in casual writing | Mix commas, periods, parentheses; keep one dash if it's right |
| Deleting every transition | Choppy text, lost logic | Keep links that carry logic ("but", "so", "because") |
| Making every sentence short and punchy | That's the mid-2026 model style | Vary length |
| Adding invented anecdotes, names, numbers | Fabrication, worse than vagueness | Use supplied facts or flag `[ADD: …]` |
| Forced casualness ("Honestly?", "Let's be real", slang) in formal text | Register mismatch and forced sass | Match the genre |
| Adding typos or lowercasing to "look human" | Worse writing, no real gain | Don't |
| Turning every triple into a pair | New pattern | Let the content decide the count |
| Stripping all structure from a manual or spec | Hurts navigation | Keep headings that help readers find things |
| Cutting every hedge in medical, legal, financial or safety text | Removes real uncertainty | Keep precise hedges that say what is uncertain |

---

## 7. Weak or unreliable signs (don't "fix" these for their own sake)

- Perfect grammar and spelling.
- Formal or academic prose in general. Only specific words are overrepresented, not formality itself.
- A single "delve", "moreover" or "crucial".
- Transition words in isolation.
- The Oxford comma or American spelling (follow the house style).
- Curly quotes (word processors add them).
- Mixed casual and formal register. It is common among technical writers, young writers, neurodivergent writers, non-native speakers and texts with several authors.
- Non-native English patterns, which are often mistaken for AI.
- AI-detector scores. Tools such as GPTZero have real error rates and are thrown off by paraphrasing. Studies cited by Wikipedia found most people spot AI text barely better than chance; only heavy LLM users do much better.
- Text written before 30 November 2022 (ChatGPT's public launch) is not ChatGPT output, whatever it looks like.

---

## 8. Final checklist

- [ ] No chat framing, placeholders, tool tokens or tracking parameters
- [ ] Every claim is specific, sourced, or cut; nothing invented; `[ADD]`/`[VERIFY]` flags left where details are missing
- [ ] No sentence could be pasted unchanged into a text about a different subject
- [ ] "Is" and "has" used where they fit (no "serves as", "boasts")
- [ ] No reflexive "not X but Y", triplets, false "from X to Y" ranges, or "-ing" significance tails
- [ ] At most one sentence-initial formal transition per paragraph
- [ ] Sentence lengths vary; paragraph lengths follow the content
- [ ] No restating conclusion; the text ends on new information, a decision or a next step
- [ ] Formatting fits the destination: no stray Markdown, bold, emoji or title case
- [ ] Em dashes rare, and no single punctuation mark used as a blanket substitute
- [ ] Register fits the reader and genre; greeting and sign-off sound like the sender
- [ ] Read aloud: nothing you wouldn't say to a colleague

---

## 9. Ready-to-use prompt

```
You are an editor. Rewrite the text below so it reads as if a careful person
wrote it for [AUDIENCE] in [GENRE: email / blog post / report / cover letter / ...].

Follow signs-of-ai-writing-en.md:
1. Remove all chat artifacts, placeholders and disclaimers (section G).
2. Keep every fact. Do not invent names, numbers, quotes, anecdotes or sources.
   Where a vague claim needs a detail you don't have, cut it or insert [ADD: ...].
3. Fix the patterns in sections A–F and H, starting with clusters.
4. Avoid the over-correction traps in section 6.
5. Output only the rewritten text. After it, list any [ADD]/[VERIFY] flags.

Facts I can confirm: [paste]
Text: [paste]
```

---

## 10. Sources

- Wikipedia, "Signs of AI writing" (WikiProject AI Cleanup), version of 22 Nov 2026: https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing
- softaworks/agent-toolkit, `signs-of-ai-writing.md`: https://github.com/softaworks/agent-toolkit/blob/main/skills/writing-clearly-and-concisely/signs-of-ai-writing.md
- Michael G. Wagner, "The Ten Telltale Signs of AI-Generated Text", The Augmented Educator (first five signs public): https://www.theaugmentededucator.com/p/the-ten-telltale-signs-of-ai-generated
- Thomas Cox, "How to spot when writing is AI: The 6 elements of robot style", Hunting the Muse: https://huntingthemuse.net/library/how-to-tell-if-writing-is-ai
- ETBI Digital Library, "Signs of AI Writing": https://library.etbi.ie/cs/sources2/aisigns
- Alberto Romero, "10 Signs of AI Writing That 99% of People Miss", The Algorithmic Bridge: https://www.thealgorithmicbridge.com/p/10-signs-of-ai-writing-that-99-of
- Bert Maxwell, "Top Signs Your Writing Was Generated by AI (and How to Fix It)", Wandering Educators: https://www.wanderingeducators.com/best/stories/top-signs-writing-generated-by-ai-how-to-fix-it
- Medium article on words and phrases overused by ChatGPT, with recommendation-letter, cover-letter, LinkedIn, email and résumé examples (text supplied by the user): https://medium.com/@soibifaa98/the-only-5-signs-of-ai-writing-you-need-to-remove-in-your-text-now-8cb0d7ac00dd
- Guo et al., "Do Large Language Models Have an English Accent?", ACL 2025: https://arxiv.org/abs/2410.15956
