#!/usr/bin/env bash
# master-brain :: sweep every fleet source and install EVERY brain — clone/
# update/status helpers.
#
# Usage:
#   bash brains.sh list      # print the resolved repo names (one per line)
#   bash brains.sh discover  # gh-walk the sources, print owner/repo NOT canonical
#   bash brains.sh install   # install every repo (plugin OR skill), update rest
#   bash brains.sh update    # same as install (idempotent) + fast-forwards
#   bash brains.sh status    # show install state + version + last commit per repo
#
# The fleet sweeps every source in SOURCES, in order: the AI-Marketing-Hub org
# (private, members-only — cloning/plugin-installing requires git + gh
# authenticated with AI Marketing Hub Pro access) and the AgriciDaniel personal
# account (public releases of the same ecosystem). On a repo-NAME collision the
# EARLIER source wins — the org ships the active-development versions of
# claude-seo / claude-blog / claude-ads etc., the personal account their public
# releases, so the org must stay canonical.
#
# POLICY (why this file changed): the sweep installs EVERYTHING the sources
# publish. We do NOT keep a hand-curated allow/deny list of which repos are
# "worth" it — that curation is exactly what silently dropped claude-seo. Instead
# we walk each source and install each repo by DETECTING its type:
#   * has .claude-plugin/marketplace.json  -> install as a Claude PLUGIN
#   * otherwise                            -> clone as a skills/ brain
# The only repos skipped are STRUCTURAL non-installs (this repo itself, .github /
# profile-README repos, forks of third-party repos, and same-name repos already
# taken by an earlier source) — not a judgement about value. Pick-and-choose
# happens at EXECUTION time locally, never at install time. New repos added to a
# source are picked up automatically with zero edits here.

set -uo pipefail

# Sweep sources, in priority order — first source wins repo-name collisions.
SOURCES=("AI-Marketing-Hub" "AgriciDaniel")
ORG="${SOURCES[0]}"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
COMMANDS_DIR="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

# Canonical brains, in recommended read/install order. Discovery appends every
# OTHER org repo after these; this list only guarantees ordering + an offline
# fallback when gh is unavailable. Membership here is NOT a filter — repos not
# listed are still installed, just after these.
BRAINS=(
  "claude-obsidian"
  "website-brain"
  "marketing-brain"
  "local-seo-brain"
  "client-intelligence-report"
)

# External fleet plugins that live OUTSIDE the AI-Marketing-Hub org, so the org
# sweep structurally cannot discover them — they must be listed explicitly. This
# is NOT the curated org allow/deny list the sweep abolished: these repos are in
# other orgs entirely, so an org walk can never reach them. Each entry is
# "<marketplace-add-arg>|<plugin@marketplace ref>".
#   claude-mem  cross-session memory (public, thedotmack/claude-mem)
EXTERNAL_PLUGINS=(
  "thedotmack/claude-mem|claude-mem@thedotmack"
)

# Repo name -> owning source. Canonical brains and first-discovered names claim
# ownership; later sources never override (org stays canonical on collisions).
declare -A REPO_OWNER
owner_of() { printf '%s' "${REPO_OWNER[$1]:-$ORG}"; }

repo_url_ssh()   { printf 'git@github.com:%s/%s.git' "$(owner_of "$1")" "$1"; }
repo_url_https() { printf 'https://github.com/%s/%s.git' "$(owner_of "$1")" "$1"; }

# STRUCTURAL skips only — repos that have nothing installable for Claude Code, not
# a value judgement. `master-brain` is THIS repo (cloning it into skills/ under
# itself is nonsensical/recursive); `.github` is an org profile-README repo; a
# repo named after its owner is a personal profile-README repo. Second arg is the
# source owner (optional).
is_structural_skip() {
  case "$1" in
    master-brain|.github) return 0 ;;
  esac
  [ -n "${2:-}" ] && [ "$1" = "$2" ] && return 0
  return 1
}

