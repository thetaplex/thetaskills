# manage-docket

See [How these skills are built](writing-skills.md).

Say something like **"add a task due Friday and send me an invite"**.

Adds and updates Docket tasks, events, decisions and notes with the Docket tools, and exports events as RFC 5545 `.ics` files.

## What it writes

the Docket (through its tools only), `docket/calendar/*.ics`. It installs nothing.

## Requirements

Python 3 (standard library only), and an agent that can read, create and edit files and run shell commands.

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall).
