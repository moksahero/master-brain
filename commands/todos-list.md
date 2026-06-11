---
description: List the Master Brain TODO backlog from the SQLite store — open vs done, grouped and prioritized.
argument-hint: "[open|done|all] (default: open)"
---

Read the `master-brain` skill. Then list the TODO backlog.

TODOs live in a SQLite database at `todos/todos.db`. Rows are created
automatically when a Hub brain runs (via the plugin hook) and manually by other
Master Brain commands. Read it through the bundled CLI:

```bash
CLI="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs"
```

## Steps

1. If `todos/todos.db` doesn't exist, say there are no todos yet and stop.
2. Run `node "$CLI" list <filter> --json` where `<filter>` is `$ARGUMENTS`
   (default `open`; accept `open`, `done`, `all`). The `--json` output is an
   array of rows with `id, skill, title, status, priority, source, created`.
3. Present a compact table grouped by status, then by priority
   (high → normal → low): id, title, skill, age (from `created`), source.
4. Footer line: counts via `node "$CLI" count open`, `node "$CLI" count blocked`,
   `node "$CLI" count done` — show `N open · M done · K blocked/stale`.

If there are open todos, end by suggesting `/mb:todos-review` to triage or
`/mb:todos-execute` to work them. This is read-only — don't mutate any rows.
