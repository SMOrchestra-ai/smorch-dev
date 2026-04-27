# Skill — Arabic Claude MicroSaaS Content Creator
## What this skill does
Transforms a YouTube video into 4 high-quality Arabic LinkedIn posts — 2 about AI/Claude and 2 building hype for MicroSaaS training — with visuals, quality scored, pushed to GHL as drafts.
## When to use this skill
- User says "Start" or "Brand Start" and provides a transcript
- User shares a transcript (VTT, SRT, plain text, or PDF)
- User asks to create Arabic LinkedIn posts from a transcript
## Inputs required
- Transcript (VTT, SRT, plain text, or PDF) — never a YouTube link or video
- Access to good-lookalikes/ folder
- Access to mamoun-founder.md
## Quality standard
Every post is measured against 3 benchmarks:
1. mamoun-founder.md rules — non-negotiable
2. good-lookalikes PDFs — style, length, structure, depth
3. Quality gate score — minimum 9/10 average before shipping
If a post does not pass all 3 — rewrite before delivering. Never deliver below 9/10.
## Post requirements — AI/Claude posts (2)
- Topic: AI tools, Claude, automation in real business
- Dialect: Jordanian Arabic, conversational
- Length: max 130 words
- Structure: hook + numbered steps or short story + CTA
- Voice: first person (أنا), contrarian, specific
- Numbers: always digits (3 not ثلاثة)
- Tool names: English (Claude, n8n, GHL, Clay)
- MicroSaaS angle where relevant
- No em dashes, no hashtags, no hype, no guru content
## Post requirements — MicroSaaS training hype posts (2)
- Topic: building MicroSaaS using Claude as operating system, in a weekend
- Dialect: Jordanian Arabic, warm, personal
- Length: max 130 words
- Structure: painful hook + real story + soft training reference + CTA
- Voice: first person (أنا), storytelling, never selling
- Never say "تدريب" or "كورس" directly in every post
- Never use: "سارع بالتسجيل" / "لا تفوّت" / "عرض محدود"
- No em dashes, no hype, no direct selling
## Quality gate (mandatory before delivery)
Use smorch-gtm-scoring plugin if available.
If not, self-score on 8 dimensions (1-10 each):
1. Hook strength
2. Dialect accuracy — natural Jordanian Arabic
3. Specificity — real numbers, real tools, real outcomes
4. Anti-gimmick — zero hype, zero guru content
5. Structure — follows template and good-lookalikes
6. Visual match — matches good-lookalikes style
7. Arabic text accuracy — correct RTL, no broken characters
8. CTA quality — natural, not salesy
Minimum to ship: 9/10 average.
Show score table for every post.
Always show path to 10/10.
Nothing ships without passing quality gate.
## Visual requirements
Never ask the user. Decide yourself:
- Steps or process → Carousel built directly in Canva
- Numbers, stats, comparisons → Infographic via Gemini
- One strong insight → Single visual via Gemini
Match exact ratio and style from good-lookalikes PDFs.
## Arabic text in visuals — mandatory
- All Arabic text must be RTL
- Use Arabic-supported fonts only: Cairo, Tajawal, Noto Sans Arabic, or Almarai
- Never use Latin fonts for Arabic text
- In Canva: set text direction to RTL before typing
- In Gemini: specify "Arabic text, right-to-left, using [font], fully rendered, no broken characters"
- If Arabic text renders broken — regenerate before delivering
- Jordanian dialect in all text — not MSA
## Output
- 4 Arabic posts
- 4 visuals (one per post)
- 4 score tables (one per post)
- All saved in posts-[DATE] folder
- All pushed to GHL as drafts under Mamoun Alamouri personal LinkedIn
- Never published directly
## After approval
When a post is approved say:
"This post is approved. Save it as template to Arabic-Claude-MicroSaaS/templates/template-approved.md"
