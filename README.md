# Master Brain

**The orchestration layer for the [AI Marketing Hub](https://github.com/AI-Marketing-Hub) brains.**

There are a lot of brains — website-brain, marketing-brain, local-seo-brain,
claude-obsidian, claude-ads, and the fused client-intelligence-report — and a new
member doesn't know which one to use or how to wire them together. Master Brain
is the conductor: it installs the fleet, onboards you, scaffolds your project,
routes you to the right brain, and turns every brain run into a tracked TODO so
nothing gets dropped.

## Install

Master Brain is a Claude Code plugin. Add the marketplace and install it:

```bash
claude plugin marketplace add AI-Marketing-Hub/master-brain
claude plugin install mb@ai-marketing-hub-master-brain
```

Then, in Claude Code:

```
/mb:install      # clone the brains into ~/.claude/skills + install the claude-ads & claude-mem plugins
/mb:init         # scaffold a project (wiki / web / reports / data / todos)
/mb:idk           # not sure what to do? this tells you the next step
```

> The brains are **private, members-only** AI-Marketing-Hub repos. You need
> [AI Marketing Hub Pro](https://www.skool.com/ai-marketing-hub-pro) access and a
> git account authenticated to GitHub. Master Brain clones via SSH and falls back
> to HTTPS, so you must have an **SSH public key registered in your GitHub account**
> ([GitHub guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account))
> — or a credential helper configured for HTTPS. Verify SSH with `ssh -T git@github.com`.

## Commands

| Command | What it does |
| --- | --- |
| `/mb:idk` | Router & onboarding. Detects what's installed and recommends the next action. |
| `/mb:install` | Clone/update every cloned brain + install the claude-ads & claude-mem plugins if missing. |
| `/mb:init` | Guided project setup — asks your goal, scaffolds the workspace, queues first todos. |
| `/mb:update` | Fast-forward every installed brain to the latest version. |
| `/mb:doctor` | Health check: installs, API keys (present/absent), tooling, todo backlog. |
| `/mb:report` | Drive the fused multi-brain client intelligence report for a URL. |
| `/mb:todos-add` | Add a manual follow-up TODO to the backlog. |
| `/mb:todos-routine` | Generate recurring TODOs on a cadence (pair with `/schedule`). |
| `/mb:todos-list` | List the TODO backlog (open / done / all). |
| `/mb:todos-review` | Triage: dedupe, prioritize, mark stale/blocked, enrich. |
| `/mb:todos-execute` | Work every open TODO to completion (records an outcome on each). |
| `/mb:todos-log` | Project history — what's been done, chronologically, with outcomes. |

## Prompt Library

[**PROMPTS.md**](PROMPTS.md) lists every runnable prompt available to Master Brain —
67 copy-paste prompts across 10 buckets: the `mb` bucket (Master Brain's own
`/mb:` commands, also in [**MB-COMMANDS.md**](MB-COMMANDS.md)) plus ads, seo, blog,
local, research, video, client, build, and install (parsed from the captured
classroom). Each carries its slash command and `<placeholders>`. Pull one from the CLI:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/classroom.sh" prompts get ads 0      # one prompt, ready to run
```

Regenerate the doc after a re-capture with `node scripts/prompts.mjs markdown > PROMPTS.md`.

## The brains

| Brain | What it does |
| --- | --- |
| **claude-obsidian** | The knowledge substrate — a compounding Obsidian wiki every brain writes into. |
| **website-brain** | Crawl any site into a clean, generation-ready Obsidian vault (Firecrawl). |
| **marketing-brain** | Competitor + keyword research → a source-cited growth/SEO plan (DataForSEO). |
| **local-seo-brain** | Google Business Profile, map-pack rankings, reviews, citations, NAP. |
| **claude-ads** (*plugin*) | Paid media audit + AI creative across Google/Meta/TikTok/LinkedIn/etc. Installs as a Claude plugin, not a `skills/` clone. |
| **client-intelligence-report** | The fused multi-brain "Mega-Brain" → an agency-grade bilingual PDF. |
| **claude-mem** (thedotmack · *optional, public plugin*) | Cross-session memory so the brains remember past work. Installs to `~/.claude/plugins`, not `skills/`. |
| **humanizer** (blader · *vendored, public*) | Strips AI-writing tells from prose so deliverables read human-written. Ships with the plugin as `mb:humanizer`; `/mb:install` also clones it standalone as `/humanizer`. |

## Humanizer (standing writing rule)

master-brain vendors [blader/humanizer](https://github.com/blader/humanizer) (MIT) under
`skills/humanizer/`. It's not just an on-demand command — it's a **standing rule**: before
the brains deliver any prose (marketing copy, reports, emails, blog drafts, client
deliverables), that text should be passed through the humanizer patterns so it reads
human-written, not AI-generated. master-brain's SessionStart hook reinforces this each
session. Skip it only for code, raw data, or when the user asks for verbatim output.

Run it directly on any text:

```
/humanizer        # or mb:humanizer
[paste text]
```

It honors a target register — e.g. "expressions a Japanese real-estate agent would
understand" produces plain, jargon-free Japanese. The pattern list itself is
English-oriented; for non-English output the agent applies the *spirit* (no inflated
symbolism, no promo fluff, plain words, natural rhythm) to the target language.

To re-sync after an upstream change, see `skills/humanizer/VENDORED.md`.

## How the TODO loop works

Installing the plugin activates a `PostToolUse` hook
([`hooks/hooks.json`](hooks/hooks.json) → [`scripts/mb-todo.sh`](scripts/mb-todo.sh)).
Whenever a Hub brain runs, a TODO row is written to a SQLite database at
`todos/todos.db` — using Node's built-in `node:sqlite` module, so there's no
native dependency and no `sqlite3` CLI to install (needs **Node ≥ 22.5**). Every
`/mb:todos-*` command reads and writes it through
[`scripts/todos.mjs`](scripts/todos.mjs). You can also capture your own follow-ups
with `/mb:todos-add`, and generate recurring ones on a cadence with
`/mb:todos-routine` (ads audit every two weeks, SEO refresh monthly, report refresh
quarterly — pair it with `/schedule` so it runs itself). `SessionStart` reminds you
of the open count. Keep the list trustworthy with `/mb:todos-review` and clear it
with `/mb:todos-execute` — which records an **outcome** on every todo it closes.
`/mb:todos-log` then turns those outcomes into a chronological project history (add
`--write` to save it to `reports/PROGRESS.md` for the client). No edits to your
global `settings.json` — the hook ships with the plugin.

### TODO dashboard (optional web app)

[`todos/`](todos/) is a small **Next.js 16 + Tailwind** app for browsing the
backlog and checking todos off in the browser — same SQLite store the hook and
commands use. Point it at a project's database and run it:

```bash
cd todos
npm install
TODOS_DB=/path/to/your/project/todos/todos.db npm run dev   # http://localhost:3000
```

It reads the DB live, so todos captured by brain runs show up on refresh, and
checking a box marks the row `done`. See [`todos/README.md`](todos/README.md).

## Project shape

`/mb:init` produces:

```
<project>/
├── wiki/         # the fused Obsidian vault (claude-obsidian substrate)
├── web/          # optional Next.js + Tailwind site (new builds)
├── reports/      # generated PDFs / decks
├── data/         # raw research outputs (Firecrawl / DataForSEO caches, exports)
├── todos/        # the TODO loop — todos.db (SQLite) + a Next.js dashboard
└── CLAUDE.md     # project focus, target market, active brains
```

## Requirements

- [Claude Code](https://claude.com/claude-code)
- **Node ≥ 22.5** → the TODO store uses the built-in `node:sqlite` module (no native build, no `sqlite3` CLI)
- AI Marketing Hub Pro access + authenticated git (an **SSH public key registered in your GitHub account**, or an HTTPS credential helper)
- **Firecrawl key** → full site capture + brand-tokens.json + screenshots (website-brain)
- **DataForSEO credentials** → real search volumes on the keyword map (marketing + local SEO)
- **Playwright MCP** → the browser the live audits log in through (`claude mcp add playwright npx @playwright/mcp@latest`)
- **GBP + ad-account access** → live local & paid audits (local-seo-brain + claude-ads) — via Playwright manual-login, CSV export, or native API
- **pandoc** (+ a CJK-capable LaTeX engine) → render the bilingual/Japanese report to PDF

`/mb:install` walks you through adding each of these; `/mb:doctor` re-checks them anytime.

---

Built for the AI Marketing Hub community · MIT licensed.
🆓 https://www.skool.com/ai-marketing-hub · ⚡ https://www.skool.com/ai-marketing-hub-pro