# Walk one source via gh and print every non-archived, non-fork repo name. Forks
# are third-party repos mirrored into the account, not fleet brains. Silent no-op
# (returns non-zero) when gh is missing or not authenticated.
gh_source_repos() {
  local owner="$1"
  command -v gh >/dev/null 2>&1 || return 1
  gh auth status >/dev/null 2>&1 || return 1
  gh repo list "$owner" --limit 300 --json name,isArchived,isFork \
    --jq '.[] | select((.isArchived or .isFork) | not) | .name' 2>/dev/null
}

# Print discovered "owner<TAB>name" pairs NOT already in the canonical list, all
# sources in priority order, first source claiming each name.
discover_new() {
  local src name found b
  declare -A seen
  for b in "${BRAINS[@]}"; do seen[$b]=1; done
  for src in "${SOURCES[@]}"; do
    while IFS= read -r name; do
      [ -z "$name" ] && continue
      is_structural_skip "$name" "$src" && continue
      [ -n "${seen[$name]:-}" ] && continue
      seen[$name]=1
      printf '%s\t%s\n' "$src" "$name"
    done < <(gh_source_repos "$src")
  done
}

# Populate the global RESOLVED array: canonical brains first (order preserved),
# then every gh-discovered repo from each source in priority order. Falls back to
# canonical-only without gh. Also records each repo's owning source.
RESOLVED=()
resolve_brains() {
  RESOLVED=("${BRAINS[@]}")
  local b src name
  for b in "${BRAINS[@]}"; do REPO_OWNER[$b]="$ORG"; done
  while IFS=$'\t' read -r src name; do
    [ -z "$name" ] && continue
    REPO_OWNER[$name]="$src"
    RESOLVED+=("$name")
  done < <(discover_new)
}

# --- Plugin detection + install ------------------------------------------------
# A repo is a Claude plugin when it ships .claude-plugin/marketplace.json. We
# detect it live via the GitHub API (cached per run) so the sweep never needs a
# hardcoded plugin list. This is what makes claude-ads / claude-seo / claude-blog
# (and any future plugin brain) install automatically.
declare -A PLUGIN_CACHE
repo_is_plugin() {
  local name="$1"
  if [ -z "${PLUGIN_CACHE[$name]:-}" ]; then
    if command -v gh >/dev/null 2>&1 \
       && gh api "repos/$(owner_of "$name")/$name/contents/.claude-plugin/marketplace.json" >/dev/null 2>&1; then
      PLUGIN_CACHE[$name]=yes
    else
      PLUGIN_CACHE[$name]=no
    fi
  fi
  [ "${PLUGIN_CACHE[$name]}" = yes ]
}

# Emit "<plugin-name>\t<marketplace-name>" for each plugin declared in a repo's
# marketplace.json. Used to build the `<plugin>@<marketplace>` install ref.
plugin_refs() {
  local name="$1"
  gh api "repos/$(owner_of "$name")/$name/contents/.claude-plugin/marketplace.json" --jq '.content' 2>/dev/null \
    | base64 -d 2>/dev/null \
    | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin); m=d.get("name","")
    for p in d.get("plugins",[]):
        n=p.get("name","")
        if n and m: print(n+"\t"+m)
except Exception:
    pass' 2>/dev/null
}

plugin_installed() {
  grep -q "\"$1\"" "$INSTALLED_PLUGINS" 2>/dev/null
}

