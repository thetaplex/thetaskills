---
name: weekly-review
description: Turns notes, inbox items and goals into Docket items and a written daily or weekly action plan in docket/plans/, ordered by priority, with dates and .ics invites. Use when the user asks to triage notes or an inbox, plan the week or the day, review open tasks, or build an action plan or to-do list.
---
# Weekly review and action plan

File: `docket/plans/<slug>.md`. Use the path the user gives, if any.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- The Docket: `python3 <skills>/manage-docket/scripts/docket.py list`, `add`, `update` and `ics`. The manage-docket skill lists the options.
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <file>`

## 1. Collect

1. Read each notes or inbox file the user names. If they name none, list the folder and read the notes files.
2. Run `docket.py list` to see what is already there.

## 2. Triage each line into the Docket

Go through the notes one line at a time. Skip a line that the Docket already has.

| The line is | Run |
|---|---|
| Something to do | `docket.py add --title "..."`, with `--priority 3` if urgent, and `--due` if it has a date. |
| A meeting or a deadline with a date | `docket.py add --kind event --title "..." --due ...`, then `docket.py ics` with `--title`, `--start` and `--end`. |
| A choice already made | `docket.py add --kind decision --title "..."` |
| Done already | `docket.py update D# --status done` |

Note each key the script prints, like [D3].

## 3. Write the plan

Create the file with this shape:

```markdown
# Action plan, week of <YYYY-MM-DD>

## Top priorities
- [D#] <title>, due <YYYY-MM-DD>

## Schedule
- <YYYY-MM-DD HH:MM> [D#] <title>. Invite: docket/calendar/<file>.ics

## Open tasks
- [D#] <title>, due <YYYY-MM-DD>

## Decisions and notes
- [D#] <decision or note>
```

Top priorities holds the priority 3 items. Order each section by date, soonest first.

## 4. Check and report

1. Read the file back, to check that you wrote it.
2. Run the style check on the plan. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the top priorities, and the style check result.

## Rules

- Use only keys that the Docket script printed.
- Dates as YYYY-MM-DD.
- Short sentences, active voice (write-ste skill).
