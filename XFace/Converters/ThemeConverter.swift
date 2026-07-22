import Foundation

/// Converter that translates raw VS Code theme configurations into the Universal Theme Model.
public final class ThemeConverter {
    
    /// Converts a Decoded VS Code Theme configuration into a standard Theme.
    public static func convert(vscodeTheme: VSCodeTheme, defaultName: String = "Untitled Theme") -> Theme {
        let name = vscodeTheme.name ?? defaultName
        let author = "XFace Importer"
        
        let colors = vscodeTheme.colors ?? [:]
        let tokenColors = vscodeTheme.tokenColors ?? []
        
        // 1. Resolve UI/Editor Colors
        let background = ColorParser.parse(colors["editor.background"]) ?? ThemeColor(hex: "#1E1E1E")
        let foreground = ColorParser.parse(colors["editor.foreground"]) ?? ThemeColor(hex: "#D4D4D4")
        let selection = ColorParser.parse(colors["editor.selectionBackground"]) ?? ThemeColor(hex: "#264F78")
        let currentLine = ColorParser.parse(colors["editor.lineHighlightBackground"]) ?? ThemeColor(hex: "#282828")
        let cursor = ColorParser.parse(colors["editorCursor.foreground"]) ?? ThemeColor(hex: "#AEAFAD")
        
        // Helper block to match scopes
        func findColor(forScopes targetScopes: [String]) -> ThemeColor {
            for target in targetScopes {
                if let hex = colorForScope(target, in: tokenColors) {
                    if let parsed = ColorParser.parse(hex) {
                        return parsed
                    }
                }
            }
            return foreground // Default fallback is theme editor foreground
        }
        
        // 2. Map Syntax Highlight Categories
        let keyword = findColor(forScopes: ["keyword.control", "keyword", "storage.type", "storage"])
        let string = findColor(forScopes: ["string", "string.quoted", "punctuation.definition.string"])
        let number = findColor(forScopes: ["constant.numeric"])
        let comment = findColor(forScopes: ["comment", "punctuation.definition.comment"])
        let type = findColor(forScopes: ["support.type", "entity.name.type"])
        let `class` = findColor(forScopes: ["entity.name.type.class", "entity.name.class", "support.class"])
        let `protocol` = findColor(forScopes: ["entity.name.type.interface", "entity.name.type.protocol", "entity.name.interface"])
        let function = findColor(forScopes: ["support.function", "entity.name.function"])
        let method = findColor(forScopes: ["entity.name.function.member", "meta.function-call", "entity.name.function"])
        let property = findColor(forScopes: ["variable.other.property", "support.type.property-name", "variable.other.object.property"])
        let variable = findColor(forScopes: ["variable", "variable.other.readwrite", "variable.other"])
        let parameter = findColor(forScopes: ["variable.parameter"])
        let `enum` = findColor(forScopes: ["entity.name.type.enum", "entity.name.enum"])
        let namespace = findColor(forScopes: ["entity.name.namespace", "support.other.namespace"])
        let preprocessor = findColor(forScopes: ["meta.preprocessor", "keyword.control.directive", "keyword.control.import"])
        let attribute = findColor(forScopes: ["entity.other.attribute-name", "meta.attribute"])
        let `operator` = findColor(forScopes: ["keyword.operator", "storage.type.number.css"])
        let punctuation = findColor(forScopes: ["punctuation", "meta.brace", "punctuation.section"])
        let plainText = foreground
        
        return Theme(
            name: name,
            author: author,
            background: background,
            foreground: foreground,
            selection: selection,
            currentLine: currentLine,
            cursor: cursor,
            keyword: keyword,
            string: string,
            number: number,
            comment: comment,
            type: type,
            class: `class`,
            protocol: `protocol`,
            function: function,
            method: method,
            property: property,
            variable: variable,
            parameter: parameter,
            enum: `enum`,
            namespace: namespace,
            preprocessor: preprocessor,
            attribute: attribute,
            operator: `operator`,
            punctuation: punctuation,
            plainText: plainText
        )
    }
    
    /// Finds the best (longest matching prefix) color matching a textmate scope.
    private static func colorForScope(_ targetScope: String, in tokenColors: [VSCodeTokenColor]) -> String? {
        var bestMatchColor: String? = nil
        var bestMatchLength = 0
        
        for token in tokenColors {
            guard let foreground = token.settings?.foreground, let scopes = token.scope?.list else { continue }
            for scope in scopes {
                if targetScope == scope {
                    return foreground // Exact matches win immediately
                }
                // TextMate subscope match: e.g. "keyword" matches "keyword.control"
                if targetScope.hasPrefix(scope + ".") {
                    if scope.count > bestMatchLength {
                        bestMatchLength = scope.count
                        bestMatchColor = foreground
                    }
                }
            }
        }
        return bestMatchColor
    }
}
