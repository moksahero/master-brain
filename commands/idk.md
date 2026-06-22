---
description: Master Brain router & onboarding. Detects what's installed and tells you exactly what to run next.
argument-hint: "[optional: what you're trying to do]"
---

Read the `master-brain` skill for the full ecosystem map. Then act as the
onboarding router. The user may be brand new and not know where to start.

## 1. Take stock (silent, fast)

Run the status helper to see the fleet:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/brains.sh" status
```

Also check: is `claude-mem` installed (`~/.claude/plugins/installed_plugins.json`),
is the current directory a Master Brain project (look for `wiki/`, `todos/`,
`CLAUDE.md`), and how many open todos exist
(`[ -f todos/todos.db ] && node "$SCRIPTS/todos.mjs" count open`).

## 2. Report a short dashboard

Show a compact summary: which brains are installed (with versions), claude-mem
status, whether this folder is an initialized project, and the open-todo count.
Keep it to a tight table + one or two lines. Do NOT dump raw output.

## 3. Recommend the next step

Pick the single most useful next action and say it plainly:

- **Brains missing** → "Run `/mb:install` to get the toolkits."
- **Installed but no project here** → "Run `/mb:init` to scaffold a project."
- **Project exists, open todos** → "You have N open todos — `/mb:todos-list` then `/mb:todos-execute`."
- **User described a goal in `$ARGUMENTS`** → route them to the right brain using
  the cheat-sheet in the skill, and offer to kick it off.

If the user passed `$ARGUMENTS` describing what they want (e.g. "rank my plumbing
business in Austin"), map it to the right brain(s) and propose the exact command
or prompt to run next. Always end with one clear, single recommended action.

Ground the routing in the canonical docs rather than improvising: before
recommending, consult the captured classroom for the matching decision lesson —

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/classroom.sh" show 03-how-it-all-works/04-which-skill-when.md
bash "$SCRIPTS/classroom.sh" search "<the user's goal>"   # find the closest lesson(s)
```

If a Prompt Library lesson exists for the brain you're routing to
(`bash "$SCRIPTS/classroom.sh" search "<brain> prompt"`), hand back its prompt so
the user can run it immediately.
