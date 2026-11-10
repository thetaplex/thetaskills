# open-source-ready

Say **"open source this repo"** in a GitHub repository. The agent gets it ready to make public, following the owner's conventions, and stops just before the switch:

- **license and NOTICE:** copied from the owner's `.github` repo, or chosen by you if there isn't one
- **CONTRIBUTING.md and CHANGELOG.md** ([Keep a Changelog](https://keepachangelog.com/en/1.1.0/)), plus a code of conduct and security policy if the owner's `.github` repo doesn't provide them
- **issue templates** with fields that fit the project
- **`.github/dependabot.yml`** for the package managers it finds
- **a secret scan of the full git history,** plus author emails and absolute home paths
- **private vulnerability reporting,** turned on once you confirm, so security reports have somewhere to go
- **`.gitignore`, the README, tests, CI and the repo description**
- **a first release,** tagged and published once you confirm

It ends by printing `gh repo edit <owner>/<repo> --visibility public --accept-visibility-change-consequences`. You run that yourself.

## Where conventions come from

The owner's public [`.github` repository](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file) is the source. The skill copies its `LICENSE` and `NOTICE`, because GitHub never inherits those. It doesn't duplicate the files GitHub already inherits from there, such as the code of conduct and security policy. It also looks at the owner's five most recently updated public repos (skipping forks and archived repos), and if most of them have something (their own issue templates, Dependabot), it suggests the same thing. It never applies those automatically.

## What it changes

It changes files in the repository only, always on a branch, through one pull request. It asks before every push, tag, release, history rewrite and repo setting change. It installs nothing on your machine.

## Requirements

- [`gh`](https://cli.github.com), logged in (`gh auth login`)
- Optional: [`gitleaks`](https://github.com/gitleaks/gitleaks), for a thorough secret scan. Without it, a small built-in pattern scan runs, and the report says which one ran.
- Optional: [`git filter-repo`](https://github.com/newren/git-filter-repo), only if you choose to rewrite history to remove a secret

## The check script

`skills/open-source-ready/scripts/check.sh [repo-dir]` runs every mechanical check and changes nothing. Each line is `STATUS check detail`. It exits with code 0 when nothing is `MISSING` or `FAIL`, so you can use it in CI:

```bash
OSR_OFFLINE=1 bash skills/open-source-ready/scripts/check.sh
```

| Variable | Effect |
|---|---|
| `OSR_OFFLINE=1` | Skip the GitHub checks (owner conventions, CI, description) |
| `OSR_SCANNER=builtin` or `gitleaks` | Force a secret scanner |
| `OSR_TEST_CMD="<cmd>"` | The test command to run, if it can't be detected |

## Uninstall

Remove the skill as described in [INSTALL.md](../INSTALL.md#uninstall). It installs nothing else, so there's nothing more to remove.
