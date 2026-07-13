# Google Ads Playbook — distilled cross-client rules

The **trainable layer** for the ads-google operator. Rules distilled from real
client outcomes recorded in `google-ads-ledger.md`. The skill reads this before
every run and promotes/demotes rules after every run.

**Confidence tiers**
- **CONFIRMED** — observed on ≥2 clients, or externally verified. Apply as a hard check.
- **OBSERVED** — seen once, on one client. Apply, but watch for counter-evidence.
- **HYPOTHESIS** — doctrine or reasoning not yet tested on this portfolio. Test when cheap.
- **REFUTED** — tried and disproven here. Do not re-suggest; kept as negative knowledge.

Promotion rule: an OBSERVED pattern that repeats on a *second* client →
CONFIRMED (cite both ledger entries). Every rule cites its evidence. Never
renumber — retire with REFUTED so old ledger references stay valid.

---

## L — Learning phase & cadence

- **L1 (HYPOTHESIS — upstream doctrine; confirm on your own ledger)**: launch →
  ~1 week hands-off (learning phase) → then optimize. No bid/budget/keyword
  changes in the first ~7 days; they reset learning. Week 1 = read-only
  tracking/status/search-term checks only. Queue changes with an unlock date.
- **L2 (HYPOTHESIS)**: at tiny budgets (< ~¥3,000 / $20 per day), Smart Bidding
  (tCPA) needs ~30 CV/month to work; below that, Manual CPC or Max Clicks with
  a CPC cap outperforms. Test when an account reaches steady CV volume.

## C — Conversion chain (check BEFORE any spend analysis)

- **C1 (HYPOTHESIS — confirmed twice upstream; verify on your stack)**: Netlify
  Forms on Next.js SSR must POST to `/__forms.html`, not `/`. Otherwise
  submissions silently drop — no email, no CV, and the ads data shows a fake
  0% CVR. Diagnostic: form works visually but no notification email arrives.
- **C2 (HYPOTHESIS — upstream research corpus)**: external-booking handoffs
  (Hotpepper/EPARK/LINE etc.) leak gclid — fire the conversion on YOUR page
  (button click / completion-based CV) before handing off, or attribution is lost.

## N — Negative keywords

- **N1 (HYPOTHESIS — JP linguistic reality)**: JP negatives must cover script
  variants — kanji/hiragana/katakana(/romaji) of the same word. A negative on
  求人 blocks neither バイト nor アルバイト. Build themed shared lists per intent:
  job-seeker (求人, 採用, バイト, 年収), informational (とは, やり方, 自分で),
  free (無料, 格安 — only where off-brand), competitor names (only if intentional).
- **N2 (CONFIRMED — plugin doctrine + universal)**: negatives Exact/Phrase only,
  sourced from the actual search-terms report, never Broad, never guessed.

## B — Budgets, bids, structure (tiny local accounts)

- **B1 (HYPOTHESIS)**: at tiny budgets, lost-impression-share (budget vs rank)
  is the primary weekly dial: rank-lost on a converting keyword → +bid;
  budget-lost across the campaign → reallocate before asking for more budget.
- **B2 (HYPOTHESIS)**: 地名 × サービス (locality × service) terms beat generic
  service terms for local intent at low budget — concentrate spend there first.
  Measure via per-ad-group CPA once CV data exists.

## Benchmarks — per vertical (fill from YOUR data, not US averages)

The generic audit framework's US thresholds do not apply at small budgets.
This table is the portfolio's own baseline; update it from ledger outcomes.

| Vertical (client) | Target CPC | CTR baseline | CVR target | CPA target | Status |
|---|---|---|---|---|---|
| (example) 整体 (acme) | ¥300 | TBD | TBD | TBD (1件の粗利から逆算) | pre-data |

---

*Update discipline: rules change only with a ledger citation.*
