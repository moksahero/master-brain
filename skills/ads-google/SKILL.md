---
name: ads-google
version: 1.0.0
description: >
  Google Ads operator for small-budget local/SMB portfolios. Pulls live account
  data over the Google Ads REST API (GAQL) with a zero-dependency helper, gates
  every action by account phase (launch-check / watch / optimize / audit) so the
  learning phase is never reset, calibrates thresholds to the account's real
  budget instead of US-average benchmarks, and closes a training loop by reading
  and writing a cross-client playbook + experiment ledger in your workspace.
  Use for any Google Ads review, weekly optimization pass, search-terms check,
  launch verification, or full audit. Triggers on: "review the ads account",
  "optimize the campaign", "check search terms", "google ads audit",
  "launch check", "why no conversions".
license: MIT
metadata:
  author: AgriciDaniel
  category: marketing
---

# Google Ads Operator — portfolio edition

The claude-ads plugin's `google-audit.md` is a 95-check *audit* framework: great
for a one-shot snapshot, wrong as a weekly operating loop for small accounts.
This skill is the **operator layer** on top of it, sharpened by running real
small-budget portfolios:

1. **Phase-gated modes** — the account's age and learning-phase state decide
   what you may touch, not the wording of the user's request.
2. **Budget-relative calibration** — a ¥1,000/day (~$7) account can never pass
   thresholds written for US lead-gen; verdicts must scale to real spend.
3. **A training loop** — every run reads distilled rules before acting and
   writes outcomes back afterward, so the skill gets smarter per client *and*
   across clients. **Never skip step 0 or step 6.**

## Workspace resolution

All learned state lives in the user's **ads workspace**, not in this plugin:

- Walk up from the cwd looking for `shared/findings/google-ads-playbook.md`.
  The directory containing `shared/` is the WORKSPACE.
- If none exists, offer to bootstrap one at the current git root (or a
  directory the user names): copy everything under this skill's `templates/`
  into `WORKSPACE/shared/findings/` and `scripts/gads.py` into
  `WORKSPACE/shared/tools/`, then have the user fill the client registry.
- Never write client data, CIDs, or outcomes into the plugin directory —
  the plugin is shared code; the workspace is private memory.

## Auth & the API helper

