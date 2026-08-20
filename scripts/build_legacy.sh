#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
configuration="${CONFIGURATION:-Release}"
app_version="${APP_VERSION:-1.0}"
build_number="${BUILD_NUMBER:-1}"
update_url="${QRSCOUT_UPDATE_URL:-}"
output_root="${BUILD_DIR:-$repository_root/build}"
object_directory="$output_root/objects-$configuration"
app_directory="$output_root/$configuration-iphoneos/QRScoutLegacy.app"
payload_directory="$output_root/ipa/Payload"
sdk_path="$(xcrun --sdk iphoneos --show-sdk-path)"
clang_path="$(xcrun --sdk iphoneos --find clang)"
ibtool_path="$(xcrun --sdk iphoneos --find ibtool)"
actool_path="$(xcrun --sdk iphoneos --find actool)"

mkdir -p "$object_directory" "$app_directory/Base.lproj"

common_flags=(
    -arch arm64
    -isysroot "$sdk_path"
    -miphoneos-version-min=9.0
    -fobjc-arc
    -fmodules
    -fmodules-cache-path="$output_root/ModuleCache"
    -Wall
    -Wextra
    -Werror=unguarded-availability
    -I "$repository_root/QRScoutLegacy"
)

if [[ "$configuration" == "Debug" ]]; then
    common_flags+=(-O0 -g -DDEBUG=1)
else
    common_flags+=(-Os -DNDEBUG=1)
fi

sources=(
    main.m
    AppDelegate.m
    ScoutViewController.m
    CounterControl.m
    PayloadBuilder.m
)

objects=()
for source in "${sources[@]}"; do
    object="$object_directory/${source%.m}.o"
    "$clang_path" "${common_flags[@]}" \
        -c "$repository_root/QRScoutLegacy/$source" \
        -o "$object"
    objects+=("$object")
done

"$clang_path" \
    -arch arm64 \
    -isysroot "$sdk_path" \
    -miphoneos-version-min=9.0 \
    -fobjc-arc \
    -Wl,-dead_strip \
    -framework UIKit \
    -framework Foundation \
    -framework CoreImage \
    -framework QuartzCore \
    "${objects[@]}" \
    -o "$app_directory/QRScoutLegacy"

"$ibtool_path" \
    --compile "$app_directory/Base.lproj/LaunchScreen.storyboardc" \
    --minimum-deployment-target 9.0 \
    --target-device iphone \
    --target-device ipad \
    "$repository_root/QRScoutLegacy/LaunchScreen.storyboard"

asset_partial_plist="$output_root/assetcatalog-partial.plist"
"$actool_path" \
    --output-format human-readable-text \
    --app-icon AppIcon \
    --minimum-deployment-target 9.0 \
    --platform iphoneos \
    --target-device iphone \
    --target-device ipad \
    --output-partial-info-plist "$asset_partial_plist" \
    --compile "$app_directory" \
    "$repository_root/QRScoutLegacy/Assets.xcassets"

cp "$repository_root/QRScoutLegacy/Info.plist" "$app_directory/Info.plist"
plutil -insert CFBundleIcons -json '{"CFBundlePrimaryIcon":{"CFBundleIconFiles":["AppIcon29x29","AppIcon40x40","AppIcon57x57","AppIcon60x60"],"CFBundleIconName":"AppIcon"}}' "$app_directory/Info.plist"
plutil -insert 'CFBundleIcons~ipad' -json '{"CFBundlePrimaryIcon":{"CFBundleIconFiles":["AppIcon29x29","AppIcon40x40","AppIcon57x57","AppIcon60x60","AppIcon50x50","AppIcon72x72","AppIcon76x76"],"CFBundleIconName":"AppIcon"}}' "$app_directory/Info.plist"
plutil -replace CFBundleDevelopmentRegion -string en "$app_directory/Info.plist"
plutil -replace CFBundleExecutable -string QRScoutLegacy "$app_directory/Info.plist"
plutil -replace CFBundleIdentifier -string com.qrscout.meco.legacy "$app_directory/Info.plist"
plutil -replace CFBundleName -string QRScoutLegacy "$app_directory/Info.plist"
plutil -replace CFBundlePackageType -string APPL "$app_directory/Info.plist"
plutil -replace CFBundleShortVersionString -string "$app_version" "$app_directory/Info.plist"
plutil -replace CFBundleVersion -string "$build_number" "$app_directory/Info.plist"
plutil -replace QRScoutUpdateURL -string "$update_url" "$app_directory/Info.plist"
plutil -insert CFBundleSupportedPlatforms -json '["iPhoneOS"]' "$app_directory/Info.plist"
plutil -insert DTPlatformName -string iphoneos "$app_directory/Info.plist"
plutil -insert MinimumOSVersion -string 9.0 "$app_directory/Info.plist"
plutil -insert UIDeviceFamily -json '[1,2]' "$app_directory/Info.plist"
printf 'APPL????' > "$app_directory/PkgInfo"

mkdir -p "$payload_directory"
ditto "$app_directory" "$payload_directory/QRScoutLegacy.app"
ditto -c -k --sequesterRsrc --keepParent "$payload_directory" "$output_root/QRScoutLegacy-unsigned.ipa"

echo "Built $app_directory"
echo "Packaged $output_root/QRScoutLegacy-unsigned.ipa"
echo "The app is unsigned; sign it with an Apple development or distribution identity before installation."
