#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
configuration="${CONFIGURATION:-Release}"
output_root="${BUILD_DIR:-$repository_root/build}"
object_directory="$output_root/objects-$configuration"
app_directory="$output_root/$configuration-iphoneos/QRScoutLegacy.app"
payload_directory="$output_root/ipa/Payload"
sdk_path="$(xcrun --sdk iphoneos --show-sdk-path)"
clang_path="$(xcrun --sdk iphoneos --find clang)"
ibtool_path="$(xcrun --sdk iphoneos --find ibtool)"

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

cp "$repository_root/QRScoutLegacy/Info.plist" "$app_directory/Info.plist"
plutil -replace CFBundleDevelopmentRegion -string en "$app_directory/Info.plist"
plutil -replace CFBundleExecutable -string QRScoutLegacy "$app_directory/Info.plist"
plutil -replace CFBundleIdentifier -string com.qrscout.meco.legacy "$app_directory/Info.plist"
plutil -replace CFBundleName -string QRScoutLegacy "$app_directory/Info.plist"
plutil -replace CFBundlePackageType -string APPL "$app_directory/Info.plist"
plutil -replace CFBundleShortVersionString -string 1.0 "$app_directory/Info.plist"
plutil -replace CFBundleVersion -string 1 "$app_directory/Info.plist"
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
