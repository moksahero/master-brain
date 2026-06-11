---
description: List the Master Brain TODO backlog from ./todos — open vs done, grouped and prioritized.
argument-hint: "[open|done|all] (default: open)"
---

Read the `master-brain` skill. Then list the TODO backlog.

TODOs live as markdown files in `./todos/`, each with frontmatter:
`status` (open|done|blocked|stale), `priority`, `skill`, `created`, `source`.
They are created automatically when a Hub brain runs (via the plugin hook) and
manually by other Master Brain commands.

## Steps

1. If `./todos/` doesn't exist, say there are no todos yet and stop.
2. Read every `todos/*.md`, parse the frontmatter and the first `#` heading.
3. Filter by `$ARGUMENTS` (default `open`). Accept `open`, `done`, `all`.
4. Present a compact table grouped by status, then by priority
   (high → normal → low): title, skill, age (from `created`), file name.
5. Footer line: counts — `N open · M done · K blocked/stale`.

If there are open todos, end by suggesting `/mb:todos-review` to triage
or `/mb:todos-execute` to work them. Do not modify any files — this is
read-only.
