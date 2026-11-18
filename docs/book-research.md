# book-research

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"I am writing a book about the 1854 cholera outbreak"**.

First session: asks the author five intake questions and creates one research file per chapter. Later sessions: answers 2 to 4 questions for one chapter and keeps shared timeline, people, places and terms files.

## What it writes

`research/book/` (brief, chapters, reference files, open questions). It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands, and search and open web pages. It runs the scripts of [source-triage](source-triage.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
