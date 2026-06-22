#!/usr/bin/env bash
# master-brain :: lookup helper for the captured Skool classroom (classroom/).
#
# The classroom is the canonical, human-written documentation for the whole
# AI Marketing Hub — setup, which-skill-when, client delivery, prompt library.
# This helper lets a command pull the ONE relevant lesson on demand instead of
# loading the whole 1.4 MB corpus into context.
#
# Usage:
#   bash classroom.sh search <query>   # lessons matching title OR body (relevance-ish)
#   bash classroom.sh list             # all courses → lessons (the index)
#   bash classroom.sh courses          # just the 12 course names
#   bash classroom.sh show <rel-path>  # print one lesson (e.g. 03-how-it-all-works/04-which-skill-when.md)
#
# Resolves classroom/ next to this scripts/ dir, honoring $CLAUDE_PLUGIN_ROOT
# (plugin install) and falling back to the script's own location (skill clone).

set -uo pipefail

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLASSROOM="$ROOT/classroom"

if [ ! -d "$CLASSROOM" ]; then
  echo "classroom/ not found at $CLASSROOM" >&2
  echo "Re-capture with: node \"$ROOT/scripts/classroom-to-md.mjs\" <raw.json> classroom" >&2
  exit 1
fi

cmd="${1:-list}"; shift || true

# Print "<rel-path>\t<course> › <lesson>" for a lesson file.
_label() {
  local f="$1" rel course lesson
  rel="${f#"$CLASSROOM"/}"
  course=$(sed -n 's/^course:[[:space:]]*"\(.*\)"/\1/p' "$f" | head -1)
  lesson=$(sed -n 's/^lesson:[[:space:]]*"\(.*\)"/\1/p' "$f" | head -1)
  printf '%s\t%s › %s\n' "$rel" "${course:-?}" "${lesson:-?}"
}

case "$cmd" in
  search)
    q="$*"
    [ -z "$q" ] && { echo "usage: classroom.sh search <query>" >&2; exit 2; }
    # Title hits first (frontmatter `lesson:` line), then body hits — deduped.
    { grep -rilE "^lesson:.*$q" --include='*.md' "$CLASSROOM" 2>/dev/null
      grep -rilE "$q"            --include='*.md' "$CLASSROOM" 2>/dev/null
    } | grep -v '/\.raw/' | grep -v '/README\.md$' | awk '!seen[$0]++' | while read -r f; do
      _label "$f"
    done
    ;;
  list)
    sed -n 's/^## /\n# /p; s/^- \[\(.*\)\](\(.*\))/  \1  ->  \2/p' "$CLASSROOM/README.md"
    ;;
  courses)
    grep -E '^## ' "$CLASSROOM/README.md" | sed 's/^## //'
    ;;
  show|cat)
    rel="${1:-}"
    [ -z "$rel" ] && { echo "usage: classroom.sh show <rel-path>" >&2; exit 2; }
    f="$CLASSROOM/$rel"
    [ -f "$f" ] || { echo "not found: $rel" >&2; exit 1; }
    cat "$f"
    ;;
  *)
    echo "usage: classroom.sh {search <q>|list|courses|show <rel-path>}" >&2
    exit 2
    ;;
esac
