#!/usr/bin/env bash
# master-brain :: canonical registry of AI Marketing Hub brains + clone/update/status helpers.
#
# Usage:
#   bash brains.sh list      # print the resolved brain repo names (one per line)
#   bash brains.sh discover  # gh-walk the org, print brains NOT already canonical
#   bash brains.sh install   # clone any missing brain, fast-forward the rest
#   bash brains.sh update    # same as install (idempotent)
#   bash brains.sh status    # show install state + version + last commit per brain
#
# Brains are private, members-only repos in the AI-Marketing-Hub org. Cloning
# requires that your git is authenticated to GitHub (SSH key or gh/credential
# helper). We try SSH first, then fall back to HTTPS.
#
# DISCOVERY: when the `gh` CLI is installed and authenticated, install/update/
# status/list walk the ENTIRE org and pick up any new brain automatically — so a
# repo added to AI-Marketing-Hub (e.g. social-hub) joins the fleet with no edit
# here. We include both Claude plugins and Obsidian-brain vaults, and exclude
# Codex-runtime variants (codex-*) and non-skill infra (see DENY_EXACT). Without
# gh, we degrade gracefully to the static canonical list below.

set -uo pipefail

ORG="AI-Marketing-Hub"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# Canonical brains, in recommended read/install order. Discovery appends any
# other org brains after these; this list just guarantees order + an offline
# fallback when gh is unavailable.
#   claude-obsidian             knowledge substrate every brain writes into
#   website-brain               crawl a site into an Obsidian vault
#   marketing-brain             competitors + keywords + growth (SEO) plan
#   local-seo-brain             GBP / map pack / citations / reviews
#   client-intelligence-report  the fused multi-brain client report (Mega-Brain)
# claude-ads is intentionally NOT here: it ships as a Claude plugin
# (claude-ads@ai-marketing-hub-claude-ads), installed by /mb:install, not cloned.
BRAINS=(
  "claude-obsidian"
  "website-brain"
  "marketing-brain"
  "local-seo-brain"
  "client-intelligence-report"
)

# Org repos that are NOT installable Claude brains: org infra, standalone apps,
# asset dumps, and master-brain itself. Codex-runtime variants (codex-*) are
# excluded separately by prefix. Edit this list to tune what discovery picks up.
DENY_EXACT=(
  # claude-ads is a real brain but ships as a Claude plugin, not a skills/ clone,
  # so exclude it from gh-discovery to avoid a dead duplicate in ~/.claude/skills.
  "claude-ads"
  ".github"
  "classroom-assets"
  "marketing-os"
  "member-workflows"
  "master-brain"
)

repo_url_ssh()   { printf 'git@github.com:%s/%s.git' "$ORG" "$1"; }
repo_url_https() { printf 'https://github.com/%s/%s.git' "$ORG" "$1"; }

# True (0) when a repo name should be skipped by discovery.
is_denied() {
  local name="$1" d
  case "$name" in codex-*) return 0 ;; esac
  for d in "${DENY_EXACT[@]}"; do [ "$name" = "$d" ] && return 0; done
  return 1
}

# Walk the org via gh and print every non-archived repo name. Silent no-op
# (returns non-zero) when gh is missing or not authenticated.
gh_org_repos() {
  command -v gh >/dev/null 2>&1 || return 1
  gh auth status >/dev/null 2>&1 || return 1
  gh repo list "$ORG" --limit 200 --json name,isArchived \
    --jq '.[] | select(.isArchived | not) | .name' 2>/dev/null
}

# Print the discovered brains that are NOT already in the canonical list.
discover_new() {
  local name found b
  gh_org_repos | while IFS= read -r name; do
    [ -z "$name" ] && continue
    is_denied "$name" && continue
    found=0
    for b in "${BRAINS[@]}"; do [ "$b" = "$name" ] && { found=1; break; }; done
    [ "$found" -eq 1 ] && continue
    printf '%s\n' "$name"
  done
}

# Populate the global RESOLVED array: canonical brains first (order preserved),
# then any gh-discovered extras. Falls back to canonical-only without gh.
RESOLVED=()
resolve_brains() {
  RESOLVED=("${BRAINS[@]}")
  local name
  while IFS= read -r name; do
    [ -n "$name" ] && RESOLVED+=("$name")
  done < <(discover_new)
}

MASTER_BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"

clone_or_update() {
  local name="$1" dest="$SKILLS_DIR/$1"
  if [ -d "$dest/.git" ]; then
    printf '  \xe2\x86\xbb  %-28s updating\n' "$name"
    git -C "$dest" pull --ff-only 2>&1 | sed 's/^/        /' \
      || printf '        \xe2\x9a\xa0  pull failed (local changes? non-ff?)\n'
  elif [ -d "$dest" ]; then
    printf '  \xe2\x80\xa2  %-28s present but not a git checkout \xe2\x80\x94 leaving as-is\n' "$name"
  else
    printf '  \xe2\x86\x93  %-28s installing\n' "$name"
    if [ -d "${MASTER_BRAIN_DIR}/skills/${name}" ]; then
      cp -r "${MASTER_BRAIN_DIR}/skills/${name}" "$dest"
      printf '        installed from master-brain bundle\n'
    elif git clone --depth 1 "$(repo_url_ssh "$name")" "$dest" >/dev/null 2>&1; then
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
    resolve_brains
    printf '%s\n' "${RESOLVED[@]}"
    ;;
  discover)
    if ! command -v gh >/dev/null 2>&1; then
      echo "gh CLI not found — install it to auto-discover new org brains." >&2
      exit 1
    fi
    if ! gh auth status >/dev/null 2>&1; then
      echo "gh is not authenticated — run 'gh auth login' to auto-discover new org brains." >&2
      exit 1
    fi
    discover_new
    ;;
  install|update)
    echo "master-brain :: ${cmd} into ${SKILLS_DIR}"
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      echo "  discovering brains across the ${ORG} org via gh ..."
    else
      echo "  gh unavailable or not authed -- using the built-in canonical list only."
    fi
    resolve_brains
    mkdir -p "$SKILLS_DIR"
    for b in "${RESOLVED[@]}"; do clone_or_update "$b"; done
    echo "done."
    ;;
  status)
    resolve_brains
    echo "master-brain :: brain fleet in ${SKILLS_DIR}"
    printf '  %-28s %-8s %-9s %s\n' "BRAIN" "STATE" "VERSION" "LAST COMMIT"
    for b in "${RESOLVED[@]}"; do brain_status "$b"; done
    ;;
  *)
    echo "usage: brains.sh {list|discover|install|update|status}" >&2
    exit 2
    ;;
esac
