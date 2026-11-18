# thetaskills

The agent skills we use internally at ThetaPlex, published so anyone can use them. They work with **pi**, **opencode**, **Strands Agents**, **Claude Code**, **Codex**, and any agent that reads the [Agent Skills](https://agentskills.io) format.

## Skills

### Repos and codebases

| Skill | Say | What it does |
|---|---|---|
| [vibe-scaffold](skills/vibe-scaffold/SKILL.md) | "let's start a new project" | Scaffolds the repo with git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans your first feature. [Details](docs/vibe-scaffold.md) |
| [open-source-ready](skills/open-source-ready/SKILL.md) | "open source this repo" | Gets a GitHub repo ready to make public using its owner's conventions, and stops before the switch. [Details](docs/open-source-ready.md) |
| [codebase-to-deck](skills/codebase-to-deck/SKILL.md) | "turn this codebase into a presentation" | Writes a slide deck (Marp Markdown and PDF, ThetaPlex theme) that teaches non-technical readers how a codebase works, with an FAQ after each part. Builds on [codebase-to-course](https://github.com/zarazhangrui/codebase-to-course). [Details](docs/codebase-to-deck.md) |

The research, writing and assistant skills below are written for small local models (4B to 8B), and they work with large ones too. They share three Python scripts (standard library only) for the source ledger, the style check and the Docket, so install them together. [How they are built](docs/writing-skills.md).

### Research

| Skill | Say | What it does |
|---|---|---|
| [deep-research](skills/deep-research/SKILL.md) | "write a report on how SQLite WAL mode works" | Splits the request into 3 sub-questions, searches each one, registers sources in a ledger, keeps notes with source keys in `research/notes.md`, then hands over to the writing skill for the genre. [Details](docs/deep-research.md) |
| [research-method](skills/research-method/SKILL.md) | "what does the evidence say about X?" | Answers one factual question: frames it, searches, reads a primary source, registers it and answers with source keys. [Details](docs/research-method.md) |
| [source-triage](skills/source-triage/SKILL.md) | "which of these results should I trust?" | Scores search results from 1 to 5, registers the keepers before reading, and reads and cites the highest scores first. [Details](docs/source-triage.md) |
| [book-research](skills/book-research/SKILL.md) | "I am writing a book about the 1854 cholera outbreak" | First session: asks the author five intake questions and creates one research file per chapter. [Details](docs/book-research.md) |

### Writing

| Skill | Say | What it does |
|---|---|---|
| [write-book-chapter](skills/write-book-chapter/SKILL.md) | "draft chapter 1 from my research" | Drafts one chapter, part by part, from that chapter's research file, in the author's voice. [Details](docs/write-book-chapter.md) |
| [write-brief](skills/write-brief/SKILL.md) | "write a one-page brief for the council" | Drafts a 500 to 700 word brief: key message, three findings, recommendation, evidence and references. [Details](docs/write-brief.md) |
| [write-report](skills/write-report/SKILL.md) | "write a technical report on our options" | Drafts a 2000 to 4000 word report: executive summary, scope, findings, analysis, recommendations, limitations and references. [Details](docs/write-report.md) |
| [write-research-paper](skills/write-research-paper/SKILL.md) | "write a short research paper on citation errors" | Drafts a paper: abstract, background, method, findings, discussion, limitations and references. [Details](docs/write-research-paper.md) |
| [write-research-proposal](skills/write-research-proposal/SKILL.md) | "write a research proposal on X" | Drafts a 1500 to 2500 word proposal: summary, problem, prior work, aims, method, timeline table, risks and references. [Details](docs/write-research-proposal.md) |
| [write-essay](skills/write-essay/SKILL.md) | "write an essay arguing that X" | Drafts an 800 to 1200 word essay: opening with the thesis, two or three arguments, the strongest objection, conclusion and references. [Details](docs/write-essay.md) |
| [write-ste](skills/write-ste/SKILL.md) | "fix the style errors in this draft" | The ASD-STE100 Simplified Technical English rules, a script that checks the measurable ones, the word swaps it asks for most, and how to fix its report one line at a time. [Details](docs/write-ste.md) |

### Assistant

| Skill | Say | What it does |
|---|---|---|
| [manage-docket](skills/manage-docket/SKILL.md) | "add a task due Friday and send me an invite" | Adds and updates Docket tasks, events, decisions and notes with a bundled script, and exports events as RFC 5545 `.ics` files. [Details](docs/manage-docket.md) |
| [draft-communication](skills/draft-communication/SKILL.md) | "draft a status memo for the team" | Drafts an email, memo, invitation or agenda with a specific subject, the purpose first, action items with owners and dates, and Docket keys. [Details](docs/draft-communication.md) |
| [weekly-review](skills/weekly-review/SKILL.md) | "triage my inbox notes and plan the week" | Triages notes into Docket items, exports dated events as `.ics` files, and writes a prioritized action plan. [Details](docs/weekly-review.md) |

## Install

Prerequisites: your agent, plus whatever tools a skill needs, which its page in [`docs/`](docs/) lists. vibe-scaffold's setup script needs [Node.js](https://nodejs.org) 20.19 or later, [Homebrew](https://brew.sh) or [cargo](https://rustup.rs), and [uv](https://docs.astral.sh/uv/getting-started/installation/) or [pipx](https://pipx.pypa.io). open-source-ready needs the [GitHub CLI](https://cli.github.com), logged in. codebase-to-deck needs the codebase-to-course skill, Node.js and Chrome.

```bash
pi install git:github.com/thetaplex/thetaskills                  # pi
npx skills add thetaplex/thetaskills --agent opencode --global   # opencode
```

Claude Code, Codex, Strands and other agents: see [INSTALL.md](INSTALL.md).

## Contributing

This repo is where ThetaPlex keeps its skills, so new internal skills go here. Outside contributions are welcome too. See [CONTRIBUTING](CONTRIBUTING.md) for the layout and checks, and run `npm test` before opening a PR.

## License

[Apache-2.0](LICENSE). Skills that install third-party tools credit them in their page under [`docs/`](docs/).
