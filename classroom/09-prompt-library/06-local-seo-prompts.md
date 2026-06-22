---
course: "Prompt Library"
lesson: "📍 Local SEO Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=960a83d8cc594a0ab25890a2d77cd739
course_slug: 2afc71bf
module_id: 960a83d8cc594a0ab25890a2d77cd739
---
# 📍 Local SEO Prompts

> Pair these prompts with `/seo local` and `/seo maps` to audit a Google Business Profile, find NAP gaps, track local-pack rankings on a geo-grid, and generate clean LocalBusiness schema.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-local.gif)

*Audit the profile, fix the NAP gaps, and see where you rank by location.*

---

### Local SEO is three layers

Claude SEO treats local as three things: Google Business Profile signals, NAP (name, address, phone) consistency across citations, and review intelligence. The prompts below hit each layer.

`/seo maps` adds the grid: geo-grid rank tracking, profile auditing, and competitor radius mapping. The difference between "am I ranking" and "where, exactly, am I ranking from." Deep training lives in [🔎 Claude SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f) and [📍 Local SEO Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=22902679826f428295b66ca4141160bd).

---

## Prompts

**Full local SEO audit:**

```text
/seo local https://<yoursite.com>

Context: we're a <business type> serving <city / service area>. Audit our Google Business Profile, NAP consistency across directories, and review profile. Rank the fixes that move us into the map pack first.
```

**Map-pack and geo-grid intelligence:**

```text
/seo maps

Context: <business name> in <city>, primary keyword <keyword>. Run a geo-grid so I can see where in my service area I rank in the local pack versus my top 3 competitors, and tell me which neighborhoods I'm losing.
```

**Find and fix NAP inconsistencies:**

```text
/seo local https://<yoursite.com>

Focus only on NAP consistency. List every directory where my name, address, or phone differs from my Google Business Profile, and give me the exact corrected values to paste into each.
```

**Generate LocalBusiness schema:**

```text
/seo schema https://<yoursite.com>

Generate complete LocalBusiness JSON-LD for a <business type> in <city>. Include geo coordinates, opening hours, and areaServed. Validate it and flag anything Google now ignores.
```

---

- `/seo local <url>` audits the three local layers: GBP, NAP, and reviews.
- `/seo maps` runs a geo-grid so you see ranking by location, not just yes or no.
- Run `/seo local` focused on NAP to clean up citation inconsistencies fast.
- `/seo schema` generates and validates LocalBusiness JSON-LD with geo and hours.
- Deep training: [🔎 Claude SEO](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f) and [📍 Local SEO Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=22902679826f428295b66ca4141160bd).

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [🧠 Research & Brain Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=28cc74b0a0c246208b5df5073fa1f3bf)
