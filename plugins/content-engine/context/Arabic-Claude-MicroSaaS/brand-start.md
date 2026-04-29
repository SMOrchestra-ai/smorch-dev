# Brand Start — Arabic Claude MicroSaaS
When I say "Brand Start", do this in order without stopping:
1. Read mamoun-founder.md — load all rules, voice, constraints
   Also read mamoun-voice-arabic.md — this is Mamoun's exact Arabic writing style with real examples. Every Arabic post must sound exactly like these examples. Match the sentence length, the tone, the structure, and the specific phrases he uses. If it does not sound like Mamoun wrote it himself — rewrite.
   Also read templates/template-ai-claude-approved.md and templates/template-training-hype-approved.md — these are the approved post structures. Match them.
2. Read all images and PDFs in good-lookalikes/ carefully:
   - Study every design: colors, fonts, layout, spacing
   - Study every format: how carousels are structured, how infographics present data
   - Study every style: what makes each visual scroll-stopping
   - This is your only visual reference — nothing else
3. Read instructions.md — this is your workflow
4. Confirm by saying exactly: "Arabic Claude MicroSaaS loaded. Ready."
When I give you input after confirmation, do this automatically:
5. Process the transcript (input is always a transcript — VTT, SRT, plain text, or PDF — never a YouTube link or video):
   - Read the full transcript content carefully
   - If content is very long: chunk it into sections, process each section, then synthesize the key themes across all sections
   - Do not summarize too early — extract every insight, number, framework, and story first
   - Then identify the strongest angles for posts
   - Extract: key insights, frameworks, stories, numbers, tools mentioned
   - Identify 2 angles for AI/Claude posts and 2 angles for MicroSaaS training hype posts
   - Never skip content because it is too long — process everything
6. Identify the strongest angles — 2 for AI/Claude posts and 2 for MicroSaaS training hype posts
7. Write 2 Arabic AI/Claude posts following these rules:
   - Jordanian dialect — conversational, like talking to a friend
   - Topic: AI tools, Claude, automation in real business
   - Hook: one line that stops the scroll
   - Body: numbered steps or short story, specific tools and numbers
   - Max 130 words
   - No em dashes
   - No hype, no guru content, no gimmicks
   - First person (أنا) always
   - Numbers as digits (3 not ثلاثة)
   - Tool names in English: Claude, n8n, GHL, Clay
   - MicroSaaS angle where relevant
   Write 2 Arabic MicroSaaS training hype posts following these rules:
   - Jordanian dialect — warm, like sharing a personal story not selling
   - Topic: building MicroSaaS using Claude as the operating system, in a weekend
   - Hook: must touch a real pain — "قبل سنة كنت..." or "عندك فكرة MicroSaaS؟"
   - Body: real story or painful truth, personal and warm
   - Soft reference to training — never direct selling
   - Never say "تدريب" or "كورس" directly in every post
   - Never use: "سارع بالتسجيل" / "لا تفوّت" / "عرض محدود"
   - Max 130 words
   - No em dashes
   - First person (أنا) always
   - Numbers as digits
8. Compare each post against good-lookalikes PDFs — if it doesn't match quality, rewrite before delivering
9. Run anti-gimmick check on every post:
   - Real = specific numbers, real tools, real outcomes, real story
   - Fake = "حوّل حياتك" / "السر هو..." / "لا تفوّت الفرصة"
   - If post could have been written by anyone — rewrite
10. QUALITY GATE — score every post before delivering:
    - Use smorch-gtm-scoring plugin if available
    - If not available, self-score on these 8 dimensions (1-10 each):
      1. Hook strength — does it stop the scroll?
      2. Dialect accuracy — is it natural Jordanian Arabic?
      3. Specificity — real numbers, real tools, real outcomes?
      4. Anti-gimmick — zero hype, zero guru content?
      5. Structure — follows template and good-lookalikes?
      6. Visual match — does visual match good-lookalikes style?
      7. Arabic text accuracy — correct RTL, no broken characters?
      8. CTA quality — natural, not salesy?
    - Show the score table for every post
    - Minimum score to ship: 9/10 average
    - If below 9/10 — fix the weak dimensions and rescore
    - Always show the path to 10/10
    - Nothing ships without passing the quality gate
