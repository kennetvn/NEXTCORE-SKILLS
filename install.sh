#!/usr/bin/env bash
# NextCoreSkill — one-command installer
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash
#   or locally:
#   ./install.sh [--target=PATH] [--update] [--ide=IDE] [--minimal]
#
# Options:
#   --target=PATH   Install path (default: .claude for Claude Code, .agent for Antigravity)
#   --update        Update existing install (preserve user overrides)
#   --ide=NAME      Target IDE: claude-code (default) | antigravity
#   --minimal       Install core hooks + essential skills only (Claude Code only)
#   --force         Overwrite existing target without prompt
#   --skills=LIST   Install only specific skills (comma-separated, Claude Code only)
#
# Environment:
#   NC_SOURCE       Source directory (default: this script's parent)
#   NC_REPO         Git repo (https://github.com/kennetvn/NEXTCORE-SKILLS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NC_SOURCE="${NC_SOURCE:-$SCRIPT_DIR}"
NC_REPO="${NC_REPO:-https://github.com/kennetvn/NEXTCORE-SKILLS}"

TARGET=""
MODE="fresh"
IDE="claude-code"
MINIMAL=false
FORCE=false
SKILLS=""

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
log() { echo -e "${G}[nc]${NC} $1"; }
warn() { echo -e "${Y}[nc]${NC} $1"; }
err() { echo -e "${R}[nc]${NC} $1" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#*=}" ;;
    --update)   MODE="update" ;;
    --ide=*)    IDE="${arg#*=}" ;;
    --minimal)  MINIMAL=true ;;
    --force)    FORCE=true ;;
    --skills=*) SKILLS="${arg#*=}" ;;
    --help|-h)  grep '^#' "$0" | head -22 ; exit 0 ;;
    *) err "Unknown arg: $arg" ;;
  esac
done

# Default target based on IDE

# Auto-detect IDE if not specified (based on existing directories)
if [ "$IDE" = "claude-code" ] && [ -z "$TARGET" ] && [ $# -eq 0 ]; then
  if   [ -d "${PWD}/.agent/workflows" ];    then IDE="antigravity"; log "Auto-detected: antigravity"
  elif [ -d "${PWD}/.cursor" ];              then IDE="cursor";      log "Auto-detected: cursor"
  elif [ -d "${PWD}/.windsurf" ];            then IDE="windsurf";    log "Auto-detected: windsurf"
  elif [ -d "${PWD}/.continue" ];            then IDE="continue";    log "Auto-detected: continue"
  elif [ -d "${PWD}/.zed" ];                 then IDE="zed";         log "Auto-detected: zed"
  elif [ -d "${PWD}/.void" ];                then IDE="void";        log "Auto-detected: void"
  elif [ -d "${PWD}/.idea" ];                then IDE="jetbrains";   log "Auto-detected: jetbrains"
  elif [ -d "${PWD}/.aider" ];               then IDE="aider";       log "Auto-detected: aider"
  elif [ -d "${PWD}/.github" ] && [ -f "${PWD}/.github/copilot-instructions.md" ]; then IDE="copilot"; log "Auto-detected: copilot"
  fi
fi
if [ -z "$TARGET" ]; then
  case "$IDE" in
    claude-code) TARGET="${PWD}/.claude" ;;
    antigravity) TARGET="${PWD}/.agent" ;;
    cursor)      TARGET="${PWD}/.cursor" ;;
    windsurf)    TARGET="${PWD}/.windsurf" ;;
    copilot)     TARGET="${PWD}/.github" ;;
    continue)    TARGET="${PWD}/.continue" ;;
    aider)       TARGET="${PWD}/.aider/nextcore" ;;
    zed)         TARGET="${PWD}/.zed" ;;
    jetbrains)   TARGET="${PWD}/.junie" ;;
    void)        TARGET="${PWD}" ;;
    *) err "Unsupported IDE: $IDE (supported: claude-code, antigravity, cursor, windsurf, copilot, continue, aider, zed, jetbrains, void)" ;;
  esac
