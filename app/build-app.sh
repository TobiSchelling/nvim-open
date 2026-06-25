#!/usr/bin/env bash
# Build "Open in Nvim.app" from the AppleScript source, declare it as a
# document handler for text-ish files, and register it with Launch Services.
#
# Usage: build-app.sh [DEST_DIR]   (default: ~/Applications)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Open in Nvim"
BUNDLE_ID="com.tobischelling.open-in-nvim"
DEST="${1:-$HOME/Applications}"
APP="$DEST/$APP_NAME.app"
PLIST="$APP/Contents/Info.plist"
PB="/usr/libexec/PlistBuddy"

mkdir -p "$DEST"
rm -rf "$APP"
osacompile -o "$APP" "$HERE/open-in-nvim.applescript"

# Identity
"$PB" -c "Set :CFBundleIdentifier $BUNDLE_ID" "$PLIST" 2>/dev/null \
  || "$PB" -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$PLIST"

# Declare a single document type (Viewer, Alternate rank) for common text UTIs,
# so the app appears in Finder's "Open With" for these files.
"$PB" -c "Delete :CFBundleDocumentTypes" "$PLIST" 2>/dev/null || true
"$PB" -c "Add :CFBundleDocumentTypes array" "$PLIST"
"$PB" -c "Add :CFBundleDocumentTypes:0 dict" "$PLIST"
"$PB" -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string 'Text file'" "$PLIST"
"$PB" -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Viewer" "$PLIST"
"$PB" -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" "$PLIST"
"$PB" -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" "$PLIST"
i=0
for uti in public.plain-text public.text public.source-code public.data net.daringfireball.markdown; do
  "$PB" -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:$i string $uti" "$PLIST"
  i=$((i + 1))
done

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
[[ -x "$LSREGISTER" ]] && "$LSREGISTER" -f "$APP" || true

echo "Built and registered: $APP"
