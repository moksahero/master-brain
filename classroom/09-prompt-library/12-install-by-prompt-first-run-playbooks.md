---
course: "Prompt Library"
lesson: "📦 Install by Prompt + First-Run Playbooks"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=af828c1dd05c40aeb37ff7fe01730f13
course_slug: 2afc71bf
module_id: af828c1dd05c40aeb37ff7fe01730f13
---
# 📦 Install by Prompt + First-Run Playbooks

> Install any product by pasting one plain-English line, then run the right first move instead of guessing.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-install.gif)

*Paste one line to install, then run the first move that works.*

---

Two things non-technical members keep asking for: *"what do I paste to install this"* and *"what do I run first."* Both, in one place. Per-product detail lives in each tool's Cheat Sheet.

## Install by prompt

Paste the line for the product you want. It maps to the menu / commands on each Cheat Sheet.

---

**Claude SEO**

```text
Install the Claude SEO skill from this repo and check it's up to date: github.com/AI-Marketing-Hub/claude-seo
```

[**Claude Blog**](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=d36ed305e9dd4826852fe483df73fec8)

```text
Install the Claude Blog skill from this repo and confirm it's current: github.com/AI-Marketing-Hub/claude-blog (if a slug errors, install from the menu)
```

[**Claude Ads**](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=166ec4ea11f343648e30d0c3d471245c)

```text
Install the Claude Ads skill from this repo and check we're up to date: github.com/AI-Marketing-Hub/claude-ads
```

[**Claude Obsidian**](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=61647f28ea044ba694649a1a879b4104)

```text
Install the Claude Obsidian skill from this repo and confirm it's up to date: github.com/AI-Marketing-Hub/claude-obsidian
```

[**Walt**](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=38534fb5dcd445b694fc3966c20c5392)

```text
Clone Walt and set up my creator vault: github.com/AI-Marketing-Hub/walt
```

**Marketing Brain**

```text
Clone the Marketing Brain and install it: github.com/AI-Marketing-Hub/marketing-brain
```

**Local SEO Brain**

```text
Clone the Local SEO Brain and set up a client vault: github.com/AI-Marketing-Hub/local-seo-brain
```

**Ads Brain**

```text
Clone the Ads Brain and set it up: github.com/AI-Marketing-Hub/ads-brain
```

**SEO OS**

```text
Set up SEO OS locally and open the dashboard: github.com/AI-Marketing-Hub/seo-os
```

[**Marketing OS**](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=65ec0298ab304a1c99d0319c28677ed5)

```text
Set up Marketing OS from source and open it locally: github.com/AI-Marketing-Hub/marketing-os
```

[**Brainstein**](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=96488a5da2a74801bc83da74aafa756e)

```text
Install Brainstein and confirm it's up to date: github.com/AI-Marketing-Hub/Brainstein
```

## First-run playbooks

The order that works, the product to pair, the prereq, and the mode to run it in.

### Claude SEO

- Run the audit first. Always. `/seo audit <your site>` before you change anything.
- Fix in order: sitemap, then robots.txt, then read every page for context and flag keyword cannibalization.
- Pair it with the Marketing Brain. That is where the strategy lives.
- Prereq: a DataForSEO key turns estimates into real rankings (you bring your own).

> Heavy jobs (full audit + fixes): run in workflow mode with ultrathinking.

### Claude Blog

- Start with a cluster, not a single post. `/blog cluster plan <seed>`.
- Write the pillar first. The 5 gates auto-QA it. Nothing ships under 90.
- Pull targets from the Marketing Brain. Pre-check the page with Claude SEO.

> Cluster plan and pillar draft: run in workflow mode.

### Claude Ads

- Audit before you spend. `/ads audit`.
- Fix tracking and budget leaks first. Build campaigns second.
- Pair with the Ads Brain for the weekly signal, and Claude SEO so paid amplifies a page that already converts.
- Approval-first. It never edits your live account.

