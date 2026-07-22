import SwiftUI
import AppKit

/// Represents a color in the theme, storing its hex value and offering helper utilities for SwiftUI/AppKit.
public struct ThemeColor: Codable, Equatable, Sendable {
    public var hex: String
    
    public init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanHex.hasPrefix("#") {
            cleanHex = "#" + cleanHex
        }
        self.hex = cleanHex
    }
    
    /// SwiftUI Color representation.
    public var color: Color {
        Color(nsColor: nsColor)
    }
    
    /// NSColor representation for AppKit components.
    public var nsColor: NSColor {
        var rgb: UInt64 = 0
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        // Support 6-digit (#RRGGBB) or 8-digit (#RRGGBBAA) hex codes
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else {
            return .textColor
        }
        
        let r, g, b, a: CGFloat
        if cleanHex.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if cleanHex.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return .textColor
        }
        
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}
