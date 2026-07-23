---
description: Full evidence-only website audit for any site — five parallel specialist lanes, annotated screenshots, validated charts, and an owner-ready Times New Roman PDF, verified page by page.
argument-hint: "<website URL> [client name] [business type] [report language]"
---

Read the `website-audit` skill (under this plugin's `skills/website-audit/`) and
run its seven-phase process end to end for `$ARGUMENTS`.

Work **autonomously**. Do not stop for approval between phases, and do not stop
until the final PDF has been rendered *and* visually verified page by page.

1. **Intake, one round only.** URL (required), client/company name, business type,
   report language. In an `/mb:init` project, read `CLAUDE.md` first: the language
   and client are usually already recorded, so ask only for what is genuinely
   missing. Two languages means two full PDFs, the second a native translation.
2. **Preflight** the toolchain (`scripts/render.sh check`). Report anything
   missing with its install line, then continue with what works: only the final
   PDF render hard-requires WeasyPrint.
3. **Phase 1 yourself** — `scripts/ground-truth.sh <url>`. Read the digest. The
   SPA-without-SSR pattern (empty served HTML, one canonical everywhere) is the
   most common killer finding; if the digest shows it, every lane must know from
   the start.
4. **Phase 2** — launch all five lanes in ONE message using
   `references/lane-briefs.md`, each brief prefixed with the ground-truth digest.
   Route through the Hub brains when installed (claude-seo, claude-ads,
   social-hub, landing-page-optimization) and generic sub-agents otherwise.
   Babysit them: resume a stalled lane, and re-run any lane yourself if its tool
   had no network. An empty findings file is not a result.
5. **Phases 3 to 7** — reconcile into 4 to 6 root causes, annotate 5 to 7
   screenshots with numbered callouts, hand-code the charts as inline SVG (load
   `dataviz` first), write the report against `references/report-spec.md` +
   `assets/report.css`, render with WeasyPrint, then rasterize EVERY page and
   look at each one. Fix layout defects and re-render until a full pass is clean.
6. **Before delivering**, pass the report prose through the `humanizer` patterns
   (standing master-brain rule). Findings files and code are exempt.
7. **Write back** — in a Master Brain project, persist root causes and key numbers
   to `wiki/`, raw evidence to `data/`, the PDF to `reports/`, append `wiki/log.md`,
   and queue a review TODO.

Close with the TLDR: what is wrong in priority order, plus the deliverable list
(`findings/`, `screenshots/`, `annotated/`, the PDF path).

Ground rules that are not negotiable: evidence only (unverifiable is written
"no data", never estimated), reconcile lane conflicts explicitly, include a
"What is already good" section, never use em dashes, and write the body for a
non-technical owner.
