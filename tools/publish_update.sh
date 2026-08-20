#!/usr/bin/env bash
set -euo pipefail

DMG="${1:?usage: publish_update.sh <notarized-dmg> <app-bundle>}"
APP="${2:?usage: publish_update.sh <notarized-dmg> <app-bundle>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUCKET="${SPREAD_UPDATE_BUCKET:-ideasbyrobert-assets}"
PREFIX="${SPREAD_UPDATE_PREFIX:-spread}"
BASE_URL="${SPREAD_UPDATE_URL:-https://downloads.ideasbyrobert.com/spread}"
ACCOUNT="${SPREAD_SPARKLE_ACCOUNT:-Spread}"
CHANNEL="$ROOT/.derived/update-channel"
ARCHIVES="$CHANNEL/archives"
APPCAST="$ARCHIVES/appcast.xml"
REMOTE_APPCAST="$BASE_URL/appcast.xml"

GENERATE="$(find "$ROOT/.build" -name "generate_appcast" -type f -perm +111 2>/dev/null | head -1 || true)"
if [ -z "$GENERATE" ]; then
    GENERATE="$(find "$ROOT/../Feather/.build" -name "generate_appcast" -type f -perm +111 2>/dev/null | head -1 || true)"
fi

[ -f "$DMG" ] || { echo "error: DMG missing: $DMG" >&2; exit 65; }
[ -d "$APP" ] || { echo "error: app bundle missing: $APP" >&2; exit 65; }
[ -n "$GENERATE" ] && [ -x "$GENERATE" ] || { echo "error: generate_appcast missing — run swift package resolve" >&2; exit 65; }

VERSION="$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString)"
BUILD="$(defaults read "$APP/Contents/Info.plist" CFBundleVersion)"

say()
{
    printf '==> %s\n' "$*"
}

mkdir -p "$ARCHIVES"

if [ ! -f "$APPCAST" ]; then
    if curl --fail --silent --location "$REMOTE_APPCAST" --output "$APPCAST.download"; then
        mv "$APPCAST.download" "$APPCAST"
        say "fetched existing appcast"
    else
        rm -f "$APPCAST.download"
        say "no published appcast yet — starting fresh"
    fi
fi

ZIP="$ARCHIVES/GridWindowManager-$VERSION-$BUILD.zip"
say "Archiving $APP -> $(basename "$ZIP")"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

say "Generating appcast (Sparkle key account: $ACCOUNT)"
"$GENERATE" \
    --account "$ACCOUNT" \
    --download-url-prefix "$BASE_URL/" \
    --link "https://github.com/ideasbyrobert/spread" \
    --maximum-versions 5 \
    --maximum-deltas 0 \
    "$ARCHIVES"

[ -f "$APPCAST" ] || { echo "error: generate_appcast produced no appcast.xml" >&2; exit 65; }

FEED_BUILD="$(xmllint --xpath 'string(//*[local-name()="item"][1]/*[local-name()="version"])' "$APPCAST")"
FEED_URL="$(xmllint --xpath 'string(//*[local-name()="item"][1]/*[local-name()="enclosure"]/@url)' "$APPCAST")"
[ "$FEED_BUILD" = "$BUILD" ] || {
    echo "error: appcast latest build ($FEED_BUILD) is not this build ($BUILD)" >&2; exit 65; }
[ "$FEED_URL" = "$BASE_URL/$(basename "$ZIP")" ] || {
    echo "error: appcast points at $FEED_URL, expected $BASE_URL/$(basename "$ZIP")" >&2; exit 65; }
say "appcast advertises build $FEED_BUILD"

put()
{
    local args=(r2 object put "$BUCKET/$PREFIX/$1" --remote --file "$2"
                --content-type "$3" --cache-control "$4")
    [ $# -ge 5 ] && args+=(--content-disposition "$5")
    wrangler "${args[@]}" >/dev/null
    echo "    $BASE_URL/$1"
}

say "Uploading to Cloudflare R2 ($BUCKET/$PREFIX)"
put "$(basename "$ZIP")" "$ZIP" "application/zip" "public, max-age=31536000, immutable"
put "GridWindowManager-$VERSION-$BUILD.dmg" "$DMG" "application/x-apple-diskimage" \
    "public, max-age=31536000, immutable"
put "latest/GridWindowManager.dmg" "$DMG" "application/x-apple-diskimage" \
    "no-cache, no-store, must-revalidate" 'attachment; filename="GridWindowManager.dmg"'
put "appcast.xml" "$APPCAST" "application/xml; charset=utf-8" \
    "no-cache, no-store, must-revalidate"

say "Verifying the public feed"
for _ in $(seq 1 12); do
    REMOTE="$(curl --fail --silent --location "$REMOTE_APPCAST" || true)"
    if [ -n "$REMOTE" ]; then
        GOT="$(printf '%s' "$REMOTE" | xmllint --xpath 'string(//*[local-name()="item"][1]/*[local-name()="version"])' - 2>/dev/null || true)"
        [ "$GOT" = "$BUILD" ] && { say "public feed now advertises build $BUILD"; break; }
    fi
    sleep 3
done
[ "${GOT:-}" = "$BUILD" ] || { echo "error: public feed never showed build $BUILD" >&2; exit 65; }

curl --fail --silent --show-error --head --location "$BASE_URL/$(basename "$ZIP")" -o /dev/null
curl --fail --silent --show-error --head --location "$BASE_URL/latest/GridWindowManager.dmg" -o /dev/null

cat <<SUMMARY

Published GridWindowManager $VERSION (build $BUILD)
  Sparkle feed : $REMOTE_APPCAST
  Update ZIP   : $BASE_URL/$(basename "$ZIP")
  Stable DMG   : $BASE_URL/latest/GridWindowManager.dmg
SUMMARY
