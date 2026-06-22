---
course: "Prompt Library"
lesson: "🎬 Video & Content Prompts"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=6d0449c86fa540f3a3b6403a1b9eab57
course_slug: 2afc71bf
module_id: 6d0449c86fa540f3a3b6403a1b9eab57
---
# 🎬 Video & Content Prompts

> Package a video idea before you script it, write a scroll-stopping hook, draft a tight script, turn one long video into a batch of shorts, and generate or edit on-brand images.

![](https://cdn.jsdelivr.net/gh/AI-Marketing-Hub/classroom-assets@cfc5a1e99148d256bff96912f16ee28322523f56/chat-pl-video.gif)

*Package the title first, then hook, script, shorts, and on-brand images.*

---

### Packaging before script

Walt's core rule: packaging before script, style before production. The title and thumbnail decide whether anyone watches, so you write those first and let them shape the script. Not the other way around. The full pipeline lives in [🎬 Walt](https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=38534fb5dcd445b694fc3966c20c5392).

A winning long video is raw material for a week of shorts. These prompts run in any Claude session. Pair them with the Walt vault for performance-aware output.

---

## Prompts

**Package the idea (titles + thumbnail before anything else):**

```text
Video idea: <one-line idea>. Audience: <who>. Channel niche: <niche>.

Following "packaging before script": give me 8 title options ranked by curiosity without clickbait, plus a thumbnail concept (subject, text overlay of 3 words max, emotion) for the top 3 titles.
```

**Write the hook (first 15 seconds):**

```text
Video title: <chosen title>. Promise: <what the viewer gets>.

Write three opening-hook options for the first 15 seconds. Each must restate the promise, open a curiosity loop, and earn the next 10 seconds. No "hey guys, welcome back."
```

**Draft a retention-aware script:**

```text
Title: <title>. Hook: <chosen hook>. Length target: <minutes>.

Write a script that delivers the promise in clear beats, reopens a curiosity loop every 60 to 90 seconds, and ends with one specific call to action. Mark where a pattern interrupt or B-roll should go.
```

**Turn one long video into shorts:**

```text
Here's the transcript of my long video:

<paste transcript or timestamps of the best moments>

Find the <N> highest-retention standalone moments. For each, give me a 30 to 60 second short with its own hook, a vertical caption plan, and a title for that platform.
```

### On-brand images with `/banana`

`/banana` is a creative-director skill. It rewards a brief, not a keyword dump. Name the subject, the style, the lighting, the framing, and the aspect ratio. Use `/banana generate` for new images and `/banana edit` to change an existing one without rerolling.

**Generate a product shot:**

```text
/banana generate

A studio product shot of <product>, on a <clean / textured> background, soft top-down lighting, subtle shadow, centered, lots of negative space for text. Square 1:1, photorealistic, premium feel.
```

**Generate ad creative with a message:**

```text
/banana generate

Scroll-stopping ad image for <product> aimed at <audience>. Show <the benefit, visually>. Bold but on-brand: <brand colors>. Leave the top third clear for a headline. Vertical 4:5 for feed.
```

**Edit an existing image (change one thing):**

```text
/banana edit <path-to-image>

Keep everything the same but <the one change, e.g. swap the background to a warm sunset, remove the text, change the shirt to navy>. Match the existing lighting and style.
```

---

- Package first: write titles and thumbnails before the script (Walt's rule).
- The hook prompt kills "hey guys" intros and earns the next 10 seconds.
- The script prompt builds in curiosity loops and one clear CTA.
- The repurpose prompt mines one long video for a batch of shorts.
- `/banana generate` rewards a creative brief. `/banana edit` changes one thing and keeps the rest.

[*Prompt Library & Cheat Sheets*](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=cda1296bf09b45969c19d8ee99617010) · Next: [🎯 Client & Agency Prompts](https://www.skool.com/ai-marketing-hub-pro/classroom/2afc71bf?md=5aaf0d0bb6364e8383f3f5b62d6ba65c)
