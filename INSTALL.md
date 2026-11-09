# Install

Pick your agent below. If it isn't listed but reads `~/.agents/skills` (the [Agent Skills](https://agentskills.io) standard location), use [Any agent](#any-agent-agentsskills).

Some skills need machine-wide tools. vibe-scaffold, for example, needs OpenSpec, rtk, headroom, superpowers and ponytail. Those skills ship a `scripts/setup.sh`, and the agent offers to run it the first time it's needed. [`docs/`](docs/) lists exactly what each one installs.

## Pi

```bash
pi install git:github.com/thetaplex/thetaskills
```

## OpenCode

```bash
npx skills add thetaplex/thetaskills --agent opencode --global
```

## Claude Code

```
/plugin marketplace add thetaplex/thetaskills
```
```
/plugin install thetaskills@thetaskills
```
(Send these as two separate prompts.)

## Codex

```bash
codex plugin marketplace add thetaplex/thetaskills
codex plugin add thetaskills@thetaskills
```

## Strands Agents

Strands is an SDK, so you point it at the skills folder yourself. Install the skills with [Any agent](#any-agent-agentsskills), then see [`examples/strands_agent.py`](examples/strands_agent.py).

## Skills CLI

The [skills CLI](https://skills.sh) copies skills into the skills folder of many agents:

```bash
npx skills add thetaplex/thetaskills                          # pick from a list
npx skills add thetaplex/thetaskills --skill vibe-scaffold     # just one
```

Choose the agent with `--agent`, and add `--global` to install for your user instead of the current project.

## Any agent (`~/.agents/skills`)

From a git checkout, with updates via `git pull`:

```bash
git clone https://github.com/thetaplex/thetaskills ~/thetaskills
~/thetaskills/scripts/install.sh                  # or: scripts/install.sh vibe-scaffold
```

This links each skill into `~/.agents/skills` and runs each skill's `scripts/setup.sh`. Add `--link-only` to skip the setup scripts.

## Uninstall

| Host | Command |
|------|---------|
| Pi | `pi uninstall thetaskills` |
| Claude Code | `/plugin remove thetaskills` |
| Codex | `codex plugin remove thetaskills` |
| Skills CLI | `npx skills remove vibe-scaffold` (same `--agent` / `--global` flags as the install) |
| Any agent | `rm ~/.agents/skills/vibe-scaffold` and `rm -rf ~/thetaskills` |

This removes the skills only. To remove what a skill's setup installed, see that skill's page in [`docs/`](docs/) (e.g. [vibe-scaffold](docs/vibe-scaffold.md#uninstall)).
