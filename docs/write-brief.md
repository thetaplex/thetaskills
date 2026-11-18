# write-brief

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"write a one-page brief for the council"**.

Drafts a 500 to 700 word brief: key message, three findings, recommendation, evidence and references.

## What it writes

`research/drafts/<slug>-brief.md`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands. It runs the scripts of [source-triage](source-triage.md) and [write-ste](write-ste.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
