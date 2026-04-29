# Content Engine Plugin v2.0

## What This Does
Transforms any transcript into LinkedIn-ready content for Mamoun Alamouri.
Posts are quality scored, visuals generated, and pushed to GHL as drafts.

## How to Install
This plugin is registered in the smorch-dev marketplace at the repo root
(`.claude-plugin/marketplace.json`). Install via Claude Code:

```
/plugin marketplace add SMOrchestra-ai/smorch-dev
/plugin install content-engine
```

## How to Use
1. Open Cowork + add the Mamoun-Context folder.
2. Say "Brand Start".
3. Answer the 7 setup questions.
4. Paste the transcript.
5. Everything runs automatically.

## Skills Included
1. **brand-voice-smorchestra** — voice, forbidden phrases, MENA vocabulary. Foundation skill, always loads first.
2. **content-quality-rubric** — 8-dimension scorer. Foundation skill.
3. **linkedin-post-en** — English LinkedIn posts.
4. **linkedin-post-ar-jordan** — Jordanian Arabic LinkedIn posts.

## Rules
- Min score to ship: **9.0/10**.
- Input: transcript only (VTT, SRT, text, PDF).
- GHL: always **draft**, never publish directly.
- Profile: Mamoun Alamouri personal LinkedIn — **NOT** SMOrchestra.
- Location ID: `7IYdMpQvOejcQmZdDjAQ`.
- No hashtags. No em dashes.

## Layout
```
plugins/content-engine/
  .claude-plugin/plugin.json
  README.md
  assets/                    # logo + carousel last-slide EN/AR (PNG)
  skills/
    brand-voice-smorchestra/
    content-quality-rubric/
    linkedin-post-en/
    linkedin-post-ar-jordan/
  context/                   # founder profile, good-lookalikes, scored examples
```
