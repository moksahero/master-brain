---
name: website-audit
description: >
  Run a full, evidence-only website audit for any site (SaaS, e-commerce, service
  business, agency, local, platform) and deliver an owner-ready Times New Roman PDF:
  ground-truth curl pass, five parallel specialist lanes writing severity-rated
  findings files, Playwright screenshots with numbered PIL callouts, hand-coded SVG
  charts, a WeasyPrint report, and a mandatory page-by-page visual verification.
  Use when the user says "website audit", "audit this site", "full site audit",
  "site teardown", "what is wrong with my website", "SEO + UX + reputation audit",
  "audit report PDF", or hands over a URL and asks what to fix.
version: 1.0.0
license: MIT
metadata:
  author: AgriciDaniel
  category: marketing
---

# Website Audit

One URL in, one PDF an owner will actually read out. This is an **execution
process**, not a checklist: you work autonomously, run the five specialist lanes
in parallel, and you are not done until the rendered PDF has been rasterized and
looked at page by page.

Works for any site type. The lane briefs adapt to the business model; the shape
of the report does not.

## Inputs (ask only for what is missing)

| Input | Notes |
| --- | --- |
| **Website URL** | Required. |
| **Client / company name** | Verify the legal entity in the official company register if identifiable. |
| **Business type** | SaaS, e-commerce, service business, agency, marketplace, rewards platform, local. Drives the trust checklist and the competitor set. |
| **Report language** | Default English. If a second language is asked for, produce **both** as separate PDFs. In an `/mb:init` project, honor the language recorded in `CLAUDE.md` (often Japanese). |
| **Output folder** | Current working directory. Create `findings/` and `screenshots/` inside it. In a Master Brain project, write under `reports/<client>-audit/` and mirror the evidence into `data/`. |

Ask in **one** round. Then run to completion without stopping for approval.

## Ground rules (non-negotiable)

1. **Evidence only.** Every claim traces to something captured: an HTTP response,
   a screenshot, a rendered DOM, a public record, a cited source. Anything
   unverifiable is written as **"no data"** — never estimated, never invented.
2. **Reconcile conflicts explicitly.** When two lanes disagree, say which evidence
   won and why.
3. **Fairness.** The report must contain a "What is already good" section. An audit
   that only attacks reads as a sales pitch.
4. **Never use em dashes.** Commas, colons, parentheses, periods.
5. **Write for a non-technical owner.** Plain language, analogies for technical
   concepts, no jargon in the body. Technical evidence lives in the findings files.
6. **Humanizer pass.** Before the report text is final, run the prose through the
   `humanizer` skill patterns (master-brain standing rule). Findings files and code
   are exempt.

## Preflight

```bash
SKILL="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/skills/website-audit"
bash "$SKILL/scripts/render.sh" check     # weasyprint, pdftoppm, python3+PIL, npx
```

`render.sh check` prints exactly what is missing and the install line for it.
WeasyPrint is the renderer the style spec is tuned for; do not silently swap it.
Screenshots go through the **Playwright MCP** when connected (preferred: it can
drive popups and read the console) and fall back to the bundled
`scripts/capture.sh` (`npx playwright screenshot`) otherwise.

## Phase 1: Ground truth (do this yourself, before any sub-agent)

```bash
bash "$SKILL/scripts/ground-truth.sh" https://example.com   # writes findings/00-ground-truth.md
```

It captures, and you read: raw homepage HTML (server-rendered vs client-side SPA:
an empty body shell is an SPA and that becomes a headline finding), `robots.txt`,
`sitemap.xml` and the full public URL list, meta/canonical/JSON-LD/company
identifiers in the raw HTML, response headers, compression, and the Googlebot +
GPTBot user-agent variants of the homepage.

**This ground truth goes verbatim into every sub-agent prompt** so no lane
rediscovers it. The SPA-without-SSR pattern (empty served HTML, homepage
canonical everywhere) is the single most common killer finding on modern sites:
one curl detects it, and every lane must know from the start.

## Phase 2: Five parallel specialist lanes

Launch all five as sub-agents **in one message**. Each writes a severity-rated
(Critical / High / Medium / Low) markdown findings file with concrete evidence per
finding and an explicit "no data" register, then returns a 10-line summary.

| Lane | Output file | Route through |
| --- | --- | --- |
| Technical SEO | `findings/technical-seo.md` | `claude-seo:seo-technical` agent, else a generic sub-agent with the brief |
| Page inventory | `findings/page-inventory.md` | generic sub-agent + `scripts/page-inventory.sh` |
| Content and E-E-A-T | `findings/content-eeat.md` | `claude-seo:seo-content` + `claude-seo:seo-geo` |
| Visual / UI | `findings/ui-visual.md` + `screenshots/` | `claude-seo:seo-visual` + Playwright MCP + `landing-page-optimization` skill |
| Marketing, socials, reputation | `findings/marketing-socials.md` | `claude-ads:ads-competitor`, `social-hub:social-intel`, `seo-local`/`seo-maps` for local |

