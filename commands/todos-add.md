---
description: Add a manual TODO to the SQLite store — capture a follow-up so it joins the tracked backlog.
argument-hint: "<what to do> (e.g. 'redo the GBP audit after the client verifies their profile')"
---

Read the `master-brain` skill. Then insert one new TODO row so it flows through
the same review/execute loop as the auto-captured ones.

```bash
CLI="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs"
```

`$ARGUMENTS` is the free-text todo. If it's empty, ask the user what the todo is
(one line is enough) before writing anything.

## 1. Derive the fields

- **title** — a short imperative line from the user's text (e.g. "Redo GBP audit
  after profile verification").
- **priority** — default `normal`. Use `high` if the user signals urgency
  (today/urgent/blocker/ASAP) or `low` if they say it's a someday/nice-to-have.
- **skill** — if the todo clearly belongs to a Hub brain, set that brain's name
  (`website-brain`, `marketing-brain`, `local-seo-brain`, `claude-obsidian`,
  `claude-ads`, `client-intelligence-report`); otherwise use `manual`.

## 2. Insert the row

```bash
node "$CLI" add "<title>" --priority=<high|normal|low> --skill=<brain|manual>
```

`source` defaults to `manual`. The CLI creates `todos/todos.db` (and the schema)
on first use, so no setup is needed. If the user gave several distinct follow-ups
in one message, run one `add` per todo.

## 3. Confirm

Report the row(s) added (the CLI prints `added #<id>`) and the parsed
priority/skill, then show the new open count (`node "$CLI" count open`) and
suggest `/mb:todos-list` to see the backlog or `/mb:todos-review` to triage it.
Don't touch any other todos.