# Some plugin brains (gogh, fable-5-brain, dataforseo-brain, youtube-brain, …)
# declare their skill as `"skills": ["./SKILL.md"]` — a root FILE. Claude Code
# only loads plugin skills from directories, so the plugin's agents appear but
# the /<skill> command never does. Each of those repos ships an install.sh with
# a `claude` target that copies the skill surface to ~/.claude/skills/<name>;
# run it after every plugin install/update so the skill is truly system-wide.
sync_root_skill_surface() {
  local pl="$1" mk="$2" dir
  dir="$(ls -1d "$HOME/.claude/plugins/cache/$mk/$pl"/*/ 2>/dev/null | sort -V | tail -1)"
  dir="${dir%/}"
  [ -n "$dir" ] && [ -f "$dir/SKILL.md" ] && [ -f "$dir/install.sh" ] || return 0
  grep -qs '"\./SKILL\.md"' "$dir/.claude-plugin/plugin.json" "$dir/plugin.json" || return 0
  if bash "$dir/install.sh" --target claude >/dev/null 2>&1; then
    printf '        skill surface \xe2\x86\x92 ~/.claude/skills/%s (root-SKILL.md plugins don'\''t auto-load it)\n' "$pl"
  else
    printf '        \xe2\x9a\xa0  skill-surface install failed (install.sh --target claude)\n'
  fi
}

# Install (or, in update mode, refresh) every plugin declared by a plugin repo.
install_plugin() {
  local name="$1" mode="${2:-install}" pl mk ref got=0
  while IFS=$'\t' read -r pl mk; do
    [ -z "$pl" ] || [ -z "$mk" ] && continue
    got=1
    ref="${pl}@${mk}"
    if plugin_installed "$ref"; then
      if [ "$mode" = "update" ]; then
        printf '  \xe2\x86\xbb  %-28s plugin \xe2\x80\x94 updating (%s)\n' "$name" "$ref"
        claude plugin update "$ref" >/dev/null 2>&1 \
          || printf '        \xe2\x9a\xa0  update failed\n'
      else
        printf '  \xe2\x80\xa2  %-28s plugin \xe2\x80\x94 already installed (%s)\n' "$name" "$ref"
      fi
      sync_root_skill_surface "$pl" "$mk"
    else
      printf '  \xe2\x86\x93  %-28s plugin \xe2\x80\x94 installing (%s)\n' "$name" "$ref"
      claude plugin marketplace add "$(owner_of "$name")/$name" >/dev/null 2>&1
      if claude plugin install "$ref" >/dev/null 2>&1; then
        printf '        installed\n'
        sync_root_skill_surface "$pl" "$mk"
      else
        printf '        \xe2\x9a\xa0  install failed \xe2\x80\x94 confirm AI Marketing Hub Pro access + git auth\n'
      fi
    fi
  done < <(plugin_refs "$name")
  if [ "$got" -eq 0 ]; then
    # marketplace.json exists but declares no plugins (some repos use it as a
    # custom install catalog, e.g. claude-video) — caller falls back to a clone.
    printf '  \xe2\x9a\xa0  %-28s marked plugin but no plugins parsed \xe2\x80\x94 falling back to skills clone\n' "$name"
    return 1
  fi
}

