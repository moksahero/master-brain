-- New routine TODOs added 2026-06-11 (tied to audit findings). Idempotent insert.
-- due_date = created + cadence.
INSERT OR IGNORE INTO todos (id, title, brain, status, priority, body, source, due_date, created_at) VALUES
('rt-ads-search-terms-20260611',
 'claude-ads: review nitokyo.shop search terms — add negatives, harvest converting close-variants as keywords',
 'claude-ads', 'open', 'high',
 'Recurring (every 1w). The audit found converting close-variant terms (luxe wholesale japan, wholesale luxury bags, wholesale coach bags) NOT added as keywords, and no negative lists. Weekly: harvest converters to exact, add negatives, check for waste.',
 'routine:ads-search-terms', '2026-06-18', '2026-06-11'),

('rt-conversion-tracking-check-20260611',
 'claude-ads: verify nitokyo.shop conversion goals healthy (Contact goal, Enhanced Conversions, no broken actions)',
 'claude-ads', 'open', 'high',
 'Recurring (every 1m). The Contact goal was Misconfigured (Error) and 2 of 4 actions had no recent conversions. Monthly: confirm goals Healthy, Enhanced Conversions + Consent Mode v2 active, all primary actions recording.',
 'routine:conversion-tracking-check', '2026-07-11', '2026-06-11'),

('rt-rank-tracking-20260611',
 'marketing-brain: track nitokyo.shop rankings for target keywords vs the greenfield baseline',
 'marketing-brain', 'open', 'normal',
 'Recurring (every 2w). Site was greenfield (ranks for ~0) on 2026-06-11. Track the P1 wholesale cluster + low-KD Japan-brand terms (chanel backpack, fendi baguette vintage, louis vuitton monogram bag) as the on-page fixes land.',
 'routine:rank-tracking', '2026-06-25', '2026-06-11'),

('rt-content-publish-20260611',
 'marketing-brain: ship one BEAST-plan content piece for nitokyo.shop (brand-sourcing page or authority article)',
 'marketing-brain', 'open', 'normal',
 'Recurring (every 1m). Work the BEAST plan content queue: brand-sourcing landing pages (Buy [Brand] from Japan) and authority articles (authentication, condition grades, EU duty-free importing). One shipped per month minimum.',
 'routine:content-publish', '2026-07-11', '2026-06-11');
