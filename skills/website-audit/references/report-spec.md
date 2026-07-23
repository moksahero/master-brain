# Report spec — structure, charts, style, verification

The report is written for a non-technical owner. Plain language in the body,
analogies for technical concepts, technical proof in `findings/`. No em dashes.

## Structure

1. **Cover page** (no page number): title, site, client, scope, date, evidence counts.
2. **Contents.**
3. **The Verdict in One Page** — the honest headline first (what is genuinely real
   and good), then the 3 to 5 compounding problems as numbered plain-language
   points, then the sequencing logic, then a "How to read this report" box.
4. **The Big Picture** — scores chart, severity chart, and a 4-tile row of the most
   damning numbers.
5. **One chapter per root-cause problem** (typically 5 to 7). Annotated screenshots
   and/or a chart as evidence, plain-language narrative, and a **"What this means"**
   box closing each chapter with the takeaway and the fix.
6. **Risks** — anything with legal or platform-penalty exposure gets a red **"Risk"**
   box with the defusal step.
7. **The Plan** — three tables:
   - **P0 this week** (quick high-impact fixes)
   - **P1 next 30 days** (foundation rebuild)
   - **P2 days 30 to 90** (growth engine)

   Columns: `#`, `Action`, `Who` (Developer / Designer / Copywriter / Marketing /
   Owner), `Fixes` (section reference). Close with a **"Why this order"** box
   explaining why spending on marketing before the fixes wastes money.
8. **What Is Already Good** — genuine positives, stated plainly.
9. **Appendix** — evidence-file table, methodology summary, and a
   verification-limits paragraph listing every "no data" item and every reconciled
   source conflict.

Adapt chapter titles to the actual findings. Keep the shape.

## Charts

Load the `dataviz` skill first if available. Hand-code every chart as **inline SVG**
in the report HTML: deterministic, serif-matching, no library, no external fetch.

- Horizontal bars, thin marks, rounded ends, **direct value labels on every bar**,
  recessive axes.
- **Scores chart**: single hue (`#3b6fb5`) with a dashed reference line marking the
  healthy threshold (e.g. "healthy: 70+").
- **Severity chart**: severity is **ordered** data, so use a single-hue sequential
  ramp dark to light — `#7f1d1d`, `#a53f35`, `#c76b52`, `#e0a184`. Never four
  unrelated colors.
- **Two-series comparison** (e.g. "what a visitor sees vs what Google receives"):
  exactly two hues, colorblind-safe. The pair `#3b6fb5` / `#c03a2b` passes. Small legend.
- **Extreme ranges do not go in a bar chart.** 2 reviews vs 285,000 becomes
  big-number stat tiles.

## Style spec

Include [`../assets/report.css`](../assets/report.css) — it implements exactly this:

- A4, `Times New Roman, Liberation Serif, serif`, 11pt body, justified, 1.45 line height.
- Footer on every page except the cover:
  `"<site> Website Audit, <Month Year> | Page X of Y"`.
- `h1` with a bottom border; each numbered section starts on a new page (`page-break-before`).
- Severity colors: Critical `#7f1d1d`, High `#a53f35`, Medium `#8a6d00`, Low `#3f6b3f`.
- `.meaning` box: 4px blue left border (`#3b6fb5`), light blue background, small-caps
  "What this means." label.
- `.warn` box: 4px red left border (`#9b1c1c`), light red background, small-caps "Risk." label.
- Stat tiles: bordered table cells, 19pt bold numbers (bad numbers in dark red), 8.5pt captions.
- Figures: full-width images with a thin gray border and a 9pt caption whose callout
  numbers are bold red; `page-break-inside: avoid`.

Markup the CSS expects:

```html
<div class="cover">…</div>
<h1>3. Google receives an empty page</h1>
<figure><img src="annotated/home-mobile.png"><figcaption>
  <b>1</b> the hero never renders, <b>2</b> the cookie wall covers the only CTA.
</figcaption></figure>
<div class="meaning">Search engines index a blank shell, so none of the copy counts.</div>
<div class="warn">Review gating breaches Trustpilot policy. Remove the star filter.</div>
<table class="tiles"><tr><td><span class="num bad">0</span><span class="cap">words Google receives</span></td>…</tr></table>
```

## Verification (Phase 7, mandatory)

Render, rasterize **every** page with `pdftoppm`, and look at each one with the Read
tool. Fix and re-render:

- orphaned boxes or paragraphs alone on a page,
- near-empty pages,
- figures that overflowed onto their own page (crop the image, or move text between figures),
- tables split badly across a page break.

Do not declare done until a full page-by-page pass shows no layout defects. A second
language means a full native translation (chart labels, captions, boxes, tables,
localized number formatting) reusing the same annotated images, verified the same way.
