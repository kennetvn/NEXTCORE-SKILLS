#!/usr/bin/env bash
# NextCoreSkill — one-command installer for Claude Code projects
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/kennetvn/nextcoreskill/main/install.sh | bash
#   or locally:
#   ./install.sh [--target=PATH] [--update] [--ide=claude-code] [--minimal]
#
# Options:
#   --target=PATH   Where to install (default: ./.claude)
#   --update        Update existing install (preserve user overrides)
#   --ide=NAME      Target IDE (claude-code|cursor|continue) — only claude-code for now
#   --minimal       Install core hooks + essential skills only (no docs/tutorials)
#   --force         Overwrite existing .claude without prompt
#
# Environment:
#   NC_SOURCE       Source directory (default: this script's parent)
#   NC_REPO         Git repo for remote install (https://github.com/kennetvn/nextcoreskill)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NC_SOURCE="${NC_SOURCE:-$SCRIPT_DIR}"
NC_REPO="${NC_REPO:-https://github.com/kennetvn/nextcoreskill}"

TARGET="${PWD}/.claude"
MODE="fresh"
IDE="claude-code"
MINIMAL=false
FORCE=false

# Colors
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
log() { echo -e "${G}[nc]${NC} $1"; }
warn() { echo -e "${Y}[nc]${NC} $1"; }
err() { echo -e "${R}[nc]${NC} $1" >&2; exit 1; }

# Parse args
for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#*=}" ;;
    --update)   MODE="update" ;;
    --ide=*)    IDE="${arg#*=}" ;;
    --minimal)  MINIMAL=true ;;
    --force)    FORCE=true ;;
    --help|-h)  grep '^#' "$0" | head -20 ; exit 0 ;;
    *) err "Unknown arg: $arg" ;;
  esac
done

[ "$IDE" = "claude-code" ] || err "Only claude-code supported currently (requested: $IDE)"

log "Installing NextCoreSkill → $TARGET (mode: $MODE)"

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

# Install
mkdir -p "$TARGET"
for dir in hooks skills agents commands output-styles rules schemas scripts; do
  if [ -d "$NC_SOURCE/$dir" ]; then
    if [ "$MODE" = "update" ] && [ -d "$TARGET/$dir" ]; then
      # Update: merge, don't overwrite user customizations
      rsync -a --ignore-existing "$NC_SOURCE/$dir/" "$TARGET/$dir/"
    else
      cp -r "$NC_SOURCE/$dir" "$TARGET/"
    fi
  fi
done

# Copy root files (settings template, statusline, config template)
for f in settings.json statusline.cjs .nc.json metadata.json .env.example; do
  if [ -f "$NC_SOURCE/$f" ]; then
    if [ "$MODE" = "update" ] && [ -f "$TARGET/$f" ]; then
      warn "Kept existing $f (update mode)"
    else
      cp "$NC_SOURCE/$f" "$TARGET/"
    fi
  fi
done

# Make hooks executable
chmod +x "$TARGET/hooks"/*.cjs 2>/dev/null || true
chmod +x "$TARGET/scripts"/*.cjs 2>/dev/null || true
chmod +x "$TARGET/statusline.cjs" 2>/dev/null || true

# Minimal mode: strip heavy skill assets
if [ "$MINIMAL" = true ]; then
  log "Minimal mode: removing skill scripts/venvs..."
  find "$TARGET/skills" -name ".venv" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$TARGET/skills" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$TARGET/skills" -name ".coverage" -exec rm -f {} + 2>/dev/null || true
fi

# Cleanup temp clone
[ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ] && rm -rf "$TMPDIR"

# Summary
SKILL_COUNT=$(find "$TARGET/skills" -maxdepth 1 -type d | wc -l)
HOOK_COUNT=$(find "$TARGET/hooks" -maxdepth 1 -name "*.cjs" | wc -l)

log "Done!"
echo
echo -e "${C}Installed:${NC}"
echo "  Target:   $TARGET"
echo "  Skills:   $((SKILL_COUNT - 1))"
echo "  Hooks:    $HOOK_COUNT"
echo "  Mode:     $MODE"
echo
echo -e "${C}Next:${NC}"
echo "  1. Restart Claude Code to load new skills/hooks"
echo "  2. Check status: /nc:help"
echo "  3. Configure: edit $TARGET/.nc.json"
echo "  4. (Optional) Copy env template: cp $TARGET/.env.example $TARGET/.env"
