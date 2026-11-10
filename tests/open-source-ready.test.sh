#!/usr/bin/env bash
# Offline test for open-source-ready's check.sh, run against throwaway repos.
set -u
C="$(cd "$(dirname "$0")/.." && pwd)/skills/open-source-ready/scripts/check.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" GIT_CONFIG_NOSYSTEM=1 OSR_OFFLINE=1 OSR_SCANNER=builtin
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@users.noreply.github.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@users.noreply.github.com
mkdir -p "$HOME"

run() { OUT=$(bash "$C" "$1" 2>&1); RC=$?; }
has()   { echo "$OUT" | grep -qE "$1" || { echo "expected /$1/ in:"; echo "$OUT"; exit 1; }; }
hasnt() { ! echo "$OUT" | grep -qE "$1" || { echo "did not expect /$1/ in:"; echo "$OUT"; exit 1; }; }
rc()    { [ "$RC" = "$1" ] || { echo "expected exit $1, got $RC:"; echo "$OUT"; exit 1; }; }
repo() { # <dir> [file...]: new repo with README.md plus the given files, one commit
  local d="$1"; shift; mkdir -p "$d"; git -C "$d" init -q
  echo "# x" > "$d/README.md"
  for f in "$@"; do mkdir -p "$d/$(dirname "$f")"; : > "$d/$f"; done
  git -C "$d" add -A; git -C "$d" commit -qm init
}

# --- Task 1: local files ----------------------------------------------------
repo "$T/empty"; run "$T/empty"; rc 1
has '^MISSING +license'; has '^MISSING +contributing'; has '^MISSING +changelog'
has '^MISSING +issue-templates'; has '^MISSING +dependabot'
has '^SKIP +code-of-conduct'; has '^SKIP +security-policy'

repo "$T/eco" package.json uv.lock .github/workflows/ci.yml; run "$T/eco"
has '^MISSING +dependabot .*npm'; has '^MISSING +dependabot .*uv'; has '^MISSING +dependabot .*github-actions'

repo "$T/alt" LICENSE.md .github/CODE_OF_CONDUCT.md docs/SECURITY.md; run "$T/alt"
has '^OK +license'; has '^OK +code-of-conduct'; has '^OK +security-policy'

repo "$T/apache"; echo "Apache License" > "$T/apache/LICENSE"; run "$T/apache"; has '^MISSING +notice'
repo "$T/mit"; echo "MIT License" > "$T/mit/LICENSE"; run "$T/mit"; hasnt '^MISSING +notice'

mkdir -p "$T/plain"; run "$T/plain"; rc 2; has '^FAIL +repo'
