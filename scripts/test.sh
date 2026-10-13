#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/qrscout-legacy-tests.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT

xcrun --sdk macosx clang \
    -fobjc-arc \
    -fmodules \
    -framework Foundation \
    -I "$repository_root/QRScoutLegacy" \
    "$repository_root/scripts/payload_builder_check.m" \
    "$repository_root/QRScoutLegacy/PayloadBuilder.m" \
    -o "$temporary_directory/payload_builder_check"

if [[ "${1:-}" == "--emit-scanner-payload" ]]; then
    "$temporary_directory/payload_builder_check" --emit-scanner-payload
else
    "$temporary_directory/payload_builder_check"
    echo "Payload contract checks passed."
fi
