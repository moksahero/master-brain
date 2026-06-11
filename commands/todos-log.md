---
description: Show what's been done — a chronological log of completed TODOs and their outcomes (the project's history).
argument-hint: "[all | last <N> | since <YYYY-MM-DD>] [--write]  (default: all)"
---

Read the `master-brain` skill. Then produce a **project history** from the TODO
backlog — a clean, chronological record of what has actually been done, so the
user (or their client) can see the project's progress at a glance.

This is read-only by default: it never changes a todo's status. It's the
counterpart to `/mb:todos-list` (which shows what's *left*) — this shows what's
*finished*.

## 1. Gather completed work

1. If `./todos/` doesn't exist, say there's no history yet and stop.
2. Read every `todos/*.md` with `status: done`. For each, pull: the `#` title, the
   `completed` date (fall back to `created` if absent), `skill`, `priority`,
   `source` (auto-capture / manual / routine), and the `## Outcome` note.
3. Apply `$ARGUMENTS`: `last <N>` keeps the N most recent, `since <date>` keeps
   those completed on/after that date, `all` (default) keeps everything.

## 2. Render the timeline

Group by completion date, newest day first. Under each date, one line per item:

```
## 2026-06-10
- ✅ **Redo GBP audit after verification** · local-seo-brain · routine
  → Map-pack rank up to #3 for "x"; findings in wiki/audits/gbp-2026-06.md
- ✅ **Refresh Q2 ad creative** · claude-ads · manual
  → Replaced 4 fatigued ads; new set live, CTR baseline reset
```

Use the `## Outcome` text for the `→` line (trim to its headline). Lead each item
with the title in bold, then `skill · source`.

## 3. Summarize

Footer with the totals that make progress legible:
- **N tasks completed** total (and this week / this month if dates allow).
- Breakdown by skill (e.g. `claude-ads ×6 · marketing-brain ×3 · local-seo-brain ×4`).
- A pointer to what's still moving: open + blocked counts (from `/mb:todos-list`).

## 4. Optional: persist it

If `$ARGUMENTS` contains `--write`, also write the rendered timeline to
`reports/PROGRESS.md` (create `reports/` if needed) so it's a shareable artifact —
a running changelog a non-technical owner can open. Tell the user the path. Without
`--write`, only print to the conversation and change nothing.
