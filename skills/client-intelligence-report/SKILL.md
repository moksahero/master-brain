---
name: client-intelligence-report
description: >
  Turn any client website into a fused multi-brain Obsidian knowledge base and a
  premium bilingual SEO and marketing intelligence report a non-technical owner
  will actually read and value. Use when you want to capture a site, layer
  competitor, keyword, and local SEO analysis, audit it to best practices, and
  produce an agency-grade PDF. Triggers on: "client intelligence report",
  "website brain to report", "SEO and marketing audit", "capture site into
  Obsidian", "local SEO report", "bilingual SEO report", "client SEO deck".
license: MIT
---

# Client Intelligence Report: from a URL to a report worth $20,000

This is the exact workflow behind the fused three-brain vault and the bilingual
master report. You point it at one website. You get back a navigable knowledge
graph of everything that site is, plus a premium PDF that turns the data into a
plan an owner can act on.

It is six prompts. You paste them in order into Claude Code or Codex. The agent
does the crawling, the analysis, the writing, the layout, and the safety check.
You curate and approve.

## How to use this file

Two ways:

1. **Hands-off**: give this whole file to your Claude Code or Codex agent as the
   goal (for example with `/goal`), and tell it: "set up the three brains for
   <URL> and produce the report." It installs the toolkits, wires the keys, and
   runs the six prompts for you.
2. **Manual**: install the toolkits below, add your two API keys, then paste the
   six prompts in order.

## What you walk away with

1. A **three-brain Obsidian vault**, fused into one graph:
   - **Website brain**: every page captured as a note with a full-page
     screenshot, full frontmatter, on-page SEO, and Core Web Vitals.
   - **Marketing brain**: competitors, keyword opportunities, and a growth plan.
   - **Local SEO brain**: per store Google Business Profile, map-grid rankings,
     reviews, and NAP consistency (for multi-location clients).
2. A **master report PDF in two languages**: white agency cover, executive
   scorecard, every angle as a chapter with charts and tables, a plain-language
   glossary, and one prioritized action plan.
3. A **clean, shareable zip** with no secrets in it.

## Prerequisites (one time)

### Tools

- **Claude Code** or **Codex** in your terminal or IDE. https://claude.com/claude-code
- **Obsidian** installed. https://obsidian.md
- **firecrawl-cli** for the website crawl: `npm i -g firecrawl-cli` (Node 18+).
  Verify with `firecrawl --status`.

### Install the toolkits

Four repos in the AI Marketing Hub org (Pro members have access). Clone each into
your Claude skills folder:

```bash
git clone https://github.com/AI-Marketing-Hub/website-brain    ~/.claude/skills/website-brain
git clone https://github.com/AI-Marketing-Hub/marketing-brain  ~/.claude/skills/marketing-brain
git clone https://github.com/AI-Marketing-Hub/local-seo-brain  ~/.claude/skills/local-seo-brain
git clone https://github.com/AI-Marketing-Hub/claude-obsidian  ~/.claude/skills/claude-obsidian
```

- website-brain: https://github.com/AI-Marketing-Hub/website-brain
- marketing-brain: https://github.com/AI-Marketing-Hub/marketing-brain
- local-seo-brain: https://github.com/AI-Marketing-Hub/local-seo-brain
- claude-obsidian: https://github.com/AI-Marketing-Hub/claude-obsidian
- Org home: https://github.com/AI-Marketing-Hub

Each repo README has the Claude Code plugin install and the Codex path if you
prefer those, plus any dependencies it needs. Codex users: clone the same four
repos into your Codex skills folder.

### API keys (two are required, one optional)

Save keys in a local `.env` file. Never paste a key into a prompt. The tools read
them from your environment, so the keys never touch the vault or the report.

- **Firecrawl** (required, powers the website crawl). Get a key at
  https://firecrawl.dev, then either run `firecrawl login` or put
  `FIRECRAWL_API_KEY=fc-...` in `~/.config/website-brain/.env` (or a repo-local
  `.env`, or your global `~/Documents/.env`). Bills about 1 credit per page.
- **DataForSEO** (required, powers SEO, marketing, and local). Put
  `DATAFORSEO_LOGIN=...` and `DATAFORSEO_PASSWORD=...` in `~/Documents/.env`.
  Costs a few cents per run.
