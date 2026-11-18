---
name: write-brief
description: Drafts a 500 to 700 word brief that gives a busy reader one key message, three findings and a recommendation, with a source key on every fact. Use when the user asks for a brief, a policy brief, an executive brief or a one-pager for a decision. For any report, even a short one, use write-report.
---
# Write a brief

File: `research/drafts/<slug>-brief.md`. Length: 500 to 700 words.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <draft>`

## 1. Write the skeleton now

Create the file with this text. Change only the title.

```markdown
# <Title>

## Key message
TODO key message: 1 sentence. The answer the reader needs.

## Findings
TODO findings: 3 bullets, 20 to 40 words each. Each bullet has a key.

## Recommendation
TODO recommendation: 50 to 100 words. What to do, and why.

## Evidence
TODO evidence: 150 to 250 words. The facts behind the findings.

## References
TODO references
```

## 2. Check the sources

List the sources. If there are fewer than 3, use the deep-research skill to get more. Then come back to step 3.

## 3. Fill one section at a time

Replace one whole TODO line with the section text. One section per edit, in this order: evidence, findings, recommendation, key message.
Write only facts from `research/notes.md` or from pages you read.
After a break or a context reset: read the draft, then go on at the first TODO line.

## 4. Fill the references

Replace `TODO references` with one line per key you cited: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Run the style check. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the key message, and the result of both checks.

## Rules

- A key is what the sources script printed, like [S3]. Put it after the fact: `... in 2024 [S3].`
- Never write a key that the source list does not show.
- A fact without a key: cut it, or write it as an open question.
- At most 6 sentences per paragraph. Short sentences, active voice, simple words (write-ste skill).
