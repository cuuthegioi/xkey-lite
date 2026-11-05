#!/bin/bash
# Build XKeyLite.app (Release), zip it, and update the Homebrew cask with the new sha256.
# Needs the "XKeyLite Local Signing" certificate in the login keychain (see README).
set -euo pipefail
cd "$(dirname "$0")"

IDENTITY="XKeyLite Local Signing"
CASK="packaging/homebrew/xkeylite.rb"
VERSION=$(sed -n 's/^MARKETING_VERSION *= *//p' Version.xcconfig)
APP="build/Build/Products/Release/XKeyLite.app"
ZIP="Release/XKeyLite-$VERSION.zip"

if ! security find-certificate -c "$IDENTITY" >/dev/null 2>&1; then
    echo "Missing certificate \"$IDENTITY\" in the login keychain. See README > Build." >&2
    exit 1
fi

echo "Building XKeyLite $VERSION..."
rm -rf build Release
xcodebuild -project XKey.xcodeproj -scheme XKey -configuration Release \
    -derivedDataPath build -quiet build

codesign --verify --deep --strict "$APP"
codesign -dr - "$APP" 2>&1 | grep -q 'certificate leaf' || {
    echo "XKeyLite.app is not signed with \"$IDENTITY\"." >&2
    exit 1
}

mkdir -p Release
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
SHA=$(shasum -a 256 "$ZIP" | cut -d' ' -f1)

sed -i '' -e "s/^  version \".*\"/  version \"$VERSION\"/" \
          -e "s/^  sha256 \".*\"/  sha256 \"$SHA\"/" "$CASK"

echo
echo "Version: $VERSION"
echo "Zip:     $ZIP"
echo "SHA-256: $SHA"
echo "Cask:    $CASK (version and sha256 updated)"
