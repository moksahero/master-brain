---
description: Triage the TODO backlog — dedupe, prioritize, mark stale/blocked — so the list stays trustworthy.
---

Read the `master-brain` skill. Then triage `./todos/` so the backlog stays
honest before anyone runs `/mb:todos-execute`. This is the "constantly
reviewed" loop.

## Steps

1. Read every `todos/*.md` (frontmatter + body).
2. **Dedupe:** auto-captured todos for the same skill close in time often
   describe one piece of work. Merge duplicates into one, preserving any manual
   notes; mark the redundant files `status: done` with a `merged-into:` pointer.
3. **Prioritize:** set `priority` (high / normal / low) based on impact and
   whether it blocks delivery. Client-facing report/delivery todos rank high.
4. **Mark stale:** if a todo's underlying run is clearly superseded or older than
   ~14 days with no action and no value, set `status: stale` with a one-line why.
5. **Mark blocked:** if a todo can't proceed (missing key, awaiting client),
   set `status: blocked` and record what it's waiting on.
6. **Enrich thin todos:** auto-captured stubs often just say "review the run".
   Where you can tell what the actual next action is, write it into `## Next
   actions` so `-execute` has something concrete to do.

Make the edits directly to the files. Then show a short before/after summary:
how many merged, reprioritized, marked stale/blocked, enriched — and the
resulting `N open · M done · K blocked/stale` counts. End by recommending
`/mb:todos-execute` if there are actionable open todos.
