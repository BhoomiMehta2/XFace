#!/bin/bash
set -e

# Determine target application directory
if [ -w "/Applications" ]; then
    APP_DIR="/Applications"
else
    APP_DIR="$HOME/Applications"
    mkdir -p "$APP_DIR"
fi

if [ -d "$APP_DIR/Spectrum.app" ]; then
    echo "✨ Updating Spectrum for Xcode to the latest version..."
else
    echo "✨ Installing Spectrum for Xcode..."
fi

echo "📥 Downloading latest Spectrum-v1.0.zip..."

curl -sL "https://bhoomimehta2.github.io/Spectrum/Spectrum-v1.0.zip" -o "/tmp/Spectrum-v1.0.zip"

echo "📦 Extracting..."
rm -rf "/tmp/SpectrumInstall"
mkdir -p "/tmp/SpectrumInstall"
unzip -q "/tmp/Spectrum-v1.0.zip" -d "/tmp/SpectrumInstall"

echo "📂 Moving to Applications..."
# Kill app if it's running
killall "Spectrum" 2>/dev/null || true

# Remove if exists
rm -rf "$APP_DIR/Spectrum.app"
cp -R "/tmp/SpectrumInstall/Spectrum.app" "$APP_DIR/"

echo "🛡️  Bypassing Gatekeeper..."
xattr -d com.apple.quarantine "$APP_DIR/Spectrum.app" 2>/dev/null || true

echo "🧹 Cleaning up..."
rm -rf "/tmp/Spectrum-v1.0.zip" "/tmp/SpectrumInstall"

echo "✅ Success! Spectrum is now installed."
echo "🚀 Opening Spectrum..."
open "$APP_DIR/Spectrum.app"
