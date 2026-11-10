# 1. An open-source-ready skill that follows the owner's conventions

Date: 2026-11-10

## Status

Accepted

## Context

Getting thetaskills ready to make public took a long checklist, worked through by hand: legal files, community files, issue templates, a secret scan, a README check, passing tests and CI, the repo description, and a first release. Most of it repeats for every repo, and each owner (organisation or person) has its own conventions on top.

GitHub splits these files in a way that is easy to get wrong:

- An owner's public `.github` repository supplies default community health files (code of conduct, `SECURITY.md`, PR template, issue templates) to every repository of that owner that lacks its own copy. This works for both organisations and personal accounts.
- `LICENSE` and `NOTICE` are never inherited. A repository without its own `LICENSE` has no license.
- Issue templates are inherited as a set. A repository with any `.github/ISSUE_TEMPLATE/` folder gets none of the owner's templates.

The skill will be published for anyone to use, so it can't name thetaplex, thetaskills or any other owner.

## Decision

Add a skill, `skills/open-source-ready/`, that gets the current repository ready to make public. It follows the owner's conventions where it can find them, and stops right before the visibility change.

### Goals

- One request ("open source this repo", "make this repo public", "is this repo ready to open source?") produces a repo that is ready to make public, with every change reviewed through a pull request.
- Conventions come from the owner, not from the skill.
- Safe to re-run: a repo that is already ready gets a clean report and no changes.

### Non-goals

- Making the repo public. The skill prints the command and the user runs it.
- Rotating secrets or choosing a license on the user's behalf.
- Rewriting git history without the user's explicit go-ahead.
- Hosts other than GitHub. The skill needs `gh`, logged in.

### Anti-goals

These make it a failure even if it technically works:

- Overwriting a file the repo already has.
- A push, tag, release or history rewrite that the user didn't confirm.
- Any owner name, repo name, email address or URL hardcoded in the skill.
- Adding files the owner's `.github` repository already provides.

### How conventions are found

