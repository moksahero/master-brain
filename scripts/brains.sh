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
  # Same prune for the generated app-repo wrappers written by Phase 1b of
  # register_skill_aliases. Those are real files, not symlinks, so the sweep above
  # cannot see them; each carries a marker naming the SKILL.md it wraps.
  for link in "$COMMANDS_DIR"/*.md; do
    [ -L "$link" ] && continue
    [ -f "$link" ] || continue
    d="$(sed -n 's/^<!-- mb:skill-wrapper \(.*\) -->$/\1/p' "$link" | head -1)"
    [ -n "$d" ] || continue
    [ -e "$d" ] && continue
    rm -f "$link"
    printf '        pruned stale /%s (app repo removed its skill upstream)\n' "$(basename "${link%.md}")"
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
  # Phase 1b: APP repos, which ship their operating skill at
  # <repo>/.claude/skills/<repo>/SKILL.md instead of at the root (enrichard). Phase 1
  # cannot see those: they sit one level deeper, behind a dot directory. Two rules keep
  # this narrow and safe.
  #
  #   1. Only the SELF-NAMED skill is exposed (dir name == repo name). A repo's other
  #      .claude/skills entries are its own development chores, not fleet capability
  #      (marketing-os ships pr-review, testing, bump-version, i18n; exposing those
  #      globally would squat obvious command names for no benefit).
  #   2. We WRITE a wrapper instead of symlinking the SKILL.md raw. An app repo's skill
  #      locates its own code with `git rev-parse --show-toplevel`, which resolves to
  #      whatever repo the user is sitting in, so a raw alias silently points the skill
  #      at the wrong checkout. The wrapper pins the real path first.
  for skillmd in "$SKILLS_DIR"/*/.claude/skills/*/SKILL.md; do
    [ -e "$skillmd" ] || continue
    brain="${skillmd#"$SKILLS_DIR"/}"; brain="${brain%%/*}"
    bare="$(basename "$(dirname "$skillmd")")"
    [ "$bare" = "$brain" ] || continue
    skip_cmd_register "$brain" && continue
    dest="$COMMANDS_DIR/$bare.md"
    if [ -n "${CMD_OWNER[$bare.md]:-}" ]; then
      [ "${CMD_OWNER[$bare.md]}" = "$brain" ] || \
        printf '        \xe2\x9a\xa0  /%s alias skipped: already owned by %s\n' "$bare" "${CMD_OWNER[$bare.md]}"
      continue
    fi
    # Never clobber a hand-written command; our own wrapper carries the marker.
    if [ -e "$dest" ] && [ ! -L "$dest" ] && ! grep -q '^<!-- mb:skill-wrapper ' "$dest" 2>/dev/null; then
      continue
    fi
    rm -f "$dest"
    cat > "$dest" <<WRAPPER
---
description: Operate the ${brain} app, cloned at ${SKILLS_DIR}/${brain}. Reads that repo's own skill.
argument-hint: "see the skill's own commands"
---
<!-- mb:skill-wrapper ${skillmd} -->

\`${brain}\` is an app repository, not a brain clone. Its checkout lives at:

\`\`\`
${SKILLS_DIR}/${brain}
\`\`\`

Work from that directory. Its skill resolves the app with
\`git rev-parse --show-toplevel\`, so running it from any other project points it
at the wrong repository.

Now read \`${skillmd}\` and follow it exactly, including every spend gate,
confirmation step, and hard stop it defines. Its sibling \`reference/\` directory
holds the API contract it refers to.

Arguments: \$ARGUMENTS
WRAPPER
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
  ["jp-lp.md"]="jp-lp.md"
  ["compass.md"]="compass.md"
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

# --- Digest: inventory what the fleet actually exposes ---------------------------
# The sweep clones every repo in the source orgs, but a clone is not capability.
# A repo only reaches a project through a bare slash command, and it only gets one
# if it ships commands/*.md, a SKILL.md at a scanned depth, or a plugin manifest.
# A repo that ships none of those (an Obsidian vault template, a dataset, a docs
# site) installs silently and contributes nothing, and nobody finds out.
#
# This pass closes both halves of that gap:
#   1. It writes a complete inventory of every registered command to FLEET_FILE.
#      Projects scaffolded by /mb:init point at that file in their managed CLAUDE.md
#      block, so a brain installed today is discoverable in a project scaffolded last
#      month, with no per-project resync.
#   2. It names every cloned repo that exposes nothing, and says what the repo looks
#      like, so it gets handled deliberately instead of sitting inert in skills/.
FLEET_FILE="${MB_FLEET_FILE:-$HOME/.claude/master-brain-fleet.md}"

# First `description:` value out of a markdown file's YAML frontmatter, flattened
# to one line. Folded and multi-line descriptions are truncated; this is an index,
# not the skill itself.
fm_description() {
  [ -f "$1" ] || return 0
  awk '
    NR==1 && $0 !~ /^---[[:space:]]*$/ { exit }
    NR==1 { next }
    /^---[[:space:]]*$/ { exit }
    /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^["'"'"']|["'"'"']$/, "")
      print
      exit
    }
  ' "$1" 2>/dev/null | tr '\n' ' ' | cut -c1-240
}

# Which brain, plugin, or repo a registered command came from, derived from where
# the command file points rather than from a list we would have to maintain.
cmd_source() {
  local f="$1" t
  if [ -L "$f" ]; then
    t="$(readlink -f "$f" 2>/dev/null)" || t=""
    case "$t" in
      "$SKILLS_DIR"/*) t="${t#"$SKILLS_DIR"/}"; printf '%s' "${t%%/*}"; return ;;
      "$HOME"/.claude/plugins/cache/*)
        t="${t#"$HOME"/.claude/plugins/cache/}"; t="${t#*/}"; printf '%s' "${t%%/*}"; return ;;
    esac
    printf 'unknown'; return
  fi
  if grep -q '^<!-- mb:skill-wrapper ' "$f" 2>/dev/null; then
    t="$(sed -n 's/^<!-- mb:skill-wrapper \(.*\) -->$/\1/p' "$f" | head -1)"
    t="${t#"$SKILLS_DIR"/}"; printf '%s' "${t%%/*}"; return
  fi
  printf 'master-brain'
}

# True when a repo exposes at least one surface Claude Code can reach.
repo_has_surface() {
  local d="$1"
  [ -f "$d/SKILL.md" ] && return 0
  [ -f "$d/.claude-plugin/plugin.json" ] && return 0
  compgen -G "$d/skills/*/SKILL.md"          >/dev/null 2>&1 && return 0
  compgen -G "$d/.claude/skills/*/SKILL.md"  >/dev/null 2>&1 && return 0
  compgen -G "$d/commands/*.md"              >/dev/null 2>&1 && return 0
  return 1
}

