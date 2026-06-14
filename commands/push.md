---
description: Promote this project's reusable tooling (todos/ dashboard + scripts) UP into the master-brain source repo, then optionally ship it to every other project.
argument-hint: "[--ship] (also version-bump, commit, push to GitHub, and propagate)"
---

Read the `master-brain` skill. Then promote the **reusable** parts of the current
project back into the master-brain source of truth.

This is the reverse of `/mb:update`: `/mb:update` pushes canonical tooling DOWN
into a project; `/mb:push` lifts a project's tooling edits UP into the source repo
so every other project can get them.

## What moves (and what never does)

Only the shared `todos/` tooling is promoted — the SQLite TODO store, its
migrations, schema, and the Next.js dashboard under `todos/src`. Project-OWNED
files (`routines.yml`, `wrangler.jsonc`, the `mds/` seed todos) and all project
DATA (the SQLite db, `node_modules`, `.next`, dated todo markdown, anything under
`wiki/` `data/` `reports/` `web/`) are **never** touched — those belong to the
project, not the toolkit.

## 1. Promote tooling into the source repo

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/sync-tooling.sh" pull .
```

This writes into the canonical source repo (`MB_SOURCE_REPO`, default
`~/ai-marketing-hub/master-brain`) — NOT the plugin cache, so the change survives
updates and can reach GitHub. It also auto-registers this project so future
`/mb:update --all` runs reach it.

## 2. Show the diff and confirm

```bash
REPO="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
git -C "$REPO" status --short -- todos
git -C "$REPO" diff -- todos
```

Summarize what changed in plain language. If the diff is empty, say "nothing to
promote — the source repo already matches this project's tooling" and stop.

If the diff includes anything that looks project-specific (a client name, a
hard-coded path, secrets, a one-off todo), STOP and flag it — that should not
enter the shared toolkit. Let the user decide before shipping.

## 3. Ship it (only when `$ARGUMENTS` contains `--ship`, or the user confirms)

```bash
REPO="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
bash "$REPO/scripts/ship.sh" patch -m "feat(todos): promote tooling from $(basename "$PWD")"
```

`ship.sh` version-bumps, propagates source → marketplace → plugin cache, and
commits + pushes to GitHub. After it completes, the new tooling is the canonical
version; other projects pick it up the next time they run `/mb:update` (or
immediately via `bash "$REPO/scripts/sync-tooling.sh" push --all`).

Without `--ship`, stop after step 2 with the changes staged in the working tree
and tell the user to review, then run `/mb:push --ship` (or `ship.sh`) when ready.

## 4. Report

State, in this order:
- **What was promoted** (which `todos/` files changed in the source repo).
- Whether it was **shipped** (version bump + GitHub push) or left for review.
- How **other projects** get it: `/mb:update` per project, or `sync-tooling.sh
  push --all` to fan out to every registered project at once.
