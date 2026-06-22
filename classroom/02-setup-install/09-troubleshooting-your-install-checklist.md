---
course: "Setup & Install"
lesson: "🩹 Troubleshooting & Your Install Checklist"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=a3599aec7f5c49bf886cf2266a7fd7ca
course_slug: 708c1575
module_id: a3599aec7f5c49bf886cf2266a7fd7ca
---
# 🩹 Troubleshooting & Your Install Checklist

> **What you'll be able to do:** Fix the five things that go wrong before you have to ask, and confirm your setup is complete.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-setup-troubleshoot.gif)

*Ask how to fix a broken install, get the five common fixes.*

Ninety percent of install problems are one of these five. Match your symptom, apply the fix.

---

### 1. `marketplace add` returns a 404

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/8a5c4a24304a4e17ba2825289d1ed6e312e8f36ee2ca461ab0bcd681e71fe135-md.png)

**Cause:** your GitHub account isn't in the private `AI-Marketing-Hub` org. **Fix:** confirm you're authed (`gh auth status`), then [**DM me **](https://www.skool.com/@daniel-agrici-3925?g=ai-marketing-hub-pro)**your GitHub username** to get added. Or use the public repo: `AI-Marketing-Hub/<repo>` → `AgriciDaniel/<repo>`.

---

### 2. "Not authenticated" / permission denied

**Cause:** no GitHub login on the CLI. **Fix:** run `gh auth login` (GitHub.com → HTTPS → browser), then re-run the install.

---

### 3. The plugin installed but its command doesn't show

**Cause:** [Claude Code](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=f579fae5e640447f90c73fb4ee8ed75f) needs a refresh, or you're on an old version. **Fix:** restart Claude Code; run `/plugin` to confirm it's **enabled** (not just installed); check `claude --version` is **1.0.33+**.

---

### 4. The install slug is rejected

**Cause:** a typo, or a docs/catalog name mismatch. **Fix:** add the marketplace, then run `/plugin` and **pick the skill from the list**. Claude Code uses the correct name automatically. Never hand-type the slug when the list is right there.

---

### 5. The skill loads but an API / MCP feature fails

**Cause:** a required key isn't configured (e.g. [DataForSEO](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=af828c1dd05c40aeb37ff7fe01730f13)). **Fix:** check the skill's README for required keys, add them to your local `.env`, restart. Keys stay local. Never share them.

> Still stuck? Post: the **exact command**, the **exact error**, your **OS**, and `claude --version`. That's everything we need to help in one reply.

---

## ✅ Your install checklist

Tick these and you're fully set up:

- `claude --version` is 1.0.33+
- `gh auth status` shows you logged in
- You can add a marketplace without a 404 (you're in the org)
- Your path's skill is installed and its `/command` responds
- Two folders exist: `~/AI-Marketing-Hub` (tools) and `~/Clients` (work)
- (If needed) one Brain or OS app cloned and opening

✅ Post your checklist with ✅/❌ on each line. Any ❌ gets a fast reply from the room.

---

- 404 = not in the org → DM your GitHub username.
- Command missing = restart + check version + enable in `/plugin`.
- Slug rejected = pick it from the `/plugin` list.
- Finish the checklist and you're ready for the rest of the path.

[*Setup & Install*](https://www.skool.com/ai-marketing-hub-pro/classroom/708c1575?md=8b9ef028d41544ca86d8d0e41c5fb222) · Next course: [🧭 How It All Works Together](https://www.skool.com/ai-marketing-hub-pro/classroom/9e6dbe7b?md=9d7945f4c70541c796e25a61d9e6d561)
