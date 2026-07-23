#!/usr/bin/env bash
# Phase 1 of the website audit: capture ground truth BEFORE any sub-agent runs.
# Writes raw evidence into findings/raw/ and a readable digest to
# findings/00-ground-truth.md. Everything here is fact, not interpretation:
# the digest is what you paste into every lane prompt.
#
# Usage: bash ground-truth.sh https://example.com [output-dir]
set -uo pipefail

URL="${1:?usage: ground-truth.sh <url> [outdir]}"
OUT="${2:-.}"
RAW="$OUT/findings/raw"
DIGEST="$OUT/findings/00-ground-truth.md"
mkdir -p "$RAW"

# Normalize: strip trailing slash, derive origin + host.
URL="${URL%/}"
ORIGIN="$(printf '%s' "$URL" | sed -E 's#^(https?://[^/]+).*#\1#')"
HOST="$(printf '%s' "$ORIGIN" | sed -E 's#^https?://##')"

UA_BOT='Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
UA_GPT='Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko); compatible; GPTBot/1.1; +https://openai.com/gptbot'
UA_HUMAN='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36'

fetch() { # fetch <ua> <url> <basename>
  curl -sSL --max-time 45 --compressed -A "$1" -D "$RAW/$3.headers" -o "$RAW/$3.html" "$2" 2>"$RAW/$3.err"
}

echo "→ homepage (human UA)"
fetch "$UA_HUMAN" "$URL" home
echo "→ homepage (Googlebot)"
fetch "$UA_BOT" "$URL" home-googlebot
echo "→ homepage (GPTBot)"
fetch "$UA_GPT" "$URL" home-gptbot

echo "→ robots.txt / sitemap.xml"
curl -sSL --max-time 20 -A "$UA_HUMAN" "$ORIGIN/robots.txt" -o "$RAW/robots.txt" 2>/dev/null
curl -sSL --max-time 30 -A "$UA_HUMAN" "$ORIGIN/sitemap.xml" -o "$RAW/sitemap.xml" 2>/dev/null

# Sitemap index → pull child sitemaps too, then collect every <loc>.
: > "$RAW/urls.txt"
collect_locs() { grep -oE '<loc>[^<]+</loc>' "$1" 2>/dev/null | sed -E 's#</?loc>##g'; }
if grep -qi '<sitemapindex' "$RAW/sitemap.xml" 2>/dev/null; then
  while IFS= read -r child; do
    [ -z "$child" ] && continue
    safe="$(printf '%s' "$child" | tr -c 'A-Za-z0-9._-' '_')"
    curl -sSL --max-time 30 -A "$UA_HUMAN" "$child" -o "$RAW/sitemap-$safe.xml" 2>/dev/null
    collect_locs "$RAW/sitemap-$safe.xml" >> "$RAW/urls.txt"
  done < <(collect_locs "$RAW/sitemap.xml")
else
  collect_locs "$RAW/sitemap.xml" >> "$RAW/urls.txt"
fi
sort -u -o "$RAW/urls.txt" "$RAW/urls.txt" 2>/dev/null

echo "→ soft-404 probe / compression / protocol"
SOFT404_CODE="$(curl -sS -o "$RAW/soft404.html" -w '%{http_code}' --max-time 25 -A "$UA_HUMAN" "$ORIGIN/mb-audit-nonexistent-$RANDOM" 2>/dev/null)"
SOFT404_BYTES="$(wc -c < "$RAW/soft404.html" 2>/dev/null | tr -d ' ')"
GZIP_HDR="$(curl -sSI --max-time 20 -H 'Accept-Encoding: gzip, br' -A "$UA_HUMAN" "$URL" 2>/dev/null | grep -i '^content-encoding:' | tr -d '\r')"
HTTP_VER="$(curl -sSo /dev/null --max-time 20 -w '%{http_version}' -A "$UA_HUMAN" "$URL" 2>/dev/null)"
REDIRECTS="$(curl -sSo /dev/null --max-time 25 -w '%{num_redirects} → %{url_effective} (%{http_code})' -A "$UA_HUMAN" "$URL" 2>/dev/null)"
curl -sSvI --max-time 20 "$URL" >"$RAW/tls.txt" 2>&1

