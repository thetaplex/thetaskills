---
name: open-source-ready
description: Gets a GitHub repository ready to make public, following its owner's conventions from their .github repo and other public repos - license and NOTICE, contributing and changelog, issue templates, Dependabot, a secret and history scan, README, tests and CI, a release - then stops and prints the command to make it public. Use when the user says "open source this repo", "make this repo public", "is this repo ready to open source", "prepare this repo for open source" or "open-source readiness check".
---

# Open-source ready

Get the current repository ready to make public. Every change goes through a branch and a pull request. Making the repo public is the user's step, never yours.

Requires `gh`, logged in. `scripts/` and `references/` are relative to this skill's folder.

## Steps

1. **Check.** Run `bash scripts/check.sh <repo-dir>`. Each line is `STATUS check detail`. `MISSING` and `FAIL` need fixing, `DIFF` and `WARN` need the user's attention, and `INFO` lines carry the owner, visibility and peer conventions. If the output says `SKIP ... offline`, ask the user to run `gh auth login`, then check again.

2. **Branch.** Create a branch from the default branch, for example `chore/open-source-ready`. Make every fix there.

3. **Fix what's `MISSING`.** Never overwrite an existing file.
   - **license and notice:** if the `INFO owner` line names a public `<owner>/.github`, copy its file: `gh api repos/<owner>/.github/contents/LICENSE -H 'Accept: application/vnd.github.raw' > LICENSE` (the same for `NOTICE`). Otherwise ask the user which license to use and who the copyright holder is. Add a `NOTICE` for Apache-2.0.
   - **contributing, changelog, code-of-conduct, security-policy:** use `references/community.md`. Add a code of conduct or security policy only when `check.sh` reports it `MISSING`. Files inherited from `<owner>/.github` are already covered.
   - **issue-templates:** copy all three files from `references/issue-templates/` into `.github/ISSUE_TEMPLATE/`. Adding only some would hide all of the owner's templates. Fill in the placeholders, and make the bug form's required fields fit this project (read the code to tell whether it's a CLI, a library or a service).
   - **dependabot:** follow `references/dependabot.md`, using the ecosystems on the `dependabot` line.
   - **gitignore:** add the listed entries.
   - **tests:** ask the user for the test command, then check again with `OSR_TEST_CMD="<cmd>"`. If tests fail, stop and report. Fixing them is a separate task.
   - **ci:** report it. A red CI run blocks the release.
   - **description:** propose one matching the README's opening line, and set it with `gh repo edit --description` once the user confirms.

4. **Secrets.** On `FAIL secrets`, stop and follow `references/history-rewrite.md`. The user picks rotate only, rewrite history, or stop. Never rewrite history without their explicit go-ahead.

5. **Report what needs the user's attention.**
   - **`DIFF license`:** the repo's license differs from the owner's. Leave it unchanged and say so.
   - **`WARN emails`:** list the addresses. Offer the mailmap rewrite in `references/history-rewrite.md`, or leave them if they're meant to be public.
   - **`WARN home-paths`:** suggest replacing each path with a placeholder.
   - **`peers` lines:** if most of the owner's other repos have something this repo lacks, suggest it. Never apply it automatically.

6. **README.** Go through `references/readme-checklist.md` and write any missing parts.

7. **Check again** until `check.sh` exits 0, apart from items the user chose to accept.

8. **Pull request.** Commit with the repo's commit convention and ask before pushing. Open one PR that lists what changed and what the user accepted as-is.

9. **Release, after the PR is merged.** Propose a version: `0.1.0` if the repo has never been released, otherwise the next Semantic Versioning version based on the `Unreleased` entries. Once the user confirms, move the entries into a new version section of `CHANGELOG.md` (through a PR if the default branch is protected). Then tag it, push the tag, and run `gh release create <tag> --notes-file <that section>`. Ask before each push, tag and release.

10. **Stop.** If `INFO visibility` says `PRIVATE`, end with this command, and don't run it:

    ```bash
    gh repo edit <owner>/<repo> --visibility public --accept-visibility-change-consequences
    ```

    If the repo is already public, say so instead.

## Rules

- Never overwrite an existing file, and never change a file reported as `DIFF`.
- Ask before every push, tag, release, history rewrite and repo setting change.
- Never change the repo's visibility.
