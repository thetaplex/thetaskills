# research-method

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"what does the evidence say about X?"**.

Answers one factual question: frames it, searches, reads a primary source, registers it and answers with source keys. It does not answer from memory.

## What it writes

`research/notes.md`, the source ledger. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands, and search and open web pages. It runs the scripts of [source-triage](source-triage.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
