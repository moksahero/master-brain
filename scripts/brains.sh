#!/usr/bin/env bash
# master-brain :: canonical registry of AI Marketing Hub brains + clone/update/status helpers.
#
# Usage:
#   bash brains.sh list      # print the brain repo names (one per line)
#   bash brains.sh install   # clone any missing brain, fast-forward the rest
#   bash brains.sh update    # same as install (idempotent)
#   bash brains.sh status    # show install state + version + last commit per brain
#
# Brains are private, members-only repos in the AI-Marketing-Hub org. Cloning
# requires that your git is authenticated to GitHub (SSH key or gh/credential
# helper). We try SSH first, then fall back to HTTPS.

set -uo pipefail

ORG="AI-Marketing-Hub"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# Canonical brains, in recommended read/install order.
#   claude-obsidian             knowledge substrate every brain writes into
#   website-brain               crawl a site into an Obsidian vault
#   marketing-brain             competitors + keywords + growth (SEO) plan
#   local-seo-brain             GBP / map pack / citations / reviews
#   claude-ads                  paid media audit + creative (Google/Meta/TikTok/...)
#   client-intelligence-report  the fused multi-brain client report (Mega-Brain)
BRAINS=(
  "claude-obsidian"
  "website-brain"
  "marketing-brain"
  "local-seo-brain"
  "claude-ads"
  "client-intelligence-report"
)

repo_url_ssh()   { printf 'git@github.com:%s/%s.git' "$ORG" "$1"; }
repo_url_https() { printf 'https://github.com/%s/%s.git' "$ORG" "$1"; }

clone_or_update() {
  local name="$1" dest="$SKILLS_DIR/$1"
  if [ -d "$dest/.git" ]; then
    printf '  \xe2\x86\xbb  %-28s updating\n' "$name"
    git -C "$dest" pull --ff-only 2>&1 | sed 's/^/        /' \
      || printf '        \xe2\x9a\xa0  pull failed (local changes? non-ff?)\n'
  elif [ -d "$dest" ]; then
    printf '  \xe2\x80\xa2  %-28s present but not a git checkout \xe2\x80\x94 leaving as-is\n' "$name"
  else
    printf '  \xe2\x86\x93  %-28s cloning\n' "$name"
    if git clone --depth 1 "$(repo_url_ssh "$name")" "$dest" >/dev/null 2>&1; then
      printf '        cloned via ssh\n'
    elif git clone --depth 1 "$(repo_url_https "$name")" "$dest" >/dev/null 2>&1; then
      printf '        cloned via https\n'
    else
      printf '        \xe2\x9a\xa0  clone failed \xe2\x80\x94 confirm AI Marketing Hub Pro access + git auth\n'
    fi
  fi
}

brain_status() {
  local name="$1" dest="$SKILLS_DIR/$1" ver="-" sha="-" state
  if [ -d "$dest/.git" ]; then
    state="git"
    sha="$(git -C "$dest" log -1 --format='%h %cd' --date=short 2>/dev/null || echo '-')"
  elif [ -d "$dest" ]; then
    state="dir"
  else
    state="MISSING"
  fi
  if [ -f "$dest/.claude-plugin/plugin.json" ]; then
    ver="$(grep -m1 '"version"' "$dest/.claude-plugin/plugin.json" | sed 's/[^0-9.]//g')"
  fi
  printf '  %-28s %-8s v%-8s %s\n' "$name" "$state" "${ver:--}" "$sha"
}

cmd="${1:-list}"
case "$cmd" in
  list)
    printf '%s\n' "${BRAINS[@]}"
    ;;
  install|update)
    echo "master-brain :: ${cmd} into ${SKILLS_DIR}"
    mkdir -p "$SKILLS_DIR"
    for b in "${BRAINS[@]}"; do clone_or_update "$b"; done
    echo "done."
    ;;
  status)
    echo "master-brain :: brain fleet in ${SKILLS_DIR}"
    printf '  %-28s %-8s %-9s %s\n' "BRAIN" "STATE" "VERSION" "LAST COMMIT"
    for b in "${BRAINS[@]}"; do brain_status "$b"; done
    ;;
  *)
    echo "usage: brains.sh {list|install|update|status}" >&2
    exit 2
    ;;
esac