> Multi-platform audit: run in workflow mode.

### Claude Obsidian

- Set up the vault first: `/wiki`.
- Ingest in batches: "ingest all of these." Let it auto-link.
- It becomes the memory layer your other skills cite. Point any Brain at it.

> Big ingests: run in workflow mode.

### Walt

- Scaffold your creator vault first. One channel is one vault.
- Fill the Style Profile before the pipeline. The brain is only as good as your inputs.
- Log performance after each video. The brain learns what your audience rewards.

> (Deeper video strategy is parked for a later pass.)

### Marketing Brain

- One vault per client. `marketing-brain new <client> --site <url> --niche "..."`.
- Run competitor and keyword research, then synthesize the BEAST plan.
- It feeds SEO, Blog, and Ads. Build it before them.
- Try `marketing-brain demo` first. Offline, zero cost.
- Prereq: a DataForSEO key for the live pipeline (you bring your own).

> Example: *"Set up the Marketing Brain for example.com, do proper keyword research, and follow best practices."*

> Full research-to-plan: run in workflow mode with ultrathinking.

### Local SEO Brain

- Pair it with the Marketing Brain. Research becomes the local plan.
- Scaffold the client vault, then ingest GBP, citations, reviews, and geo-grid.
- Synthesize the Health Scorecard, then execute with `/seo local`.
- Run `build_demo_vault.py` first to see the shape. No deps.

> Synthesis pass: run in workflow mode.

### Ads Brain

- Import your ad export first, enrich market context, then synthesize the plan.
- Pair with Claude Ads. The audit gives the brain the leaks to fix.
- Approval-first. It never touches the live account.

> Plan synthesis: run in workflow mode.

### SEO OS

- Clone, run `install.sh`, then `pnpm dev`. Open `/setup`.
- Add a client, build the brain, watch the Task Feed, read the HEALTH score.
- The dashboard layer on top of the skills. Pair with the Brains for strategy.

> Brain builds run as background jobs. Watch the Task Feed.

### Marketing OS

- Build and start the server, open `127.0.0.1:25808`.
- Add your AI connections in AI Core first.
- Then Assistants, Jobs, Teams. Pair with the Brains for the vault graph.

> Jobs scheduler runs heavy tasks in the background.

### Brainstein

- `brainstein init-spec`, then `brainstein new` to scaffold a brain.
- `brainstein audit-brain <repo>` for the 33-item SSS+ score.
- `brainstein next <repo>` tells you the one thing to fix next.

> Audit + generate: run in workflow mode.

## API keys (bring your own)

Two keys unlock the data layer. You supply your own. Keys stay on your machine, never in a vault note or the community feed.

- **DataForSEO** turns estimates into real rankings and live keyword data. Used by [Claude SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f), Blog research, the strategy Brains ([Marketing](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=888db513f2b24f4d85320fe80ee88bbb), [Local SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=22902679826f428295b66ca4141160bd), [Ads](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=9166b414941a45cb851448ef0c5ee7ac)), and [SEO OS](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=3562bd77965742c7811d4c22c9063f01). Get a key at `dataforseo.com`. The live pipeline is walked through in [Marketing Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=ed8d47df468a4107b570f7e6e39e3196).
- [**Firecrawl**](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=0c17dddab4274ddaa33b75e2855ede57) crawls whole sites into structured pages. Used by [Website Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=1dc04a82c97547d1aa66353d805793b5) and Claude SEO's deep crawl. Get a key at `firecrawl.dev` (free tier to start). Setup steps are in [the Website Brain first win](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=0c17dddab4274ddaa33b75e2855ede57).

> **Workflow mode + ultrathinking** is the other convention: use it for heavy multi-step jobs (full audits, cluster plans, brain synthesis). Short asks don't need it.

---

- One pasteable line installs any product. No slugs to memorize.
- Every product has a best first move. Run that, not a random command.
- Add DataForSEO. Run heavy jobs in workflow mode with ultrathinking.

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010)
