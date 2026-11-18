# write-book-chapter

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"draft chapter 1 from my research"**.

Drafts one chapter, part by part, from that chapter's research file, in the author's voice. Facts the story needs but the research lacks are marked `[CHECK: ...]` and added to the chapter's open list.

## What it writes

`research/drafts/NN-slug-chapter.md`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands. It runs the scripts of [source-triage](source-triage.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
