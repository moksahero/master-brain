#!/usr/bin/env bash
# master-brain :: single source of truth for the mb-managed section of a project's CLAUDE.md.
#
# Usage:
#   bash claude-md.sh emit             # print the managed block (with markers) to stdout
#   bash claude-md.sh sync [DIR]       # reconcile DIR/CLAUDE.md (default: cwd) to the canonical block
#
# The managed block is delimited by HTML-comment markers. Everything OUTSIDE the
# markers (project name, focus, market, active brains, API-key status, report
# language) is owned by the project and is NEVER touched.
#
#   /mb:init   writes the project-specific CLAUDE.md, then calls `sync .` to append
#              this section — so new projects ship with the markers in place.
#   /mb:update calls `sync .` on the current project to retrofit the section into
#              older projects and refresh it when this canonical text changes.
#
# Keeping the text here (not duplicated in init.md / SKILL.md) means the rule
# lives in ONE place; the commands reference it instead of re-stating it.

set -uo pipefail

START='<!-- mb:managed:start — auto-synced by /mb:update; do not edit between these markers, changes are overwritten -->'
END='<!-- mb:managed:end -->'

managed_block() {
  cat <<BLOCK
${START}
## Persistence — keep the work in the vault

This project is a Master Brain workspace. \`wiki/\` and \`data/\` are its durable
memory: **work that isn't written there is lost when the session ends.** So, as
a standing rule for every session in this directory:

- **\`wiki/\`** — the lasting knowledge. Any finding, decision, number, competitor
  fact, or deliverable summary worth more than this one chat → a note under
  \`wiki/\` (\`entities/\`, \`concepts/\`, \`sources/\`, \`deliverables/\`), a one-line
  entry in \`wiki/log.md\`, and a link from \`wiki/index.md\`. Update existing notes
  instead of duplicating.
- **\`data/\`** — the raw evidence behind that knowledge: API dumps
  (DataForSEO/Firecrawl), scrapes, exports, CSVs. Regenerable, but cite-able.
- **\`reports/\`** — rendered deliverables (PDF/HTML). Output, not memory.

Before finishing a substantive piece of work, write it back: update \`wiki/\`,
drop raw artifacts in \`data/\`, append \`wiki/log.md\`. Don't leave the vault
frozen at bootstrap while results pile up only in \`reports/\` or \`web/\`.
${END}
BLOCK
}

sync() {
  local dir="${1:-.}"
  local file="$dir/CLAUDE.md"

  if [ ! -f "$file" ]; then
    echo "claude-md: no CLAUDE.md in $dir — skip (run /mb:init to scaffold one)"
    return 0
  fi

  local blockfile tmp
  blockfile="$(mktemp)" || return 1
  tmp="$(mktemp)" || { rm -f "$blockfile"; return 1; }
  managed_block > "$blockfile"

  local had_markers="no"
  if grep -qF "$START" "$file" && grep -qF "$END" "$file"; then
    had_markers="yes"
    # Replace everything from START to END (inclusive) with the canonical block.
    awk -v s="$START" -v e="$END" -v bf="$blockfile" '
      BEGIN { while ((getline line < bf) > 0) block = block line ORS }
      index($0, s) { printf "%s", block; skip = 1; next }
      skip && index($0, e) { skip = 0; next }
      skip { next }
      { print }
    ' "$file" > "$tmp"
  else
    # No markers yet (older project) — append the block after a blank line.
    { cat "$file"; printf '\n'; cat "$blockfile"; } > "$tmp"
  fi

  if cmp -s "$file" "$tmp"; then
    echo "claude-md: $file already current — no change"
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
    [ "$had_markers" = "yes" ] && echo "claude-md: refreshed managed section in $file" \
                               || echo "claude-md: added managed section to $file"
  fi
  rm -f "$blockfile"
}

cmd="${1:-}"
case "$cmd" in
  emit) managed_block ;;
  sync) shift; sync "${1:-.}" ;;
  *)
    echo "usage: claude-md.sh {emit | sync [DIR]}" >&2
    exit 2
    ;;
esac
