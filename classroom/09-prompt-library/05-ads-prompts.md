---
course: "Prompt Library"
lesson: "📣 Ads Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=fce03d6168734b18b8c7c2ba626a651b
course_slug: 2afc71bf
module_id: fce03d6168734b18b8c7c2ba626a651b
---
# 📣 Ads Prompts

> Pair these prompts with `/ads` to run a multi-platform audit, build a plan, sanity-check the financials, and design a clean A/B test.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-ads.gif)

*Audit, plan, run the math, and test with your real budget in mind.*

---

### Always tell it your budget

Benchmarks for a $500/month account and a $50k/month account are different worlds. State your spend, your platform, and your business up front and every `/ads` answer gets more useful.

`/ads audit` runs specialist agents across platforms in parallel and returns a 0 to 100 score with ranked fixes. The `/ads plan`, `/ads math`, and `/ads test` prompts turn that into action. Deep training lives in [📣 Claude Ads](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=166ec4ea11f343648e30d0c3d471245c).

---

## Prompts

**Multi-platform audit with budget context:**

```text
/ads audit

Context: we spend <$X/month> across <platforms, e.g. Google + Meta> for a <business type>. Our target is <CPA / ROAS goal>. Give me the score, the top 3 critical findings, and the fixes ranked by revenue impact.
```

**Single-platform deep dive (swap the platform):**

```text
/ads google

Context: <$X/month> on Google Ads for <business>. Look past the UI surface. Flag broken conversion goals, budget starvation, and wasted spend. Tell me the three changes that move CPA most.
```

**Strategic plan for a business type:**

```text
/ads plan <saas | ecommerce | local | b2b>

Context: we sell <product> to <audience> with a <$X/month> budget. Build a channel mix, a starting budget split, the campaign structure, and the first three tests to run.
```

**Run the PPC math:**

```text
/ads math

We have a CPC of <$X>, a conversion rate of <Y%>, an average order value of <$Z>, and a margin of <M%>. Calculate break-even CPA, target ROAS, and how much budget I can profitably spend per month.
```

**Design a clean A/B test:**

```text
/ads test

I want to test <variable, e.g. headline A vs B> on <platform>. Give me the hypothesis, the sample size and runtime I need for significance, and the one metric that decides the winner.
```

---

- Lead every `/ads` prompt with budget, platform, and business. It changes the benchmarks.
- `/ads audit` returns a score and revenue-ranked fixes. Swap in `/ads google`, `/ads meta`, and others for one platform.
- `/ads plan <type>` builds a channel mix and test roadmap from zero.
- `/ads math` and `/ads test` keep decisions grounded in numbers, not hunches.
- Deep training: [📣 Claude Ads](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=166ec4ea11f343648e30d0c3d471245c).

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [📍 Local SEO Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=960a83d8cc594a0ab25890a2d77cd739)
