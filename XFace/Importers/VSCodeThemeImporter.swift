import Foundation

/// Internal Decodable representing the raw structure of a VS Code theme JSON.
public struct VSCodeTheme: Decodable {
    public let name: String?
    public let type: String?
    public let colors: [String: String]?
    public let tokenColors: [VSCodeTokenColor]?
}

/// A token color rule mapping TextMate scopes to visual settings.
public struct VSCodeTokenColor: Decodable {
    public let name: String?
    public let scope: VSCodeScope?
    public let settings: VSCodeTokenSettings?
}

/// Helper structure wrapping a single or multi-string scope selector.
public enum VSCodeScope: Decodable {
    case single(String)
    case multiple([String])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleVal = try? container.decode(String.self) {
            self = .single(singleVal)
        } else if let arrayVal = try? container.decode([String].self) {
            self = .multiple(arrayVal)
        } else {
            throw DecodingError.typeMismatch(
                VSCodeScope.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Scope must be a String or an Array of Strings"
                )
            )
        }
    }
    
    /// Normalizes and returns the scope string names as a clean list.
    public var list: [String] {
        switch self {
        case .single(let str):
            return str.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        case .multiple(let array):
            return array
        }
    }
}

/// Visual settings inside a VS Code token rule.
public struct VSCodeTokenSettings: Decodable {
    public let foreground: String?
}

/// Reads and imports VS Code theme JSON files.
public final class VSCodeThemeImporter {
    
    /// Decodes a VS Code Theme JSON from a given URL after removing any inline comments.
    public static func importTheme(from url: URL) throws -> VSCodeTheme {
        let data = try Data(contentsOf: url)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "VSCodeThemeImporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid file encoding. File must be UTF-8."])
        }
        
        let cleanedString = cleanJSONComments(jsonString)
        guard let cleanedData = cleanedString.data(using: .utf8) else {
            throw NSError(domain: "VSCodeThemeImporter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to sanitize comments from JSON file."])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VSCodeTheme.self, from: cleanedData)
    }
    
    /// Strips inline single line (//) and multi line (/* */) comments from JSON strings.
    public static func cleanJSONComments(_ jsonString: String) -> String {
        var result = ""
        var inString = false
        var inSingleComment = false
        var inMultiComment = false
        
        let chars = Array(jsonString)
        var i = 0
        while i < chars.count {
            let char = chars[i]
            
            if inSingleComment {
                if char == "\n" || char == "\r" {
                    inSingleComment = false
                    result.append(char)
                }
            } else if inMultiComment {
                if char == "*", i + 1 < chars.count, chars[i + 1] == "/" {
                    inMultiComment = false
                    i += 1
                }
            } else if inString {
                if char == "\"" {
                    // Check if escaped
                    var escaped = false
                    var j = i - 1
                    while j >= 0 && chars[j] == "\\" {
                        escaped = !escaped
                        j -= 1
                    }
                    if !escaped {
                        inString = false
                    }
                }
                result.append(char)
            } else {
                if char == "\"", i == 0 || chars[i - 1] != "\\" {
                    inString = true
                    result.append(char)
                } else if char == "/", i + 1 < chars.count, chars[i + 1] == "/" {
                    inSingleComment = true
                    i += 1
                } else if char == "/", i + 1 < chars.count, chars[i + 1] == "*" {
                    inMultiComment = true
                    i += 1
                } else {
                    result.append(char)
                }
            }
            i += 1
        }
        return result
    }
}
