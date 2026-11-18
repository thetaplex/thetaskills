---
name: write-report
description: Drafts a research report of 2000 to 4000 words with an executive summary, scope, findings, analysis and recommendations, with a source key on every fact. Use when the user asks for a report of any length, a short or technical report, a research report, an evaluation, a review of options or a state-of-the-art summary. For 1 or 2 pages for a decision, use write-brief. For an academic paper, use write-research-paper.
---
# Write a report

File: `research/drafts/<slug>-report.md`. Length: 2000 to 4000 words.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <draft>`

## 1. Write the skeleton now

Create the file with this text. Change only the title.

```markdown
# <Title>

## Executive summary
TODO summary: 100 to 200 words. The question, the main findings, the main recommendation.

## Scope
TODO scope: 100 to 200 words. What the report covers, what it leaves out, how you found the sources.

## Findings
TODO findings: 3 to 5 subsections (### Finding 1 ...), 200 to 400 words each. Each fact has a key.

## Analysis
TODO analysis: 300 to 600 words. What the findings mean together. Where the sources agree and disagree.

## Recommendations
TODO recommendations: 3 to 5 numbered items. Each item says who does what.

## Limitations
TODO limitations: 100 to 200 words. What you could not check, and what is missing.

## References
TODO references
```

## 2. Check the sources

List the sources. If there are fewer than 5, use the deep-research skill to get more. Then come back to step 3.

## 3. Fill one section at a time

Replace one whole TODO line with the section text. One section per edit. For the findings, do one finding per edit, and keep the TODO line under the new text until the last finding.
Order: scope, findings, analysis, recommendations, limitations, executive summary.
Write only facts from `research/notes.md` or from pages you read.
After a break or a context reset: read the draft, then go on at the first TODO line.

## 4. Fill the references

Replace `TODO references` with one line per key you cited: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Run the style check. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the findings in one line each, and the result of both checks.

## Rules

- A key is what the sources script printed, like [S3]. Put it after the fact: `... in 2024 [S3].`
- Never write a key that the source list does not show.
- A fact without a key: cut it, or write it as an open question.
- At most 6 sentences per paragraph. Short sentences, active voice, simple words (write-ste skill).
