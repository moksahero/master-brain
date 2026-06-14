#!/usr/bin/env bash
# master-brain :: sync the reusable per-project tooling between a project and this
# source repo. The tooling lives under todos/ (the SQLite TODO store + its Next.js
# dashboard). This is the COMPLEMENT to claude-md.sh: that script syncs the managed
# CLAUDE.md block; this one syncs the todos/ scaffold.
#
#   bash sync-tooling.sh pull DIR     # DIR/todos  -> repo/todos   (promote a project's
#                                       tooling edits up into the source of truth)
#   bash sync-tooling.sh push DIR     # repo/todos -> DIR/todos    (bring one project current)
#   bash sync-tooling.sh push --all   # repo/todos -> every registered project
#   bash sync-tooling.sh register DIR # add DIR to the project registry
#   bash sync-tooling.sh list         # print the project registry
#
# DIRECTION OF TRUTH
#   - SHARED files (the dashboard app, scripts, schema, migrations) are overwritten
#     in the destination — that's the point of a sync.
#   - SEED files (routines.yml, wrangler.jsonc, mds/) are project-OWNED: copied only
#     when missing in the destination, never overwritten. A project's cadence and its
#     Cloudflare worker name must survive an update.
#   - DATA / build junk (the SQLite db, node_modules, .next, dated todo md files) are
#     never touched in either direction.
#
# The registry is machine-local (lists THIS user's projects) so it lives under
# ~/.claude, not in the committed repo.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The canonical SOURCE repo — what gets committed and pushed to GitHub. This script
# may run from the installed plugin CACHE (~/.claude/plugins/cache/.../mb/<ver>),
# whose parent is NOT the source of truth; promoting tooling there would be lost on
# the next plugin update. So resolve the real source repo: honour MB_SOURCE_REPO,
# else the conventional checkout, else fall back to this script's own repo root.
REPO_ROOT="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
[ -d "$REPO_ROOT/.git" ] || REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SUBDIR="todos"
REGISTRY="${MB_PROJECTS_FILE:-$HOME/.claude/master-brain-projects.txt}"

# SHARED: synced in both directions, destination overwritten. Directories are
# mirrored (--delete) so removed files disappear; files are copied.
SHARED_FILES=(
  add-todo.sh
  schema.sql
  seed.sql
  next.config.ts
  open-next.config.ts
  postcss.config.mjs
  tsconfig.json
  cloudflare-env.d.ts
  package.json
  package-lock.json
  README.md
  .gitignore
)
SHARED_DIRS=(
  src
  migrations
)

# SEED: project-owned. Copied only when absent in the destination; never overwritten.
SEED_FILES=(
  routines.yml
  wrangler.jsonc
)
SEED_DIRS=(
  mds
)

need_rsync() {
  command -v rsync >/dev/null 2>&1 || { echo "sync-tooling: rsync not found on PATH" >&2; exit 3; }
}

# Copy a SHARED file (overwrite). $1=src dir $2=dest dir $3=name
copy_shared_file() {
  local src="$1/$3" dest="$2/$3"
  [ -f "$src" ] || return 0
  rsync -a "$src" "$dest" && echo "  ~ $3"
}

# Mirror a SHARED dir (overwrite + delete extras). $1=src dir $2=dest dir $3=name
mirror_shared_dir() {
  local src="$1/$3/" dest="$2/$3/"
  [ -d "$1/$3" ] || return 0
  mkdir -p "$dest"
  rsync -a --delete \
    --exclude 'node_modules/' --exclude '.next/' --exclude '.open-next/' \
    --exclude '.wrangler/' --exclude '*.db' --exclude '*.sqlite*' \
    "$src" "$dest" && echo "  ~ $3/"
}

# Seed a file only if missing. $1=src dir $2=dest dir $3=name
seed_file() {
  local src="$1/$3" dest="$2/$3"
  [ -f "$src" ] || return 0
  if [ -e "$dest" ]; then echo "  = $3 (kept project copy)"; return 0; fi
  rsync -a "$src" "$dest" && echo "  + $3 (seeded)"
}

