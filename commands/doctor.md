---
description: Health check — what's installed, what's missing, API keys, claude-mem, and the todo backlog.
---

Read the `master-brain` skill. Then run a full diagnostic and present a single
readable health report. This is the command for "I don't know what's wrong" or
"am I set up correctly".

## Checks to run

1. **Brain fleet** — `bash "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/brains.sh" status`.
   Note any brain that is MISSING or not a git checkout.
2. **claude-mem** — present in `~/.claude/plugins/installed_plugins.json`? enabled in `~/.claude/settings.json`?
3. **API keys** — check the environment and common `.env` locations (`~/Documents/.env`,
   `~/.config/website-brain/.env`, `./.env`) WITHOUT printing secret values —
   report only present/absent for:
   - `FIRECRAWL_API_KEY` (website-brain crawl → full capture + brand-tokens + screenshots)
   - `DATAFORSEO_LOGIN` / `DATAFORSEO_PASSWORD` (marketing + local + SEO data → real search volumes)
   - Google API keys (optional: PageSpeed/CrUX/Search Console/GA4)
4. **Account access** — can the user reach their Google Business Profile and ad
   platforms (Google Ads, Meta, TikTok, LinkedIn, Microsoft) for live local & paid
   audits (local-seo-brain + claude-ads)? Note the method in play — Playwright
   manual-login, manual CSV export to `data/`, or native API/OAuth — and report
   which accounts are reachable. For GBP, flag if the profile isn't verified or the
   user lacks at least Manager access.
5. **Playwright MCP** — is the `playwright` MCP server installed (`claude mcp list`,
   or are the `browser_*` tools available)? Required for the Playwright manual-login
   audit method. If missing → `claude mcp add playwright npx @playwright/mcp@latest`
   and `npx playwright install chromium`.
6. **Tooling** — `git`, `node`/`npm`, `python3`, `firecrawl` CLI (`firecrawl --status`
   if present), and `pandoc` (`pandoc --version`) — pandoc renders the bilingual /
   Japanese report to PDF; note if a CJK-capable LaTeX engine (`xelatex`/`lualatex`)
   is also missing.
7. **This project** — is the cwd an initialized Master Brain project (`wiki/`,
   `todos/`, `CLAUDE.md`)? Open-todo count (`grep -lR 'status: open' todos`).
8. **The TODO hook** — is the master-brain plugin's hook active (plugin
   installed)? If todos aren't being auto-captured, flag it.

## Output

A compact report with three sections — **✅ Ready**, **⚠ Needs attention**,
**❌ Missing** — each line stating the exact fix (e.g. "❌ FIRECRAWL_API_KEY not
set → add it to ~/.config/website-brain/.env"). Never print secret values, only
whether they're present. End with the single highest-priority action.
