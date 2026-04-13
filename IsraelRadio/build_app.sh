#!/bin/bash
set -e

APP_NAME="IsraelRadio"
APP_DIR="/Applications/${APP_NAME}.app"
CONTENTS="${APP_DIR}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

echo "Building ${APP_NAME}..."
cd "$(dirname "$0")"
swift build -c release 2>&1

BINARY=".build/release/${APP_NAME}"

if [ ! -f "$BINARY" ]; then
    echo "ERROR: Binary not found at $BINARY"
    exit 1
fi

echo "Creating app bundle at ${APP_DIR}..."
rm -rf "${APP_DIR}"
mkdir -p "${MACOS}" "${RESOURCES}"

cp "$BINARY" "${MACOS}/${APP_NAME}"

cat > "${CONTENTS}/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>IsraelRadio</string>
    <key>CFBundleIdentifier</key>
    <string>com.coolsite.israelradio</string>
    <key>CFBundleName</key>
    <string>Israel Radio</string>
    <key>CFBundleDisplayName</key>
    <string>Israel Radio</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
PLIST

# Generate app icon using built-in macOS Python
python3 - "${RESOURCES}" << 'PYICON'
import sys, struct, zlib

out_dir = sys.argv[1]

def create_png(size):
    """Create a radio icon PNG at the given size."""
    pixels = []
    center_x, center_y = size / 2, size / 2
    r_outer = size * 0.42
    r_inner = size * 0.32
    r_knob = size * 0.12
    r_bg = size * 0.46
    
    for y in range(size):
        row = []
        for x in range(size):
            dx = x - center_x
            dy = y - center_y
            dist = (dx*dx + dy*dy) ** 0.5
            
            # Background circle
            if dist <= r_bg:
                # Dark blue background
                bg_r, bg_g, bg_b = 30, 60, 120
                
                # Radio wave arcs (top half)
                angle_from_center = (dx*dx + dy*dy) ** 0.5
                
                # Inner knob
                if dist <= r_knob:
                    row.extend([220, 60, 60, 255])
                # Wave rings
                elif abs(dist - r_inner) < size * 0.02 and dy < size * 0.05:
                    row.extend([100, 200, 255, 255])
                elif abs(dist - r_outer) < size * 0.02 and dy < size * 0.1:
                    row.extend([100, 200, 255, 255])
                elif abs(dist - (r_inner + r_outer) / 2) < size * 0.02 and dy < size * 0.08:
                    row.extend([100, 200, 255, 255])
                else:
                    row.extend([bg_r, bg_g, bg_b, 255])
            else:
                row.extend([0, 0, 0, 0])
        pixels.append(bytes(row))
    
    def make_png(width, height, rows):
        def chunk(ctype, data):
            c = ctype + data
            return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
        
        sig = b'\x89PNG\r\n\x1a\n'
        ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
        raw = b''
        for row in rows:
            raw += b'\x00' + row
        idat = chunk(b'IDAT', zlib.compress(raw))
        iend = chunk(b'IEND', b'')
        return sig + ihdr + idat + iend
    
    return make_png(size, size, pixels)

# Create iconset
import os
iconset = os.path.join(out_dir, "AppIcon.iconset")
os.makedirs(iconset, exist_ok=True)

sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

for sz, name in sizes:
    png_data = create_png(sz)
    with open(os.path.join(iconset, name), 'wb') as f:
        f.write(png_data)

print("Icon PNGs generated.")
PYICON

# Convert iconset to icns
if [ -d "${RESOURCES}/AppIcon.iconset" ]; then
    iconutil -c icns "${RESOURCES}/AppIcon.iconset" -o "${RESOURCES}/AppIcon.icns" 2>/dev/null && \
        rm -rf "${RESOURCES}/AppIcon.iconset" && \
        echo "App icon created." || \
        echo "Warning: iconutil failed, app will use default icon."
fi

echo ""
echo "=== Done! ==="
echo "App installed to: ${APP_DIR}"
echo "You can find 'Israel Radio' in your Applications folder."
echo "Launch it from Spotlight, Launchpad, or Finder."
