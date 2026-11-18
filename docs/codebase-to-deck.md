# codebase-to-deck

Say **"turn this codebase into a presentation"** in a project. The agent reads the code and writes a slide deck that teaches how it works to someone who steers AI coding tools but doesn't read code:

- **4 to 6 parts,** each built around one everyday comparison, starting from what the app does and working down into the code
- **code slides** with exact snippets from the repo and plain-English bullets beside them
- **an FAQ slide after each part:** situations you'll actually hit ("every test shows `error`, where do I look?") with the reasoning behind each answer
- **the ThetaPlex theme** from [thetaplex.com](https://thetaplex.com): parchment background, bronze accent, Cormorant Garamond headings, Inter body text

You get two files: `<project>-deck.md`, which reads as plain Markdown and is a [Marp](https://marp.app) deck, and `<project>-deck.pdf` in 16:9.

## How it relates to codebase-to-course

[codebase-to-course](https://github.com/zarazhangrui/codebase-to-course) does the hard part: reading the codebase and designing the curriculum. This skill uses those two phases and then writes slides instead of an interactive HTML page. Quizzes become FAQs, animations become numbered steps, and group chats become quoted dialogue. You need both skills installed.

## Requirements

- The [codebase-to-course](https://github.com/zarazhangrui/codebase-to-course) skill, installed for your agent
- [Node.js](https://nodejs.org), for `npx` to run Marp CLI
- Google Chrome or Chromium. Set `CHROME=/path/to/chrome` if the script can't find it

## The render script

`skills/codebase-to-deck/scripts/render.sh <deck.md> [out.pdf]` turns any Marp deck into a PDF. Marp's own PDF export times out on some machines, so the script exports HTML with Marp and prints it with headless Chrome. It also measures every slide:

```text
FIT 27 102% No checklist: the exploratory run
wrote thetatest-deck.pdf
```

A slide over 100% has content cut off, and the script exits 1. Split that slide, or put `<!-- _class: small -->` above its heading. The PDF is still written, so you can look at it.

## Editing the deck

Edit the `.md` and run the render script again. Each `---` line starts a new slide. The theme lives in the deck's front matter, so changing a colour there changes the whole deck.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall). Marp CLI runs through `npx` and is only cached by npm. Nothing else is installed.
