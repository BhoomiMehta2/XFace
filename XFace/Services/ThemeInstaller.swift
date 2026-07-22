import Foundation
import AppKit

/// Service handling theme installation into Xcode's FontAndColorThemes folder.
public final class ThemeInstaller {
    
    /// Adds the xccolortheme file to Xcode without setting it as active.
    public static func addTheme(themeName: String, xmlContent: String) throws {
        let fileManager = FileManager.default
        
        guard let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw NSError(
                domain: "ThemeInstaller",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not locate the User Library directory. Please check disk permissions."]
            )
        }
        
        let fontAndColorThemesURL = libraryURL
            .appendingPathComponent("Developer")
            .appendingPathComponent("Xcode")
            .appendingPathComponent("UserData")
            .appendingPathComponent("FontAndColorThemes")
        
        if !fileManager.fileExists(atPath: fontAndColorThemesURL.path) {
            try fileManager.createDirectory(at: fontAndColorThemesURL, withIntermediateDirectories: true)
        }
        
        let destinationURL = fontAndColorThemesURL.appendingPathComponent("\(themeName).xccolortheme")
        try xmlContent.write(to: destinationURL, atomically: true, encoding: .utf8)
    }
    
    public static func applyTheme(themeName: String) -> Bool {
        let domains = ["com.apple.dt.Xcode" as CFString, "com.apple.dt.Xcode-beta" as CFString]
        let themeFile = "\(themeName).xccolortheme" as CFString
        
        for domain in domains {
            CFPreferencesSetAppValue("XCFontAndColorCurrentTheme" as CFString, themeFile, domain)
            CFPreferencesSetAppValue("XCFontAndColorCurrentDarkTheme" as CFString, themeFile, domain)
            CFPreferencesAppSynchronize(domain)
        }
        
        let isXcodeRunning = NSWorkspace.shared.runningApplications.contains { app in
            app.bundleIdentifier == "com.apple.dt.Xcode" || app.bundleIdentifier == "com.apple.dt.Xcode-beta"
        }
        
        return isXcodeRunning
    }
    
    /// Deletes the xccolortheme file from Xcode's FontAndColorThemes folder.
    public static func removeTheme(themeName: String) throws {
        let fileManager = FileManager.default
        
        guard let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw NSError(
                domain: "ThemeInstaller",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not locate the User Library directory. Please check disk permissions."]
            )
        }
        
        let destinationURL = libraryURL
            .appendingPathComponent("Developer")
            .appendingPathComponent("Xcode")
            .appendingPathComponent("UserData")
            .appendingPathComponent("FontAndColorThemes")
            .appendingPathComponent("\(themeName).xccolortheme")
            
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
    }
}
