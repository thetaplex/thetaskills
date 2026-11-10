# vibe-scaffold

Say **"let's start a new project"** and the agent sets up the repo the same way every time:

- a git repo
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) specs, plus the `/opsx:*` commands for your agents
- an `AGENTS.md` section telling the agent to work spec-first ([superpowers](https://github.com/obra/superpowers) process, [ponytail](https://github.com/DietrichGebert/ponytail) minimalism, [rtk](https://github.com/rtk-ai/rtk) for noisy shell commands)

Then it starts brainstorming your first feature and writes it up as an OpenSpec proposal.

## Machine setup (`scripts/setup.sh`)

The skill offers to run this the first time it finds tools missing. You can also run it yourself: `bash skills/vibe-scaffold/scripts/setup.sh` from a checkout, or `scripts/install.sh` to link the skills and run it in one go. It's safe to re-run, and re-running updates everything to its latest release.

| Thing | Where | How |
|---|---|---|
| superpowers, ponytail skills | clones in `~/.vibe-scaffold/`, symlinked into `~/.agents/skills/` | `git clone --depth 1` at the newest `vX.Y.Z` release tag (default branch if a repo has no tags) |
| OpenSpec CLI | global npm | `npm install -g @fission-ai/openspec` |
| rtk | brew, or cargo at the newest release tag | plus `rtk init -g --opencode` and a pi hook if those agents are installed |
| headroom | `uv tool` (or pipx) | plus `~/.vibe-scaffold/aliases.sh` with `oc` = `headroom wrap opencode` |

Add `source ~/.vibe-scaffold/aliases.sh` to your `~/.zshrc` or `~/.bashrc`.

Per repo, only two things are written: what `openspec init` creates, and a marked block in `AGENTS.md`.

## Per-agent notes

- **opencode:** use `oc` to start it through headroom.
- **pi:** headroom has no `wrap pi`, so run `headroom proxy --port 8787` and point your provider's base URL at it.
- **Strands:** see [`examples/strands_agent.py`](../examples/strands_agent.py).
- After setup, restart the agent (pi: `/reload`) so it picks up the repo's new `/opsx:*` commands. The skill works around this for the first proposal.

## Usage

From inside the folder you want to set up, say "let's start a new project".

Running it again is safe: steps already done are skipped. If you run it from a subfolder of an existing repo, it stops and asks first.

Options (environment variables):

- `OPENSPEC_TOOLS=opencode,pi` picks the OpenSpec targets. By default it uses the agents it finds installed.
- `ALLOW_SUBDIR=1` sets up a subfolder of another repo on its own.

## Without an agent

The skill only wraps two scripts, and you can run both yourself from a checkout of this repo:

```bash
git clone https://github.com/thetaplex/thetaskills ~/thetaskills
bash ~/thetaskills/skills/vibe-scaffold/scripts/setup.sh                 # once per machine
bash ~/thetaskills/skills/vibe-scaffold/scripts/bootstrap.sh ~/code/my-app   # once per project
```

`bootstrap.sh` takes the project folder as its argument (the current folder if you leave it out) and creates the folder if it doesn't exist. It reads the same `OPENSPEC_TOOLS` and `ALLOW_SUBDIR` variables as above. Each line of output starts with `OK`, `SKIP`, `WARN`, `FAIL` or `STOP`. It exits with code 2 when it stops because the folder is inside another repo.

The scripts don't do the parts the agent would:

1. Replace the `<!-- describe the project -->` placeholder in `AGENTS.md` with the project's name and purpose.
2. Start your agent in the project folder and propose the first change with `/opsx:propose <what you want to build>`.

## Uninstall

```bash
for l in ~/.agents/skills/*; do   # remove only links that point into ~/.vibe-scaffold
  [ -L "$l" ] && case "$(readlink "$l")" in "$HOME/.vibe-scaffold"*) rm "$l";; esac
done
rm -rf ~/.vibe-scaffold   # then remove the skill itself: see INSTALL.md#uninstall
npm uninstall -g @fission-ai/openspec
rtk init -g --uninstall; uv tool uninstall headroom-ai
```

## Credits

This skill only wires together other people's work: [superpowers](https://github.com/obra/superpowers), [ponytail](https://github.com/DietrichGebert/ponytail), [OpenSpec](https://github.com/Fission-AI/OpenSpec), [rtk](https://github.com/rtk-ai/rtk), [headroom](https://github.com/chopratejas/headroom). Each keeps its own license.
