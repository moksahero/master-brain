---
description: Install the whole AI Marketing Hub fleet — a full sweep of the AI-Marketing-Hub org (every brain, plugin or skill) plus claude-mem — in one shot.
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

Tell the user what's about to happen: "I'll sweep the **entire `AI-Marketing-Hub`
org** and install every repo it publishes — no curated allow/deny list. Each repo
is installed by detecting its type: repos that ship a Claude plugin
(`.claude-plugin/marketplace.json`) are plugin-installed (claude-ads, claude-seo,
claude-blog, sales-brain, social-hub, …); the rest are cloned as `~/.claude/skills`
brains (marketing-brain, website-brain, walt, email-marketing, …). The only repos
skipped are structural non-installs (`master-brain` itself and the org `.github`
profile). Pick-and-choose happens at execution time, never at install." To preview
the full resolved list first, run `bash "$SCRIPTS/brains.sh" list`.

> **Why the full sweep (don't reintroduce a curated list).** Install-time
> filtering is exactly what silently dropped `claude-seo` (a plugin repo that
> nobody remembered to add to a hardcoded list). The rule is: **install
> everything the org has, decide what to *run* locally.** A repo added to the org
> tomorrow joins the fleet automatically — no edit to `brains.sh`.

## 2. Sweep the org (installs every brain — plugins AND skills)

```bash
bash "$SCRIPTS/brains.sh" install
```

This is idempotent and does the whole org in one pass: it walks every non-archived
repo, and for each one either **plugin-installs** it (marketplace add + install,
when it ships `.claude-plugin/marketplace.json`) or **clones/fast-forwards** it as
a skills brain. Existing working clones are fast-forwarded, not disturbed. If an
install fails, the most likely causes are (a) no AI Marketing Hub Pro access on
this GitHub account, or (b) git/gh not authenticated. Surface the failing repo name
and the fix; don't fail silently. `gh` must be installed **and authenticated** for
the sweep and for plugin detection — without it, only the offline canonical
skills-clone list runs and plugins can't be resolved; note it and suggest
`gh auth login`.

## 3. Confirm claude-mem (external, installed by the sweep)

The org-hosted plugin brains (claude-ads, claude-seo, claude-blog, …) are installed
by the Step 2 org sweep, and **claude-mem is installed by that same sweep too** —
`brains.sh` carries it in its `EXTERNAL_PLUGINS` list because it lives at
`thedotmack/claude-mem`, **outside** the AI-Marketing-Hub org, so an org walk can
never discover it. There is no separate per-plugin list to maintain here anymore;
this step just confirms the result.

**claude-mem** (`claude-mem@thedotmack`) — cross-session memory (public). It's
already handled by Step 2; only run this by hand if you skipped the sweep or it
reported a failure:

```bash
claude plugin marketplace add thedotmack/claude-mem
claude plugin install claude-mem@thedotmack
```

If the `claude` CLI plugin commands aren't available in this environment, fall
back to each project's documented installer (for claude-mem,
`npx claude-mem@latest install`) and tell the user. If it's already installed, say
so and skip.

## 3b. Install the humanizer skill (writing quality)

master-brain ships **humanizer** (blader/humanizer, MIT) vendored as `mb:humanizer`,
so `claude plugin update` already gives every PC the skill. This step also clones it
standalone so the short `/humanizer` command works. It's a public repo — no Pro
access needed:

```bash
if [ -d "$HOME/.claude/skills/humanizer/.git" ]; then
  git -C "$HOME/.claude/skills/humanizer" pull --ff-only
else
  git clone https://github.com/blader/humanizer.git "$HOME/.claude/skills/humanizer"
fi
```

Remind the user of the **standing rule**: any prose the brains produce — marketing
copy, reports, emails, blog drafts, client deliverables — should be passed through
humanizer before delivery so it reads human-written, not AI-generated. master-brain's
SessionStart hook reinforces this each session.

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
