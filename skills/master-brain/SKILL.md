---
name: master-brain
description: >
  Orchestration layer for the AI Marketing Hub brains. Use when the user wants to
  install, update, or onboard onto the Hub toolkits; scaffold a new or existing
  marketing project; decide WHICH brain to use; run the fused client intelligence
  report; or manage the auto-captured TODO backlog. Triggers on: "master brain",
  "set up the brains", "which brain do I use", "onboard me", "install the AI
  Marketing Hub skills", "update the brains", "marketing project scaffold",
  "what should I run next".
version: 0.1.0
license: MIT
metadata:
  author: AgriciDaniel
  category: marketing
---

# Master Brain

Master Brain is the **conductor** for the AI Marketing Hub. The individual brains
are powerful but there are many of them, and a new user does not know where to
start. Master Brain answers three questions:

1. **What do I have / need?** — install and update the fleet (`/mb:install`, `/mb:update`, `/mb:doctor`).
2. **What should I do?** — onboard, scaffold a project, and route to the right brain (`/mb:idk`, `/mb:init`).
3. **Did anything get dropped?** — every brain run becomes a TODO that is tracked, reviewed, and executed (`/mb:todos-*`).

## The fleet

| Brain | Repo | What it does |
| --- | --- | --- |
| **claude-obsidian** | `AI-Marketing-Hub/claude-obsidian` | The knowledge substrate. A compounding Obsidian wiki every other brain writes into. |
| **website-brain** | `AI-Marketing-Hub/website-brain` | Crawl any site into a clean, generation-ready Obsidian vault (Firecrawl). |
| **marketing-brain** | `AI-Marketing-Hub/marketing-brain` | Competitor + keyword research → a source-cited growth/SEO plan (DataForSEO). |
| **local-seo-brain** | `AI-Marketing-Hub/local-seo-brain` | Google Business Profile, map-pack rankings, reviews, citations, NAP. |
| **claude-ads** | `AI-Marketing-Hub/claude-ads` | Paid media audit + AI creative across Google/Meta/TikTok/LinkedIn/etc. |
| **client-intelligence-report** | `AI-Marketing-Hub/client-intelligence-report` | The fused multi-brain "Mega-Brain" → an agency-grade bilingual PDF. |
| **claude-mem** | `thedotmack/claude-mem` | Cross-session memory so the brains remember past work. |

Brains install into `~/.claude/skills/<name>` (members-only repos; needs Pro access + git auth).

## How a project is shaped

`/mb:init` scaffolds a working directory like this:

```
<project>/
├── wiki/         # the fused Obsidian vault (claude-obsidian substrate)
├── web/          # optional Next.js + Tailwind site (new builds)
├── reports/      # generated PDFs / decks
├── data/         # raw research outputs (DataForSEO/Firecrawl caches, exports)
├── todos/        # the TODO loop — todos.db (SQLite) + the Next.js dashboard
└── CLAUDE.md     # project focus, target market, which brains are active
```

## The TODO loop (why nothing gets dropped)

When the plugin is installed, a `PostToolUse` hook (`hooks/hooks.json` →
`scripts/mb-todo.sh`) watches for any Hub brain run and inserts a TODO row into
the project's SQLite store at `todos/todos.db` (via the built-in `node:sqlite`
module — no native deps). All the `/mb:todos-*` commands read/write it through
`scripts/todos.mjs`, and the `todos/` Next.js + Tailwind app is an optional
dashboard for browsing and checking off todos in the browser. `SessionStart`
reminds you of the open count. You can also add your own follow-ups manually. Use:

- `/mb:todos-add` — capture a manual follow-up into the backlog.
- `/mb:todos-routine` — generate recurring TODOs on a cadence (the engine behind `/schedule`).
- `/mb:todos-list` — see the backlog (open vs done, grouped).
- `/mb:todos-review` — triage: dedupe, prioritize, mark stale/blocked.
- `/mb:todos-execute` — work every open TODO to completion (records an outcome).
- `/mb:todos-log` — the project history: what's been done, chronologically, with outcomes.

## Routing cheat-sheet (which brain for the job)

- "Capture / understand a website" → **website-brain**
- "Find competitors & keywords, build an SEO plan" → **marketing-brain**
- "Rank a local business / map pack / GBP" → **local-seo-brain**
- "Audit or build paid ads" → **claude-ads**
- "One premium report fusing all of the above" → **client-intelligence-report** (`/mb:report`)
- "Organize knowledge / persistent wiki" → **claude-obsidian**

## Commands

`/mb:idk` · `/mb:install` · `/mb:init` ·
`/mb:update` · `/mb:doctor` · `/mb:report` ·
`/mb:todos-add` · `/mb:todos-routine` · `/mb:todos-list` · `/mb:todos-review` · `/mb:todos-execute` · `/mb:todos-log`

## Locating the scripts

The deterministic helpers live in `scripts/`. When running as a plugin they are
at `$CLAUDE_PLUGIN_ROOT/scripts/`. If `$CLAUDE_PLUGIN_ROOT` is unset (e.g. the
folder was cloned as a plain skill), fall back to
`~/.claude/skills/master-brain/scripts/`.
