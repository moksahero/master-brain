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
├── wiki/         # always — the fused Obsidian vault; the project's durable memory
├── reports/      # if reports/report focus — rendered deliverables
├── data/         # always — raw research caches/exports (the evidence behind wiki/)
├── todos/        # always — the review loop (todos.db, created on first capture)
├── web/          # only if "new" + Next.js/Tailwind approved
└── CLAUDE.md     # project memory: focus, market, active brains, persistence rule
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
- The scaffolded `CLAUDE.md` **must include a "Persistence" conventions block**
  so every future session in this directory writes work back to the vault rather
  than only to `reports/`/`web/`. Embed this verbatim (adapt the report-language
  line to the chosen language):

  ```markdown
  ## Persistence — keep the work in the vault
  This project is a Master Brain workspace. `wiki/` and `data/` are its durable
  memory: **work that isn't written there is lost when the session ends.** So, as
  a standing rule for every session in this directory:

  - **`wiki/`** — the lasting knowledge. Any finding, decision, number, competitor
    fact, or deliverable summary worth more than this one chat → a note under
    `wiki/` (`entities/`, `concepts/`, `sources/`, `deliverables/`), a one-line
    entry in `wiki/log.md`, and a link from `wiki/index.md`. Update existing notes
    instead of duplicating.
  - **`data/`** — the raw evidence behind that knowledge: API dumps
    (DataForSEO/Firecrawl), scrapes, exports, CSVs. Regenerable, but cite-able.
  - **`reports/`** — rendered deliverables (PDF/HTML). Output, not memory.

  Before finishing a substantive piece of work, write it back: update `wiki/`,
  drop raw artifacts in `data/`, append `wiki/log.md`. Don't leave the vault
  frozen at bootstrap while results pile up only in `reports/` or `web/`.
  ```

## 3. Map focus → brains and queue first actions

Translate the chosen focus into concrete brain runs, and queue each as a TODO so
the work is tracked from the start — add them via the CLI (creates `todos/todos.db`
on first use):

```bash
node "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs" \
  add "<first action>" --skill=<brain> --priority=high
```


- SEO/content → **marketing-brain**
- local SEO → **local-seo-brain**
- paid ads → **claude-ads**
- website capture → **website-brain**
- report → **client-intelligence-report** (`/mb:report`)

## 4. Confirm

Show what was created (tree), which brains are active, and the queued todos.
End with: "Want me to start with [most relevant brain] now?"
