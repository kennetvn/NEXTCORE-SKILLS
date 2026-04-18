#!/usr/bin/env bash
# Uninstall NEXTCORE-SKILLS for a specific IDE

set -euo pipefail

IDE="claude-code"
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --ide=*)    IDE="${arg#*=}" ;;
    --target=*) TARGET="${arg#*=}" ;;
    --help|-h)
      cat <<HELPEOF
Usage: ./uninstall.sh [--ide=NAME] [--target=PATH]

IDEs: claude-code | antigravity | cursor | windsurf | copilot | continue | aider | codeium | zed | jetbrains | void
HELPEOF
      exit 0
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  case "$IDE" in
    claude-code) TARGET="${PWD}/.claude" ;;
    antigravity) TARGET="${PWD}/.agent" ;;
    cursor)      TARGET="${PWD}/.cursor" ;;
    windsurf)    TARGET="${PWD}/.windsurf" ;;
    copilot)     TARGET="${PWD}/.github" ;;
    continue)    TARGET="${PWD}/.continue" ;;
    aider)       TARGET="${PWD}/.aider/nextcore" ;;
    codeium)     TARGET="${PWD}/.codeium" ;;
    zed)         TARGET="${PWD}/.zed" ;;
    jetbrains)   TARGET="${PWD}/.idea/ai-prompts" ;;
    void)        TARGET="${PWD}/.void" ;;
    *) echo "Unknown IDE: $IDE" >&2; exit 1 ;;
  esac
fi

if [ ! -d "$TARGET" ]; then
  echo "[nc] Nothing to uninstall: $TARGET does not exist"
  exit 0
fi

echo "[nc] Uninstall target: $TARGET"
read -p "Remove all NEXTCORE files here? [y/N] " -r
[[ $REPLY =~ ^[Yy]$ ]] || { echo "[nc] Aborted"; exit 1; }

if [ "$IDE" = "claude-code" ]; then
  # Only remove NEXTCORE-owned subdirs
  for sub in hooks skills agents commands output-styles rules schemas scripts; do
    [ -d "$TARGET/$sub" ] && rm -rf "$TARGET/$sub"
  done
  for f in statusline.cjs .nc.json metadata.json .env.example; do
    [ -f "$TARGET/$f" ] && rm -f "$TARGET/$f"
  done
  echo "[nc] Claude Code NEXTCORE files removed (kept user's own files)"
elif [ "$IDE" = "copilot" ]; then
  # Only remove prompts dir (user may have other .github content)
  [ -d "$TARGET/prompts" ] && rm -rf "$TARGET/prompts"
  echo "[nc] Copilot prompts removed"
else
  # For other IDEs, remove whole IDE target dir (if only NEXTCORE uses it)
  rm -rf "$TARGET"
  echo "[nc] $IDE target removed: $TARGET"
fi

echo "[nc] Done."
