#!/usr/bin/env python3
"""Verify a humanized rewrite: AI-writing tells left, and facts kept.

    check_tells.py OUTPUT [--source SRC [SRC ...]] [--lang auto|en|fa] [--json]
    check_tells.py --self-test

OUTPUT and SRC are file paths, or - for stdin. Pass the original text (and any
file of facts the user confirmed) as --source to check that no number, URL or
name was lost or invented.

Exit 0 = pass. Exit 1 = fix needed: a Strong tell, a paragraph with 3+ Medium
tells, fact drift, or invisible characters/homoglyphs the rewrite added.
Exit 2 = usage error.

Tell lists follow references/signs-of-ai-writing-{en,fa}.md plus
references/research-updates-{en,fa}.md (sections G/ط are Strong; Weak signs are
reported for context only). Text in quotes and > blockquotes is not scanned for
tells, since quotes and poetry are left as written. Stdlib only.
"""
import argparse
import json
import re
import statistics
import sys

APOS = "(?:'|’)"
CLUSTER = 3  # Medium tells in one paragraph that count as a cluster

SHARED = [  # tool tokens, placeholders and punctuation: any language
    ("strong", "G5/ط۶ tool token or tracking parameter",
     r"contentReference\[|oaicite|\bturn\d+(?:search|news|view|fetch)\d+|citeturn|【\d+†[^】]*】"
     r"|utm_source=(?:chatgpt\.com|openai|copilot\.com)|referrer=grok\.com|↩"),
    ("strong", "G4/ط۵ placeholder", r"\b(?:19|20)\d\d-XX-XX\b|INSERT_[A-Z_]+|example\.com/source\d|XXX"),
    ("weak", "F5 Markdown (remove if the destination does not render it)", r"\*\*[^*\n]+\*\*|^#{1,6} "),
    ("weak", "F emoji decoration", "[\U0001F300-\U0001FAFF☀-➿]"),
]

EN_WORDS = (
    "delve[sd]? delving tapestry pivotal crucial intricate interplay meticulous(?:ly)? vibrant "
    "underscor(?:e|es|ed|ing) garner(?:s|ed)? bolster(?:s|ed)? showcas(?:e|es|ed|ing) "
    "foster(?:s|ed|ing)? enhanc(?:e|es|ed|ing) landscape realm nuanced seamless(?:ly)? "
    "streamlin(?:e|es|ed|ing) harness(?:es|ed|ing)? illuminat(?:e|es|ed|ing) facilitat(?:e|es|ed|ing) "
    "beacon palpable embark(?:s|ed|ing)? ever-evolving robust transformative invaluable commendable "
    "multifaceted quietly leverag(?:e|es|ed|ing) empower(?:s|ed|ing)? unlock(?:s|ed|ing)? "
    "elevat(?:e|es|ed|ing) enduring notably"
).split()

