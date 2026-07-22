# XFace 🎨

**XFace** is a native macOS application built with SwiftUI that allows developers to seamlessly import, preview, and apply VS Code themes directly to Xcode with a single click.

No more manual plist editing, color parsing, or downloading zip files. Just search, select, and code in style.

---

## Features ✨

- **VS Code Marketplace Search**: Query the official VS Code Extension Gallery directly inside the app, download extension packs, and import them in the background.
- **Auto-Suffix Collisions**: Easily import extension packs (like *Doki Theme* or *Catppuccin*) containing multiple variants. Duplicate names are automatically resolved without crashing the app.
- **Xcode Automatic Preferences Integration**: Installing a theme automatically runs a background process updating `XCFontAndColorCurrentTheme` and `XCFontAndColorCurrentDarkTheme` preferences. The theme will be active immediately upon Xcode restart!
- **Local Database Persistence**: All imported custom themes are safely persisted locally on your disk (`~/Library/Application Support/XFace`) and reloaded automatically upon launch.
- **No Third-Party Bloat**: Built purely with native macOS commands (`/usr/bin/unzip`, `sips`, and `defaults`) avoiding heavy third-party framework dependencies.
- **Universal Binary Support**: Native execution for both Intel (`x86_64`) and Apple Silicon (`arm64`) Macs.

---

## Installation & How to Run 🛠️

### 1. Build using Xcode
1. Open the project folder or double-click `ThemeForge.xcodeproj` in Xcode.
2. Select the target **XFace** and press **Cmd + R** to run it.
3. To copy the application to your applications folder, select **Product -> Archive** in Xcode, or build it using the command-line helper.

### 2. Build via Command Line
Run the helper project compiler script to build a Release configuration directly into your `/Applications` directory:
```bash
# 1. Regenerate Xcode project
python3 generate_xcodeproj.py

# 2. Build and install to applications folder
xcodebuild -project ThemeForge.xcodeproj -scheme XFace -configuration Release build CONFIGURATION_BUILD_DIR=build
rm -rf /Applications/XFace.app
cp -R build/XFace.app /Applications/XFace.app
rm -rf build
killall Finder && killall Dock
```

---

## macOS Security Warning (Gatekeeper) 🛡️

Since **XFace** is an open-source tool and not signed with a paid Apple Developer account ($99/year), macOS will show a warning saying it **"cannot be opened because the developer cannot be verified"** or **"cannot check it for malicious software"** when run for the first time.

This is standard macOS security behavior for independent developer tools. You can easily bypass it using one of these methods:

### Method 1: The Right-Click Trick
1. Open **Finder** and navigate to your `/Applications` folder.
2. **Right-click** (or `Control` + click) the `XFace.app` icon and select **Open**.
3. A popup will appear. Click the **Open** button (instead of Cancel or Move to Trash). macOS will remember this, and the app will open normally from now on.

### Method 2: System Privacy Settings
1. Double-click the app, get the warning popup, and click **Cancel** or **OK**.
2. Open your Mac's **System Settings** and go to **Privacy & Security**.
3. Scroll down to the **Security** section. You will see a message: *"XFace was blocked from use because it is not from an identified developer."*
4. Click **Open Anyway** and enter your Mac password.

### Method 3: Clean via Terminal (Recommended)
If you downloaded a zip or dmg, you can remove the macOS "quarantine" flag from the app bundle using terminal:
```bash
xattr -d com.apple.quarantine /Applications/XFace.app
```

---

## Usage Guide 📖

1. **Import a Theme**: 
   - Click **Import JSON** at the bottom of the sidebar.
   - Go to the **Search Marketplace** tab, type a search keyword (e.g., `Tokyo Night` or `Doki Theme`), and press Enter.
   - Click **Get** to download and unpack all themes.
2. **Preview**: Click any theme in your **Imported** sidebar section to preview syntax highlighting on a Swift code editor mockup.
3. **Install**: Click **Install to Xcode** at the top right, restart Xcode, and start coding!

---

## Technical Details ⚙️

- **Framework**: SwiftUI (using the Swift 5.9 `@Observable` system).
- **Format Conversion**: Converts VS Code JSON tokens (including hex cleaning) into standard Xcode `.xccolortheme` XML configuration keys.
- **Persistence Directory**: `~/Library/Application Support/XFace/ImportedThemes/themes.json`

---

## License 📄

This project is open-source and available under the [MIT License](LICENSE).
