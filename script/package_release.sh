#!/bin/zsh
set -euo pipefail

script_directory="${0:A:h}"
project_directory="${script_directory:h}"
project="${project_directory}/GridWindowManager.xcodeproj"
info_plist="${project_directory}/Resources/Info.plist"
app_name="GridWindowManager"
bundle_identifier="com.ideasbyrobert.GridWindowManager"
app_identity="${APP_IDENTITY:-Developer ID Application: ROBERT KARAPETYAN (X87D35HM5V)}"
notary_profile="${NOTARY_PROFILE:-AC_NOTARY}"
team_id="${TEAM_ID:-X87D35HM5V}"
version="$(plutil -extract CFBundleShortVersionString raw "$info_plist")"
build="$(plutil -extract CFBundleVersion raw "$info_plist")"
stamp="$(date -u +%Y%m%d-%H%M%S)"
release_directory="${GRID_WINDOW_MANAGER_RELEASE_ROOT:-${project_directory}/.derived/release/${stamp}}"
archive="${release_directory}/${app_name}.xcarchive"
derived_data="${release_directory}/DerivedData"
app="${archive}/Products/Applications/${app_name}.app"
binary="${app}/Contents/MacOS/${app_name}"
app_submission="${release_directory}/${app_name}-${version}-${build}-app.zip"
app_zip="${release_directory}/${app_name}-${version}-${build}.zip"
dmg_root="${release_directory}/DMG"
dmg="${release_directory}/${app_name}-${version}-${build}.dmg"
mount_point="${release_directory}/MountedDMG"
dist_directory="${project_directory}/dist"
dist_zip="${dist_directory}/${app_name}-${version}-${build}.zip"
dist_dmg="${dist_directory}/${app_name}-${version}-${build}.dmg"

fail()
{
    print -u2 "error: $1"
    exit 65
}

notarize()
{
    local artifact="$1"
    local result="$2"
    local submit_arguments=(
        "$artifact"
        --keychain-profile "$notary_profile"
        --no-s3-acceleration
        --wait
        --timeout 20m
        --output-format json
    )
    if [[ "$artifact" == *.dmg ]]
    then
        submit_arguments+=(--force)
    fi
    xcrun notarytool submit "${submit_arguments[@]}" | tee "$result"
    [[ "$(plutil -extract status raw "$result")" == "Accepted" ]] \
        || fail "Apple did not accept ${artifact:t}."
}

cleanup()
{
    if mount | grep -Fq "on ${mount_point} "
    then
        diskutil eject "$mount_point" >/dev/null
    fi
}

trap cleanup EXIT

identities="$(security find-identity -v -p codesigning)"
[[ "$identities" == *"$app_identity"* ]] \
    || fail "the Developer ID Application identity is unavailable."
xcrun notarytool history \
    --keychain-profile "$notary_profile" \
    >/dev/null 2>&1 \
    || fail "the ${notary_profile} notary profile is unusable."

mkdir -p "$release_directory" "$dist_directory"
cd "$project_directory"
xcodegen generate
xcodebuild \
    -quiet \
    -project "$project" \
    -scheme "$app_name" \
    -configuration Release \
    -destination "generic/platform=macOS" \
    -archivePath "$archive" \
    -derivedDataPath "$derived_data" \
    "ARCHS=arm64 x86_64" \
    "CODE_SIGN_IDENTITY=$app_identity" \
    "DEVELOPMENT_TEAM=$team_id" \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
    CODE_SIGN_STYLE=Manual \
    ENABLE_HARDENED_RUNTIME=YES \
    ONLY_ACTIVE_ARCH=NO \
    archive

[[ -d "$app" ]] || fail "the archive did not contain ${app_name}.app."
[[ "$(plutil -extract CFBundleIdentifier raw "${app}/Contents/Info.plist")" == "$bundle_identifier" ]] \
    || fail "the release app has the wrong bundle identifier."
[[ "$(plutil -extract CFBundleIconName raw "${app}/Contents/Info.plist")" == "$app_name" ]] \
    || fail "the adaptive app icon was not compiled."
architectures="$(lipo -archs "$binary")"
[[ "$architectures" == *"arm64"* && "$architectures" == *"x86_64"* ]] \
    || fail "the release app is not universal."
codesign --verify --deep --strict --verbose=2 "$app"
signature="$(codesign -dvv "$app" 2>&1)"
[[ "$signature" == *"Authority=$app_identity"* ]] \
    || fail "the app is not signed with the requested Developer ID identity."
[[ "$signature" == *"TeamIdentifier=$team_id"* ]] \
    || fail "the app is signed by the wrong team."
[[ "$signature" == *"Timestamp="* ]] \
    || fail "the app does not have a secure timestamp."
[[ "$signature" == *"runtime"* ]] \
    || fail "hardened runtime is missing."
entitlements="$(codesign -d --entitlements - "$app" 2>/dev/null)"
[[ "$entitlements" == *"com.apple.security.automation.apple-events"* ]] \
    || fail "the Apple Events entitlement is missing."
[[ "$entitlements" != *"com.apple.security.get-task-allow"* ]] \
    || fail "the release app permits debugger attachment."

ditto -c -k --sequesterRsrc --keepParent "$app" "$app_submission"
notarize "$app_submission" "${release_directory}/notary-app.json"
xcrun stapler staple "$app"
xcrun stapler validate "$app"
spctl -a -t execute -vv "$app"
ditto -c -k --sequesterRsrc --keepParent "$app" "$app_zip"

mkdir -p "$dmg_root"
ditto "$app" "${dmg_root}/${app_name}.app"
ln -s /Applications "${dmg_root}/Applications"
diskutil image create from \
    --volumeName "$app_name" \
    --format UDZO \
    "$dmg_root" \
    "$dmg"
codesign --force --sign "$app_identity" --timestamp "$dmg"
codesign --verify --verbose=2 "$dmg"
notarize "$dmg" "${release_directory}/notary-dmg.json"
xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
spctl -a -t open --context context:primary-signature -vv "$dmg"

mkdir -p "$mount_point"
diskutil image attach \
    --mountOptions nobrowse \
    --readOnly \
    --mountPoint "$mount_point" \
    "$dmg" \
    >/dev/null
[[ -d "${mount_point}/${app_name}.app" ]] \
    || fail "the disk image does not contain ${app_name}.app."
[[ -L "${mount_point}/Applications" && "$(readlink "${mount_point}/Applications")" == "/Applications" ]] \
    || fail "the disk image does not contain the Applications shortcut."
codesign --verify --deep --strict --verbose=2 "${mount_point}/${app_name}.app"
xcrun stapler validate "${mount_point}/${app_name}.app"
spctl -a -t execute -vv "${mount_point}/${app_name}.app"
diskutil eject "$mount_point" >/dev/null

ditto "$app_zip" "$dist_zip"
ditto "$dmg" "$dist_dmg"
shasum -a 256 "$dist_zip" "$dist_dmg" | tee "${release_directory}/SHA256SUMS"

print "Built a Developer ID signed, notarized, and stapled GridWindowManager release."
print "App: $app"
print "ZIP: $dist_zip"
print "DMG: $dist_dmg"
print "Release evidence: $release_directory"
