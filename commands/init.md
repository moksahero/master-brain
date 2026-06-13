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
  market, primary URL, **report language**, and the list of brains this project
  will use. Downstream report runs (`/mb:report`) should honor this
  language.
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
- paid ads → **claude-ads**
- website capture → **website-brain**
- report → **client-intelligence-report** (`/mb:report`)

## 5. Confirm

Show what was created (tree), which brains are active, and the queued todos.
End with: "Want me to start with [most relevant brain] now?"
