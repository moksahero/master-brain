#!/usr/bin/env bash
# Lane 2 helper: for every URL in a list, pull the SERVED html and extract the
# fields the page-inventory table needs. Deterministic, no rendering, no guessing.
# Output is TSV on stdout (also written to findings/raw/page-inventory.tsv).
#
# Usage: bash page-inventory.sh findings/raw/urls.txt [outdir] [max-urls]
#   status  url  title  description  canonical  robots  og:title  h1  words  jsonld-types
set -uo pipefail

LIST="${1:?usage: page-inventory.sh <urls.txt> [outdir] [max]}"
OUT="${2:-.}"
MAX="${3:-300}"
RAW="$OUT/findings/raw/pages"
TSV="$OUT/findings/raw/page-inventory.tsv"
mkdir -p "$RAW"

UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36'

one() { # extract first regex match, strip tags, collapse whitespace
  grep -oiE "$2" "$1" 2>/dev/null | head -1 | sed -E 's/<[^>]+>//g; s/^[[:space:]]+|[[:space:]]+$//g' | tr '\t\n' '  '
}
attr() { # value of attr $3 from the first tag matching $2
  grep -oiE "$2" "$1" 2>/dev/null | head -1 | grep -oiE "$3=\"[^\"]*\"" | head -1 | sed -E "s/^$3=\"//I; s/\"$//" | tr '\t\n' '  '
}

printf 'status\turl\ttitle\tdescription\tcanonical\trobots\tog_title\th1\twords\tjsonld\n' > "$TSV"

n=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  n=$((n+1)); [ "$n" -gt "$MAX" ] && break
  slug="$(printf '%s' "$url" | tr -c 'A-Za-z0-9._-' '_' | cut -c1-120)"
  f="$RAW/$slug.html"
  code="$(curl -sSL --max-time 30 --compressed -A "$UA" -o "$f" -w '%{http_code}' "$url" 2>/dev/null)"

  title="$(one "$f" '<title[^>]*>[^<]*</title>')"
  desc="$(attr "$f" '<meta[^>]+name="description"[^>]*>' 'content')"
  canon="$(attr "$f" '<link[^>]+rel="canonical"[^>]*>' 'href')"
  robots="$(attr "$f" '<meta[^>]+name="robots"[^>]*>' 'content')"
  ogt="$(attr "$f" '<meta[^>]+property="og:title"[^>]*>' 'content')"
  h1="$(one "$f" '<h1[^>]*>.*</h1>')"
  words="$(sed -E 's#<script[^>]*>.*</script>##g; s#<style[^>]*>.*</style>##g' "$f" 2>/dev/null \
           | sed -E 's/<[^>]+>/ /g' | tr -s '[:space:]' ' ' | wc -w | tr -d ' ')"
  jsonld="$(grep -oE '"@type"[[:space:]]*:[[:space:]]*"[^"]+"' "$f" 2>/dev/null \
            | sed -E 's/.*"([^"]+)"$/\1/' | sort -u | paste -sd, - )"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$code" "$url" "${title:--}" "${desc:--}" "${canon:--}" "${robots:--}" \
    "${ogt:--}" "${h1:--}" "$words" "${jsonld:--}" >> "$TSV"
  printf '.' >&2
done < "$LIST"

echo >&2
cat "$TSV"
echo >&2
echo "✓ $TSV ($((n)) URLs)" >&2
echo "  Duplicate groups (the finding that usually matters most):" >&2
awk -F'\t' 'NR>1{t[$3]++; c[$5]++} END{
  print "    duplicate titles:";    for (k in t) if (t[k]>1) printf "      %3d × %s\n", t[k], substr(k,1,70)
  print "    duplicate canonicals:"; for (k in c) if (c[k]>1) printf "      %3d × %s\n", c[k], substr(k,1,70)
}' "$TSV" >&2
