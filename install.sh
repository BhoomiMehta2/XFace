#!/bin/bash
set -e

if [ -d "/Applications/Spectrum.app" ]; then
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
rm -rf "/Applications/Spectrum.app"
cp -R "/tmp/SpectrumInstall/Spectrum.app" "/Applications/"

echo "🛡️  Bypassing Gatekeeper..."
xattr -d com.apple.quarantine "/Applications/Spectrum.app" 2>/dev/null || true

echo "🧹 Cleaning up..."
rm -rf "/tmp/Spectrum-v1.0.zip" "/tmp/SpectrumInstall"

echo "✅ Success! Spectrum is now installed."
echo "🚀 Opening Spectrum..."
open "/Applications/Spectrum.app"
