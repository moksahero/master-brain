---
description: Work every open TODO in ./todos to completion, marking each done as you go.
argument-hint: "[optional: filter by skill or priority]"
---

Read the `master-brain` skill. Then execute the open TODO backlog in `./todos/`.

## 1. Gather and order

1. Read every `todos/*.md` with `status: open`. Skip `done`, `blocked`, `stale`.
2. If `$ARGUMENTS` is given, filter to matching skill or priority.
3. Order by priority (high → normal → low), then oldest first.
4. If a todo is a thin auto-capture with no concrete `## Next actions`, infer the
   real next action from its `skill` and the project context before acting. If
   it's genuinely ambiguous, ask the user rather than guessing.

## 2. Execute one at a time

For each open todo:
- State which todo you're starting.
- Do the work — invoking the relevant brain/skill as needed (e.g. a
  marketing-brain todo runs marketing-brain). Keep outputs in `wiki/`,
  `reports/`, `data/` as appropriate.
- When complete, set `status: done` in that file's frontmatter, add a
  `completed: <YYYY-MM-DDTHH:MM:SS>` field (so `/mb:todos-log` can order the
  project history), and append a brief `## Outcome` note — what was produced, where
  it lives, and the headline result — in one or two sentences a client could read.
- If you hit a blocker (missing key, needs client input), set `status: blocked`
  with what it's waiting on, and move on — don't stall the whole run.

## 3. Caution

Some todos imply outward or hard-to-reverse actions (publishing, sending,
deleting). For those, confirm with the user before doing them rather than acting
autonomously.

## 4. Report

End with a summary: completed, blocked (and why), skipped, and the new backlog
counts. If new follow-up work surfaced, write it as fresh todos so the loop
continues.