EN = [
    ("strong", "G1 chat phrase",
     r"\b(?:certainly|of course|absolutely)!|\bsure, here" + APOS + r"s\b"
     r"|\bhere(?:" + APOS + r"s| is) (?:a|the|your) (?:revised|rewritten|updated|polished|improved)\b"
     r"|\bI hope this helps\b|\blet me know if you" + APOS + r"d like\b|\bwould you like me to\b"
     r"|\bis there anything else\b|\bfeel free to (?:adjust|modify|tweak|customi[sz]e)\b|\bgreat question\b"
     r"|^\s*(?:certainly[!,.]?\s+)?below is (?:a|an|the|your)\b"),
    ("strong", "G1 prompt echo",
     r"\b(?:based on|according to|from) the (?:document|text|information|details|notes|data|file|article|draft)s? "
     r"you (?:provided|shared|gave|sent|uploaded|pasted)\b"),
    ("strong", "G2 model self-reference",
     r"\bas an? (?:AI|large) language model\b|\bas of my (?:last )?(?:knowledge|training) (?:update|cutoff)\b"
     r"|\bup to my last training\b|\bI don" + APOS + r"t have access to real-time\b|\bI can" + APOS + r"t browse\b"),
    ("strong", "G3 source disclaimer",
     r"\bwhile specific details\b.{0,60}?\b(?:limited|scarce)\b|\bnot widely documented\b"
     r"|\bbased on (?:the )?available information\b|\bin the provided search results\b|\bmaintains a low profile\b"),
    ("strong", "G4 placeholder",
     r"\[(?:your|insert|company|client|recipient|name|date|title|link)\b[^\]]*\]"
     r"|\((?:add|insert) link here\)|\(if available\)"),
    ("medium", "B1 AI vocabulary", r"\b(?:" + "|".join(EN_WORDS) + r")\b"),
    ("medium", "B2 sentence-initial formal transition",
     r"(?:^|[.!?]\s+)(?:additionally|moreover|furthermore|consequently|nevertheless|nonetheless"
     r"|notwithstanding|indeed|undoubtedly|hence|thus),"),
    ("medium", "B3 buzzword",
     r"\b(?:actionable insights|data-driven|results-driven|best-in-class|drive efficiency|synerg(?:y|ies|istic)|holistic)\b"),
    ("medium", "B5 stock opener",
     r"\bin today" + APOS + r"s (?:fast-paced|digital|ever-changing|rapidly evolving|modern) (?:world|age|landscape|era)\b"
     r"|\bin the ever-evolving\b|\blet" + APOS + r"s dive in\b|\bbuckle up\b|\bgame[- ]changer\b|\bcutting-edge\b"
     r"|\bembark on a journey\b|\bnavigate the complexities\b|\bunlock the (?:full )?potential\b"),
    ("medium", "C1 copula avoidance", r"\b(?:serves|stands) as\b|\bboasts\b"),
    ("medium", "C2 negative parallelism",
     r"\bnot only\b[^.!?]{0,80}?\bbut also\b|\bit" + APOS + r"s not just\b[^.!?]{0,60}?\bit" + APOS + r"s\b"),
    ("medium", "C8 forced punchiness",
     r"\bhere" + APOS + r"s the thing:|\bthe (?:result|kicker|catch)\?|\blet that sink in\b|\bspoiler:|\bplot twist:"),
    ("medium", "C9 wordy phrase", r"\bin order to\b|\bdue to the fact that\b|\bat this point in time\b|\ba plethora of\b"),
    ("medium", "4.2 stock phrase",
     r"\bit" + APOS + r"s (?:important|worth) (?:to note|noting)\b|\bplays? an? (?:pivotal|crucial|key|vital) role\b"
     r"|\bis a testament to\b|\bI hope this (?:email|message) finds you well\b"
     r"|\bplease don" + APOS + r"t hesitate to\b|\bin conclusion\b"),
    ("medium", "C nominalization",
     r"\b(?:conduct(?:s|ed|ing)?|perform(?:s|ed|ing)?|carr(?:y|ies|ied) out|achiev(?:e|es|ed|ing)|result(?:s|ed)? in"
     r"|provid(?:e|es|ed|ing)|mak(?:e|es|ing)|made) (?:an? |the )?\w+(?:tion|ment|ance|ence|sis) (?:of|in|on|for)\b"),
    ("medium", "H fake candor", r"(?:^|[.!?]\s+)(?:and )?honestly\?|\b(?:is|are|was|were|feels?) genuinely\b"),
    ("medium", "H bare dramatic beat", r"(?:^|[.!?]\s+)(?:this|it|that) (?:matters|changes everything)\."),
    ("weak", "F1 em dash (contested; vary punctuation, don't swap all for one mark)", r"—"),
]

