---
description: Generate recurring TODOs from the project's routine schedule — the cadence engine behind /schedule.
argument-hint: "[status|due|all] (default: due — generate what's due now)"
---

Read the `master-brain` skill. Then run the routine engine: read the project's
routine schedule, work out what is **due**, and insert a fresh TODO row for each
due routine into `todos/todos.db` so recurring client work (ads audits, SEO
refreshes, GBP checks, report refreshes) never falls off the radar.

```bash
CLI="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs"
```

This command is designed to be **scheduled** — point `/schedule` (or `/loop`) at
`/mb:todos-routine` on whatever heartbeat you like (e.g. weekly or every two weeks)
and the per-routine cadence below decides what actually gets emitted each run. It
only *generates* TODOs; `/mb:todos-execute` does the work.

## 1. Load (or seed) the schedule

The schedule lives at `todos/routines.yml` (plain config, separate from the DB).
If the file is missing, create it with sensible defaults and tell the user to edit
the cadences / client name, then continue:

```yaml
# master-brain routine schedule → generates TODOs on a cadence.
# every:    Nd | Nw | Nm  (days / weeks / months)
# last_run: YYYY-MM-DD     (blank = treat as due now)
# Pair with: /schedule  →  /mb:todos-routine  (heartbeat) and  /mb:todos-execute
client: ""           # optional: client name or URL, interpolated into titles as {client}
routines:
  - id: ads-audit
    every: 2w
    title: "Run /ads audit + /ads budget for {client}; log findings as next actions"
    skill: claude-ads
    priority: high
    last_run:
  - id: seo-refresh
    every: 1m
    title: "marketing-brain: re-run keyword/competitor research, decide next action for {client}"
    skill: marketing-brain
    priority: normal
    last_run:
  - id: local-gbp
    every: 1m
    title: "local-seo-brain: geo-grid scan, review velocity, NAP/GBP check for {client}"
    skill: local-seo-brain
    priority: normal
    last_run:
  - id: site-recrawl
    every: 3m
    title: "website-brain: re-crawl {client} and diff against the last capture"
    skill: website-brain
    priority: low
    last_run:
  - id: client-report
    every: 3m
    title: "Refresh the fused client intelligence report for {client} (/mb:report)"
    skill: client-intelligence-report
    priority: normal
    last_run:
  - id: backlog-review
    every: 2w
    title: "Triage the TODO backlog (/mb:todos-review)"
    skill: manual
    priority: normal
    last_run:
```

## 2. Compute what's due

For each routine, due ⇔ `last_run` is blank OR `today − last_run ≥ every`. Use
`date` for today and parse `every` (`d`/`w`/`m`). Interpolate `{client}` from the
`client` field (drop it cleanly if empty).

`$ARGUMENTS` modes:
- **`status`** (or `due`) — dry run: print a table of each routine, its cadence,
  last run, next-due date, and whether it's due now. **Write nothing.**
- **`all`** — force-generate every routine regardless of due date (useful for a
  first run or a manual kick).
- **default** — generate only the routines that are due.

## 3. Emit TODOs (idempotent)

For each routine being generated, **skip if an open TODO for the same routine id
already exists** so re-running never spams duplicates:

```bash
# exits 0 (skip) if an open row already carries this routine id, else 1 (emit)
node "$CLI" has-open-routine <id> && echo "already open — skip" || \
  node "$CLI" add "<interpolated title>" \
    --priority=<from routine> --skill=<from routine> \
    --source=routine --routine=<id>
```

Then set that routine's `last_run` to today in `todos/routines.yml`.

## 4. Report

List what was generated (and what was skipped as already-open), show the new open
count (`node "$CLI" count open`), and print the next-due date for every routine.
If anything is due, suggest `/mb:todos-execute` to work it. If the user hasn't
automated this yet, remind them: "Schedule it with `/schedule` → `/mb:todos-routine`
(e.g. every two weeks) so this runs itself."
