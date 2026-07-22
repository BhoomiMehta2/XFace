import Foundation

/// Utility class to parse and validate color strings from VS Code themes.
public final class ColorParser {
    
    /// Normalizes and parses a hex color string into a standardized format.
    /// Supports #RGB, #RGBA, #RRGGBB, and #RRGGBBAA.
    public static func parse(_ hexString: String?) -> ThemeColor? {
        guard let hex = hexString else { return nil }
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        // Normalize 3-digit and 4-digit hex codes
        if cleanHex.count == 3 {
            cleanHex = cleanHex.map { "\($0)\($0)" }.joined()
        } else if cleanHex.count == 4 {
            cleanHex = cleanHex.map { "\($0)\($0)" }.joined()
        }
        
        guard cleanHex.count == 6 || cleanHex.count == 8 else {
            return nil
        }
        
        // Validate hex format
        let hexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        guard cleanHex.unicodeScalars.allSatisfy({ hexChars.contains($0) }) else {
            return nil
        }
        
        return ThemeColor(hex: "#" + cleanHex)
    }
}
