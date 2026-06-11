---
description: Drive the fused multi-brain client intelligence report (the Mega-Brain) for a website.
argument-hint: "<website URL> [city/country] [languages]"
---

Read the `master-brain` skill, then hand off to the **client-intelligence-report**
brain to produce the fused multi-brain report. That brain already encodes the
full six-prompt pipeline (website → marketing → local → audit → report → safe
package); your job is to gather inputs, confirm scope, and run it.

## 1. Preconditions

- Ensure `client-intelligence-report`, `website-brain`, `marketing-brain`,
  `local-seo-brain`, and `claude-obsidian` are installed. If not, tell the user
  to run `/mb:install` first.
- Ensure the required keys exist (don't print them): `FIRECRAWL_API_KEY` and
  DataForSEO credentials. If missing, point to `/mb:doctor`.

## 2. Gather scope (use `$ARGUMENTS`, then ask only what's missing)

- **Website URL** (required).
- **Target city/country** (for keyword + local work).
- **Single or multi-location?** (multi enables the local SEO chapter).
- **Languages** for the final PDF (default: the site's own language; ask if a
  second language is wanted).

## 3. Run the report

Invoke the `client-intelligence-report` skill with the gathered scope. Let that
brain own the crawl, the three brains, the audit, the layout, and the safe-zip
packaging — it is the source of truth for that workflow. Run it in the current
project folder so outputs land in `wiki/`, `reports/`, and `data/`.

## 4. After it finishes

- Confirm where the PDF(s) and vault landed.
- Write a TODO in `todos/` for owner review/delivery of the report.
- Offer next steps (e.g. "want a deck version, or to act on the action plan?").