fi

case "$IDE" in
  claude-code|antigravity|cursor|windsurf|copilot|continue|aider|zed|jetbrains|void) ;;
  *) err "Unsupported IDE: $IDE (supported: claude-code, antigravity, cursor, windsurf, copilot, continue, aider, zed, jetbrains, void)" ;;
esac

log "Installing NextCoreSkill for $IDE → $TARGET (mode: $MODE)"

# Detect source: local dir or remote repo
if [ ! -d "$NC_SOURCE/skills" ]; then
  TMPDIR=$(mktemp -d)
  log "Cloning $NC_REPO..."
  git clone --depth=1 "$NC_REPO" "$TMPDIR" 2>/dev/null || err "Failed to clone $NC_REPO"
  NC_SOURCE="$TMPDIR"
fi

# Backup existing
if [ -d "$TARGET" ] && [ "$MODE" = "fresh" ] && [ "$FORCE" = false ]; then
  warn "$TARGET already exists"
  read -p "Backup and replace? [y/N] " -r
  [[ $REPLY =~ ^[Yy]$ ]] || err "Aborted"
  BACKUP="$TARGET.backup.$(date +%s)"
  mv "$TARGET" "$BACKUP"
  log "Backed up to $BACKUP"
fi

mkdir -p "$TARGET"

