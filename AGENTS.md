# Working on thetaskills

This repo is a collection of Agent Skills. Each skill is a folder under `skills/`, and the manifests at the root publish all of them together.

## Layout

```
skills/<name>/SKILL.md      the skill: frontmatter (name, description) + instructions
skills/<name>/scripts/      optional helpers, run relative to the skill folder
skills/<name>/references/   optional docs the skill tells the agent to read
docs/<name>.md              human docs: what it does, what it installs, uninstall
package.json                pi package ("pi": {"skills": ["./skills"]})
.claude-plugin/, .codex-plugin/, .agents/plugins/   plugin and marketplace manifests
scripts/install.sh          links skills into ~/.agents/skills for any agent
tests/run.sh                all checks (npm test)
```

## Rules

- The frontmatter `name` must match the folder name: lowercase letters, digits and hyphens, at most 64 characters.
- The `description` says what the skill does and when to use it, including the phrases a user would say. Agents pick skills from this field alone.
- Keep `SKILL.md` short. Move long material into `references/` and link to it.
- Scripts must be safe to re-run and must not prompt interactively. Machine-wide installs go in `scripts/setup.sh`, and the skill asks the user before running it.
- Don't add per-skill README files. Human docs go in `docs/<name>.md`.
- When you add a skill, add a row to the table in `README.md`. When you bump a version, bump it in all four manifests (`package.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`).
- Run `npm test` (or `bash tests/run.sh`) before committing.
