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

# --- Task 2: secrets, emails, home paths -----------------------------------
K="AKIA""ABCDEFGHIJKLMNOP"                       # fake key, assembled so this file never contains it
repo "$T/leak"; echo "key=$K" > "$T/leak/cfg"; git -C "$T/leak" add cfg; git -C "$T/leak" commit -qm add
git -C "$T/leak" rm -q cfg; git -C "$T/leak" commit -qm remove        # deleted, but still in history
run "$T/leak"; rc 1; has '^FAIL +secrets .*scanner: builtin'; hasnt "$K"

repo "$T/clean"; run "$T/clean"; has '^OK +secrets .*scanner: builtin'; has '^OK +emails'

repo "$T/mail"; echo y > "$T/mail/y"; git -C "$T/mail" add y
GIT_AUTHOR_EMAIL=dev@example.com git -C "$T/mail" commit -qm y; run "$T/mail"; has '^WARN +emails .*dev@example.com'

repo "$T/home"; echo "see /Use""rs/alice/x" > "$T/home/notes"; git -C "$T/home" add notes; git -C "$T/home" commit -qm n
run "$T/home"; has '^WARN +home-paths'
repo "$T/placeholder"; echo "/Users/<name>/x" > "$T/placeholder/n"; git -C "$T/placeholder" add n; git -C "$T/placeholder" commit -qm n
run "$T/placeholder"; hasnt '^WARN +home-paths'

mkdir -p "$T/fresh"; git -C "$T/fresh" init -q; run "$T/fresh"
[ "$RC" != 2 ] || { echo "fresh repo crashed:"; echo "$OUT"; exit 1; }; has '^OK +secrets .*no commits'
SHA=$(git -C "$T/leak" rev-parse HEAD~1)               # accepted finding, gitleaks fingerprint format
echo "$SHA:cfg:aws-access-token:1" > "$T/leak/.gitleaksignore"; run "$T/leak"; has '^OK +secrets'

# --- Task 3: gitignore, tests ----------------------------------------------
repo "$T/gi"; mkdir "$T/gi/.serena"; : > "$T/gi/.serena/x"; run "$T/gi"; has '^MISSING +gitignore .*\.serena'
printf '.serena/\n.DS_Store\n' > "$T/gi/.gitignore"; git -C "$T/gi" add .gitignore; git -C "$T/gi" commit -qm gi
run "$T/gi"; has '^OK +gitignore'

repo "$T/npm"; echo '{"scripts":{"test":"true"}}' > "$T/npm/package.json"; run "$T/npm"; has '^OK +tests .*npm test'
OUT=$(OSR_TEST_CMD=false bash "$C" "$T/npm" 2>&1); RC=$?; rc 1; has '^FAIL +tests'
repo "$T/notest"; run "$T/notest"; has '^MISSING +tests'
if command -v just >/dev/null; then
  printf 'check:\n\ttrue\n' > "$T/npm/justfile"; run "$T/npm"; has '^OK +tests .*just check'; rm "$T/npm/justfile"
fi

repo "$T/my repo"; ( cd / && run "$T/my repo"; [ "$RC" != 2 ] ) || { echo "path with spaces failed"; exit 1; }

for d in empty eco alt leak gi npm "my repo"; do              # read-only: no new or changed files
  before=$(git -C "$T/$d" status --porcelain); run "$T/$d"
  [ "$(git -C "$T/$d" status --porcelain)" = "$before" ] || { echo "check.sh changed $d"; exit 1; }
done
