#!/usr/bin/env bash
# Render a Marp deck to PDF and report slides that don't fit.
# Usage: bash render.sh <deck.md> [out.pdf]
# Needs Node.js (npx) and Chrome or Chromium. Set CHROME to override the browser path.
# Prints "FIT <slide> <percent>% <title>" for every slide over 95% full.
# Exits 1 if any slide is over 100% (its content is cut off), else 0.
set -euo pipefail

DECK=${1:?usage: render.sh <deck.md> [out.pdf]}
[ -f "$DECK" ] || { echo "no such file: $DECK" >&2; exit 2; }
OUT=${2:-${DECK%.md}.pdf}
MARP="@marp-team/marp-cli@4.1.2"

if [ -z "${CHROME:-}" ]; then
  for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/Applications/Chromium.app/Contents/MacOS/Chromium" \
           google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then CHROME=$c; break; fi
  done
fi
[ -n "${CHROME:-}" ] || { echo "Chrome or Chromium not found; set CHROME=/path/to/chrome" >&2; exit 2; }

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
HTML="$T/deck.html"

# Marp's own --pdf export times out on some machines; printing its HTML with headless Chrome is reliable.
npx -y "$MARP" --no-stdin "$DECK" -o "$HTML" >/dev/null 2>&1 || { echo "marp failed on $DECK" >&2; exit 2; }

chrome() { "$CHROME" --headless=new --disable-gpu --no-first-run --user-data-dir="$T/profile" \
  --window-size=1280,720 --virtual-time-budget=10000 "$@" 2>/dev/null; }

# Fit check: measure each slide's content height against the slide height after fonts load.
FIT_JS='<script>document.fonts.ready.then(()=>{const o=[];document.querySelectorAll("section[id]").forEach((s,i)=>{const r=s.getBoundingClientRect();let m=0;s.querySelectorAll("*").forEach(e=>{if(e.closest("footer"))return;const b=e.getBoundingClientRect();if(b.height)m=Math.max(m,b.bottom-r.top)});const p=Math.round(100*m/r.height);if(p>95)o.push("FIT "+(i+1)+" "+p+"% "+((s.querySelector("h1,h2")||{}).textContent||"").trim())});const e=document.createElement("pre");e.id="fit-report";e.textContent="\n"+(o.join("\n")||"FIT ok")+"\n";document.body.appendChild(e)})</script>'
python3 - "$HTML" "$T/check.html" "$FIT_JS" <<'PY'
import sys
html = open(sys.argv[1], encoding="utf-8").read()
open(sys.argv[2], "w", encoding="utf-8").write(html.replace("</body>", sys.argv[3] + "</body>", 1))
PY
REPORT=$(chrome --dump-dom "file://$T/check.html" | sed -n '/id="fit-report"/,/<\/pre>/p' | grep '^FIT' || true)
[ -n "$REPORT" ] || { echo "fit check produced no report" >&2; exit 2; }
echo "$REPORT"

chrome --no-pdf-header-footer --print-to-pdf="$T/deck.pdf" "file://$HTML" >/dev/null
mv "$T/deck.pdf" "$OUT"
echo "wrote $OUT"

if echo "$REPORT" | awk '$1=="FIT" && $3+0>100 {bad=1} END {exit !bad}'; then
  echo "some slides overflow: split them or add <!-- _class: small -->" >&2
  exit 1
fi