Auth is env-based (put these in the `env` block of `~/.claude/settings.json`
so they're available system-wide):

```
GOOGLE_ADS_DEVELOPER_TOKEN     # from the MCC's API Center
GOOGLE_ADS_OAUTH_CLIENT_ID     # OAuth desktop client
GOOGLE_ADS_OAUTH_CLIENT_SECRET
GOOGLE_ADS_REFRESH_TOKEN
GOOGLE_ADS_LOGIN_CUSTOMER_ID   # MCC id (omit only for direct single-account access)
```

The helper is stdlib-only Python (no google-ads SDK needed):

```python
import sys; sys.path.insert(0, "<WORKSPACE>/shared/tools")
import gads
rows = gads.search(QUERY, cid="1234567890")   # cid REQUIRED per call — never default-guess
gads.mutate("adGroupCriteria", [{"create": {...}}], cid="1234567890")
gads.units("見出しテキスト")  # RSA length in Google's units (CJK = 2) — validate BEFORE writing ads
```

## Client registry

`WORKSPACE/shared/findings/google-ads-clients.md` — one row per client:
name/aliases, CID, vertical, daily budget, target CPC, project dir, LP URLs,
notes (see template). Rules:

- **Client resolution**: explicit argument wins; otherwise match the cwd
  against the registry's project-dir column and confirm the resolved
  client + CID in one line before pulling data. Ambiguous or unregistered →
  ask. **Never guess a CID.**
- New client → add a registry row AND a ledger section (step 6) in the same run.
- Accounts that belong to a different business/credential set get their own
  workspace — never mix ledgers across trust boundaries.

## Process

### 0. Load the learned layer (always, before touching data)

1. Read `shared/findings/google-ads-playbook.md` — distilled cross-client
   rules with confidence tiers. Apply CONFIRMED rules as hard checks; treat
   OBSERVED/HYPOTHESIS as things to test; never re-suggest REFUTED.
2. Read this client's section of `shared/findings/google-ads-ledger.md`.
   Any entry with **Check-on ≤ today** and outcome `(pending)` MUST be
   measured this run and filled in with real numbers.
3. Skim the client project's `wiki/log.md` (or equivalent) for context.

### 1. Pull live data (GAQL query pack)

Adjust date ranges per mode; `segments.date DURING LAST_30_DAYS` etc.

- **Campaigns**: `SELECT campaign.id, campaign.name, campaign.status, campaign.bidding_strategy_type, campaign_budget.amount_micros, metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions, metrics.search_impression_share, metrics.search_budget_lost_impression_share, metrics.search_rank_lost_impression_share FROM campaign WHERE campaign.status != 'REMOVED'`
- **Search terms**: `SELECT search_term_view.search_term, segments.keyword.info.text, metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions FROM search_term_view WHERE segments.date DURING LAST_30_DAYS ORDER BY metrics.cost_micros DESC`
- **Keywords**: `SELECT ad_group.name, ad_group_criterion.keyword.text, ad_group_criterion.keyword.match_type, ad_group_criterion.status, ad_group_criterion.quality_info.quality_score, metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions FROM keyword_view WHERE campaign.status = 'ENABLED'`
- **Conversion actions**: `SELECT conversion_action.name, conversion_action.status, conversion_action.primary_for_goal, metrics.all_conversions FROM conversion_action`
- **Recent changes** (dates the learning phase): `SELECT change_event.change_date_time, change_event.change_resource_type, change_event.resource_change_operation FROM change_event WHERE change_event.change_date_time DURING LAST_14_DAYS LIMIT 50` — `change_event` REQUIRES a date filter ≤30d AND a LIMIT.

GAQL gotchas: dedupe keywords by ad_group + text + match_type; structure
checks on ENABLED entities only; not every metric combines with every
resource — when a query 400s, split it.

### 2. Pick the mode by account phase (not by request wording)

Compute days-since-launch / days-since-last-structural-change from the ledger
plus `change_event`.

| Mode | When | What you may do |
|---|---|---|
| **launch-check** | day 0–2 after enable | Verify only: ads/keywords approved, conversion actions firing (tag on LP, status ENABLED), budget pacing sane, geo = Presence, no disapprovals. NO changes. |
| **watch** | day 3–7, or <30 clicks total | Read-only. Scan search terms; QUEUE obviously-irrelevant terms as proposed negatives in the ledger — do NOT apply yet (learning phase, playbook L-rules). Verify conversions have started; 0 CV after ≥20 clicks → debug the CV chain first (playbook C-rules) — tracking fixes never reset learning and are always allowed. |
| **optimize** | weekly, day 8+ | Apply queued negatives (Exact/Phrase, never Broad). Bid moves on rank-lost-IS keywords. Prune 0-impression keywords after 14d. RSA asset review. ONE change-set per week, logged. |
| **audit** | ≥30 days data, or on demand | Full 95-check framework from the claude-ads plugin (`find ~/.claude/plugins -name google-audit.md` — plus `benchmarks.md`, `scoring-system.md` alongside it). Score with the calibration below overriding the plugin's US thresholds. |

If the user asks to "optimize" but the account is in learning phase: say so,
run **watch**, and queue the changes with an unlock date. That restraint is
doctrine — mid-learning changes reset the learning phase and destroy the week.

### 3. Small-budget calibration (overrides plugin thresholds)

Written for accounts at roughly ¥700–5,000/day (~$5–35); the principle is
**scale every verdict to the account's real budget**:

- **Wasted-spend flag**: a search term with **≥ ~70% of one day's budget**
  spent and 0 CV. Below that, flag only clearly-irrelevant *intent*,
  whatever the spend.
- **Data-sufficiency gates**: no CTR verdict under 100 impressions; no
  CVR/CPA verdict under 30 clicks; no QS verdict while QS is null (young
  accounts). Report "insufficient data" as its own category — never as FAIL.
- **CPC targets** come from the client's registry row / ledger, in the
  account currency — not from a global benchmark table.
- **Priority-1 signals at tiny budgets**: `search_budget_lost_impression_share`
  and `search_rank_lost_impression_share`. Lost-IS analysis beats Quality
  Score chasing: rank-lost on a converting keyword → raise its bid;
  budget-lost across the campaign → reallocate before asking for budget.
- **CV chain before spend analysis**: a broken conversion chain invalidates
  every downstream number. Verify in order: tag/conversion component present
  on the LP → form POST target actually receives submissions (Netlify Forms
  on Next.js SSR must POST to `/__forms.html`, playbook C1) → no gclid loss
  into external booking/LINE handoffs — fire the conversion on YOUR page
  before handing off (playbook C2) → ≥1 conversion recorded in-platform.
- **Japanese accounts**: negatives must cover script variants — the same
  word in kanji/hiragana/katakana/romaji (a negative on 求人 blocks neither
  バイト nor アルバイト); build themed shared lists (job-seeker, informational
  とは/やり方, 無料, competitor names) at MCC level when a theme recurs.
  Validate RSA lengths in Google's units (CJK chars count 2 — headline 30,
  description 90) with `gads.units()` BEFORE writing ads.

### 4. Evaluate & report

Findings in three buckets: **Do now** / **Queued (with unlock date)** /
**Watch**. Every recommendation cites the data row that motivated it (term,
spend, clicks, CV). Audit mode writes the scored `GOOGLE-ADS-REPORT.md` into
the client project's `reports/` dir — never into a brain vault or the plugin.

### 5. Apply changes (optimize/audit modes only)

Mutations via `gads.mutate(...)` with an explicit `cid=`. PAUSED campaigns
stay PAUSED unless the user says enable. Never delete — pause. One atomic
change-set, then re-query to verify the new state before reporting it.

### 6. Write back — this is how the skill trains (never skip)

1. **Ledger** (`shared/findings/google-ads-ledger.md`): one appended entry
   per action taken or queued, in the entry format defined at the top of that
   file — including a falsifiable **Hypothesis** and a **Check-on** date
   (typically +7d). Fill any `(pending)` outcomes that came due this run.
2. **Playbook promotion**: an outcome that confirms a pattern already
   OBSERVED on a *different* client → promote to CONFIRMED (cite both ledger
   entries). New single-client result → add/update as OBSERVED. Disconfirmed
   → mark REFUTED and keep it; negative knowledge is knowledge. Rules change
   only with a ledger citation; never renumber — retire with REFUTED so old
   references stay valid.
3. **Client wiki**: append the run summary to the client project's
   `wiki/log.md` (findings persist automatically, not as an optional step).
4. Commit workspace changes if the workspace is a repo the user has
   authorized you to push to.
