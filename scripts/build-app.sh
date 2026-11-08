#!/usr/bin/env bash
# Builds a universal, ad-hoc signed MemoryDropAlert.app into ./build
set -euo pipefail
cd "$(dirname "$0")/.."

ARCH_FLAGS=(--arch arm64 --arch x86_64)
swift build -c release "${ARCH_FLAGS[@]}"
BIN_DIR="$(swift build -c release "${ARCH_FLAGS[@]}" --show-bin-path)"

APP="build/MemoryDropAlert.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/MemoryDropAlert" "$APP/Contents/MacOS/MemoryDropAlert"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"

echo "Built $APP"
