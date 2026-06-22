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
4. **How do improvements spread?** — tooling flows DOWN into each project on `/mb:update`, and a project's tooling edits flow UP to the source repo via `/mb:push` so every project shares them.

## The fleet

| Brain | Repo | What it does |
| --- | --- | --- |
| **claude-obsidian** | `AI-Marketing-Hub/claude-obsidian` | The knowledge substrate. A compounding Obsidian wiki every other brain writes into. |
| **website-brain** | `AI-Marketing-Hub/website-brain` | Crawl any site into a clean, generation-ready Obsidian vault (Firecrawl). |
| **marketing-brain** | `AI-Marketing-Hub/marketing-brain` | Competitor + keyword research → a source-cited growth/SEO plan (DataForSEO). |
| **local-seo-brain** | `AI-Marketing-Hub/local-seo-brain` | Google Business Profile, map-pack rankings, reviews, citations, NAP. |
| **claude-ads** (*plugin*) | `AI-Marketing-Hub/claude-ads` | Paid media audit + AI creative across Google/Meta/TikTok/LinkedIn/etc. Installs as a Claude plugin, not a `skills/` clone. |
| **client-intelligence-report** | `AI-Marketing-Hub/client-intelligence-report` | The fused multi-brain "Mega-Brain" → an agency-grade bilingual PDF. |
| **claude-mem** (*optional · public plugin*) | `thedotmack/claude-mem` | Cross-session memory so the brains remember past work. |

Most brains clone into `~/.claude/skills/<name>` (members-only repos; needs Pro access + git auth). **claude-ads** and **claude-mem** are the exceptions — they install as Claude plugins under `~/.claude/plugins`.

This table is the curated core, but the fleet is **not** hard-coded: when `gh` is
authenticated, `/mb:install` and `/mb:update` walk the whole `AI-Marketing-Hub`
org and pick up any other brain published there (e.g. `social-hub`) automatically.
Discovery includes Claude plugins and Obsidian-brain vaults; it skips
Codex-runtime variants (`codex-*`) and org infra. Run
`bash scripts/brains.sh discover` to see what the org adds beyond this table.

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

## Persistence — work compounds in `wiki/` and `data/`

A Master Brain project is meant to *accumulate*. The whole point of scaffolding
`wiki/` and `data/` is that they become the project's durable memory — **work that
isn't written there is gone when the session ends.** This is a standing rule for
*every* session that operates in an `/mb:init` project, not just brain runs:

- **`wiki/`** — the lasting knowledge. Any finding, decision, number, competitor
  fact, or deliverable summary worth more than this one chat → a note under
  `wiki/` (`entities/`, `concepts/`, `sources/`, `deliverables/`), a one-line
  entry in `wiki/log.md`, and a link from `wiki/index.md`. Update existing notes
  rather than duplicating.
- **`data/`** — the raw evidence behind that knowledge: API dumps
  (DataForSEO/Firecrawl), scrapes, exports, CSVs. Regenerable, but cite-able.
- **`reports/`** — rendered deliverables (PDF/HTML). Output, not memory.

The failure mode to avoid: results pile up only in `reports/` or `web/` while
`wiki/` and `data/` stay frozen at bootstrap. Before finishing a substantive
piece of work, **write it back** — update `wiki/`, drop raw artifacts in `data/`,
append `wiki/log.md`. `/mb:init` bakes this rule into every project's `CLAUDE.md`
so future sessions inherit it automatically.

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

## Knowledge base — the captured classroom

The member classroom from
[skool.com/ai-marketing-hub-pro](https://www.skool.com/ai-marketing-hub-pro/classroom)
is mirrored into this repo at **`classroom/`** — 12 courses, 167 lessons, one
Markdown file each, plus `classroom/README.md` as the index. This is the
**canonical, human-written documentation** for the whole Hub: setup order,
which-skill-when, the client-delivery flow, troubleshooting, and the copy-paste
Prompt Library. When a question is about *how the Hub works or how to run it*,
prefer this corpus over improvising — it is the source of truth the commands
route against.

Don't load it wholesale (it's ~1.4 MB). Pull the one relevant lesson with the
helper:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/classroom.sh" search "which skill when"   # → matching lesson paths
bash "$SCRIPTS/classroom.sh" show 03-how-it-all-works/04-which-skill-when.md
bash "$SCRIPTS/classroom.sh" courses                     # the 12 course names
```

Map of what to consult when:

- **Setup / install / API keys / troubleshooting** → course `02-setup-install/`
  (esp. `09-troubleshooting-your-install-checklist.md`).
- **Which brain/skill for a goal, how it fits together** → course
  `03-how-it-all-works/` (esp. `04-which-skill-when.md`) and `01-start-here/03-pick-your-path.md`.
- **Running a client engagement end to end** → course `04-client-delivery/`.
- **The actual prompt to run a skill** → course `09-prompt-library/`.

## Commands

`/mb:idk` · `/mb:install` · `/mb:init` ·
`/mb:update` · `/mb:push` · `/mb:doctor` · `/mb:report` ·
`/mb:todos-add` · `/mb:todos-routine` · `/mb:todos-list` · `/mb:todos-review` · `/mb:todos-execute` · `/mb:todos-log`

## Locating the scripts

The deterministic helpers live in `scripts/`. When running as a plugin they are
at `$CLAUDE_PLUGIN_ROOT/scripts/`. If `$CLAUDE_PLUGIN_ROOT` is unset (e.g. the
folder was cloned as a plain skill), fall back to
`~/.claude/skills/master-brain/scripts/`.