1. Work out `<owner>/<repo>` and the default branch with `gh repo view`. If there is no GitHub remote, stop and say so.
2. If `<owner>/.github` exists and is public, it is the source of conventions: its `LICENSE` and `NOTICE` are copied, and any community file it provides is reported as covered.
3. If there is none, ask the user which license to use. Add a local `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1) and `SECURITY.md` pointing at the repo's private vulnerability reporting page, and ask for a conduct contact.
4. Peer repos: list the owner's public repos that aren't forks or archived. A file found in most of them (own issue templates, `.github/dependabot.yml`) becomes a suggestion for this repo, not an automatic change.

### Checklist, in order

1. **Legal.** If `LICENSE` is missing, copy it from the owner's `.github` repo, or create it from the license the user picks. Add `NOTICE` only for Apache-2.0 or when the owner's `.github` repo has one. If the repo's copy differs from the owner's, report the difference and don't change it.
2. **Community files.** Add starting versions of `CONTRIBUTING.md`, using the repo's real test command, and `CHANGELOG.md` (Keep a Changelog, Semantic Versioning) if they are missing. Leave anything the owner's `.github` repo provides.
3. **Issue templates.** If the repo has none, add `bug_report.yml`, `feature_request.yml` and `config.yml` together, starting from the templates in `references/`. The agent fills in the bug form's required fields for this kind of project (a CLI asks for version and OS; a library asks for language and runtime version; a service asks how it's deployed). Keep the warning against pasting secrets. `config.yml` turns off blank issues and links to the repo's private vulnerability reporting page.
4. **Dependabot.** If `.github/dependabot.yml` is missing, find the package ecosystems from manifests and lockfiles (for example `package.json`, `uv.lock`, `Cargo.toml`, `go.mod`), and add `github-actions` if `.github/workflows/` exists. Write one weekly entry per ecosystem and directory. Before writing, check each ecosystem name against GitHub's current list of supported ecosystems.
5. **Secrets and personal data.** Scan the tracked files and the full history with `gitleaks` if it is installed, otherwise with a built-in pattern search, and say which one ran. Flag author emails that aren't GitHub noreply addresses, and absolute home paths such as `/Users/<name>` or `/home/<name>`. A finding blocks the release until it is resolved. The skill always recommends rotating a leaked secret, because once anything was pushed, removing it from history doesn't make it secret again. If the finding is in history, the user picks one of these:
   - **Rotate only.** Revoke the secret and leave history as it is. If the user accepts the finding, it is recorded in the gitleaks allowlist (`.gitleaksignore`), so later runs don't block on it again.
   - **Rewrite history.** Only after the user explicitly says so. The skill explains the effects first: every commit SHA from the first affected commit onwards changes, existing clones and forks keep the old history, open pull requests break, and tags have to be recreated. It then runs `git filter-repo` (`--replace-text` for secrets, `--mailmap` for author emails) on a fresh mirror clone, keeps a backup bundle of the original, re-runs the scan, and asks again before force-pushing the branches and tags. If `git filter-repo` isn't installed, the skill tells the user how to install it and doesn't fall back to `git filter-branch`.
   - **Stop.** Leave everything as it is and don't release.
6. **Hygiene.** Check that `.gitignore` covers OS files and any tool-local folders found in the working tree (for example `.DS_Store`, `.serena/`, `.idea/`).
7. **README.** Check for: what it does, why it exists, install, quickstart, usage, links and license; named prerequisites; at most three badges. The agent writes the missing parts itself, because this needs judgement.
8. **Tests and CI.** Find the test command (a `justfile` `test` or `check` recipe, `package.json` scripts, or `CONTRIBUTING.md`), or ask for it. It must pass locally, and the latest CI run on the default branch must be green.
9. **Repo metadata.** The GitHub description matches the README's opening line.
10. **Release.** Propose a version: 0.1.0 if the repo has never been released, otherwise the next Semantic Versioning version based on the Unreleased entries. Once the user confirms, move those entries into the new version section, then tag and create the GitHub release with that section as its notes.
11. **Stop.** Print `gh repo edit <owner>/<repo> --visibility public --accept-visibility-change-consequences` and don't run it. If the repo is already public, skip this step and say so.

### How the work is split

- `scripts/check.sh` runs the mechanical checks (steps 1–6, 8 and 9) and prints one line per check, starting with `OK`, `MISSING`, `DIFF` or `FAIL`. It is re-runnable, never prompts, changes nothing, and exits non-zero if any check fails, so CI can use it too. It follows the same pattern as vibe-scaffold's `bootstrap.sh`.
- `references/` holds the issue-template starting shapes and the README checklist.
- `SKILL.md` tells the agent to run `check.sh`, make the fixes on a branch, open one pull request, and confirm with the user before each push, tag and release.
- `docs/open-source-ready.md` is the human documentation: what the skill does, what it changes, and how to uninstall it. It also gets a row in the README table, and `tests/` gets an offline test for `check.sh` that runs against a throwaway repo.

### Left to the builder

- Exact patterns for the built-in secret scan.
- Wording of the reference templates and the README checklist.
- How `check.sh` reaches GitHub (`gh api`) and how it behaves offline. It should skip GitHub checks with a `SKIP` line rather than fail.

## Consequences

- Owners get their own conventions applied with no configuration. An owner without a `.github` repository gets sensible defaults and a few questions.
- Suggestions based on peer repos depend on how consistent the owner's repos are. When the owner has few or inconsistent repos, there are just fewer suggestions.
- Rewriting history is allowed, but only when the user asks for it. Done before the repo is first made public, it does the least damage, because there are no outside clones or forks yet. Done afterwards, GitHub may keep the old commits reachable through cached views and pull request refs until GitHub Support purges them, and the skill says so.
- The built-in secret scan is weaker than gitleaks. The report says which scanner ran, so a clean result isn't over-trusted.
- Adding the skill is a minor change for thetaskills: the next release is 0.2.0, with the version bumped in all four manifests.
- Builds that never use `gh` are out of scope until someone needs them.
