---
name: draft-communication
description: Drafts an email, memo, invitation, meeting agenda or status update as a Markdown file in docket/drafts/, with a clear subject, the purpose first, action items with owners and dates, and Docket keys. Use when the user asks to write, draft or prepare an email, memo, invite, agenda, announcement or status summary.
---
# Draft a communication

File: `docket/drafts/<slug>.md`. Use the path the user gives, if any. Length: 100 to 300 words.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- The Docket: `python3 <skills>/manage-docket/scripts/docket.py list`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <file>`

## 1. Gather the facts

1. Run `docket.py list`. Note the `[D#]` keys of the items this message is about.
2. Read the files the user names.
3. Need an outside fact (an address, opening hours, a price)? Search the web, then open the official page. Use only what the page says.

## 2. Write the file

Create the file with this shape:

```markdown
To: <people or team>
Date: <YYYY-MM-DD>
Subject: <specific subject, like "Architecture review on 2026-11-25 at 10:00">

<1 or 2 sentences: the purpose, the request or the decision.>

## Details
- <one fact per line, with its [D#] key>

## Action items
- <owner>: <what to do> by <YYYY-MM-DD> [D#]
```

For an agenda, put `## Agenda` with numbered items and times before Action items.

## 3. Check and report

1. Read the file back, to check that you wrote it.
2. Run the style check on the file. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the subject line, and the style check result.

## Rules

- Name every Docket item by its key, like [D1]. Use only keys that the Docket list shows.
- Dates as YYYY-MM-DD. Times as HH:MM.
- Short sentences, active voice, simple words (write-ste skill). No contractions, no semicolons.
