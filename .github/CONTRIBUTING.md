# Contributing

Thanks for helping out. To add a skill:

1. Create `skills/<name>/SKILL.md`. Use a lowercase-hyphen name that matches the folder, and a `description` that says what the skill does and when to use it.
2. Optional: put helpers in `skills/<name>/scripts/` and longer docs for the agent in `skills/<name>/references/`. If the skill needs machine-wide tools, add a `scripts/setup.sh` that is safe to re-run and never prompts.
3. Write `docs/<name>.md` for humans: what it does, what it installs, and how to uninstall.
4. Add a row to the skills table in `README.md`.
5. Run `npm test` (or `bash tests/run.sh`).

[`AGENTS.md`](../AGENTS.md) has the full rules. Your coding agent reads them automatically.

Bug reports are welcome too. Please include your agent (pi, opencode, …), OS, and the output of the skill's script if there was one.