- **Google PageSpeed Insights API** (required for the performance chapter). Powers
  the **mandatory Core Web Vitals section** with real-user (CrUX field) LCP, INP,
  and CLS — the metrics Google actually ranks on. Get a key in Google Cloud
  Console (enable "PageSpeed Insights API"), then put `GOOGLE_PAGESPEED_API_KEY=...`
  (or `GOOGLE_API_KEY=...`) in your secrets. One call to
  `pagespeedonline/v5/runPagespeed` returns both field (`loadingExperience` /
  `originLoadingExperience`) and lab (Lighthouse) data — you do **not** need the
  separate CrUX API. If the key's project returns `429` quota 0, the API is not
  enabled on that project; enable it (or use a key whose project has it). Free.
- **Other Google APIs** (optional: Search Console, GA4). For indexation status and
  live organic traffic in the technical/marketing chapters. The pipeline runs
  without these.

### What each API powers

| API | What it does | Used in |
| --- | --- | --- |
| Firecrawl | Maps the site, downloads every page (markdown, HTML, links, images) and a full-page screenshot | Website brain (prompt 1) |
| DataForSEO | Per-page on-page SEO; competitor and keyword discovery; GBP, map-grid rankings, reviews, NAP, citations | All three brains (prompts 1, 2, 3) |
| PageSpeed Insights (required) | Real-user (CrUX field) LCP/INP/CLS + Lighthouse lab, mobile & desktop | The mandatory performance chapter (prompt 5) |
| Other Google APIs (optional) | Indexation, organic traffic | Deeper technical and marketing detail |

## The six-prompt plan

Run these in order, in one session, in the same project folder. Each brain builds
on the one before it.

**1. Capture the website brain**  ·  *website-brain (Firecrawl + DataForSEO)*
> Capture the website at <URL> into an Obsidian website-brain. Crawl every page,
> create one note per page with full frontmatter plus a full-page screenshot and
> per-page SEO and Core Web Vitals, build the brand, entities, and structure
> notes, and wire it into a navigable graph with index, hot, log, and overview.
> Keep it in the site's own language.

Under the hood: Firecrawl maps and downloads each page, a multi-agent build writes
the notes, and DataForSEO adds the per-page SEO and Core Web Vitals.

**2. Add the marketing brain**  ·  *marketing-brain (DataForSEO)*
> Add a marketing brain to this vault. Use DataForSEO to map the competitor
> landscape and keyword opportunities for <URL> targeting <CITY or COUNTRY>,
> build the growth plan, and fuse it with the website brain: bidirectional links,
> store-page cross links, no orphans, no dangling links.

Under the hood: discovers competitors, pulls ranked keywords and the opportunity
pool, builds the plan, and grafts it into `wiki/marketing` with a link check.

**3. Add the local SEO brain**  ·  *local-seo-brain (DataForSEO)* (skip if one location)
> Add a local SEO brain for the <N> store locations. Pull Google Business Profile
> data, geo-grid map rankings, reviews, NAP consistency, and citation gaps from
> DataForSEO. Build per-store notes and fuse it as a third brain linked to the
> matching website store pages.

Under the hood: one set of notes per store (profile, map grid, reviews,
competitors), grafted into `wiki/local-seo` and cross-linked to the website store
pages.

**4. Full audit and best-practices review**  ·  *claude-obsidian (lint + verify)*
> Do a full claude-obsidian health and best-practices review of the whole vault.
> Check every brain for orphans, dead links, missing fields, relevance, and
> convention conformance. Use multi-agent orchestration with an adversarial
> verify so nothing is over-reported. Write a lint report with a scorecard, then
> ask me before applying fixes.

Under the hood: grades the vault against the claude-obsidian WIKI.md schema,
writes a scorecard to `wiki/meta`, and lists fixes for your approval.

**5. Build the master report**  ·  *the agent builds it (deterministic layout + AI prose)*
> Build one consolidated master report PDF per language. Premium agency style in
> the client's brand colors: white hero cover, **an executive scorecard, a
> how-to-read page**, every perspective as a chapter with charts, tables, and
> captioned screenshots, a plain-language glossary, and one prioritized action
> plan. Write it so a non-technical owner sees the value. Save to the vault and my
> Desktop.

