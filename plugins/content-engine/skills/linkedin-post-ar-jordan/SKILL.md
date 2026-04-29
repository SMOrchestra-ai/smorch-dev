---
name: linkedin-post-ar-jordan
description: "Jordanian Arabic LinkedIn post writer for Mamoun Alamouri. Requires brand-voice-smorchestra and content-quality-rubric loaded first. Two types: AI/Claude posts and MicroSaaS training hype posts. Jordanian/Levantine dialect only. Min 9/10 quality gate."
---

# LinkedIn Post — Jordanian Arabic

## Dependencies
1. brand-voice-smorchestra — load first
2. content-quality-rubric — load second

## Platform Rules
- Max 130 words per post
- No hashtags. Max 1 emoji at end (optional).
- One line = one idea. Always.
- RTL direction always.

## Two Post Types

### Type 1: AI/Claude Posts
Topic: AI tools, Claude, automation in real business.
Tone: Authority or Contrarian.
Goal: Teach something specific. Build authority.

### Type 2: MicroSaaS Training Hype
Topic: Building MicroSaaS using Claude as operating system, in a weekend.
Tone: Narrative or Contrarian.
Goal: Build curiosity for training. NEVER sell directly.

## Post Structure — AI/Claude
```
[هوك — جملة وحدة. بيان مش سؤال.]

[النفي المتكرر — اختياري بس قوي]
مش [X]. مش [Y]. مش [Z].
[الإجابة الحقيقية.]

← [نقطة أولى]
← [نقطة ثانية]
← [نقطة ثالثة]

[جملة ختامية + CTA]
```

## Post Structure — MicroSaaS Hype
```
[هوك — ألم حقيقي أو لحظة شخصية]

[القصة — 2-3 أسطر. شخصي. دافي.]

[ربط ناعم للتدريب]
"هاد تحديداً اللي رح أشرحه."
أو "قريباً رح أفتح لعدد محدود."

[سؤال CTA]
```

## Dialect Rules
- هاد / هاي / هدول (مش هذا / هذه / هؤلاء)
- شو (مش ماذا) | وين (مش أين) | ليش (مش لماذا)
- بدي / رح / لازم / ضل / هلأ / بس / كمان
- أدوات بالإنجليزي: Claude, Cowork, n8n, GHL, Clay
- مصطلحات بالإنجليزي: Context, SOP, ICP, MicroSaaS, GTM
- الأرقام: ٣ مش ثلاثة
- السهم للقوائم: ← (لليسار للعربي)

## Hype Post Rules
ممنوع: "سارع بالتسجيل" / "لا تفوّت" / "عرض محدود" / "تدريب" مباشرة في كل بوست
مسموح: "رح أفتح لعدد محدود" / "قريباً رح أشارك الطريقة"

## Quality Gate
1. forbidden-phrases-ar.md check
2. Score with content-quality-rubric (Arabic dimensions)
3. Min 9.0 average
4. Show score table + path to 10/10

See references/ for Jordanian markers, RTL punctuation, code-switching.
See examples/ for 9.2 AI/Claude post and 9.1 MicroSaaS hype post.

## Good Lookalikes (from context/)
Real Mamoun Arabic posts that scored 9+ live under
`../../context/Arabic-Claude-MicroSaaS/good-lookalikes/` (PDFs/images) and the
scored runs `../../context/Arabic-Claude-MicroSaaS/posts-2026-04-09|12|13/`.
Mine those for hooks, dialect cadence, and CTA patterns when calibrating.
