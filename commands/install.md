---
description: Install the whole AI Marketing Hub fleet — every brain plus the claude-ads and claude-mem plugins — in one shot.
---

Read the `master-brain` skill. Then run the install workflow. The brains are
private, members-only AI-Marketing-Hub repos, so cloning requires Pro access and
authenticated git (SSH key or credential helper).

## 1. Preflight

Confirm `git` is available. Resolve the scripts directory:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
```

The captured **Setup & Install** course is the canonical, member-facing version
of this whole flow. Skim it so your steps and wording match what the user has
seen in the classroom, and use the troubleshooting lesson as the remediation
script when anything below fails:

```bash
bash "$SCRIPTS/classroom.sh" show 02-setup-install/09-troubleshooting-your-install-checklist.md
# bash "$SCRIPTS/classroom.sh" list   # to see every Setup & Install lesson
```

Tell the user what's about to happen: "I'll clone/update the AI Marketing Hub
brains into `~/.claude/skills` — the canonical fleet (claude-obsidian,
website-brain, marketing-brain, local-seo-brain,
client-intelligence-report) **plus any other brain discovered in the
`AI-Marketing-Hub` org** when `gh` is authenticated — and install the
claude-ads + claude-mem plugins if they're missing." To preview the full resolved list first, run
`bash "$SCRIPTS/brains.sh" list`.

## 2. Install / update the brains

```bash
bash "$SCRIPTS/brains.sh" install
```

This is idempotent: it resolves the fleet (canonical list + any `gh`-discovered
org brains such as `social-hub`), clones what's missing, and fast-forwards what's
present (SSH first, HTTPS fallback). If any clone fails, the most likely causes
are (a) no AI Marketing Hub Pro access on this GitHub account, or (b) git not
authenticated. Surface the failing repo name and the fix; don't fail silently.
If `gh` isn't installed or logged in, discovery is skipped (canonical list only)
— note it and suggest `gh auth login`.

## 3. Install the plugin brains (claude-ads + claude-mem)

Two brains ship as Claude **plugins**, not `~/.claude/skills` clones, so they're
installed separately. Check `~/.claude/plugins/installed_plugins.json` for each
entry and install whichever is missing.

**claude-ads** (`claude-ads@ai-marketing-hub-claude-ads`) — the paid-media brain.
It's a multi-skill repo that only loads as a plugin (a bare `skills/` clone has no
top-level `SKILL.md` and won't load), so it is **not** cloned by `brains.sh`:

```bash
claude plugin marketplace add AI-Marketing-Hub/claude-ads
claude plugin install claude-ads@ai-marketing-hub-claude-ads
```

It's a private, members-only repo, so this needs the same Pro access + git auth as
the cloned brains.

**claude-mem** (`claude-mem@thedotmack`) — cross-session memory (public):

```bash
claude plugin marketplace add thedotmack/claude-mem
claude plugin install claude-mem@thedotmack
```

If the `claude` CLI plugin commands aren't available in this environment, fall
back to each project's documented installer (for claude-mem,
`npx claude-mem@latest install`) and tell the user. If a plugin is already
installed, say so and skip.

## 4. Configure prerequisites (API keys + tools)

The brains run without these, but each one is **required to unlock a specific
capability**. Detect what's already present (check the environment and the common
`.env` locations — `~/.config/website-brain/.env`, `~/Documents/.env`, `./.env`)
and **never print secret values — report only present/absent**. Then, for every
item that is missing, tell the user exactly what it unlocks, where to get it, and
where to put it, and ask them to add it before moving on. Walk these five in order:

1. **Firecrawl API key** → *full site capture + brand-tokens.json + screenshots*
   (powers **website-brain**). Check `FIRECRAWL_API_KEY`. If missing: get a key at
   https://www.firecrawl.dev and add it to `~/.config/website-brain/.env` as
   `FIRECRAWL_API_KEY=...`.
2. **DataForSEO credentials** → *real search volumes attached to the keyword map*
   (powers **marketing-brain** + **local-seo-brain**). Check `DATAFORSEO_LOGIN`
   and `DATAFORSEO_PASSWORD`. If missing: sign up at https://dataforseo.com and
   add both to the same `.env`.
3. **Playwright MCP** → *the browser the live audits drive* (powers the GBP +
   ad-account method below). Check whether the Playwright MCP server is installed —
   the `browser_*` tools should be available (e.g. `claude mcp list` shows
   `playwright`). If missing, install it:
   ```bash
   claude mcp add playwright npx @playwright/mcp@latest
   npx playwright install chromium
   ```
   Do not skip this if the user wants live GBP/ad audits — without it there's no
   browser to log in through.
4. **GBP + ad-account access** → *live local & paid audits* (powers
   **local-seo-brain** + **claude-ads**). This is account access, not a single key.
   Confirm the user can reach each account they intend to audit, via one of three
   methods (easiest → most robust):
   - **Playwright manual-login** *(recommended, low setup, read-only)* — launch a
     non-headless persistent browser, the user logs in by hand (handles 2FA), the
     audit reads the dashboards. Requires the Playwright MCP from step 3. Note the
     ToS caveat: automating platform UIs is a gray area, so use it only for
     accounts the user owns or manages. For **GBP**, the client's Business Profile
     must already be verified and the user's Google account needs at least
     **Manager** access (Profile → Settings → People and access → Add).
   - **Manual export → `data/`** *(reliable, compliant)* — the user exports a CSV/
     report from each platform UI and drops it in the project's `data/` folder; the
     audit reads the file.
   - **Native API + OAuth** *(most complete, most setup)* — Google Ads API, Meta
     Marketing API, etc., for deep/automated pipelines.
5. **pandoc** → *render the bilingual (incl. Japanese) report to PDF* (powers
   **client-intelligence-report**). Check `pandoc --version`. If missing, install
   it via the system package manager (`brew install pandoc`, `apt install pandoc`,
   etc.). Japanese PDF output also needs a CJK-capable engine — a LaTeX install
   with `xelatex`/`lualatex` and a CJK font (e.g. Noto Sans CJK) — so flag that too.

Summarize as a checklist: ✅ configured / ❌ still needed, each with its one-line
fix. It's fine for the user to skip some now and add them later — note that
`/mb:doctor` re-checks all of these at any time.

## 5. Verify and report

Run `bash "$SCRIPTS/brains.sh" status` and show the result as a clean table:
each brain, installed yes/no, version, last commit. Confirm claude-ads + claude-mem plugin status,
and restate the prerequisite checklist from Step 4 (configured vs still needed).

Close with the next step: "All set — run `/mb:init` to scaffold your
first project, or `/mb:idk` if you want me to recommend what to do."
