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

Show the **full** pending state of the source repo — not just `todos/`. The
tooling pull above only moves `todos/`, but a `/mb:push` should also carry up any
edits you've made directly in the source repo (command/skill files like
`commands/init.md`, scripts, docs, version bumps):

```bash
REPO="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
git -C "$REPO" status --short
git -C "$REPO" diff
```

Summarize what changed in plain language. If the working tree is clean, say
"nothing to promote — the source repo already matches this project's tooling" and
stop.

If the diff includes anything that looks project-specific (a client name, a
hard-coded path, secrets, a one-off todo), STOP and flag it — that should not
enter the shared toolkit. Let the user decide before shipping.

## 3. Commit and push to GitHub

A `/mb:push` always ends by **committing and pushing the source repo to GitHub** —
that is how every other project actually receives the change (via `/mb:update`).
Do not leave promoted changes sitting uncommitted.

- **If `$ARGUMENTS` contains `--ship`** (or the change is shared `todos/` tooling
  that should mint a new release), run `ship.sh` — it version-bumps, propagates
  source → marketplace → plugin cache, and commits + pushes to GitHub:

  ```bash
  REPO="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
  bash "$REPO/scripts/ship.sh" patch -m "feat: promote tooling from $(basename "$PWD")"
  ```

- **Otherwise** (or when the version was already bumped as part of the edits),
  commit and push directly without a second bump:

  ```bash
  REPO="${MB_SOURCE_REPO:-$HOME/ai-marketing-hub/master-brain}"
  git -C "$REPO" add -A
  git -C "$REPO" commit -m "<summary of what was promoted>"
  git -C "$REPO" push
  ```

  Then refresh the local plugin cache so this machine is on the new version:
  `claude plugin update mb@ai-marketing-hub-master-brain`.

Pushing to GitHub is outward-facing — if the user did not pass `--ship` and did
not already confirm, ask once before pushing.

## 4. Report

State, in this order:
- **What was promoted** (which source-repo files changed).
- That it was **committed and pushed** to GitHub (commit + version), or — if the
  user declined — that it's left staged for review.
- How **other projects** get it: `/mb:update` per project, or `sync-tooling.sh
  push --all` to fan out `todos/` tooling to every registered project at once.
