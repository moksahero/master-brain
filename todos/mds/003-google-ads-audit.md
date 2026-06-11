---
id: 003
title: Google Ads audit via /ads-google + Playwright (claude-ads)
brain: claude-ads
status: done
priority: 1
created: 2026-06-11
completed: 2026-06-11
outcome: "Audited live account 347-392-5494 via Playwright. Health 71/100 (C+). Report: wiki/deliverables/google-ads-audit.md. Top fixes: fund budget-starved Wholesale Search (loses 36% IS to budget), fix misconfigured Contact goal, add ad assets (strength Average), enable Enhanced Conversions. 143 conv / ¥189,485 / 30d."
---

# Assess current paid Google Ads status

Run **claude-ads `/ads-google`** with the **Playwright MCP** to log into the live Google Ads
account and assess current paid status. This is mission #2.

## Account
- Google Ads ID: **AW-17800269183** (from `src/app/layout.tsx`).
- Conversion action: `AW-17800269183/rVXoCJ3pxqwcEP-a6qdC` (contact form lead, budget-tiered value).
- GA4 `G-21SMTBCDHG`; GCLID capture + Customer Match already wired in `ContactForm.tsx`.

## Audit scope (95-check framework)
- Conversion tracking health (is the lead conversion firing + valued correctly?).
- Wasted spend / search terms / negative keywords.
- Account structure, keywords, match types, Quality Score.
- Ad assets, PMax/AI Max usage, Smart Bidding signals, settings.

## Prereqs (flag to user before running)
- Need an authenticated Playwright session into Google Ads (login). Confirm access.

## Done when
- `wiki/deliverables/google-ads-audit.md` with health score (0-100) + prioritized fixes.
- Raw exports/screenshots into `data/ads/`.