11. For each post, decide the visual format and specs:
    DECISION RULES (no asking — decide yourself):
    - Post has steps or a process → Carousel
    - Post has numbers, stats, or comparisons → Infographic
    - Post has one strong insight or quote → Single visual
    VISUAL TOOL BY FORMAT:
    - Infographic → Generate using Gemini
    - Single visual → Generate using Gemini
    - Carousel → Build directly inside Canva (do not give user a prompt to copy)
      - Use exact dimensions from good-lookalikes
      - Match style, colors, fonts, layout from good-lookalikes PDFs
      - Each slide follows post content in order
      - Last slide must always be assets/last-slide-arabic.png — import the exact file, never redesign or recreate it
      - Save as PDF and PNG
      - Do NOT upload to GHL — user uploads manually
    BRAND LOGO — MANDATORY ON EVERY VISUAL:
    - Add assets/mamoun-logo.png to the top-left corner of every visual (single, infographic, and every carousel slide)
    - Never resize, recolor, or redesign the logo — use the exact file from assets/
    RATIO AND SIZE:
    - Open good-lookalikes PDFs and match exact ratio used
    - Never use a random ratio — always base on good-lookalikes
    ARABIC TEXT IN VISUALS — MANDATORY RULES:
    - All Arabic text must be right-to-left (RTL)
    - Use Arabic-supported fonts only: Cairo, Tajawal, Noto Sans Arabic, or Almarai
    - Never use Latin fonts for Arabic text — letters will break
    - Test every Arabic word before placing in design
    - Numbers stay as Western digits (3 not ٣) unless good-lookalikes use Arabic-Indic
    - In Canva: set text direction to RTL before typing Arabic
    - In Gemini prompts: specify "Arabic text, right-to-left, using [font name], fully rendered, no broken characters"
    - If Arabic text renders broken or wrong — regenerate before delivering
    - Jordanian dialect in all text — not MSA
    GEMINI PROMPT RULES (for infographics and single visuals):
    - Describe exact design system from good-lookalikes: colors, fonts, layout, spacing
    - Always include: "Add Mamoun Alamouri logo (MA orange circle on black) to top-left corner"
    - Always include: "Arabic text RTL, using Cairo font, fully rendered, no broken characters"
    - Include: "Match this exact ratio: [ratio from good-lookalikes]. Do not use stock photo style. Do not use generic AI illustration style. Replicate this exact design system: [describe every detail]."
    - If result looks generic, ratio is wrong, Arabic text is broken, or logo is missing — regenerate
12. Create a folder named: posts-[DATE] inside Arabic-Claude-MicroSaaS/
    Inside it create one subfolder per post: post-1, post-2, post-3, post-4
    Inside each subfolder save:
    - post.md → full LinkedIn post text
    - visual.[format] → generated image or Canva export
    - prompt.md → exact Gemini prompt used
    - score.md → quality gate score table
13. Create INDEX.md inside posts-[DATE] folder summarizing the session. It must include:
    - Session variables: topic, platform, funnel stage, style, language, content type
    - Table of all posts generated with scores and GHL status — clearly separating AI/Claude posts from MicroSaaS hype posts. Columns: Post #, Type (AI/Claude or MicroSaaS Hype), Title/Hook, Score, GHL Draft Status
    - Table of all visuals generated with columns: Post #, Format (carousel / infographic / single), File location (relative path inside posts-[DATE])
    - Notes and decisions: any angle choices, rewrites, quality gate fixes, or deviations made during the session
14. Push all 4 posts as drafts to GHL Social Planner:
    - Location ID: 7IYdMpQvOejcQmZdDjAQ
    - Profile: Mamoun Alamouri personal LinkedIn — NOT SMOrchestra
    - Status: Draft always — never publish directly
15. Say: "4 Arabic posts saved to GHL as drafts under Mamoun Alamouri. Posts and visuals saved in posts-[DATE] folder. Quality scores saved in each subfolder. INDEX.md created with full session summary. Upload visuals manually to GHL."
Never stop between steps to ask for confirmation. Just execute.
