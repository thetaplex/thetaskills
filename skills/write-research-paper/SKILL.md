---
name: write-research-paper
description: Drafts a research paper of 3000 to 5000 words (abstract, background, method, findings, discussion, limitations), with a source key on every fact. Use when the user asks for a research paper, an academic paper, a literature review, a survey or a short paper. To plan future work, use write-research-proposal. For a report to a decision maker, use write-report.
---
# Write a research paper

File: `research/drafts/<slug>-paper.md`. Length: 3000 to 5000 words. A "short paper" is 1500 to 2500.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <draft>`

## 1. Write the skeleton now

Create the file with this text. Change only the title.

```markdown
# <Title>

## Abstract
TODO abstract: 4 to 6 sentences. The question, the method, the findings.

## Background
TODO background: 300 to 600 words. What is known. Each fact has a key.

## Method
TODO method: 150 to 300 words. How you searched, what you kept and why.

## Findings
TODO findings: 3 to 5 subsections (### Finding 1 ...), 300 to 600 words each. Each fact has a key.

## Discussion
TODO discussion: 300 to 600 words. What the findings mean. Where the sources disagree.

## Limitations
TODO limitations: 100 to 200 words. What you could not check, and what is missing.

## References
TODO references
```

## 2. Check the sources

List the sources. If there are fewer than 5, use the deep-research skill to get more. Then come back to step 3.

## 3. Fill one section at a time

Replace one whole TODO line with the section text. One section per edit. For the findings, do one finding per edit, and keep the TODO line under the new text until the last finding.
Order: background, method, findings, discussion, limitations, abstract.
Write only facts from `research/notes.md` or from pages you read.
After a break or a context reset: read the draft, then go on at the first TODO line.

## 4. Fill the references

Replace `TODO references` with one line per key you cited: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Run the style check. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the findings in one line each, and the result of both checks.

## Rules

- A key is what the sources script printed, like [S3]. Put it after the fact: `... in 2024 [S3].` Two keys: `[S1][S4]`.
- Never write a key that the source list does not show.
- A fact without a key: cut it, or write it as an open question.
- At most 6 sentences per paragraph. Short sentences, active voice, simple words (write-ste skill).
