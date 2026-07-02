#!/usr/bin/env bash
# master-brain :: Stop-hook — nudge distilled write-back of substantive work into
# the current project's wiki/ vault.
#
# Context: claude-mem (and any raw activity log) already captures the granular
# trail. This hook keeps wiki/ (the *distilled* knowledge layer) from drifting
# stale when work happens that never touches the vault — Google Ads UI changes,
# LP/code edits, research, decisions. It only *reminds*; the actual note-writing
# is a model pass.
#
# Git-root-aware on purpose: master-brain projects are frequently subdirectories
# of a larger repo, so a `[ -d .git ]` guard (as some plugin hooks use) wrongly
# no-ops in them. We resolve the real repo root instead.
#
# Safe everywhere: exits 0 and stays silent unless the CWD is a vault project
# (has wiki/) with non-vault changes present. No output = no nudge.
set -u

proj="$(pwd)"

# Not a vault project -> nothing to do.
[ -d "$proj/wiki" ] || exit 0

# Not in a git work tree -> nothing to diff against.
root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[ -n "$root" ] || exit 0

# Any change under this project, excluding the vault's own managed paths.
# Scoped to $proj so sibling projects in the same repo don't trigger it.
changed="$(git -C "$root" status --porcelain -- "$proj" 2>/dev/null \
  | cut -c4- \
  | grep -vE "(^|/)(wiki|\.raw|\.vault-meta)/" \
  | head -1)"

[ -n "$changed" ] || exit 0

cat <<'MSG'
WIKI_WRITEBACK: Work happened this session outside wiki/. Before yielding, if substantive
work occurred (code, ads changes, LP edits, research, or a decision) and it is NOT already
reflected in wiki/, persist it now — distilled, not a raw dump:
  1. Append one dated line to wiki/log.md
  2. Update or create the relevant note under wiki/entities, wiki/concepts, or wiki/deliverables
  3. Refresh wiki/hot.md (it is a cache, not a journal: <500 words, overwrite fully)
  4. Ensure the note is linked from wiki/index.md
Keep it factual; cite data/ where a number comes from. The raw activity trail lives elsewhere,
so wiki/ only needs the durable, distilled version.
If this turn was only conversation/Q&A, or you already updated wiki/ this turn, do nothing
and stay silent.
MSG
