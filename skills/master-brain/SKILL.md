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
| **website-audit** | *ships with this plugin* (`skills/website-audit/`) | Evidence-only site teardown → an owner-ready Times New Roman PDF. Ground-truth curl pass, five parallel specialist lanes, PIL callouts, inline-SVG charts, WeasyPrint, page-by-page verification. `/mb:website-audit`, bare `/website-audit`. |
| **jp-lp** | *ships with this plugin* (`skills/jp-lp/`) | 日本市場向けLPの設計・執筆・監査. Measured JP-specific patterns (two distinct LP populations, block orders per vertical, 和文 typography values, form/LINE/payment reality) plus the compliance gate that sits *upstream* of copy: 景表法・薬機法・特商法・医療広告ガイドライン・ステマ規制 and per-platform ad review. Ships a Japanese A4 PDF stylesheet. `/mb:jp-lp`, bare `/jp-lp`. |
| **anti-slop** (*plugin*) | `AgriciDaniel/anti-slop` | Substance pass over any deliverable: finds and repairs padding, vague attribution, unsourced claims, dead citations, non-existent packages, vendor residue. `/slop-review`, `/slop-rewrite`, `/slop-verify`, `/slop-code`. Reports defects, never authorship. Ships a global write gate — see [the delivery rule](#the-delivery-rule--substance-before-style). |
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

**In an `/mb:init` project, routing is automatic.** The `mb:managed` block that
`scripts/claude-md.sh` writes into every project's `CLAUDE.md` carries a full
topic-to-skill map plus the rule that a *mention* is the trigger: "our Reddit
ads" runs `ads-reddit`, no slash command required. Most specific skill wins, and
the session names the skill before running it. `/mb:update` retrofits that block
into projects scaffolded before the map existed. The cheat-sheet below is the
conductor's own shorthand for the brain-level choice.

- "Capture / understand a website" → **website-brain**
- "Find competitors & keywords, build an SEO plan" → **marketing-brain**
- "Rank a local business / map pack / GBP" → **local-seo-brain**
- "Audit or build paid ads" → **claude-ads**
- "What is wrong with my website / audit this site" → **website-audit** (`/mb:website-audit`)
- **"日本market向けのLPを作る / 直す / 法務チェックする"** → **jp-lp** (`/mb:jp-lp`, bare `/jp-lp`).
  Use it for *any* Japanese-market landing page, and use it *instead of* reaching for
  `landing-page-optimization` alone: that skill is English and Western-SaaS shaped, so it
  misses the two-population split, the 和文 typography values, the form and LINE reality, and
  the 景表法・薬機法・医療広告 gate that in Japan sits **upstream** of the copy, not after it.
  Run both when useful; `jp-lp` wins on conflict.
- "One premium report fusing all of the above" → **client-intelligence-report** (`/mb:report`)
- "Organize knowledge / persistent wiki" → **claude-obsidian**
- "Review / clean up a draft, check its sources, de-slop it" → **anti-slop**
  (`/slop-review`, `/slop-rewrite`, `/slop-verify`, `/slop-code`). See
  [the delivery rule](#the-delivery-rule--substance-before-style) below; it runs
  on every prose deliverable, not just on request.
- **"Research an online store / e-commerce site"** → the **e-commerce recipe**, not
  the generic SEO route. Read
  [`references/ecommerce-research.md`](references/ecommerce-research.md) and run it
  in order: **catalog pull → `/website-audit` → `/seo-ecommerce` → marketing-brain
  → `/ads-dna` + `/ads-competitor` + `/ads-landing` → `/mb:report`**. The catalog
  pull (step 0) is mandatory — a store is audited from its SKUs, not its homepage.
  Skip `local-seo-brain` unless there are physical stores.

## The delivery rule — substance before style

Every prose deliverable a Hub brain produces (reports, marketing copy, emails,
blog drafts, client decks) goes through **two passes, in this order**. The
`SessionStart` hook in `hooks/hooks.json` states this rule at the top of every
session.

**Pass 1 — substance (`anti-slop`).** Fix what is actually wrong before touching
how it reads:

| Command | Use it for |
| --- | --- |
| `/slop-review` | read-only findings over prose or docs: padding, vague attribution, hollow analysis, unsourced claims. Diagnoses only; never edits. |
| `/slop-rewrite` | repairs **only** what a review already listed. Never invents a fact, number, date or citation not already in the source. |
| `/slop-verify` | citations, DOIs/ISBNs/arXiv IDs, links, package existence, vendor residue (`oaicite`, `[cite: 1]`, `utm_source=chatgpt.com`). The only layer allowed to hard-fail. |
| `/slop-code` | source, tests, config, generated docs, commit messages, PR bodies. |

**Pass 2 — style (`humanizer`).** Only after the substance pass: run
`mb:humanizer` / `/humanizer` so the copy reads human-written.

**Why this order.** Stripping the style markers off an unsourced paragraph
leaves an unsourced paragraph with the warning label removed. Anti-slop is built
on that objection, so it goes first and humanizer polishes what survives.

Two limits worth stating, because they are design constraints and not
disclaimers:

- Anti-slop **reports defects, never authorship**. There is no score, no
  percentage, and no verdict about who or what wrote something. Do not ask it
  for one and do not present its output as one.
- Its house-style linter (em dash, en dash, spaced double hyphen, banned tokens)
  is **house style only** — a preference chosen by a document's owner. A hit is
  not a defect and says nothing about quality. Note that this repo's own house
  style *uses* em dashes freely, so the linter and this repo disagree by design.

### The global write gate (know what you are turning on)

The `anti-slop` plugin ships its own `PostToolUse` hook on `Write|Edit` with no
skill or path condition. While the plugin is installed and its linter path
resolves, it fires on **every write in every repository** and blocks (exit 2) on
a house-style hit. Because this repo's docs use em dashes throughout, that gate
will block routine edits here.

It ships broken-by-default: the hook looks for the linter at
`$CLAUDE_PLUGIN_ROOT/../anti-slop-brain/scripts/lint_voice.py`, which only
resolves in the upstream repo layout, not in the flattened plugin cache. To
switch it **on**, link the sibling brain into the cache:

```bash
ln -sfn ~/.claude/plugins/marketplaces/anti-slop/anti-slop-brain \
        ~/.claude/plugins/cache/anti-slop/anti-slop/anti-slop-brain
```

To switch it **off** again, remove that symlink — the hook returns to a silent
no-op. Deleting the link is the whole revert; nothing was written to any
settings file.

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
- **The actual prompt to run a skill** → course `09-prompt-library/` — but use the
  catalog below, don't hand-read the lessons.

### Runnable prompts — the Prompt Library catalog

The Prompt Library is parsed into a queryable catalog of **67 runnable prompts**
(via `scripts/prompts.mjs`, exposed through `classroom.sh prompts`). This includes
the **`mb` bucket** — Master Brain's own `/mb:` commands (source:
`prompts/mb-prompts.md`, also rendered as [`MB-COMMANDS.md`](../../MB-COMMANDS.md))
— plus the per-skill buckets parsed from the captured classroom. A rendered,
human-readable listing of all of them lives at [`PROMPTS.md`](../../PROMPTS.md)
(regenerate with `node scripts/prompts.mjs markdown > PROMPTS.md`).
When you route a user to a skill — or when a new user asks how to run Master
Brain itself — hand back the *blessed* prompt instead of inventing one:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/classroom.sh" prompts list             # 9 buckets + counts
bash "$SCRIPTS/classroom.sh" prompts skill ads        # the prompts in a bucket
bash "$SCRIPTS/classroom.sh" prompts get ads 0        # one prompt, ready to fill + run
bash "$SCRIPTS/classroom.sh" prompts search "audit"   # match across all buckets
```

Bucket keys are fuzzy — `mb` (→ the `/mb:` commands; aliases `commands`,
`master-brain`), `ads`, `seo`, `blog`, `local` (→ local-seo), `marketing`
or `research` (→ research-brain), `video` (→ video-content), `client` (→
client-agency), `install`. Every prompt comes with its slash command (e.g.
`/ads audit`) and `<placeholders>` the user fills in. `get` prepends the three
context lines (Business / Goal / Voice) the library recommends.

## Commands

`/mb:idk` · `/mb:install` · `/mb:init` ·
`/mb:update` · `/mb:push` · `/mb:ship` · `/mb:doctor` ·
`/mb:website-audit` (bare `/website-audit`) · `/mb:report` ·
`/mb:todos-add` · `/mb:todos-routine` · `/mb:todos-list` · `/mb:todos-review` · `/mb:todos-execute` · `/mb:todos-log`

## Changing master-brain itself — always ship, never just push

Editing a file in this repo does **not** make the change usable. Two separate
things have to happen, and `/mb:ship` (→ `scripts/ship.sh`) does both:

1. **System-wide availability** — version bump → mirror into the local marketplace
   → `claude plugin update` (refreshes the `mb:` commands) → `brains.sh register`
   (writes the **bare** aliases like `/website-audit` and every brain skill into
   `~/.claude/commands`). A plain `git push` skips all of this, so the new command
   does not exist on this machine until the next `/mb:update`.
2. **The repo** — `git add -A`, commit, push to `origin`.

```bash
bash scripts/ship.sh -m "feat(mb): <what changed>"          # patch bump + everything
bash scripts/ship.sh --minor -m "feat(mb): new command"     # new command or skill
bash scripts/ship.sh --no-bump -m "docs(mb): …"             # docs only
```

Restart Claude Code after adding a *new* command so the session loads it. Other
machines pick it up with `/mb:update`.

## Locating the scripts

The deterministic helpers live in `scripts/`. When running as a plugin they are
at `$CLAUDE_PLUGIN_ROOT/scripts/`. If `$CLAUDE_PLUGIN_ROOT` is unset (e.g. the
folder was cloned as a plain skill), fall back to
`~/.claude/skills/master-brain/scripts/`.
