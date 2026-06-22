---
course: "Client Delivery"
lesson: "🔍 Analyze: Audit & Research"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=ef7b3728d32244f39f2da0b260b51dc7
course_slug: d2605b58
module_id: ef7b3728d32244f39f2da0b260b51dc7
---
# 🔍 Analyze: Audit & Research

> Turn "I have a client" into "I know exactly what's broken and what to go after," with receipts.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-cf-analyze.gif)

*Ask what's broken and Claude pulls the audit, the research, and one prioritized plan.*

---

## Half 1: Audit what's there

From inside the client folder:

```text
/seo audit <client-url>
```

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/470654b97b504baaad49a13508059bfbbf590f201d04448e82c88dbcc984b156.png)

You get a baseline scorecard: technical health, content, schema, the lot. Save it to `audits/`. If the site feels broken or unindexed, go deeper with `/seo technical <url>`.

**Why first:** you can't show improvement without a baseline. The audit is your before photo.

---

## Half 2: Research the opportunity

This is the [**Marketing Brain**](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=888db513f2b24f4d85320fe80ee88bbb) step. Run its research pipeline for the client's niche + geo to get the demand, the competitors, and the keyword map.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/2bad2f76a5a4433fb43885a516190dcc8688f9d2b05145c8b71f633fa68236bb-md.png)

```text
Read my Marketing Brain. Run the research pipeline for <client niche> in <city>.
Give me the keyword + competitor map and the top 5 opportunities, saved to research/.
```

Local client? Add the [**Local SEO Brain**](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=22902679826f428295b66ca4141160bd) layer (see [Using the Brains Together](https://www.skool.com/ai-marketing-hub-pro/classroom/9e6dbe7b?md=2dd5aee9e531477881de4712acc3595d)).

---

## Turn it into a plan

Now you have two documents: what's broken (audit) and what's worth doing (research). Ask Claude to merge them:

```text
Using audits/<file> and research/<file>, give me a prioritized 30-day action plan
for <client>: fix-first list, pages to write, and what to measure.
```

**You're done when:** `audits/` and `research/` are populated and you have a prioritized plan.

> 💡 Lead with the fix-first list in your kickoff. Clients trust you when you show them what's broken before you pitch what's next.

> ✅ Run an audit on one site and post your top fix-first item. That single finding is often enough to close a client.

- Audit first (`/seo audit`) for the baseline before photo. Save to `audits/`.
- Research with Marketing Brain for the opportunity map. Save to `research/`.
- Merge both into one prioritized 30-day plan.

[*The Client Delivery Flow*](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=89d92e3fde4e4320acdfd6f9c1bbb583) · Next: [✍️ Draft: Content & Ads](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=6853a7b87a1a4d1e9fb5a2bc93f16384)
