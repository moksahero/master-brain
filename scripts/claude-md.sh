#!/usr/bin/env bash
# master-brain :: single source of truth for the mb-managed section of a project's CLAUDE.md.
#
# Usage:
#   bash claude-md.sh emit             # print the managed block (with markers) to stdout
#   bash claude-md.sh sync [DIR]       # reconcile DIR/CLAUDE.md (default: cwd) to the canonical block
#
# The managed block is delimited by HTML-comment markers. Everything OUTSIDE the
# markers (project name, focus, market, active brains, API-key status, report
# language) is owned by the project and is NEVER touched.
#
#   /mb:init   writes the project-specific CLAUDE.md, then calls `sync .` to append
#              this section — so new projects ship with the markers in place.
#   /mb:update calls `sync .` on the current project to retrofit the section into
#              older projects and refresh it when this canonical text changes.
#
# Keeping the text here (not duplicated in init.md / SKILL.md) means the rule
# lives in ONE place; the commands reference it instead of re-stating it.
#
# The block carries TWO rules:
#   1. Persistence  — work is written back into wiki/ and data/.
#   2. Brain routing — a topic mention is enough to invoke a fleet skill; the
#      user never has to type the slash command. Kept here so every project
#      created by /mb:init, and every older project refreshed by /mb:update,
#      inherits the same routing map as the fleet grows.

set -uo pipefail

START='<!-- mb:managed:start — auto-synced by /mb:update; do not edit between these markers, changes are overwritten -->'
END='<!-- mb:managed:end -->'

managed_block() {
  printf '%s\n' "$START"
  cat <<'BODY'
## Persistence — keep the work in the vault

This project is a Master Brain workspace. `wiki/` and `data/` are its durable
memory: **work that isn't written there is lost when the session ends.** So, as
a standing rule for every session in this directory:

- **`wiki/`** — the lasting knowledge. Any finding, decision, number, competitor
  fact, or deliverable summary worth more than this one chat → a note under
  `wiki/` (`entities/`, `concepts/`, `sources/`, `deliverables/`), a one-line
  entry in `wiki/log.md`, and a link from `wiki/index.md`. Update existing notes
  instead of duplicating.
- **`data/`** — the raw evidence behind that knowledge: API dumps
  (DataForSEO/Firecrawl), scrapes, exports, CSVs. Regenerable, but cite-able.
- **`reports/`** — rendered deliverables (PDF/HTML). Output, not memory.

Before finishing a substantive piece of work, write it back: update `wiki/`,
drop raw artifacts in `data/`, append `wiki/log.md`. Don't leave the vault
frozen at bootstrap while results pile up only in `reports/` or `web/`.

## Brain routing — a mention is the trigger, not a slash command

The full AI Marketing Hub fleet is installed system-wide in `~/.claude/skills`
and refreshed by `/mb:update`. In this project, **route on topic, not on
syntax**: when a request touches one of the areas below, invoke the matching
skill yourself. Nobody has to type `/ads-reddit` for the Reddit Ads skill to
run — "how are the Reddit ads doing" is already the trigger.

Four rules settle the usual cases:

1. **Most specific wins.** "Reddit ads" → `ads-reddit`, not the generic
   `ads-audit`. Reach for a family-level skill (`claude-ads:ads`, `seo`, `blog`) only when
   the request genuinely is cross-platform or unscoped.
2. **Japanese-market landing pages → `jp-lp`**, never `landing-page-optimization`
   alone. That one is English and Western-SaaS shaped: it misses the two LP
   populations, the 和文 typography values, the form/LINE reality, and the
   景表法・薬機法・特商法・医療広告 gate that in Japan sits *upstream* of the copy.
   Run both when useful; `jp-lp` wins on conflict.
3. **Name the skill in one line before running it.** Routing silently is how the
   wrong brain gets used for ten minutes.
4. **Don't force a fit.** If two skills fit equally, ask once. If none fit, just
   do the work. `find-skills` is the escape hatch when you suspect a skill
   exists but can't name it.

The map below is curated, so it lags the fleet. `/mb:update` regenerates a
complete inventory of every installed skill at `~/.claude/master-brain-fleet.md`,
one line each with its owning brain and what it does. **Read that file before
concluding no skill fits**. A brain installed after this block was written will
be there and not here.

### Topic → skill

- **A named ad platform** → `ads-google` · `ads-meta` (Facebook, Instagram) ·
  `ads-reddit` · `ads-tiktok` · `ads-linkedin` · `ads-x` · `ads-youtube` ·
  `ads-microsoft` (Bing) · `ads-pinterest` · `ads-snapchat` · `ads-amazon` ·
  `ads-apple`.
- **Paid media, cross-platform** → brand/offer profile before any creative:
  `ads-dna`; competitor ad libraries: `ads-competitor`; the post-click page:
  `ads-landing`; budget, pacing, CPA/ROAS/MER, break-even: `ads-budget` and
  `ads-math`; hooks, fatigue, format coverage: `ads-creative`; asset production:
  `ads-generate`, `ads-photoshoot`; pixels, CAPI, attribution windows:
  `ads-attribution`, `ads-server-side-tracking`; experiments: `ads-test`;
  pacing watch: `ads-monitor`; whole-account teardown: `ads-audit`; strategy:
  `ads-plan`.
- **SEO** → whole site: `seo-audit`; one page: `seo-page`; crawl, index, robots,
  Core Web Vitals: `seo-technical`; map pack, GBP, NAP, reviews: `seo-local`,
  `seo-maps`; store, products, Shopping: `seo-ecommerce`; JSON-LD and rich
  results: `seo-schema`; `seo-sitemap`; `seo-hreflang`; AI Overviews, ChatGPT,
  Perplexity visibility: `seo-geo`; keyword grouping and pillar pages:
  `seo-cluster`; links: `seo-backlinks`; alt text and image weight:
  `seo-images`; post-deploy regression: `seo-drift`; "ranked but not
  converting / why won't this rank": `seo-sxo`.
- **Content** → `blog-write`, `blog-outline`, `blog-brief`, `blog-rewrite`,
  `blog-audit`, `blog-cluster`, `blog-schema`, `blog-factcheck`, `blog-decay`,
  `blog-cannibalization`, `blog-translate`, `blog-multilingual`, `blog-image`,
  `blog-chart`. Product and PDP work → the `product-page` family
  (`product-page-write`, `-audit`, `-cro`, `-schema`, `-objections`,
  `-compliance`). One asset into many channels → `repurpose` plus the
  per-platform `repurpose-*`.
- **Email** → strategy `email-plan`; copy `email-write`; automation
  `email-sequence`; pre-send scoring `email-review`; SPF/DKIM/DMARC and
  deliverability `email-audit`; inbox triage `email-check`.
- **Social, video, imagery** → `social-hub`, `social-research`, `social-intel`,
  `social-produce`; the `video-*` family; `banana` for image generation;
  `canvas` for visual boards; `walt` for a video-production brain.
- **Site and research** → `website-audit` (evidence-only teardown → PDF; run it
  first whenever there is an existing site), `website-brain-crawl` and
  `website-brain-build` (capture a site into a vault), `marketing-brain`
  (competitors plus keywords), `web-perf` (Core Web Vitals via DevTools),
  `client-intelligence-report` / `/mb:report` (the fused PDF).
- **Knowledge and vault** → `wiki`, `wiki-ingest`, `wiki-query`, `wiki-lint`,
  `wiki-fold`, `save`. This is the machinery behind the Persistence rule above.
- **Planning, journaling, a client's own operating system** → `compass`. An
  Obsidian vault template: daily questions, quarterly retreats, multi-scale
  planning, habits, tasks, people, writing boards. `/compass new <slug>` builds
  one clean vault per client; `/compass run <job> --vault <path>` runs its
  prompt library (morning, end of day, weekly review, retreat, task triage,
  vault health). One vault, one client, always.

### Always-on, whatever else runs

- **Every prose deliverable** goes through substance then style:
  `slop-review` → `slop-rewrite` → `slop-verify`, then `humanizer`. Not only on
  request. Skip both only for code, raw data, or verbatim output.
- **Every client-facing deliverable names only the company it is for.** No other
  client anywhere in it: body, headings, tables, figures, captions, footnotes,
  filenames, metadata. Anonymise instead. Grep for other names before rendering.
BODY
  printf '%s\n' "$END"
}