# Seed a dir only if missing. $1=src dir $2=dest dir $3=name
seed_dir() {
  local src="$1/$3" dest="$2/$3"
  [ -d "$src" ] || return 0
  if [ -e "$dest" ]; then echo "  = $3/ (kept project copy)"; return 0; fi
  mkdir -p "$dest"
  rsync -a "$src/" "$dest/" && echo "  + $3/ (seeded)"
}

# $1 = src todos dir, $2 = dest todos dir, $3 = mode (shared-only | shared+seed)
sync_dir() {
  local src="$1" dest="$2" mode="$3"
  mkdir -p "$dest"
  local f
  for f in "${SHARED_FILES[@]}"; do copy_shared_file "$src" "$dest" "$f"; done
  for f in "${SHARED_DIRS[@]}";  do mirror_shared_dir "$src" "$dest" "$f"; done
  if [ "$mode" = "shared+seed" ]; then
    for f in "${SEED_FILES[@]}"; do seed_file "$src" "$dest" "$f"; done
    for f in "${SEED_DIRS[@]}";  do seed_dir  "$src" "$dest" "$f"; done
  fi
}

register() {
  local dir
  dir="$(cd "$1" 2>/dev/null && pwd)" || { echo "sync-tooling: no such dir: $1" >&2; return 1; }
  mkdir -p "$(dirname "$REGISTRY")"
  touch "$REGISTRY"
  if grep -qxF "$dir" "$REGISTRY"; then
    echo "sync-tooling: already registered: $dir"
  else
    printf '%s\n' "$dir" >> "$REGISTRY"
    echo "sync-tooling: registered $dir"
  fi
}

pull() {
  need_rsync
  local dir; dir="$(cd "$1" 2>/dev/null && pwd)" || { echo "sync-tooling: no such dir: $1" >&2; exit 1; }
  [ -d "$dir/$SUBDIR" ] || { echo "sync-tooling: $dir has no $SUBDIR/ — nothing to pull" >&2; exit 1; }
  echo "sync-tooling: PULL $dir/$SUBDIR -> $REPO_ROOT/$SUBDIR (canonical)"
  sync_dir "$dir/$SUBDIR" "$REPO_ROOT/$SUBDIR" "shared-only"
  echo "sync-tooling: done. Review with 'git -C $REPO_ROOT diff -- $SUBDIR', then ship.sh to release."
}

push_one() {
  need_rsync
  local dir; dir="$(cd "$1" 2>/dev/null && pwd)" || { echo "sync-tooling: no such dir: $1" >&2; return 1; }
  if [ ! -d "$dir/$SUBDIR" ]; then
    echo "sync-tooling: PUSH $REPO_ROOT/$SUBDIR -> $dir/$SUBDIR (fresh install)"
  else
    echo "sync-tooling: PUSH $REPO_ROOT/$SUBDIR -> $dir/$SUBDIR"
  fi
  sync_dir "$REPO_ROOT/$SUBDIR" "$dir/$SUBDIR" "shared+seed"
}

push() {
  if [ "${1:-}" = "--all" ]; then
    [ -f "$REGISTRY" ] || { echo "sync-tooling: no registry at $REGISTRY — register projects first" >&2; exit 1; }
    local any=0
    while IFS= read -r dir; do
      [ -z "$dir" ] && continue
      [ -d "$dir" ] || { echo "sync-tooling: skip missing $dir"; continue; }
      push_one "$dir"; any=1
    done < "$REGISTRY"
    [ "$any" = 1 ] || echo "sync-tooling: registry empty — nothing to push"
  else
    [ -n "${1:-}" ] || { echo "usage: sync-tooling.sh push {DIR | --all}" >&2; exit 2; }
    push_one "$1"
  fi
}

cmd="${1:-}"
case "$cmd" in
  pull)     shift; pull "${1:?usage: sync-tooling.sh pull DIR}" ;;
  push)     shift; push "${1:-}" ;;
  register) shift; register "${1:?usage: sync-tooling.sh register DIR}" ;;
  list)     [ -f "$REGISTRY" ] && cat "$REGISTRY" || echo "(no projects registered at $REGISTRY)" ;;
  *)
    echo "usage: sync-tooling.sh {pull DIR | push DIR | push --all | register DIR | list}" >&2
    exit 2
    ;;
esac