# Best guess at what a surfaceless repo actually is, so the report says something
# more useful than "nothing found".
repo_shape() {
  local d="$1" bits=""
  [ -d "$d/.obsidian" ]   && bits="${bits}Obsidian vault, "
  [ -f "$d/AGENTS.md" ]   && bits="${bits}has AGENTS.md, "
  compgen -G "$d/Prompts/*.md" >/dev/null 2>&1 && bits="${bits}prompt library, "
  [ -f "$d/package.json" ] && bits="${bits}node package, "
  [ -f "$d/pyproject.toml" ] && bits="${bits}python package, "
  [ -f "$d/.mcp.example.json" ] && bits="${bits}ships an MCP example, "
  [ -z "$bits" ] && bits="no recognised shape, "
  printf '%s' "${bits%, }"
}

digest() {
  local f base src desc n=0 undigested=0 d name wrapper
  mkdir -p "$(dirname "$FLEET_FILE")"
  {
    printf '# Fleet inventory\n\n'
    printf 'Generated by `/mb:update`. Every skill and command installed on this\n'
    printf 'machine, one line each. Regenerated in full on every run, so it is\n'
    printf 'accurate as of the last update and stale after a manual install.\n\n'
    printf 'Read this when a topic has no match in a project CLAUDE.md routing map.\n'
    printf 'Being listed here means the command exists; it does not mean it fits.\n\n'
    printf '| Command | From | What it does |\n'
    printf '| --- | --- | --- |\n'
  } > "$FLEET_FILE"

  for f in "$COMMANDS_DIR"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f" .md)"
    src="$(cmd_source "$f")"
    desc="$(fm_description "$f" | sed 's/|/\\|/g')"
    [ -z "$desc" ] && desc="(no description in frontmatter)"
    printf '| `/%s` | %s | %s |\n' "$base" "$src" "$desc" >> "$FLEET_FILE"
    n=$((n+1))
  done
  printf '        %d command(s) inventoried -> %s\n' "$n" "$FLEET_FILE"

  # Second half: cloned repos that reach no project.
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    repo_has_surface "$d" && continue
    wrapper="$COMMANDS_DIR/$name.md"
    if [ -f "$wrapper" ] && [ ! -L "$wrapper" ]; then
      printf '        %-28s no skill surface, driven by /%s\n' "$name" "$name"
      continue
    fi
    undigested=$((undigested+1))
    printf '        \xe2\x9a\xa0  %-28s UNDIGESTED: %s\n' "$name" "$(repo_shape "$d")"
  done
  if [ "$undigested" -gt 0 ]; then
    printf '\n        %d cloned repo(s) expose nothing and reach no project.\n' "$undigested"
    printf '        Each needs one of: a wrapper command in master-brain/commands/,\n'
    printf '        an entry in the topic map in scripts/claude-md.sh, or removal.\n'
    printf '        A clone that no command drives is dead weight in skills/.\n\n'
  fi
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
    echo "  digesting the fleet ..."
    digest
    echo "done."
    ;;
  register)
    # Re-wire slash commands + bare skill aliases WITHOUT a network sweep. Fast,
    # idempotent, safe to run any time a brain adds/removes a skill.
    echo "master-brain :: registering commands + skill aliases into ${COMMANDS_DIR}"
    register_commands
    digest
    echo "done."
    ;;
  digest)
    # Inventory + undigested report only. No network, no re-register.
    echo "master-brain :: digesting the fleet"
    digest
    ;;
  status)
    resolve_brains
    echo "master-brain :: brain fleet in ${SKILLS_DIR} (+ plugins)"
    printf '  %-28s %-8s %-9s %s\n' "BRAIN" "STATE" "VERSION" "LAST COMMIT"
    for b in "${RESOLVED[@]}"; do brain_status "$b"; done
    ;;
  *)
    echo "usage: brains.sh {list|discover|install|update|register|digest|status}" >&2
    exit 2
    ;;
esac
