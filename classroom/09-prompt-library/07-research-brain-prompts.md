---
course: "Prompt Library"
lesson: "🧠 Research & Brain Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=28cc74b0a0c246208b5df5073fa1f3bf
course_slug: 2afc71bf
module_id: 28cc74b0a0c246208b5df5073fa1f3bf
---
# 🧠 Research & Brain Prompts

> Run research prompts that turn raw inputs into a plan you can act on the same day. And run the full prompt members keep asking for: how to make the Marketing Brain and [Local SEO Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=22902679826f428295b66ca4141160bd) work on the same client without stepping on each other.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-research.gif)

*Turn competitor and customer inputs into one plan you can act on today.*

---

### Research is advisory, so make it decide

The Marketing Brain researches and recommends. It never touches your live accounts. So end every research prompt with a decision: not "tell me about X," but "tell me what to *do* about X."

Research quality follows input quality. Paste a competitor URL, a real review, or a transcript and the output stops being generic. The full system lives in [🧠 Marketing Brain](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=888db513f2b24f4d85320fe80ee88bbb).

---

## Prompts

**Competitor teardown:**

```text
Analyze this competitor: <competitor URL>.

Break down their positioning, who they target, their core offer and pricing logic, and the three things they do better than us. Then give me two specific angles where we can win that they've left open.
```

**Mine the voice of the customer:**

```text
Here are real customer reviews / support messages / call notes:

<paste 5 to 15 raw quotes>

Pull out the exact phrases customers use for their problem and their desired outcome. Group them by theme, and give me the five phrases I should put in my headlines and ads word-for-word.
```

**Build a keyword workbook:**

```text
Build a keyword workbook for a <business type> selling <product> to <audience>.

Group keywords by buying stage (problem-aware, solution-aware, ready-to-buy). For each group give me 5 to 8 keywords, the intent, and the page type that should target it.
```

**Find the positioning angle:**

```text
Business: <what we sell and to whom>. Top competitors: <list>.

Find the single positioning angle we can own: the thing that's true for us, valued by buyers, and not already claimed by a competitor. Give me the one-sentence positioning statement and three proof points.
```

### Merge the Brains (the one members keep asking for)

Marketing Brain finds *what to go after*. Local SEO Brain tells you *how to win it locally*. No overlap. A relay. The order is the whole trick: research first, local plan second, execution last.

Both Brains live in your `~/AI-Marketing-Hub` folder. The client's work lives in its own folder. You point [Claude Code](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f579fae5e640447f90c73fb4ee8ed75f) at the client folder, then run this prompt to bridge both vaults into one action plan.

**The full "merge the Marketing Brain + Local SEO Brain" prompt:**

```text
You have two vaults available in ~/AI-Marketing-Hub:
1. Marketing Brain (research + strategy: keyword map, competitor map, demand)
2. Local SEO Brain (local execution: Google Business Profile, citations/NAP, local content, maps)

Client: <client name>. Location: <city / service area>. Niche: <what they do>.

Step 1 (read Marketing Brain): Pull the existing strategy for <client>: the keyword + competitor
map and the priority targets. If no strategy exists yet, say so and stop.

Step 2 (read Local SEO Brain): Pull the relevant chapters on Google Business Profile,
citations and NAP consistency, and local content/pages.

Step 3 (merge into one plan): Produce ONE local SEO action plan for <client> in <city>:
- What to fix first (ranked by impact to effort)
- The exact Google Business Profile changes
- The citations to build or correct (with the corrected NAP values)
- 3 local pages to write, each with a target keyword and the intent

Rules: do not invent data. Cite which vault each recommendation came from. Keep it to one page
a non-technical client could read. End with the first three actions for this week.
```

After the plan exists, your skills do the work: `/seo local`, `/seo maps`, and `/blog write` read from both vaults and execute the tasks. The order and the why are covered in [Using the Brains Together](https://www.skool.com/ai-marketing-hub-pro/classroom/9e6dbe7b?md=2dd5aee9e531477881de4712acc3595d).

**Add **[**Ads Brain**](https://www.skool.com/ai-marketing-hub-pro/classroom/c1d53bcf?md=9166b414941a45cb851448ef0c5ee7ac)** on top (once pages are ranking):**

```text
Read the local SEO plan for <client> and identify the pages now ranking and converting.

Using my Ads Brain strategy patterns, tell me which of those winning pages to amplify with paid:
the platform, the campaign type, a starting budget, and the first test. Organic strategy first,
paid amplification only on proven winners.
```

---

- End every research prompt with a decision, not "tell me about it."
- Voice-of-customer mining beats invented copy. Feed it real quotes.
- Merge the Brains in one direction: Marketing Brain research, then Local SEO Brain plan, then skills execute.
- The merge prompt reads both vaults and returns one client-ready plan, with each recommendation citing its source vault.
- Add Ads Brain last, only on pages that already rank and convert.

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [🎬 Video & Content Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=6d0449c86fa540f3a3b6403a1b9eab57)
