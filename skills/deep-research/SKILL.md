---
name: deep-research
description: Research loop behind a sourced document. Splits the question into sub-questions, searches each one, registers sources in a ledger, writes notes with source keys, then hands over to a writing skill. Use when the user asks for a paper, proposal, report, brief, essay or literature review, or when an answer needs many sources. For one quick fact, use research-method.
---
# Deep research

Your context is short. The files are your memory. Write a note right after each page you read.

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- Register a source: `python3 <skills>/source-triage/scripts/sources.py add --url <url> --title "<title>" --relevance <1-5>`. It prints the key, like `[S3]`.
- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`

## 1. Start the draft

Use the writing skill for the request, and do only its step 1 (the skeleton):

- brief or one-pager: write-brief
- report or evaluation: write-report
- paper or literature review: write-research-paper
- proposal: write-research-proposal
- essay or op-ed: write-essay
- book chapter: write-book-chapter

## 2. Split the question

Write 3 sub-questions that together answer the request. Each one has its own answer.
If `research/notes.md` does not exist, create it:

```markdown
# Notes

## Q1 <sub-question 1>

## Q2 <sub-question 2>

## Q3 <sub-question 3>
```

## 3. Research each sub-question

Do these steps for Q1, Q2 and Q3:

1. Search the web with one query in the words of the sub-question.
2. Pick the 2 best results: a paper, standard, official page or dataset before a blog or news. Register each one, with `relevance` from 1 to 5.
3. Open the best one. If that fails, open the second one.
4. Add 1 to 3 notes under the sub-question heading in `research/notes.md`, one line per note: `- [S2] <one fact> (section or page)`.

A note is one fact and its key. It is not a summary of the page. Write it right after you read the page.

## 4. Check the gaps

Read `research/notes.md`. A sub-question with no note gets one more search, in other words. Then stop searching, even if gaps stay open. Write each gap under its heading as `- Open: <what is missing>`.

## 5. Write the draft

Go back to the writing skill and do step 2 and the rest. Write from the notes.

## Rules

- Use only keys that the sources script printed. Never invent a source or a key.
- If a page does not open, take the next result. Never repeat a failed call unchanged.
- No evidence for a point: write `- Open:` in the notes. Do not fill the gap from memory.
