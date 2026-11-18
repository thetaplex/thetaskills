---
name: research-method
description: Answers one factual question from sources. Frames it, searches, reads the primary source, registers it in a source ledger and answers with source keys. Use when the user asks a factual question, wants something looked up, checked or compared, or asks "what does the evidence say" about one point. For a full paper, report or proposal, use deep-research.
---
# Research method

## Tools

Run these from the project folder. Replace `<skills>` with the folder that holds this skill's folder.

- Register a source: `python3 <skills>/source-triage/scripts/sources.py add --url <url> --title "<title>" --relevance <1-5>`. It prints the key, like `[S3]`.
- List the sources: `python3 <skills>/source-triage/scripts/sources.py list`

## 1. Frame the question

Write one sentence: what you want to know. Write one more: what evidence would settle it (a number, a date, a rule, a study result).

## 2. Search

1. Search the web with 1 broad query.
2. If the results show better terms (a name, a standard, a study title), search once more with those terms.
3. Stop after 3 searches in a row that add nothing new.

## 3. Pick and read

Prefer, in this order: a paper, a standard, an official page or documentation, a dataset. Use news or a blog only to find the primary source.

- A DOI: open `https://doi.org/<doi>`.
- A web page or PDF: open it.

Register each source you use, with `relevance` from 1 to 5 (5 = a primary source that answers the question).

## 4. Note what you learned

Right after you read, add 1 to 3 notes to `research/notes.md`, one fact per line: `- [S2] <one fact> (section or page)`.
Put them under a heading `## <your question>`. Create the file with `# Notes` if it does not exist.

## 5. Answer

- A factual answer needs 2 sources that agree, or 1 primary source.
- Give the answer in 1 to 5 sentences, each fact with its key, like [S2].
- If the sources disagree, give both claims with both keys.
- If you found no evidence, say so. Do not answer from memory.

## Rules

- Use only keys that the sources script printed. Never invent a reference.
- If a page does not open, try the next result. Never repeat a failed call unchanged.
