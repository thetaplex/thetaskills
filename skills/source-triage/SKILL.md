---
name: source-triage
description: Judges search results before reading them. Scores each result 1 to 5, registers the keepers in a source ledger (research/sources.json) and reads the best first. Use when a web search returned many results, when deciding which sources to trust, read or cite, or when the ledger holds more sources than you can read.
---
# Source triage

## Tools

Run these from the project folder.

- Register a source: `python3 <this skill's folder>/scripts/sources.py add --url <url> --title "<title>" --relevance <1-5>`. Add `--authors "A, B"`, `--year`, `--doi` or `--note` if you know them. It prints the key, like `[S3]`. A known url or DOI prints the key it already has.
- List the sources, best first: `python3 <this skill's folder>/scripts/sources.py list`
- Add a note: `python3 <this skill's folder>/scripts/sources.py note --heading "<heading>" --text "[S2] <one fact> (page)"`. It adds the line under `## <heading>` in `research/notes.md` (`--file` for another file). It refuses a key that the ledger does not have.
- Write a draft's references: `python3 <this skill's folder>/scripts/sources.py refs <draft.md>`
- Check a draft: `python3 <this skill's folder>/scripts/sources.py check <draft.md> [--words MIN-MAX]`. It checks the keys, the TODO lines and the length.

## 1. Score each result 1 to 5

| Score | The result is |
|---|---|
| 5 | A primary source that answers the question: paper, dataset, standard, official report. |
| 4 | A primary source on part of the question, or a review or textbook that cites primary sources. |
| 3 | Useful background from a named author or organization. |
| 2 | Off to the side, or a weak site on a relevant point. |
| 1 | Off topic, opinion, advertising, or no author. Skip it. |

Quick signs:

- Strong site: university, publisher, standards body, government, the project's own site.
- Weak site: content farm, unknown blog, a page that only sells something.
- Date: is it recent enough for the question? An old source is fine for history.
- Opinion never supports a factual claim.

## 2. Register the keepers

Register each result with a score of 2 or more. Use the title from the search result and the score as `--relevance`. Registering is cheap. Do it before you read.

## 3. Read the best first

1. List the sources. The list shows the highest relevance first.
2. Read the 5s and 4s first, then the 3s.
3. Right after you read, add each fact with the note command: `--heading` is the question, like `Q1 ...`, and `--text` is `[S2] <one fact> (section or page)`.

## 4. Cite from the top

When you write the draft, cite the highest scores first. Use a source with a score under 3 only when it is the only support for a claim.
