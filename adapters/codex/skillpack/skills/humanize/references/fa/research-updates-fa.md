# Research updates to the Farsi guide (Nov 2026)

This file holds findings from a later audit of `signs-of-ai-writing-fa.md`. It covers three strands: Persian practitioner sources and genres, academic evidence, and orthography with cultural facts. Where this file and the guide disagree, follow this file. No rule in the guide was found to be factually wrong. The changes are about how sure each claim is, and they fill some gaps.

## Contents
1. Evidence status: what is measured and what is editing guidance
2. Corrections and caveats by section
3. New patterns
4. New genre examples (Telegram, Digikala product page, student assignment)
5. Shared findings from the English audit that apply to Persian

---

## 1. Evidence status

- **ب۱ AI vocabulary table:** no Persian source confirms these words on their own. The list was built by translating English "AI word" lists, plus one confirmed Persian template sentence. **Only clusters count;** a single word is Weak.
- **و۱/و۲ calque and translationese lists:** linguistically sound, textbook English→Persian calques. They have not been measured on a corpus of human or LLM Persian. Keep the guide's caveat: a calque alone doesn't prove machine origin.
- **Guo et al. (ACL 2025, arXiv:2410.15956) and "Lost in Literalism" (arXiv:2503.04369):** neither tested Persian. Guo et al. tested French and Chinese; the other paper tested En-Zh, De-En, En-Is, En-Cs, En-De and En-Ru. The English-accent effect in Persian is an **extrapolation**: plausible, not measured.
- **arXiv:2408.10724 (Persian AI news):** the only source that measured Persian AI text. Detectors separated it mostly by its unusual article **length**, a dataset artifact, not by style markers. Length is a Weak signal.
- **ی "newer-model tells":** from English and Wikipedia observation, not measured on Persian, and the guide already says so. Don't strengthen the claim.
- **Formality alone is Weak.** Persian has a wide gap between formal and colloquial register, so a formal text is not a sign by itself.
- **The Zoomit test is confirmed.** Only Smodin flagged Persian AI text, and Zoomit called it "somewhat reliable." Persian detectors are unreliable, so don't use any detector score as a gate.

## 2. Corrections and caveats by section

| Section | Correction |
|---|---|
| ۸ (61.3%) | The correct figure is **61.22%** (Liang et al. 2023), for non-native English writers. |
| ۸ (14 tools, below 80%) | The study (Weber-Wulff et al. 2023) is about **English**, not Persian. The "<80%" comes from a secondary summary. |
| ۸ SynthID | Confirmed. Back-translation and paraphrase sharply cut detection (arXiv:2508.20228). Rewriting removes watermarks, so see the ethics note in SKILL.md. |
| ز۱ em dash | Soften it. Don't claim that Persian historically never had the em dash. Say: Persian editing style guides usually prefer «،» «؛», parentheses or a new sentence over the em dash. The practical advice stays the same. |
| ب۲ می‌باشد | Mainstream editorial advice, **not a grammar law**. A minority view does not consider می‌باشد ungrammatical, but in modern writing it marks an administrative or machine style. Replace it in most registers; it is a style choice, not a "mistake". |
| و۲ توسط | توسط is native Persian, not a pure calque. It is a heavy formal construction that good prose rarely uses. Prefer the active verb, but don't call it a grammar error. |
| ب۷ fake tanvin | The rule is confirmed by broad consensus. Don't attribute it to Najafi by name without a page reference. |
| ۷ over-correction | Even named authorities (Najafi, Samiei Gilani) disagree with each other and with the Academy's orthography. Don't apply any style "rule" as absolute law. |
| ح۱ currency | Confirmed: use toman or rial in prose. The 1404 redenomination debate doesn't change this. |
| ح۲ weekend | Friday is the official holiday, and Saturday–Sunday is wrong. **The second weekly holiday (Thursday or Saturday) was legally unsettled in 1404–1405, with several reversals.** Don't assume either one. If the text depends on it, write `[VERIFY: second weekly holiday]`. |
| ح۴ verses | Confirmed: fake or misattributed Hafez and Rumi lines are common. Check a decorative verse or cut it. Never "improve" a real one. |
| Letter conventions | Confirmed as genuine, not tells: موضوع, احتراماً, جناب آقای / سرکار خانم and the standard closings. |
| ب۴ template | Reconfirmed, including a reusable **section** template (see N1). |

**New rule, the ezafe after a silent ه:** both «خانه‌ی من» and «خانهٔ من» are acceptable. The Academy prefers «ه‌ی», but «هٔ» is common in books and formal text. Keep **one form through the whole document** and never mix them. Treat this as a style choice, not an error.

## 3. New patterns

**N1. Repeated glossary-section template (Medium, a sub-pattern of د۶).** Each entry follows the same shape: bold heading, textbook definition, «برای مثال», then a closing sentence about the future or «نقش کلیدی». The intro is often repeated word for word as a later heading.
- ❌ **یادگیری ماشین:** یادگیری ماشین زیرمجموعه‌ای از هوش مصنوعی است که به رایانه‌ها امکان می‌دهد از داده‌ها یاد بگیرند. برای مثال، سیستم‌های پیشنهاددهنده از این روش استفاده می‌کنند. این حوزه در آینده نقش کلیدی در صنایع مختلف ایفا خواهد کرد.
- ✅ یادگیری ماشین یعنی رایانه از نمونه‌ها الگو پیدا می‌کند، نه از قانون‌هایی که از پیش نوشته شده‌اند. سیستم پیشنهاد فیلم دقیقاً همین کار را می‌کند: فیلم‌هایی که دیده‌اید را با فیلم‌های کاربران مشابه مقایسه می‌کند.
- Fix: build each section around one real example. Break the heading, definition, example, future-sentence pattern, and let sections differ in length.

