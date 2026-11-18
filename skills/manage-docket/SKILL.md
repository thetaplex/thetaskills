---
name: manage-docket
description: Records and updates tasks, events, decisions and notes on a project Docket (docket/docket.json and docket/DOCKET.md) with a bundled script, and exports events as .ics calendar files. Use when the user asks to add a task, set a reminder or deadline, schedule a meeting, log a decision, mark something done, or make a calendar invite.
---
# Manage the Docket

The Docket holds every task, event, decision and note. It lives in `docket/docket.json`, and the script keeps `docket/DOCKET.md` up to date. Change it only with the script.

Run the script from the project folder: `python3 <this skill's folder>/scripts/docket.py <command>`.

## 1. Look first

Run `docket.py list`. If an item already exists, update it. Do not add it twice.

## 2. Add each new item

Run `docket.py add` once per item:

| Option | Value |
|---|---|
| `--kind` | `task` (the default), `event`, `decision` or `note` |
| `--title` | A short phrase, like `"Renew the TLS certificate"` |
| `--priority` | A number: `3` urgent or high, `2` normal (the default), `1` low |
| `--due` | `2026-11-24` or `2026-11-25T10:00` |
| `--detail` | The owner, the context, or the reason for a decision |

It prints the key, like `[D1]`. Note it. You need it later.

## 3. Change an item

Run `docket.py update D1` with only the options that change: `--status` (`open`, `done`, `cancelled`), `--priority`, `--due`, `--title` or `--detail`.

## 4. Export an event

The `ics` command does not add the event to the Docket. First add it with `--kind event`. Then, for each event with a date or a time, run `docket.py ics`:

- `--title`, and `--start` like `2026-11-25T10:00`
- `--end`: for "1 hour from 10:00", give `2026-11-25T11:00`
- `--location` and `--description` if you have them

It writes a `.ics` file in `docket/calendar/` that Apple Calendar, Outlook and Google Calendar open. Times are local time.

## 5. Report

Reply with each key and its title, and the path of each `.ics` file.

## Rules

- Never edit `docket/docket.json` or `docket/DOCKET.md` by hand.
- `--priority` is a number, not a word.
- Name Docket items by key, like [D1], in every plan, memo and reply.