sync() {
  local dir="${1:-.}"
  local file="$dir/CLAUDE.md"

  if [ ! -f "$file" ]; then
    echo "claude-md: no CLAUDE.md in $dir — skip (run /mb:init to scaffold one)"
    return 0
  fi

  local blockfile tmp
  blockfile="$(mktemp)" || return 1
  tmp="$(mktemp)" || { rm -f "$blockfile"; return 1; }
  managed_block > "$blockfile"

  local had_markers="no"
  if grep -qF "$START" "$file" && grep -qF "$END" "$file"; then
    had_markers="yes"
    # Replace everything from START to END (inclusive) with the canonical block.
    awk -v s="$START" -v e="$END" -v bf="$blockfile" '
      BEGIN { while ((getline line < bf) > 0) block = block line ORS }
      index($0, s) { printf "%s", block; skip = 1; next }
      skip && index($0, e) { skip = 0; next }
      skip { next }
      { print }
    ' "$file" > "$tmp"
  else
    # No markers yet (older project) — append the block after a blank line.
    { cat "$file"; printf '\n'; cat "$blockfile"; } > "$tmp"
  fi

  if cmp -s "$file" "$tmp"; then
    echo "claude-md: $file already current — no change"
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
    [ "$had_markers" = "yes" ] && echo "claude-md: refreshed managed section in $file" \
                               || echo "claude-md: added managed section to $file"
  fi
  rm -f "$blockfile"
}

cmd="${1:-}"
case "$cmd" in
  emit) managed_block ;;
  sync) shift; sync "${1:-.}" ;;
  *)
    echo "usage: claude-md.sh {emit | sync [DIR]}" >&2
    exit 2
    ;;
esac