# Persian patterns run on a normalized copy: ZWNJ -> space, Arabic ي/ك -> Persian ی/ک.
FA = [
    ("strong", "ط۱ chat phrase",
     r"حتما[ًا]?!|این هم متن|سؤال بسیار خوبی|سوال بسیار خوبی|خوشحال می شوم (?:که )?(?:به شما )?کمک کنم"
     r"|امیدوارم این (?:مطلب|متن|پاسخ) (?:برای شما |برایتان )?مفید|اگر بخواهید،? می توانم"),
    ("strong", "ط۲ model self-reference", r"به عنوان یک مدل زبانی|تا تاریخ آخرین به ?روزرسانی|به اینترنت دسترسی ندارم"),
    ("strong", "ط۳ prompt echo", r"طبق درخواست شما|بر اساس توضیحات شما|مطابق دستور ارائه ?شده|در این ?جا متنی با لحن"),
    ("strong", "ط۴ source disclaimer",
     r"اطلاعات دقیقی [^.؟!\n]{0,60}?در دسترس نیست|بر اساس اطلاعات موجود|برای اطلاعات به ?روز به منابع رسمی"),
    ("strong", "ط۵ placeholder", r"\[(?:نام|تاریخ|شماره|آدرس|عنوان)[^\]]*\]|این ?جا [^.\n]{0,20}?را وارد کنید"),
    ("medium", "ب۲ bureaucratic verb",
     r"می باشد|می باشند|\bگردید|به عمل (?:آمد|می آید|آورد)|صورت (?:پذیرفت|پذیرفته|می پذیرد)"
     r"|\bمورد [^.،؛!؟\n]{1,30}? قرار (?:گرفت|گرفته|می گیرد|داد|دادند)|به شمار می رود|محسوب می شود"
     r"|اقدام به [^.،\n]{1,30}? (?:نمود|کرد|نمایید)|حاصل فرمایید|\bجهت\b|\bمذکور|فوق الذکر|\bکماکان\b|\bلذا\b"),
    ("medium", "ب۳ filler phrase", r"لازم به ذکر است|شایان ذکر است|گفتنی است|ناگفته نماند|همان ?طور که می دانید"),
    ("medium", "ب۴ stock opener or closer",
     r"در دنیای امروز|در عصر دیجیتال|امروزه با پیشرفت (?:تکنولوژی|فناوری)|دیگر یک مفهوم علمی ?تخیلی نیست"
     r"|در نهایت می توان گفت|امید است (?:که )?این (?:مطلب|مقاله)"),
    ("medium", "ب۵ intensifier", r"به طور قابل توجهی|\bبی شک\b|بدون تردید|\bبه شدت\b"),
    ("medium", "ب۶ inflated preposition", r"در راستای|در جهت نیل به|\bبه منظور\b|\bدر خصوص\b|در رابطه با"),
    ("medium", "ب۱ AI vocabulary",
     r"ترکیبی بی نظیر از|\b(?:جامع|کلیدی|حیاتی|چشمگیر|نوآورانه|بی نظیر)\b|بهره گیری|ارتقا (?:بخشیدن|بخشید|می بخشد)"
     r"|به ارمغان (?:آورد|می آورد|آوردن|بیاورد)|رقم (?:زد|می زند|زدن|خواهد زد)|هموار کردن مسیر|مسیر [^.\n]{0,20}?را هموار"
     r"|به بررسی عمیق"),
    ("medium", "ج۲ not only…but also", r"نه تنها [^.؟!\n]{1,80}? بلکه"),
    ("medium", "ج۴ false range", r"\bاز [^.؟!،\n]{1,40}? گرفته تا\b"),
    ("medium", "و۱ calque",
     r"در پایان روز|بیایید نگاهی|امیدوارم این (?:ایمیل|پیام) [^.\n]{0,20}?(?:خوب|در سلامت)|دریغ نکنید|\bاتخاذ"
     r"|نقش (?:کلیدی|مهمی|حیاتی|بسزایی|اساسی) (?:را )?(?:بازی|ایفا)|تغییردهنده ی بازی"
     r"|این ?جاست که [^.\n]{1,30}? وارد می شود|با کمال افتخار اعلام"),
    ("medium", "و۲ calque (توسط، به‌عنوان یک)", r"\bتوسط\b|\bبه عنوان یک\b"),
    ("medium", "ی newer-model tell", r"اهمیت دارد|بی ?سروصدا|قابل اتکا"),
    ("medium", "ز۱ em dash (not used in Persian prose)", r"—"),
]

PATTERNS = {
    lang: [(s, c, re.compile(p, re.I | re.M)) for s, c, p in SHARED + table]
    for lang, table in (("en", EN), ("fa", FA))
}
FA_NORM = str.maketrans({"‌": " ", "‏": " ", "‎": " ", "ي": "ی", "ك": "ک"})  # length-preserving
DIGITS = str.maketrans("۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩٫", "01234567890123456789.")
MARKER = re.compile(r"\[(?:ADD|VERIFY):[^\]]*\]")
# Whole tool tokens and placeholders: their digits and words are not facts.
ARTIFACT = re.compile(r":?contentReference\[[^\]]*\](?:\{[^}]*\})?|【[^】]*】|\bturn\d+(?:search|news|view|fetch)\d+"
                      r"|\[(?:your|insert|company|client|recipient|name|date|title|link)\b[^\]]*\]"
                      r"|\[(?:نام|تاریخ|شماره|آدرس|عنوان)[^\]]*\]", re.I)
