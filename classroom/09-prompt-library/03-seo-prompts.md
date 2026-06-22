---
course: "Prompt Library"
lesson: "🔎 SEO Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=1076bae928754c1d9fd107576cd6bad9
course_slug: 2afc71bf
module_id: 1076bae928754c1d9fd107576cd6bad9
---
# 🔎 SEO Prompts

> Pair these prompts with `/seo` to audit a site, deep-dive one page, fix schema, prep for AI search, and plan keyword clusters. Each one returns a ranked fix list, not a wall of data.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-seo.gif)

*Every prompt hands back a ranked fix list, not a wall of data.*

---

### The pattern: command + URL + context

Most `/seo` prompts are a command, a URL, and one line of context. Tell Claude your business type and your goal and the benchmarks get sharper.

Start broad with the audit. It gives you the priority order. The single-page and schema prompts fix what it flags. Deep training lives in [🔎 Claude SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f).

---

## Prompts

**Full-site audit with context (your most-used prompt):**

```text
/seo audit https://<yoursite.com>

Context: we're a <business type> selling <product> to <audience>. Our biggest goal this quarter is <goal>. Give me the score, the top 3 critical findings, and a ranked fix list I can hand to a non-technical teammate.
```

**Single-page deep dive:**

```text
/seo page https://<yoursite.com>/<important-page>

Tell me the on-page issues, content-quality gaps, and missing schema for this exact page. Rank fixes by impact to effort so I know what to do first.
```

**Schema detect, validate, and generate:**

```text
/seo schema https://<yoursite.com>/<page>

Show me what structured data exists, what's broken or deprecated, and generate the JSON-LD I should add. Skip any schema type Google no longer rewards.
```

**Get cited by AI (GEO):**

```text
/seo geo https://<yoursite.com>/<page>

Audit this page for AI-search citability across ChatGPT, Perplexity, and Google AI Overviews. Tell me exactly what to add so an AI quotes this page as a source.
```

**Keyword and topic clusters:**

```text
/seo cluster <seed keyword>

Build a hub-and-spoke topic cluster around this seed. Give me the pillar page plus 6 to 10 supporting articles, each with a target keyword and the search intent behind it.
```

---

- `/seo audit <url>` is the workhorse. Always add a context line for sharper benchmarks.
- `/seo page` and `/seo schema` fix what the audit flags, page by page.
- `/seo geo` preps a page to get cited by AI search, not only ranked.
- `/seo cluster <keyword>` turns one keyword into a full content plan.
- Deep training: [🔎 Claude SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f).

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [✍️ Blog Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=da4f8949abcc49f6bce4a47dc7f4c501)
