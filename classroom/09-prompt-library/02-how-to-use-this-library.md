---
course: "Prompt Library"
lesson: "📖 How to Use This Library"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=9a88b338c3bc41fd8d03f0026480c5df
course_slug: 2afc71bf
module_id: 9a88b338c3bc41fd8d03f0026480c5df
---
# 📖 How to Use This Library

> **What you'll be able to do:** Read any prompt in this course and run it right the first time. You'll know how the bracket pattern works, when to keep a slash command, and the three context lines that lift every prompt.

*Copy the prompt, swap the brackets, add three context lines, and run.*

This whole course is copy-paste. The only thing you ever change is the text inside `<angle brackets>`. Find your job, copy the prompt, fill the blanks, run it.

### The bracket pattern

Every prompt has placeholders that look like `<your site>` or `<topic>`. Delete the brackets and type your real value. Never leave a bracket in. Claude will treat `< >` as a literal instruction and stop to ask you what it means.

---

Quick rule: if you see `< >`, that part is your job.

This:

```text
Write a comparison page for <my product> vs <competitor> aimed at <buyer type>.
```

Becomes:

```text
Write a comparison page for Acme CRM vs HubSpot aimed at small agency owners.
```

---

### Slash command vs plain prompt

Some prompts start with a slash command like `/seo` or `/blog`. That command routes your request to the right tool. Keep it.

Other prompts are plain English with no slash. Those run in any Claude session. If a plain prompt has no slash, you can still run it inside a product (like `/blog`) to give it that product's context.

---

### The three context lines

Before almost any prompt, three lines lift the output. Add them at the top:

```text
Business: <what you sell and to whom>
Goal: <the one outcome you want from this>
Voice: <how it should sound, e.g. plain, expert, friendly>
```

Generic prompt in, generic answer out. The model can't read your mind. These three lines are how you hand it the brief.

---

- Replace everything in `<angle brackets>` with your real values. Never leave a bracket in.
- Keep the slash command if a prompt has one. It routes to the right tool.
- Add Business / Goal / Voice context lines to lift every prompt.
- These are starting points. Lesson 10 teaches you to build your own.

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [🔎 SEO Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=1076bae928754c1d9fd107576cd6bad9)
