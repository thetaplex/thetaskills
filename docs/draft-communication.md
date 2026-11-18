# draft-communication

Written for small local models (4B to 8B parameters) and works in any agent. See [Writing skills for small models](writing-skills.md) for how these skills are built.

Say something like **"draft a status memo for the team"**.

Drafts an email, memo, invitation or agenda with a specific subject, the purpose first, action items with owners and dates, and Docket keys.

## What it writes

`docket/drafts/<slug>.md`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands, and search and open web pages. It runs the scripts of [manage-docket](manage-docket.md) and [write-ste](write-ste.md), so install those skills next to it. The installers in [INSTALL.md](../INSTALL.md) install them all.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
