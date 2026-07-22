import AppKit
import UniformTypeIdentifiers

/// Service handling theme export using native NSSavePanel dialogs.
public final class ThemeExporter {
    
    /// Displays a save panel to export an .xccolortheme file to disk.
    @MainActor
    public static func export(themeName: String, xmlContent: String) throws -> Bool {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "xccolortheme")].compactMap { $0 }
        savePanel.nameFieldStringValue = "\(themeName).xccolortheme"
        savePanel.title = "Export Xcode Theme"
        savePanel.prompt = "Export"
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return false
        }
        
        try xmlContent.write(to: url, atomically: true, encoding: .utf8)
        return true
    }
}