# Install (or, in update mode, refresh) the external, non-org fleet plugins
# (claude-mem, …). Runs regardless of gh — these don't need org discovery.
install_external_plugins() {
  local mode="${1:-install}" entry add ref name
  for entry in "${EXTERNAL_PLUGINS[@]}"; do
    add="${entry%%|*}"; ref="${entry##*|}"; name="${ref%@*}"
    if plugin_installed "$ref"; then
      if [ "$mode" = "update" ]; then
        printf '  \xe2\x86\xbb  %-28s external plugin \xe2\x80\x94 updating (%s)\n' "$name" "$ref"
        claude plugin update "$ref" >/dev/null 2>&1 \
          || printf '        \xe2\x9a\xa0  update failed\n'
      else
        printf '  \xe2\x80\xa2  %-28s external plugin \xe2\x80\x94 already installed (%s)\n' "$name" "$ref"
      fi
    else
      printf '  \xe2\x86\x93  %-28s external plugin \xe2\x80\x94 installing (%s)\n' "$name" "$ref"
      claude plugin marketplace add "$add" >/dev/null 2>&1
      if claude plugin install "$ref" >/dev/null 2>&1; then
        printf '        installed\n'
      else
        printf '        \xe2\x9a\xa0  install failed \xe2\x80\x94 try each project'\''s installer (e.g. npx claude-mem@latest install)\n'
      fi
    fi
  done
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

# Install one org repo the right way: already a working skills clone -> keep it
# fast-forwarded (don't disturb a functioning brain); else if it's a plugin repo
# -> plugin-install; else -> clone as a skills brain.
install_one() {
  local name="$1" mode="$2"
  is_structural_skip "$name" && return 0
  if [ -d "$SKILLS_DIR/$name/.git" ] || [ -d "$SKILLS_DIR/$name" ]; then
    clone_or_update "$name"
  elif repo_is_plugin "$name"; then
    install_plugin "$name" "$mode" || clone_or_update "$name"
  else
    clone_or_update "$name"
  fi
}

# Make each cloned brain's commands runnable as top-level slash commands by
# symlinking every commands/*.md into the personal commands dir. Brains that ship
# as skills/ clones (not plugins) otherwise expose no slash commands at all — this
# closes that gap so /goal, /start, /campaign, etc. work everywhere. Plugins wire
# their own commands, so this pass only touches skills/ clones.
#
# codex-* dirs are skipped here (command registration only): they are a different
# runtime and must never SHADOW a Claude command of the same name. This is a
# collision-safety guard, not an install filter — the codex repos are still
# installed, their commands just aren't symlinked into the Claude command space.
declare -A CMD_OWNER
skip_cmd_register() {
  case "$1" in codex-*) return 0 ;; esac
  is_structural_skip "$1"
}
register_commands() {
  [ "${CLAUDE_SKIP_CMD_REGISTER:-0}" = "1" ] && { echo "  command registration skipped (CLAUDE_SKIP_CMD_REGISTER=1)"; return 0; }
  local name src f base dest n=0 d link
  CMD_OWNER=()
  mkdir -p "$COMMANDS_DIR"
  echo "  registering brain commands into ${COMMANDS_DIR} ..."
  # Prune symlinks whose target vanished (a brain removed or restructured its
  # commands/ dir upstream — e.g. claude-obsidian v2.0.0 moved to plugin layout).
  # Only touches links that point into SKILLS_DIR; user-authored files are safe.
  for link in "$COMMANDS_DIR"/*.md; do
    [ -L "$link" ] || continue
    [ -e "$link" ] && continue
    case "$(readlink "$link")" in
      "$SKILLS_DIR"/*)
        rm -f "$link"
        printf '        pruned stale /%s (brain removed its command upstream)\n' "$(basename "${link%.md}")"
        ;;
    esac
  done
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    skip_cmd_register "$name" && continue
    src="$SKILLS_DIR/$name/commands"
    [ -d "$src" ] || continue
    for f in "$src"/*.md; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      dest="$COMMANDS_DIR/$base"
      if [ -n "${CMD_OWNER[$base]:-}" ]; then
        printf '        \xe2\x9a\xa0  /%s collision: %s overrides %s\n' "${base%.md}" "$name" "${CMD_OWNER[$base]}"
      fi
      ln -sf "$f" "$dest"
      CMD_OWNER[$base]="$name"
      n=$((n+1))
    done
  done
  printf '        %d command(s) registered (%d unique name(s))\n' "$n" "${#CMD_OWNER[@]}"
  register_skill_aliases
  register_master_brain_commands
}

# commands/*.md is only half the surface. Most brains expose their real
# capabilities as SKILL.md files: a root SKILL.md (the brain itself) and one
# level of sub-skills under <brain>/skills/<sub>/SKILL.md (ads-competitor,
# seo-audit, blog-write, canvas-export, ...). Plugins surface those ONLY under a
# plugin: namespace, so from a fresh project you'd have to know the exact
# /claude-ads:ads-competitor form. This pass symlinks each such SKILL.md as a
# bare top-level slash command so /ads-competitor (and every sibling) works in
# every project, with NO per-project /mb:update. Same collision rule as the
# commands/ pass: a real command file or an earlier owner wins (first-wins), and
# a user-authored (non-symlink) command of the same name is never clobbered.
# Scope is deliberately shallow — only <brain>/SKILL.md and
# <brain>/skills/<sub>/SKILL.md. Deeper SKILL.md files (examples/, vendored
# copies, nested sub-sub-skills, marketing-os/seo-os resources) are internal and
# stay unexposed. These symlinks point into SKILLS_DIR, so the stale-link sweep
# at the top of register_commands auto-prunes any whose skill vanishes upstream.
register_skill_aliases() {
  local skillmd brain bare dest a=0 pdir plugin latest
  # Phase 1: brains that live as skills/ clones under SKILLS_DIR.
  for skillmd in "$SKILLS_DIR"/*/SKILL.md "$SKILLS_DIR"/*/skills/*/SKILL.md; do
    [ -e "$skillmd" ] || continue
    brain="${skillmd#"$SKILLS_DIR"/}"; brain="${brain%%/*}"
    skip_cmd_register "$brain" && continue
    bare="$(basename "$(dirname "$skillmd")")"
    dest="$COMMANDS_DIR/$bare.md"
    if [ -n "${CMD_OWNER[$bare.md]:-}" ]; then
      [ "${CMD_OWNER[$bare.md]}" = "$brain" ] || \
        printf '        \xe2\x9a\xa0  /%s alias skipped: already owned by %s\n' "$bare" "${CMD_OWNER[$bare.md]}"
      continue
    fi
    [ -e "$dest" ] && [ ! -L "$dest" ] && continue
    ln -sf "$skillmd" "$dest"
    CMD_OWNER[$bare.md]="$brain"
    a=$((a+1))
  done
  # Phase 2: brains whose skills live ONLY in the versioned plugin cache
  # (claude-repurpose, banana-claude, claude-music, claude-mem, ...). Resolve each
  # plugin's CURRENT version dir (highest semver) and alias its canonical
  # skills/*/SKILL.md. mb (fleet management: /update, /install, /doctor, /todos-*)
  # is intentionally excluded so those stay under the reserved mb: namespace and
  # never shadow a same-named brain skill. Symlinks point at the versioned path, so
  # a version bump breaks the old link — the stale-link sweep at the top of
  # register_commands prunes it and the next register re-points to the new version.
  for pdir in "$HOME"/.claude/plugins/cache/*/*/; do
    plugin="$(basename "$pdir")"
    case "$plugin" in mb) continue ;; esac
    latest="$(ls -1d "$pdir"*/ 2>/dev/null | sort -V | tail -1)"
    [ -n "$latest" ] || continue
    for skillmd in "$latest"skills/*/SKILL.md; do
      [ -e "$skillmd" ] || continue
      bare="$(basename "$(dirname "$skillmd")")"
      dest="$COMMANDS_DIR/$bare.md"
      if [ -n "${CMD_OWNER[$bare.md]:-}" ]; then
        [ "${CMD_OWNER[$bare.md]}" = "$plugin" ] || \
          printf '        \xe2\x9a\xa0  /%s alias skipped: already owned by %s\n' "$bare" "${CMD_OWNER[$bare.md]}"
        continue
      fi
      [ -e "$dest" ] && [ ! -L "$dest" ] && continue
      ln -sf "$skillmd" "$dest"
      CMD_OWNER[$bare.md]="$plugin"
      a=$((a+1))
    done
  done
  printf '        %d skill(s) aliased as bare commands\n' "$a"
}

# master-brain's own commands/ dir is mostly MANAGEMENT (update/doctor/install/
# todos-*/push/report/init/idk) — those stay under the mb: plugin namespace, which
# is reserved for changing master-brain itself. But a few are BRAIN-OPERATION
# commands that should be reachable as clean top-level slash commands instead. Map
# each here (source filename -> top-level slash filename) and we expose it.
# We COPY (not symlink) because this script usually runs from the versioned plugin
# cache (…/mb/<ver>/scripts), whose path changes every release — a symlink would go
# stale on the next bump, whereas /mb:update re-copies fresh content each run.
# Value is a space-separated list of top-level slash filenames to expose for the
# same source command (so one brain-op command can carry an alias). youtuber.md
# ships as both /youtuber (primary, matches the command name) and /youtube (alias).
declare -A MB_BRAIN_COMMANDS=(
  ["youtuber.md"]="youtuber.md youtube.md"
  ["website-audit.md"]="website-audit.md"
)
register_master_brain_commands() {
  [ "${CLAUDE_SKIP_CMD_REGISTER:-0}" = "1" ] && return 0
  local src_dir="$MASTER_BRAIN_DIR/commands" from to
  [ -d "$src_dir" ] || return 0
  for from in "${!MB_BRAIN_COMMANDS[@]}"; do
    [ -f "$src_dir/$from" ] || continue
    for to in ${MB_BRAIN_COMMANDS[$from]}; do
      cp -f "$src_dir/$from" "$COMMANDS_DIR/$to"
      printf '        /%s registered (master-brain brain-op: %s)\n' "${to%.md}" "${from%.md}"
    done
  done
}

