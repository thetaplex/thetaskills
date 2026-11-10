#!/usr/bin/env bash
# open-source-ready: read-only readiness checks for making a GitHub repo public.
# Usage: bash check.sh [repo-dir]   Prints "STATUS check detail" lines; never writes, never prompts.
# Exit: 0 = no MISSING/FAIL, 1 = at least one, 2 = not a git work tree.
# Env: OSR_OFFLINE=1 (skip GitHub checks), OSR_SCANNER=builtin|gitleaks, OSR_TEST_CMD="<cmd>".
set -u
DIR="${1:-$PWD}"
if ! git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf '%-7s %s %s\n' FAIL repo "not a git work tree: $DIR"; exit 2
fi
cd "$DIR" || exit 2
cd "$(git rev-parse --show-toplevel)" || exit 2

BAD=0
out() { printf '%-7s %s %s\n' "$1" "$2" "${3:-}"; case "$1" in MISSING|FAIL) BAD=1;; esac; }
has_any() { local p; for p in "$@"; do [ -e "$p" ] && return 0; done; return 1; }
first_of() { local p; for p in "$@"; do [ -e "$p" ] && { echo "$p"; return 0; }; done; return 1; }
community() { has_any "$1" ".github/$1" "docs/$1"; }   # GitHub looks in root, .github/ and docs/

# --- 1. Legal -----------------------------------------------------------------
LICENSE_FILE=$(first_of LICENSE LICENSE.md LICENSE.txt COPYING || true)
if [ -n "$LICENSE_FILE" ]; then out OK license "$LICENSE_FILE"; else out MISSING license "no LICENSE"; fi
IS_APACHE=""; [ -n "$LICENSE_FILE" ] && grep -q "Apache License" "$LICENSE_FILE" && IS_APACHE=1
if has_any NOTICE NOTICE.md NOTICE.txt; then out OK notice "NOTICE"
elif [ -n "$IS_APACHE" ]; then out MISSING notice "Apache-2.0 license without NOTICE"; fi

# --- 2. Community files ---------------------------------------------------------
for pair in contributing:CONTRIBUTING.md changelog:CHANGELOG.md; do
  name=${pair%%:*}; file=${pair#*:}
  if community "$file"; then out OK "$name" "$file"; else out MISSING "$name" "no $file"; fi
done

# --- 3. Issue templates -----------------------------------------------------
if [ -d .github/ISSUE_TEMPLATE ] && [ -n "$(ls -A .github/ISSUE_TEMPLATE 2>/dev/null)" ]; then
  out OK issue-templates ".github/ISSUE_TEMPLATE"
else out MISSING issue-templates "no .github/ISSUE_TEMPLATE"; fi

# --- 4. Dependabot ------------------------------------------------------------
ecosystems() { # print detected Dependabot ecosystems, space-separated
  local found="" f
  add() { case " $found " in *" $1 "*) ;; *) found="$found $1";; esac; }
  while IFS= read -r f; do
    case "$(basename "$f")" in
      package.json) add npm;;
      uv.lock) add uv;;
      requirements*.txt) add pip;;
      pyproject.toml) [ -e "$(dirname "$f")/uv.lock" ] || add pip;;
      Cargo.toml) add cargo;;
      go.mod) add gomod;;
      Gemfile) add bundler;;
      composer.json) add composer;;
      pom.xml) add maven;;
      build.gradle|build.gradle.kts) add gradle;;
      *.csproj) add nuget;;
      Dockerfile) add docker;;
    esac
  done < <(find . -maxdepth 3 \( -name node_modules -o -name .git \) -prune -o -type f -print 2>/dev/null)
  [ -d .github/workflows ] && add github-actions
  echo "${found# }"
}
if has_any .github/dependabot.yml .github/dependabot.yaml; then out OK dependabot ".github/dependabot.yml"
else eco=$(ecosystems); out MISSING dependabot "no .github/dependabot.yml; ecosystems: ${eco:-none detected}"; fi

# --- GitHub-dependent community files (online part added later) --------------
for pair in code-of-conduct:CODE_OF_CONDUCT.md security-policy:SECURITY.md; do
  name=${pair%%:*}; file=${pair#*:}
  if community "$file"; then out OK "$name" "$file"; else out SKIP "$name" "offline or gh not logged in"; fi
done

exit "$BAD"
