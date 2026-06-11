-- Add due_date column and set due dates for the routine TODOs (their next-due dates).
ALTER TABLE todos ADD COLUMN due_date TEXT;

UPDATE todos SET due_date = '2026-06-25' WHERE id = 'rt-ads-audit-20260611';
UPDATE todos SET due_date = '2026-06-25' WHERE id = 'rt-backlog-review-20260611';
UPDATE todos SET due_date = '2026-07-11' WHERE id = 'rt-seo-refresh-20260611';
UPDATE todos SET due_date = '2026-09-11' WHERE id = 'rt-site-recrawl-20260611';
UPDATE todos SET due_date = '2026-09-11' WHERE id = 'rt-client-report-20260611';
