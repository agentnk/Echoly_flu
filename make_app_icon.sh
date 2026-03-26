#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: bash make_app_icon.sh /path/to/image.png"
    exit 1
fi

IMAGE_FILE="$1"
ICONSET_DIR="icon.iconset"

mkdir -p "$ICONSET_DIR"

# Generate different resolution icons required by macOS
sips -z 16 16     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16.png"
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16@2x.png"
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32.png"
sips -z 64 64     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32@2x.png"
sips -z 128 128   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128.png"
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128@2x.png"
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256.png"
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256@2x.png"
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512.png"
sips -z 1024 1024 "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512@2x.png"

echo "Generating icns..."
iconutil -c icns "$ICONSET_DIR" -o icon.icns
rm -rf "$ICONSET_DIR"

echo "icon.icns generated! You can now run bash build_app.sh to apply it."
