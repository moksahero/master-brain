#!/usr/bin/env bash
# master-brain :: PostToolUse hook body.
# When an AI Marketing Hub brain skill runs, insert a TODO row into the project's
# SQLite store (todos/todos.db) so the follow-up is never dropped. Reads the hook
# JSON payload on stdin. Always exits 0 so it can never break a session.
#
# Storage is SQLite via node:sqlite (built into Node 22.5+/24) — no native module
# and no sqlite3 CLI required. The same DB powers the Next.js dashboard in todos/.
#
# A brain run is detected by the Skill tool's `skill` input matching a known
# Hub brain (optionally namespaced, e.g. "website-brain:website-brain-build").

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# Extract the skill name from the tool_input (robust JSON via python3, with a
# grep fallback if python3 is unavailable).
skill=""
if command -v python3 >/dev/null 2>&1; then
  skill="$(printf '%s' "$payload" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get("tool_input", {}) or {}
    print(ti.get("skill") or ti.get("name") or "")
except Exception:
    print("")
' 2>/dev/null)"
fi
if [ -z "$skill" ]; then
  skill="$(printf '%s' "$payload" | grep -oE '"skill"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*"skill"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
fi
[ -z "$skill" ] && exit 0

# Is this one of our brains? Match the namespace root before any ':'.
base="${skill%%:*}"
case "$base" in
  website-brain|marketing-brain|local-seo-brain|claude-obsidian|claude-ads|client-intelligence-report) ;;
  *) exit 0 ;;
esac

# node is required to write the SQLite store; if it's missing we silently skip
# rather than break the session. /mb:doctor surfaces this.
command -v node >/dev/null 2>&1 || exit 0

ts="$(date '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || echo unknown)"
minute="${ts:0:16}"
db="todos/todos.db"
mkdir -p todos 2>/dev/null || exit 0

# Insert one auto-capture TODO. The partial UNIQUE(skill, minute) index dedupes
# repeated runs of the same brain within a minute (INSERT OR IGNORE). Any error
# (e.g. Node < 22.5 without node:sqlite) is swallowed so the hook never fails.
TODO_DB="$db" TODO_SKILL="$skill" TODO_TS="$ts" TODO_MIN="$minute" \
  node 2>/dev/null <<'NODE' || true
const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync(process.env.TODO_DB);
db.exec(`
  CREATE TABLE IF NOT EXISTS todos (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    skill     TEXT NOT NULL,
    title     TEXT NOT NULL,
    status    TEXT NOT NULL DEFAULT 'open',
    priority  TEXT NOT NULL DEFAULT 'normal',
    source    TEXT,
    project   TEXT,
    outcome   TEXT,
    routine   TEXT,
    created   TEXT NOT NULL,
    updated   TEXT,
    minute    TEXT NOT NULL
  );
  CREATE UNIQUE INDEX IF NOT EXISTS idx_dedupe
    ON todos (skill, minute) WHERE source = 'auto-capture';
`);
const skill = process.env.TODO_SKILL;
db.prepare(
  `INSERT OR IGNORE INTO todos
     (skill, title, status, priority, source, project, created, minute)
   VALUES (?, ?, 'open', 'normal', 'auto-capture', NULL, ?, ?)`
).run(skill, 'Follow up: ' + skill + ' run', process.env.TODO_TS, process.env.TODO_MIN);
NODE

exit 0