QUOTED = re.compile(r"«[^»\n]*»|“[^”\n]*”|\"[^\"\n]*\"|^\s*>.*$", re.M)
URL = re.compile(r"https?://[^\s)\]»>\"']+")
NUM = re.compile(r"\d+(?:[,٬]\d{3})*(?:\.\d+)?")
LIST_NUM = re.compile(r"^\s*\d+[.)]\s", re.M)
LATIN_WORD = re.compile(r"[A-Za-z][A-Za-z0-9&'+#.-]*[A-Za-z0-9+#]")
# Invisible characters (ZWNJ and RLM/LRM excluded: Persian needs them) and Latin/Cyrillic homoglyph mixes.
HIDDEN = re.compile("[​⁠﻿  ᠎⁡-⁤]|[A-Za-z][Ѐ-ӿ]|[Ѐ-ӿ][A-Za-z]")
SENT_START = set(".!?:;\"“(*#•-–—\n")


def detect_lang(text):
    fa = len(re.findall(r"[؀-ۿ]", text))
    return "fa" if fa > len(re.findall(r"[A-Za-z]", text)) else "en"


def clean_url(u):
    u = re.sub(r"[?&](?:utm_[a-z]+|referrer)=[^&#]*", "", u.rstrip(".,;:!?،؛"))
    return u.rstrip("?&/")


def title_line(line):
    """Headings, subject lines and Title Case lines: their capitals are style, not names."""
    ws = LATIN_WORD.findall(line)
    return bool(re.match(r"\s*(?:#|subject:)", line, re.I)) or (
        len(ws) >= 5 and sum(w[0].isupper() for w in ws) >= 0.7 * len(ws))


def names(text, lang):
    """Proper-name candidates. en: capitalized words not at a sentence start. fa: any Latin word."""
    out = set()
    if lang == "en":  # ponytail: a name that only appears in a heading is not checked
        text = "\n".join("" if title_line(l) else l for l in text.split("\n"))
    for m in LATIN_WORD.finditer(text):
        w = m.group().rstrip(".")
        if lang == "fa":
            out.add(w)
            continue
        before = text[:m.start()].rstrip(" \t")
        if w[0].isupper() and w != "I" and before and before[-1] not in SENT_START:
            out.add(w)
    return out


def facts(text, lang):
    t = ARTIFACT.sub(" ", MARKER.sub(" ", text)).translate(DIGITS)
    urls = {clean_url(u) for u in URL.findall(t)}
    t = LIST_NUM.sub(" ", URL.sub(" ", t))
    nums = {re.sub("[,٬]", "", n) for n in NUM.findall(t)}
    return nums, urls, names(t, lang)


def fact_drift(output, sources, lang):
    src = "\n".join(sources)
    s_nums, s_urls, s_names = facts(src, lang)
    o_nums, o_urls, o_names = facts(output, lang)
    out_plain = MARKER.sub(" ", output).translate(DIGITS)
    src_plain = src.translate(DIGITS).lower()
    return {
        "missing": sorted(s_nums - o_nums) + sorted(s_urls - o_urls) + sorted(n for n in s_names if n not in out_plain),
        "new": sorted(o_nums - s_nums) + sorted(o_urls - s_urls) + sorted(n for n in o_names if n.lower() not in src_plain),
    }


def quotes_lost(output, source, lang):
    """Quotes, verses and > blockquote lines of 4+ words in the source that are not verbatim in the output."""
    norm = lambda s: " ".join((s.translate(FA_NORM) if lang == "fa" else s).split())
    out = norm(output)
    found = (m.strip("«»“”\"> \t\n") for m in QUOTED.findall(source))
    return [q for q in found if len(q.split()) >= 4 and norm(q) not in out]  # ponytail: shorter scare-quotes may be cut freely


def scan(text, lang):
    norm = text.translate(FA_NORM) if lang == "fa" else text
    norm = QUOTED.sub(lambda m: " " * len(m.group()), norm)
    breaks = [m.end() for m in re.finditer(r"\n\s*\n", norm)]
    hits = []
    for strength, code, rx in PATTERNS[lang]:
        for m in rx.finditer(norm):
            hits.append({
                "strength": strength, "code": code, "match": text[m.start():m.end()].strip(" ,.\n"),
                "line": norm.count("\n", 0, m.start()) + 1,
                "para": sum(b <= m.start() for b in breaks) + 1,
            })
    return sorted(hits, key=lambda h: h["line"])


