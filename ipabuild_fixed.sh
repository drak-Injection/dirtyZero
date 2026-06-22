#!/bin/bash
set -e
cd "$(dirname "$0")"
APPLICATION_NAME=dirtyZero
echo "[*] Building $APPLICATION_NAME"
rm -rf build
rm -f *.ipa
WORKING_LOCATION="$(pwd)"
mkdir -p build && cd build
xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Debug \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    SWIFT_VERSION=5.0 \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"
DD_APP=$(find "$WORKING_LOCATION/build/DerivedDataApp" -name "$APPLICATION_NAME.app" -type d | head -1)
cp -r "$DD_APP" ./
codesign --remove ./$APPLICATION_NAME.app 2>/dev/null || true
rm -rf ./$APPLICATION_NAME.app/_CodeSignature ./$APPLICATION_NAME.app/embedded.mobileprovision 2>/dev/null || true
mkdir Payload
cp -r $APPLICATION_NAME.app Payload/
zip -vr $APPLICATION_NAME.ipa Payload
rm -rf Payload
cd .. && mv build/$APPLICATION_NAME.ipa ./ 2>/dev/null || mv build/*.ipa ./
rm -rf build/
echo "Done: $APPLICATION_NAME.ipa"
