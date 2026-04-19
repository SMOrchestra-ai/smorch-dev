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

# Install plugins (manual copy — PowerShell equivalent of install-plugins.sh)
Write-Host "`n→ Installing Claude Code plugins…"
New-Item -ItemType Directory -Path $ClaudePluginsDir -Force | Out-Null

foreach ($plugin in @("smorch-dev", "smorch-ops")) {
    $src = "$RepoDir\plugins\$plugin"
    $dst = "$ClaudePluginsDir\$plugin"
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    Copy-Item -Recurse $src $dst
    Write-Host "  installed: $plugin"
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
Write-Host "  smorch-dev plugin: $(if (Test-Path "$ClaudePluginsDir\smorch-dev") {'✓'} else {'✗'})"
Write-Host "  smorch-ops plugin: $(if (Test-Path "$ClaudePluginsDir\smorch-ops") {'✓'} else {'✗'})"
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
