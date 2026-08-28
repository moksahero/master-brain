# The 100 point score every report opens with

Standing rule for every client-facing report this fleet produces: **the first
thing the reader sees after the cover is a score out of 100.** Not on page four,
not in the third paragraph of the executive summary. First.

Owners read the first page and skim the rest. A number they can hold in their
head is what makes the other forty pages get opened at all, and it is what makes
the next report comparable to this one.

This file is the single source of that rule. `/mb:report`, `/website-audit`,
`/mb:init` and the mb-managed `CLAUDE.md` block all point here instead of
restating it.

## Where it goes

Page 1 of the body, immediately after the cover and contents, before the verdict
narrative, before any chapter, before any chart other than the scorecard's own.
If the reader stops after one page, they still leave with the score, the rank,
and the one thing dragging it down.

## What it contains

1. **The overall score as a badge**: `72 / 100`, with its letter rank.
2. **One row per dimension** actually covered by the report: the dimension name,
   its own score out of 100, its letter rank, a bar, and its weight.
3. **The weighted overall**, stated as arithmetic the reader could redo: the
   weights are printed, they sum to 100, and the overall is their weighted
   average.
4. **One line naming the biggest drag**: which dimension costs the most points,
   and therefore where the first money goes.
5. **The bands, stated once**: A 90+, B 80+, C 60+, D 40+, F below 40.

## How the number is built

Score is a summary of the findings, never an impression. Build it so anyone can
reconstruct it.

- Each dimension **starts at 100 and loses points to findings that are actually
  in the report body**. Default deductions: Critical 25, High 15, Medium 7,
  Low 3. Floor at 0.
- A dimension carrying an unresolved **Critical cannot score above 60**, whatever
  the arithmetic says. A site that does not get indexed is not a B.
- The overall is `round(sum(score_i * weight_i) / sum(weight_i))`. Recompute it
  from the printed rows right before rendering. A scorecard whose rows do not
  add up to its own badge is the fastest way to lose the room.
- The **deduction ledger goes in the appendix**: every dimension, every finding
  that cost it points, the severity, the points. The badge on page 1 is the
  claim; the appendix is the receipt.

### Default dimensions and weights

Adapt the set to what the engagement actually covered, then reprint the weights.
Starting points:

| Report | Dimensions (weight) |
| --- | --- |
| Website audit | Technical foundation 25, Findability and SEO 25, Conversion and LP 20, Content and trust 15, Measurement 15 |
| Client intelligence report | Site and brand foundation 20, SEO and keywords 25, Google performance and Core Web Vitals 20, Competitors and ads 20, Landing page and CRO 15 |
| Paid media audit | Tracking and attribution 30, Account structure 20, Creative 20, Budget and bidding 20, Policy and compliance 10 |

## Grounding, and what to do with missing data

- Every dimension score traces to findings in this report. Never invent a grade
  the body does not support, and never grade a dimension the report did not
  examine.
- If a dimension could not be measured (missing API key, blocked crawl, no
  account access), **keep the row, mark it `no data`, exclude it from the
  weighting, and renormalize the remaining weights** so they still sum to 100.
  Say so in the note under the table. Do not silently drop the row, and do not
  score an unmeasured dimension at 0: that is a fabricated failing grade.
- Degraded data widens the `no data` list. It does not quietly lower the score.

## Japanese wording

Reports default to Japanese. Use these labels so scores read the same across
every deliverable:

- 総合スコア **72 / 100**（ランク C）
- 評価軸ごとの内訳: 評価軸 / スコア / ランク / 配点
- 配点の合計は 100。総合スコアは各評価軸の加重平均。
- 最も足を引っ張っている項目: <dimension>（<points> 点の損失）
- ランク基準: A 90以上 / B 80以上 / C 60以上 / D 40以上 / F 40未満
- 測定できなかった項目は「データなし」と明記し、配点から除外して再配分する。

## What this rule is not

It does not touch the `anti-slop` pass. Anti-slop reports defects in prose and
deliberately refuses to emit a score or a verdict on authorship. This scorecard
grades **the client's asset**, not the writing about it. The two never meet: do
not ask anti-slop for a number, and do not source this number from it.

## Scope

**Applies to** any rendered client-facing report: `/mb:report`,
`/website-audit`, ads audits, LP and CRO reports, SEO audits, whatever else ends
in a PDF or a document with a client's name on the cover.

**Does not apply to** raw findings files, data dumps, `wiki/` notes, internal
working files, or a plain answer in chat. Those stay evidence-shaped.
