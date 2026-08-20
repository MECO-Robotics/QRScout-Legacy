#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
template="$repository_root/updates/manifest.plist.template"

if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 <https-ipa-url> <output-plist> [app-version] [build-number]" >&2
    exit 2
fi

ipa_url="$1"
output_path="$2"
app_version="${3:-1.0}"
build_number="${4:-1}"

if [[ "$ipa_url" != https://* ]]; then
    echo "The IPA URL must use HTTPS." >&2
    exit 2
fi

mkdir -p "$(dirname "$output_path")"
sed \
    -e "s|__IPA_URL__|$ipa_url|g" \
    -e "s|__APP_VERSION__|$app_version|g" \
    -e "s|__BUILD_NUMBER__|$build_number|g" \
    "$template" > "$output_path"

plutil -lint "$output_path"
echo "Wrote OTA manifest: $output_path"
