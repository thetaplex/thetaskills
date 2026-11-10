# Secrets found in history

A finding blocks the release until it is resolved. Always recommend rotating a leaked secret first, because once anything was pushed, removing it from history doesn't make it secret again.

Show the user the findings (commit and file, never the value) and let them pick one option:

1. **Rotate only.** Revoke the secret and leave history as it is. If the user accepts the finding, add its fingerprint to `.gitleaksignore` (`<commit-sha>:<file>:<rule>:<line>`, or `<commit-sha>:<file>` for the builtin scanner), so later runs don't block on it again.
2. **Rewrite history.** Do this only when the user explicitly says so, after following the steps below.
3. **Stop.** Leave everything as it is and don't release.

## Before rewriting, tell the user

- Every commit SHA changes from the first affected commit onwards.
- Existing clones and forks keep the old history.
- Open pull requests break, and tags have to be recreated.
- If the repo was ever public, GitHub may keep the old commits reachable through cached views and pull request refs until GitHub Support purges them.

## Procedure

Requires `git filter-repo` (https://github.com/newren/git-filter-repo; for example `brew install git-filter-repo` or `uv tool install git-filter-repo`). If it isn't installed, say how to install it and stop. Never fall back to `git filter-branch`.

```bash
git clone --mirror <remote-url> /tmp/<repo>-rewrite.git && cd /tmp/<repo>-rewrite.git
git bundle create ../<repo>-backup.bundle --all            # backup of the original
# one run only: filter-repo refuses to run again on a clone it has already rewritten
#   replacements.txt: one literal per line, e.g.  <secret>==>REDACTED
#   mailmap: lines like  Proper Name <new@users.noreply.github.com> <old@example.com>
git filter-repo --replace-text ../replacements.txt --mailmap ../mailmap   # drop whichever flag isn't needed
```

1. Run `check.sh` again against the rewritten mirror (`git clone` it to a temp folder first) and confirm the finding is gone.
2. Ask the user again before pushing. Then run `git push --force --mirror <remote-url>` from the mirror, which rewrites every branch and tag. filter-repo removes the `origin` remote, so give the URL explicitly.
3. Tell the user to re-clone. Old clones must not be pushed again.
4. Delete `replacements.txt` once done, since it contains the secret.
