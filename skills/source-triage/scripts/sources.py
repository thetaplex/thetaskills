#!/usr/bin/env python3
"""Source ledger for sourced writing: research/sources.json in the current folder.

  sources.py add --url URL --title TITLE [--relevance 1-5] [--authors "A, B"] [--year Y]
                 [--doi DOI] [--note NOTE]     prints the key, like [S3]; a known url or doi
                                               prints the existing key
  sources.py list                              one line per source, highest relevance first
  sources.py note --heading H --text T [--file F]
                                               adds one note as the last line under `## H` in
                                               F (default research/notes.md); refuses keys
                                               that are not in the ledger
  sources.py refs DRAFT.md                     writes one References line per cited key
  sources.py check DRAFT.md [--words MIN-MAX]  every [S#] in the draft must be in the ledger,
                                               no TODO line left, length in range;
                                               exits 1 on FAIL
"""
import argparse
import datetime
import json
import os
import re
import sys

LEDGER = os.path.join("research", "sources.json")
NOTES = os.path.join("research", "notes.md")
REF_HEADINGS = ("references", "sources")


def load():
    if not os.path.exists(LEDGER):
        return []
    with open(LEDGER, encoding="utf-8") as f:
        text = f.read().strip()
    return json.loads(text) if text else []


def save(items):
    os.makedirs(os.path.dirname(LEDGER), exist_ok=True)
    tmp = LEDGER + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(items, f, indent=2, ensure_ascii=False)
    os.replace(tmp, LEDGER)  # never leaves a half-written ledger


def num(key):
    m = re.fullmatch(r"S(\d+)", key or "")
    return int(m.group(1)) if m else 0


def line(s):
    meta = ", ".join(s.get("authors") or [])
    if s.get("year"):
        meta += (", " if meta else "") + str(s["year"])
    rel = f" r={s['relevance']}" if s.get("relevance") else ""
    return f"[{s['key']}]{rel} {s['title']}{f' ({meta})' if meta else ''} {s['url']}"


