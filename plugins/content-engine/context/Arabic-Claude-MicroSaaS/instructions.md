# Instructions — Arabic Claude MicroSaaS Content Engine

## Trigger
User says "Brand Start" and gives a transcript (VTT, SRT, plain text, or PDF). The input is always a transcript. Never a YouTube link or video.
That is the trigger. Execute all steps without stopping or asking.

---

## Step 1 — Load Context (read all 3 files before anything else)

1. Read `mamoun-founder.md` — founder identity, decision framework, communication rules, hard constraints (no em dashes, no filler, contrarian angles, MENA context, tool stack)
2. Read `mamoun-voice-arabic.md` — Arabic writing voice. This defines everything: sentence length (1-2 lines), hook style (shock/question), personal experience over theory, specific numbers, English tool names, ← arrow usage, soft CTA, banned phrases. Study the 3 real examples (MicroSaaS, Context Engineering, GTM)
3. Read `brand-start.md` — the master workflow definition (14 steps). This file is the source of truth for the process

After reading all 3: say "Arabic Claude MicroSaaS loaded. Ready." Then wait for the transcript input.

---

## Step 2 — Load Visual References

Read ALL files in `good-lookalikes/` — JPGs, GIFs, PDFs.
Study every single one:
- Colors: black backgrounds, orange accents (#FF6600), white text (#FFFFFF)
- Fonts: Cairo, Tajawal (Arabic RTL)
- Layout: clean, minimal, no stock photos, MA logo top-left
- Formats: carousels (numbered slides, orange circles), infographics (horizontal sections), single visuals (comparison columns)
- What makes them scroll-stopping: bold typography, high contrast, specific numbers visible

This is your ONLY visual reference. Nothing else.

---

## Step 3 — Extract Content From Input

The input is always a transcript (VTT, SRT, plain text, or PDF). Never a YouTube link or video.

- Read the full transcript content carefully
- If content is very long: chunk it into sections, process each section, then synthesize the key themes across all sections
- Do not summarize too early — extract every insight, number, framework, and story first
- Then identify the strongest angles for posts
- Never skip content because it is too long — process everything

### What to extract (both cases):
- Key insights and frameworks taught
- Specific numbers, tools, and outcomes mentioned
- Personal stories or transformations described
- Step-by-step processes or methodologies
- Contrarian angles or surprising claims

---

## Step 4 — Identify 4 Angles

From the extracted content, identify exactly 4 angles:

### 2 AI/Claude angles (Posts 1 and 2)
Pick angles that highlight:
- A specific Claude capability, technique, or workflow
- A mindset shift (e.g., Prompt Engineering vs Context Engineering)
- A concrete "how I use Claude" story with tools and numbers

### 2 MicroSaaS training hype angles (Posts 3 and 4)
Pick angles that highlight:
- The "weekend build" transformation — before vs after
- The "Claude as your team" narrative
- The bridge from using Claude personally to building a product for others
- A painful truth about traditional software building

Each angle must be distinct. No overlap. No recycled hooks.

---

## Step 5 — Write 4 Arabic Posts

### Posts 1 and 2 — AI/Claude
- Jordanian/Levantine dialect. NOT MSA. NOT Gulf
- Topic: AI tools, Claude, automation in real business
- Hook: one line that stops the scroll — shock, contrarian claim, or specific number. Never start with a question. Start with a statement.
- Body: numbered steps (←) or short personal story, specific tools and numbers
- Max 130 words (count EVERY word including single-letter Arabic prepositions)
- No em dashes (use colons, commas, line breaks)
- No hype, no guru content, no gimmicks
- First person (أنا) always
- Numbers as digits (3 not ثلاثة, but Arabic-Indic ١٢٣ allowed for lists)
- Tool names always in English: Claude, n8n, GHL, Clay, MCP, Skills, CRM, APIs
- MicroSaaS angle where relevant
- CTA: soft — question or "الفيديو الكامل بالتعليقات"

### Posts 3 and 4 — MicroSaaS Training Hype
- Jordanian/Levantine dialect — warm, like sharing a personal story not selling
- Topic: building MicroSaaS using Claude as operating system, in a weekend
- Hook: must touch a real pain — "قبل سنة كنت..." or contrast (chatbot vs operator)
- Body: real story or painful truth, personal and warm
- Soft reference to training — NEVER direct selling
- NEVER say "تدريب" or "كورس" in every post. Use soft alternatives: "مع المؤسسين", "بنشتغل عليه", "الرابط بالتعليقات"
- NEVER use: "سارع بالتسجيل" / "لا تفوّت" / "عرض محدود"
- Max 130 words
- No em dashes
- First person (أنا) always
- Numbers as digits
- CTA: "حابب تبني المايكرو ساس تاعك؟" or "الرابط بالبايو"

### Banned phrases (all posts):
- "في عالمنا اليوم"
- "لا شك أن"
- "من المهم أن نذكر"
- "الأتمتة" → use "نظام تلقائي" or "automation"
- Any guru content or empty promises

### Voice check:
After writing each post, read it against `mamoun-voice-arabic.md` examples. If it doesn't sound like Mamoun wrote it himself — rewrite. Specifically check:
- Are sentences short (1-2 lines each)?
- Does every line stand on its own?
- Is the hook shock/question/contrarian?
- Are there specific numbers and tool names?
- Does it use ← arrows where appropriate?
- Is the CTA soft and natural?

---

## Step 6 — Word Count Compliance

Count every word in each post. Arabic prepositions (بـ, لـ, كـ) attached to words count as part of that word. Standalone words like من, في, على count separately.

If any post exceeds 130 words: trim by removing adjectives, combining lines, or tightening phrasing. Never cut substance — cut filler.

Recount after every edit.

---

## Step 7 — Banned Phrase Check

Run grep/search on all 4 posts for:
- "تدريب" — soft-fix if found (replace with "مع المؤسسين" or similar)
- "كورس" — remove or rephrase
- "في عالمنا اليوم" — delete
- "الأتمتة" — replace with "نظام تلقائي"
- Em dashes (—) — replace with line breaks or colons
- Emojis — remove all

Fix any violations before proceeding.

---

## Step 8 — Quality Gate (mandatory, nothing ships without this)

Score every post on 8 dimensions (1-10 each):

| Dimension | What to check |
|-----------|---------------|
| Hook strength | Does it stop the scroll? Would YOU stop scrolling? |
| Dialect accuracy | Natural Jordanian Arabic — "عشان", "مش", "إشي", "هاد", "بيجي" |
| Specificity | Real numbers, real tools (by name), real outcomes |
| Anti-gimmick | Zero hype, zero guru content, zero empty promises |
| Structure | Hook → Context → Core (steps/story) → Punch → CTA |
| Visual match | Does the visual format match good-lookalikes style? |
| Arabic text accuracy | Correct RTL, no broken chars, English tools in English |
| CTA quality | Natural question or soft link — never salesy |

### Rules:
- Minimum to ship: 9/10 average
- If below 9/10: fix the weak dimensions, rewrite, rescore
- Always note "Path to 10/10" for each post
- Save score table as `score.md` in each post subfolder

---

## Step 9 — Visual Format Decision

Decide automatically based on post content (never ask user):

| Content pattern | Format | Tool |
|----------------|--------|------|
| Steps, process, numbered list | Carousel (8 slides, 1:1) | Build as HTML, user recreates in Canva |
| Numbers, stats, comparison | Infographic (4:5, 1080x1350) | Gemini prompt |
| One strong insight or quote | Single visual (1:1, 1080x1080) | Gemini prompt |

### Design system (from good-lookalikes):
- Background: solid black (#000000)
- Accent: orange (#FF6600)
- Text: white (#FFFFFF)
- Font: Cairo or Tajawal (Arabic RTL)
- MA logo: top-left corner on every slide/visual
- Clean, minimal, no stock photos
- Numbers visible and large
- High contrast typography

### For Carousels:
Build an HTML file with all slides at 1080x1080. Each slide must:
- Have MA logo (orange circle with "MA" in white) top-left
- Last slide: always import assets/last-slide-arabic.png exactly as-is. Do NOT redesign or recreate it.
- Have pagination dots at bottom
- Have grid overlay for depth
- Use subtle orange glow effects on key slides
- Follow RTL layout for all Arabic text

### For Gemini prompts:
Write a detailed prompt in `prompt.md` specifying:
- Exact dimensions and ratio
- Exact design system (colors, fonts, layout)
- Exact content per section
- "Arabic text must be RTL using Cairo font, fully rendered, no broken characters"
- "Do not use stock photo style. Do not use generic AI illustration style."

---

## Step 10 — Create INDEX.md

After generating all content, create an INDEX.md inside the posts-[DATE] folder. It must contain:
- Session variables: topic, platform, funnel stage, style, language, content type
- Table of all posts generated with scores and GHL status — clearly separating AI/Claude posts from MicroSaaS hype posts. Columns: Post #, Type (AI/Claude or MicroSaaS Hype), Title/Hook, Score, GHL Draft Status
- Table of all visuals generated with columns: Post #, Format (carousel / infographic / single), File location
- Notes and decisions: any angle choices, rewrites, quality gate fixes, or deviations made during the session

---

## Step 11 — Save to Folder

Create folder: `posts-[YYYY-MM-DD]/` inside `Arabic-Claude-MicroSaaS/`

Structure:
```
posts-YYYY-MM-DD/
├── post-1/
│   ├── post.md          (full LinkedIn post text)
│   ├── prompt.md         (visual spec — Canva breakdown or Gemini prompt)
│   ├── score.md          (quality gate score table)
│   └── carousel.html     (if carousel format — rendered HTML)
├── post-2/
│   ├── post.md
│   ├── prompt.md
│   └── score.md
├── post-3/
│   ├── post.md
│   ├── prompt.md
│   ├── score.md
│   └── carousel.html
└── post-4/
    ├── post.md
    ├── prompt.md
    └── score.md
```

---

## Step 11 — Push to GHL Social Planner

For each of the 4 posts, create a draft in GHL Social Planner:

### GHL details:
- Location ID: `7IYdMpQvOejcQmZdDjAQ`
- Profile: **Mamoun Alamouri ps** (LinkedIn personal) — NEVER SMOrchestra
- Status: Draft always — never publish directly

### GHL posting workflow (Chrome browser):
1. Navigate to: `https://app.gohighlevel.com/v2/location/7IYdMpQvOejcQmZdDjAQ/marketing/social-planner`
2. Click "+ New Post"
3. In "Post to" dropdown: select **Mamoun Alamouri ps** (the LinkedIn personal account with the "in" badge). VERIFY the correct account is selected — not SMOrchestra, not mamounalamouri (Instagram)
4. Close dropdown by clicking outside or pressing Escape
5. Paste post content using JavaScript injection:
   ```javascript
   // Convert post text to paragraphs
   const content = `<p>line 1</p><p>line 2</p>...`;
   const editor = document.querySelector('[contenteditable="true"]');
   editor.innerHTML = content;
   editor.dispatchEvent(new Event('input', { bubbles: true }));
   ```
   - Each line of the post becomes a `<p>` tag
   - Empty lines become `<p><br></p>`
   - Dispatch input event to register the change
6. Click "Save for later" button
7. Verify: take screenshot and confirm correct account and content

### Critical checks before saving each post:
- Account shows "Mamoun Alamouri ps" (NOT SMOrchestra)
- Content is fully pasted and visible in editor
- No Instagram or other accounts accidentally selected

### If wrong account selected:
- Click "Post to" dropdown
- Uncheck wrong account
- Check "Mamoun Alamouri ps"
- Close dropdown
- Save

---

## Step 12 — Final Verification

After all 4 posts are saved:
1. Return to Social Planner list view
2. Verify all 4 drafts appear with correct LinkedIn icon (Mamoun Alamouri ps)
3. Verify dates are correct

---

## Step 13 — Generate Carousel HTML (for carousel posts)

For any post assigned Carousel format, build a complete HTML file:
- 1080x1080 per slide
- Cairo font (Google Fonts)
- Black background, orange accent, white text
- MA logo on every slide
- Pagination dots
- Subtle grid overlay and orange glow effects
- Save as `carousel.html` in the post subfolder

---

## Step 14 — Deliver

Say exactly:
"4 Arabic posts saved to GHL as drafts under Mamoun Alamouri. Posts and visuals saved in posts-[DATE] folder. Quality scores saved in each subfolder. Upload visuals manually to GHL."

Then provide summary table:
- Post 1: [topic] ([format]) — Score: X/10
- Post 2: [topic] ([format]) — Score: X/10
- Post 3: [topic] ([format]) — Score: X/10
- Post 4: [topic] ([format]) — Score: X/10

---

## Reference: Approved Templates

Two template files live in `Arabic-Claude-MicroSaaS/templates/`:
- `template-ai-claude-approved.md` — 2 approved AI/Claude posts as structural reference
- `template-training-hype-approved.md` — 2 approved MicroSaaS hype posts as structural reference

When writing new posts, match the structure, tone, length, and hook style of these templates. They are the quality standard.

---

## Execution Rules

1. Never stop between steps to ask for confirmation
2. Never ask "shall I proceed?" — just proceed
3. If a transcript is unreadable or malformed, ask the user for a clean version
4. If a post exceeds 130 words, trim it before scoring
5. If a post scores below 9/10, fix and rescore before saving
6. If wrong GHL account is selected, fix it immediately
7. Read all reference files FIRST before writing anything
8. Match mamoun-voice-arabic.md examples exactly — if it doesn't sound like Mamoun, rewrite
