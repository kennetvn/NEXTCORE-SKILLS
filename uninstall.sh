#!/usr/bin/env bash
# NextCoreSkill — uninstaller
# Usage: ./uninstall.sh [--target=PATH] [--keep-config]

set -euo pipefail

TARGET="${PWD}/.claude"
KEEP_CONFIG=false

for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#*=}" ;;
    --keep-config) KEEP_CONFIG=true ;;
  esac
done

[ -d "$TARGET" ] || { echo "Not installed at $TARGET"; exit 0; }

BACKUP="$TARGET.removed.$(date +%s)"
if [ "$KEEP_CONFIG" = true ]; then
  # Preserve .nc.json + .env + settings.json
  mkdir -p "$BACKUP"
  for f in .nc.json .env settings.json settings.local.json; do
    [ -f "$TARGET/$f" ] && mv "$TARGET/$f" "$BACKUP/"
  done
  rm -rf "$TARGET"
  mkdir -p "$TARGET"
  mv "$BACKUP"/* "$TARGET/" 2>/dev/null || true
  rmdir "$BACKUP"
  echo "Uninstalled NextCoreSkill. Config preserved in $TARGET"
else
  mv "$TARGET" "$BACKUP"
  echo "Moved $TARGET → $BACKUP (delete manually when sure)"
fi
