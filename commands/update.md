---
description: Update every installed AI Marketing Hub brain to the latest version.
---

Read the `master-brain` skill. Then update the fleet.

## 1. Discover + update

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/brains.sh" update
```

When the `gh` CLI is installed and authenticated, this **sweeps every fleet
source** — the `AI-Marketing-Hub` org AND the `AgriciDaniel` public account — and
installs/refreshes *every* repo they publish — no curated allow/deny list. Each
repo is handled by detecting its type: repos that ship a Claude plugin
(`.claude-plugin/marketplace.json`) are plugin-installed or `claude plugin
update`d (claude-ads, claude-seo, claude-blog, sales-brain, social-hub, …); the
rest are cloned/fast-forwarded as `~/.claude/skills` brains. On a repo-name
collision the earlier source wins — the org stays canonical over the personal
account's public releases. The only repos skipped are structural non-installs
(`master-brain` itself, `.github`/profile-README repos, and forks of third-party
repos). A repo newly added to either source joins the fleet automatically — no
edit to `brains.sh`. Without `gh`, it falls back to the offline canonical
skills-clone list (plugins can't be resolved) and says so.

> **Why the full sweep.** Install-time filtering is what silently dropped
> `claude-seo`. The rule is install everything the org has; pick what to *run*
> locally. Do not reintroduce a hardcoded plugin or exclusion list here.

It fast-forwards every brain that's a git checkout in `~/.claude/skills`, clones
any newly discovered skill brain that isn't present yet, and plugin-installs any
new plugin brain. A brain with uncommitted local changes (or a non-fast-forward
history) is reported as a failed pull rather than force-updated — never clobber
local work.

Finally, it **registers slash commands**: every resolved brain that ships a
`commands/` dir has its `commands/*.md` symlinked into `~/.claude/commands` so
they're runnable as top-level commands (`/goal`, `/start`, `/campaign`, …).
Brains that expose commands only through a plugin are unaffected; brains that ship
as plain `skills/` clones (which otherwise expose no slash commands) get theirs
wired up here. Last writer wins on a name clash and each collision is logged in
the update output. Set `CLAUDE_SKIP_CMD_REGISTER=1` to opt out.

Then it **digests the fleet**. Cloning a repo is not the same as making it
usable, and the gap between the two is where new brains go to die. Two outputs:

1. `~/.claude/master-brain-fleet.md`, a full inventory of every registered
   command with its owning brain and description. Projects scaffolded by
   `/mb:init` point at this file in their managed `CLAUDE.md` block, so a brain
   installed today is discoverable from a project scaffolded months ago without
   resyncing that project.
2. An **UNDIGESTED** list: cloned repos that expose no `commands/`, no `SKILL.md`
   at a scanned depth, and no plugin manifest. Those reach no project at all.
   The report says what each repo looks like (Obsidian vault, node package,
   prompt library) so it can be handled rather than ignored.

An undigested repo needs one of three things, and the choice is a judgement call
that belongs to a person, not the sweep:

- **a wrapper command** in `master-brain/commands/`, added to
  `MB_BRAIN_COMMANDS` in `brains.sh` so it registers system-wide (this is how
  `/compass` drives an Obsidian vault template that ships no skill);
- **an entry in the topic map** in `scripts/claude-md.sh`, so projects route to
  it on a topic mention rather than on someone remembering it exists;
- **removal**, when it is a dataset, a docs site, or an n8n workflow that was
  never meant to be a Claude capability.

Work the list down rather than letting it grow. Run the digest alone, without a
network sweep, with:

```bash
bash "$SCRIPTS/brains.sh" digest
```

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

## 4. Refresh master-brain itself + claude-mem

The org's own plugin brains (claude-ads, claude-seo, claude-blog, sales-brain,
social-hub, …) are **already refreshed by the Step 1 sweep** — it runs
`claude plugin update` on each installed org plugin. Two plugins still need an
explicit refresh here because they sit *outside* that sweep: `master-brain` itself
(its marketplace is a local git checkout, below) and `claude-mem` (a public,
non-org plugin).

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

# (b) re-cache master-brain (re-reads from the local checkout above) + claude-mem.
# Every AI-Marketing-Hub org plugin was already `claude plugin update`d by the
# Step 1 sweep, so they are NOT repeated here.
claude plugin update mb@ai-marketing-hub-master-brain
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
