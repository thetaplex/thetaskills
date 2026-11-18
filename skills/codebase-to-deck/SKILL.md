---
name: codebase-to-deck
description: Turns a codebase into a slide deck that teaches non-technical readers how it works - Markdown (Marp) and PDF, in the ThetaPlex theme, with an FAQ after each part. Builds on the codebase-to-course skill's analysis and curriculum. Use when the user says "turn this codebase into a presentation", "make a deck explaining this repo", "codebase walkthrough as slides" or "explain this project as a PDF".
---

# Codebase to deck

Write a deck that teaches how a codebase works to someone who steers AI coding tools but doesn't read code. The output is a Markdown deck in [Marp](https://marp.app) format and a PDF rendered from it.

`references/` and `scripts/` are relative to this skill's folder.

## Requirements

- The **codebase-to-course** skill (<https://github.com/zarazhangrui/codebase-to-course>). This skill reuses its analysis and curriculum, and doesn't repeat them. If it isn't installed, stop and ask the user to install it.
- Node.js (`npx`) and Chrome or Chromium, for the PDF.

## Steps

1. **Analyse and plan with codebase-to-course.** Invoke it and follow its codebase analysis and curriculum design phases, and the content rules they point to. Stop before its build phase: no HTML, no `styles.css`, no module files. Done when you have 4 to 6 parts, and each part has a comparison it doesn't share with any other part, a concrete opening, and the snippets it will show.

2. **Write the deck.** Copy `references/template.md` to `<project>-deck.md` in the folder the user names, and ask if they named none. Keep its front matter unchanged: it holds the ThetaPlex theme. Fill in the slides by following `references/slide-patterns.md`. Each course part becomes a part-divider slide followed by one slide per screen, and each part ends with an FAQ slide. Done when every part has at least one code slide, at least one FAQ slide, and every snippet matches its file exactly.

3. **Render and fit.** Run `bash scripts/render.sh <project>-deck.md`. It writes the PDF next to the deck and prints `FIT <slide> <percent>% <title>` for each slide over 95% full. Fix each slide over 100% by splitting it in two, or by adding `<!-- _class: small -->` above its heading, then run it again. Done when the script exits 0.

4. **Report.** Give the user the full paths of the `.md` and the `.pdf`, the slide count, and anything you left out.
