#!/usr/bin/env bash
# One-time (and re-runnable) machine setup for the shared agent stack.
#   Skills  : superpowers, ponytail, new-project  -> ~/.agents/skills  (pi + opencode read this; Strands is pointed at it)
#   CLIs    : openspec, rtk, headroom
#   Hooks   : rtk rewrite hooks for opencode and pi
# Re-run any time to update everything.
set -eo pipefail

STACK="${AGENT_STACK_HOME:-$HOME/.agent-stack}"   # git checkouts live here
SKILLS="$HOME/.agents/skills"                     # Agent Skills standard location
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"   # .../skills/new-project
REPO_DIR="$(cd "$SKILL_DIR/../.." && pwd -P)"
mkdir -p "$STACK" "$SKILLS"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

clone_or_pull() { # <url> <dir>
  if [ -d "$2/.git" ]; then git -C "$2" pull --ff-only -q || warn "could not update $2"
  else git clone -q --depth 1 "$1" "$2"; fi
}

link_pack() { # <checkout dir>: symlink each skill folder flat into ~/.agents/skills
  for d in "$1"/skills/*/; do
    [ -f "$d/SKILL.md" ] && ln -sfn "${d%/}" "$SKILLS/$(basename "$d")"
  done
}

# --- 1. Skill packs ---------------------------------------------------------
log "Skill packs -> $SKILLS"
clone_or_pull https://github.com/obra/superpowers       "$STACK/superpowers"
clone_or_pull https://github.com/DietrichGebert/ponytail "$STACK/ponytail"
link_pack "$STACK/superpowers"
link_pack "$STACK/ponytail"

# From a git checkout (install.sh), link new-project so `git pull` updates it.
# From `npx skills add`, the skill is already installed where your agent looks - leave it alone.
if [ -f "$REPO_DIR/install.sh" ]; then
  ln -sfn "$SKILL_DIR" "$SKILLS/new-project"
  chmod +x "$SKILL_DIR/scripts/"*.sh
fi

for l in "$SKILLS"/*; do [ -L "$l" ] && [ ! -e "$l" ] && rm "$l"; done   # drop links to removed skills

# --- 2. OpenSpec (per-repo init happens in the new-project skill) ------------
log "OpenSpec"
if have npm; then { npm install -g @fission-ai/openspec@latest >/dev/null && openspec --version; } || warn "openspec install failed"
else warn "npm not found - install Node.js >= 20.19, then: npm install -g @fission-ai/openspec@latest"; fi

# --- 3. rtk (Rust Token Killer) ---------------------------------------------
log "rtk"
if ! rtk gain >/dev/null 2>&1; then
  if have brew; then brew install rtk || warn "brew install rtk failed"
  elif have cargo; then cargo install --git https://github.com/rtk-ai/rtk rtk || warn "cargo install rtk failed"
  else warn "install rtk via brew, cargo, or https://github.com/rtk-ai/rtk/releases"; fi
fi
if rtk gain >/dev/null 2>&1; then
  have opencode && { rtk init -g --opencode || warn "rtk opencode hook failed"; }
  if have pi; then
    rtk init -g --agent pi 2>/dev/null \
      || pi install git:github.com/capyup/pi-rtk \
      || warn "no rtk hook for pi - agents will follow the AGENTS.md rtk rule instead"
  fi
else
  warn "'rtk gain' fails - either rtk is missing or the wrong 'rtk' (Rust Type Kit) is on PATH"
fi

# --- 4. headroom (context compression proxy) --------------------------------
log "headroom"
if ! have headroom; then
  if have uv; then uv tool install --python 3.13 "headroom-ai[all]" || warn "headroom install failed"
  elif have pipx; then pipx install "headroom-ai[all]" || warn "headroom install failed"
  else warn "install uv (or pipx), then: uv tool install --python 3.13 'headroom-ai[all]'"; fi
fi
cat > "$STACK/aliases.sh" <<'EOF'
# Source from ~/.bashrc or ~/.zshrc:  source ~/.agent-stack/aliases.sh
# headroom compresses at launch time, so start agents through it.
alias oc='headroom wrap opencode'
# pi isn't in headroom's wrap list: run `headroom proxy --port 8787` and point pi's provider baseUrl at it.
EOF

# --- 5. Summary --------------------------------------------------------------
log "Done. Skills installed:"
ls -1 "$SKILLS" | sed 's/^/     /'
cat <<EOF

Next:
  * Add to your shell rc:  source $STACK/aliases.sh
  * Optional always-on modes (the skills above already work without these):
      pi:       pi install git:github.com/DietrichGebert/ponytail
      opencode: add "superpowers@git+https://github.com/obra/superpowers.git" and
                "@dietrichgebert/ponytail" to the plugin list in ~/.config/opencode/opencode.json
  * Strands: see examples/strands_agent.py in the agent-stack repo.
  * In any agent, say: "let's start a new project"
EOF
