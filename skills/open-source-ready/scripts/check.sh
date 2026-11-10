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

# --- 5. Secrets and personal data ----------------------------------------------
SCANNER="${OSR_SCANNER:-}"
[ -z "$SCANNER" ] && { command -v gitleaks >/dev/null 2>&1 && SCANNER=gitleaks || SCANNER=builtin; }
if ! git rev-parse -q --verify HEAD >/dev/null; then
  out OK secrets "no commits (scanner: $SCANNER)"
elif [ "$SCANNER" = gitleaks ]; then
  if gitleaks git --redact --no-banner --exit-code 1 . >/dev/null 2>&1 \
     || { [ $? -ne 1 ] && gitleaks detect --redact --no-banner --exit-code 1 >/dev/null 2>&1; }; then
    out OK secrets "history clean (scanner: gitleaks)"
  else out FAIL secrets "findings in history (scanner: gitleaks); run: gitleaks git --redact -v"; fi
else
  # ponytail: a handful of high-signal token patterns; install gitleaks for real coverage
  PAT='AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|sk-[A-Za-z0-9_-]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
  hits=$(git log --all -p --no-color --format='commit %H' 2>/dev/null | awk -v pat="$PAT" '
    /^commit / { c=$2; next }  /^\+\+\+ b\// { f=substr($0,7); next }
    /^\+/ && $0 ~ pat { print c ":" f }' | sort -u)
  if [ -n "$hits" ] && [ -f .gitleaksignore ]; then   # accepted findings: <sha>:<file>[:rule:line]
    hits=$(echo "$hits" | while IFS= read -r h; do grep -qF "$h" .gitleaksignore || echo "$h"; done)
  fi
  if [ -z "$hits" ]; then out OK secrets "history clean (scanner: builtin)"
  else out FAIL secrets "possible secrets in history (scanner: builtin) at $(echo "$hits" | tr '\n' ' ')"; fi
fi
if git rev-parse -q --verify HEAD >/dev/null; then
  emails=$(git log --all --format='%ae%n%ce' | sort -u | grep -v '@users\.noreply\.github\.com$' | tr '\n' ' ')
  if [ -z "$emails" ]; then out OK emails "all author emails are GitHub noreply"
  else out WARN emails "non-noreply author emails in history: ${emails% }"; fi
fi
paths=$(git grep -nIE '/(Users|home)/[a-z][a-z0-9._-]+/' 2>/dev/null | head -5 | cut -d: -f1,2 | tr '\n' ' ')
if [ -n "$paths" ]; then out WARN home-paths "absolute home paths in tracked files: ${paths% }"
else out OK home-paths "none in tracked files"; fi

# --- 6. Hygiene ----------------------------------------------------------------
unignored=""
git check-ignore -q --no-index .DS_Store || unignored=".DS_Store"
for d in .serena .idea .vscode .venv node_modules __pycache__ .env; do
  [ -e "$d" ] && ! git check-ignore -q --no-index "$d" && unignored="$unignored $d"
done
if [ -n "$unignored" ]; then out MISSING gitignore "not ignored: ${unignored# }"; else out OK gitignore ".gitignore covers OS and tool files"; fi

# --- 8. Tests -------------------------------------------------------------------
TEST_CMD="${OSR_TEST_CMD:-}"
if [ -z "$TEST_CMD" ] && command -v just >/dev/null 2>&1 && has_any justfile Justfile .justfile; then
  for r in check test; do just --summary 2>/dev/null | tr ' ' '\n' | grep -qx "$r" && { TEST_CMD="just $r"; break; }; done
fi
if [ -z "$TEST_CMD" ] && [ -f package.json ] && grep -q '"test"[[:space:]]*:' package.json; then
  if [ -f pnpm-lock.yaml ]; then TEST_CMD="pnpm test"; else TEST_CMD="npm test"; fi
fi
if [ -z "$TEST_CMD" ]; then out MISSING tests "no test command found (set OSR_TEST_CMD)"
else
  log=$(mktemp); trap 'rm -f "$log"' EXIT
  if sh -c "$TEST_CMD" >"$log" 2>&1; then out OK tests "$TEST_CMD passed"
  else out FAIL tests "$TEST_CMD failed"; tail -20 "$log" | while IFS= read -r l; do out INFO tests "$l"; done; fi
fi

# --- GitHub-dependent community files (online part added later) --------------
for pair in code-of-conduct:CODE_OF_CONDUCT.md security-policy:SECURITY.md; do
  name=${pair%%:*}; file=${pair#*:}
  if community "$file"; then out OK "$name" "$file"; else out SKIP "$name" "offline or gh not logged in"; fi
done

exit "$BAD"
