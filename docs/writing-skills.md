# How these skills are built

source-triage, book-research, write-ste and manage-docket each pair a short skill with a Python script. The script does the part a model cannot do reliably on its own. The rules in the skills come from what models got wrong in eval runs.

## How an agent picks a skill

Most agents put only each skill's name and description in the prompt. So the description is all the model sees when it chooses. Each description says what the skill does and lists the words a user would say.

## What the eval runs showed, and the fix

| Failure in the transcripts | Fix |
|---|---|
| The model invented sources or keys | Sources go into a ledger through a script that gives out the keys. `sources.py check` fails on any key in a draft that is not in the ledger. |
| To add a note, the model replaced the heading with only the note, and the heading was gone | `sources.py note` appends one line under a heading. The model never edits the notes file. |
| Notes cited keys that were never registered, the draft copied them, and the key check rejected the section on every try | `sources.py note` refuses a key that is not in the ledger, so the error comes at the note, not at the draft. |
| The model copied reference details by hand, with mistakes | `sources.py refs` writes one References line per cited key from the ledger. |
| Drafts kept `TODO` lines or came out far too short | `sources.py check` fails on any `TODO` line left, and with `--words MIN-MAX` on a length out of range. |
| A check said FAIL and the model stopped | Every check has an "on FAIL, do this" step. |
| Skills pointed at other skills ("the same rules as ...") and the model did not follow | Each skill states its own rules. Repeating three lines costs less than a missed hop. |
| Wrong argument types, like a priority of `"high"` | The Docket script takes a number and the skill says so. Each command line is spelled out. |
| Many style violations per sentence | `write-ste` lists the checker's rules with its exact limits, plus the word swaps the runs needed most. |

## The scripts

They use only the standard library and write plain files in the project folder:

| Script | Files | Commands |
|---|---|---|
| `source-triage/scripts/sources.py` | `research/sources.json`, `research/notes.md`, the draft | `add`, `list`, `note`, `refs <draft>`, `check <draft> [--words MIN-MAX]` |
| `write-ste/scripts/check_style.py` | none | `<file.md>` |
| `manage-docket/scripts/docket.py` | `docket/docket.json`, `docket/DOCKET.md`, `docket/calendar/*.ics` | `add`, `update`, `list`, `ics` |

book-research calls `sources.py` in its sibling folder, so install the set together.

## Writing style of the skills

Numbered steps with one action each. Exact commands and options. Templates in fenced blocks to copy, not descriptions of structure. Short sentences. No "why" paragraphs: the model spends its attention on them instead of the steps.
