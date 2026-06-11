---
description: Add a manual TODO to ./todos — capture a follow-up so it joins the tracked backlog.
argument-hint: "<what to do> (e.g. 'redo the GBP audit after the client verifies their profile')"
---

Read the `master-brain` skill. Then write one new TODO file into `./todos/` so it
flows through the same review/execute loop as the auto-captured ones.

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
- **slug** — lowercase, alphanumeric-and-dashes, from the title (for the filename).

## 2. Write the file

Create `./todos/` if it doesn't exist. Name the file
`todos/<YYYYMMDD-HHMMSS>-<slug>.md` (same stamp format the hook uses). Use this
exact frontmatter so `/mb:todos-list`, `/mb:todos-review`, and
`/mb:todos-execute` all parse it:

```markdown
---
status: open
priority: <high|normal|low>
skill: <brain or manual>
created: <YYYY-MM-DDTHH:MM:SS>
source: manual
---

# <title>

<the user's full description, verbatim if useful>

## Next actions
- [ ] <first concrete step, if known>
```

Generate the timestamps with `date` (`date '+%Y-%m-%dT%H:%M:%S'` for `created`,
`date '+%Y%m%d-%H%M%S'` for the filename). If the user gave several distinct
follow-ups in one message, write one file per todo.

## 3. Confirm

Report the file(s) created and the parsed priority/skill, then show the new open
count and suggest `/mb:todos-list` to see the backlog or `/mb:todos-review` to
triage it. Do not modify any other todos.
