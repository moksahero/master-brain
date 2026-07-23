#!/usr/bin/env bash
# Lane 4 fallback capture: desktop + mobile, above-the-fold + full page.
# Preferred path is the Playwright MCP (it can dismiss popups, read the console,
# and time network idle). Use this when the MCP is not connected.
#
# Usage: bash capture.sh <url> <label> [outdir]
#   e.g. bash capture.sh https://example.com/pricing pricing
# Writes: screenshots/<label>-desktop-fold.png, -desktop-full.png,
#         screenshots/<label>-mobile-fold.png, -mobile-full.png
set -uo pipefail

URL="${1:?usage: capture.sh <url> <label> [outdir]}"
LABEL="${2:?usage: capture.sh <url> <label> [outdir]}"
OUT="${3:-.}/screenshots"
mkdir -p "$OUT"

command -v npx >/dev/null 2>&1 || { echo "npx not found — install Node 18+ or use the Playwright MCP" >&2; exit 1; }

shot() { # shot <viewport> <name> <extra flags...>
  local vp="$1" name="$2"; shift 2
  npx --yes playwright screenshot \
    --viewport-size="$vp" \
    --wait-for-timeout=3000 \
    "$@" "$URL" "$OUT/$name" >/dev/null 2>&1 \
    && echo "  ✓ $OUT/$name" \
    || echo "  ⚠ failed: $name (retry via Playwright MCP)" >&2
}

echo "→ $URL"
shot "1920,1080" "$LABEL-desktop-fold.png"
shot "1920,1080" "$LABEL-desktop-full.png" --full-page
shot "390,844"   "$LABEL-mobile-fold.png"  --device="iPhone 13"
shot "390,844"   "$LABEL-mobile-full.png"  --device="iPhone 13" --full-page

cat <<'EOF'

Still owed by the lane (this script cannot do it):
  · BEFORE / AFTER popup states — capture the interruption sequence in order
  · console errors per route
  · load time to network idle per route
  · DOM check: does the hero actually render on mobile, or is it just below the fold
Drive those through the Playwright MCP.
EOF
