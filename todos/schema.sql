-- NiTokyo TODOs — D1 schema
-- Master Brain inserts rows here; the web app reads & updates them.

CREATE TABLE IF NOT EXISTS todos (
  id          TEXT PRIMARY KEY,
  title       TEXT NOT NULL,
  brain       TEXT,                       -- which brain/skill produced it (e.g. marketing-brain)
  status      TEXT NOT NULL DEFAULT 'open',   -- open | in_progress | done
  priority    TEXT NOT NULL DEFAULT 'normal', -- low | normal | high  (numbers also accepted)
  body        TEXT,                       -- markdown body / details
  outcome     TEXT,                       -- what happened when closed out
  source      TEXT,                       -- e.g. "master-brain auto-capture"
  kind        TEXT NOT NULL DEFAULT 'one_time', -- routine (recurring) | one_time (ad-hoc)
  frequency   TEXT,                       -- cadence for routine items: Nd | Nw | Nm (e.g. 1w, 2w, 1m); NULL for one_time
  due_date    TEXT DEFAULT (date('now','+7 days')),  -- auto-defaults +7d; add-todo.sh varies by priority
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT NOT NULL DEFAULT (datetime('now')),
  completed_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_todos_status  ON todos(status);
CREATE INDEX IF NOT EXISTS idx_todos_created ON todos(created_at DESC);
