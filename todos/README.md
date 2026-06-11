# NiTokyo TODOs

Next.js 16 + Tailwind v4 task board, deployed to **Cloudflare Workers** with a
**D1** database. Master Brain inserts tasks via the `wrangler` CLI; the web app
lists them and lets you change status / priority / outcome.

## Stack
- Next.js 16 (App Router, React 19) built for Cloudflare via `@opennextjs/cloudflare`
- Cloudflare D1 (SQLite) — binding `DB`
- One Worker, deployed with `wrangler`

## First-time setup

```bash
cd todos        # the app lives at the todos/ root; markdown TODOs are in todos/mds/
npm install

# 1. Create the D1 database (copy the printed database_id into wrangler.jsonc)
npx wrangler d1 create nitokyo-todos

# 2. Apply schema (remote = production D1, local = dev sqlite)
npm run db:remote      # production
npm run db:local       # local dev
npm run db:seed        # optional: seed 4 rows from the existing markdown TODOs
```

Paste the `database_id` from step 1 into `wrangler.jsonc` (`REPLACE_WITH_DATABASE_ID`).

## Develop locally
```bash
npm run dev            # http://localhost:3000  (uses local D1 via db:local)
```

## Deploy (one command)
```bash
npm run deploy         # builds with OpenNext + wrangler deploy
```

## Master Brain → insert a TODO
Every TODO must be classified as **One Time** (`one_time`) or **Routine** (`routine`).
Routine items also require a **frequency** (`Nd|Nw|Nm`, e.g. `1w`, `2w`, `1m`).
```bash
# one-time:  Title  kind  [brain] [priority] [body] [due_date] [frequency]
./add-todo.sh "Review marketing-brain output" one_time marketing-brain high "Check vault notes"

# routine (frequency required):
./add-todo.sh "Weekly search-terms review" routine claude-ads high "" "" 1w
```
Or raw SQL (set `kind`, and `frequency` for routines):
```bash
npx wrangler d1 execute nitokyo-todos --remote \
  --command "INSERT INTO todos (id,title,brain,status,priority,kind,frequency) VALUES ('$(date +%s)','My task','marketing-brain','open','normal','routine','1w');"
```

## API
- `GET  /api/todos` — list all
- `GET  /api/todos/:id` — one
- `PATCH /api/todos/:id` — update `{ status | priority | outcome | title | body | due_date | kind | frequency }`
