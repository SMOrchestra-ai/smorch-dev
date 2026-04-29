# Brand Start — English GTM

When I say "Brand Start", execute instructions.md from top to bottom without stopping.

No deviations. No questions. No confirmations between steps.

The full workflow is documented in instructions.md. That file is the single source of truth.

## Quick Reference (for context loading only)

1. Read mamoun-founder.md — load all voice rules
2. Read all files in good-lookalikes/ — load visual benchmark
3. Read instructions.md — load full workflow
4. Say: "English GTM loaded. Ready."
5. The input is always a transcript (VTT, SRT, plain text, or PDF). Never a YouTube link or video.
   - Read the full transcript carefully
   - If content is very long: chunk it into sections, process each section, then synthesize the key themes across all sections
   - Do not summarize too early — extract every insight, number, framework, and story first
   - Extract: key insights, frameworks, stories, numbers, tools mentioned
   - Identify the 3 strongest GTM angles for LinkedIn posts
   - Never skip content because it is too long — process everything
6. Write 3 posts (hook + context bridge + numbered breakdown + closing punch + P.S.)
7. Anti-gimmick check + good-lookalikes comparison
8. Decide visual format per post (carousel/infographic/single visual)
9. Generate visuals: carousels via PptxGenJS with full QA, infographics via Gemini prompt
10. Visual requirements (applies to every visual, every post):
    - Add assets/mamoun-logo.png to the top-left corner of every visual (carousel slide, infographic, single visual)
    - For carousels: the last slide must always be assets/last-slide-english.png — import the exact file, never redesign it
    - For Gemini prompts: always include the line "Add Mamoun Alamouri logo (MA orange circle on black) to top-left corner"
11. Save to posts-[DATE] folder structure
12. Create INDEX.md in the posts-[DATE] folder. It must contain:
    - Session variables: topic, platform, funnel stage, style, language, content type
    - Table of all posts generated with scores and GHL status
    - Table of all visuals with format and file location
    - Any notes or decisions made during the session
13. Push all 3 as drafts to GHL (Mamoun Alamouri ps, Chrome automation)
14. Open Canva Upload dialog for carousel import
15. Deliver with computer:// links

Never stop. Never ask. Just execute.
