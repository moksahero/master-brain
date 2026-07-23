#!/usr/bin/env bash
# master-brain :: ship a /mb change everywhere in one command.
#
# The source of truth is THIS repo. A change here only takes effect once it is
# propagated to the local marketplace and the installed plugin cache (an
# unchanged version makes `claude plugin update` a no-op, so we bump first).
# This script does that whole chain so you never have to remember the steps.
#
# Usage:
#   bash scripts/ship.sh                 # bump patch + propagate + reinstall (LOCAL only)
#   bash scripts/ship.sh -m "feat: ..."  # also git add + commit + push to origin
#   bash scripts/ship.sh --minor -m ...  # bump minor instead of patch
#   bash scripts/ship.sh --no-bump -m .. # don't bump version (e.g. README-only)
#   bash scripts/ship.sh --dry-run       # show what would happen, change nothing
#
# Without -m it stops before git (so you can review), and tells you how to ship.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKETPLACE_NAME="ai-marketing-hub-master-brain"
PLUGIN_REF="mb@${MARKETPLACE_NAME}"

# Where the marketplace reads its files from. Three setups exist in the wild:
#   a) the marketplace is registered as a Directory pointing AT this checkout
#      (the common case) -> nothing to mirror, the source IS the marketplace;
#   b) a separate mirror dir (~/.claude/local-marketplaces/master-brain);
#   c) an explicit override via MB_MARKETPLACE_DIR.
# Resolve it from the CLI when we can, so a machine that never had the mirror dir
# still ships instead of dying at step 2.
resolve_marketplace_dir() {
  local from_cli
  [ -n "${MB_MARKETPLACE_DIR:-}" ] && { printf '%s' "$MB_MARKETPLACE_DIR"; return; }
  from_cli="$(claude plugin marketplace list 2>/dev/null \
    | awk -v n="$MARKETPLACE_NAME" '
        $0 ~ n {hit=1; next}
        hit && /Source: Directory \(/ { sub(/.*Source: Directory \(/,""); sub(/\).*/,""); print; exit }
        hit && /Source:/ {exit}')"
  if [ -n "$from_cli" ]; then printf '%s' "$from_cli"; return; fi
  if [ -d "$HOME/.claude/local-marketplaces/master-brain" ]; then
    printf '%s' "$HOME/.claude/local-marketplaces/master-brain"; return
  fi
  printf '%s' "$SRC"
}
MKT="$(resolve_marketplace_dir)"

bump="patch"; msg=""; dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--message) msg="${2:-}"; shift 2 ;;
    --minor)   bump="minor"; shift ;;
    --major)   bump="major"; shift ;;
    --no-bump) bump="none";  shift ;;
    --dry-run) dry=1; shift ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "ship: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

run() { if [ "$dry" = 1 ]; then echo "  [dry-run] $*"; else eval "$*"; fi; }
# argv-exact variant: no eval, so a multi-line commit message with quotes,
# backticks, or $ in it survives intact. Anything taking user text uses this.
runq() { if [ "$dry" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi; }

cur="$(grep -m1 '"version"' "$SRC/.claude-plugin/plugin.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$cur" ] || { echo "ship: could not read current version" >&2; exit 1; }

# --- 1. version bump (in source manifests) ---
new="$cur"
if [ "$bump" != "none" ]; then
  IFS=. read -r MA MI PA <<<"$cur"
  case "$bump" in
    patch) PA=$((PA+1)) ;;
    minor) MI=$((MI+1)); PA=0 ;;
    major) MA=$((MA+1)); MI=0; PA=0 ;;
  esac
  new="${MA}.${MI}.${PA}"
  echo "ship: version ${cur} -> ${new} (${bump})"
  # Rewrite EVERY "version": "x.y.z" in both manifests, not just occurrences of the
  # old plugin.json value: marketplace.json used to drift behind (0.6.7 while
  # plugin.json said 0.7.1) because it carried a different string and the old
  # match-the-current-version substitution silently skipped it.
  run "perl -0pi -e 's/\"version\": \"[0-9]+\\.[0-9]+\\.[0-9]+\"/\"version\": \"${new}\"/g' \
        '$SRC/.claude-plugin/plugin.json' '$SRC/.claude-plugin/marketplace.json'"
else
  echo "ship: version unchanged (${cur}); --no-bump means the cache may not refresh via plugin update"
fi

# --- 2. propagate source -> marketplace (mirror commands/, scripts/, manifests) ---
if [ "$MKT" = "$SRC" ]; then
  echo "ship: source repo IS the marketplace ($SRC) — nothing to mirror"
elif [ ! -d "$MKT" ]; then
  echo "ship: marketplace dir not found: $MKT" >&2
  echo "      set MB_MARKETPLACE_DIR, or re-add it:  claude plugin marketplace add $SRC" >&2
  exit 1
else
  echo "ship: propagate source -> ${MKT}"
  for sub in commands scripts skills .claude-plugin; do
    [ -d "$SRC/$sub" ] || continue
    run "rsync -a --delete '$SRC/$sub/' '$MKT/$sub/'"
  done
  for f in README.md LICENSE; do
    [ -f "$SRC/$f" ] && run "cp '$SRC/$f' '$MKT/$f'"
  done
fi

# --- 3. reinstall: refresh marketplace index + update the plugin cache ---
echo "ship: refresh marketplace + update plugin cache"
run "claude plugin marketplace update '$MARKETPLACE_NAME'"
run "claude plugin update '$PLUGIN_REF'"

# --- 3b. surface everything system-wide -----------------------------------------
# A new command or skill in this repo is invisible until it is wired into
# ~/.claude/commands: /mb:<cmd> comes from the refreshed plugin cache above, but
# the BARE aliases (/website-audit, /ads-google, every brain skill) and the
# master-brain brain-op command copies are written by brains.sh register. It is a
# fast, network-free, idempotent pass, so it runs on every ship. This is what
# makes "edit master-brain -> available everywhere" true without /mb:update.
echo "ship: register commands + bare skill aliases system-wide"
run "bash '$SRC/scripts/brains.sh' register"

# --- 4. git: only if a commit message was given ---
if [ -n "$msg" ]; then
  echo "ship: commit + push"
  runq git -C "$SRC" add -A
  runq git -C "$SRC" commit -m "$msg"
  runq git -C "$SRC" push origin HEAD
  echo "ship: shipped ${new} and pushed."
else
  echo
  echo "ship: LOCAL ship done (v${new}). Source repo is NOT committed/pushed."
  echo "      Review, then ship to GitHub with:  bash scripts/ship.sh --no-bump -m \"<message>\""
  echo "      (or re-run with -m to bump again + commit + push in one go)"
fi

echo "ship: restart Claude Code to load the updated /mb commands."
