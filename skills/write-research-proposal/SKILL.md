---
name: write-research-proposal
description: Drafts a research proposal of 1500 to 2500 words (problem, prior work, aims, method, timeline, risks), with a source key on every fact. Use when the user asks for a research proposal, a grant proposal, a project proposal, a study plan or a thesis proposal. For finished work, use write-research-paper or write-report.
---
# Write a research proposal

File: `research/drafts/<slug>-proposal.md`. Length: 1500 to 2500 words.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <draft>`

## 1. Write the skeleton now

Create the file with this text. Change only the title.

```markdown
# <Title>

## Summary
TODO summary: 3 to 5 sentences. The problem, the aims, the method.

## Problem
TODO problem: 200 to 400 words. What is unknown or broken, and why it matters. Each fact has a key.

## Prior work
TODO prior work: 300 to 500 words. What others did, with keys. The gap that is left.

## Aims
TODO aims: 2 to 4 numbered aims. One sentence each.

## Method
TODO method: 400 to 700 words. For each aim: the work, the data or tools, and how you know it worked.

## Timeline
TODO timeline: a table with the columns Phase, Months, Output.

## Risks
TODO risks: 2 to 4 bullets. What can fail, and what you will do then.

## References
TODO references
```

## 2. Check the sources

List the sources. If there are fewer than 4, use the deep-research skill to get more. Then come back to step 3.

## 3. Fill one section at a time

Replace one whole TODO line with the section text. One section per edit, in this order: problem, prior work, aims, method, timeline, risks, summary.
Write only facts from `research/notes.md` or from pages you read. The aims, method, timeline and risks are a plan, so they need no keys.
After a break or a context reset: read the draft, then go on at the first TODO line.

## 4. Fill the references

Replace `TODO references` with one line per key you cited: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Run the style check. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the aims, and the result of both checks.

## Rules

- A key is what the sources script printed, like [S3]. Put it after the fact: `... in 2024 [S3].`
- Never write a key that the source list does not show.
- A fact without a key: cut it, or write it as an open question.
- At most 6 sentences per paragraph. Short sentences, active voice, simple words (write-ste skill).
