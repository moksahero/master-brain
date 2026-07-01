---
description: Update every installed AI Marketing Hub brain to the latest version.
---

Read the `master-brain` skill. Then update the fleet.

## 1. Discover + update

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/brains.sh" update
```

When the `gh` CLI is installed and authenticated, this **walks the entire
`AI-Marketing-Hub` org** and resolves the fleet dynamically: the canonical brains
first, then any other brain that's been added to the org (e.g. `social-hub`). So
a newly published brain joins the fleet automatically — no edit to `brains.sh`.
Discovery includes both Claude plugins and Obsidian-brain vaults, and excludes
Codex-runtime variants (`codex-*`) and non-skill infra (`.github`,
`classroom-assets`, `marketing-os`, `member-workflows`). Without `gh`, it falls
back to the built-in canonical list and says so.

It then fast-forwards every brain that's a git checkout in `~/.claude/skills` and
clones any newly discovered brain that isn't present yet. A brain with
uncommitted local changes (or a non-fast-forward history) is reported as a failed
pull rather than force-updated — never clobber local work.

Finally, it **registers slash commands**: every resolved brain that ships a
`commands/` dir has its `commands/*.md` symlinked into `~/.claude/commands` so
they're runnable as top-level commands (`/goal`, `/start`, `/campaign`, …).
Brains that expose commands only through a plugin are unaffected; brains that ship
as plain `skills/` clones (which otherwise expose no slash commands) get theirs
wired up here. Last writer wins on a name clash and each collision is logged in
the update output. Set `CLAUDE_SKIP_CMD_REGISTER=1` to opt out.

To preview what discovery would add before updating, run:

```bash
bash "$SCRIPTS/brains.sh" discover   # prints org brains not in the canonical list
```

(If `gh` is missing or not logged in, that's fine — note it and continue; the
update still runs against the canonical list. Suggest `gh auth login` so future
updates auto-pick-up new org brains.)

This updates the **system-wide** brain fleet under `~/.claude/skills` (the
`brains.sh` banner prints the exact target dir — it is `$HOME/.claude/skills`
unless `CLAUDE_SKILLS_DIR` is set, never the current project). Brains load from
there for *every* project, so this step is global, not per-project. Call out the
resolved path in the report so the scope is unambiguous.

## 2. Sync this project's CLAUDE.md managed section (current directory only)

The brain *code* is global, but the **Persistence conventions** live in each
project's `CLAUDE.md`. Projects scaffolded before that rule existed never got it.
Retrofit/refresh it for the current project — and only the current project:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/claude-md.sh" sync .
```

This reconciles only the block between the `<!-- mb:managed:start -->` /
`<!-- mb:managed:end -->` markers to the canonical text — adding it if absent,
refreshing it if stale, leaving it untouched if current. Everything outside the
markers (project name, focus, market, active brains, API-key status, report
language) is project-owned and never modified. If there's no `CLAUDE.md` here,
it skips with a note (this isn't an `/mb:init` project). Report add / refresh /
no-change / skip.

## 3. Sync this project's reusable tooling (current directory only)

The `todos/` scaffold (SQLite TODO store + Next.js dashboard) is shared tooling
that improves over time in the source repo. Bring the current project current —
overwriting only the shared files, never the project-owned ones:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
[ -d ./todos ] && bash "$SCRIPTS/sync-tooling.sh" push .
```

This reads from the canonical source repo and refreshes `todos/src`,
`migrations/`, `schema.sql`, etc., while keeping the project's own `routines.yml`,
`wrangler.jsonc`, `mds/`, and SQLite db untouched. If there's no `todos/` here,
it skips. This is the DOWN direction; `/mb:push` is the UP direction (promote a
project's tooling edits back into the source repo). Report which files refreshed.

## 4. Refresh the plugin brains (master-brain itself + claude-ads + claude-mem)

These ship as plugins, not `skills/` clones, so `brains.sh` doesn't touch them.

**master-brain updates itself here too.** Its marketplace source is a *local git
checkout* (see `~/.claude/plugins/known_marketplaces.json` → the
`ai-marketing-hub-master-brain` entry's `installLocation`). So `/mb:update` must
(a) fast-forward that checkout from its git remote — so anything pushed to the
master-brain repo (new classroom lessons, prompt-library edits, command/skill
tweaks) lands locally — and then (b) re-cache the `mb` plugin from that checkout
so the running `/mb:` commands and the captured `classroom/` reflect the pull.

```bash
# (a) resolve + fast-forward the master-brain checkout (the marketplace source)
MB_DIR="$(python3 - <<'PY'
import json, os
p = os.path.expanduser('~/.claude/plugins/known_marketplaces.json')
def find(o):
    if isinstance(o, dict):
        loc = o.get('installLocation') or o.get('path')
        if loc and 'master-brain' in str(loc):
            return loc
        for v in o.values():
            r = find(v)
            if r: return r
    elif isinstance(o, list):
        for v in o:
            r = find(v)
            if r: return r
try:
    print(find(json.load(open(p))) or '')
except Exception:
    print('')
PY
)"
MB_DIR="${MB_DIR:-$HOME/ai-marketing-hub/master-brain}"
if [ -d "$MB_DIR/.git" ]; then
  echo "master-brain checkout: $MB_DIR"
  git -C "$MB_DIR" pull --ff-only 2>&1   # never clobbers; aborts if local edits conflict
fi

# (b) re-cache the plugins (mb re-reads from the local checkout above)
claude plugin update mb@ai-marketing-hub-master-brain
claude plugin update claude-ads@ai-marketing-hub-claude-ads
claude plugin update claude-mem@thedotmack
```

A `git pull --ff-only` never force-overwrites: if the checkout has uncommitted
edits that would collide, it aborts with a message — report that and move on
rather than stashing or forcing. If the checkout is already current, the pull is
a no-op and the plugin re-cache simply confirms the latest version.

(If the plugin CLI isn't available, or a plugin isn't installed, note it and skip.)

## 5. Report what changed

Run `bash "$SCRIPTS/brains.sh" status` and show the table. State the resolved
**install path** (`~/.claude/skills`) up front so it's clear the brain update was
system-wide, then call out:

- Any **newly discovered brain** that was just cloned into the fleet (name it and
  say where it came from — "new in the org").
- Any brain that **failed to update** and why (local changes, not a git checkout,
  missing), with the one-line fix.
- Any brain that was **behind and is now current**, with the new version.
- The **master-brain self-update** result from step 4: whether the local checkout
  was fast-forwarded (and to what), or was already current, plus the re-cached
  `mb` plugin version — so it's clear `/mb:update` now refreshes master-brain too.
- The **CLAUDE.md managed-section** result for this project (added / refreshed /
  no-change / skipped) from step 2 — so it's clear that part was per-project.
- The **tooling sync** result for this project (which `todos/` files refreshed, or
  skipped if no `todos/` here) from step 3 — also per-project.

Make the two scopes explicit so they're never confused: brain code = **system-wide**
(`~/.claude/skills`); the Persistence block = **this project only** (`./CLAUDE.md`).

End with a one-line "fleet is current" or a list of what needs manual attention.
