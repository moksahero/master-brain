# Master Brain sync architecture

Three-node setup and the propagation paths between them.

- **① Local installation** under `~/.claude` — what actually runs.
- **② Source repo** at `/home/ta/ai-marketing-hub/master-brain` — source of truth, pushed to GitHub.
- **③ Individual projects** like `/home/ta/bazinga/new-bazinga` — where work happens; changes must flow back to ②.

```mermaid
flowchart TB
    subgraph GH["☁️ GitHub — durable backup"]
        REPO_REMOTE["github.com/moksahero/master-brain<br/>origin/main"]
    end

    subgraph SRC["② Source repo — source of truth"]
        SRCREPO["/home/ta/ai-marketing-hub/master-brain<br/>commands/ · scripts/ · skills/ · .claude-plugin/"]
    end

    subgraph LOCAL["① Local installation under ~/.claude"]
        MKT["~/.claude/local-marketplaces/master-brain<br/>(marketplace copy)"]
        CACHE["~/.claude/plugins/cache/.../mb/&lt;ver&gt;<br/>(installed cache — what actually RUNS)"]
        SKILLS["~/.claude/skills/*<br/>(brain fleet: git checkouts)"]
    end

    subgraph PROJ["③ Individual projects"]
        P1["/home/ta/bazinga/new-bazinga<br/>CLAUDE.md (managed section) · wiki/ · data/"]
        P2["…other projects"]
    end

    %% Forward propagation (deploy): ship.sh
    SRCREPO -- "scripts/ship.sh: rsync" --> MKT
    MKT -- "claude plugin update (version-gated)" --> CACHE
    SRCREPO -- "git commit + push" --> REPO_REMOTE

    %% DOWN: per-project persistence rule + tooling sync (/mb:update, /mb:init)
    CACHE -- "/mb:update → claude-md.sh sync" --> P1
    CACHE -- "/mb:update → sync-tooling.sh push (todos/)" --> P1
    CACHE -- "/mb:update → sync-tooling.sh push --all" --> P2

    %% Brain fleet
    CACHE -- "/mb:update brains.sh clone/update" --> SKILLS

    %% UP: the loop is now CLOSED — /mb:push promotes a project's tooling edits
    P1 == "/mb:push → sync-tooling.sh pull → ship.sh" ==> SRCREPO

    classDef closed stroke:#2ecc71,stroke-width:3px;
    class P1 closed;
```

## The loop (now closed)

You edit reusable `todos/` tooling in a project (③). `/mb:push` promotes ONLY the
shared tooling up into the source repo (②) and ships it (version bump + GitHub
push + propagate to the local cache). Every other project then receives it on its
next `/mb:update` (or all at once via `sync-tooling.sh push --all`).

What flows in each direction:

| Asset | Direction | Mechanism |
| --- | --- | --- |
| `todos/` dashboard + scripts + migrations + schema | ③ → ② → all ③ | `/mb:push` up, `/mb:update` down |
| Persistence rule (managed `CLAUDE.md` block) | ② → all ③ | `claude-md.sh` (canonical text lives in the script) |
| Brain fleet | ② → `~/.claude/skills` | `brains.sh` |

What deliberately **stays put** (never crosses ③ → ②):

- Project DATA — `wiki/`, `data/`, `reports/`, the SQLite todo db.
- Project-OWNED tooling — `routines.yml` (cadence), `wrangler.jsonc` (worker name),
  `mds/` seed todos. These are seeded once on init, then never overwritten.
- `web/` — that's the project's own site, not master-brain tooling.

Registry of projects to fan out to: `~/.claude/master-brain-projects.txt`
(machine-local; `/mb:init` registers each new project).
```