The full brief for each lane, including what "done" means, is in
[`references/lane-briefs.md`](references/lane-briefs.md). Paste the lane brief plus
the Phase 1 ground truth into each sub-agent prompt. If the Hub brains are not
installed, the briefs work as-is with generic sub-agents.

**Babysit the agents.** If one stops mid-work, resume it with instructions to
continue to completion. If a delegated tool has no network or fails, re-run that
lane yourself rather than accepting an empty file. Delegating to an external CLI
(e.g. Codex) only works for local-file tasks: sandboxes usually have no network,
so anything that fetches the web stays in Claude Code.

## Phase 3: Reconcile and synthesize

- Read all findings files. Reconcile conflicts. Count findings by severity.
- Identify the **4 to 6 root causes** that explain most findings. There are always
  fewer causes than findings.
- Decide the narrative: each root cause becomes one problem chapter told as a
  story — what we saw, why it hurts the business, what to do.

## Phase 4: Annotate screenshots

Pick the 5 to 7 screenshots that prove the biggest problems and draw numbered
callouts on them:

```bash
python3 "$SKILL/scripts/annotate.py" screenshots/home-mobile.png annotated/home-mobile.png \
  --box 120,340,880,610 --box 60,1200,900,1400 --crop 0,200,1080,1600
```

Red rounded rectangles (stroke `rgb(200,40,30)`, width ≈ W/320, radius 12) plus a
numbered circle badge per box. Crop tall or mostly-empty screenshots to the
relevant region so figures do not waste page space. **Every annotation number must
be explained in the figure caption.**

## Phase 5: Build charts

Load the **`dataviz`** skill first if it is available, then follow
[`references/report-spec.md`](references/report-spec.md) → *Charts*. The rules that
make these charts work: horizontal bars, thin marks, rounded ends, direct value
labels on every bar, recessive axes; a single hue plus a dashed "healthy: 70+"
reference line for scores; a **single-hue sequential ramp** for severity (it is
ordered data, never four unrelated colors); exactly two colorblind-safe hues for
any two-series comparison; **big-number stat tiles instead of bars** when the range
is extreme (2 reviews vs 285,000). Hand-code them as inline SVG in the report HTML:
deterministic, serif-matching, no library.

## Phase 6: Write the report and render the PDF

One HTML file, rendered with WeasyPrint. The chapter structure, the box types, and
the complete style spec are in [`references/report-spec.md`](references/report-spec.md);
the stylesheet itself is ready to include at [`assets/report.css`](assets/report.css).

Structure (adapt titles to the actual findings, keep the shape): cover, contents,
**The Verdict in One Page**, **The Big Picture**, one chapter per root cause,
**Risks**, **The Plan** (P0 this week / P1 next 30 days / P2 days 30 to 90),
**What Is Already Good**, appendix.

```bash
bash "$SKILL/scripts/render.sh" render report.html "<Client>-Website-Audit-Report.pdf"
```

## Phase 7: Verify like a publisher (mandatory)

```bash
bash "$SKILL/scripts/render.sh" verify "<Client>-Website-Audit-Report.pdf"   # → verify/page-NN.png
```

Then **actually look at every page** with the Read tool. Fix and re-render:
orphaned boxes or paragraphs alone on a page, near-empty pages, figures that
overflowed to their own page (crop the image or move text between figures), badly
split tables. Do not declare done until a full page-by-page pass shows no layout
defects.

If a second language was requested, produce it as a full **native translation**
(chart labels, captions, boxes, tables, localized number formatting), reusing the
same annotated images, and verify its pages the same way.

## Final deliverables

- `findings/` — the five evidence files (plus `00-ground-truth.md`)
- `screenshots/` — all raw captures, `annotated/` — the callout versions
- `<Client>-Website-Audit-Report.pdf` (and the second-language PDF if requested)
- A closing summary to the user: TLDR of what is wrong in priority order, plus the
  deliverable list.

## Write-back (Master Brain projects)

When running inside an `/mb:init` project, the audit is not finished until it is
persisted: root causes and key numbers as notes under `wiki/`, raw captures and
HTTP evidence under `data/`, a line in `wiki/log.md`, the PDF in `reports/`, and a
TODO for owner review:

```bash
node "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts/todos.mjs" \
  add "Review + deliver <Client> website audit PDF" --skill=website-audit --priority=high
```

## Notes for the operator

- Typical wall clock: 15 to 25 minutes for the audit lanes, plus the report build.
- If the Hub packs (claude-seo / claude-blog / claude-ads / website-brain) are
  installed, route the lanes through them; otherwise the briefs stand alone.
- This audit is **site-side**. For the fused multi-brain vault plus a bilingual
  agency deck, run `/mb:report` (client-intelligence-report) instead or after.
