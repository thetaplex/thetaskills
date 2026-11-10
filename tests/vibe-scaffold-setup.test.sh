#!/usr/bin/env bash
# Offline test for setup.sh's release pinning: latest_tag and clone_or_pull against a local repo.
set -u
S="$(cd "$(dirname "$0")/.." && pwd)/skills/vibe-scaffold/scripts/setup.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
mkdir -p "$HOME"
log() { :; }; warn() { echo "WARN $*"; }
eval "$(sed -n '/^latest_tag()/,/^}/p; /^clone_or_pull()/,/^}/p' "$S")"
die() { echo "FAIL $*"; exit 1; }

R="$T/remote"; git init -q "$R"
commit() { echo "$1" > "$R/f"; git -C "$R" add f; git -C "$R" commit -qm "$1"; }
URL="file://$R"

commit c1; [ -z "$(latest_tag "$URL")" ] || die "expected no tag"
OUT=$(clone_or_pull "$URL" "$T/a"); echo "$OUT" | grep -q "no release tag" || die "no fallback warning"

commit c2; git -C "$R" tag v1.2.0
commit c3; git -C "$R" tag v1.10.0              # 1.10 > 1.2: version sort, not string sort
commit c4; git -C "$R" tag v2.0.0-rc1; git -C "$R" tag nightly   # pre-release and odd tags ignored
commit c5                                         # untagged commit on main must not be used
[ "$(latest_tag "$URL")" = v1.10.0 ] || die "latest_tag gave '$(latest_tag "$URL")'"

clone_or_pull "$URL" "$T/b" >/dev/null; [ "$(cat "$T/b/f")" = c3 ] || die "fresh clone not at v1.10.0"
commit c6; git -C "$R" tag v1.11.0
clone_or_pull "$URL" "$T/b" >/dev/null; [ "$(cat "$T/b/f")" = c6 ] || die "re-run did not move to v1.11.0"
clone_or_pull "$URL" "$T/a" >/dev/null; [ "$(cat "$T/a/f")" = c6 ] || die "old branch checkout not moved to tag"
