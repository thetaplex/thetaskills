---
name: book-research
description: Researches a book over many sessions. The first session asks the author intake questions and sets up one research file per chapter. Each later session answers 2 to 4 questions for one chapter and adds them to the research corpus with source keys. Use when the user is writing a book, fiction or non-fiction, and wants research, fact-checking or background for it. To write chapter text, use write-book-chapter.
---
# Book research

The corpus lives in `research/book/`. Breadth comes from many sessions, not from one.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- Register a source: `python3 <skills>/source-triage/scripts/sources.py add --url <url> --title "<title>" --relevance <1-5>`. It prints the key, like `[S3]`.
- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`

## First session: intake

If `research/book/brief.md` does not exist, do not search yet. Ask the author these questions in one message, then stop and wait:

1. Fiction or non-fiction? For fiction: the period, the place, and what must feel true to a reader who knows it.
2. The premise or argument in 2 sentences, and who the reader is.
3. The chapter list, or the best guess for now.
4. What research exists already: files, sources to start from, people to interview.
5. Any source to avoid.

When the author answers:

1. Write `research/book/brief.md` with the answers.
2. For each chapter, write `research/book/chapters/NN-slug.md`:

   ```markdown
   # NN Chapter title

   ## Questions
   - <3 to 6 questions this chapter must answer>

   ## Learnings

   ## Still open
   ```

3. Ask the author to correct the questions. Stop.

## Every later session

1. Read `brief.md`, and `research/book/open-questions.md` if it exists. Take the chapter the author names. Else take the one with the most open questions.
2. Pick 2 to 4 of that chapter's questions.
3. For each question: search the web, register the 2 best results, open the best one.
4. Right after you read, add the facts under `## Learnings`, one line per fact: `- [S2] <one fact> (page, section or timestamp)`.
5. Facts that many chapters use go once into `research/book/timeline.md`, `people.md`, `places.md` or `terms.md`. One line per entry, with the key.
6. Two sources disagree: write both claims with both keys under `## Still open`. The author decides.
7. Prefer primary sources: records, letters, datasets, the original study. A secondary source gets a lower relevance.
8. Rewrite `research/book/open-questions.md`: every open question, by chapter.
9. Reply in at most 5 lines: what the chapter has now, and what it still lacks.

## Rules

- Use only keys that the sources script printed. Never invent a source.
- The ledger is shared by the whole book. A source registered for one chapter is ready for the next.
