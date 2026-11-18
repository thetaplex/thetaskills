---
name: write-ste
description: The ASD-STE100 Simplified Technical English rules, a checker script that enforces the measurable ones, the word swaps it asks for most, and how to fix its report line by line. Use when writing or revising any draft, memo or plan in plain technical English, when the user asks for STE, ASD-STE100 or simple English, or when the style check returns FAIL.
---
# Write in Simplified Technical English (ASD-STE100)

## The checker

Run it from the project folder: `python3 <this skill's folder>/scripts/check_style.py <file.md>`. It prints `PASS (N sentences)`, or `FAIL` and one line per violation: `line 12 [word] utilize -> use`.

## The rules it enforces

| Rule | Limit | Fix |
|---|---|---|
| length | List items and steps: 20 words. Other sentences: 25 words. | Split into two sentences. |
| paragraph | 6 sentences. | Start a new paragraph. |
| passive | No "is/was/are/were/be/been + done, made, tested ...". | Name who acts: "We tested it", not "It was tested". |
| semicolon | No `;`. | Use two sentences. |
| contraction | No don't, it's, we're. | Write do not, it is, we are. |
| noun-cluster | At most 3 nouns in a row. | Add "of" or "for": "the rate of error in citations". |
| word | Simple words only. | Use the swap below. |

Headings, tables, quotes, code and the References section are not checked.

## Swaps it asks for most

The swap also applies to other forms of the word (provides, provided, providing).

- provide → give
- generate → make
- ensure → make sure
- establish → set up
- demonstrate, exhibit, illustrate → show
- achieve, conduct, perform, implement → do
- require → need
- regarding, concerning → about
- initial, preliminary → first
- subsequent → next
- subsequently → then
- additional → more
- additionally, furthermore, in addition → also
- utilize, employ → use
- obtain, acquire, retrieve → get
- enhance, optimize → improve
- evaluate, assess, examine, validate → check
- determine → find
- methodology → method
- terminology → words
- various → different
- numerous → many
- majority → most
- approximately → about
- currently, presently → now
- consequently, thereby → so
- facilitate, assist → help
- enable, permit → let
- consider → think about
- represent → show
- occur → happen
- proceed → go
- substantial, considerable → large
- fundamental → basic
- optimal, optimum → best

## Fixing a report

1. Fix one reported line per edit. Replace the sentence as it is now with the fixed sentence.
2. Do not rewrite the whole draft. It makes new violations.
3. Run the checker once more. If some violations stay, list them in your reply and go on.
