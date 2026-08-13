#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-all}"
APP_NAME="GridWindowManager"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/.build/DerivedData"
ARCHITECTURE="$(uname -m)"
XCODEBUILD_ARGUMENTS=(
    -project "$ROOT_DIR/GridWindowManager.xcodeproj"
    -scheme "$APP_NAME"
    -configuration Debug
    -derivedDataPath "$DERIVED_DATA"
    -destination "platform=macOS,arch=$ARCHITECTURE"
    CODE_SIGNING_ALLOWED=NO
    -quiet
    test
)

case "$MODE" in
    all)
        ;;
    --live-accessibility|live-accessibility)
        XCODEBUILD_ARGUMENTS+=(
            'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) GRIDWINDOWMANAGER_RUN_AX_TESTS'
            "-only-testing:GridWindowManagerTests/AccessibilityIntegrationTests"
        )
        ;;
    --live-app-accessibility|live-app-accessibility)
        XCODEBUILD_ARGUMENTS+=(
            'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) GRIDWINDOWMANAGER_RUN_APP_AX_UI_TESTS'
            "-only-testing:GridWindowManagerUITests/LiveAccessibilityUITests"
        )
        ;;
    *)
        printf 'usage: %s [--live-accessibility|--live-app-accessibility]\n' "$0" >&2
        exit 2
        ;;
esac

cd "$ROOT_DIR"
xcodegen generate
xcodebuild "${XCODEBUILD_ARGUMENTS[@]}"