def rhythm(text):
    sents = [s for s in re.split(r"(?<=[.!?؟])\s+|\n+", MARKER.sub("", text)) if s.split()]
    lens = [len(s.split()) for s in sents]
    if len(lens) < 8:
        return None
    cv = statistics.pstdev(lens) / statistics.mean(lens)
    return {"sentences": len(lens), "cv": round(cv, 2), "uniform": cv < 0.35}


def check(output, sources=(), lang="auto"):
    lang = detect_lang(output) if lang == "auto" else lang
    hits = scan(output, lang)
    per_para = {}
    for h in hits:
        if h["strength"] == "medium":
            per_para.setdefault(h["para"], []).append(h["match"])
    by = {s: [h for h in hits if h["strength"] == s] for s in ("strong", "medium", "weak")}
    report = {
        "lang": lang, **by,
        "clusters": {p: m for p, m in per_para.items() if len(m) >= CLUSTER},
        "rhythm": rhythm(output),
        "flags": MARKER.findall(output),
        "facts": fact_drift(output, sources, lang) if sources else None,
        "hidden": {"output": len(HIDDEN.findall(output)),
                   "source": len(HIDDEN.findall("\n".join(sources))) if sources else None},
        "quotes_lost": quotes_lost(output, sources[0], lang) if sources else [],  # first source = original text
    }
    drift = report["facts"] and (report["facts"]["missing"] or report["facts"]["new"])
    added_hidden = sources and report["hidden"]["output"] > report["hidden"]["source"]
    report["pass"] = not (report["strong"] or report["clusters"] or drift or added_hidden or report["quotes_lost"])
    return report


def show(r):
    p = print
    p(f"check_tells: {'PASS' if r['pass'] else 'FAIL'} (lang={r['lang']})")
    p(f"Strong tells (always remove): {len(r['strong'])}")
    for h in r["strong"]:
        p(f"  L{h['line']} [{h['code']}] {h['match']!r}")
    p(f"Medium tells: {len(r['medium'])} total; paragraphs with {CLUSTER}+ (clusters, fix these): {len(r['clusters'])}")
    for para, ms in r["clusters"].items():
        p(f"  paragraph {para}: {', '.join(repr(m) for m in ms)}")
    lone = [h for h in r["medium"] if h["para"] not in r["clusters"]]
    if lone:
        p("  isolated (fix only if it hurts the sentence): " + ", ".join(f"L{h['line']} {h['match']!r}" for h in lone))
    if r["weak"]:
        kinds = sorted({h["code"] for h in r["weak"]})
        p(f"Weak signs (context only, never proof): {len(r['weak'])} -> " + "; ".join(kinds))
    if r["rhythm"]:
        rh = r["rhythm"]
        p(f"Rhythm: {rh['sentences']} sentences, length CV {rh['cv']}"
          + (" -> uniform; vary length if other tells are present (weak sign alone)" if rh["uniform"] else " (ok)"))
    hd = r["hidden"]
    if hd["output"]:
        added = hd["source"] is not None and hd["output"] > hd["source"]
        p(f"Invisible characters or homoglyphs: {hd['output']}"
          + (" -> ADDED by the rewrite: remove them (forbidden)" if added else " -> strip unless intended (e.g. a deliberate no-break space)"))
    if r["facts"] is not None:
        f = r["facts"]
        p("Facts vs source: " + ("ok" if not (f["missing"] or f["new"]) else ""))
        if f["missing"]:
            p(f"  missing from output (restore, or confirm it was pure filler): {', '.join(f['missing'])}")
        if f["new"]:
            p(f"  new in output, not in source (remove unless the user supplied it): {', '.join(f['new'])}")
    for q in r["quotes_lost"]:
        p(f"Quote/verse changed or dropped (restore verbatim): {q[:80]!r}")
    if r["flags"]:
        p(f"Flags to list after the text ({len(r['flags'])}): " + " ".join(r["flags"]))


def read(path):
    if path == "-":
        return sys.stdin.read()
    with open(path, encoding="utf-8") as f:
        return f.read()


