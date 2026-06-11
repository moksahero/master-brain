-- Sync the 4 seed TODOs to their real final state after the 2026-06-11 session.
-- All four missions completed. Run against remote D1.

UPDATE todos SET
  title = 'Capture nitokyo.shop into the vault (website-brain)',
  brain = 'website-brain', status = 'done', priority = 'normal',
  body = 'Firecrawl capture of nitokyo.shop into the site-capture/ vault: per-page notes, screenshots, brand-tokens.json, image library.',
  outcome = '8 pages captured; brand-tokens.json built (gold #c9a962, Playfair Display + Inter); critic graded it complete and generation-ready. Gap: /personalshopper + /influencer not in sitemap, documented from source.',
  source = 'master-brain', updated_at = datetime('now'), completed_at = datetime('now')
WHERE id = '001';

UPDATE todos SET
  title = 'Intensive SEO keyword + competitor research (marketing-brain)',
  brain = 'marketing-brain', status = 'done', priority = 'high',
  body = 'DataForSEO competitor + keyword research, dedup workbook, PAA mining, and the ULTIMATE BEAST Plan for nitokyo.shop. Market: global English.',
  outcome = 'Pipeline complete (~$2.60). 26 niche competitors, 13,093 keywords, BEAST plan 4,991 words. Site is greenfield (ranks for ~0). P0 blocker: /wholesale, /catalog, /weekly-items duplicate the homepage title. Low-KD goldmine: chanel backpack (9,900,KD0), louis vuitton monogram bag (9,900,KD0), fendi baguette vintage, dior vintage saddle bag, luxury brands japan.',
  source = 'master-brain', updated_at = datetime('now'), completed_at = datetime('now')
WHERE id = '002';

UPDATE todos SET
  title = 'Google Ads audit (/ads-google + Playwright)',
  brain = 'claude-ads', status = 'done', priority = 'high',
  body = 'Audit the live Google Ads account 347-392-5494 via Playwright across the 95-check framework (conversion tracking, wasted spend, structure, keywords, ads, settings).',
  outcome = 'Health 71/100 (C+). 143 conv / 189,485 JPY / 30d. Top fixes: fund the budget-starved Wholesale Search campaign (loses 36% IS to budget), fix the misconfigured Contact conversion goal (Error), add ad assets (strength Average), audit PMax (75% IS lost to rank). Report: wiki/deliverables/google-ads-audit.md.',
  source = 'master-brain', updated_at = datetime('now'), completed_at = datetime('now')
WHERE id = '003';

UPDATE todos SET
  title = 'Fused client intelligence report',
  brain = 'client-intelligence-report', status = 'done', priority = 'normal',
  body = 'Fuse site capture + SEO/BEAST plan + Google Ads audit into one agency-grade English report.',
  outcome = 'Written to reports/NiTokyo-Intelligence-Report-2026-06-11.md (+ on-brand PDF). Thesis: a healthy paid account on a greenfield organic presence; the 3-line duplicate-title fix is the compounding unlock (ranks organically AND lowers paid CPC). Unified paid+organic 30/60/90 roadmap.',
  source = 'master-brain', updated_at = datetime('now'), completed_at = datetime('now')
WHERE id = '004';
