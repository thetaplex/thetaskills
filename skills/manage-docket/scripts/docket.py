#!/usr/bin/env python3
"""Docket of tasks, events, decisions and notes: docket/docket.json in the current folder.
Every change also rewrites docket/DOCKET.md.

  docket.py add --title T [--kind task|event|decision|note] [--priority 1-3] [--due DATE]
                [--detail D]          prints the key, like [D3]; an open item with the same
                                      kind and title prints the existing key
  docket.py update D3 [--status open|done|cancelled] [--priority N] [--due DATE]
                [--title T] [--detail D]
  docket.py list                      open first, then priority 3 to 1, then due date
  docket.py ics --title T --start 2026-11-25T10:00 [--end ...] [--location L]
                [--description D] [--filename F]   writes docket/calendar/<slug>.ics

DATE is YYYY-MM-DD or YYYY-MM-DDTHH:MM. Priority 3 is urgent, 2 normal, 1 low.
"""
import argparse
import datetime
import json
import os
import re
import sys

JSON = os.path.join("docket", "docket.json")
MD = os.path.join("docket", "DOCKET.md")
STATUS = ("open", "done", "cancelled")


def load():
    if not os.path.exists(JSON):
        return []
    with open(JSON, encoding="utf-8") as f:
        text = f.read().strip()
    return json.loads(text) if text else []


def num(key):
    m = re.fullmatch(r"\[?[Dd](\d+)\]?", key.strip())
    return int(m.group(1)) if m else 0


def order(items):
    return sorted(items, key=lambda i: (STATUS.index(i["status"]), -i["priority"],
                                        i.get("due") or "9999", num(i["key"])))


def line(i):
    due = f" (due: {i['due']})" if i.get("due") else ""
    detail = f" - {i['detail']}" if i.get("detail") else ""
    return f"{i['key']} [{i['kind']} | {i['status']} | p{i['priority']}] {i['title']}{due}{detail}"


def save(items):
    os.makedirs("docket", exist_ok=True)
    with open(JSON + ".tmp", "w", encoding="utf-8") as f:
        json.dump(items, f, indent=2, ensure_ascii=False)
    os.replace(JSON + ".tmp", JSON)
    out = ["# Docket", ""]
    for st in STATUS:
        group = [i for i in order(items) if i["status"] == st]
        if group:
            out.append(f"## {st.capitalize()}")
            out += [f"- [{'x' if st == 'done' else ' '}] {line(i)}" for i in group]
            out.append("")
    with open(MD, "w", encoding="utf-8") as f:
        f.write("\n".join(out if items else out + ["No items recorded."]) + "\n")


def date(raw):
    """YYYY-MM-DD -> (YYYYMMDD, True); YYYY-MM-DDTHH:MM[:SS] -> (YYYYMMDDTHHMMSS, False)."""
    d = re.sub(r"\D", "", raw)
    if len(d) == 8:
        return d, True
    if len(d) in (12, 14):
        return f"{d[:8]}T{d[8:12]}{d[12:] or '00'}", False
    sys.exit(f"bad date '{raw}': use YYYY-MM-DD or YYYY-MM-DDTHH:MM")


def add(a):
    items = load()
    for i in items:
        if i["kind"] == a.kind and i["title"].lower() == a.title.lower() and i["status"] == "open":
            print(f"exists {line(i)}")
            return
    if a.due:
        date(a.due)
    i = {"key": f"[D{max((num(x['key']) for x in items), default=0) + 1}]", "kind": a.kind,
         "title": a.title, "status": "open", "priority": max(1, min(3, a.priority)),
         "due": a.due, "detail": a.detail, "created_at": datetime.date.today().isoformat()}
    items.append(i)
    save(items)
    print(f"added {line(i)}")


def update(a):
    items = load()
    hit = [i for i in items if num(i["key"]) == num(a.key)]
    if not hit:
        sys.exit(f"no item {a.key}. Run: docket.py list")
    i = hit[0]
    for k in ("status", "due", "title", "detail"):
        if getattr(a, k):
            i[k] = getattr(a, k)
    if a.priority:
        i["priority"] = max(1, min(3, a.priority))
    save(items)
    print(f"updated {line(i)}")


def list_items(_):
    items = order(load())
    print("\n".join(map(line, items)) if items else "No items recorded.")


def esc(s):
    return s.replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,").replace("\n", "\\n")


def slug(s):
    return "-".join(re.findall(r"[a-z0-9]+", s.lower())) or "event"


def ics(a):
    start, all_day = date(a.start)
    val = ";VALUE=DATE" if all_day else ""
    lines = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//thetaskills//docket//EN",
             "CALSCALE:GREGORIAN", "BEGIN:VEVENT",
             f"UID:{slug(a.title + '-' + a.start)}@docket",
             f"DTSTAMP:{datetime.datetime.now(datetime.timezone.utc):%Y%m%dT%H%M%SZ}",
             f"DTSTART{val}:{start}"]  # local (floating) time
    if a.end:
        end, end_day = date(a.end)
        lines.append(f"DTEND{';VALUE=DATE' if end_day else ''}:{end}")
    lines.append(f"SUMMARY:{esc(a.title)}")
    if a.location:
        lines.append(f"LOCATION:{esc(a.location)}")
    if a.description:
        lines.append(f"DESCRIPTION:{esc(a.description)}")
    lines += ["END:VEVENT", "END:VCALENDAR"]
    path = os.path.join("docket", "calendar", slug((a.filename or a.title).removesuffix(".ics")) + ".ics")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write("\r\n".join(lines) + "\r\n")
    print(f"wrote {path}")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("add")
    a.add_argument("--title", required=True)
    a.add_argument("--kind", default="task", choices=["task", "event", "decision", "note"])
    a.add_argument("--priority", type=int, default=2)
    a.add_argument("--due")
    a.add_argument("--detail")
    a.set_defaults(fn=add)
    u = sub.add_parser("update")
    u.add_argument("key")
    u.add_argument("--status", choices=STATUS)
    u.add_argument("--priority", type=int)
    u.add_argument("--due")
    u.add_argument("--title")
    u.add_argument("--detail")
    u.set_defaults(fn=update)
    sub.add_parser("list").set_defaults(fn=list_items)
    c = sub.add_parser("ics")
    c.add_argument("--title", required=True)
    c.add_argument("--start", required=True)
    for k in ("end", "location", "description", "filename"):
        c.add_argument(f"--{k}")
    c.set_defaults(fn=ics)
    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