**N2. An AI tone formalizer used on casual text (Weak; this is a cause, not a sign).** Someone pastes a chat reply into a formalizer and gets administrative register back, which is the هـ۱ tone mismatch.
- ❌ «بدین‌وسیله به استحضار می‌رساند که سفارش جنابعالی ارسال گردید.»
- ✅ «سفارشتون ارسال شد.»
- Fix: put the text back in the register of its channel. Only administrative letters should sound like administrative letters.

## 4. New genre examples

These three were written for the audit; no real Persian examples were found. Every fact is kept.

**۶.۸ Telegram channel post.** Facts: the channel covers AI content tools. Canva AI now separates the product photo from its background. A freelancer used to do this, and it took two days.

Before:
> 🚀 هوش مصنوعی دیگر یک مفهوم علمی‌تخیلی نیست، بلکه به بخشی جدایی‌ناپذیر از زندگی ما تبدیل شده است! امروز می‌خواهیم نگاهی عمیق به یکی از کاربردهای شگفت‌انگیز آن بیندازیم. ✨ این ابزار نه تنها در کار شما صرفه‌جویی می‌کند، بلکه تجربه‌ای کاملاً متفاوت هم به ارمغان می‌آورد. برای اطلاعات بیشتر، حتماً پست‌های بعدی را دنبال کنید! 🔥

After (colloquial, matching the channel):
> کانوا حالا پس‌زمینه‌ی عکس محصول رو خودش جدا می‌کنه.
>
> تا دیروز این کار رو می‌سپردیم به فریلنسر و دو روز طول می‌کشید؛ حالا با همین ابزار چند ثانیه‌ای تمومه.

**۶.۹ Digikala product description.** Facts: 320 stainless-steel pot, 24 cm. Works on gas and induction. Dishwasher-safe. 2-year warranty.

Before:
> این محصول با کیفیتی بی‌نظیر و طراحی مثال‌زدنی، تجربه‌ای منحصربه‌فرد را برای شما به ارمغان می‌آورد. ساخته‌شده از بهترین متریال موجود، این محصول نه تنها زیبایی خاصی به فضای شما می‌بخشد، بلکه از دوام و کارایی بالایی نیز برخوردار است.

After:
> قابلمه‌ی استیل ضدزنگ ۳۲۰، سایز ۲۴ سانتی‌متر. روی اجاق گاز و القایی کار می‌کند و در ماشین ظرف‌شویی هم شسته می‌شود. ۲ سال گارانتی دارد.

The Before text is pure ب۱/ج۲ with no facts. A rewrite without facts can only flag `[ADD: material, size, compatible cooktops, warranty]`, so never invent them.

**۶.۱۰ Student assignment introduction.** Facts: a research-methods assignment. Data from 40 high-school students in one Tehran school. The question is whether hours spent studying English relate to grades in other subjects.

Before:
> در دنیای امروز، اهمیت یادگیری زبان دوم بر کسی پوشیده نیست. زبان نه تنها ابزاری برای ارتباط است، بلکه دریچه‌ای به فرهنگ‌های دیگر نیز محسوب می‌شود. در این مقاله قصد داریم به بررسی عمیق تأثیر یادگیری زبان انگلیسی بر عملکرد تحصیلی دانش‌آموزان بپردازیم.

After:
> این پژوهش رابطه‌ی ساعت مطالعه‌ی زبان انگلیسی با نمره‌ی سایر درس‌ها را در ۴۰ دانش‌آموز دبیرستانی یک مدرسه‌ی تهران بررسی می‌کند. فرضیه این است که دانش‌آموزانی که بیشتر زبان می‌خوانند، در درس‌های دیگر هم نمره‌ی بهتری می‌گیرند.

Note: the Before says «تأثیر» (effect), but the study measures a relationship. Keep «رابطه» and don't claim causation. If the course requires AI-use disclosure (Payame Noor University has a written policy for theses, for example), the rewrite doesn't remove that duty.

## 5. Shared findings from the English audit that apply to Persian

- **Restructure; don't swap synonyms.** Swapping words keeps 91.4% of a model's fingerprint, while restructuring brings it down to 58.1% (Sun et al., ICML 2025).
- **Never use automated "humanizer" or paraphrasing tools.** They change facts or quotations in 35–65% of the documents that contain them (arXiv:2611.00359). For Persian, that includes verses and quotations.
- **Long ban lists fail when applied mechanically** (arXiv:2509.24090). Use the ۵ tables case by case.
- **Invisible characters:** strip U+200B, U+00A0, U+202F and U+FEFF, and never add them. **ZWNJ (U+200C) is required Persian orthography, not a hidden character.** Never remove a correct ZWNJ.
- **Rhythm alone is Weak.** Uniform sentence length also shows up in human writing, and detectors misflag neurodivergent and non-native writers.
