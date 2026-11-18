# thetaskills

A selection of the agent skills we use at ThetaPlex: the ones that give a capable model something it lacks on its own, like a script, a check or state that lasts across sessions. They work with **pi**, **opencode**, **Strands Agents**, **Claude Code**, **Codex**, and any agent that reads the [Agent Skills](https://agentskills.io) format.

## Skills

### Repos and codebases

| Skill | Say | What it does |
|---|---|---|
| [vibe-scaffold](skills/vibe-scaffold/SKILL.md) | "let's start a new project" | Scaffolds the repo with git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans your first feature. [Details](docs/vibe-scaffold.md) |
| [open-source-ready](skills/open-source-ready/SKILL.md) | "open source this repo" | Gets a GitHub repo ready to make public using its owner's conventions, and stops before the switch. [Details](docs/open-source-ready.md) |
| [codebase-to-deck](skills/codebase-to-deck/SKILL.md) | "turn this codebase into a presentation" | Writes a slide deck (Marp Markdown and PDF, ThetaPlex theme) that teaches non-technical readers how a codebase works, with an FAQ after each part. Builds on [codebase-to-course](https://github.com/zarazhangrui/codebase-to-course). [Details](docs/codebase-to-deck.md) |

### Research, writing and assistant

Each of these skills comes with a Python script (standard library only) that does what a model cannot do reliably on its own: hand out citation keys and check drafts against them, check ASD-STE100 style, and keep a task Docket across sessions. book-research uses source-triage's script, so install them together. [How they are built](docs/writing-skills.md).

| Skill | Say | What it does |
|---|---|---|
| [source-triage](skills/source-triage/SKILL.md) | "which of these results should I trust?" | Keeps a source ledger with stable `[S#]` keys. Scores search results from 1 to 5 and registers the keepers. Adds notes that may cite only registered keys, writes a draft's references, and checks a draft for unknown keys, leftover TODO lines and length. [Details](docs/source-triage.md) |
| [book-research](skills/book-research/SKILL.md) | "I am writing a book about the 1854 cholera outbreak" | First session: asks the author five intake questions and creates one research file per chapter. Later sessions answer that chapter's questions into a corpus with source keys. [Details](docs/book-research.md) |
| [write-ste](skills/write-ste/SKILL.md) | "fix the style errors in this draft" | The ASD-STE100 Simplified Technical English rules, a script that checks the measurable ones, the word swaps it asks for most, and how to fix its report one line at a time. [Details](docs/write-ste.md) |
| [manage-docket](skills/manage-docket/SKILL.md) | "add a task due Friday and send me an invite" | Adds and updates Docket tasks, events, decisions and notes with a bundled script, and exports events as RFC 5545 `.ics` files. [Details](docs/manage-docket.md) |

## Install

Prerequisites: your agent, plus whatever tools a skill needs, which its page in [`docs/`](docs/) lists. vibe-scaffold's setup script needs [Node.js](https://nodejs.org) 20.19 or later, [Homebrew](https://brew.sh) or [cargo](https://rustup.rs), and [uv](https://docs.astral.sh/uv/getting-started/installation/) or [pipx](https://pipx.pypa.io). open-source-ready needs the [GitHub CLI](https://cli.github.com), logged in. codebase-to-deck needs the codebase-to-course skill, Node.js and Chrome.

```bash
pi install git:github.com/thetaplex/thetaskills                  # pi
npx skills add thetaplex/thetaskills --agent opencode --global   # opencode
```

Claude Code, Codex, Strands and other agents: see [INSTALL.md](INSTALL.md).

## Contributing

This repo publishes only skills that add a script, a check or state that a capable model lacks, and other ThetaPlex skills stay private. Outside contributions that meet the same bar are welcome. See [CONTRIBUTING](CONTRIBUTING.md) for the layout and checks, and run `npm test` before opening a PR.

## License

[Apache-2.0](LICENSE). Skills that install third-party tools credit them in their page under [`docs/`](docs/).
