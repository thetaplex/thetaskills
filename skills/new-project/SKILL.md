---
name: new-project
description: Bootstraps a new code project with the user's standard agent stack - git, OpenSpec specs, an AGENTS.md wired for superpowers, ponytail, rtk and headroom. Use whenever the user says "let's start a new project", "start a new project", "new repo", "set up this repo", or asks to scaffold or initialize a project.
---

# New project

Set up the current repository (or a folder the user names) with the standard agent stack, then hand off to planning.

## Steps

1. **Pick the folder.** Use the current working directory unless the user named another one. If the user hasn't said what the project is, ask one short question: its name and a one-line purpose.

2. **Run the bootstrap script.** It is idempotent, so it's safe to re-run:

   ```bash
   bash scripts/bootstrap.sh <project-dir>
   ```

   `scripts/` is relative to this skill's folder. It does `git init`, `openspec init` for the agents it finds installed, adds the agent-stack block to `AGENTS.md`, and checks the global tools. Override the OpenSpec targets with `OPENSPEC_TOOLS=opencode,pi`.

3. **Read the output.** Each line starts with `OK`, `SKIP`, `WARN`, `FAIL` or `STOP`.
   - `STOP` means the folder is inside another git repo. Ask the user whether they meant the repo root (rerun with that path) or really want this subfolder set up on its own (rerun with `ALLOW_SUBDIR=1`).
   - A `FAIL` about a missing tool or skill means the machine-wide stack isn't installed. Ask the user whether to run `bash scripts/setup.sh`. It clones superpowers and ponytail into `~/.agent-stack`, links them into `~/.agents/skills`, and installs openspec (npm -g), rtk (brew or cargo) and headroom (uv), plus rtk hooks for opencode and pi. Only run it with their OK, then run bootstrap again.
   - Fix anything else that is project-local.

4. **Fill in the project section.** In `AGENTS.md`, replace the `<!-- describe the project -->` placeholder with the name and purpose.

5. **Hand off to planning.** Use the superpowers `brainstorming` skill to shape the first feature, then capture the result as an OpenSpec change. The `/opsx:*` commands and OpenSpec skills were just created in this repo, so this session won't have loaded them yet. Read `.opencode/skills/openspec-propose/SKILL.md` (or `.pi/skills/openspec-propose/SKILL.md`) and follow it directly. Tell the user that `/opsx:propose` works natively after they restart the agent (pi: `/reload`). Follow ponytail's ladder while you do it: start with the smallest version that works.

6. **Report back briefly:** what was set up, any `WARN`/`FAIL` lines, and the proposed first change.

## Rules

- Don't overwrite an existing `AGENTS.md`. The script only adds its marked block.
- Don't commit unless the user asks to.
