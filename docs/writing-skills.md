# Writing skills for small models

The research, writing and assistant skills target a 4B to 8B parameter model on the user's own machine. These models have a short context and a limited number of tool steps per turn. A large model forgives a loose skill, and a small one does not. The skills come from what Gemma 4 E4B got wrong in eval runs, and they work just as well for large models.

## How an agent picks a skill

Most agents put only each skill's name and description in the prompt. So the description is all the model sees when it chooses. Each description starts with what the skill makes and its length. It lists the words a user would say, and it names the nearest other skill ("for 1 or 2 pages, use write-brief").

## What the eval runs showed, and the fix in each skill

| Failure in the transcripts | Fix |
|---|---|
| The model wrote the whole draft in one call, then stopped | Each writing skill first writes a skeleton with one `TODO` line per section, then fills one `TODO` per edit. The file shows what is left, so the work survives a context reset. |
| The model invented sources or keys | Sources go into a ledger through a script that gives out the keys. A second script checks that every key in the draft is in the ledger. |
| The model drafted with too few sources | Each writing skill lists the sources first and has a minimum per genre (brief 3, essay and proposal 4, paper and report 5). |
| A check said FAIL and the model stopped | Every check has a "on FAIL, do this" step. |
| Skills pointed at other skills ("the same rules as ...") and the model did not follow | Each skill states its own rules. Repeating three lines costs less than a missed hop. |
| Wrong argument types, like a priority of `"high"` | The Docket script takes a number and the skill says so. Each command line is spelled out. |
| More than one style violation per sentence | `write-ste` lists the checker's rules with its exact limits, plus the word swaps the runs needed most. The budgets fit the checker: 6 sentences of 25 words is about 150 words per paragraph. |

## The scripts

Three Python scripts replace the tools a research app would have built in. They use only the standard library and write plain files in the project folder:

| Script | Files | Commands |
|---|---|---|
| `source-triage/scripts/sources.py` | `research/sources.json` | `add`, `list`, `check <draft>` |
| `write-ste/scripts/check_style.py` | none | `<file.md>` |
| `manage-docket/scripts/docket.py` | `docket/docket.json`, `docket/DOCKET.md`, `docket/calendar/*.ics` | `add`, `update`, `list`, `ics` |

Other skills call these scripts in their sibling folders, so install the set together.

## Writing style of the skills

Numbered steps with one action each. Exact commands and options. Templates in fenced blocks to copy, not descriptions of structure. Short sentences in the same Simplified Technical English that the drafts must pass. No "why" paragraphs: a small model spends its attention on them instead of the steps.

## The family

The research loop (`deep-research`, `research-method`, `source-triage`) gathers sources and notes. Six writing skills (`write-brief`, `write-report`, `write-research-paper`, `write-research-proposal`, `write-essay`, `write-book-chapter`) share one procedure: skeleton, source check, one section per edit, references, checks. `book-research` builds a corpus for a book over many sessions. `write-ste` holds the style rules. `manage-docket`, `draft-communication` and `weekly-review` cover tasks, messages and plans.
