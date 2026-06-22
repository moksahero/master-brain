---
course: "The Codex Suite"
lesson: "📣 Codex Ads"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/ded6ca5c?md=ecd6bcfee18943939341a2821765e076
course_slug: ded6ca5c
module_id: ecd6bcfee18943939341a2821765e076
---
# 📣 Codex Ads

> **What you'll be able to do:** Audit a paid campaign, generate ad creative, and sanity-check attribution from Codex CLI. This is the Hub's ads skill, Codex-native.

> 🎬 **Watch:** [claude-ads: a free Claude Code skill that audits 8 ad platforms](https://youtu.be/qUXSZHiMPK8)

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/anim-real-codex-ads.gif)

### What codex-ads does

codex-ads ports the Hub's paid-advertising skill to Codex. It audits and optimizes across the big platforms: Google, Meta, TikTok, LinkedIn, Microsoft, Apple, Amazon, and YouTube. Plus the cross-cutting work: scored audits, AI ad creative, attribution and server-side tracking, budget math, and landing-page fit.

### Install it

```bash
codex plugin marketplace add AI-Marketing-Hub/codex-ads
codex plugin add codex-ads@ai-marketing-hub-codex-ads
```

### Run it

The pattern matches the Claude Ads course. Run an audit to get a scored read on a campaign, then act on the ranked findings. The audit covers structure, targeting, creative, bidding, and tracking. You don't need every platform. Point it at the one you run.

Audit a single platform:

```text
Audit my Google Ads account structure, targeting, creative, and
conversion tracking. Score it 0-100 and give me the top 5 changes
ranked by expected impact on ROAS.
```

Generate creative variations:

```text
Write 5 Meta ad variations for a B2B SaaS free trial. Mix hooks:
pain-point, social proof, and curiosity. Keep primary text under 125
characters and give a matching headline for each.
```

### Same as the Claude version

Two parts earn their keep fast. Creative generation gets you out of the blank-box stall. Attribution and server-side tracking make your numbers trustworthy, the deep-dive most accounts skip and then wonder why ROAS looks off. Same methodology as Claude Ads. For the platform playbooks and the attribution depth, see the product course.

> Run a codex-ads audit on one platform you spend on. Post your **score** plus the first optimization you'll ship.

- codex-ads is the Hub's ads skill, Codex-native.
- Covers Google, Meta, TikTok, LinkedIn, Microsoft, Apple, Amazon, YouTube.
- Audit returns a score and ranked fixes. Creative and attribution are the high-leverage parts.
- Methodology mirrors Claude Ads.

[*The Codex Suite*](https://www.skool.com/ai-marketing-hub-pro/classroom/ded6ca5c?md=ed1717deecdb4decb7d5bd674c0f030d) · Next: [🗂️ Codex Obsidian](https://www.skool.com/ai-marketing-hub-pro/classroom/ded6ca5c?md=b3390ab294ca4fb18618650563ef5493)

**Repo:** [github.com/AI-Marketing-Hub/codex-ads](https://github.com/AI-Marketing-Hub/codex-ads)