def self_test():
    bad = ("Certainly! Here is a revised version.\n\nMoreover, our platform serves as a pivotal hub. "
           "We delve into a vibrant tapestry of ideas — see https://x.org/a?utm_source=chatgpt.com\n")
    r = check(bad, [bad], "en")
    assert not r["pass"] and len(r["strong"]) >= 3, r["strong"]
    assert 2 in r["clusters"], r["clusters"]
    good = "We moved the billing service to the new cluster on 14 March. Downtime was 40 minutes."
    assert check(good, [good])["pass"]
    d = fact_drift("Revenue rose 12% in Q3 under Dana Ruiz.", ["Revenue rose 9% in Q3 under Dana Ruiz at Acme."], "en")
    assert d["missing"] == ["9", "Acme"] and d["new"] == ["12"], d
    assert fact_drift("See https://x.org/a.", ["See https://x.org/a?utm_source=chatgpt.com"], "en") == {"missing": [], "new": []}
    assert fact_drift("x [ADD: 3 clients] y", ["x y"], "en")["new"] == []
    assert names("The report. Then Acme and I met Bo.", "en") == {"Acme", "Bo"}
    src = "Subject: Exciting Update on Our Pivotal Data Journey\n\nIt costs $5 :contentReference[oaicite:2]{index=2}.\n\nBest,\n[Your Name]"
    assert fact_drift("It costs $5.", [src], "en") == {"missing": [], "new": []}, fact_drift("It costs $5.", [src], "en")
    assert fact_drift("Best,", ["Best regards, Jane Doe"], "en")["missing"] == ["Doe", "Jane"]
    fa_bad = "حتماً! این هم متن شما.\n\nلازم به ذکر است که این سرویس در راستای رشد شما می‌باشد و نقش کلیدی ایفا می‌کند."
    r = check(fa_bad, [], "auto")
    assert r["lang"] == "fa" and len(r["strong"]) == 2 and 2 in r["clusters"], r
    assert check("این سرویس ۳ ماه پیش راه افتاد و حالا ۲۴۰ مشتری دارد.", ["این سرویس 3 ماه پیش راه افتاد و حالا 240 مشتری دارد."])["pass"]
    assert check("«لازم به ذکر است» را حذف کنید.", [], "fa")["medium"] == []  # quoted text is not scanned
    r = check("Based on the notes you provided, the launch slipped. This matters. We will conduct an evaluation of it.", [], "en")
    assert [h["code"] for h in r["strong"]] == ["G1 prompt echo"], r["strong"]
    assert {"H bare dramatic beat", "C nominalization"} <= {h["code"] for h in r["medium"]}, r["medium"]
    dash = check("We shipped — finally — on Friday — after QA — signed off.", [], "en")
    assert dash["pass"] and len(dash["weak"]) == 4 and not dash["medium"]  # EN em dash: weak, never a cluster
    assert not check("Ship it​ today.", ["Ship it today."], "en")["pass"]  # inserted zero-width space
    assert check("Ship it today.", ["Ship it today."], "en")["pass"]  # kept from source: fine
    assert not check("Pay vіa card.", ["Pay via card."], "en")["pass"]  # Cyrillic і homoglyph
    verse = "حافظ گفته:\n\n> صبا به لطف بگو آن غزال رعنا را\n\nممنون."
    assert check(verse.replace("ممنون.", "مرسی."), [verse], "fa")["quotes_lost"] == []
    assert check("حافظ گفته: صبا به لطف بگو آن غزال زیبا را", [verse], "fa")["quotes_lost"] == ["صبا به لطف بگو آن غزال رعنا را"]
    print("self-test ok")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("output", nargs="?", help="rewritten text file, or - for stdin")
    ap.add_argument("--source", nargs="+", default=[], help="original text and any confirmed-facts files")
    ap.add_argument("--lang", choices=["auto", "en", "fa"], default="auto")
    ap.add_argument("--json", action="store_true", help="print the report as JSON")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    if not a.output:
        ap.error("OUTPUT is required")
    r = check(read(a.output), [read(s) for s in a.source], a.lang)
    print(json.dumps(r, ensure_ascii=False, indent=2)) if a.json else show(r)
    sys.exit(0 if r["pass"] else 1)


if __name__ == "__main__":
    main()
