---
description: Work every open TODO to completion, marking each done in the SQLite store as you go.
argument-hint: "[optional: filter by skill or priority]"
---

Read the `master-brain` skill. Then execute the open TODO backlog.

```bash
CLI="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs"
```

## 1. Gather and order

1. Run `node "$CLI" list open --json` to get the open rows. Skip done, blocked,
   stale.
2. If `$ARGUMENTS` is given, filter to matching `skill` or `priority`.
3. Order by priority (high → normal → low), then oldest `created` first.
4. Auto-captured rows are thin (title is just "Follow up: `<skill>` run"). Infer
   the real next action from its `skill` and the project context before acting.
   If it's genuinely ambiguous, ask the user rather than guessing.

## 2. Execute one at a time

For each open todo (referenced by its `id`):
- State which todo you're starting.
- Do the work — invoking the relevant brain/skill as needed (e.g. a
  marketing-brain todo runs marketing-brain). Keep outputs in `wiki/`,
  `reports/`, `data/` as appropriate.
- When complete, mark it done **with a one-line outcome** a client could read —
  what was produced, where it lives, the headline result:

  ```bash
  node "$CLI" done <id> --outcome="Map-pack rank up to #3; findings in wiki/audits/gbp.md"
  ```

  (`done` stamps `updated`, which `/mb:todos-log` uses to order the history.)
- If you hit a blocker (missing key, needs client input), record it and move on
  — don't stall the whole run:

  ```bash
  node "$CLI" block <id> --note="waiting on client ad approval"
  ```

## 3. Caution

Some todos imply outward or hard-to-reverse actions (publishing, sending,
deleting). For those, confirm with the user before doing them rather than acting
autonomously.

## 4. Report

End with a summary: completed, blocked (and why), skipped, and the new backlog
counts (`node "$CLI" count open` / `blocked`). If new follow-up work surfaced,
add it with `node "$CLI" add "..."` so the loop continues.
