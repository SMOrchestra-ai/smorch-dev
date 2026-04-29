# Instructions — English AI Claude Content Workflow

This is the permanent workflow for producing LinkedIn posts from YouTube content. Follow every step in order. Do not stop between steps to ask for confirmation. Just execute.

---

## Trigger

User says "Brand Start" and gives a transcript (VTT, SRT, plain text, or PDF). The input is always a transcript. Never a YouTube link or video.
That is the trigger. Execute all steps without stopping or asking.

---

## Step 1 — Load founder context

Read `mamoun-founder.md` before anything else. This file contains voice rules, decision framework, and hard constraints. Follow every rule without exception.

Key constraints to internalize:
- No em dashes (use commas, periods, or line breaks instead)
- No filler words, no fluff, no hashtags, no emojis
- First person, founder-to-founder tone
- Contrarian and opinionated, always take a clear stance
- Specific numbers over vague claims
- MENA-focused when content allows
- Max 3000 characters per post

---

## Step 2 — Load good lookalikes

Open `good-lookalikes/` and read every file: all PDFs and all images (JPGs, GIFs).

Study carefully:
- Colors: black backgrounds, orange (#FF6600) headlines, white body text
- Typography: bold sans-serif for headlines, clean medium weight for body
- Layout: MA logo top-left, text upper portion, 3D renders lower portion
- Visual style: metallic/industrial 3D renders with orange accent lighting, NOT stock photos, NOT generic AI illustrations
- Carousel format: 1080x1350px per slide, orange-bordered cards for lists, orange chevron badges for numbered items
- Infographic format: gauge meters, data visualization with orange/white palette
- Single visual format: one strong 3D metallic render centered

This is the only visual reference. Nothing else. Every Gemini prompt must replicate this exact design system.

---

## Step 3 — Load approved templates

Read `templates/template-approved.md`. This contains the 3 approved reference posts and the extracted style rules. Every new post must match or exceed this quality level.

Use the templates to calibrate:
- Hook style and length
- Section structure (1/, 2/, 3/ format)
- Level of specificity (real tools, real numbers, real outcomes)
- CTA format ("DM me [KEYWORD]")
- P.S. engagement question format

---

## Step 4 — Process transcript

The input is always a transcript (VTT, SRT, plain text, or PDF). Never a YouTube link or video.

- Read the full transcript content carefully
- If content is very long: chunk it into sections, process each section, then synthesize the key themes across all sections
- Do not summarize too early — extract every insight, number, framework, and story first
- Never skip content because it is too long — process everything
- Strip timestamps if present, keep only the text content

---

## Step 5 — Identify 3 angles

Analyze the transcript and identify the 3 strongest angles for LinkedIn posts about AI and Claude. Each angle must be distinct:

Decision framework:
- Angle 1: Broad feature showcase or system overview (carousel format)
- Angle 2: Deep dive on one specific feature or concept (single visual format)
- Angle 3: Contrarian process reveal or mindset shift (infographic format)

Every angle must pass this test: "Would a MENA founder running a small team stop scrolling for this?"

---

## Step 6 — Write 3 English posts

Write each post following this exact structure:

1. **Hook** (1-2 lines): Contrarian take, surprising stat, or bold claim. Stop the scroll.
2. **Context bridge** (2-3 lines): Set up the problem. Show the gap between what most people do and the better way.
3. **Numbered breakdown** (3-5 sections using 1/, 2/, 3/ format): Each section gets a bold sub-header + 2-4 short lines. Use → for sub-lists (not dashes or dots).
4. **Closing punch** (1-2 lines): Gap statement or mindset shift that ties back to the hook.
5. **DM CTA**: "DM me [KEYWORD]" with specific value offered.
6. **P.S. question**: Engagement hook that invites comments.

Voice rules:
- First person, founder-to-founder
- Short paragraphs (1-3 lines max)
- Specific: real numbers, real tools, real outcomes
- No em dashes, no hashtags, no emojis, no filler
- Under 3000 characters per post
- Every post must have a contrarian angle

---

## Step 7 — Anti-gimmick check

Before finalizing each post, run these checks:

1. Does it sound like Mamoun wrote it? (compare against templates/template-approved.md)
2. Does it match the approved templates in structure, tone, and length?
3. Is it specific? Real numbers, real tools, real outcomes — not vague claims.
4. Could anyone else have written this? If yes, rewrite.
5. Does it sound like guru content or hype? If yes, kill it.
6. Any em dashes? Remove them.
7. Any hashtags or emojis? Remove them.
8. Over 3000 characters? Tighten it.

---

## Step 8 — Generate Gemini image prompts

For each post, decide the visual format based on the content:

**Decision rules (decide yourself, never ask):**
- Post has steps or a process → Carousel (10 slides, 1080x1350px each)
- Post has numbers, stats, or comparisons → Infographic
- Post has one strong insight or concept → Single visual

**Gemini prompt requirements:**
- Open with the exact format and dimensions
- Describe the full design system from good-lookalikes: black background, orange (#FF6600) headlines, white body text, MA logo top-left, 3D metallic/industrial renders
- Break down each slide or section with specific text, layout, and image descriptions
- End with: "Do not use stock photo style. Do not use generic AI illustration style. Match this exact design system."
- Include specific 3D render descriptions: metallic surfaces, industrial aesthetic, orange accent lighting, volumetric lighting, photorealistic
- Always include: "Add Mamoun Alamouri logo (MA orange circle on black) to top-left corner"

**Branding rules (apply to every visual):**
- Add assets/mamoun-logo.png to the top-left corner of every visual
- For carousels: the last slide must always be assets/last-slide-english.png — import the exact file, never redesign or recreate it

---

## Step 9 — Save to folder structure

Create this folder structure:

```
English-AI-Claude/
  posts-[YYYY-MM-DD]/
    INDEX.md       (session manifest — see Step 9b)
    post-1/
      post.md      (full LinkedIn post text)
      prompt.md    (Gemini image prompt)
      score.md     (quality gate score table)
    post-2/
      post.md
      prompt.md
      score.md
    post-3/
      post.md
      prompt.md
      score.md
```

Date format: `posts-2026-04-08` (ISO date of creation).

### Step 9b — Create INDEX.md

Create INDEX.md inside the posts-[DATE] folder. It must contain:
- Session variables: topic, platform, funnel stage, style, language, content type
- Table of all posts generated with their scores and GHL status
- Table of all visuals with format and file location
- Any notes or decisions made during the session

---

## Step 10 — QUALITY GATE (mandatory before delivering anything)

Score all deliverables before presenting. Scoring hierarchy:

1. Use smorch-gtm-scoring plugin for GTM assets (campaigns, emails, posts, offers, YouTube)
2. If no specific plugin applies, self-score on these dimensions (1-10 each):
   - Hook strength — does it stop the scroll?
   - Specificity — real numbers, real tools, real outcomes?
   - Anti-gimmick — zero hype, zero guru content?
   - Structure — follows template and good-lookalikes?
   - Voice match — sounds like Mamoun wrote it?
   - Visual match — matches good-lookalikes style?
   - Funnel stage match — right positioning for TOFU/MOFU/BOFU?
   - MENA relevance — regional context included where relevant?

Rules:
- Always show the score table for every post.
- Always offer the path to 10/10.
- Nothing ships without a score.
- Minimum threshold: 9/10 average for production.
- If below 9/10 — fix weak dimensions, rescore, then deliver.

---

## Step 11 — Push all 3 posts as drafts to GHL

Use Chrome browser automation (not the API — it has a schema bug).

### 11a. Navigate to Social Planner
```
https://app.gohighlevel.com/v2/location/7IYdMpQvOejcQmZdDjAQ/marketing/social-planner
```

### 11b. For each post, repeat this process:

1. Click **"+ New Post"** button (top-right, orange button)
2. Select **"Create New Post"** from the dropdown
3. Wait for the composer to fully load (5-8 seconds)
4. Select the correct LinkedIn profile:
   - Open the account dropdown
   - Check **"Mamoun Alamouri ps"** (the one with the LinkedIn icon and fire emoji)
   - NOT "SMOrchestra" (that's the company page)
   - NOT "Mamoun. Alamouri" (that's Facebook)
5. Inject the post content via JavaScript (typing times out on long posts):
   ```javascript
   const editor = document.querySelector('.ql-editor');
   const text = `POST CONTENT HERE`;
   const paragraphs = text.split('\n').map(line =>
     line.trim() === '' ? '<p><br></p>' : '<p>' + line + '</p>'
   ).join('');
   editor.innerHTML = paragraphs;
   editor.dispatchEvent(new Event('input', { bubbles: true }));
   ```
6. Verify the post preview on the right side shows the correct content and profile
7. Click **"Save for later"** (bottom-right button) — NEVER click "Post"
8. Wait for redirect back to the Social Planner list (confirms save)
9. Verify the post appears in the list with "Draft" status

### 11c. Repeat for all 3 posts

After all 3 are saved, verify the Social Planner list shows all 3 drafts under Mamoun Alamouri's LinkedIn profile.

---

## Step 12 — Deliver

Say exactly:

"3 posts saved to GHL as drafts under Mamoun Alamouri. Posts and prompts saved in posts-[DATE] folder. Generate visuals from the Gemini prompts in each prompt.md, then upload them manually to the GHL drafts before publishing."

---

## Reference files

| File | Purpose |
|------|---------|
| `mamoun-founder.md` | Founder voice, constraints, decision framework |
| `good-lookalikes/` | Visual design reference (PDFs + images) |
| `templates/template-approved.md` | 3 approved post templates + style rules |
| `brand-start.md` | Original trigger definition |
| `skill-english-ai-claude.md` | Skill metadata |

---

## Known issues and fixes

| Issue | Fix |
|-------|-----|
| `youtube-transcript-api` old API (`get_transcript()`) fails | Use instance-based API: `ytt_api = YouTubeTranscriptApi(); ytt_api.fetch()` |
| Only Arabic captions available | Use `languages=['ar']` parameter |
| GHL MCP `create-post` returns 422 | Schema bug in MCP connector. Use Chrome automation instead. |
| Typing long posts into GHL times out | Use JavaScript injection into `.ql-editor` instead of typing |
| GHL account dropdown won't close | Press Escape or click outside, then proceed |
| Chrome screenshot timeouts | Wait 5-8 seconds after page actions, refresh with F5 if needed |
| GHL composer loads blank | Wait 8-10 seconds, refresh if still blank |
