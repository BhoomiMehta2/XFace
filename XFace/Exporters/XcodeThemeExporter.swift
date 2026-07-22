import Foundation

// MARK: - ThemeColor Extension for Xcode Plist RGBA
extension ThemeColor {
    /// Formats the color into the space-separated decimal RGBA string format expected by Xcode.
    /// Safely ensures color is in the device RGB color space to prevent catalog space lookup crashes.
    public var xcodeColorString: String {
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            return "1 1 1 1"
        }
        let r = rgbColor.redComponent
        let g = rgbColor.greenComponent
        let b = rgbColor.blueComponent
        let a = rgbColor.alphaComponent
        
        // Xcode expects trimmed floats like "0.18039 0.20392 0.25098 1"
        // NOT padded like "0.180392 0.203922 0.250980 1.000000"
        func fmt(_ v: CGFloat) -> String {
            // Use up to 6 sig figs, strip trailing zeros
            var s = String(format: "%.6g", v)
            return s
        }
        
        return "\(fmt(r)) \(fmt(g)) \(fmt(b)) \(fmt(a))"
    }
}

/// Translates the Universal Theme Model into Xcode-specific plist configuration structure.
public final class XcodeThemeExporter {
    
    /// Converts a Universal Theme model into a valid .xccolortheme XML string.
    public static func generateXML(for theme: Theme) -> String {
        var plistDict: [String: Any] = [:]
        
        // Settings Version info
        plistDict["DVTFontAndColorVersion"] = 1
        plistDict["DVTLineSpacing"] = 1.1
        
        // Base Panel configurations
        let bgStr = theme.background.xcodeColorString
        let fgStr = theme.foreground.xcodeColorString
        let selStr = theme.selection.xcodeColorString
        let lineStr = theme.currentLine.xcodeColorString
        let cursorStr = theme.cursor.xcodeColorString
        
        plistDict["DVTSourceTextBackground"] = bgStr
        plistDict["DVTSourceTextForeground"] = fgStr
        plistDict["DVTSourceTextSelectionColor"] = selStr
        plistDict["DVTSourceTextCurrentLineHighlightColor"] = lineStr
        plistDict["DVTSourceTextInsertionPointColor"] = cursorStr
        
        plistDict["DVTConsoleTextBackgroundColor"] = bgStr
        plistDict["DVTConsoleTextSelectionColor"] = selStr
        plistDict["DVTConsoleTextInsertionPointColor"] = cursorStr
        
        plistDict["DVTConsoleDebuggerInputTextColor"] = fgStr
        plistDict["DVTConsoleDebuggerOutputTextColor"] = fgStr
        plistDict["DVTConsoleDebuggerPromptTextColor"] = theme.keyword.xcodeColorString
        
        plistDict["DVTConsoleExectuableInputTextColor"] = fgStr
        plistDict["DVTConsoleExectuableOutputTextColor"] = fgStr
        
        // Rich Markup configurations
        plistDict["DVTMarkupTextBackgroundColor"] = theme.background.xcodeColorString
        plistDict["DVTMarkupTextNormalColor"] = theme.foreground.xcodeColorString
        plistDict["DVTMarkupTextLinkColor"] = theme.class.xcodeColorString
        plistDict["DVTMarkupTextCodeFont"] = "SFMono-Regular - 11.0"
        plistDict["DVTMarkupTextEmphasisFont"] = ".SFNS-RegularItalic - 12.0"
        plistDict["DVTMarkupTextLinkFont"] = ".SFNS-Regular - 12.0"
        plistDict["DVTMarkupTextNormalFont"] = ".SFNS-Regular - 12.0"
        
        // Token syntax color definitions dictionary
        var syntaxColors: [String: String] = [:]
        
        syntaxColors["xcode.syntax.keyword"] = theme.keyword.xcodeColorString
        syntaxColors["xcode.syntax.string"] = theme.string.xcodeColorString
        syntaxColors["xcode.syntax.number"] = theme.number.xcodeColorString
        syntaxColors["xcode.syntax.comment"] = theme.comment.xcodeColorString
        syntaxColors["xcode.syntax.comment.doc"] = theme.comment.xcodeColorString
        syntaxColors["xcode.syntax.comment.doc.keyword"] = theme.keyword.xcodeColorString
        syntaxColors["xcode.syntax.declaration.type"] = theme.type.xcodeColorString
        
        syntaxColors["xcode.syntax.identifier.class"] = theme.class.xcodeColorString
        syntaxColors["xcode.syntax.identifier.class.system"] = theme.class.xcodeColorString
        syntaxColors["xcode.syntax.identifier.constant"] = theme.variable.xcodeColorString
        syntaxColors["xcode.syntax.identifier.constant.system"] = theme.variable.xcodeColorString
        syntaxColors["xcode.syntax.identifier.function"] = theme.function.xcodeColorString
        syntaxColors["xcode.syntax.identifier.function.system"] = theme.function.xcodeColorString
        syntaxColors["xcode.syntax.identifier.type"] = theme.type.xcodeColorString
        syntaxColors["xcode.syntax.identifier.type.system"] = theme.type.xcodeColorString
        syntaxColors["xcode.syntax.identifier.variable"] = theme.variable.xcodeColorString
        syntaxColors["xcode.syntax.identifier.variable.system"] = theme.variable.xcodeColorString
        
        syntaxColors["xcode.syntax.preprocessor"] = theme.preprocessor.xcodeColorString
        syntaxColors["xcode.syntax.attribute"] = theme.attribute.xcodeColorString
        syntaxColors["xcode.syntax.character"] = theme.string.xcodeColorString
        syntaxColors["xcode.syntax.plain"] = theme.plainText.xcodeColorString
        
        syntaxColors["xcode.syntax.regex"] = theme.string.xcodeColorString
        syntaxColors["xcode.syntax.regex.number"] = theme.number.xcodeColorString
        syntaxColors["xcode.syntax.regex.charname"] = theme.variable.xcodeColorString
        syntaxColors["xcode.syntax.regex.capturename"] = theme.variable.xcodeColorString
        syntaxColors["xcode.syntax.url"] = theme.class.xcodeColorString
        
        syntaxColors["xcode.syntax.declaration.other"] = theme.keyword.xcodeColorString
        syntaxColors["xcode.syntax.identifier.macro"] = theme.preprocessor.xcodeColorString
        syntaxColors["xcode.syntax.identifier.macro.system"] = theme.preprocessor.xcodeColorString
        syntaxColors["xcode.syntax.mark"] = theme.comment.xcodeColorString
        syntaxColors["xcode.syntax.markup.code"] = theme.string.xcodeColorString
        
        plistDict["DVTSourceTextSyntaxColors"] = syntaxColors
        
        // Token syntax fonts dictionary setting fallbacks
        var syntaxFonts: [String: String] = [:]
        for key in syntaxColors.keys {
            if key == "xcode.syntax.keyword" || key == "xcode.syntax.comment.doc.keyword" || key == "xcode.syntax.mark" {
                syntaxFonts[key] = "SFMono-Bold - 13.0"
            } else {
                syntaxFonts[key] = "SFMono-Medium - 13.0"
            }
        }
        
        plistDict["DVTSourceTextSyntaxFonts"] = syntaxFonts
        
        return XMLWriter.makePlistString(from: plistDict)
    }
}
