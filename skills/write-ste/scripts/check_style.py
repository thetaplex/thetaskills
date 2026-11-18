#!/usr/bin/env python3
"""Check a Markdown file against the measurable ASD-STE100 rules.

Usage: python3 check_style.py <file.md>
Prints PASS (N sentences) and exits 0, or FAIL with one line per violation and exits 1.
Skips headings, tables, quotes, code, `- [S1]` source lines and the References section.
"""
import re
import sys

# (unapproved, approved), lowercase. Multi-word entries match as phrases.
WORDS = [
    ("utilize", "use"), ("utilise", "use"), ("commence", "start"), ("terminate", "stop"),
    ("approximately", "about"), ("additional", "more"), ("sufficient", "enough"),
    ("prior to", "before"), ("subsequent to", "after"), ("in order to", "to"),
    ("facilitate", "help"), ("demonstrate", "show"), ("ascertain", "find out"),
    ("endeavour", "try"), ("endeavor", "try"), ("attempt", "try"), ("obtain", "get"),
    ("acquire", "get"), ("purchase", "buy"), ("require", "need"), ("necessitate", "need"),
    ("accomplish", "do"), ("perform", "do"), ("conduct", "do"), ("implement", "do"),
    ("assist", "help"), ("permit", "let"), ("enable", "let"), ("ensure", "make sure"),
    ("examine", "check"), ("modify", "change"), ("alter", "change"), ("eliminate", "remove"),
    ("whilst", "while"), ("regarding", "about"), ("concerning", "about"), ("numerous", "many"),
    ("majority", "most"), ("optimum", "best"), ("component", "part"),
    ("methodology", "method"), ("functionality", "function"), ("in the event that", "if"),
    ("at this point in time", "now"), ("accelerate", "speed up"), ("accommodate", "hold"),
    ("achieve", "do"), ("activate", "start"), ("aggregate", "total"), ("allocate", "give"),
    ("amend", "change"), ("apparent", "clear"), ("appropriate", "correct"), ("arrange", "put"),
    ("assess", "check"), ("authorize", "let"), ("bear in mind", "remember"), ("cease", "stop"),
    ("circumvent", "go around"), ("clarify", "make clear"), ("commencement", "start"),
    ("comprise", "include"), ("consequently", "so"), ("consider", "think about"),
    ("construct", "make"), ("currently", "now"), ("deactivate", "stop"),
    ("decrease", "reduce"), ("deem", "think"), ("depart", "leave"), ("designate", "name"),
    ("determine", "find"), ("discontinue", "stop"), ("discover", "find"), ("dispatch", "send"),
    ("displace", "move"), ("distribute", "give out"), ("due to the fact that", "because"),
    ("employ", "use"), ("encounter", "meet"), ("establish", "set up"), ("evaluate", "check"),
    ("eventually", "at last"), ("exceed", "be more than"), ("exhibit", "show"),
    ("expedite", "speed up"), ("expire", "end"), ("extremely", "very"), ("fabricate", "make"),
    ("finalize", "finish"), ("for the purpose of", "to"), ("furnish", "give"),
    ("furthermore", "also"), ("generate", "make"), ("henceforth", "from now"),
    ("illustrate", "show"), ("immediately", "at once"), ("inform", "tell"),
    ("initial", "first"), ("initiate", "start"), ("insufficient", "not enough"),
    ("interrupt", "stop"), ("manufacture", "make"), ("nevertheless", "but"),
    ("notify", "tell"), ("observe", "see"), ("occur", "happen"), ("originate", "start"),
    ("otherwise", "or"), ("participate", "take part"), ("possess", "have"),
    ("preclude", "prevent"), ("preferably", "if possible"), ("previously", "before"),
    ("principal", "main"), ("proceed", "go"), ("procure", "get"), ("provide", "give"),
    ("relocate", "move"), ("remainder", "rest"), ("render", "make"), ("represent", "show"),
    ("reside", "live"), ("respond", "answer"), ("retain", "keep"), ("retrieve", "get"),
    ("revise", "change"), ("simultaneously", "at the same time"), ("solely", "only"),
    ("subsequently", "then"), ("substantial", "large"), ("thereby", "so"),
    ("transmit", "send"), ("ultimately", "at last"), ("undergo", "go through"),
    ("unnecessary", "not needed"), ("until such time as", "until"), ("utilization", "use"),
    ("validate", "check"), ("various", "different"), ("with regard to", "about"),
    ("with respect to", "about"), ("in addition", "also"), ("in conjunction with", "with"),
    ("in the absence of", "without"), ("a number of", "some"), ("is able to", "can"),
    ("subsequent", "next"), ("magnitude", "size"), ("sufficiently", "enough"),
    ("excessive", "too much"), ("fundamental", "basic"), ("inadequate", "not enough"),
    ("peruse", "read"), ("reiterate", "say again"), ("elucidate", "make clear"),
    ("optimal", "best"), ("preliminary", "first"), ("rectify", "correct"),
    ("transpire", "happen"), ("viable", "possible"), ("additionally", "also"),
    ("assistance", "help"), ("considerable", "large"), ("discrepancy", "difference"),
    ("enhance", "improve"), ("enumerate", "list"), ("inception", "start"),
    ("optimize", "improve"), ("predominantly", "mostly"), ("presently", "now"),
    ("relinquish", "give up"), ("thereafter", "after that"), ("pursuant to", "under"),
    ("comply with", "obey"), ("as a result of", "because of"), ("in the vicinity of", "near"),
    ("ameliorate", "improve"), ("aforementioned", "this"), ("terminology", "words"),
]
SUFFIXES = ("", "e", "es", "ed", "d", "ing", "s")
FUNCTION_WORDS = set("""a an the of in on at to for with by from into onto over under about after
before between through and or but nor so if than that which who when while because as i you he
she it we they me him her us them my your his its our their this these those is are was were be
been being am do does did have has had can could will would shall should may might must
not""".split())


