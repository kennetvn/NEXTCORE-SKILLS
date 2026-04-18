# NextCoreSkill - one-command installer for Windows / PowerShell
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex
#   or locally:
#   .\install.ps1 [-Target <path>] [-Update] [-Ide <name>] [-Minimal] [-Force]
#
# IDE: claude-code (default) | antigravity | cursor | windsurf

param(
    [string]$Target = "",
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

$SupportedIdes = @("claude-code", "antigravity", "cursor", "windsurf", "copilot", "continue", "aider", "zed", "jetbrains", "void")
if ($SupportedIdes -notcontains $Ide) {
    Fail "Unsupported IDE: $Ide (supported: $($SupportedIdes -join ', '))"
}

if ([string]::IsNullOrEmpty($Target)) {
    switch ($Ide) {
        "claude-code" { $Target = "$(Get-Location)\.claude" }
        "antigravity" { $Target = "$(Get-Location)\.agent" }
        "cursor"      { $Target = "$(Get-Location)\.cursor" }
        "windsurf"    { $Target = "$(Get-Location)\.windsurf" }
        "copilot"     { $Target = "$(Get-Location)\.github" }
        "continue"    { $Target = "$(Get-Location)\.continue" }
        "aider"       { $Target = "$(Get-Location)\.aider\nextcore" }
        "zed"         { $Target = "$(Get-Location)\.zed" }
        "jetbrains"   { $Target = "$(Get-Location)\.idea\ai-prompts" }
        "void"        { $Target = "$(Get-Location)\.void" }
    }
}

$Mode = if ($Update) { "update" } else { "fresh" }
Log "Installing NextCoreSkill for $Ide -> $Target (mode: $Mode)"

if (-not (Test-Path "$NcSource\skills")) {
    $TmpDir = Join-Path $env:TEMP "nc-install-$(Get-Random)"
    New-Item -ItemType Directory -Path $TmpDir | Out-Null
    Log "Cloning $NcRepo..."
    & git clone --depth=1 $NcRepo $TmpDir 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Failed to clone $NcRepo" }
    $NcSource = $TmpDir
}

if ((Test-Path $Target) -and ($Mode -eq "fresh") -and (-not $Force)) {
    Warn "$Target already exists"
    $confirm = Read-Host "Backup and replace? [y/N]"
    if ($confirm -notmatch '^[Yy]') { Fail "Aborted" }
    $Backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -Path $Target -Destination $Backup
    Log "Backed up to $Backup"
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null

if ($Ide -eq "claude-code") {
    $dirs = @("hooks", "skills", "agents", "commands", "output-styles", "rules", "schemas", "scripts")
    foreach ($dir in $dirs) {
        $srcDir = Join-Path $NcSource $dir
        $dstDir = Join-Path $Target $dir
        if (Test-Path $srcDir) {
            if (($Mode -eq "update") -and (Test-Path $dstDir)) {
                Copy-Item -Path "$srcDir\*" -Destination $dstDir -Recurse -Force:$false -ErrorAction SilentlyContinue
            } else {
                Copy-Item -Path $srcDir -Destination $Target -Recurse -Force
            }
        }
    }

    $rootFiles = @("settings.json", "statusline.cjs", ".nc.json", "metadata.json", ".env.example")
    foreach ($f in $rootFiles) {
        $srcFile = Join-Path $NcSource $f
        $dstFile = Join-Path $Target $f
        if (Test-Path $srcFile) {
            if (($Mode -eq "update") -and (Test-Path $dstFile)) {
                Warn "Kept existing $f (update mode)"
            } else {
                Copy-Item -Path $srcFile -Destination $dstFile -Force
            }
        }
    }

    if ($Minimal) {
        Log "Minimal mode: removing skill scripts/venvs..."
        Get-ChildItem -Path "$Target\skills" -Recurse -Directory -Filter ".venv" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$Target\skills" -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    $SkillCount = (Get-ChildItem -Path "$Target\skills" -Directory -ErrorAction SilentlyContinue).Count
    $HookCount = (Get-ChildItem -Path "$Target\hooks" -Filter "*.cjs" -ErrorAction SilentlyContinue).Count

} elseif ($Ide -eq "antigravity") {
    $SrcWorkflows = Join-Path $NcSource "adapters\antigravity\workflows"
    if (-not (Test-Path $SrcWorkflows)) { Fail "Adapter source missing: $SrcWorkflows" }

    $DstWorkflows = Join-Path $Target "workflows"
    New-Item -ItemType Directory -Path $DstWorkflows -Force | Out-Null

    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcWorkflows\*" -Destination $DstWorkflows -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcWorkflows\*" -Destination $DstWorkflows -Recurse -Force
    }

    if ($Minimal) { Warn "-Minimal ignored for antigravity (no skill assets to trim)" }

    $SkillCount = (Get-ChildItem -Path $DstWorkflows -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0

} elseif ($Ide -eq "cursor") {
    $SrcCmds = Join-Path $NcSource "adapters\cursor\commands"
    if (-not (Test-Path $SrcCmds)) { Fail "Adapter source missing: $SrcCmds" }

    $DstCmds = Join-Path $Target "commands"
    New-Item -ItemType Directory -Path $DstCmds -Force | Out-Null

    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcCmds\*" -Destination $DstCmds -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcCmds\*" -Destination $DstCmds -Recurse -Force
    }

    if ($Minimal) { Warn "-Minimal ignored for cursor (no skill assets to trim)" }

    $SkillCount = (Get-ChildItem -Path $DstCmds -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0

} elseif ($Ide -eq "windsurf") {
    $SrcWF = Join-Path $NcSource "adapters\windsurf\workflows"
    if (-not (Test-Path $SrcWF)) { Fail "Adapter source missing: $SrcWF" }

    $DstWF = Join-Path $Target "workflows"
    New-Item -ItemType Directory -Path $DstWF -Force | Out-Null

    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcWF\*" -Destination $DstWF -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcWF\*" -Destination $DstWF -Recurse -Force
    }

    if ($Minimal) { Warn "-Minimal ignored for windsurf (no skill assets to trim)" }

    $SkillCount = (Get-ChildItem -Path $DstWF -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0

} elseif ($Ide -eq "copilot") {
    $SrcPR = Join-Path $NcSource "adapters\copilot\prompts"
    if (-not (Test-Path $SrcPR)) { Fail "Adapter source missing: $SrcPR" }
    $DstPR = Join-Path $Target "prompts"
    New-Item -ItemType Directory -Path $DstPR -Force | Out-Null
    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcPR\*" -Destination $DstPR -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcPR\*" -Destination $DstPR -Recurse -Force
    }
    if ($Minimal) { Warn "-Minimal ignored for copilot (no skill assets to trim)" }
    $SkillCount = (Get-ChildItem -Path $DstPR -Filter "nc-*.prompt.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0
}

} elseif ($Ide -eq "continue") {
    $SrcCPR = Join-Path $NcSource "adapters\continue\prompts"
    if (-not (Test-Path $SrcCPR)) { Fail "Adapter source missing: $SrcCPR" }
    $DstCPR = Join-Path $Target "prompts"
    New-Item -ItemType Directory -Path $DstCPR -Force | Out-Null
    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcCPR\*" -Destination $DstCPR -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcCPR\*" -Destination $DstCPR -Recurse -Force
    }
    $SkillCount = (Get-ChildItem -Path $DstCPR -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0

} elseif ($Ide -eq "aider") {
    $SrcAP = Join-Path $NcSource "adapters\aider\prompts"
    $SrcAC = Join-Path $NcSource "adapters\aider\conventions"
    if (-not (Test-Path $SrcAP)) { Fail "Adapter source missing: $SrcAP" }
    $DstAP = Join-Path $Target "prompts"
    New-Item -ItemType Directory -Path $DstAP -Force | Out-Null
    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcAP\*" -Destination $DstAP -Recurse -Force:$false -ErrorAction SilentlyContinue
        Copy-Item -Path "$SrcAC\*" -Destination $Target -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcAP\*" -Destination $DstAP -Recurse -Force
        Copy-Item -Path "$SrcAC\*" -Destination $Target -Force
    }
    $SkillCount = (Get-ChildItem -Path $DstAP -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0
}

} elseif ($Ide -in @("zed","jetbrains","void")) {
    $SrcX = Join-Path $NcSource "adapters\$Ide\prompts"
    if (-not (Test-Path $SrcX)) { Fail "Adapter source missing: $SrcX" }
    $DstX = Join-Path $Target "prompts"
    New-Item -ItemType Directory -Path $DstX -Force | Out-Null
    if ($Mode -eq "update") {
        Copy-Item -Path "$SrcX\*" -Destination $DstX -Recurse -Force:$false -ErrorAction SilentlyContinue
    } else {
        Copy-Item -Path "$SrcX\*" -Destination $DstX -Recurse -Force
    }
    $SkillCount = (Get-ChildItem -Path $DstX -Filter "nc-*.md" -ErrorAction SilentlyContinue).Count
    $HookCount = 0
}

if ($TmpDir -and (Test-Path $TmpDir)) {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}

Log "Done!"
Write-Host ""
Write-Host "Installed:" -ForegroundColor Cyan
Write-Host "  IDE:      $Ide"
Write-Host "  Target:   $Target"

if ($Ide -eq "claude-code") {
    Write-Host "  Skills:   $SkillCount"
    Write-Host "  Hooks:    $HookCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Claude Code to load hooks + skills"
    Write-Host "  2. Type /nc: in chat to see available slash commands"
} elseif ($Ide -eq "antigravity") {
    Write-Host "  Workflows: $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Antigravity to discover new workflows"
    Write-Host "  2. Type /nc- in chat to see available slash commands"
} elseif ($Ide -eq "cursor") {
    Write-Host "  Commands: $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Cursor to discover new slash commands"
    Write-Host "  2. Type /nc- in chat to see available commands"
} elseif ($Ide -eq "windsurf") {
    Write-Host "  Workflows: $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Windsurf to discover new workflows"
    Write-Host "  2. Type /nc- in chat to see available commands"
} elseif ($Ide -eq "copilot") {
    Write-Host "  Prompts:   $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Enable chat.promptFiles in VS Code settings"
    Write-Host "  2. Add .github/prompts to chat.promptFilesLocations"
    Write-Host "  3. Reload VS Code, then type /nc- in Copilot Chat"
} elseif ($Ide -eq "continue") {
    Write-Host "  Prompts:  $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Continue extension"
    Write-Host "  2. Type /nc- in Continue chat"
} elseif ($Ide -eq "aider") {
    Write-Host "  Prompts:  $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. aider --read .aider/nextcore/nextcore-conventions.md"
    Write-Host "  2. /read .aider/nextcore/prompts/nc-plan.md (or any workflow)"
} elseif ($Ide -in @("zed","jetbrains","void")) {
    Write-Host "  Prompts:  $SkillCount"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart $Ide IDE"
    Write-Host "  2. Type /nc- in the IDE chat"
}

# v2.6.0+: onboarding tip
Write-Host ""
Write-Host "Tip:" -ForegroundColor Cyan -NoNewline
Write-Host " Run /nc-onboard in your IDE for a 1-min profile setup (3 questions, calibrates persona/language/depth)."
