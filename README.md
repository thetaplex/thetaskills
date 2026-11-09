# thetaskills

Agent skills for vibe-coded projects. They work with **pi**, **opencode**, **Strands Agents**, **Claude Code**, **Codex**, and any agent that reads the [Agent Skills](https://agentskills.io) format.

## Skills

| Skill | Say | What it does |
|---|---|---|
| [vibe-scaffold](skills/vibe-scaffold/SKILL.md) | "let's start a new project" | Scaffolds the repo with git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans your first feature. [Details](docs/vibe-scaffold.md) |

## Install

```bash
pi install git:github.com/thetaplex/thetaskills                  # pi
npx skills add thetaplex/thetaskills --agent opencode --global   # opencode
```

Claude Code, Codex, Strands and other agents: see [INSTALL.md](INSTALL.md).

## Contributing

New skills are welcome. See [CONTRIBUTING](.github/CONTRIBUTING.md) for the layout and checks, and run `npm test` before opening a PR.

## License

[MIT](LICENSE). Skills that install third-party tools credit them in their page under [`docs/`](docs/).
