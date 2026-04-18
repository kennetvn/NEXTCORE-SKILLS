# NextCoreSkill — one-command installer for Windows / PowerShell
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex
#   or locally:
#   .\install.ps1 [-Target <path>] [-Update] [-Minimal] [-Force]

param(
    [string]$Target = "$(Get-Location)\.claude",
    [switch]$Update,
    [string]$Ide = "claude-code",
    [switch]$Minimal,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$NcSource = if ($env:NC_SOURCE) { $env:NC_SOURCE } else { $ScriptDir }
$NcRepo = if ($env:NC_REPO) { $env:NC_REPO } else { "https://github.com/kennetvn/NEXTCORE-SKILLS" }

function Log { param($msg) Write-Host "[nc] $msg" -ForegroundColor Green }
function Warn { param($msg) Write-Host "[nc] $msg" -ForegroundColor Yellow }
function Fail { param($msg) Write-Host "[nc] $msg" -ForegroundColor Red; exit 1 }

if ($Ide -ne "claude-code") { Fail "Only claude-code supported (requested: $Ide)" }

$Mode = if ($Update) { "update" } else { "fresh" }
Log "Installing NextCoreSkill -> $Target (mode: $Mode)"

# Detect source: local or remote
if (-not (Test-Path "$NcSource\skills")) {
    $TmpDir = Join-Path $env:TEMP "nextcoreskill-$(Get-Random)"
    Log "Cloning $NcRepo..."
    git clone --depth=1 $NcRepo $TmpDir | Out-Null
    if (-not $?) { Fail "Failed to clone $NcRepo" }
    $NcSource = $TmpDir
}

# Backup existing
if ((Test-Path $Target) -and ($Mode -eq "fresh") -and (-not $Force)) {
    Warn "$Target already exists"
    $reply = Read-Host "Backup and replace? [y/N]"
    if ($reply -notmatch '^[Yy]$') { Fail "Aborted" }
    $Backup = "$Target.backup.$([int](Get-Date -UFormat %s))"
    Move-Item $Target $Backup
    Log "Backed up to $Backup"
}

# Install
New-Item -ItemType Directory -Force -Path $Target | Out-Null
$Dirs = @("hooks", "skills", "agents", "commands", "output-styles", "rules", "schemas", "scripts")
foreach ($dir in $Dirs) {
    $src = Join-Path $NcSource $dir
    $dst = Join-Path $Target $dir
    if (Test-Path $src) {
        if (($Mode -eq "update") -and (Test-Path $dst)) {
            robocopy $src $dst /E /XC /XN /XO /NFL /NDL /NJH /NJS | Out-Null
        } else {
            Copy-Item -Recurse -Force $src $dst
        }
    }
}

# Copy root files
$Files = @("settings.json", "statusline.cjs", ".nc.json", "metadata.json", ".env.example")
foreach ($f in $Files) {
    $src = Join-Path $NcSource $f
    $dst = Join-Path $Target $f
    if (Test-Path $src) {
        if (($Mode -eq "update") -and (Test-Path $dst)) {
            Warn "Kept existing $f (update mode)"
        } else {
            Copy-Item -Force $src $dst
        }
    }
}

# Minimal mode
if ($Minimal) {
    Log "Minimal mode: removing venv/node_modules..."
    Get-ChildItem "$Target\skills" -Recurse -Directory -Filter ".venv" | Remove-Item -Recurse -Force
    Get-ChildItem "$Target\skills" -Recurse -Directory -Filter "node_modules" | Remove-Item -Recurse -Force
}

# Cleanup
if ($TmpDir -and (Test-Path $TmpDir)) { Remove-Item -Recurse -Force $TmpDir }

# Summary
$SkillCount = (Get-ChildItem "$Target\skills" -Directory).Count
$HookCount = (Get-ChildItem "$Target\hooks" -Filter "*.cjs" -File).Count

Log "Done!"
Write-Host ""
Write-Host "Installed:" -ForegroundColor Cyan
Write-Host "  Target:   $Target"
Write-Host "  Skills:   $SkillCount"
Write-Host "  Hooks:    $HookCount"
Write-Host "  Mode:     $Mode"
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  1. Restart Claude Code to load new skills/hooks"
Write-Host "  2. Check status: /nc:help"
Write-Host "  3. Configure: edit $Target\.nc.json"
Write-Host "  4. (Optional) Copy env template: cp $Target\.env.example $Target\.env"
