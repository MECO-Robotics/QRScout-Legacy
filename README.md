# QRScout Legacy

QRScout Legacy is a dependency-free Objective-C/UIKit scouting app for the 2026 FIRST Robotics Competition game REBUILT, presented by Haas. It runs on 64-bit iPads including the iPad mini 2 on iOS 9.3.2 and iOS 12.5.8.

The original workflow is preserved:

- Prematch scout, match, team, alliance, station, and robot-note entry
- REBUILT AUTO fuel scored/missed and this robot's AUTO Level 1 tower result
- REBUILT TELEOP active-HUB fuel scored/missed and inactive-HUB fuel tracking
- Endgame tower Level 1, Level 2, or Level 3 selection and comments
- Live ISO-8859-1 QR generation
- CSV payload and column-name clipboard actions
- Commit confirmation
- Reset behavior that keeps the scout/alliance and advances a numeric match number

The interface uses a REBUILT navy/red/white MECO Robotics visual system with a gradient team header, rounded scouting cards, red accent markers, polished input fields, clearer counter controls, and an app icon branded for FRC Team 8324 MECO Robotics in `QRScoutLegacy/Assets.xcassets`.

## Compatibility choices

- Deployment target: iOS 9.0
- Architecture: arm64, used by the iPad mini 2
- UI framework: UIKit, including only APIs available in iOS 9
- Language: Objective-C with ARC, so there is no Swift runtime to bundle
- Dependencies: Apple system frameworks only; the app works offline
- App lifecycle: pre-scene `UIApplicationDelegate`, supported by iOS 9 and iOS 12

The project uses an Xcode 7-compatible project format. Xcode releases that still permit an iOS 9 deployment target can open, sign, build, and archive it normally. Current Xcode releases reject iOS targets below their supported range at the project-build layer, so this repository also includes a direct compiler build script.

## Build

On a Mac with Xcode and its command-line tools installed:

```sh
./scripts/test.sh
./scripts/build_legacy.sh
```

The second command creates:

- `build/Release-iphoneos/QRScoutLegacy.app`
- `build/QRScoutLegacy-unsigned.ipa`

To embed an optional no-cable update button and version the build:

```sh
APP_VERSION=1.1 BUILD_NUMBER=2 \
QRSCOUT_UPDATE_URL=https://your-host.example/qrscout/manifest.plist \
./scripts/build_legacy.sh
```

The script compiles for arm64 with an iOS 9.0 minimum, treats newer unguarded API use as an error, compiles the launch storyboard for the same minimum, and packages an unsigned IPA.

To make a development build instead:

```sh
CONFIGURATION=Debug ./scripts/build_legacy.sh
```

`BUILD_DIR=/absolute/path` can be used to place generated files elsewhere.

## No-cable updates

iOS does not allow an app to silently replace its own executable. This project supports the practical OTA workflow: host the IPA and an HTTPS OTA manifest, then tap **Update** inside the app. The app converts the manifest URL into an `itms-services` install request. The button is included only when `QRSCOUT_UPDATE_URL` is set during the build.

Create a manifest for each new build with:

```sh
./scripts/make_manifest.sh \
  https://your-host.example/qrscout/QRScoutLegacy.ipa \
  public/qrscout/manifest.plist 1.1 2
```

Upload both files to the same HTTPS host. Future releases only require uploading the new IPA and replacing the manifest; the iPad does not need to be connected to the computer. On a jailbroken iOS 12 device, AppSync/Filza can install the unsigned IPA. A normally signed OTA IPA still requires a valid Apple signing identity and provisioning profile.

## Sign and install

An unsigned IPA cannot be installed on a physical iPad. Use one of these routes:

1. Open `QRScoutLegacy.xcodeproj` in an Xcode version whose deployment range includes iOS 9.0, select your development team, change `com.qrscout.meco.legacy` if your profile requires a different bundle identifier, and run on the device.
2. Sign the generated app with a valid provisioning profile and matching Apple certificate using your organization's established signing process, then rebuild the IPA around that signed app.

For a practical period toolchain, Xcode 10.x supports an iOS 9 deployment target and iOS 12-era devices. A current Xcode toolchain can produce the unsigned binary through `scripts/build_legacy.sh`, but it cannot perform the normal project build with this deployment target.

Keep automatic date/time enabled on an older device before installing, since certificate validation is sensitive to the device clock.

## REBUILT scouting contract

REBUILT has a 20-second AUTO period followed by 2:20 of TELEOP. FUEL scored through an active HUB and TOWER levels are the game-specific scoring observations captured here. The app records missed fuel and fuel observed in an inactive HUB as scouting data; those observations do not themselves award match points. The official game manual defines AUTO Level 1 tower scoring for up to two alliance robots, and TELEOP tower Levels 1–3; this per-robot form records whether the selected robot achieved each result.

## Spreadsheet contract

The QR payload remains a comma-separated row in this exact order:

```text
scout,match,team,alliance,station,robotNotes,autoFuelScored,autoFuelMissed,autoTowerLevel1,teleopFuelScored,teleopFuelMissed,teleopFuelInactive,fouls,defenseRating,towerLevel,comments
```

Commas and line feeds in free text are converted to spaces, matching the original app. The payload contract is covered by both the XCTest target and the command-line test script.

## Verification

The repository can verify the build metadata with:

```sh
file build/Release-iphoneos/QRScoutLegacy.app/QRScoutLegacy
otool -l build/Release-iphoneos/QRScoutLegacy.app/QRScoutLegacy | grep -A4 LC_VERSION_MIN_IPHONEOS
plutil -p build/Release-iphoneos/QRScoutLegacy.app/Info.plist
unzip -t build/QRScoutLegacy-unsigned.ipa
```

Expected results include an arm64 Mach-O executable, `LC_VERSION_MIN_IPHONEOS` version `9.0`, and `MinimumOSVersion` `9.0`.

Compiler and package checks cannot replace a final launch test on the two target OS versions. Before field deployment, sign the app and smoke-test data entry, counter limits, QR scanning, clipboard actions, reset, portrait, and landscape on an iPad mini 2 running iOS 9.3.2 and another running iOS 12.5.8.
