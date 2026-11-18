#!/usr/bin/env bash
# check_style.py, sources.py and docket.py, run in a temp project folder.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
STYLE="$REPO/skills/write-ste/scripts/check_style.py"
SRC="$REPO/skills/source-triage/scripts/sources.py"
DOCKET="$REPO/skills/manage-docket/scripts/docket.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; cd "$T"
die() { echo "FAIL $*"; exit 1; }

# Style: a clean file passes, each rule fires once
printf '# Title\n\nWe tested the tool. It works.\n\n## References\n- [S1] Utilize; it was tested.\n' > ok.md
python3 "$STYLE" ok.md | grep -q "^PASS (2 sentences)" || die "clean file"
printf 'We utilize it. It was tested. Do not do this; ever. It is not done, don'"'"'t stop.\nThe citation error rate data grew.\n' > bad.md
out=$(python3 "$STYLE" bad.md) && die "bad file passed"
for r in word passive semicolon contraction noun-cluster; do grep -q "\[$r\]" <<<"$out" || die "no $r in: $out"; done
grep -q "utilize -> use" <<<"$out" || die "word hint"

# Sources: add, dedupe, list order, citation check
python3 "$SRC" add --url https://a.example --title "Paper A" --relevance 3 | grep -q "\[S1\]" || die "add S1"
python3 "$SRC" add --url https://b.example --title "Paper B" --relevance 5 --authors "Ng, Li" --year 2024 >/dev/null
python3 "$SRC" add --url https://a.example --title "Again" | grep -q "^exists \[S1\]" || die "dedupe"
[ "$(python3 "$SRC" list | head -1)" = "[S2] r=5 Paper B (Ng, Li, 2024) https://b.example" ] || die "list order"
printf 'Fact [S1].\n\n## References\n- [S1] A\n' > d.md
python3 "$SRC" check d.md | grep -q "Orphans (in ledger, never cited): S2" || die "orphans"
printf 'Fact [S9].\n' > d2.md
python3 "$SRC" check d2.md | grep -q "Missing from ledger (not allowed): S9" && die "missing key passed"

# Docket: add, dedupe, update, markdown, ics
python3 "$DOCKET" add --title "Renew cert" --priority 3 --due 2026-11-24 | grep -q "\[D1\]" || die "add D1"
python3 "$DOCKET" add --title "renew cert" | grep -q "^exists \[D1\]" || die "docket dedupe"
python3 "$DOCKET" add --kind event --title "Review" --due 2026-11-25T10:00 >/dev/null
python3 "$DOCKET" update D1 --status done | grep -q "done" || die "update"
grep -q "^- \[x\] \[D1\]" docket/DOCKET.md || die "DOCKET.md"
python3 "$DOCKET" ics --title "Review, arch" --start 2026-11-25T10:00 --end 2026-11-25T11:00 >/dev/null
grep -q "DTSTART:20261125T100000" docket/calendar/review-arch.ics || die "ics start"
grep -q 'SUMMARY:Review\\, arch' docket/calendar/review-arch.ics || die "ics escape"
python3 "$DOCKET" update D9 --status done 2>/dev/null && die "unknown key passed"
true
