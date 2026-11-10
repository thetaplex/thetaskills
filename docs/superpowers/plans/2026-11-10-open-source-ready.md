# open-source-ready Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task by task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a skill, `open-source-ready`, that gets any GitHub repo ready to make public by following its owner's conventions, and stops right before the visibility change.

**Architecture:** `scripts/check.sh` is a read-only bash checker. It prints one status line per check and runs every mechanical check in the ADR (steps 1–6, 8 and 9). `SKILL.md` tells the agent to run it, fix the gaps on a branch using the starting shapes in `references/`, and confirm before each push, tag, release and history rewrite. An offline test drives `check.sh` against throwaway repos.

**Tech Stack:** bash, git, `gh` (with its `--jq` flag, so there's no separate `jq` dependency), optional `gitleaks` and `git filter-repo`.

**Spec:** `docs/adr/0001-open-source-ready-skill.md`

## Global Constraints

- No owner name, repo name, email address or URL from a specific owner anywhere under `skills/open-source-ready/`. URLs to public standards such as Keep a Changelog, Contributor Covenant and GitHub docs are fine.
- `check.sh` never writes to the repo and never prompts. It must be safe to run any number of times.
- `check.sh` must pass `shellcheck -S error` (CI runs shellcheck) and `bash -n`.
- The frontmatter `name` is `open-source-ready`, matching the folder. The `description` is at most 1024 characters and includes the trigger phrases "open source this repo", "make this repo public" and "is this repo ready to open source".
- Repo rules from `AGENTS.md`: human docs go in `docs/open-source-ready.md`, the README gets a skills table row, and there's no per-skill README.
- Skill-relative paths: `SKILL.md` refers to `scripts/check.sh` and `references/...`, relative to the skill folder.

## `check.sh` interface (shared by all tasks)

- **Usage:** `bash scripts/check.sh [repo-dir]`. Defaults to `$PWD`. Paths with spaces must work.
- **Output:** each line is `printf '%-7s %s %s\n' "$STATUS" "$CHECK" "$DETAIL"`.
  - `STATUS` is one of `OK`, `MISSING`, `DIFF`, `FAIL`, `WARN`, `SKIP`, `INFO`.
  - `CHECK` is one of `license`, `notice`, `contributing`, `changelog`, `code-of-conduct`, `security-policy`, `issue-templates`, `dependabot`, `secrets`, `emails`, `home-paths`, `gitignore`, `tests`, `ci`, `description`, `owner`, `peers`, `visibility`.
- **Exit codes:** 0 when there are no `MISSING` or `FAIL` lines; 1 when there is at least one; 2 when `repo-dir` isn't a git work tree. The last case prints `FAIL repo not a git work tree: <dir>`.
- **Environment variables:**
  - `OSR_OFFLINE=1` skips every GitHub check with a `SKIP` line. The script also falls back to this when `gh` is missing or `gh auth status` fails.
  - `OSR_SCANNER=builtin|gitleaks` forces the secret scanner. By default it uses gitleaks if installed, otherwise builtin.
  - `OSR_TEST_CMD` overrides test-command detection.
- **`WARN` lines don't affect the exit code.** My call: the ADR says to "flag" author emails and home paths, and a repo can publish a real email address on purpose. Secrets, by contrast, are `FAIL`.

## Review Focus

1. Legal files under other names: `LICENSE.md`, `LICENSE.txt` and `COPYING` count as a license. Test in Task 1.
2. Community files in `.github/` or `docs/`, which GitHub also checks, count as present locally. Test in Task 1.
3. A repo with no commits yet: the history scans must not crash, and the scan reports `OK` with "no commits". Test in Task 2.
4. A secret that was committed and then deleted is still in history and must still produce `FAIL`. Test in Task 2.
5. A `repo-dir` argument containing spaces, with the script run from somewhere else. Test in Task 3.

---

### Task 1: `check.sh` local file checks

**Files:**
- Create: `skills/open-source-ready/scripts/check.sh`
- Create: `tests/open-source-ready.test.sh`

**Interfaces:**
- Produces: `check.sh` with the interface above. Internal helpers that later tasks reuse: `out STATUS CHECK DETAIL` prints a line and records failures; `has_any PATH...` succeeds if any of the paths exists in the repo.

- [ ] **Step 1: Write the failing test.** `tests/open-source-ready.test.sh` follows `tests/vibe-scaffold.test.sh`: `set -u`, a `mktemp -d` work dir with `trap` cleanup, a sandboxed `HOME`, `GIT_CONFIG_NOSYSTEM=1`, fixed author and committer settings (`t@users.noreply.github.com`), and `export OSR_OFFLINE=1 OSR_SCANNER=builtin`. It also needs a helper `run DIR` that sets `OUT` and `RC`, and `has REGEX` / `hasnt REGEX`, which grep `OUT` and exit 1 with the output when the check fails. The cases are:
  - **empty-files repo**, with one commit containing `README.md` only. `RC=1`, and `OUT` matches `^MISSING +license`, `^MISSING +contributing`, `^MISSING +changelog`, `^MISSING +issue-templates` and `^MISSING +dependabot`. With `OSR_OFFLINE=1`, `code-of-conduct` and `security-policy` are `SKIP`.
  - **dependabot detection:** with `package.json`, `uv.lock` and `.github/workflows/ci.yml` present, the `dependabot` detail contains `npm`, `uv` and `github-actions`.
  - **alternate names:** with `LICENSE.md`, `.github/CODE_OF_CONDUCT.md` and `docs/SECURITY.md`, the output has `^OK +license`, `^OK +code-of-conduct` and `^OK +security-policy`.
  - **notice:** with an Apache-2.0 `LICENSE` (containing `Apache License`) and no `NOTICE`, the output has `^MISSING +notice`. With an MIT `LICENSE`, it has no `MISSING notice` line.
  - **not a repo:** running it on a plain directory gives `RC=2` and `^FAIL +repo`.

- [ ] **Step 2: Run the test and confirm it fails.** Run `bash tests/open-source-ready.test.sh`. Expected: it fails because `check.sh` doesn't exist.

- [ ] **Step 3: Implement the local checks in `check.sh`.**
  - **license:** `LICENSE`, `LICENSE.md`, `LICENSE.txt` or `COPYING` in the root.
  - **notice:** `MISSING` when the license contains `Apache License` and there's no `NOTICE`. Task 4 adds the owner-has-`NOTICE` case.
  - **contributing and changelog:** checked in the root, `.github/` and `docs/`.
  - **code-of-conduct and security-policy:** `OK` if found locally in the root, `.github/` or `docs/`, otherwise `SKIP` when offline. Task 4 adds the online lookup.
  - **issue-templates:** any file in `.github/ISSUE_TEMPLATE/`.
  - **dependabot:** `.github/dependabot.yml` or `.yaml`. When it's missing, the detail lists the detected ecosystems, using this map: `package.json`→`npm`, `uv.lock`→`uv`, `requirements*.txt` or `pyproject.toml` without `uv.lock`→`pip`, `Cargo.toml`→`cargo`, `go.mod`→`gomod`, `Gemfile`→`bundler`, `composer.json`→`composer`, `pom.xml`→`maven`, `build.gradle*`→`gradle`, `*.csproj`→`nuget`, `Dockerfile`→`docker`, `.github/workflows/`→`github-actions`. Search at most two directory levels deep, skipping `node_modules` and `.git`.

- [ ] **Step 4: Run the test and confirm it passes.** Run `bash tests/open-source-ready.test.sh && bash -n skills/open-source-ready/scripts/check.sh`. Expected: no output and exit code 0.

- [ ] **Step 5: Commit.** `git add skills/open-source-ready/scripts/check.sh tests/open-source-ready.test.sh && git commit -m "feat(open-source-ready): check legal, community and template files"`

### Task 2: Secrets, emails and home paths

**Files:**
- Modify: `skills/open-source-ready/scripts/check.sh`
- Modify: `tests/open-source-ready.test.sh`

**Interfaces:**
- Consumes: `out` and the `OSR_SCANNER` variable from Task 1.
- Produces: the `secrets` line, with its detail starting `scanner: builtin` or `scanner: gitleaks`, plus the `emails` and `home-paths` lines.

- [ ] **Step 1: Write the failing tests.** Build the fake key at runtime, `K="AKIA""ABCDEFGHIJKLMNOP"`, so the fake secret never sits in this repo's own files.
  - **secret in history:** commit a file containing `$K`, then delete it in the next commit. Expected: `RC=1`, `^FAIL +secrets`, and the detail contains `scanner: builtin`.
  - **clean:** a repo with no secrets has `^OK +secrets .*scanner: builtin`.
  - **email:** one commit authored by `dev@example.com` gives `^WARN +emails .*dev@example.com`. A noreply-only history gives `^OK +emails`.
  - **home path:** a tracked file containing `/Users/alice/x` gives `^WARN +home-paths`.
  - **no commits:** running after `git init` alone does not crash: `RC` isn't 2, and the output has `^OK +secrets .*no commits`.

- [ ] **Step 2: Run the tests and confirm they fail.** Run `bash tests/open-source-ready.test.sh`. Expected: it fails on the first secrets assertion.

- [ ] **Step 3: Implement the scans.**
  - **builtin:** run `git log --all -p --no-color` and grep it with `-E` for the patterns `AKIA[0-9A-Z]{16}`, `gh[pousr]_[A-Za-z0-9]{36}`, `github_pat_[A-Za-z0-9_]{22,}`, `sk-[A-Za-z0-9_-]{20,}`, `xox[baprs]-[A-Za-z0-9-]{10,}`, `AIza[0-9A-Za-z_-]{35}` and `-----BEGIN [A-Z ]*PRIVATE KEY-----`. Skip anything listed in `.gitleaksignore`. Report the commit and file of each match, never the secret's value.
  - **gitleaks:** `gitleaks git --redact --no-banner --exit-code 1`, falling back to `gitleaks detect --redact` on older versions.
  - **emails:** distinct values from `git log --all --format='%ae%n%ce'` that don't end in `@users.noreply.github.com`.
  - **home paths:** `git grep -nE '/(Users|home)/[a-z][a-z0-9._-]+/'` over tracked files, excluding the expected placeholders `/Users/<name>` and `/home/<name>`.

- [ ] **Step 4: Run the tests and confirm they pass.** Run `bash tests/open-source-ready.test.sh`. Expected: exit code 0.

- [ ] **Step 5: Commit.** `git commit -am "feat(open-source-ready): scan history for secrets, emails and home paths"`

### Task 3: gitignore and tests

**Files:**
- Modify: `skills/open-source-ready/scripts/check.sh`
- Modify: `tests/open-source-ready.test.sh`

**Interfaces:**
- Consumes: `out` from Task 1, and the `OSR_TEST_CMD` variable.
- Produces: the `gitignore` and `tests` lines.

- [ ] **Step 1: Write the failing tests.**
  - **untracked tool folder:** an untracked `.serena/` that isn't ignored gives `^MISSING +gitignore .*\.serena`. Once `.serena/` and `.DS_Store` are in `.gitignore`, the output has `^OK +gitignore`.
  - **tests passing:** `package.json` with `{"scripts":{"test":"true"}}` gives `^OK +tests .*npm test`.
  - **tests failing:** `OSR_TEST_CMD=false` gives `^FAIL +tests` and `RC=1`.
  - **no test command:** a repo without one gives `^MISSING +tests`.
  - **justfile:** a `justfile` with a `check:` recipe is chosen over `package.json`, giving the detail `just check`. Skip this case if `just` isn't installed.
  - **path with spaces:** a repo at `"$T/my repo"`, run from `/`, works and gives `RC` 0 or 1, never 2.
  - **read-only:** for every case, `git status --porcelain` is the same before and after the run.

- [ ] **Step 2: Run the tests and confirm they fail.** Run `bash tests/open-source-ready.test.sh`. Expected: it fails on the gitignore assertion.

- [ ] **Step 3: Implement both checks.**
  - **gitignore:** use `git check-ignore -q --no-index .DS_Store`. For each of `.serena .idea .vscode .venv node_modules __pycache__ .env` that exists in the working tree and isn't ignored, report `MISSING`.
  - **tests:** find the command in this order: `OSR_TEST_CMD`, then a `just` recipe `check` or `test`, then the `package.json` `scripts.test` (using pnpm when there's `pnpm-lock.yaml`, otherwise npm). Run it in the repo with stdout and stderr captured. On failure, print the last 20 lines as `INFO` lines.

- [ ] **Step 4: Run the tests and confirm they pass.** Run `bash tests/open-source-ready.test.sh`. Expected: exit code 0.

- [ ] **Step 5: Commit.** `git commit -am "feat(open-source-ready): check gitignore and run the test command"`

### Task 4: GitHub checks

**Files:**
- Modify: `skills/open-source-ready/scripts/check.sh`
- Modify: `tests/open-source-ready.test.sh`

**Interfaces:**
- Consumes: `out`, plus the `notice`, `code-of-conduct` and `security-policy` logic from Task 1.
- Produces: the `owner`, `visibility`, `ci`, `description` and `peers` lines, and the online versions of `license` (`DIFF`), `notice`, `code-of-conduct` and `security-policy`.

- [ ] **Step 1: Write the failing test.** With `OSR_OFFLINE=1`, the output has `^SKIP +owner`, `^SKIP +ci` and `^SKIP +description`, and the `RC` matches the local checks alone. Online behaviour can't be tested offline, so Task 7 checks it.

- [ ] **Step 2: Run the test and confirm it fails.** Run `bash tests/open-source-ready.test.sh`. Expected: it fails on `SKIP +owner`.

- [ ] **Step 3: Implement the online checks.** All of these run only when `gh` is installed and logged in. Otherwise each prints `SKIP <check> offline or gh not logged in`.
  - **owner and visibility:** `gh repo view --json nameWithOwner,visibility,defaultBranchRef,description` gives `INFO owner <owner>/<repo>` and `INFO visibility <PUBLIC|PRIVATE>`.
  - **owner `.github` repo:** check whether `<owner>/.github` exists and is public. If not, print `INFO owner no public <owner>/.github; defaults apply`.
  - **license:** compare the local license with the owner's copy using `gh api repos/<owner>/.github/contents/LICENSE -H 'Accept: application/vnd.github.raw'`. If they differ, report `DIFF`.
  - **notice:** if the owner has a `NOTICE` and the repo doesn't, report `MISSING`.
  - **code-of-conduct and security-policy:** if the owner's repo has the file in its root, `.github/` or `docs/`, report `OK inherited from <owner>/.github`. Otherwise report `MISSING`.
  - **ci:** if `.github/workflows/` exists, check the conclusion of the latest `gh run list --branch <default> --limit 1` run: `success` is `OK`, anything else is `FAIL`, and no runs is `MISSING`. Without workflows, report `SKIP ci no workflows`.
  - **description:** report `MISSING` when it's empty, otherwise `OK "<description>"`. The agent judges whether it matches the README.
  - **peers:** among the owner's public repos that aren't forks or archived (up to 50, excluding this one), count those with their own `.github/ISSUE_TEMPLATE` and those with `.github/dependabot.yml`. Print one line per convention, such as `INFO peers 3/4 have issue-templates`.

- [ ] **Step 4: Run the test and confirm it passes.** Run `bash tests/open-source-ready.test.sh`. Expected: exit code 0.

- [ ] **Step 5: Commit.** `git commit -am "feat(open-source-ready): check owner conventions, CI and description on GitHub"`

### Task 5: References

**Files:**
- Create: `skills/open-source-ready/references/issue-templates/bug_report.yml`, `feature_request.yml`, `config.yml`
- Create: `skills/open-source-ready/references/community.md`: starting versions of `CONTRIBUTING.md` and `CHANGELOG.md` (Keep a Changelog 1.1.0, SemVer 2.0.0), plus the fallback `CODE_OF_CONDUCT.md` (a link to Contributor Covenant 2.1 with a contact placeholder) and `SECURITY.md` (private vulnerability reporting).
- Create: `skills/open-source-ready/references/dependabot.md`: the ecosystem map from Task 1, a weekly `version: 2` template, and an instruction to check names against https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference#package-ecosystem- before writing.
- Create: `skills/open-source-ready/references/readme-checklist.md`: the ADR step 7 list.
- Create: `skills/open-source-ready/references/history-rewrite.md`: the ADR step 5 options, word for word, then the procedure: mirror clone, backup bundle, `git filter-repo --replace-text` or `--mailmap`, scan again, confirm, force-push branches and tags, and the note about GitHub's cached views.

- [ ] **Step 1: Write the files.** Use `<project>`, `<owner>/<repo>` and `<security-advisory-url>` as placeholders. The bug form has the API-key warning markdown and the required fields `version` and `environment`, and a comment telling the agent to adapt `environment` to the project type (CLI, library or service, as in the ADR step 3 examples). `config.yml` has `blank_issues_enabled: false` and a security contact link to `https://github.com/<owner>/<repo>/security/advisories/new`.
- [ ] **Step 2: Verify.** Run `python3 -I -c "import sys,yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]" skills/open-source-ready/references/issue-templates/*.yml` (or `ruby -ryaml` if PyYAML is missing), then `grep -rniE 'thetaplex|thetaskills|haraprasad' skills/open-source-ready`. Expected: the YAML parses, and grep finds nothing.
- [ ] **Step 3: Commit.** `git add skills/open-source-ready/references && git commit -m "feat(open-source-ready): add reference templates"`

### Task 6: `SKILL.md`, docs, README, CHANGELOG and ADR status

**Files:**
- Create: `skills/open-source-ready/SKILL.md`
- Create: `docs/open-source-ready.md`
- Modify: `README.md` (skills table), `CHANGELOG.md` (`### Added` under Unreleased), `docs/adr/0001-open-source-ready-skill.md` (status `Proposed` → `Accepted`, since the ADR was merged after review)

- [ ] **Step 1: Write `SKILL.md`.** Keep it under about 80 lines. It should have:
  - **Frontmatter** that meets the global constraints.
  - **Steps:**
    1. Run `bash scripts/check.sh`.
    2. Branch.
    3. Fix each `MISSING`, using `references/`. Copy `LICENSE`/`NOTICE` from the owner's repo with `gh api`, or ask which license to use when there's no owner `.github` repo. Don't change files reported as `DIFF`.
    4. Handle `FAIL secrets` through `references/history-rewrite.md`.
    5. Check the README with `references/readme-checklist.md`.
    6. Run `check.sh` again until it exits 0.
    7. Open one PR.
    8. After merge, propose a version and release it.
    9. Print the visibility command.
  - **Rules:**
    - Never overwrite an existing file.
    - Ask before every push, tag, release and history rewrite.
    - Never run the visibility change.
    - Suggest conventions from `peers` lines rather than applying them.
- [ ] **Step 2: Write `docs/open-source-ready.md`.** Sections: what it does; what it changes (only files in the repo, and nothing installed on the machine); requirements (`gh` logged in, with optional `gitleaks` and `git filter-repo`); running `check.sh` in CI with `OSR_OFFLINE=1`; uninstall (pointing to `INSTALL.md#uninstall`).
- [ ] **Step 3: Update the README and CHANGELOG.** README row: `| [open-source-ready](skills/open-source-ready/SKILL.md) | "open source this repo" | Gets a GitHub repo ready to make public using its owner's conventions, and stops before the switch. [Details](docs/open-source-ready.md) |`. CHANGELOG: `- \`open-source-ready\` skill: gets a GitHub repo ready to make public using its owner's conventions, and stops before the visibility change.`
- [ ] **Step 4: Verify.** Run `npm test`. Expected: `all checks passed`, including `ok   skill open-source-ready` and `ok   tests/open-source-ready.test.sh`.
- [ ] **Step 5: Commit.** `git add -A skills/open-source-ready docs README.md CHANGELOG.md && git commit -m "feat(open-source-ready): add skill instructions and docs"`

### Task 7: Smoke test on a real repo (no commit)

- [ ] **Step 1:** Run `bash skills/open-source-ready/scripts/check.sh` in this repo while online. Expected:
  - `INFO owner thetaplex/thetaskills`
  - `OK license`, with no `DIFF`, because it matches the owner's copy
  - `OK code-of-conduct` and `OK security-policy` (local copies)
  - `OK issue-templates`
  - `MISSING dependabot` detail listing `npm` and `github-actions`
  - `OK ci`
  - `INFO peers` lines
- [ ] **Step 2:** Paste the output into the PR body as evidence. A `MISSING dependabot` line here is a real finding for this repo, and fixing it belongs in a separate PR.