brain_status() {
  local name="$1" dest="$SKILLS_DIR/$1" ver="-" sha="-" state
  if [ -d "$dest/.git" ]; then
    state="git"
    sha="$(git -C "$dest" log -1 --format='%h %cd' --date=short 2>/dev/null || echo '-')"
  elif [ -d "$dest" ]; then
    state="dir"
  elif repo_is_plugin "$name" && { ver=""; while IFS=$'\t' read -r pl mk; do [ -n "$pl" ] && plugin_installed "${pl}@${mk}" && ver="installed"; done < <(plugin_refs "$name"); [ -n "$ver" ]; }; then
    state="plugin"; sha="(plugin)"; ver="-"
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
      echo "gh CLI not found — install it to auto-discover org repos." >&2
      exit 1
    fi
    if ! gh auth status >/dev/null 2>&1; then
      echo "gh is not authenticated — run 'gh auth login' to auto-discover org repos." >&2
      exit 1
    fi
    discover_new | awk -F'\t' '{print $1 "/" $2}'
    ;;
  install|update)
    echo "master-brain :: ${cmd} into ${SKILLS_DIR} (+ plugins)"
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      echo "  sweeping every fleet source via gh (${SOURCES[*]}) — installing every repo (plugin or skill) ..."
    else
      echo "  gh unavailable or not authed -- using the built-in canonical list only (plugins can't be resolved)."
    fi
    resolve_brains
    mkdir -p "$SKILLS_DIR"
    for b in "${RESOLVED[@]}"; do install_one "$b" "$cmd"; done
    echo "  external (non-org) fleet plugins ..."
    install_external_plugins "$cmd"
    register_commands
    echo "done."
    ;;
  register)
    # Re-wire slash commands + bare skill aliases WITHOUT a network sweep. Fast,
    # idempotent, safe to run any time a brain adds/removes a skill.
    echo "master-brain :: registering commands + skill aliases into ${COMMANDS_DIR}"
    register_commands
    echo "done."
    ;;
  status)
    resolve_brains
    echo "master-brain :: brain fleet in ${SKILLS_DIR} (+ plugins)"
    printf '  %-28s %-8s %-9s %s\n' "BRAIN" "STATE" "VERSION" "LAST COMMIT"
    for b in "${RESOLVED[@]}"; do brain_status "$b"; done
    ;;
  *)
    echo "usage: brains.sh {list|discover|install|update|register|status}" >&2
    exit 2
    ;;
esac
