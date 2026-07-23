# Lane briefs — the five parallel specialists

Paste **one brief + the Phase 1 ground truth** into each sub-agent. Each lane:

- writes its own file into `findings/`, severity-rated **Critical / High / Medium / Low**;
- attaches concrete evidence to every finding (URL, header, HTML snippet, screenshot path, source link);
- keeps an explicit **"no data" register** at the bottom for anything it could not verify;
- returns a **10-line summary** to the orchestrator;
- never estimates a number it did not observe.

Findings file shape: see [`../templates/findings.md`](../templates/findings.md).

---

## Lane 1 — Technical SEO → `findings/technical-seo.md`

Route: `claude-seo:seo-technical` agent when installed, else a generic sub-agent.

Cover:

- **Crawlability and indexability per route**: canonical, title, meta description,
  meta robots **in the SERVED html, not the rendered one**. A canonical that only
  appears after hydration does not exist for the crawler.
- **JS-rendering risk**: compare raw vs rendered DOM per template. Test **Googlebot
  and GPTBot user agents** for cloaking or prerender differences.
- **Soft-404 behavior** on invalid paths (does `/thispagedoesnotexist` return 200?).
- **Redirect chains**, http→https, www/non-www, **trailing-slash duplicates**.
- **HTTP compression** — test `Accept-Encoding` explicitly, do not assume.
- **Payload weight of the critical path** (HTML + blocking CSS/JS, transfer size).
- **Cache-Control** on documents and static assets.
- **Security headers**: HSTS, CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy.
- **TLS** (cert issuer, expiry, chain) and **HTTP/2 / HTTP/3** support.
- **Structured data completeness** (types present, required properties missing, validation errors).
- **hreflang** correctness and reciprocity if multilingual.
- **Sitemap URL health**: every sitemap URL's status, and URLs live on the site but absent from the sitemap.

---

## Lane 2 — Page inventory → `findings/page-inventory.md`

Route: generic sub-agent driving `scripts/page-inventory.sh` (writes a TSV you turn
into the table and the issue list).

For **every sitemap URL**, record: HTTP status, title, meta description, canonical,
meta robots, `og:title`, **h1 presence in raw HTML**, raw visible word count,
JSON-LD types.

Then a per-page issue list: missing or duplicate titles and descriptions, canonical
mismatches, thin raw content.

**Duplicate-across-all-pages patterns are usually the biggest finding** — one title
and one canonical repeated site-wide means the site has one page as far as search
is concerned. Report the duplicate groups first, with counts.

---

## Lane 3 — Content and E-E-A-T → `findings/content-eeat.md`

Route: `claude-seo:seo-content` + `claude-seo:seo-geo` when installed.

- **Rendered word count per page vs page-type minimums.** Label this *topical
  coverage*, not a filler target.
- **E-E-A-T rubric scored /100** — Experience, Expertise, Authoritativeness,
  Trustworthiness, **with the weights stated** so the score is reproducible.
- **Trust content checklist adapted to the niche**: About/team page with real
  people, FAQ, proof (case studies, payouts, portfolio, reviews shown on-site),
  transparency pages, legal completeness **and dates**, contact quality (phone,
  chat, stated response expectations), copy bugs and placeholder text.
- **Benchmark against what the top competitors in this niche standardly show.**
  Name them, and say what they have that this site does not.
- **AI-citation readiness score**: what a non-JS crawler can actually quote. If the
  answer is "nothing", that is a Critical finding, not a nice-to-have.

---

## Lane 4 — Visual / UI review → `findings/ui-visual.md` + `screenshots/`

Route: Playwright MCP (preferred: drives popups, reads console) or
`claude-seo:seo-visual`; load the `landing-page-optimization` skill for the CTA and
above-the-fold judgment.

Captures at **desktop 1920x1080** and **mobile 390x844**, above-the-fold and full
page, for the homepage and **every key template** (product/service page, pricing,
contact, blog post, checkout).

**Capture BEFORE and AFTER dismissing any popup or modal.** The interruption
sequence is itself evidence: if the first thing a visitor sees is a cookie wall
stacked on a newsletter modal, screenshot both states in order.

Check:

- First-visit experience, in order, as a real person meets it.
- Whether the hero / value proposition **actually exists on mobile** — inspect the
  DOM, not just the fold. "Pushed below the fold" and "not rendered at all" are
  different findings.
- CTA clarity: is the primary action obvious, singular, and above the fold?
- Placeholder or unfinished assets (lorem ipsum, stock left in, broken images).
- Dead whitespace, stray elements, overlap, horizontal scroll on mobile.
- **Console errors** per route.
- **Load time to network idle** per route.

Name screenshots `screenshots/<template>-<desktop|mobile>-<fold|full>[-popup].png` so
the report can cite them.

---

## Lane 5 — Marketing, socials, reputation → `findings/marketing-socials.md`

Route: `claude-ads:ads-competitor` for the competitor ad picture, `social-hub:social-intel`
for platform presence, `seo-local` / `seo-maps` when the business is local.

- **Direct-probe social URLs on every major platform** and record the HTTP status.
  Absence is a finding. Bot-walled platforms are marked **unverified, not absent** —
  never claim a profile does not exist because a login wall blocked you.
- **Reviews footprint** (Trustpilot, Google, G2, industry-specific), live-checked
  with counts and dates.
- **Brand SERP**: query `"<brand>"` and `"<brand> reviews"` and describe what an
  interested buyer actually finds.
- **Lookalike / typosquat domains** and anything impersonating the brand.
- **Company-register verification**: incorporation date, officers, address type.
  Flag mass virtual-office addresses.
- **Press and backlinks**: who links, who cites, is there any third-party mention.
- **Integrations visible in the shipped code**, including compliance risks such as
  review gating, undisclosed affiliate scripts, or trackers firing before consent.
- **Competitor benchmark with concrete numbers and sources** — no vibes.

---

## Definition of done, per lane

The lane is done when its file has: a severity table, every finding evidenced, the
"no data" register filled in, and the 10-line summary returned. An empty or
placeholder file is not a result — if the tooling failed, say so in the summary so
the orchestrator can re-run the lane itself.
