---
course: "Setup & Install"
lesson: "🧱 What Claude Code Is (Plain English)"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f579fae5e640447f90c73fb4ee8ed75f
course_slug: 708c1575
module_id: f579fae5e640447f90c73fb4ee8ed75f
---
# 🧱 What Claude Code Is (Plain English)

> **What you'll be able to do:** Explain, in your own words, what Claude Code and a "skill" are, and confirm the three things every install needs so nothing fails halfway.

No jargon. If you've never opened a terminal, you're in the right place.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/c2-claude-code-terminal.gif)

*This is Claude Code. You type, it does the work.*

---

### Claude Code is who you talk to

Claude Code is Claude, running on your computer, that can *do* things: read files, run tools, build stuff. You type a request, it does the work. That's it.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/16b96d7c29a4464db53218e818611efb2b2151c175c847828ddb9bb918a65468.png)

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/8e0289bf7bc84392875be8cac25975493adea6ef5b0f46aa8327abb7889f4628.png)

You'll see it called a "CLI" (command-line tool). Don't let the word scare you. For everything in this Hub, you mostly type plain English and the occasional `/command`.

---

### A "skill" is a tool you add to Claude Code

Out of the box, Claude Code is general. A **skill** (you'll also hear "plugin") teaches it one job really well. Install [**Claude SEO**](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=0e87e1b9a1ea4e0ba7047bf57960939f) and now Claude Code knows how to audit a website. Install [**Claude Blog**](https://www.skool.com/ai-marketing-hub-pro/classroom/b5886e72?md=d36ed305e9dd4826852fe483df73fec8) and it knows how to write a ranked post.

![seo-command-demo.gif](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/0a01b771cce94e30abad822636c61c8038fd1d9717544ab2a701305f14ff21e5.gif)

You install skills once. After that you run them with a **command**, like `/seo` or `/blog`. The command is just the skill's name with a slash.

> Plain-English glossary: **Terminal** = the text window you type into. **Command** = a `/word` you type to run a skill. **Plugin / skill** = a tool you added. **Repo** = the folder on GitHub where a tool lives.

---

### Before you install: 3 things to have ready

Five minutes here saves an hour of "why won't it install."

1. [**Claude Code**](https://claude.com/product/claude-code)**.** You install skills *inside* Claude Code. Check with `claude --version`; update if it's old.
2. [**A GitHub login on your machine.**](https://support.claude.com/en/articles/10167454-use-the-github-integration) The skills live on GitHub. Run `gh auth login` once (GitHub.com → HTTPS → log in via browser).
3. [**Pro org access.**](https://github.com/AI-Marketing-Hub) The Pro skills live in the private `AI-Marketing-Hub` [GitHub org](https://github.com/AI-Marketing-Hub). Your GitHub account has to be a member. **If an install ever returns a 404, that's the signal you're not in the org yet or didn't accept the invite.** DM me your GitHub username in the community and I'll add you.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/608d89de42b74300b2aedb350b0535d2bedaaec1d2004f9aa8d54f1278d7a826-md.png)

---

### Pro vs. public: know which you're installing

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/c2-public-vs-pro.gif)

- [**Pro (you, here):**](https://github.com/orgs/AI-Marketing-Hub/repositories) `AI-Marketing-Hub/<repo>`. Early access, runs ahead of public.
- [**Public (free, MIT):**](https://github.com/AgriciDaniel)[ ](https://github.com/AgriciDaniel)`AgriciDaniel/<repo>`. Stable releases.

> Every command in this course defaults to **Pro**. To use public instead, swap `AI-Marketing-Hub/<repo>` → `AgriciDaniel/<repo>`.

[*Setup & Install*](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=8b9ef028d41544ca86d8d0e41c5fb222) · Next: [🗂️ How Your Setup Is Organized](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f2884ded38ec419e9fa4900a25aea509)
