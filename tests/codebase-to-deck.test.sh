#!/usr/bin/env bash
# render.sh: the template renders and fits; an overfull slide is reported and fails.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
RENDER="$REPO/skills/codebase-to-deck/scripts/render.sh"
TEMPLATE="$REPO/skills/codebase-to-deck/references/template.md"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
die() { echo "FAIL $*"; exit 1; }

# The template keeps the classes the slide patterns name.
for c in lead part faq small; do grep -q "section\.$c" "$TEMPLATE" || die "template lacks section.$c"; done
grep -q '^marp: true$' "$TEMPLATE" || die "template is not a Marp deck"

if ! command -v npx >/dev/null; then echo "skip render tests: npx not found"; exit 0; fi
bash "$RENDER" "$T/missing.md" 2>/dev/null && die "missing file accepted"
command -v google-chrome >/dev/null || command -v chromium >/dev/null || [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] \
  || [ -n "${CHROME:-}" ] || { echo "skip render tests: no Chrome"; exit 0; }

cp "$TEMPLATE" "$T/deck.md"
out=$(bash "$RENDER" "$T/deck.md") || die "template render failed: $out"
[ -s "$T/deck.pdf" ] || die "no PDF written"
grep -q '^FIT ok$' <<<"$out" || die "template slides too full: $out"

{ printf -- '---\nmarp: true\n---\n\n## Too long\n\n'; for i in $(seq 1 30); do echo "- line $i"; done; } > "$T/over.md"
out=$(bash "$RENDER" "$T/over.md") && die "overflow passed: $out"
grep -qE '^FIT 1 [0-9]{3}% Too long$' <<<"$out" || die "overflow not reported: $out"
