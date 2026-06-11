-- Seed rows mirroring the markdown TODOs already in todos/, so the app is non-empty on first run.
INSERT OR IGNORE INTO todos (id, title, brain, status, priority, body, source, created_at) VALUES
('001', 'Capture nitokyo.shop into the vault (website-brain)', 'website-brain', 'done', 'high',
 'Run website-brain (Firecrawl) on https://nitokyo.shop to build the shared substrate for SEO + report work.', 'seed', '2026-06-11'),
('002', 'SEO keyword research', 'marketing-brain', 'open', 'high',
 'Intensive keyword + competitor research to lift conversions.', 'seed', '2026-06-11'),
('003', 'Google Ads audit', 'claude-ads', 'open', 'normal',
 'Audit the live Google Ads account AW-17800269183.', 'seed', '2026-06-11'),
('004', 'Fused client intelligence report', 'client-intelligence-report', 'open', 'normal',
 'Produce the fused English deliverable.', 'seed', '2026-06-11');
