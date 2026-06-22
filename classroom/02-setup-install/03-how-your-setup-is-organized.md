---
course: "Setup & Install"
lesson: "🗂️ How Your Setup Is Organized"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f2884ded38ec419e9fa4900a25aea509
course_slug: 708c1575
module_id: f2884ded38ec419e9fa4900a25aea509
---
# 🗂️ How Your Setup Is Organized

> Picture where everything lives on your machine: the skills, the brains, and each client's work. Members asked for this. It's the thing that makes the whole system click.

The tools stop feeling like magic the moment you can see where they live.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/c2-setup-drawers.gif)

### Think of it as three drawers

**The skills (installed once, used everywhere)** When you install a skill, [Claude Code](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f579fae5e640447f90c73fb4ee8ed75f) stores it in a hidden settings folder in your home directory (`~/.claude/`). You never have to open it. It just means: install a skill once, and the `/command` works in *any* folder you open. Skills are global.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/cbba766828184d2cabb09ffb7e785c1fde8b53a8388b4410ab51dec13d662f4c.png)

---

**The brains and apps (folders you clone)** The Brains (Marketing, Local SEO, Ads) and the OS apps ([SEO OS](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=3562bd77965742c7811d4c22c9063f01), [Marketing OS](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=65ec0298ab304a1c99d0319c28677ed5)) aren't plugins. They're folders you download ("clone") to a spot you choose. A tidy habit:

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/507213a2039c4af5b54153922d005828c3ba9f0d1bb44b3c89e8942d009b0b81.png)

```
~/AI-Marketing-Hub/
  marketing-brain/
  local-seo-brain/
  website-brain/
```

Keep them together so you always know where they are.

---

**Your client work (one folder per project)** This is the important one. **Each client gets its own folder.** You open that folder in Claude Code, and you run your skills *inside it*. The work, the notes, the outputs all stay in that one place.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/f06e1dafcd45410ea4a822bc43b7ab9f72c01ab562a042aca6812c639ab101eb.png)

```
~/Clients/
  acme-dental/
  bobs-plumbing/
  my-own-site/
```

---

### Why this matters

- **Skills are global. Work is local.** One install, used across every client folder. Each client's files stay separated and clean.
- **Nothing leaks between clients.** Acme's audit stays in Acme's folder.
- **You always know where to look.** Skills in `~/.claude`, tools in `~/AI-Marketing-Hub`, work in `~/Clients`.

> 🔑 API keys live in a `.env` file *inside* the tool's folder, on your machine. They never get posted or committed. We cover keys when a skill needs one.

We'll set up your first client folder properly in [the Client Delivery Flow](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=2abf11ca84a544be8975308e11cab8b4).

---

- Make two folders today: `~/AI-Marketing-Hub` (for tools) and `~/Clients` (for work).
- Skills are global; you install once and use everywhere.
- One folder per client keeps work separated and findable.

[*Setup & Install*](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=8b9ef028d41544ca86d8d0e41c5fb222) · Next: [🔌 Install Your First Skill](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=c4ccd34fe8754432a44496f89985917e)
