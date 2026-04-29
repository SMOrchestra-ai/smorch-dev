# Content Engine — Context

This folder holds the canonical voice + reference material the content-engine
plugin's skills depend on at runtime.

## What's here (text — checked in)
```
Arabic-Claude-MicroSaaS/
  mamoun-founder.md         # founder profile, thesis, decision framework
  mamoun-voice-arabic.md    # Arabic tone guide (used by linkedin-post-ar-jordan)
```

## What still needs to land here (binary / bulk — moved manually)
The full extracted `context\Arabic-Claude-MicroSaaS\` tree from the upload also
contains:
- `good-lookalikes/` — real Mamoun posts that scored 9+ (PDF/JPG/GIF). Used by
  linkedin-post-ar-jordan as calibration anchors.
- `carousel-slides-brand/` — brand carousel reference (PNG, slides 00-10).
- `posts-2026-04-09|12|13/` — scored production runs (post.md + prompt.md +
  score.md per post, plus per-post `slides-v2/` PNG sets).
- `instructions.md`, `brand-start.md`, `readme.md`,
  `skill-arabic-claude-microsaas.md` — pre-migration instructions kept for
  reference.

These live at `..\..\context 1\context\Arabic-Claude-MicroSaaS\` until the
move-binaries PowerShell at the end of the injection runbook ships them here.

## Move command (binaries + remaining text)
From a PowerShell window at the repo root:

```powershell
# Move all remaining context content under the plugin
robocopy ".\context 1\context\Arabic-Claude-MicroSaaS" `
         ".\plugins\content-engine\context\Arabic-Claude-MicroSaaS" /E /MOVE
robocopy ".\context 1\context\mamoun-content-engine" `
         ".\plugins\content-engine\context\mamoun-content-engine" /E /MOVE
Move-Item ".\context 1\context\audit-report-2026-04-14.md" `
          ".\plugins\content-engine\context\"
Move-Item ".\context 1\context\cleanup-log-2026-04-14.md" `
          ".\plugins\content-engine\context\"

# Move plugin assets (PNG logo + last-slide EN/AR)
robocopy ".\content-engine-plugin (2) 1\content-engine-plugin\assets" `
         ".\plugins\content-engine\assets" /E /MOVE

# Clean up extraction wrappers
Remove-Item ".\context 1" -Recurse -Force
Remove-Item ".\content-engine-plugin (2) 1" -Recurse -Force
```
