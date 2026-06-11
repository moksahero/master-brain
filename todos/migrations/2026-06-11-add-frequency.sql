-- Add per-item cadence for routine TODOs.
-- frequency uses the same shorthand as routines.yml: Nd | Nw | Nm (e.g. 1w, 2w, 1m).
-- NULL for one_time items. Required (non-NULL) for kind='routine'.
ALTER TABLE todos ADD COLUMN frequency TEXT;

-- Backfill existing routine rows from their routines.yml cadence.
UPDATE todos SET frequency = '1w' WHERE source = 'routine:ads-search-terms';
UPDATE todos SET frequency = '1m' WHERE source = 'routine:conversion-tracking-check';
UPDATE todos SET frequency = '2w' WHERE source = 'routine:rank-tracking';
UPDATE todos SET frequency = '1m' WHERE source = 'routine:content-publish';
UPDATE todos SET frequency = '2w' WHERE source = 'routine:ads-audit';
UPDATE todos SET frequency = '1m' WHERE source = 'routine:seo-refresh';
UPDATE todos SET frequency = '3m' WHERE source = 'routine:site-recrawl';
UPDATE todos SET frequency = '3m' WHERE source = 'routine:client-report';
UPDATE todos SET frequency = '2w' WHERE source = 'routine:backlog-review';