def add(a):
    items = load()
    for s in items:
        if s["url"] == a.url or (a.doi and (s.get("doi") or "").lower() == a.doi.lower()):
            print(f"exists {line(s)}")
            return
    s = {
        "key": f"S{max(map(num, (i['key'] for i in items)), default=0) + 1}",
        "kind": "paper" if a.doi else "web",
        "title": a.title,
        "authors": [x.strip() for x in a.authors.split(",") if x.strip()] if a.authors else [],
        "year": a.year, "venue": None, "doi": a.doi, "url": a.url, "abstract": None,
        "note": a.note,
        "relevance": max(1, min(5, a.relevance)) if a.relevance else None,
        "added_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    items.append(s)
    save(items)
    print(f"added {line(s)}")


def list_sources(_):
    items = sorted(load(), key=lambda s: (-(s.get("relevance") or 0), num(s["key"])))
    print("\n".join(map(line, items)) if items else "No sources yet.")


def norm(heading):
    return " ".join(heading.strip().lstrip("#").split()).casefold()


def insert_note(text, heading, note):
    """`text` with `note` as the last line under `## heading`, which is added if missing."""
    lines = text.splitlines()
    want = norm(heading)
    start = next((i for i, ln in enumerate(lines)
                  if ln.startswith("## ") and norm(ln) == want), None)
    if start is None:
        while lines and not lines[-1].strip():
            lines.pop()
        lines += ["", f"## {heading.strip().lstrip('#').strip()}", note]
        return "\n".join(lines).lstrip("\n") + "\n"
    end = next((i for i in range(start + 1, len(lines)) if re.match(r"#{1,2} ", lines[i])),
               len(lines))
    while end > start + 1 and not lines[end - 1].strip():
        end -= 1
    lines.insert(end, note)
    return "\n".join(lines) + "\n"


def note(a):
    text = " ".join(a.text.split())
    if not norm(a.heading) or not text:
        sys.exit("note needs --heading and --text, like --text \"[S2] <one fact> (page)\"")
    known = {s["key"] for s in load()}
    bad = sorted({k for k in re.findall(r"\[(S\d+)\]", text)} - known, key=num)
    if bad:
        sys.exit(f"Not in the ledger: {', '.join(bad)}. Add the source first, or use one of: "
                 f"{', '.join(sorted(known, key=num)) or 'none yet'}")
    old = open(a.file, encoding="utf-8").read() if os.path.exists(a.file) else "# Notes\n"
    os.makedirs(os.path.dirname(a.file) or ".", exist_ok=True)
    with open(a.file, "w", encoding="utf-8") as f:
        f.write(insert_note(old, a.heading, text if text.startswith("- ") else f"- {text}"))
    print(f"added to {a.file} under ## {a.heading.strip().lstrip('#').strip()}")


def refs(a):
    by_key = {s["key"]: s for s in load()}
    with open(a.draft, encoding="utf-8") as f:
        lines = f.read().splitlines()
    head = next((i for i, ln in enumerate(lines)
                 if ln.startswith("## ") and norm(ln) in REF_HEADINGS), None)
    body = lines if head is None else lines[:head]
    cited = sorted({k for k in re.findall(r"\[(S\d+)\]", "\n".join(body))} & by_key.keys(), key=num)
    out = []
    for k in cited:
        s = by_key[k]
        out.append(f"- [{k}] {', '.join(s.get('authors') or []) or 'Unknown author'} "
                   f"({s.get('year') or 'n.d.'}). {s['title']}. {s['url']}")
    if head is None:
        while body and not body[-1].strip():
            body.pop()
        new = body + ["", "## References"] + out
    else:
        end = next((i for i in range(head + 1, len(lines)) if lines[i].startswith("## ")),
                   len(lines))
        new = lines[:head + 1] + out + ([""] + lines[end:] if end < len(lines) else [])
    with open(a.draft, "w", encoding="utf-8") as f:
        f.write("\n".join(new) + "\n")
    print(f"wrote {len(out)} references to {a.draft}")


def body_words(lines):
    """Words a reader reads: no headings, no keys, nothing from References on."""
    n = 0
    for raw in lines:
        if raw.startswith("## ") and norm(raw) in REF_HEADINGS:
            break
        if not raw.lstrip().startswith("#"):
            n += len(re.findall(r"\b\w[\w'-]*\b", re.sub(r"\[S\d+\]", "", raw)))
    return n


def check(a):
    known = {s["key"] for s in load()}
    cited, bad, todo = [], [], []
    in_fence = in_refs = False
    with open(a.draft, encoding="utf-8") as f:
        lines = f.read().splitlines()
    for n, raw in enumerate(lines, 1):
        if raw.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if raw.startswith("#"):
            in_refs = norm(raw) in REF_HEADINGS
            continue
        if raw.lstrip().startswith("TODO"):
            todo.append(str(n))
        text = re.sub(r"`[^`\n]*`", "", raw)
        ref = re.match(r"^\s*[-*]\s*\[S(\d+)\]", text)
        if in_refs and ref:
            k = f"S{ref.group(1)}"
            if k not in known and k not in bad:
                bad.append(k)
            continue
        for k in re.findall(r"\[S(\d+)\]", text):
            if f"S{k}" not in cited:
                cited.append(f"S{k}")
    missing = [k for k in cited if k not in known]
    orphans = sorted((k for k in known if k not in cited), key=num)
    words, short = body_words(lines), ""
    if a.words:
        lo, hi = map(int, a.words.split("-"))
        if not lo <= words <= hi:
            short = f"{words} words, want {lo} to {hi}. Lengthen or cut the sections."
    ok = not missing and not bad and not todo and not short
    print("PASS" if ok else "FAIL")
    print(f"Words: {words}")
    if todo:
        print(f"TODO lines left (not allowed), line: {', '.join(todo)}")
    if short:
        print(f"Length: {short}")
    for label, keys in [("Cited", cited), ("Missing from ledger (not allowed)", missing),
                        ("Bad references (not in ledger)", bad),
                        ("Orphans (in ledger, never cited)", orphans)]:
        if keys:
            print(f"{label}: {', '.join(keys)}")
    if not ok:
        sys.exit(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("add")
    a.add_argument("--url", required=True)
    a.add_argument("--title", required=True)
    a.add_argument("--relevance", type=int)
    a.add_argument("--authors")
    a.add_argument("--year", type=int)
    a.add_argument("--doi")
    a.add_argument("--note")
    a.set_defaults(fn=add)
    sub.add_parser("list").set_defaults(fn=list_sources)
    n = sub.add_parser("note")
    n.add_argument("--heading", required=True)
    n.add_argument("--text", required=True)
    n.add_argument("--file", default=NOTES)
    n.set_defaults(fn=note)
    r = sub.add_parser("refs")
    r.add_argument("draft")
    r.set_defaults(fn=refs)
    c = sub.add_parser("check")
    c.add_argument("draft")
    c.add_argument("--words", help="MIN-MAX body words, like 500-700")
    c.set_defaults(fn=check)
    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
