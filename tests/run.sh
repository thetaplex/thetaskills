#!/usr/bin/env bash
# All repo checks. Usage: bash tests/run.sh   (or npm test)
set -uo pipefail
cd "$(dirname "$0")/.."
FAILS=0
pass() { echo "ok   $*"; }
fail() { echo "FAIL $*"; FAILS=$((FAILS+1)); }

# 1. Every skill: valid frontmatter, name matches folder
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(sed -n '2,/^---$/s/^name: *//p' "$f" | head -1)
  desc=$(sed -n '2,/^---$/s/^description: *//p' "$f" | head -1)
  [ "$(head -1 "$f")" = "---" ] || { fail "$f: no frontmatter"; continue; }
  [ "$name" = "$dir" ] || fail "$f: name '$name' != folder '$dir'"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && [ ${#name} -le 64 ] || fail "$f: bad name '$name'"
  [ -n "$desc" ] && [ ${#desc} -le 1024 ] || fail "$f: description missing or > 1024 chars"
  [ -f "docs/$dir.md" ] || fail "$f: missing docs/$dir.md"
  grep -q "skills/$dir/" README.md || fail "$f: not listed in README.md"
  pass "skill $dir"
done

# 2. Manifests parse and versions agree
python3 - <<'PY' && pass "manifests" || fail "manifests"
import json, sys
files = {f: json.load(open(f)) for f in ["package.json", ".claude-plugin/plugin.json",
         ".claude-plugin/marketplace.json", ".codex-plugin/plugin.json", ".agents/plugins/marketplace.json"]}
v = {files["package.json"]["version"], files[".claude-plugin/plugin.json"]["version"],
     files[".codex-plugin/plugin.json"]["version"], files[".claude-plugin/marketplace.json"]["plugins"][0]["version"]}
if len(v) != 1: sys.exit(f"version mismatch: {v}")
if files["package.json"]["pi"]["skills"] != ["./skills"]: sys.exit("pi.skills must be ['./skills']")
PY

# 3. Shell scripts parse (and pass shellcheck when installed)
for s in scripts/*.sh skills/*/scripts/*.sh tests/*.sh; do
  bash -n "$s" || { fail "syntax $s"; continue; }
  if command -v shellcheck >/dev/null; then shellcheck -S error "$s" || { fail "shellcheck $s"; continue; }; fi
  pass "script $s"
done

# 4. Skill-specific tests
for t in tests/*.test.sh; do
  [ -f "$t" ] || continue
  bash "$t" && pass "$t" || fail "$t"
done

echo; [ "$FAILS" -eq 0 ] && echo "all checks passed" || { echo "$FAILS check(s) failed"; exit 1; }
