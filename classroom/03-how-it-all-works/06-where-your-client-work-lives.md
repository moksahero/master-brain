---
course: "How It All Works"
lesson: "🗂️ Where Your Client Work Lives"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/9e6dbe7b?md=9a7bf84bbc6040f0a1b0245fc350c01f
course_slug: 9e6dbe7b
module_id: 9a7bf84bbc6040f0a1b0245fc350c01f
---
# 🗂️ Where Your Client Work Lives

> **What you'll be able to do:** Set up one folder per client the right way, so every skill runs with the right context and no client's work bleeds into another's.

Skills are global, tools live in `~/AI-Marketing-Hub`, and **work lives in one folder per client**.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/c3-clients-drawers.gif)

### One folder per client. **Always**.

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/1f2cf31ad7f5436e9ecc77e5b1492a9529ccfaf137e94de7b9c3b9f1f1740676.png)

```
~/Clients/
  acme-dental/
    .claude/            ← which skills + keys this project uses
    research/           ← Marketing Brain output for this client
    content/            ← drafts the Blog skill writes
    audits/             ← SEO audit reports
    notes.md            ← your running notes
```

You **open **`**acme-dental**`** in **[**Claude Code**](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f579fae5e640447f90c73fb4ee8ed75f) and work inside it. Every `/seo`, `/blog`, `/ads` you run reads and writes *here*. Acme's audit never lands in Bob's folder.

---

### Why a `.claude/` folder per client helps

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/487969a2361b45138b48c06c3c855e65761f864e9b9d4ee4b2fe34658649fa7f.png)

Dropping a `.claude/settings.json` in a client folder (the one-file install from Course 2) means that client opens with exactly the skills it needs, already enabled. Open the folder, everything's ready. Hand the same folder to a teammate and they get the same setup.

---

### How the Brains connect to a client folder

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/0035503310904fe49087831c8d9be48d301e78cd6f134233997f5a001dd3cfc9.png)

The Brains live in `~/AI-Marketing-Hub` (shared across clients, like reference books). When you work a client, you tell Claude to **read** the relevant Brain and **write** results into the client folder. The Brain is the library; the client folder is the desk.

---

### The habit that keeps you sane

- New client? Make the folder first. `~/Clients/<name>`.
- Run everything from inside it.
- Keep keys in that folder's `.env`, never in the chat.
- Done with a client? The whole engagement is one folder you can archive or hand off.

> We use exactly this in the next course, [The Client Delivery Flow](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=89d92e3fde4e4320acdfd6f9c1bbb583), where the folder fills up step by step.

---

- One folder per client. Open it, run everything inside it.
- A `.claude/settings.json` per client = the right skills, ready on open.
- Brains are the shared library in `~/AI-Marketing-Hub`; the client folder is the desk you write to.

[*How It All Works Together*](https://www.skool.com/ai-marketing-hub-pro/classroom/9e6dbe7b?md=9d7945f4c70541c796e25a61d9e6d561) · Next course: [🎯 The Client Delivery Flow](https://www.skool.com/ai-marketing-hub-pro/classroom/d2605b58?md=89d92e3fde4e4320acdfd6f9c1bbb583)
