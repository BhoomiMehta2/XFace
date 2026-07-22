#!/bin/bash
set -e

# Determine target application directory
if [ -w "/Applications" ]; then
    APP_DIR="/Applications"
else
    APP_DIR="$HOME/Applications"
    mkdir -p "$APP_DIR"
fi

if [ -d "$APP_DIR/XFace.app" ]; then
    echo "✨ Updating XFace for Xcode to the latest version..."
else
    echo "✨ Installing XFace for Xcode..."
fi

echo "📥 Downloading latest XFace-v1.0.zip..."

curl -sL "https://bhoomimehta2.github.io/XFace/XFace-v1.0.zip" -o "/tmp/XFace-v1.0.zip"

echo "📦 Extracting..."
rm -rf "/tmp/XFaceInstall"
mkdir -p "/tmp/XFaceInstall"
unzip -q "/tmp/XFace-v1.0.zip" -d "/tmp/XFaceInstall"

echo "📂 Moving to Applications..."
# Kill app if it's running
killall "XFace" 2>/dev/null || true

# Remove if exists
rm -rf "$APP_DIR/XFace.app"
cp -R "/tmp/XFaceInstall/XFace.app" "$APP_DIR/"

echo "🛡️  Bypassing Gatekeeper..."
xattr -d com.apple.quarantine "$APP_DIR/XFace.app" 2>/dev/null || true

echo "🧹 Cleaning up..."
rm -rf "/tmp/XFace-v1.0.zip" "/tmp/XFaceInstall"

echo "✅ Success! XFace is now installed."
echo "🚀 Opening XFace..."
open "$APP_DIR/XFace.app"
