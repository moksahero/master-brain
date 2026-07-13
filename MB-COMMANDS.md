# Master Brain — Command Cheat-Sheet

The `/mb:` commands are the orchestration layer for the AI Marketing Hub. This is
the "which command, when" reference for Master Brain itself (the captured
classroom covers the underlying `/seo`, `/blog`, `/ads`, and brain workflows — see
[`PROMPTS.md`](PROMPTS.md); this page covers the `/mb:` layer that drives them).

New here? The one command to remember is **`/mb:idk`** — it detects what you have
and tells you the next step.

## Setup & health

| Command | When to run it |
| --- | --- |
| `/mb:install` | First thing, once. Clones every brain into `~/.claude/skills` and installs the claude-ads + claude-mem plugins. |
| `/mb:doctor` | "Am I set up right?" / "what's broken?" — checks installs, API keys (present/absent), tooling, and the todo backlog. |
| `/mb:update` | Periodically — fast-forwards every installed brain to the latest version. |
| `/mb:push` | After you improve this project's tooling — promotes those edits up to the source repo so every project gets them. |

## Onboard & operate

| Command | When to run it |
| --- | --- |
| `/mb:idk <goal>` | Any time you're unsure. Routes you to the right brain/command for what you're trying to do. |
| `/mb:init <goal>` | Starting a new client/project — scaffolds the workspace (`wiki/`, `data/`, `todos/`, `CLAUDE.md`), wires the right brains, and queues the first TODOs from the blessed prompts. |
| `/mb:report <url>` | When you want the fused multi-brain client intelligence report (the agency-grade bilingual PDF) for a site. |
| `/mb:ads-google [client] [mode]` | Operating a live Google Ads account week to week. Phase-gated (launch-check / watch / optimize / audit), budget-calibrated, and it trains itself via a playbook + experiment ledger in your workspace. |

## Inside `/mb:init` — what it actually does

`/mb:init <goal>` is the workhorse. It turns a few answers into a fully wired
project, with the first work already queued from blessed prompts:

1. **Short intake (one round).** New vs existing · whether to scaffold a
   Next.js + Tailwind `web/` · focus (SEO/content, local SEO, paid ads, website
   capture, or just a report) · target market/location · primary URL · report
   language (incl. bilingual, e.g. English + Japanese).
2. **API credentials (only if missing).** Checks `FIRECRAWL_API_KEY` and
   `DATAFORSEO_LOGIN`/`DATAFORSEO_PASSWORD`, asks for any missing (explaining what
   each unlocks), and persists them securely (`chmod 600`, sourced from
   `~/.zshenv`, never printed). Skipping is fine — the project runs in degraded
   "public-evidence" mode and records that in `CLAUDE.md`.
3. **Scaffolds the workspace.** Always creates `wiki/` (a real Obsidian vault via
   claude-obsidian), `data/`, `todos/`, and `CLAUDE.md`; adds `reports/` and
   `web/` only when the answers call for them. The `CLAUDE.md` gets the managed
   **Persistence block** so every future session writes work back to the vault,
   and the project is **registered** + seeded with the canonical `todos/` tooling
   (reachable later by `/mb:update` fan-out and `/mb:push` promotion).
4. **Maps focus → brains and queues first actions.** Routes the focus to the right
   brain (SEO → marketing-brain, local → local-seo-brain, ads → claude-ads,
   capture → website-brain, report → client-intelligence-report), grounds the plan
   in the canonical **5-step client flow** from the captured classroom, and **seeds
   each first TODO from the blessed Prompt Library prompt** (the real `/seo audit`,
   `/ads audit`, … with its slash command and `<placeholders>`) — so queued work
   starts from the canonical prompt, not a guess.
5. **Confirms.** Shows the created tree, active brains, and queued TODOs, then
   offers to kick off the most relevant brain.

> Net effect: `/mb:init` goes from "scaffold folders + a vague first action" to
> "scaffold + register + wire persistence + queue TODOs pre-loaded with the
> blessed, runnable prompts." See those prompts with
> `bash scripts/classroom.sh prompts skill <ads|seo|blog|local|marketing|video|client>`.

## The TODO loop (nothing gets dropped)

Every brain run is auto-captured as a TODO. Keep the list trustworthy and clear it:

| Command | When to run it |
| --- | --- |
| `/mb:todos-add "<follow-up>"` | Capture a follow-up you don't want to lose. |
| `/mb:todos-list` | See the backlog (open / done / all). |
| `/mb:todos-review` | Triage — dedupe, prioritize, mark stale/blocked. |
| `/mb:todos-execute` | Work every open TODO to completion (records an outcome on each). |
| `/mb:todos-routine` | Generate recurring TODOs on a cadence (pair with `/schedule`). |
| `/mb:todos-log` | Project history — what's been done, chronologically, with outcomes. |

## A typical first run

```text
/mb:install                      # get the fleet
/mb:doctor                       # confirm keys + tooling
/mb:init acme-seo                # scaffold the project, queue first actions
/mb:idk grow organic traffic     # let it route you to the first brain run
```

> These commands are also in the queryable prompt catalog as the `mb` bucket:
> `bash scripts/classroom.sh prompts skill mb` · `... prompts get mb 2`.
> This page and that bucket are repo-owned (source: `prompts/mb-prompts.md` +
> `commands/`), so a classroom re-capture never overwrites them.
