# E-commerce research recipe

The standing combination for any **online store** (Shopify, futureshop, MakeShop,
BASE, Magento, WooCommerce, custom). Use this whenever the target sells products
directly — instead of the generic SEO/ads routing, which under-serves stores
because it never looks at the catalog itself.

A store fails in ways a brochure site cannot: an unused `product_type`, a broken
category layer, thin product copy at scale, no reviews, a shipping threshold that
kills the cart, a checkout on a second domain that severs attribution. None of
that is visible from a keyword report. **The catalog is evidence — pull it.**

## The combination (run in this order)

| # | Step | Brain / command | Why it is here |
|---|---|---|---|
| 0 | **Catalog pull** | platform endpoints + `data/` (see below) | Ground truth on every SKU before any opinion is formed. Cheap, exact, and it reframes everything downstream. |
| 1 | **Evidence audit** | `/website-audit <url>` | Ground-truth curl pass + five specialist lanes → the technical/visual/content baseline the rest cites. |
| 2 | **E-commerce SEO** | `/seo-ecommerce <url>` | Product schema validation, Google Shopping / marketplace visibility, competitor pricing, category-layer gaps. The one EC-specific skill in the fleet. |
| 3 | **Keywords + competitors** | `marketing-brain` (DataForSEO) | Commercial-intent keyword map, category vs product vs informational split, who actually owns the SERP. |
| 4 | **Paid readiness** | `/ads-dna` → `/ads-competitor` → `/ads-landing` | Whether the category is contested, what rivals run, and whether the store's own pages can convert paid traffic at all. |
| 5 | **Fusion** | `/mb:report` | One owner-readable PDF citing steps 0–4. |

Local SEO is **out of scope** for a pure online seller with no consumer
storefront. Add `local-seo-brain` only when there are physical shops.

## Step 0 — pull the catalog

Never audit a store from its homepage alone. Get the machine-readable catalog:

```bash
# Shopify — paginate until a page returns < 250
for i in $(seq 1 20); do
  curl -sS "https://<host>/products.json?limit=250&page=$i" -o data/catalog/p$i.json
  n=$(python3 -c "import json;print(len(json.load(open('data/catalog/p$i.json'))['products']))")
  echo "page $i: $n"; [ "$n" -lt 250 ] && break
done
curl -sS "https://<host>/collections.json?limit=250" -o data/catalog/collections.json
```

Other platforms: XML sitemaps (`sitemap_products_*.xml`), a Google Merchant feed
(`/*.xml`, `/feed`), `application/ld+json` `Product` blocks scraped per page, or
the site's own CSV export. **Whatever you get, it lands in `data/`** — it is the
evidence every later claim cites.

Then compute, over the whole catalog, and put the numbers in the report:

- **Taxonomy health** — how many SKUs have an empty `product_type` / category?
  How many `vendor` values are polluted with import artifacts (backslash paths,
  category strings, duplicated brand spellings)? A broken taxonomy silently
  disables faceted navigation, collection automation, and feed quality.
- **Content depth** — body-copy character count per SKU; count SKUs under ~200
  Japanese characters (or ~200 English words). Thin product pages at scale are
  usually the single biggest organic drag on a store.
- **Imagery** — SKUs with 0 or 1 image; total page weight of the heaviest
  collection page.
- **Price sanity** — `¥0` / placeholder prices, variants priced above the parent,
  compare-at prices left set from an old sale.
- **Catalog age** — the `published_at` distribution. A single-month spike means a
  migration or a launch; if the store is only a few months old, near-zero organic
  visibility is *expected*, not a defect, and the recommendation set changes
  completely (build the base, don't "recover" rankings).
- **Duplication** — near-identical titles across colorways/sizes that should be
  variants, not separate SKUs (cannibalization at the source).

## The five checks that decide an EC verdict

Run these explicitly; they are where JP stores actually lose money, and each has
burned a real client project:

1. **Measurement** — is there any conversion pixel at all (GA4 alone is not
   enough to run ads), and does the checkout stay on the same domain? An external
   cart severs `gclid`/`fbclid` and makes every paid number a fiction. Verify with
   real network traffic, never a static `grep` for a GTM container ID.
2. **The category layer** — product detail pages are usually fine; the collection
   and category pages are usually broken (404s, no copy, no internal links, sorted
   by nothing). Check the layer between the homepage and the SKU.
3. **Social proof** — review count on-site vs the same brand's marketplace store
   (Rakuten/Amazon/Yahoo). Hundreds of reviews stranded on a mall listing while
   the own-domain store shows zero is a recurring, fixable asymmetry.
4. **Shipping and price truth** — the shipping threshold, and whether price,
   shipping, and subscription terms agree across the product page, the cart, the
   FAQ, and the policy pages. Contradictions here are both a conversion killer and
   a 景表法 / legal exposure.
5. **Content-to-commerce connection** — if the store runs a blog or a magazine,
   count the links from those pages into collections and SKUs. High-traffic
   content that never links to what it sells is the most common untapped asset in
   a JP store.

## Traps

- **Cloudflare / bot challenge** — a bulk crawl that receives 429 or challenge
  pages will make every page look like it has no `<title>` and no description.
  Confirm with a single-page `curl` before reporting a sitewide catastrophe.
- **Mobile URLs and duplicate hosts** — check `m.`, `/sp/`, and locale prefixes;
  ranking pages are often the wrong variant.
- **`product_type` vs tags vs collections** — three overlapping taxonomies. Say
  which one the store *actually* uses, and whether the other two are dead weight.
- **`products.json` is the storefront's view** — unpublished and draft SKUs will
  not appear. Do not report the count as the full inventory.

## Persisting the work

Catalog dumps → `data/catalog/`. The computed taxonomy/content/price tables →
`wiki/` as notes (not just numbers in a chat), one line in `wiki/log.md`, linked
from `wiki/index.md`. The rendered PDF → `reports/`. Same persistence rule as
every Master Brain project.