# --- Digest ------------------------------------------------------------------
body_bytes=$(wc -c < "$RAW/home.html" | tr -d ' ')
# crude but honest: strip script/style, then tags, then count words
words=$(sed -E 's#<script[^>]*>.*</script>##g; s#<style[^>]*>.*</style>##g' "$RAW/home.html" 2>/dev/null \
        | sed -E 's/<[^>]+>/ /g' | tr -s '[:space:]' ' ' | wc -w | tr -d ' ')
grab() { grep -oiE "$1" "$RAW/home.html" 2>/dev/null | head -"${2:-3}"; }

{
  echo "# Ground truth — $HOST"
  echo
  echo "Captured: $(date -u '+%Y-%m-%d %H:%M UTC') · Target: $URL"
  echo
  echo "## Delivery"
  echo
  echo "| Signal | Value |"
  echo "| --- | --- |"
  echo "| Served HTML size | ${body_bytes} bytes |"
  echo "| Raw visible words (served HTML) | ${words} |"
  echo "| Redirects | ${REDIRECTS:-no data} |"
  echo "| HTTP version | ${HTTP_VER:-no data} |"
  echo "| Content-Encoding (gzip/br requested) | ${GZIP_HDR:-none returned} |"
  echo "| Invalid path status | ${SOFT404_CODE:-no data} (${SOFT404_BYTES:-0} bytes) |"
  echo "| Googlebot HTML size | $(wc -c < "$RAW/home-googlebot.html" 2>/dev/null | tr -d ' ') bytes |"
  echo "| GPTBot HTML size | $(wc -c < "$RAW/home-gptbot.html" 2>/dev/null | tr -d ' ') bytes |"
  echo "| Sitemap URLs found | $(wc -l < "$RAW/urls.txt" 2>/dev/null | tr -d ' ') |"
  echo
  if [ "${words:-0}" -lt 120 ]; then
    echo "> **SPA / no-SSR signal**: the served HTML carries only ${words} visible words."
    echo "> Treat \"what a crawler receives is not what a visitor sees\" as a headline finding"
    echo "> and confirm it per template in the technical-SEO and page-inventory lanes."
    echo
  fi
  echo "## Response headers (homepage)"
  echo
  echo '```'
  sed -e 's/\r$//' "$RAW/home.headers" 2>/dev/null | head -40
  echo '```'
  echo
  echo "## Head of the served HTML"
  echo
  echo '```html'
  grab '<title>[^<]*</title>' 1
  grab '<meta[^>]+name="description"[^>]*>' 1
  grab '<link[^>]+rel="canonical"[^>]*>' 2
  grab '<meta[^>]+name="robots"[^>]*>' 2
  grab '<meta[^>]+property="og:[^"]+"[^>]*>' 6
  grab '<html[^>]*lang="[^"]*"' 1
  grab '<link[^>]+hreflang="[^"]*"[^>]*>' 5
  echo '```'
  echo
  echo "## Structured data types present in served HTML"
  echo
  echo '```'
  grep -oE '"@type"[[:space:]]*:[[:space:]]*"[^"]+"' "$RAW/home.html" 2>/dev/null | sort | uniq -c | sort -rn || echo "none found"
  echo '```'
  echo
  echo "## robots.txt"
  echo
  echo '```'
  head -30 "$RAW/robots.txt" 2>/dev/null || echo "not retrieved"
  echo '```'
  echo
  echo "## Public URL list (first 60 of $(wc -l < "$RAW/urls.txt" 2>/dev/null | tr -d ' '))"
  echo
  echo '```'
  head -60 "$RAW/urls.txt" 2>/dev/null || echo "no sitemap URLs"
  echo '```'
  echo
  echo "Full list: \`findings/raw/urls.txt\` · raw captures: \`findings/raw/\`"
} > "$DIGEST"

echo
echo "✓ digest  → $DIGEST"
echo "✓ raw     → $RAW/"
echo "  Paste the digest into every lane prompt so no lane rediscovers it."
