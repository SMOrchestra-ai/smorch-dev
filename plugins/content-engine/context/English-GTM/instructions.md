# Instructions — English GTM Content

## How to Activate

User says "Brand Start" and provides a transcript (VTT, SRT, plain text, or PDF). The input is always a transcript. Never a YouTube link or video.
That is the trigger. Execute every step below without stopping, without asking, without deviating.

---

## PHASE 1 — LOAD CONTEXT

### Step 1: Load Founder Voice

Read mamoun-founder.md completely.
Internalize every rule: no em dashes, no hashtags, no emojis, no fluff, first person always, specific numbers, MENA context, contrarian positioning.
This is non-negotiable. Every word you write must sound like Mamoun wrote it.

### Step 2: Load Good Lookalikes

Open good-lookalikes/ and read every PDF and image file.
Study: colors, fonts, layout, spacing, visual hierarchy, how carousels are structured, how infographics present data, what makes each visual scroll-stopping.
This is your only visual reference. Nothing else.

Design system extracted from good-lookalikes:
- Background: Solid black (#000000)
- Headlines: Bold sans-serif (Arial Black), orange (#FF6600)
- Body text: Clean sans-serif (Arial), white (#FFFFFF)
- Accent color: Orange (#FF6600) for icons, borders, badges, dividers
- Dark card fills: #1A1A1A
- Muted text: #AAAAAA or #CCCCCC
- MA logo: Orange circle with white "MA" text, top-left of every slide
- 3D rendered imagery in orange/black/white palette (icons as substitutes when generating programmatically)

### Step 3: Confirm Ready

Say exactly: "English GTM loaded. Ready."
Then wait for the transcript (VTT, SRT, plain text, or PDF).

---

## PHASE 2 — EXTRACT AND ANALYZE

### Step 4: Load Transcript

The input is always a transcript file. Accepted formats: VTT, SRT, plain text, or PDF. Never a YouTube link or video.

- Read the full transcript carefully from the provided file
- If content is very long: chunk it into sections, process each section, then synthesize the key themes across all sections
- Do not summarize too early — extract every insight, number, framework, and story first
- Never skip content because it is too long — process everything

Save full transcript text for analysis.

### Step 5: Identify 3 Angles

From the transcript, identify the 3 strongest angles for LinkedIn posts.
Each angle must connect to: GTM strategy, signal-based selling, Dream 100, 7-11-4 framework, or MENA market opportunity.
Prioritize: contrarian takes, specific numbers, actionable frameworks, real case studies from the transcript.

---

## PHASE 3 — WRITE 3 POSTS

### Step 6: Write Posts

For each of the 3 angles, write a LinkedIn post following this exact structure:

**Hook (1-2 lines):** Contrarian take, bold result, or "Old way vs New way" — must stop the scroll.

**Context bridge (2-3 lines):** Set up the problem. MENA-specific when relevant. Ground the hook in reality.

**Numbered breakdown (3-5 sections using 1/, 2/, 3/ format):**
Each section has a bold sub-header + 2-4 short lines. Use arrows for action items when appropriate.

**Closing punch (1-2 lines):** Ties back to the hook. Drives the point home.

**P.S. question:** Engagement hook. One question that invites comments.

**Hard constraints:**
- Max 3000 characters per post
- No em dashes (use periods or commas)
- No hashtags anywhere
- No emojis anywhere
- No fluff words: "transform," "unlock," "the secret is," "game-changer"
- Specific numbers always: pipeline numbers, ARR, meetings booked, percentages
- MENA context whenever relevant
- First person always
- Must sound like Mamoun wrote it, not a copywriter

### Step 7: Quality Gate

Before finalizing each post, run these checks:

**Anti-gimmick check:**
- Real = specific numbers, real tools, real outcomes, real story
- Fake = "transform your GTM," "unlock your pipeline," "the secret is..."
- If the post could have been written by anyone, rewrite
- If it sounds like guru content or hype, kill it

**Good-lookalikes comparison:**
- Read the PDFs again. Compare tone, specificity, and quality.
- If the post doesn't match, rewrite before proceeding.

---

## PHASE 4 — DECIDE VISUALS

### Step 8: Decide Visual Format Per Post

Never ask the user. Decide yourself using these rules:

| Post content | Visual format | Tool |
|---|---|---|
| Steps, process, framework | Carousel (8-10 slides) | PptxGenJS -> PPTX -> Canva import |
| Numbers, stats, comparisons | Infographic (1:1 square) | Gemini prompt |
| One strong insight or quote | Single visual (1:1 square) | Gemini prompt |

### Step 9: Generate Gemini Prompts (for infographics/single visuals)

Write a detailed Gemini image generation prompt that includes:
- Exact dimensions and ratio from good-lookalikes
- Complete design system description (colors, fonts, layout, spacing)
- Specific content to include on the visual
- "Match this exact ratio: [ratio]. Do not use stock photo style. Do not use generic AI illustration style. Replicate this exact design system."
- Always include this line verbatim in every Gemini prompt: "Add Mamoun Alamouri logo (MA orange circle on black) to top-left corner"
- Save as prompt.md in the post subfolder

### Step 10: Generate Carousel (for carousel posts)

This is the exact process. Follow it precisely.

**10a. Install dependencies:**
```bash
npm init -y && npm install pptxgenjs react-icons react react-dom sharp
```

**10b. Write the carousel script (carousel.js):**

Use PptxGenJS with this exact configuration:
- Custom 4:5 portrait layout: 7.5" x 9.375" (maps to 1080x1350px)
- Layout name: "PORTRAIT_4x5"
- Color constants: ORANGE = "FF6600", WHITE = "FFFFFF", BLACK = "000000", DARK_CARD = "1A1A1A"

Standard slide components:
- MA logo: Use the existing assets/mamoun-logo.png file. Placed at the top-left corner (x:0.3, y:0.3, w:0.55, h:0.55) on every slide. Never regenerate the logo — always import assets/mamoun-logo.png directly.
- Icons: Use react-icons/fa, render with ReactDOMServer.renderToStaticMarkup, convert SVG to PNG via sharp. Place as large semi-transparent decorative elements (transparency: 15-25) in bottom portion of slides.
- Step badges: Orange (#FF6600) filled rectangle 0.5x0.5 with black number text, positioned at x:0.5, y:1.2.
- Headlines: Arial Black, orange, 34-52pt depending on slide type.
- Body text: Arial, white, 16-20pt.
- Cards: Dark fill (#1A1A1A) rectangles with orange border or left accent bar.
- Stat boxes: Dark fill with orange border, large orange number, muted label below.
- Dividers: Orange rectangles, 0.05" height.

Standard carousel structure (9 slides):
1. Cover: Big orange headline, white italic subheadline, gray subtitle, decorative icon, orange accent line
2. Problem: Orange headline with left accent bar, white body, two stat boxes side by side, warning icon
3. Step 1: Number badge, orange headline, white body with orange highlight line, decorative icon
4. Step 2: Number badge, orange headline, mixed white/orange body text, decorative icon
5. Step 3: Number badge, orange headline, comparison cards (two dark cards with orange headers), bottom callout, decorative icon
6. Step 4: Number badge, orange headline, four horizontal cards (dark fill, orange left border, icon, white text), decorative icon
7. Opportunity: Large orange headline, white body, orange divider, bold orange closing statement, decorative icon
8. CTA: Large orange "DM me" headline, bordered card with offer details, P.S. section, envelope icon
9. Follow / Last slide: Always import assets/last-slide-english.png as the final slide. Do not redesign or regenerate this slide — import the exact file as a full-bleed image on slide 9.

Every slide (including the imported last slide) must have assets/mamoun-logo.png in the top-left corner.

**10c. Execute the script:**
```bash
node carousel.js
```

**10d. Visual QA — convert to images:**
```bash
python mnt/.claude/skills/pptx/scripts/office/soffice.py --headless --convert-to pdf "[PPTX_PATH]"
pdftoppm -jpeg -r 150 [PDF_FILE] slide
```

**10e. Visual QA — inspect every slide:**
Read each slide-N.jpg image. Check for:
- Overlapping elements (text through shapes)
- Text overflow or cut off at edges
- Orphaned words wrapping to second lines
- Elements too close (< 0.3" gaps)
- Uneven spacing
- Insufficient margins (< 0.5" from edges)
- Missing or misaligned MA logo
- Font sizing issues
- Consistency across slides

**10f. Fix issues and re-verify:**
Edit carousel.js to fix any problems found. Re-run the script, re-convert to images, re-inspect the specific slides that changed. Repeat until clean.

**10g. Save the prompt spec:**
Save the full slide-by-slide content spec as prompt.md in the post subfolder (same format as good-lookalikes carousel specs).

**10h. Open Canva for user import:**
The PPTX cannot be uploaded programmatically due to browser security restrictions. Instead:
1. Open Canva in Chrome (navigate to canva.com)
2. Click "Create a design" > "Upload"
3. Leave the Upload dialog open for the user
4. Tell the user: "Canva Upload dialog is open. Drag carousel-mena-startups.pptx from your posts-[DATE]/post-N/ folder into Canva. It will import all slides as editable pages. Add your photo to the last slide."

The PPTX file is the source of truth. Canva is the editing layer where the user adds their photo and makes final tweaks.

---

## PHASE 5 — SAVE AND DELIVER

### Step 11: Create Folder Structure

```
English-GTM/
  posts-[YYYY-MM-DD]/
    post-1/
      post.md          (full LinkedIn post text)
      prompt.md         (Gemini prompt OR carousel slide spec)
      score.md          (quality gate score table)
      visual.[format]   (generated visual file if applicable)
    post-2/
      post.md
      prompt.md
      score.md
      visual.[format]
    post-3/
      post.md
      prompt.md
      score.md
      carousel-[topic].pptx   (if carousel format)
```

Save everything before pushing to GHL.

### Step 11b: Create INDEX.md for the Session

After the folder structure is saved, create an INDEX.md inside the posts-[DATE] folder. It is the session manifest. It must contain:

**1. Session variables**
- Topic
- Platform (e.g., LinkedIn)
- Funnel stage (TOFU / MOFU / BOFU)
- Style (e.g., contrarian, case study, framework breakdown)
- Language (English / Arabic)
- Content type (single post / carousel / infographic mix)

**2. Posts table**
A markdown table listing every post generated with columns:
| # | Title / Hook | File path | Score (avg /10) | GHL status (Draft / Pushed / Failed) |

**3. Visuals table**
A markdown table listing every visual with columns:
| Post # | Format (carousel / infographic / single) | File path |

**4. Notes**
Any decisions made during the session: why a specific angle was chosen, any angles rejected, any deviations, any user overrides, any QA issues and how they were resolved.

Save as `posts-[DATE]/INDEX.md`. This file must exist before pushing to GHL.

### QUALITY GATE — mandatory before delivering anything

Score all deliverables before presenting. Scoring hierarchy:
1. Use smorch-gtm-scoring plugin for GTM assets (campaigns, emails, posts, offers, YouTube)
2. If no specific plugin applies, self-score on these dimensions (1-10 each):
   - Hook strength — does it stop the scroll?
   - Specificity — real numbers, real tools, real outcomes?
   - Anti-gimmick — zero hype, zero guru content?
   - Structure — follows template and good-lookalikes?
   - Voice match — sounds like Mamoun wrote it?
   - Visual match — matches good-lookalikes style?
   - GTM accuracy — correct use of frameworks, ICP, pipeline language?
   - MENA relevance — regional context included where relevant?

Always show the score table for every post.
Always offer the path to 10/10.
Nothing ships without a score.
Minimum threshold: 9/10 average for production.
If below 9/10 — fix weak dimensions, rescore, then deliver.

### Step 12: Push to GHL Social Planner

Use Chrome automation (not the API — the API has a schema bug with type/status fields).

**GHL Details:**
- Location ID: 7IYdMpQvOejcQmZdDjAQ
- Profile: "Mamoun Alamouri ps" (personal LinkedIn) — NOT SMOrchestra
- Status: Draft always — never publish directly

**Chrome automation steps for each post:**
1. Navigate to GHL Social Planner > Create Post
2. Open account dropdown
3. Click "Clear all" first (critical — prevents all-accounts bug)
4. Re-open dropdown, click checkbox for "Mamoun Alamouri ps" only
5. Press Escape to close dropdown (do NOT click into content area while dropdown is open)
6. Click into the content/caption area
7. Paste post text using JavaScript: `document.execCommand('insertText', false, postText)` — this avoids Chrome typing timeouts on long text
8. Click "Save as Draft"
9. Wait for confirmation, then repeat for next post

**Known GHL quirks:**
- The account selection dropdown has a "Select All" toggle. Clicking into the content area while the dropdown is open triggers it, selecting all accounts. Always close with Escape first.
- Long text typed character-by-character times out. Always use execCommand('insertText') via JavaScript.
- Do NOT attach visuals in GHL. User uploads those manually.

### Step 13: Deliver

Say exactly:
"3 GTM posts saved to GHL as drafts under Mamoun Alamouri. Posts and visuals saved in posts-[DATE] folder. Canva Upload dialog is open — drag your carousel PPTX in to edit. Upload visuals manually to GHL."

Then provide computer:// links to all deliverables.

---

## RULES

1. Never stop between steps to ask for confirmation. Execute everything.
2. Never ask what visual format to use. Decide yourself.
3. Never ask what ratio to use. Match good-lookalikes.
4. Never publish to GHL. Always draft.
5. Never skip the anti-gimmick check.
6. Never skip visual QA on carousels.
7. The input is always a transcript file (VTT, SRT, plain text, or PDF). Never a YouTube link or video. If the transcript is unreadable or malformed, tell the user.
8. The carousel PPTX is the master file. Canva is for user editing only.
9. Every post must have a P.S. question.
10. Every visual prompt must reference the exact design system from good-lookalikes.