def stem(w):
    return w[:-1] if w.endswith("e") else w


def _word_alt(w):
    if " " in w:
        return re.escape(w).replace(r"\ ", r"\s+")
    return re.escape(stem(w)) + "(?:e|es|ed|d|ing|s)?"


RE_WORD = re.compile(r"(?i)\b(?:%s)\b" % "|".join(
    _word_alt(w) for w, _ in sorted(WORDS, key=lambda p: -len(p[0]))))
RE_PASSIVE = re.compile(
    r"(?i)\b(is|are|was|were|be|been|being)\s+(\w+ed|\w+en|built|done|made|shown|given|taken"
    r"|written|found|held|kept|known|left|sent|set)\b")
RE_CONTRACTION = re.compile(r"(?i)\b\w+'(t|re|ve|ll|d|m)\b")
RE_INLINE_CODE = re.compile(r"`[^`]*`")
RE_SOURCE_LINE = re.compile(r"^- \[S\d+\]")
RE_LIST = re.compile(r"^\s*(?:[-*]|\d+\.)\s+")
RE_TOKEN = re.compile(r"[A-Za-z0-9']+")
RE_LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")
RE_URL = re.compile(r"https?://\S+")
BREAKS = set(".,;:!?()\"—-")


def hint_for(matched):
    key = " ".join(matched.lower().split())
    hits = [(w, a) for w, a in WORDS if (w == key if " " in w else
            key.startswith(stem(w)) and key[len(stem(w)):] in SUFFIXES)]
    return max(hits, key=lambda p: len(p[0]))[1] if hits else ""


def split_sentences(par):
    out, cur = [], ""
    for i, c in enumerate(par):
        cur += c
        if c not in ".!?" or (i + 1 < len(par) and not par[i + 1].isspace()):
            continue
        if cur.lower().endswith(("e.g.", "i.e.")):
            continue
        out.append(cur.strip())
        cur = ""
    if cur.strip():
        out.append(cur.strip())
    return out


def check_line(n, text, v):
    for m in RE_PASSIVE.finditer(text):
        v.append((n, "passive", m.group(0), "use the active voice"))
    for m in RE_CONTRACTION.finditer(text):
        v.append((n, "contraction", m.group(0), "write the full words"))
    if ";" in text:
        v.append((n, "semicolon", ";", "use two sentences"))
    for m in RE_WORD.finditer(text):
        v.append((n, "word", m.group(0), hint_for(m.group(0))))
    # ponytail: function-word heuristic, no POS tagger; swap for a tagger if false positives dominate
    toks = list(RE_TOKEN.finditer(text))
    run = start = 0
    for i, t in enumerate(toks):
        if i and BREAKS & set(text[toks[i - 1].end():t.start()]):
            run = 0
        w = t.group(0).lower()
        content = w not in FUNCTION_WORDS and not (
            (w.endswith("ly") and not w.endswith("ply")) or w.endswith(("ing", "ed")))
        if not content:
            run = 0
            continue
        if run == 0:
            start = i
        run += 1
        if run == 4:
            v.append((n, "noun-cluster", text[toks[start].start():t.end()],
                      "use a shorter phrase or add function words"))


def check_para(line, is_list, text, v):
    s = split_sentences(text)
    limit = 20 if is_list else 25
    for sent in s:
        words = sent.split()
        if len(words) > limit:
            v.append((line, "length", f"{' '.join(words[:8])}... ({len(words)} words)",
                      f"limit is {limit} words"))
    if len(s) > 6:
        v.append((line, "paragraph", f"{len(s)} sentences", "limit is 6 sentences"))
    return len(s)


def check_style(markdown):
    v, sentences = [], 0
    in_fence = in_refs = False
    prev_ok = True
    para = None  # [line, is_list, text]

    def flush():
        nonlocal para, sentences
        if para:
            sentences += check_para(*para, v)
        para = None

    for n, raw in enumerate(markdown.splitlines(), 1):
        t = raw.lstrip()
        indented_code = raw.startswith(("    ", "\t")) and prev_ok
        prev_ok = not t or indented_code
        if t.startswith(("```", "~~~")):
            flush()
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if t.startswith("#"):
            flush()
            in_refs = t.lstrip("#").strip().lower() == "references"
            continue
        if in_refs or indented_code or t.startswith((">", "|")) or RE_SOURCE_LINE.match(raw) or not t:
            flush()
            continue
        is_list = bool(RE_LIST.match(raw))
        clean = RE_URL.sub(" ", RE_LINK.sub(r"\1", RE_INLINE_CODE.sub(" ", RE_LIST.sub("", raw, 1))))
        check_line(n, clean, v)
        if is_list:
            flush()
        if para:
            para[2] += " " + clean
        else:
            para = [n, is_list, clean]
    flush()
    return sentences, v


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: check_style.py <file.md>")
    with open(sys.argv[1], encoding="utf-8") as f:
        sentences, v = check_style(f.read())
    if not v:
        print(f"PASS ({sentences} sentences)")
        return
    print(f"FAIL: {len(v)} violations")
    for n, rule, text, hint in v:
        print(f"line {n} [{rule}] {text} -> {hint}")
    sys.exit(1)


if __name__ == "__main__":
    main()
