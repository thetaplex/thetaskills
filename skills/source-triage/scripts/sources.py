#!/usr/bin/env python3
"""Source ledger for sourced writing: research/sources.json in the current folder.

  sources.py add --url URL --title TITLE [--relevance 1-5] [--authors "A, B"] [--year Y]
                 [--doi DOI] [--note NOTE]     prints the key, like [S3]; a known url or doi
                                               prints the existing key
  sources.py list                              one line per source, highest relevance first
  sources.py check DRAFT.md                    every [S#] in the draft must be in the ledger;
                                               exits 1 on FAIL
"""
import argparse
import datetime
import json
import os
import re
import sys

LEDGER = os.path.join("research", "sources.json")


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


def check(a):
    known = {s["key"] for s in load()}
    cited, bad = [], []
    in_fence = in_refs = False
    with open(a.draft, encoding="utf-8") as f:
        for raw in f:
            if raw.lstrip().startswith("```"):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            if raw.startswith("#"):
                in_refs = raw.lstrip("#").strip().lower() == "references"
                continue
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
    ok = not missing and not bad
    print("PASS" if ok else "FAIL")
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
    c = sub.add_parser("check")
    c.add_argument("draft")
    c.set_defaults(fn=check)
    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
