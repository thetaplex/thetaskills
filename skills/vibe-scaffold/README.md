# vibe-scaffold

Say **"let's start a new project"** and the agent sets up the repo the same way every time:

- a git repo
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) specs, plus the `/opsx:*` commands for your agents
- an `AGENTS.md` section telling the agent to work spec-first ([superpowers](https://github.com/obra/superpowers) process, [ponytail](https://github.com/DietrichGebert/ponytail) minimalism, [rtk](https://github.com/rtk-ai/rtk) for noisy shell commands)

Then it starts brainstorming your first feature and writes it up as an OpenSpec proposal.

## Machine setup (`scripts/setup.sh`)

The thetaskills `install.sh` runs this. If you installed with `npx skills add`, the agent offers to run it the first time it's needed. It's safe to re-run, and re-running updates everything.

| Thing | Where | How |
|---|---|---|
| superpowers, ponytail skills | clones in `~/.vibe-scaffold/`, symlinked into `~/.agents/skills/` | `git clone --depth 1` |
| OpenSpec CLI | global npm | `npm install -g @fission-ai/openspec` |
| rtk | brew or cargo | plus `rtk init -g --opencode` and a pi hook if those agents are installed |
| headroom | `uv tool` (or pipx) | plus `~/.vibe-scaffold/aliases.sh` with `oc` = `headroom wrap opencode` |

Add `source ~/.vibe-scaffold/aliases.sh` to your `~/.zshrc` or `~/.bashrc`.

Per repo, only two things are written: what `openspec init` creates, and a marked block in `AGENTS.md`.

## Per-agent notes

- **opencode:** use `oc` to start it through headroom.
- **pi:** headroom has no `wrap pi`, so run `headroom proxy --port 8787` and point your provider's base URL at it.
- **Strands:** see [`examples/strands_agent.py`](../../examples/strands_agent.py).
- After setup, restart the agent (pi: `/reload`) so it picks up the repo's new `/opsx:*` commands. The skill works around this for the first proposal.

## Usage

From inside the folder you want to set up, say "let's start a new project".

Running it again is safe: steps already done are skipped. If you run it from a subfolder of an existing repo, it stops and asks first.

Options (environment variables):

- `OPENSPEC_TOOLS=opencode,pi` picks the OpenSpec targets. By default it uses the agents it finds installed.
- `ALLOW_SUBDIR=1` sets up a subfolder of another repo on its own.

## Uninstall

```bash
for l in ~/.agents/skills/*; do   # remove only links that point into ~/.vibe-scaffold
  [ -L "$l" ] && case "$(readlink "$l")" in "$HOME/.vibe-scaffold"*) rm "$l";; esac
done
rm -rf ~/.vibe-scaffold ~/.agents/skills/vibe-scaffold
npm uninstall -g @fission-ai/openspec
rtk init -g --uninstall; uv tool uninstall headroom-ai
```

## Credits

This skill only wires together other people's work: [superpowers](https://github.com/obra/superpowers), [ponytail](https://github.com/DietrichGebert/ponytail), [OpenSpec](https://github.com/Fission-AI/OpenSpec), [rtk](https://github.com/rtk-ai/rtk), [headroom](https://github.com/chopratejas/headroom). Each keeps its own license.