if [ "$IDE" = "claude-code" ]; then
  # Full Claude Code install: hooks + skills + agents + commands + hooks + settings
  if [ "$IDE" = "claude-code" ] && [ -n "$SKILLS" ]; then
    # Per-skill install: filter skills/ after full copy
    KEPT_SKILLS_FOR_CLEANUP="$SKILLS"
  fi

  for dir in hooks skills agents commands output-styles rules schemas scripts; do
    if [ -d "$NC_SOURCE/$dir" ]; then
      if [ "$MODE" = "update" ] && [ -d "$TARGET/$dir" ]; then
        rsync -a --ignore-existing "$NC_SOURCE/$dir/" "$TARGET/$dir/"
      else
        cp -r "$NC_SOURCE/$dir" "$TARGET/"
      fi
    fi
  done

  for f in settings.json statusline.cjs .nc.json metadata.json .env.example; do
    if [ -f "$NC_SOURCE/$f" ]; then
      if [ "$MODE" = "update" ] && [ -f "$TARGET/$f" ]; then
        warn "Kept existing $f (update mode)"
      else
        cp "$NC_SOURCE/$f" "$TARGET/"
      fi
    fi
  done

  chmod +x "$TARGET/hooks"/*.cjs 2>/dev/null || true
  chmod +x "$TARGET/scripts"/*.cjs 2>/dev/null || true
  chmod +x "$TARGET/statusline.cjs" 2>/dev/null || true

  # Per-skill filter: remove non-requested skills
  if [ -n "${KEPT_SKILLS_FOR_CLEANUP:-}" ]; then
    KEEP_CSV=",$KEPT_SKILLS_FOR_CLEANUP,"
    for skill_dir in "$TARGET/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name=$(basename "$skill_dir")
      case "$KEEP_CSV" in
        *",$skill_name,"*) ;;
        *) rm -rf "$skill_dir" ;;
      esac
    done
    log "Per-skill install: kept $KEPT_SKILLS_FOR_CLEANUP"
  fi

  if [ "$MINIMAL" = true ]; then
    log "Minimal mode: removing skill scripts/venvs..."
    find "$TARGET/skills" -name ".venv" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$TARGET/skills" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$TARGET/skills" -name ".coverage" -exec rm -f {} + 2>/dev/null || true
  fi

  SKILL_COUNT=$(find "$TARGET/skills" -maxdepth 1 -type d | wc -l)
  HOOK_COUNT=$(find "$TARGET/hooks" -maxdepth 1 -name "*.cjs" | wc -l)

elif [ "$IDE" = "antigravity" ]; then
  # Antigravity: just workflows + references from adapters/antigravity/
  SRC_WORKFLOWS="$NC_SOURCE/adapters/antigravity/workflows"
  [ -d "$SRC_WORKFLOWS" ] || err "Adapter source missing: $SRC_WORKFLOWS"

  mkdir -p "$TARGET/workflows"

  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_WORKFLOWS/" "$TARGET/workflows/"
  else
    cp -r "$SRC_WORKFLOWS"/* "$TARGET/workflows/"
  fi

  [ "$MINIMAL" = true ] && warn "--minimal ignored for antigravity (no skill assets to trim)"

  SKILL_COUNT=$(find "$TARGET/workflows" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "cursor" ]; then
  SRC_CMDS="$NC_SOURCE/adapters/cursor/commands"
  [ -d "$SRC_CMDS" ] || err "Adapter source missing: $SRC_CMDS"
  mkdir -p "$TARGET/commands"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_CMDS/" "$TARGET/commands/"
  else
    cp -r "$SRC_CMDS"/* "$TARGET/commands/"
  fi
  [ "$MINIMAL" = true ] && warn "--minimal ignored for cursor (no skill assets to trim)"
  SKILL_COUNT=$(find "$TARGET/commands" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "windsurf" ]; then
  SRC_WF="$NC_SOURCE/adapters/windsurf/workflows"
  [ -d "$SRC_WF" ] || err "Adapter source missing: $SRC_WF"
  mkdir -p "$TARGET/workflows"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_WF/" "$TARGET/workflows/"
  else
    cp -r "$SRC_WF"/* "$TARGET/workflows/"
  fi
  [ "$MINIMAL" = true ] && warn "--minimal ignored for windsurf (no skill assets to trim)"
  SKILL_COUNT=$(find "$TARGET/workflows" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "copilot" ]; then
  SRC_PR="$NC_SOURCE/adapters/copilot/prompts"
  [ -d "$SRC_PR" ] || err "Adapter source missing: $SRC_PR"
  mkdir -p "$TARGET/prompts"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_PR/" "$TARGET/prompts/"
  else
    cp -r "$SRC_PR"/* "$TARGET/prompts/"
  fi
  [ "$MINIMAL" = true ] && warn "--minimal ignored for copilot (no skill assets to trim)"
  SKILL_COUNT=$(find "$TARGET/prompts" -maxdepth 1 -name "nc-*.prompt.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "continue" ]; then
  SRC_CPR="$NC_SOURCE/adapters/continue/prompts"
  [ -d "$SRC_CPR" ] || err "Adapter source missing: $SRC_CPR"
  mkdir -p "$TARGET/prompts"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_CPR/" "$TARGET/prompts/"
  else
    cp -r "$SRC_CPR"/* "$TARGET/prompts/"
  fi
  [ "$MINIMAL" = true ] && warn "--minimal ignored for continue (no skill assets to trim)"
  SKILL_COUNT=$(find "$TARGET/prompts" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "aider" ]; then
  SRC_AP="$NC_SOURCE/adapters/aider/prompts"
  SRC_AC="$NC_SOURCE/adapters/aider/conventions"
  [ -d "$SRC_AP" ] || err "Adapter source missing: $SRC_AP"
  mkdir -p "$TARGET/prompts"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_AP/" "$TARGET/prompts/"
    rsync -a --ignore-existing "$SRC_AC/" "$TARGET/"
  else
    cp -r "$SRC_AP"/* "$TARGET/prompts/"
    cp "$SRC_AC"/*.md "$TARGET/"
  fi
  [ "$MINIMAL" = true ] && warn "--minimal ignored for aider (no skill assets to trim)"
  SKILL_COUNT=$(find "$TARGET/prompts" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "zed" ]; then
  SRC_X="$NC_SOURCE/adapters/zed/prompts"
  [ -d "$SRC_X" ] || err "Adapter source missing: $SRC_X"
  mkdir -p "$TARGET/prompts"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_X/" "$TARGET/prompts/"
  else
    cp -r "$SRC_X"/* "$TARGET/prompts/"
  fi
  SKILL_COUNT=$(find "$TARGET/prompts" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "jetbrains" ]; then
  SRC_AG="$NC_SOURCE/adapters/jetbrains/.junie/AGENTS.md"
  SRC_P="$NC_SOURCE/adapters/jetbrains/.junie/prompts"
  [ -f "$SRC_AG" ] || err "Missing: $SRC_AG"
  mkdir -p "$TARGET/prompts"
  cp "$SRC_AG" "$TARGET/"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_P/" "$TARGET/prompts/"
  else
    cp -r "$SRC_P"/* "$TARGET/prompts/"
  fi
  SKILL_COUNT=$(find "$TARGET/prompts" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0

elif [ "$IDE" = "void" ]; then
  SRC_AG="$NC_SOURCE/adapters/void/AGENTS.md"
  SRC_P="$NC_SOURCE/adapters/void/.vscode/prompts"
  [ -f "$SRC_AG" ] || err "Missing: $SRC_AG"
  mkdir -p "$TARGET/.vscode/prompts"
  cp "$SRC_AG" "$TARGET/"
  if [ "$MODE" = "update" ]; then
    rsync -a --ignore-existing "$SRC_P/" "$TARGET/.vscode/prompts/"
  else
    cp -r "$SRC_P"/* "$TARGET/.vscode/prompts/"
  fi
  SKILL_COUNT=$(find "$TARGET/.vscode/prompts" -maxdepth 1 -name "nc-*.md" | wc -l)
  HOOK_COUNT=0
fi

# Cleanup temp clone
[ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ] && rm -rf "$TMPDIR"

# Summary
log "Done!"
echo
echo -e "${C}Installed:${NC}"
echo "  IDE:      $IDE"
echo "  Target:   $TARGET"
if [ "$IDE" = "claude-code" ]; then
  echo "  Skills:   $SKILL_COUNT"
  echo "  Hooks:    $HOOK_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart Claude Code to load hooks + skills"
  echo "  2. Type /nc: in chat to see available slash commands"
elif [ "$IDE" = "antigravity" ]; then
  echo "  Workflows: $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart Antigravity to discover new workflows"
  echo "  2. Type /nc- in chat to see available slash commands"
elif [ "$IDE" = "cursor" ]; then
  echo "  Commands: $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart Cursor to discover new slash commands"
  echo "  2. Type /nc- in chat to see available commands"
elif [ "$IDE" = "windsurf" ]; then
  echo "  Workflows: $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart Windsurf to discover new workflows"
  echo "  2. Type /nc- in chat to see available commands"
elif [ "$IDE" = "copilot" ]; then
  echo "  Prompts:  $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Enable chat.promptFiles in VS Code settings"
  echo "  2. Add ".github/prompts" to chat.promptFilesLocations"
  echo "  3. Reload VS Code, then type /nc- in Copilot Chat"
elif [ "$IDE" = "continue" ]; then
  echo "  Prompts:  $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart Continue extension"
  echo "  2. Type /nc- in Continue chat"
elif [ "$IDE" = "aider" ]; then
  echo "  Prompts:  $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. aider --read .aider/nextcore/nextcore-conventions.md"
  echo "  2. /read .aider/nextcore/prompts/nc-plan.md"
elif [ "$IDE" = "zed" ] || [ "$IDE" = "jetbrains" ] || [ "$IDE" = "void" ]; then
  echo "  Prompts:  $SKILL_COUNT"
  echo
  echo -e "${C}Next steps:${NC}"
  echo "  1. Restart $IDE IDE"
  echo "  2. Type /nc- in the IDE chat"
fi
