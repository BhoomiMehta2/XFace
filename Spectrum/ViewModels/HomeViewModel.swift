import SwiftUI
import Observation

/// ViewModel that manages the primary state of the ThemeForge application.
@Observable
@MainActor
public final class HomeViewModel {
    /// Array of built-in themes parsed from resources.
    public private(set) var builtInThemes: [Theme] = []
    
    /// User imported custom themes.
    public var importedThemes: [Theme] = []
    
    /// The currently selected theme for previewing.
    public var selectedTheme: Theme
    
    /// Themes that have been explicitly added to Xcode's FontAndColorThemes folder.
    public var addedToXcodeThemes: [Theme] = []
    
    /// The name of the theme currently applied to Xcode.
    public var activeThemeName: String? = nil
    
    /// Determines whether the import sheet is presented.
    public var isImporting: Bool = false
    
    /// Stores the active error message if an operation fails.
    public var errorMessage: String? = nil
    
    /// Controls whether the error alert is visible.
    public var showErrorAlert: Bool = false
    
    /// Controls whether the success message is visible.
    public var showSuccessMessage: Bool = false
    
    /// The text for the success notification.
    public var successMessage: String = ""
    
    /// Controls whether the Xcode restart alert popup is visible.
    public var showRestartAlert: Bool = false
    
    // MARK: - VS Code Marketplace Properties
    
    /// Results of the VS Code Marketplace search query.
    public var marketplaceResults: [VSMarketplaceExtension] = []
    
    /// Indicates whether a marketplace query is in progress.
    public var isSearchingMarketplace: Bool = false
    
    /// Stores the marketplace theme search query.
    public var marketplaceSearchQuery: String = ""
    
    /// Indicates if a marketplace package download & install is active.
    public var isImportingFromMarketplace: Bool = false
    
    /// Message summarizing the current status of marketplace download/extraction.
    public var marketplaceImportStatus: String? = nil

    public init() {
        // Load the actual bundled resources
        let loaded = Self.loadBuiltInThemes()
        self.builtInThemes = loaded
        
        // Load persisted custom themes
        let persisted = Self.loadPersistedThemes()
        self.importedThemes = persisted
        
        let persistedAdded = Self.loadPersistedAddedThemes()
        self.addedToXcodeThemes = persistedAdded
        
        self.activeThemeName = UserDefaults.standard.string(forKey: "ActiveXcodeTheme")
        
        // Default to the first imported theme if exists, otherwise default to Dracula
        self.selectedTheme = persisted.first ?? loaded.first(where: { $0.name.contains("Dracula") }) ?? .dracula
    }
    
