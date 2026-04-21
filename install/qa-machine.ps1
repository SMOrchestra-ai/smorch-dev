# Install profile: QA machine (Lana, Windows).
# Full toolkit: smorch-dev + smorch-ops + gstack + superpowers + cron sync (via Task Scheduler).
# Run as Administrator in PowerShell.

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════════════════╗"
Write-Host "║  SMOrchestra QA Machine Setup (Windows)                      ║"
Write-Host "║  Lana: half QA + half Dev — full toolkit                     ║"
Write-Host "╚══════════════════════════════════════════════════════════════╝"

$RepoDir = if ($env:REPO_DIR) { $env:REPO_DIR } else { "$HOME\CodingProjects\smorch-dev" }
$ClaudePluginsDir = "$HOME\.claude\plugins"

# Ensure winget + git are present
Write-Host "`n→ Checking prereqs…"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install App Installer from Microsoft Store first."
    exit 1
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --source winget
}

# Node 22
Write-Host "`n→ Installing Node 22…"
if (-not (Get-Command node -ErrorAction SilentlyContinue) -or -not ((node --version) -match "v22")) {
    winget install --id OpenJS.NodeJS.LTS -e --source winget
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
Write-Host "  Node $(node --version)"

# Bun (Windows support)
Write-Host "`n→ Installing Bun…"
if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
    powershell -c "irm bun.sh/install.ps1 | iex"
    $env:Path = $env:USERPROFILE + "\.bun\bin;" + $env:Path
}
Write-Host "  Bun $(bun --version)"

# Claude Code
Write-Host "`n→ Installing Claude Code…"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    npm install -g '@anthropic-ai/claude-code'
}
Write-Host "  Claude Code $(claude --version)"

# gh
Write-Host "`n→ Installing GitHub CLI…"
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    winget install --id GitHub.cli -e --source winget
}

# Clone smorch-dev
Write-Host "`n→ Cloning smorch-dev…"
if (-not (Test-Path $RepoDir)) {
    New-Item -ItemType Directory -Path (Split-Path $RepoDir) -Force | Out-Null
    git clone https://github.com/SMOrchestra-ai/smorch-dev.git $RepoDir
} else {
    Push-Location $RepoDir; git pull --quiet origin main; Pop-Location
}

# Install plugins via Claude Code marketplace (proper registration path)
Write-Host "`n→ Registering smorch-dev marketplace + installing plugins…"

# Add marketplace (one-time, idempotent)
$marketplaceList = claude plugin marketplace list 2>$null
if ($marketplaceList -notmatch "smorch-dev") {
    claude plugin marketplace add SMOrchestra-ai/smorch-dev
} else {
    claude plugin marketplace update smorch-dev | Out-Null
    Write-Host "  marketplace smorch-dev already registered — refreshed"
}

foreach ($plugin in @("smorch-dev", "smorch-ops")) {
    claude plugin install "$plugin@smorch-dev" 2>&1 | Select-Object -Last 1
    Write-Host "  installed: $plugin"
}

# Patch ~/.claude/CLAUDE.md + lessons.md with L-009 push-discipline rule
Write-Host "`n→ Patching ~/.claude/CLAUDE.md + lessons.md with L-009…"
$ClaudeDir = "$HOME\.claude"
$ClaudeMd = "$ClaudeDir\CLAUDE.md"
$LessonsMd = "$ClaudeDir\lessons.md"
$SentinelClaude = "<!-- L-009-PUSH-DISCIPLINE -->"
$SentinelLessons = "### L-009 — GitHub is the single point of truth"

New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

$L009Claude = @'

<!-- L-009-PUSH-DISCIPLINE -->
- Push discipline (L-009): GitHub remote is the single authoritative source of truth. Claude acts as lead architect — at the end of every work unit, commit + push + open PR + merge + tag + update any version references downstream scripts read. Do NOT ask "want me to open the PR?" — do it. Only escalate to CEO when: (a) force push / hard reset / branch delete, (b) deploys to smo-prod or eo-prod, (c) cross-repo edits that affect someone else's in-flight work, (d) anything touching customer data or secrets. Everything else: act. If blocked by approval, flag drift risk every turn until resolved — never carry silent drift.
'@

$L009Lessons = @'

### L-009 — GitHub is the single point of truth. Always commit AND push. No excuses.
- **Captured:** 2026-04-21
- **Trigger:** Shipped a full v1.1.0 upgrade to a plugin but left every change uncommitted — local worktree held the work, GitHub remote was stale. Other machines, cron syncs, install.sh flows never saw it. GitHub drift pattern.
- **Rule:** GitHub remote is the single authoritative source of truth for every SMOrchestra repo. A change that exists only in a local worktree is invisible work.
  - **Default behavior:** at end of every work unit → commit + push + open PR + merge + tag + bump downstream version refs. No "shall I push?" prompts.
  - **Claude acts as CPO / lead architect,** not subordinate. Only escalate to CEO for: (a) force push / hard reset / branch delete, (b) deploys to smo-prod or eo-prod, (c) cross-repo edits affecting someone else's in-flight work, (d) customer data or secrets.
  - **When approval needed:** flag drift risk every turn until resolved.
  - **WIP checkpoints:** push mid-stream on feature branches for multi-hour work.
