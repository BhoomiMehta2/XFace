import SwiftUI
import Observation

/// Token types for Swift code highlighting in the preview.
public enum SwiftTokenType: Sendable {
    case keyword
    case string
    case number
    case comment
    case `class`
    case function
    case variable
    case punctuation
    case plainText
    
    /// Maps token types to KeyPaths in the Theme model.
    public var themeKeyPath: KeyPath<Theme, ThemeColor> {
        switch self {
        case .keyword: return \.keyword
        case .string: return \.string
        case .number: return \.number
        case .comment: return \.comment
        case .class: return \.class
        case .function: return \.function
        case .variable: return \.variable
        case .punctuation: return \.punctuation
        case .plainText: return \.plainText
        }
    }
}

/// A single tokenized segment of code.
public struct CodeToken: Identifiable, Sendable {
    public let id = UUID()
    public let text: String
    public let type: SwiftTokenType
}

/// A line containing multiple tokenized code segments.
public struct CodeLine: Identifiable, Sendable {
    public let id = UUID()
    public let tokens: [CodeToken]
}

/// ViewModel managing code preview and syntax highlighting.
@Observable
@MainActor
public final class PreviewViewModel {
    
    /// The default sample Swift code to highlight.
    public let rawCode: String = """
    import Foundation

    class User {
        let name = "Bhoomi"
        var age = 21

        func greet() {
            print("Hello \\(name)")
        }
    }

    let user = User()
    user.greet()
    """
    
    /// Cached list of tokenized code lines.
    public private(set) var codeLines: [CodeLine] = []
    
    public init() {
        self.codeLines = tokenize(rawCode)
    }
    
    /// Performs a simple lexical analysis to convert Swift source string into colored tokens.
    public func tokenize(_ code: String) -> [CodeLine] {
        let lines = code.components(separatedBy: .newlines)
        return lines.map { tokenizeLine($0) }
    }
    
    private func tokenizeLine(_ line: String) -> CodeLine {
        var tokens: [CodeToken] = []
        var currentWord = ""
        var index = line.startIndex
        
        func flushWord() {
            if !currentWord.isEmpty {
                let type = classify(word: currentWord)
                tokens.append(CodeToken(text: currentWord, type: type))
                currentWord = ""
            }
        }
        
        while index < line.endIndex {
            let char = line[index]
            
            // Detect single line comments
            if char == "/", index < line.index(before: line.endIndex), line[line.index(after: index)] == "/" {
                flushWord()
                let commentText = String(line[index...])
                tokens.append(CodeToken(text: commentText, type: .comment))
                break
            }
            
            // Detect string literals
            if char == "\"" {
                flushWord()
                var stringVal = "\""
                var strIdx = line.index(after: index)
                while strIdx < line.endIndex {
                    let sChar = line[strIdx]
                    stringVal.append(sChar)
                    if sChar == "\"" {
                        strIdx = line.index(after: strIdx)
                        break
                    }
                    strIdx = line.index(after: strIdx)
                }
                tokens.append(CodeToken(text: stringVal, type: .string))
                index = strIdx
                continue
            }
            
            // Detect numeric literals
            if char.isNumber {
                if currentWord.isEmpty || currentWord.allSatisfy({ $0.isNumber }) {
                    currentWord.append(char)
                } else {
                    flushWord()
                    currentWord.append(char)
                }
                index = line.index(after: index)
                continue
            }
            
            // Detect identifiers (keywords / variables / types)
            if char.isLetter || char == "_" {
                currentWord.append(char)
                index = line.index(after: index)
                continue
            }
            
            // Non-identifier characters (whitespace / symbols)
            flushWord()
            if char.isWhitespace {
                tokens.append(CodeToken(text: String(char), type: .plainText))
            } else {
                tokens.append(CodeToken(text: String(char), type: .punctuation))
            }
            index = line.index(after: index)
        }
        
        flushWord()
        return CodeLine(tokens: tokens)
    }
    
    private func classify(word: String) -> SwiftTokenType {
        let keywords = ["import", "class", "let", "var", "func", "return", "if", "else", "for", "while"]
        if keywords.contains(word) {
            return .keyword
        }
        if word.allSatisfy({ $0.isNumber }) {
            return .number
        }
        if let firstChar = word.first, firstChar.isUppercase {
            return .class
        }
        let functions = ["print", "greet"]
        if functions.contains(word) {
            return .function
        }
        return .variable
    }
}
