---
name: linkedin-post-en
description: "English LinkedIn post writer for Mamoun Alamouri. Requires brand-voice-smorchestra and content-quality-rubric loaded first. Produces scroll-stopping English LinkedIn posts across AI/Claude, GTM, MicroSaaS, and Signal topics. Min 9/10 quality gate."
---

# LinkedIn Post — English

## Dependencies
1. brand-voice-smorchestra — load first
2. content-quality-rubric — load second

## Platform Rules
- Max 3000 characters (run count_chars.py before delivering)
- No hashtags. No emojis. No em dashes.
- Short paragraphs: 1-3 lines max
- Mobile-first: every line works on a phone screen

## Post Structure
```
[HOOK — 1-2 lines. Contrarian, specific, scroll-stopping.]

[CONTEXT — 2-3 lines. Problem setup. MENA when relevant.]

1/ [Bold title]
→ [2-4 short lines. Insight + proof.]

2/ [Bold title]
→ [2-4 short lines.]

3/ [Bold title]
→ [2-4 short lines.]

[CLOSING PUNCH — 1-2 lines. Ties back to hook.]

DM me "[KEYWORD]" — I'll send you [specific deliverable].

P.S. [Question that invites comments?]
```

## Format Rules
- Numbered sections: `1/` format ONLY. Never `1.` or `Step 1:`
- Sub-bullets: `→` ONLY. Never `-` or `•`
- Line breaks: empty line between every block

## Topic Rules

### AI / Claude
- Name exact feature: Cowork, Claude Code, Skills, Projects
- Show before/after: "3 hours → 20 minutes"
- Always tie to business outcome: pipeline, revenue, time saved
- MENA angle where possible

### GTM / Signal
- Reference 7-11-4 and Dream 100 naturally
- Name the signal source: LinkedIn post, job change, funding round
- Always: specific company size, market, result

### MicroSaaS
- Tools: Claude + n8n + GHL as standard stack
- Timeline always specific: "weekend," "72 hours," "3 weeks"
- Never: "passive income," "build while you sleep"

## Quality Gate
1. Run forbidden-phrases-en.md check
2. Score with content-quality-rubric
3. Min 9.0 weighted average
4. Show score table + path to 10/10
5. If below 9.0: fix and rescore before delivering

See examples/ for 9.1 AI topic and 9.0 GTM topic posts.
See references/ for algorithm rules and P.S. line conventions.