- **Check:** every turn ending a work unit → mental `git status`. If dirty → commit + push same turn, or flag drift.
- **Last triggered:** 2026-04-21
'@

if (-not (Test-Path $ClaudeMd)) {
    "GLOBAL INSTRUCTIONS — SMOrchestra.ai`n`n## GIT + DEPLOYMENT" | Set-Content -Path $ClaudeMd -Encoding UTF8
}
if (-not (Select-String -Path $ClaudeMd -Pattern ([regex]::Escape($SentinelClaude)) -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path $ClaudeMd -Value $L009Claude -Encoding UTF8
    Write-Host "  appended L-009 to CLAUDE.md"
} else {
    Write-Host "  L-009 already present in CLAUDE.md — skipped"
}

if (-not (Test-Path $LessonsMd)) {
    "# Global Lessons — ~/.claude/lessons.md`n**Auto-loaded at SessionStart.**`n`n## Active lessons`n" | Set-Content -Path $LessonsMd -Encoding UTF8
}
if (-not (Select-String -Path $LessonsMd -Pattern ([regex]::Escape($SentinelLessons)) -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path $LessonsMd -Value $L009Lessons -Encoding UTF8
    Write-Host "  appended L-009 to lessons.md"
} else {
    Write-Host "  L-009 already present in lessons.md — skipped"
}

# Upstream: gstack + superpowers (clone as skills)
$ClaudeSkillsDir = "$HOME\.claude\skills"
New-Item -ItemType Directory -Path $ClaudeSkillsDir -Force | Out-Null

foreach ($pair in @(
    @{Name="gstack"; Repo="https://github.com/garrytan/gstack.git"},
    @{Name="superpowers"; Repo="https://github.com/obra/superpowers.git"}
)) {
    $dst = "$ClaudeSkillsDir\$($pair.Name)"
    if (-not (Test-Path $dst)) {
        git clone --depth 1 $pair.Repo $dst
    } else {
        Push-Location $dst; git pull --quiet origin main; Pop-Location
    }
    Write-Host "  installed: $($pair.Name)"
}

# smorch-brain clone
$BrainDir = "$HOME\smorch-brain"
if (-not (Test-Path $BrainDir)) {
    git clone git@github.com:SMOrchestra-ai/smorch-brain.git $BrainDir
}

# Task Scheduler for 30-min sync (Windows equivalent of cron)
Write-Host "`n→ Configuring scheduled sync (every 30 min)…"
$TaskName = "SmorchDevSync"
$ScriptPath = "$RepoDir\scripts\sync-from-github.sh"
$LogPath = "$HOME\.claude\sync.log"

# Use bash (from Git for Windows) to run the sync script
$BashPath = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $BashPath)) { $BashPath = "bash" }

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
$action = New-ScheduledTaskAction -Execute $BashPath -Argument "`"$ScriptPath`" >> `"$LogPath`" 2>&1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 30)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType S4U
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal | Out-Null
Write-Host "  Task Scheduler entry: $TaskName (every 30 min)"

Write-Host "`n════════════════════════════════════════════════"
Write-Host "  Verification"
Write-Host "════════════════════════════════════════════════"
Write-Host "  Node:              $(node --version 2>$null)"
Write-Host "  Claude Code:       $(claude --version 2>$null)"
Write-Host "  gh:                $(gh --version 2>$null | Select-Object -First 1)"
$installed = claude plugin list 2>$null
Write-Host "  smorch-dev plugin: $(if ($installed -match 'smorch-dev@smorch-dev') {'✓'} else {'✗'})"
Write-Host "  smorch-ops plugin: $(if ($installed -match 'smorch-ops@smorch-dev') {'✓'} else {'✗'})"
Write-Host "  gstack:            $(if (Test-Path "$ClaudeSkillsDir\gstack") {'✓'} else {'✗'})"
Write-Host "  superpowers:       $(if (Test-Path "$ClaudeSkillsDir\superpowers") {'✓'} else {'✗'})"
Write-Host "  smorch-brain:      $(if (Test-Path $BrainDir) {'✓'} else {'✗'})"
Write-Host "  Scheduled sync:    $(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty State)"
Write-Host ""
Write-Host "  Next:"
Write-Host "  1. cd to any project dir"
Write-Host "  2. Run: claude"
Write-Host "  3. Type /smo to see 17 commands in autocomplete"
Write-Host "  4. First QA task: /smo-qa-handover-score on any pending handover"
Write-Host ""
