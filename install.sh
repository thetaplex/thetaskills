#!/usr/bin/env bash
# thetaskills installer (from a git checkout). Re-run after `git pull`.
#   1. Symlinks every skills/*/ into ~/.agents/skills  (pi + opencode read it; Strands: examples/strands_agent.py)
#   2. Runs each skill's optional scripts/setup.sh for machine-wide dependencies.
# Install only some:  ./install.sh dev-env-setup [other-skill ...]
#   --link-only       skip step 2
set -eo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS="$HOME/.agents/skills"; mkdir -p "$SKILLS"

LINK_ONLY=""; NAMES=()
for a in "$@"; do [ "$a" = "--link-only" ] && LINK_ONLY=1 || NAMES+=("$a"); done
[ ${#NAMES[@]} -eq 0 ] && for d in "$REPO"/skills/*/; do NAMES+=("$(basename "$d")"); done

for n in "${NAMES[@]}"; do
  d="$REPO/skills/$n"
  [ -f "$d/SKILL.md" ] || { echo "!! no skill named $n" >&2; exit 1; }
  ln -sfn "$d" "$SKILLS/$n" && echo "linked $n"
done
for n in "${NAMES[@]}"; do
  s="$REPO/skills/$n/scripts/setup.sh"
  [ -z "$LINK_ONLY" ] && [ -f "$s" ] && { echo "==> setup: $n"; bash "$s"; }
done
echo "Done. Restart your agent to pick up new skills."
