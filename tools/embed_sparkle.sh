#!/usr/bin/env bash
set -euo pipefail

BUNDLE="$1"
IDENTITY="${2:--}"
ENTITLEMENTS="${3:-}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/.build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"

if [ ! -d "$SRC" ]; then
    SRC="$(find "$ROOT/.build" -path "*/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework" -type d 2>/dev/null | head -1 || true)"
fi

if [ ! -d "$SRC" ]; then
    echo "error: Sparkle artifact missing — run 'swift package resolve' first" >&2
    exit 1
fi

mkdir -p "$BUNDLE/Contents/Frameworks"
rm -rf "$BUNDLE/Contents/Frameworks/Sparkle.framework"
cp -R "$SRC" "$BUNDLE/Contents/Frameworks/"

FW="$BUNDLE/Contents/Frameworks/Sparkle.framework"

sign()
{
    local target="$1"
    local args=(--force --sign "$IDENTITY")
    if [ "$IDENTITY" != "-" ]; then
        args+=(--options runtime --timestamp)
    else
        args+=(--timestamp=none)
    fi
    codesign "${args[@]}" "$target"
}

for xpc in "$FW/Versions/B/XPCServices/"*.xpc; do
    [ -e "$xpc" ] || continue
    sign "$xpc"
done

sign "$FW/Versions/B/Updater.app"
sign "$FW/Versions/B/Autoupdate"
sign "$FW/Versions/B"

echo "embedded Sparkle $(defaults read "$FW/Resources/Info.plist" CFBundleShortVersionString 2>/dev/null || echo '?')"
