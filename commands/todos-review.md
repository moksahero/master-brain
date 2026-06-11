---
description: Triage the TODO backlog — dedupe, prioritize, mark stale/blocked — so the list stays trustworthy.
---

Read the `master-brain` skill. Then triage the SQLite backlog so it stays honest
before anyone runs `/mb:todos-execute`. This is the "constantly reviewed" loop.

```bash
CLI="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs"
```

## Steps

1. Run `node "$CLI" list all --json` to load every row.
2. **Dedupe:** auto-captured rows for the same skill close in time often describe
   one piece of work. Keep the richest one; close the rest with a pointer —
   `node "$CLI" done <id> --outcome="merged into #<kept-id>"`.
3. **Prioritize:** the CLI doesn't edit priority in place, so when a row's
   priority is wrong, close the stale row and re-add it at the right level
   (`node "$CLI" add "<title>" --priority=high --skill=<skill>`). Client-facing
   report/delivery todos rank high. (For light touch-ups you may also note the
   correction in your summary and let `-execute` handle it.)
4. **Mark stale:** if a todo's underlying run is clearly superseded, or it's older
   than ~14 days with no value, `node "$CLI" stale <id> --note="<why>"`.
5. **Mark blocked:** if a todo can't proceed (missing key, awaiting client),
   `node "$CLI" block <id> --note="<what it's waiting on>"`.

Then show a short before/after summary: how many merged, reprioritized, marked
stale/blocked — and the resulting `N open · M done · K blocked/stale` counts
(`node "$CLI" count ...`). End by recommending `/mb:todos-execute` if there are
actionable open todos.
