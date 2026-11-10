# Community file starting points

Fill in every `<placeholder>`. Never overwrite an existing file.

## CONTRIBUTING.md

```markdown
# Contributing

Thanks for helping out.

1. Open an issue first for anything bigger than a small fix.
2. Make your change on a branch, one change per pull request.
3. Run `<test command>` before opening the pull request.
4. Add a line under `Unreleased` in CHANGELOG.md for user-visible changes.

By taking part you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
```

Use the repo's real test command (the `tests` line from `check.sh`). If the repo uses a commit convention, such as Conventional Commits, say so.

## CHANGELOG.md

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

[Unreleased]: https://github.com/<owner>/<repo>/commits/HEAD
```

## CODE_OF_CONDUCT.md (only when the owner's `.github` repo has none)

Use the full text of [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). Ask the user for the enforcement contact and put it in place of `[INSERT CONTACT METHOD]`.

## SECURITY.md (only when the owner's `.github` repo has none)

```markdown
# Security policy

## Reporting a vulnerability

Please do not open a public issue. Report privately through GitHub: **Security > Report a vulnerability** ([direct link](https://github.com/<owner>/<repo>/security/advisories/new)).

Include what you did, what happened, and the impact you expect.
```

Private vulnerability reporting must be turned on for that link to work. Check it with `gh api repos/<owner>/<repo>/private-vulnerability-reporting`, and turn it on after the user confirms with `gh api -X PUT repos/<owner>/<repo>/private-vulnerability-reporting`.
