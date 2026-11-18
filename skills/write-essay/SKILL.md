---
name: write-essay
description: Drafts an argued essay of 800 to 1200 words (thesis, arguments, the strongest objection, conclusion), with a source key on every fact. Use when the user asks for an essay, an op-ed, an opinion piece, an argument, a position piece or a long-form article. For neutral findings, use write-report.
---
# Write an essay

File: `research/drafts/<slug>-essay.md`. Length: what the request says, else 800 to 1200 words for a general reader.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`
- Check the style: `python3 <skills>/write-ste/scripts/check_style.py <draft>`

## 1. Write the skeleton now

Create the file with this text. Change only the title. The TODO lines become paragraphs. An essay has no headings except the title and References.

```markdown
# <Title>

TODO opening: 1 paragraph. The question, then the thesis in 1 sentence.

TODO argument 1: 1 paragraph, 100 to 150 words. Claim first, then evidence with keys, then what it shows.

TODO argument 2: 1 paragraph, 100 to 150 words. Same shape.

TODO argument 3: 1 paragraph, 100 to 150 words. Same shape.

TODO objection: 1 or 2 paragraphs. The strongest case against the thesis, with its key, then your answer.

TODO conclusion: 1 paragraph. What follows if the thesis holds. No new claims.

## References
TODO references
```

## 2. Check the sources

List the sources. If there are fewer than 4, use the deep-research skill to get more. Then come back to step 3.

## 3. Fill one paragraph at a time

Replace one whole TODO line with the paragraph. One paragraph per edit, from top to bottom. If you have evidence for only 2 arguments, use 2 and delete the third TODO line.
Write only facts from `research/notes.md` or from pages you read.
After a break or a context reset: read the draft, then go on at the first TODO line.

## 4. Fill the references

Replace `TODO references` with one line per key you cited: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Run the style check. Fix each reported line with one edit. Run it once more.
3. Reply with the path, the thesis, and the result of both checks.

## Rules

- A key is what the sources script printed, like [S3]. Put it after the fact: `... in 2024 [S3].`
- Never write a key that the source list does not show.
- A claim without a key is your opinion. Say so ("I think"), or cut it.
- At most 6 sentences per paragraph. Short sentences, active voice, simple words (write-ste skill).
