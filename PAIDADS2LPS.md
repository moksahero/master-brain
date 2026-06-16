# Paid Ads → LPs Flow

The **flow** is the orchestration engine. The **`/todos` store** is a separate, durable, client-shareable execution ledger: each flow step _writes/updates_ TODOs, and `mb:todos-execute` works that queue. The bi-weekly review re-feeds the build steps — closing the loop.

```mermaid
flowchart TD
    subgraph FLOW["Paid Ads → LPs Flow"]
        direction TB
        S1["1 · Pull context<br/>client priorities · commercial keywords · brand<br/><i>reads /wiki artifacts</i>"]
        S2["2 · Competitor intel + baseline<br/><code>/ads competitor</code>"]
        S3["3 · Brand DNA → brand-profile.json<br/><code>/ads dna</code>"]
        S4["4 · Build LPs FIRST (the destination)<br/>LP briefs + build + tracking pixels on page<br/><code>/ads landing</code>"]
        S5["5 · Campaigns to drive traffic → the LPs<br/>Google + others · copy matches LP → campaign-brief.md<br/><code>/ads plan</code> → <code>/ads create</code>"]
        S6["6 · Budget assessment<br/>spend split · bidding · scaling readiness<br/><code>/ads budget</code>"]
        S7["7 · Tracking verify: sGTM/CAPI + attribution<br/>verify fires BEFORE launch<br/><code>/ads server-side-tracking</code> · <code>/ads attribution</code>"]
        S8["8 · Launch 🚀"]
        S9["9 · Bi-weekly review<br/>health check · significance gate · re-budget<br/><code>/ads audit</code> · <code>/ads test</code> · <code>/ads math</code> · <code>/ads budget</code>"]

        S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7
        S7 -->|tracking verified| S8 --> S9
    end

    subgraph STORE["TODO webapp"]
        direction TB
        T_ONE["One-off TODOs<br/>baseline · build LPs · QA message match<br/>build campaigns · set budgets<br/>verify pixel/CAPI (launch-blocker)"]
        T_ROUTINE["Routine TODOs<br/>paid health-check + re-budget · q2w"]
    end

    EXEC["mb:todos-execute<br/><i>works the queue</i>"]

    %% flow steps emit TODOs into the store
    S2 -."emit: capture baseline metrics<br/>+ log competitor gaps to close".-> T_ONE
    S4 -."emit: build LP per offer<br/>+ place tracking pixels + QA message match".-> T_ONE
    S5 -."emit: build each campaign<br/>+ write ad copy that matches the LP".-> T_ONE
    S6 -."emit: set opening budgets<br/>+ pick bid strategy per campaign".-> T_ONE
    S7 -."emit: verify pixel/CAPI fires per LP<br/>(launch-blocker — must pass before step 8)".-> T_ONE
    S9 -."register: recurring health-check<br/>+ re-budget · every 2 weeks".-> T_ROUTINE

    %% store is executed
    T_ONE --> EXEC
    T_ROUTINE --> EXEC

    %% the loop: review re-feeds the build + budget steps
    S9 -->|new TODOs:<br/>rewrite LP · pause campaign · shift budget| S5

    classDef flow fill:#1e3a5f,stroke:#4a90d9,color:#fff;
    classDef store fill:#3d2f4a,stroke:#b07fd0,color:#fff;
    classDef exec fill:#2f4a3d,stroke:#5fb07f,color:#fff;
    class S1,S2,S3,S4,S5,S6,S7,S8,S9 flow;
    class T_ONE,T_ROUTINE store;
    class EXEC exec;
```

## Why LPs first

The LP is the destination — build it before the traffic sources so the campaigns are pointed at something real, and so **ad copy is written to match the LP** (not the reverse). Tracking pixels go on the page at build time (step 4); they're _verified_ before launch (step 7). Once campaigns exist, `/ads budget` (step 6) sizes the spend split, bidding, and scaling readiness.

## TODOs: how they are generated and handled

The flow never executes work directly — it **emits TODOs** into the store, and a separate pass executes them. Two kinds:

### One-off TODOs

- **What they are:** the build-out work that happens once to stand the campaigns up — capture baseline, build each LP, QA message match, build each campaign, set opening budgets, verify pixel/CAPI.
- **How they're generated:** emitted by the build steps as the flow runs (steps 2, 4, 5, 6, 7). Each step writes its own tasks — e.g. step 4 emits one "build LP" + one "QA message match" per offer, so the list scales with the number of LPs/campaigns, not the number of steps.
- **How they're handled:** worked off the queue by `mb:todos-execute` and marked done as each completes. One is a **launch-blocker** — "verify pixel/CAPI fires per LP" (step 7) must pass before step 8 (Launch). Once the build-out is done, these clear out; they don't recur.

### Routine TODOs

- **What they are:** the standing, recurring obligation — the bi-weekly health-check + re-budget. These don't get "finished"; they fire on a cadence for as long as the campaigns run.
- **How they're generated:** registered once by step 9 via `mb:todos-routine` (the cadence engine), then regenerated automatically every 2 weeks.
- **How they're handled:** each cycle, `mb:todos-execute` runs the review (`/ads audit` · `/ads test` · `/ads math` · `/ads budget`). The review's findings are written back as **new one-off TODOs** (rewrite that LP, pause a campaign, shift budget) — which is how the routine feeds [the loop](#the-loop). Routine TODOs are the most client-shareable: a recurring, predictable report cadence the client can watch in the webapp.

## Artifacts

Working files live under `/wiki/paid/` so they sit with the rest of the client's brain and the TODO store can reference stable paths:

- `brand-profile.json` (step 3)
- LP briefs (step 4)
- `campaign-brief.md` (step 5)

## The loop

Step 9's review is the engine of iteration: it writes _new_ TODOs (rewrite that LP, pause a campaign, shift budget) back into the store and re-enters the campaign + budget steps (5–6). The flow runs; the TODO store remembers.
