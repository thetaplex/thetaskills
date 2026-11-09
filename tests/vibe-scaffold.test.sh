#!/usr/bin/env bash
# Smoke test for vibe-scaffold's bootstrap.sh in throwaway folders. Needs git; uses openspec if installed.
set -u
B="$(cd "$(dirname "$0")/.." && pwd)/skills/vibe-scaffold/scripts/bootstrap.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" OPENSPEC_TOOLS=opencode,pi GIT_CONFIG_NOSYSTEM=1; mkdir -p "$HOME"
check() { echo "$OUT" | grep -q "$1" || { echo "expected '$1' in:"; echo "$OUT"; exit 1; }; }

OUT=$(bash "$B" "$T/p")                      # fresh folder
check "OK   git init"; check "AGENTS.md agent-stack block added"
[ "$(grep -c 'agent-stack:start' "$T/p/AGENTS.md")" = 1 ] || { echo "block missing"; exit 1; }
if command -v openspec >/dev/null; then check "OK   openspec init"; [ -d "$T/p/openspec" ] || exit 1
else check "FAIL openspec not installed"; fi

OUT=$(bash "$B" "$T/p")                      # re-run is a no-op
check "SKIP git repo already exists"; check "SKIP AGENTS.md already has"
[ "$(grep -c 'agent-stack:start' "$T/p/AGENTS.md")" = 1 ] || { echo "block duplicated"; exit 1; }

mkdir -p "$T/p/sub"; OUT=$(bash "$B" "$T/p/sub"); RC=$?   # subfolder stops
[ $RC = 2 ] && check "STOP inside existing repo" || { echo "subfolder did not stop (rc=$RC)"; exit 1; }
[ ! -e "$T/p/sub/AGENTS.md" ] || { echo "subfolder was modified"; exit 1; }
OUT=$(ALLOW_SUBDIR=1 bash "$B" "$T/p/sub"); check "AGENTS.md agent-stack block added"
