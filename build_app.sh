#!/bin/bash
set -e

APP_NAME="Echoly"
APP_DIR="${APP_NAME}.app"
BIN_DIR="${APP_DIR}/Contents/MacOS"
RES_DIR="${APP_DIR}/Contents/Resources"
ICON_SRC="echoly_icon.png"
ICONSET_DIR="${RES_DIR}/AppIcon.iconset"

# Remove old app if exists
rm -rf "$APP_DIR"

# Create standard macOS App Bundle structure
mkdir -p "$BIN_DIR"
mkdir -p "$RES_DIR"

echo "Compiling Swift application..."
swiftc -parse-as-library *.swift -o "$BIN_DIR/$APP_NAME"

# Bundle app icon from echoly_icon.png -> AppIcon.icns
if [ -f "$ICON_SRC" ]; then
    echo "Generating app icon..."
    mkdir -p "$ICONSET_DIR"
    sips -z 16 16     "$ICON_SRC" --out "${ICONSET_DIR}/icon_16x16.png"    > /dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "${ICONSET_DIR}/icon_32x32.png"    > /dev/null 2>&1
    sips -z 64 64     "$ICON_SRC" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128   "$ICON_SRC" --out "${ICONSET_DIR}/icon_128x128.png"  > /dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "${ICONSET_DIR}/icon_256x256.png"  > /dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "${ICONSET_DIR}/icon_512x512.png"  > /dev/null 2>&1
    sips -z 1024 1024 "$ICON_SRC" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null 2>&1
    iconutil -c icns "$ICONSET_DIR" -o "${RES_DIR}/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
fi

# Create Info.plist
cat > "${APP_DIR}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.echoly.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "✅ Built ${APP_DIR} successfully!"
