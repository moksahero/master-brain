---
description: Guided project setup — asks what you're doing, picks the right brains, and scaffolds the workspace.
argument-hint: "[optional: project name or goal]"
---

Read the `master-brain` skill. Then run guided init for a Master Brain project
in the current directory. The goal: a non-technical user answers a few questions
and walks away with the right scaffolding and the right brains wired up.

## 1. Ask the onboarding questions (one message, numbered)

Ask these, adapting to anything already given in `$ARGUMENTS`:

1. **New or existing project?** (Is there already a site/business, or are we starting fresh?)
2. **If new:** OK to create a **Next.js + Tailwind** app under `web/`? (yes / no / different stack)
3. **What's the focus?** (pick any: **SEO/content**, **local SEO / map pack**, **paid ads** — Google/Meta/TikTok/etc., **website capture**, **just a report**)
4. **Target market / location?** (city, country, or language — drives local + keyword work)
5. **Primary website URL** (if any).
6. **What language should reports be written in?** (e.g. English, Spanish, Japanese — or **bilingual** like English + Korean; default English)

Keep it to one round of questions. Don't interrogate.

## 2. Scaffold the workspace

Create only what the answers call for:

```
<project>/
├── wiki/         # always — the fused Obsidian vault (claude-obsidian substrate)
├── reports/      # if reports/report focus
├── data/         # always — raw research caches/exports
├── todos/        # always — the review loop
├── web/          # only if "new" + Next.js/Tailwind approved
└── CLAUDE.md     # project memory: focus, market, active brains
```

- Always create `wiki/`, `data/`, `todos/`, and `CLAUDE.md`.
- For the wiki, use **claude-obsidian** (`/wiki` or the `wiki` skill) to bootstrap
  a real vault rather than empty folders.
- For a new web build with approval, scaffold Next.js + Tailwind in `web/`
  (`npx create-next-app@latest web --tailwind --ts --eslint --app` — confirm
  before running, since it pulls packages).
- Write `CLAUDE.md` capturing: project name, new/existing, focus areas, target
  market, primary URL, **report language**, and the list of brains this project
  will use. Downstream report runs (`/mb:report`) should honor this
  language.

## 3. Map focus → brains and queue first actions

Translate the chosen focus into concrete brain runs, and write each as a TODO in
`todos/` so the work is tracked from the start:

- SEO/content → **marketing-brain**
- local SEO → **local-seo-brain**
- paid ads → **claude-ads**
- website capture → **website-brain**
- report → **client-intelligence-report** (`/mb:report`)

## 4. Confirm

Show what was created (tree), which brains are active, and the queued todos.
End with: "Want me to start with [most relevant brain] now?"
