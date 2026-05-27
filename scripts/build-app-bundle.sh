#!/usr/bin/env bash
set -euo pipefail

swift build

BIN_PATH="$(swift build --show-bin-path)"
APP_PATH="${1:-/private/tmp/GhiblyMail.app}"
CONTENTS_PATH="${APP_PATH}/Contents"
MACOS_PATH="${CONTENTS_PATH}/MacOS"
RESOURCES_PATH="${CONTENTS_PATH}/Resources"

mkdir -p "${MACOS_PATH}" "${RESOURCES_PATH}"
cp "${BIN_PATH}/GhiblyMail" "${MACOS_PATH}/GhiblyMail"
chmod +x "${MACOS_PATH}/GhiblyMail"
rm -rf "${APP_PATH}/GhiblyMail_GhiblyMailCore.bundle"

cat > "${CONTENTS_PATH}/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>GhiblyMail</string>
  <key>CFBundleIdentifier</key>
  <string>local.ghiblymail.mvp</string>
  <key>CFBundleName</key>
  <string>GhiblyMail</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

mkdir -p "${RESOURCES_PATH}/Office"
cp "${PWD}/Sources/GhiblyMailCore/Resources/Office/office-background-empty-v1.png" "${RESOURCES_PATH}/Office/office-background-empty-v1.png"
mkdir -p "${RESOURCES_PATH}/Mockups"
cp "${PWD}/Sources/GhiblyMailCore/Resources/Mockups/main-office-home-v1.png" "${RESOURCES_PATH}/Mockups/main-office-home-v1.png"
find "${BIN_PATH}" -maxdepth 1 -name '*GhiblyMailCore.bundle' -type d -exec cp -R {} "${RESOURCES_PATH}/" \;

codesign --force --deep --sign - "${APP_PATH}" >/dev/null

echo "${APP_PATH}"