The **executive scorecard is mandatory** — it is the first thing the owner reads
and the one slide they remember. It must appear in the executive summary of every
report and always include:

- **One overall letter rank** (A / B / C / D / F) with a 0–100 score, shown as a
  prominent badge.
- **A row per analysis dimension** present in the engagement (e.g. site/brand
  foundation, SEO/keywords, Google performance/Core Web Vitals, competitor/ads,
  landing-page/CRO) with that dimension's own 0–100 score, a letter grade, a
  visual bar, and its weight.
- **The overall as the weighted average** of the dimension scores, with a one-line
  note stating the weights and naming the dimension that drags the rank down most
  (so the owner sees the highest-ROI fix at a glance).
- Grade bands stated once: A 90+ / B 80+ / C 60+ / D 40+ / F <40.

Ground every dimension score in that chapter's real findings — never invent a
grade the body does not support. If a dimension's data is degraded (e.g. a missing
API), score what you have and say so in the note, don't omit the row.

Under the hood: scripts own the page layout so nothing overflows; the model writes
the words, grounded only in the real numbers.

**6. Package it safely to share**  ·  *secret scan + clean zip*
> Scan the whole folder for API keys and secrets. Then zip the brain for sharing:
> the notes, the graph config, the images, and the report PDFs, but exclude the
> raw crawl cache, the scripts, and anything secret-adjacent. Verify the zip is
> clean before you finish.

Under the hood: greps for key patterns, then builds a zip from an explicit include
list so the raw cache and tooling are never added.

That is the whole thing. Swap the placeholders, paste, approve.

## What makes the report land (the non-negotiables)

1. **Three brains, one graph.** Website is what the site is. Marketing is where to
   win. Local is the map. Fuse them with links in both directions so nothing
   floats off on its own.
2. **Deterministic layout, AI prose.** Let scripts own the pixels so nothing
   overflows or clips. Let the model own the words, grounded in the real numbers.
3. **Adversarial verify.** Every finding gets a skeptic before it ships. This is
   what stops a confident agent from inventing problems that are not real.
4. **Non-technical by default.** Plain language, a "what this means for you" box
   in every section, a glossary, and the impact stated in bookings and walk-ins.
5. **Bilingual and brand-styled.** Client colors, white cover, serif headers, and
   two languages as separate PDFs.
6. **Ground every number.** If it is not in the data, it does not go in the
   report. No guarantees, no guessing.
7. **Always lead with the scorecard.** Every report opens its executive summary
   with the graded scorecard above: one overall letter rank, a graded row per
   dimension, and the weighted overall. It is non-optional.
8. **Always include the PageSpeed Insights / Core Web Vitals chapter.** Every
   report has a Google-performance section built from the PageSpeed Insights API,
   and it **leads with real-user (CrUX field) data** — LCP, INP, CLS for mobile
   and desktop, at both the URL and origin level — because that is the signal
   Google ranks on. Lab (Lighthouse) numbers are shown only as diagnostic support,
   clearly labelled, and must never be presented as the user's real experience or
   as the headline grade. Pull it fresh (`strategy=mobile` and `strategy=desktop`)
   and save the raw JSON to `data/performance/`. If the API key is missing or its
   project has the API disabled (HTTP 429 quota 0), say so plainly in the chapter,
   fall back to lab data marked as lab-only, and add enabling the API as an action
   item — do not drop the chapter and do not pass lab values off as field values.

## Cost and time

- **Firecrawl**: about 1 credit per page. A 150-page site is on the order of 150
  credits. Check `firecrawl --status` before a large crawl.
- **DataForSEO**: a few cents per run across all three brains.
- **Time**: the crawl and the analysis are the long parts. Budget an afternoon for
  a fresh client, much less once you know the flow.

## Notes

- For a single-location client, skip prompt 3. The report drops the local chapter
  automatically.
- The report is the headline, but the vault is the asset. You can keep answering
  questions from it for months without re-running anything.
- Want more than two languages, or one combined master per language? Just ask in
  prompt 5.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Built by agricidaniel — Join the AI Marketing Hub community
Free  → https://www.skool.com/ai-marketing-hub
Pro   → https://www.skool.com/ai-marketing-hub-pro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
