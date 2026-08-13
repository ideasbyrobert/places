#!/usr/bin/env bash
set -euo pipefail

APP_NAME="GridWindowManager"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"

if [[ -z "${DEVELOPER_ID_APPLICATION:-}" || -z "${DEVELOPMENT_TEAM:-}" || -z "${NOTARYTOOL_PROFILE:-}" ]]
then
    printf 'DEVELOPER_ID_APPLICATION, DEVELOPMENT_TEAM, and NOTARYTOOL_PROFILE are required\n' >&2
    exit 2
fi

cd "$ROOT_DIR"
xcodegen generate
mkdir -p "$BUILD_DIR" "$DIST_DIR"
xcodebuild \
    -project "$ROOT_DIR/GridWindowManager.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$DEVELOPER_ID_APPLICATION" \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
    archive

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$DMG_PATH"
codesign --force --sign "$DEVELOPER_ID_APPLICATION" --timestamp --options runtime "$DMG_PATH"

xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARYTOOL_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

spctl --assess --type execute --verbose=4 "$APP_BUNDLE"
spctl --assess --type open --context context:primary-signature --verbose=4 "$DMG_PATH"
