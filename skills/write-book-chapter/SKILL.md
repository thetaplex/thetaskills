---
name: write-book-chapter
description: Drafts one book chapter, part by part, from the chapter's research file, in the author's voice, with a source key on every fact. Use when the user asks to write, draft or continue a chapter of a book, fiction or non-fiction. To research the book first, use book-research.
---
# Write a book chapter

Input: `research/book/brief.md` and `research/book/chapters/NN-slug.md`.
File: `research/drafts/NN-slug-chapter.md`. Length: what the brief says, else 3000 to 5000 words.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`
- Check the keys: `python3 <skills>/source-triage/scripts/sources.py check <draft>`

## 1. Read first

1. Read the brief. Note the reader, the voice, and fiction or non-fiction.
2. Read the chapter file. Its `## Learnings` lines are your facts.
3. If the author gave sample text, read it and match its voice.
4. If the chapter file has fewer than 5 learnings, stop. Tell the author to run book-research on the chapter first.

## 2. Write the skeleton

Plan 4 to 8 parts. A part is one scene (fiction) or one point (non-fiction). Create the file:

```markdown
# NN Chapter title

TODO part 1: <one line: what happens or what the reader learns>. 500 to 800 words.

TODO part 2: <one line>. 500 to 800 words.

<one TODO line per part>

## Sources
TODO sources
```

## 3. Fill one part at a time

Replace one whole TODO line with the part text. One part per edit, from top to bottom. Read the part before it first, so the next one follows on.
After a break or a context reset: read the draft, then go on at the first TODO line.

- Non-fiction: put the key after the fact, like `... in 1861 [S4].`
- Fiction: no keys in the story. The facts about the period, the place and the people must come from the learnings.
- Never add a fact that is not in the learnings. If the story needs one, write `[CHECK: <what>]` and go on.

## 4. Fill the sources

Replace `TODO sources` with one line per key you used: `- [S1] Authors (Year). Title. URL`. Copy the details from the source list.

## 5. Check and report

1. Run the key check. If it says FAIL, change each bad key to a key from the list, or cut the claim. Run it again.
2. Add each `[CHECK: ...]` item to `## Still open` in the chapter file.
3. Reply with the path, the word count, and the open `[CHECK]` items.

## Rules

- The author owns the voice. Write in the voice of the brief or the sample text, not in a technical style.
- Use only keys that the source list shows.
