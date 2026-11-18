# deep-research

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"write a report on how SQLite WAL mode works"**.

Splits the request into 3 sub-questions, searches each one, registers sources in a ledger, keeps notes with source keys in `research/notes.md`, then hands over to the writing skill for the genre.

## What it writes

`research/notes.md` and the source ledger `research/sources.json`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands, and search and open web pages. It runs the scripts of [source-triage](source-triage.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
