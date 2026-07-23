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
3. **What's the focus?** (pick any: **SEO/content**, **local SEO / map pack**, **paid ads** — Google/Meta/TikTok/etc., **website capture**, **full website audit** — the evidence-only teardown PDF, **just a report**)
4. **Target market / location?** (city, country, or language — drives local + keyword work)
5. **Primary website URL** (if any).
6. **What language should reports be written in?** (e.g. Japanese, English, Spanish — or **bilingual** like Japanese + English; **default Japanese**)

Keep it to one round of questions. Don't interrogate.

## 2. Wire up API credentials (ask only if missing)

The research brains need API keys to pull real data:

- **`FIRECRAWL_API_KEY`** — full-site crawl (website-brain, the report's site capture).
- **`DATAFORSEO_LOGIN` / `DATAFORSEO_PASSWORD`** — keyword volumes, SERP/Local Pack
  rank, competitor and geo-grid data (marketing-brain, local-seo-brain, the report).

Without them, the brains fall back to a degraded "public-evidence" mode (no real
volumes, no map-pack rank, no full crawl). So, before scaffolding:

1. **Check what's already set** — they are stored system-wide in
   `~/.config/ai-marketing-hub/secrets.env` (sourced from `~/.zshenv`):
   ```bash
   for v in FIRECRAWL_API_KEY DATAFORSEO_LOGIN DATAFORSEO_PASSWORD; do
     printf "%s=%s\n" "$v" "${!v:+SET}"   # prints SET or blank — never the value
   done
   ```
   Also check the per-brain fallbacks `~/.config/website-brain/.env` and
   `~/.config/marketing-brain/.env` in case a key lives there but isn't exported.
2. **Ask for any that are missing.** Tell the user what each key unlocks and that
   they can paste it now or skip (the project still works in degraded mode). Get
   DataForSEO at dataforseo.com, Firecrawl at firecrawl.dev.
3. **Persist any the user provides — system-wide, never printed:**
   ```bash
   mkdir -p ~/.config/ai-marketing-hub
   SECRETS=~/.config/ai-marketing-hub/secrets.env
   touch "$SECRETS"; chmod 600 "$SECRETS"
   # upsert each KEY=value WITHOUT echoing the value to the transcript
   # (write via a heredoc/printf the user can't see, or have them paste into the file)
   # then ensure ~/.zshenv sources it for every shell:
   grep -qF 'ai-marketing-hub secrets' ~/.zshenv 2>/dev/null || cat >> ~/.zshenv <<'EOF'
   # >>> ai-marketing-hub secrets >>>
   if [ -f "$HOME/.config/ai-marketing-hub/secrets.env" ]; then
     set -a; . "$HOME/.config/ai-marketing-hub/secrets.env"; set +a
   fi
   # <<< ai-marketing-hub secrets <<<
   EOF
   ```
   Keep `secrets.env` at perms `600`. Never echo a key value into the chat or a
   committed file. Confirm with a masked check (`SET` / not set) only.

Note in `CLAUDE.md` which keys are wired vs missing, so future runs know whether
they're in full or degraded mode.

## 3. Scaffold the workspace

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
  market, primary URL, **report language (default Japanese)**, and the list of
  brains this project will use. Downstream report runs (`/mb:report`) should
  honor this language — write reports in **Japanese** unless the user chose
  otherwise.
- The scaffolded `CLAUDE.md` **must include the "Persistence" conventions block**
  so every future session in this directory writes work back to the vault rather
  than only to `reports/`/`web/`. Don't retype it — after writing the
  project-specific `CLAUDE.md` (name, focus, market, brains, language, API-key
  status), append the canonical managed section by running the single-source
  script (the same one `/mb:update` uses to keep it current):

  ```bash
  SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
  bash "$SCRIPTS/claude-md.sh" sync .   # adds the mb:managed Persistence block
  ```

  The block is wrapped in `<!-- mb:managed:start -->` / `<!-- mb:managed:end -->`
  markers; everything you write outside those markers is project-owned and is
  never touched by later syncs.

- Register the project and seed the current `todos/` tooling so it starts on the
  canonical version and is reachable by `/mb:update` fan-out later:

  ```bash
  SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
  bash "$SCRIPTS/sync-tooling.sh" register .
  bash "$SCRIPTS/sync-tooling.sh" push .     # installs todos/ scaffold from source
  ```

  Registration adds this project to the machine-local registry
  (`~/.claude/master-brain-projects.txt`). If you later improve the tooling here,
  `/mb:push` promotes it back up to the source repo for every project to share.

## 4. Map focus → brains and queue first actions

Translate the chosen focus into concrete brain runs, and queue each as a TODO so
the work is tracked from the start — add them via the CLI (creates `todos/todos.db`
on first use):

```bash
node "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs" \
  add "<first action>" --skill=<brain> --priority=high
```


- SEO/content → **marketing-brain**
- local SEO → **local-seo-brain**
- paid ads → **claude-ads** — when ads are in focus, always queue these in order:
  1. **`/ads-dna <url>`** — extract brand DNA (`brand-profile.json`) so creative
     stays on-brand.
  2. **`/ads-competitor`** — competitor ad-intelligence report (Meta Ad Library /
     Google Ads Transparency / TikTok Top Ads): copy, creative, spend, gaps.
  3. **`/ads-landing <url>`** — landing-page assessment **and concrete LP design
     suggestions** (message match, above-the-fold, trust signals, form/CTA, mobile)
     to lift conversion rate.
- website capture → **website-brain**
- full website audit → **website-audit** (`/mb:website-audit`, bare `/website-audit`) —
  the evidence-only teardown: ground-truth curl pass, five parallel specialist
  lanes (technical SEO, page inventory, content/E-E-A-T, visual/UI with
  screenshots, marketing/socials/reputation), annotated screenshots, validated
  charts, and an owner-ready Times New Roman PDF verified page by page. **Queue it
  first whenever there is an existing site**, whatever the other focus areas are:
  it produces the ground truth (SPA-without-SSR, duplicate canonicals, broken
  mobile hero) that the SEO, ads, and report work all depend on. Queue it as:
  ```bash
  node "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs" \
    add "/website-audit <url> — full evidence-only audit → PDF" --skill=website-audit --priority=high
  ```
- report → **client-intelligence-report** (`/mb:report`)

Use the captured classroom as the canon for *what to queue and in what order*:
`04-client-delivery/` is the end-to-end engagement flow, and `09-prompt-library/`
has the ready-to-run prompt for each brain — seed the first TODO from it so the
work starts from the blessed prompt, not a guess:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/classroom.sh" show 04-client-delivery/02-the-five-step-flow.md
bash "$SCRIPTS/classroom.sh" prompts skill <ads|seo|blog|local|marketing|video|client>
bash "$SCRIPTS/classroom.sh" prompts get <bucket> <index>   # the blessed first-run prompt
```

Word each queued TODO around that blessed prompt (keep its slash command and
`<placeholders>`) so whoever picks it up runs the canonical prompt, not a guess.

## 5. Execute everything, then deliver a PDF report (no confirmation prompt)

Do **not** stop to ask whether to proceed. After scaffolding and queuing, run the
whole pipeline end-to-end automatically:

1. **Work every open TODO to completion** — run them in priority order, marking
   each done in the SQLite store as you go (same behavior as `/mb:todos-execute`):

   ```bash
   node "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs" list --open
   ```

   Execute each with its blessed brain/prompt (`/ads-dna`, `/ads-competitor`,
   `/ads-landing` with LP design suggestions, the SEO/local/website runs, etc.),
   then mark it done. Don't pause between todos.

2. **If the project has an existing site, run the full website audit** — invoke
   **`/website-audit <primary URL>`** (the `website-audit` skill) end to end,
   including the mandatory page-by-page PDF verification. Its findings files are
   the evidence base every later chapter cites, so run it before the fused report.

3. **Generate the client intelligence report as a PDF** — run the fused
   multi-brain report via **`/client-intelligence-report`** (`/mb:report`) over the
   primary URL, writing the rendered **PDF** into `reports/`. Write it in
   **Japanese** (the project default) unless `CLAUDE.md` records another language.

Only at the very end, show what was created (tree), which brains ran, the
completed todos, and the path to the delivered PDF report.
