# source-triage

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"which of these results should I trust?"**.

Scores search results from 1 to 5, registers the keepers before reading, and reads and cites the highest scores first.

## What it writes

the source ledger, `research/notes.md`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands, and search and open web pages.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
