# thetaskills

The agent skills we use internally at ThetaPlex, published so anyone can use them. They work with **pi**, **opencode**, **Strands Agents**, **Claude Code**, **Codex**, and any agent that reads the [Agent Skills](https://agentskills.io) format.

## Skills

| Skill | Say | What it does |
|---|---|---|
| [vibe-scaffold](skills/vibe-scaffold/SKILL.md) | "let's start a new project" | Scaffolds the repo with git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans your first feature. [Details](docs/vibe-scaffold.md) |
| [open-source-ready](skills/open-source-ready/SKILL.md) | "open source this repo" | Gets a GitHub repo ready to make public using its owner's conventions, and stops before the switch. [Details](docs/open-source-ready.md) |

## Install

Prerequisites: your agent, plus whatever tools a skill needs, which its page in [`docs/`](docs/) lists. vibe-scaffold's setup script needs [Node.js](https://nodejs.org) 20.19 or later, [Homebrew](https://brew.sh) or [cargo](https://rustup.rs), and [uv](https://docs.astral.sh/uv/getting-started/installation/) or [pipx](https://pipx.pypa.io). open-source-ready needs the [GitHub CLI](https://cli.github.com), logged in.

```bash
pi install git:github.com/thetaplex/thetaskills                  # pi
npx skills add thetaplex/thetaskills --agent opencode --global   # opencode
```

Claude Code, Codex, Strands and other agents: see [INSTALL.md](INSTALL.md).

## Contributing

This repo is where ThetaPlex keeps its skills, so new internal skills go here. Outside contributions are welcome too. See [CONTRIBUTING](CONTRIBUTING.md) for the layout and checks, and run `npm test` before opening a PR.

## License

[Apache-2.0](LICENSE). Skills that install third-party tools credit them in their page under [`docs/`](docs/).
