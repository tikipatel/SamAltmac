#!/usr/bin/env bash
# Builds a universal, ad-hoc signed SamAltmac.app into ./build
set -euo pipefail
cd "$(dirname "$0")/.."

ARCH_FLAGS=(--arch arm64 --arch x86_64)
swift build -c release "${ARCH_FLAGS[@]}"
BIN_DIR="$(swift build -c release "${ARCH_FLAGS[@]}" --show-bin-path)"

APP="build/SamAltmac.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/SamAltmac" "$APP/Contents/MacOS/SamAltmac"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"

echo "Built $APP"
