#!/usr/bin/env node
// master-brain :: TODO store CLI.
// Single deterministic entry point for the SQLite todo backend that the brains,
// the capture hook, and the Next.js dashboard (todos/) all share. Uses
// node:sqlite (built into Node 22.5+/24) — no native module, no sqlite3 CLI.
//
// DB location: $TODOS_DB, else ./todos/todos.db relative to the current project.
//
// Usage:
//   node scripts/todos.mjs list [open|done|blocked|stale|all] [--json]
//   node scripts/todos.mjs count [status]                 # bare number (hooks)
//   node scripts/todos.mjs add "<title>" [--priority=p] [--skill=s]
//                              [--source=manual|routine] [--routine=id]
//   node scripts/todos.mjs done  <id> [--outcome="..."]
//   node scripts/todos.mjs block <id> [--note="waiting on ..."]
//   node scripts/todos.mjs stale <id> [--note="..."]
//   node scripts/todos.mjs open  <id>                     # reopen
//   node scripts/todos.mjs get   <id>                     # JSON of one row
//   node scripts/todos.mjs has-open-routine <id>          # exit 0 if one exists
//   node scripts/todos.mjs log [--since=YYYY-MM-DD] [--last=N] [--json]

import { DatabaseSync } from "node:sqlite";
import path from "node:path";
import fs from "node:fs";

const DB_PATH = process.env.TODOS_DB || path.join(process.cwd(), "todos", "todos.db");

const SCHEMA = `
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
`;

function open() {
  fs.mkdirSync(path.dirname(DB_PATH), { recursive: true });
  const db = new DatabaseSync(DB_PATH);
  db.exec(SCHEMA);
  return db;
}

// Parse `--key=value` flags and positional args from argv.
function parseArgs(argv) {
  const flags = {};
  const pos = [];
  for (const a of argv) {
    const m = /^--([^=]+)=(.*)$/.exec(a);
    if (m) flags[m[1]] = m[2];
    else if (a.startsWith("--")) flags[a.slice(2)] = true;
    else pos.push(a);
  }
  return { flags, pos };
}

const now = () => new Date().toISOString();
const PRIORITY_RANK =
  "CASE priority WHEN 'high' THEN 0 WHEN 'normal' THEN 1 ELSE 2 END";

const cmd = process.argv[2];
const { flags, pos } = parseArgs(process.argv.slice(3));
const db = open();

function rowsFor(status) {
  if (!status || status === "all")
    return db
      .prepare(
        `SELECT * FROM todos ORDER BY (status='done') ASC, ${PRIORITY_RANK} ASC, created DESC`,
      )
      .all();
  return db
    .prepare(
      `SELECT * FROM todos WHERE status = ? ORDER BY ${PRIORITY_RANK} ASC, created DESC`,
    )
    .all(status);
}

function printList(rows, json) {
  if (json) {
    console.log(JSON.stringify(rows.map((r) => ({ ...r })), null, 2));
    return;
  }
  if (rows.length === 0) {
    console.log("(none)");
    return;
  }
  for (const r of rows) {
    const mark = r.status === "done" ? "✓" : r.status === "open" ? "○" : "⊘";
    console.log(
      `${mark} #${r.id} [${r.priority}] ${r.title}  · ${r.skill} · ${r.source || "?"} · ${(r.created || "").slice(0, 16)}`,
    );
  }
}

switch (cmd) {
  case "list": {
    printList(rowsFor(pos[0] || "open"), flags.json);
    break;
  }
  case "count": {
    const status = pos[0] || "open";
    const row =
      status === "all"
        ? db.prepare(`SELECT count(*) c FROM todos`).get()
        : db.prepare(`SELECT count(*) c FROM todos WHERE status = ?`).get(status);
    console.log(row.c);
    break;
  }
  case "add": {
    const title = pos[0];
    if (!title) {
      console.error("add: a title is required");
      process.exit(2);
    }
    const ts = now();
    const info = db
      .prepare(
        `INSERT OR IGNORE INTO todos
           (skill, title, status, priority, source, routine, created, minute)
         VALUES (?, ?, 'open', ?, ?, ?, ?, ?)`,
      )
      .run(
        flags.skill || "manual",
        title,
        flags.priority || "normal",
        flags.source || "manual",
        flags.routine || null,
        ts,
        ts.slice(0, 16),
      );
    console.log(info.changes ? `added #${info.lastInsertRowid}` : "skipped (duplicate)");
    break;
  }
  case "done":
  case "block":
  case "stale":
  case "open": {
    const id = Number(pos[0]);
    if (!Number.isInteger(id)) {
      console.error(`${cmd}: a numeric id is required`);
      process.exit(2);
    }
    const status = cmd === "open" ? "open" : cmd === "done" ? "done" : cmd === "block" ? "blocked" : "stale";
    const note = flags.outcome || flags.note || null;
    const info = db
      .prepare(`UPDATE todos SET status = ?, outcome = COALESCE(?, outcome), updated = ? WHERE id = ?`)
      .run(status, note, now(), id);
    console.log(info.changes ? `#${id} → ${status}` : `no todo #${id}`);
    break;
  }
  case "get": {
    const r = db.prepare(`SELECT * FROM todos WHERE id = ?`).get(Number(pos[0]));
    console.log(r ? JSON.stringify({ ...r }, null, 2) : "null");
    break;
  }
  case "has-open-routine": {
    const r = db
      .prepare(`SELECT 1 FROM todos WHERE routine = ? AND status = 'open' LIMIT 1`)
      .get(pos[0]);
    process.exit(r ? 0 : 1);
    break;
  }
  case "log": {
    let rows = db
      .prepare(
        `SELECT * FROM todos WHERE status = 'done'
         ORDER BY COALESCE(updated, created) DESC`,
      )
      .all();
    if (flags.since) rows = rows.filter((r) => (r.updated || r.created) >= flags.since);
    if (flags.last) rows = rows.slice(0, Number(flags.last));
    if (flags.json) {
      console.log(JSON.stringify(rows.map((r) => ({ ...r })), null, 2));
    } else if (rows.length === 0) {
      console.log("(no completed todos yet)");
    } else {
      for (const r of rows) {
        console.log(
          `✅ ${(r.updated || r.created || "").slice(0, 10)} — ${r.title} · ${r.skill} · ${r.source || "?"}` +
            (r.outcome ? `\n   → ${r.outcome}` : ""),
        );
      }
    }
    break;
  }
  default:
    console.error(
      "usage: todos.mjs <list|count|add|done|block|stale|open|get|has-open-routine|log> ...",
    );
    process.exit(2);
}
