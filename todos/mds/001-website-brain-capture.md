---
id: 001
title: Capture nitokyo.shop into the vault (website-brain)
brain: website-brain
status: done
priority: 2
created: 2026-06-11
completed: 2026-06-11
outcome: "Captured 8 core pages (home, catalog, wholesale, company, weekly-items + sample product, terms, privacy) into site-capture/ vault. brand-tokens.json built (gold #c9a962, Playfair Display + Inter). Critic: complete & generation-ready. Gap: /personalshopper + /influencer not in sitemap, documented from source instead."
---

# Capture nitokyo.shop → vault

Run **website-brain** (Firecrawl) on https://nitokyo.shop to build the shared substrate
for SEO + report work: one clean note per page + screenshots, brand tokens, image library,
wikilink graph.

## Scope
- Public pages: `/`, `/catalog`, `/wholesale`, `/personalshopper`, `/weekly-items`, `/influencer`,
  `/company`, plus thank-you/legal pages.
- Skip gated routes (`/secret`, `/admin`, `/authorize`).

## Why
Gives marketing-brain + the report grounded, on-site evidence (copy, CTAs, metadata) instead of
re-crawling per run.

## Done when
- Vault notes under `wiki/sources/` per page; brand-tokens.json present; review grade captured.
