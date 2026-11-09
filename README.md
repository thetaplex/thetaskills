# agent-stack

Say **"let's start a new project"** to your coding agent and it sets up the repo the same way every time:

- a git repo
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) specs, plus the `/opsx:*` commands for your agents
- an `AGENTS.md` section telling the agent to work spec-first ([superpowers](https://github.com/obra/superpowers) process, [ponytail](https://github.com/DietrichGebert/ponytail) minimalism, [rtk](https://github.com/rtk-ai/rtk) for noisy shell commands)

Then it starts brainstorming your first feature and writes it up as an OpenSpec proposal.

It works with **pi**, **opencode** and **Strands Agents**. Any agent that reads `~/.agents/skills` (the [Agent Skills](https://agentskills.io) standard location) should work too.

## Install

### Full stack (recommended)

```bash
git clone https://github.com/OWNER/agent-stack ~/.agent-stack/agent-stack
~/.agent-stack/agent-stack/install.sh
echo 'source ~/.agent-stack/aliases.sh' >> ~/.zshrc   # or ~/.bashrc
```

Re-run `install.sh` after `git pull` to update everything.

### Just the skill

```bash
npx skills add OWNER/agent-stack -g
```

The first time you start a project, the agent notices the rest of the stack is missing. It asks before running the bundled `scripts/setup.sh`.

## What the installer changes on your machine

| Thing | Where | How |
|---|---|---|
| superpowers, ponytail skills | clones in `~/.agent-stack/`, symlinked into `~/.agents/skills/` | `git clone --depth 1` |
| new-project skill | symlink in `~/.agents/skills/` (git install only) | |
| OpenSpec CLI | global npm | `npm install -g @fission-ai/openspec` |
| rtk | brew or cargo | plus `rtk init -g --opencode` and a pi hook if those agents are installed |
| headroom | `uv tool` (or pipx) | plus `~/.agent-stack/aliases.sh` with `oc` = `headroom wrap opencode` |

Nothing is installed per repo except what OpenSpec's own `openspec init` writes and the marked block in `AGENTS.md`.

## Per-agent notes

- **opencode** reads `~/.agents/skills`. Use `oc` to start it through headroom.
- **pi** reads `~/.agents/skills`. headroom has no `wrap pi`, so run `headroom proxy --port 8787` and point your provider's base URL at it.
- **Strands** is an SDK, so you point it at the skills folder yourself. See [`examples/strands_agent.py`](examples/strands_agent.py).
- After setup, restart the agent (pi: `/reload`) so it picks up the repo's new `/opsx:*` commands. The skill works around this for the first proposal.

## Usage

From inside the folder you want to set up:

> let's start a new project

Running it again is safe: steps already done are skipped. If you run it from a subfolder of an existing repo, it stops and asks first.

Options (environment variables):

- `OPENSPEC_TOOLS=opencode,pi` picks the OpenSpec targets. By default it uses the agents it finds installed.
- `ALLOW_SUBDIR=1` sets up a subfolder of another repo on its own.

## Uninstall

```bash
for l in ~/.agents/skills/*; do   # remove only links that point into ~/.agent-stack
  [ -L "$l" ] && case "$(readlink "$l")" in "$HOME/.agent-stack"*) rm "$l";; esac
done
rm -rf ~/.agent-stack
npm uninstall -g @fission-ai/openspec
rtk init -g --uninstall; uv tool uninstall headroom-ai
```

## Credits

This repo only wires together other people's work: [superpowers](https://github.com/obra/superpowers), [ponytail](https://github.com/DietrichGebert/ponytail), [OpenSpec](https://github.com/Fission-AI/OpenSpec), [rtk](https://github.com/rtk-ai/rtk), [headroom](https://github.com/chopratejas/headroom). Each keeps its own license.

## License

MIT
