---
description: Ship a master-brain change in one shot — surface every command and skill system-wide, then commit and push to GitHub.
argument-hint: "[commit message] [--minor|--major|--no-bump]"
---

You changed master-brain itself (a command, a skill, a script, docs). Two things
must happen, and this command does both:

1. **Everything becomes available system-wide** — version bump → local marketplace
   mirror → plugin cache update → `brains.sh register` (which writes the bare
   aliases like `/website-audit` and the `mb:` commands into `~/.claude/commands`).
2. **The change reaches GitHub** — `git add -A`, commit, push to `origin`.

Use this instead of a bare `git push`: a plain push updates the repo but leaves
this machine running the old plugin cache, so the new command does not exist
until the next `/mb:update`.

> `/mb:push` is a different job: it lifts a *project's* `todos/` tooling UP into
> this repo. Run that first if the change started life in a project, then run
> `/mb:ship` to release it.

## 1. Locate the source repo and show what changed

```bash
REPO="${MB_SOURCE_REPO:-$HOME/master-brain}"
[ -d "$REPO/.claude-plugin" ] || REPO="$HOME/ai-marketing-hub/master-brain"
git -C "$REPO" status --short
git -C "$REPO" diff --stat
```

If the tree is clean and no version bump is wanted, say "nothing to ship" and stop.
Otherwise summarize the change in one or two plain sentences.

## 2. Ship it

Use `$ARGUMENTS` as the commit message when given; otherwise write a conventional
one yourself from the diff (`feat(mb): …`, `fix(mb): …`, `docs(mb): …`). Default to
a patch bump; pass `--minor` for a new command or skill, `--no-bump` for docs only.

```bash
bash "$REPO/scripts/ship.sh" -m "<message>"          # patch bump + everything
bash "$REPO/scripts/ship.sh" --minor -m "<message>"  # new command/skill
bash "$REPO/scripts/ship.sh" --no-bump -m "<message>"  # docs/README only
```

`ship.sh` bumps `plugin.json` + `marketplace.json`, rsyncs `commands/ scripts/
skills/ .claude-plugin/` into the local marketplace, refreshes the marketplace
index, updates the `mb` plugin cache, runs `brains.sh register`, then commits and
pushes. Add `--dry-run` first if the change is large.

## 3. Verify, then report

```bash
ls -l ~/.claude/commands/<new-command>.md    # the bare alias exists
git -C "$REPO" log --oneline -1
```

Report: the new version, which commands or skills are now reachable (both the
`mb:` form and the bare form), and the pushed commit. If a *new* command was
added, tell the user to restart Claude Code so the session picks it up; existing
commands take effect immediately. Other machines get it with `/mb:update`.
