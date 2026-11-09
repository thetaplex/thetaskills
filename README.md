# thetaskills

A collection of [Agent Skills](https://agentskills.io) (`SKILL.md` folders) for coding agents. They're tested with **pi**, **opencode** and **Strands Agents**, and should work with any agent that reads `~/.agents/skills`.

## Skills

| Skill | Say | What it does |
|---|---|---|
| [vibe-scaffold](skills/vibe-scaffold/) | "let's start a new project" | Sets up git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans your first feature |

## Install

**All skills, kept up to date with git:**

```bash
git clone https://github.com/OWNER/thetaskills ~/thetaskills
~/thetaskills/install.sh                  # or: ./install.sh vibe-scaffold
```

This links each skill into `~/.agents/skills` and runs any setup a skill ships with (`scripts/setup.sh`). Each skill's README lists exactly what its setup installs. Use `--link-only` to skip setup.

**With the skills CLI:**

```bash
npx skills add OWNER/thetaskills -g                         # pick from a list
npx skills add OWNER/thetaskills -g --skill vibe-scaffold   # just one
```

**Strands:** see [`examples/strands_agent.py`](examples/strands_agent.py).

## Adding a skill

1. Create `skills/<name>/SKILL.md`. Use lowercase-hyphen names, and make the frontmatter `name` match the folder name.
2. Optional: put helper scripts in `skills/<name>/scripts/`. If the skill needs machine-wide tools, add `scripts/setup.sh`. Make it safe to re-run, and have it ask nothing interactively.
3. Optional: add `skills/<name>/README.md` for humans.
4. Add a row to the table above.

## License

MIT. Skills that install third-party tools credit them in their own README.