    private static func loadBuiltInThemes() -> [Theme] {
        let resourceNames = ["Dracula", "TokyoNight", "OneDark", "Catppuccin", "Nord"]
        var loaded: [Theme] = []
        
        for name in resourceNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
                continue
            }
            do {
                let vscodeTheme = try VSCodeThemeImporter.importTheme(from: url)
                let theme = ThemeConverter.convert(vscodeTheme: vscodeTheme, defaultName: name)
                loaded.append(theme)
            } catch {
                print("Error parsing bundled resource \(name).json: \(error.localizedDescription)")
            }
        }
        
        // Fallback to memory mocks if bundle isn't resolved (e.g., Xcode Previews)
        if loaded.isEmpty {
            return [.dracula, .tokyoNight, .oneDarkPro, .catppuccin, .nord]
        }
        
        return loaded
    }
    
    /// Selects a theme for previewing.
    public func selectTheme(_ theme: Theme) {
        selectedTheme = theme
    }
    
    /// Resolves duplicate theme names by appending a suffix (e.g. " (1)").
    private func uniqueThemeName(for baseName: String) -> String {
        var candidate = baseName
        var suffix = 1
        
        let isDuplicate: (String) -> Bool = { name in
            self.builtInThemes.contains(where: { $0.name.lowercased() == name.lowercased() }) ||
            self.importedThemes.contains(where: { $0.name.lowercased() == name.lowercased() })
        }
        
        while isDuplicate(candidate) {
            candidate = "\(baseName) (\(suffix))"
            suffix += 1
        }
        
        return candidate
    }
    
    /// Imports a theme from a VS Code theme JSON file.
    public func importTheme(from url: URL) {
        do {
            let vscodeTheme = try VSCodeThemeImporter.importTheme(from: url)
            let defaultName = url.deletingPathExtension().lastPathComponent
            let resolvedName = uniqueThemeName(for: vscodeTheme.name ?? defaultName)
            
            let theme = ThemeConverter.convert(vscodeTheme: vscodeTheme, defaultName: resolvedName)
            
            importedThemes.append(theme)
            saveThemes()
            selectedTheme = theme
            triggerSuccess("Imported theme '\(resolvedName)' successfully!")
        } catch {
            displayError("Failed to parse VS Code theme: \(error.localizedDescription)")
        }
    }
    
    /// Imports a theme from a raw VS Code theme JSON string.
    public func importTheme(fromText text: String, defaultName: String = "Pasted Theme") {
        do {
            let cleanedString = VSCodeThemeImporter.cleanJSONComments(text)
            guard let cleanedData = cleanedString.data(using: .utf8) else {
                throw NSError(domain: "VSCodeThemeImporter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to sanitize comments from JSON string."])
            }
            
            let decoder = JSONDecoder()
            let vscodeTheme = try decoder.decode(VSCodeTheme.self, from: cleanedData)
            let resolvedName = uniqueThemeName(for: vscodeTheme.name ?? defaultName)
            
            let theme = ThemeConverter.convert(vscodeTheme: vscodeTheme, defaultName: resolvedName)
            
            importedThemes.append(theme)
            saveThemes()
            selectedTheme = theme
            triggerSuccess("Imported theme '\(resolvedName)' successfully!")
        } catch {
            displayError("Failed to parse VS Code theme JSON: \(error.localizedDescription)")
        }
    }
    
    /// Adds the theme to Xcode and the sidebar list without applying it.
    public func addTheme() {
        do {
            let xmlContent = XcodeThemeExporter.generateXML(for: selectedTheme)
            try ThemeInstaller.addTheme(themeName: selectedTheme.name, xmlContent: xmlContent)
            
            if !addedToXcodeThemes.contains(where: { $0.name == selectedTheme.name }) {
                addedToXcodeThemes.append(selectedTheme)
                saveAddedThemes()
            }
            triggerSuccess("Theme '\(selectedTheme.name)' added to Xcode!")
        } catch {
            displayError("Failed to add theme to Xcode: \(error.localizedDescription)")
        }
    }
    
    /// Applies the theme in Xcode preferences.
    public func applyTheme() {
        let needsRestart = ThemeInstaller.applyTheme(themeName: selectedTheme.name)
        
        activeThemeName = selectedTheme.name
        UserDefaults.standard.set(selectedTheme.name, forKey: "ActiveXcodeTheme")
        
        if needsRestart {
            self.showRestartAlert = true
        } else {
            triggerSuccess("Theme '\(selectedTheme.name)' set as active in Xcode successfully!")
        }
    }
    
    /// Exports the theme as an .xccolortheme file.
    public func exportTheme() {
        do {
            let xmlContent = XcodeThemeExporter.generateXML(for: selectedTheme)
            let didSave = try ThemeExporter.export(themeName: selectedTheme.name, xmlContent: xmlContent)
            if didSave {
                triggerSuccess("Theme '\(selectedTheme.name)' exported successfully.")
            }
        } catch {
            displayError("Theme Export failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - VS Code Marketplace Actions
    
    /// Performs a marketplace search for themes asynchronously.
    public func searchMarketplaceThemes() {
        guard !marketplaceSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.marketplaceResults = []
            return
        }
        
        isSearchingMarketplace = true
        marketplaceResults = []
        
        Task {
            do {
                let results = try await VSCodeMarketplaceService.searchThemes(query: marketplaceSearchQuery)
                self.marketplaceResults = results
                self.isSearchingMarketplace = false
            } catch {
                self.isSearchingMarketplace = false
                self.displayError("Marketplace search failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Downloads, extracts, and imports themes from the specified marketplace extension.
    public func importMarketplaceTheme(_ ext: VSMarketplaceExtension) {
        guard let version = ext.versions?.first,
              let vsixFile = version.files?.first(where: { $0.assetType == "Microsoft.VisualStudio.Services.VSIXPackage" }) else {
            self.displayError("This theme extension pack has no downloadable package.")
            return
        }
        
        isImportingFromMarketplace = true
        marketplaceImportStatus = "Downloading extension package..."
        
        Task {
            do {
                // 1. Download VSIX package
                let vsixURL = try await VSCodeMarketplaceService.downloadVSIX(from: vsixFile.source)
                
                // 2. Extract theme JSONs
                self.marketplaceImportStatus = "Extracting theme configuration..."
                let themes = try VSCodeMarketplaceService.extractThemes(fromVSIX: vsixURL)
                
                // 3. Import each theme
                for theme in themes {
                    self.importTheme(fromText: theme.content, defaultName: theme.name)
                }
                
                self.isImportingFromMarketplace = false
                self.marketplaceImportStatus = nil
                self.isImporting = false // Close the sheet upon success
            } catch {
                self.isImportingFromMarketplace = false
                self.marketplaceImportStatus = nil
                self.displayError("Failed to extract theme package: \(error.localizedDescription)")
            }
        }
    }
    
    /// Displays a user-facing error message.
    public func displayError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    /// Displays a user-facing success notification.
    public func triggerSuccess(_ message: String) {
        self.successMessage = message
        self.showSuccessMessage = true
    }
    
    // MARK: - Persist Imported Themes
    
    private static func getImportedThemesDirectory() -> URL? {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = appSupport.appendingPathComponent("Spectrum").appendingPathComponent("ImportedThemes")
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private func saveThemes() {
        guard let dir = Self.getImportedThemesDirectory() else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(importedThemes)
            let fileURL = dir.appendingPathComponent("themes.json")
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save imported themes: \(error.localizedDescription)")
        }
    }
    
    private func saveAddedThemes() {
        guard let dir = Self.getImportedThemesDirectory() else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(addedToXcodeThemes)
            let fileURL = dir.appendingPathComponent("added_themes.json")
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save added themes: \(error.localizedDescription)")
        }
    }
    
    private static func loadPersistedThemes() -> [Theme] {
        guard let dir = getImportedThemesDirectory() else { return [] }
        let fileURL = dir.appendingPathComponent("themes.json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([Theme].self, from: data)
        } catch {
            print("Failed to load persisted themes: \(error.localizedDescription)")
            return []
        }
    }
    
    private static func loadPersistedAddedThemes() -> [Theme] {
        guard let dir = getImportedThemesDirectory() else { return [] }
        let fileURL = dir.appendingPathComponent("added_themes.json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([Theme].self, from: data)
        } catch {
            print("Failed to load persisted added themes: \(error.localizedDescription)")
            return []
        }
    }
}

/// Enumeration of localized errors that can occur during theme operations.
public enum ThemeError: Error, LocalizedError {
    case duplicateName(String)
    case invalidJSON
    case invalidColors
    case installationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .duplicateName(let name):
            return "A theme named '\(name)' already exists. Please choose a different theme name."
        case .invalidJSON:
            return "The imported file is not a valid JSON or VS Code theme."
        case .invalidColors:
            return "The theme JSON does not contain valid hexadecimal colors."
        case .installationFailed(let reason):
            return "Failed to install the theme to Xcode: \(reason)"
        }
    }
}
