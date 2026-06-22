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
