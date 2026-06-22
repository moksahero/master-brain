---
course: "Prompt Library"
lesson: "🎯 Client & Agency Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=5aaf0d0bb6364e8383f3f5b62d6ba65c
course_slug: 2afc71bf
module_id: 5aaf0d0bb6364e8383f3f5b62d6ba65c
---
# 🎯 Client & Agency Prompts

> Run one prompt for each step of the client flow and generate the deliverables that run an agency: a scoped plan, an audit-anchored proposal, a draft brief, a QA check, and a monthly report a client reads to the end.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-client.gif)

*One prompt per step, from a scoped plan to a report a CEO forwards.*

---

### One prompt per step of the flow

You already learned the five-step flow: **Plan → Analyze → Draft → Edit → Improve**, then loop. These prompts slot into the steps. Anchor everything in real tool output. A proposal that opens with "your score is 61 and here are the three things costing you traffic" closes better than any pitch deck. The flow itself lives in [The Client Delivery Flow](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=89d92e3fde4e4320acdfd6f9c1bbb583).

---

## Prompts

**Plan: scope the client:**

```text
Client: <company> in <industry>. They sell <product> to <audience>.

Help me scope this engagement. Give me: the one outcome that counts as a win in 90 days,
the 3 to 5 questions I must ask before I start, the access I need to request, and a one-line
definition of done. Keep it to half a page I can paste into the client folder notes.
```

**Analyze: turn an audit into a 30-day plan:**

```text
I ran the audit and got: score <X/100>, top findings <paste 3 findings>.
Here's the research opportunity: <paste keyword/competitor highlights or "none yet">.

Merge these into one prioritized 30-day plan for <client>: the fix-first list (broken things,
ranked by impact to effort), the pages or campaigns to build, and what to measure. Lead with
the fix-first list. This is what I'll present in the kickoff.
```

**Proposal from a real audit:**

```text
I ran an audit and got: score <X/100>, top findings <paste 3 findings>.

Write a one-page proposal for a <business type>. Open with the audit reality, scope the
engagement to fix the top findings, lay out a 90-day plan with milestones, and a clear monthly
price. Confident, no jargon, no overpromising.
```

**Draft: brief the deliverable:**

```text
Deliverable: <e.g. 3 blog posts / a Google Ads restructure / 5 local pages>.
Client win it serves: <the 90-day outcome>. Voice: <how the client sounds>.

Write the brief I'll hand to /blog write or /ads: the exact topics or campaign structure,
the target keyword or audience for each, the angle, and the one success metric per piece.
```

**Edit: QA before it ships:**

```text
Here's the deliverable: <paste draft or path>.

QA it on five checks and tell me what fails: (1) True, every stat and claim is real and
sourced. (2) On-brand, sounds like <client>, no hype or filler. (3) On-target, serves the
90-day win, not just word count. (4) Technically clean, links work and schema is valid.
(5) Reads well start to finish. List every issue with the exact line to fix. Nothing ships unread.
```

**Improve: the monthly client report:**

```text
This month I shipped: <list audits, posts, campaigns, fixes>.
Results: <metrics, e.g. rankings, traffic, leads, ROAS>. Baseline from month one: <paste>.

Write the monthly report for <client>. Structure: what we did, what it moved, what it means
for your business, what we're doing next month. Plain English a CEO can forward. Lead with the
single number that maps to their 90-day win. The "next month" section is next month's scope.
```

**Cold email that books a call:**

```text
Prospect: <company> in <industry>. I noticed <specific observation about their site/ads>.

Write a 90-word cold email. Lead with the specific observation, name one concrete result we'd
target, and end with a low-friction ask for a 15-minute call. No flattery, no "I hope this finds you well."
```

**Win-back email for a quiet client:**

```text
Client <name> has gone quiet. Last win we delivered: <result>. Current opportunity: <what you'd do next>.

Write a short, warm re-engagement email that reminds them of the last win and proposes one
specific next move. End with a single yes or no question.
```

---

- One prompt per step: Plan, Analyze, Draft, Edit, Improve. Same loop, every client.
- Run the audit first. Feed its score and findings into the proposal and the 30-day plan.
- The Edit prompt is the five-box QA. Nothing ships unread.
- The monthly report frames activity as outcomes a CEO will forward, and the "next month" section becomes the next Plan.
- Deliver reports as PDF via `/ads report` or the `/seo google` reporting flow.

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [🗂️  ](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=4b7733cecac1418487fb780f9944b0f9)[**🛠️ Build Your Own Prompt**](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=493b2066c6c54f7b8a6f506754ad845a)
