#!/usr/bin/env bash
# Per-repo setup for the vibe-scaffold skill. Idempotent. Prints OK/SKIP/WARN/FAIL lines.
DIR="${1:-$PWD}"
mkdir -p "$DIR" && cd "$DIR" || { echo "FAIL cannot enter $DIR"; exit 1; }

ok()   { echo "OK   $*"; }
skip() { echo "SKIP $*"; }
warn() { echo "WARN $*"; }
fail() { echo "FAIL $*"; }
have() { command -v "$1" >/dev/null 2>&1; }

echo "Project: $(pwd)"

# Refuse to nest inside another repo unless asked (avoids a second openspec/ + AGENTS.md in a subfolder)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -n "$ROOT" ] && [ "$(cd "$ROOT" && pwd -P)" != "$(pwd -P)" ] && [ -z "$ALLOW_SUBDIR" ]; then
  echo "STOP inside existing repo $ROOT - rerun with the repo root as the argument, or ALLOW_SUBDIR=1 to set up this subfolder"
  exit 2
fi

# git
if [ -n "$ROOT" ]; then skip "git repo already exists"
else git init -q && ok "git init"; fi

# OpenSpec
TOOLS="$OPENSPEC_TOOLS"
if [ -z "$TOOLS" ]; then
  for t in opencode pi claude; do have "$t" && TOOLS="${TOOLS:+$TOOLS,}$t"; done
  TOOLS="${TOOLS:-none}"
fi
if ! have openspec; then
  fail "openspec not installed (npm install -g @fission-ai/openspec@latest)"
elif [ -d openspec ]; then
  openspec update >/dev/null 2>&1 && ok "openspec update" || warn "openspec update failed"
else
  openspec init --tools "$TOOLS" --force >/dev/null 2>&1 \
    && ok "openspec init (tools: $TOOLS)" || fail "openspec init --tools $TOOLS failed"
fi

# AGENTS.md block (read natively by pi and opencode; Strands loads it as system prompt)
if grep -q 'agent-stack:start' AGENTS.md 2>/dev/null; then
  skip "AGENTS.md already has the agent-stack block"
else
  [ -s AGENTS.md ] || printf '# Project\n\n<!-- describe the project -->\n' > AGENTS.md
  cat >> AGENTS.md <<'EOF'

<!-- agent-stack:start -->
## How we work here
- **Specs first (OpenSpec):** for anything non-trivial, propose a change with `/opsx:propose` (or the `openspec-propose` skill) before writing code. Specs live in `openspec/`.
- **Process (superpowers):** brainstorming -> writing-plans -> test-driven-development -> requesting-code-review.
- **Code (ponytail):** the simplest thing that works. Reuse what's already in the repo, the stdlib or the platform before adding code or dependencies. No abstractions nobody asked for.
- **Shell (rtk):** if commands aren't rewritten automatically, prefix noisy ones with `rtk` (e.g. `rtk git status`, `rtk cargo test`).
<!-- agent-stack:end -->
EOF
  ok "AGENTS.md agent-stack block added"
fi

# Global stack checks (installed by setup.sh, not here)
S="$HOME/.agents/skills"
for s in brainstorming ponytail; do
  [ -f "$S/$s/SKILL.md" ] && ok "skill $s" || fail "skill $s missing from $S (run scripts/setup.sh)"
done
rtk gain >/dev/null 2>&1 && ok "rtk" || fail "rtk missing or wrong binary (run scripts/setup.sh)"
have headroom && ok "headroom" || warn "headroom not installed (run scripts/setup.sh)"
