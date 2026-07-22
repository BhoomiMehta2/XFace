import Foundation

/// Universal model representing a standard programming theme containing colors for base elements and syntax highlighting.
public struct Theme: Codable, Identifiable, Equatable, Sendable {
    public var id: String { name }
    
    public var name: String
    public var author: String
    public var group: String?
    
    // Editor UI Colors
    public var background: ThemeColor
    public var foreground: ThemeColor
    public var selection: ThemeColor
    public var currentLine: ThemeColor
    public var cursor: ThemeColor
    
    // Syntax Highlight Colors
    public var keyword: ThemeColor
    public var string: ThemeColor
    public var number: ThemeColor
    public var comment: ThemeColor
    public var type: ThemeColor
    public var `class`: ThemeColor
    public var `protocol`: ThemeColor
    public var function: ThemeColor
    public var method: ThemeColor
    public var property: ThemeColor
    public var variable: ThemeColor
    public var parameter: ThemeColor
    public var `enum`: ThemeColor
    public var namespace: ThemeColor
    public var preprocessor: ThemeColor
    public var attribute: ThemeColor
    public var `operator`: ThemeColor
    public var punctuation: ThemeColor
    public var plainText: ThemeColor
    
    public init(
        name: String,
        author: String,
        group: String? = nil,
        background: ThemeColor,
        foreground: ThemeColor,
        selection: ThemeColor,
        currentLine: ThemeColor,
        cursor: ThemeColor,
        keyword: ThemeColor,
        string: ThemeColor,
        number: ThemeColor,
        comment: ThemeColor,
        type: ThemeColor,
        `class`: ThemeColor,
        `protocol`: ThemeColor,
        function: ThemeColor,
        method: ThemeColor,
        property: ThemeColor,
        variable: ThemeColor,
        parameter: ThemeColor,
        `enum`: ThemeColor,
        namespace: ThemeColor,
        preprocessor: ThemeColor,
        attribute: ThemeColor,
        `operator`: ThemeColor,
        punctuation: ThemeColor,
        plainText: ThemeColor
    ) {
        self.name = name
        self.author = author
        self.group = group
        self.background = background
        self.foreground = foreground
        self.selection = selection
        self.currentLine = currentLine
        self.cursor = cursor
        self.keyword = keyword
        self.string = string
        self.number = number
        self.comment = comment
        self.type = type
        self.class = `class`
        self.protocol = `protocol`
        self.function = function
        self.method = method
        self.property = property
        self.variable = variable
        self.parameter = parameter
        self.enum = `enum`
        self.namespace = namespace
        self.preprocessor = preprocessor
        self.attribute = attribute
        self.operator = `operator`
        self.punctuation = punctuation
        self.plainText = plainText
    }
}

// MARK: - Mocks for Phase 1
extension Theme {
    public static var dracula: Theme {
        Theme(
            name: "Dracula",
            author: "Zeno Rocha",
            background: ThemeColor(hex: "#282a36"),
            foreground: ThemeColor(hex: "#f8f8f2"),
            selection: ThemeColor(hex: "#44475a"),
            currentLine: ThemeColor(hex: "#44475a"),
            cursor: ThemeColor(hex: "#f8f8f0"),
            keyword: ThemeColor(hex: "#ff79c6"),
            string: ThemeColor(hex: "#f1fa8c"),
            number: ThemeColor(hex: "#bd93f9"),
            comment: ThemeColor(hex: "#6272a4"),
            type: ThemeColor(hex: "#8be9fd"),
            class: ThemeColor(hex: "#50fa7b"),
            protocol: ThemeColor(hex: "#8be9fd"),
            function: ThemeColor(hex: "#50fa7b"),
            method: ThemeColor(hex: "#50fa7b"),
            property: ThemeColor(hex: "#f8f8f2"),
            variable: ThemeColor(hex: "#f8f8f2"),
            parameter: ThemeColor(hex: "#ffb86c"),
            enum: ThemeColor(hex: "#8be9fd"),
            namespace: ThemeColor(hex: "#ff79c6"),
            preprocessor: ThemeColor(hex: "#ff79c6"),
            attribute: ThemeColor(hex: "#50fa7b"),
            operator: ThemeColor(hex: "#ff79c6"),
            punctuation: ThemeColor(hex: "#f8f8f2"),
            plainText: ThemeColor(hex: "#f8f8f2")
        )
    }
    
    public static var tokyoNight: Theme {
        Theme(
            name: "Tokyo Night",
            author: "folke",
            background: ThemeColor(hex: "#1a1b26"),
            foreground: ThemeColor(hex: "#a9b1d6"),
            selection: ThemeColor(hex: "#33467c"),
            currentLine: ThemeColor(hex: "#292e42"),
            cursor: ThemeColor(hex: "#c0caf5"),
            keyword: ThemeColor(hex: "#bb9af7"),
            string: ThemeColor(hex: "#9ece6a"),
            number: ThemeColor(hex: "#ff9e64"),
            comment: ThemeColor(hex: "#565f89"),
            type: ThemeColor(hex: "#2ac3de"),
            class: ThemeColor(hex: "#0db9d7"),
            protocol: ThemeColor(hex: "#7aa2f7"),
            function: ThemeColor(hex: "#7aa2f7"),
            method: ThemeColor(hex: "#7aa2f7"),
            property: ThemeColor(hex: "#7aa2f7"),
            variable: ThemeColor(hex: "#c0caf5"),
            parameter: ThemeColor(hex: "#e0af68"),
            enum: ThemeColor(hex: "#2ac3de"),
            namespace: ThemeColor(hex: "#7aa2f7"),
            preprocessor: ThemeColor(hex: "#89ddff"),
            attribute: ThemeColor(hex: "#ff007f"),
            operator: ThemeColor(hex: "#89ddff"),
            punctuation: ThemeColor(hex: "#89ddff"),
            plainText: ThemeColor(hex: "#a9b1d6")
        )
    }

    public static var oneDarkPro: Theme {
        Theme(
            name: "One Dark Pro",
            author: "binaryify",
            background: ThemeColor(hex: "#282c34"),
            foreground: ThemeColor(hex: "#abb2bf"),
            selection: ThemeColor(hex: "#3e4451"),
            currentLine: ThemeColor(hex: "#2c313c"),
            cursor: ThemeColor(hex: "#528bff"),
            keyword: ThemeColor(hex: "#c678dd"),
            string: ThemeColor(hex: "#98c379"),
            number: ThemeColor(hex: "#d19a66"),
            comment: ThemeColor(hex: "#5c6370"),
            type: ThemeColor(hex: "#e5c07b"),
            class: ThemeColor(hex: "#e5c07b"),
            protocol: ThemeColor(hex: "#61afef"),
            function: ThemeColor(hex: "#61afef"),
            method: ThemeColor(hex: "#61afef"),
            property: ThemeColor(hex: "#e06c75"),
            variable: ThemeColor(hex: "#abb2bf"),
            parameter: ThemeColor(hex: "#abb2bf"),
            enum: ThemeColor(hex: "#e5c07b"),
            namespace: ThemeColor(hex: "#c678dd"),
            preprocessor: ThemeColor(hex: "#c678dd"),
            attribute: ThemeColor(hex: "#d19a66"),
            operator: ThemeColor(hex: "#56b6c2"),
            punctuation: ThemeColor(hex: "#abb2bf"),
            plainText: ThemeColor(hex: "#abb2bf")
        )
    }

    public static var catppuccin: Theme {
        Theme(
            name: "Catppuccin Mocha",
            author: "Catppuccin Org",
            background: ThemeColor(hex: "#1e1e2e"),
            foreground: ThemeColor(hex: "#cdd6f4"),
            selection: ThemeColor(hex: "#585b70"),
            currentLine: ThemeColor(hex: "#313244"),
            cursor: ThemeColor(hex: "#f5e0dc"),
            keyword: ThemeColor(hex: "#cba6f7"),
            string: ThemeColor(hex: "#a6e3a1"),
            number: ThemeColor(hex: "#fab387"),
            comment: ThemeColor(hex: "#6c7086"),
            type: ThemeColor(hex: "#cdd6f4"),
            class: ThemeColor(hex: "#f9e2af"),
            protocol: ThemeColor(hex: "#f9e2af"),
            function: ThemeColor(hex: "#89b4fa"),
            method: ThemeColor(hex: "#89b4fa"),
            property: ThemeColor(hex: "#89dceb"),
            variable: ThemeColor(hex: "#cdd6f4"),
            parameter: ThemeColor(hex: "#f5e0dc"),
            enum: ThemeColor(hex: "#f9e2af"),
            namespace: ThemeColor(hex: "#f5c2e7"),
            preprocessor: ThemeColor(hex: "#f5c2e7"),
            attribute: ThemeColor(hex: "#89b4fa"),
            operator: ThemeColor(hex: "#89dceb"),
            punctuation: ThemeColor(hex: "#9399b2"),
            plainText: ThemeColor(hex: "#cdd6f4")
        )
    }

    public static var nord: Theme {
        Theme(
            name: "Nord",
            author: "Arctic Ice Studio",
            background: ThemeColor(hex: "#2e3440"),
            foreground: ThemeColor(hex: "#d8dee9"),
            selection: ThemeColor(hex: "#434c5e"),
            currentLine: ThemeColor(hex: "#3b4252"),
            cursor: ThemeColor(hex: "#d8dee9"),
            keyword: ThemeColor(hex: "#81a1c1"),
            string: ThemeColor(hex: "#a3be8c"),
            number: ThemeColor(hex: "#b48ead"),
            comment: ThemeColor(hex: "#4c566a"),
            type: ThemeColor(hex: "#8fbcbb"),
            class: ThemeColor(hex: "#8fbcbb"),
            protocol: ThemeColor(hex: "#88c0d0"),
            function: ThemeColor(hex: "#88c0d0"),
            method: ThemeColor(hex: "#88c0d0"),
            property: ThemeColor(hex: "#d8dee9"),
            variable: ThemeColor(hex: "#d8dee9"),
            parameter: ThemeColor(hex: "#d8dee9"),
            enum: ThemeColor(hex: "#8fbcbb"),
            namespace: ThemeColor(hex: "#81a1c1"),
            preprocessor: ThemeColor(hex: "#5e81ac"),
            attribute: ThemeColor(hex: "#8fbcbb"),
            operator: ThemeColor(hex: "#81a1c1"),
            punctuation: ThemeColor(hex: "#eceff4"),
            plainText: ThemeColor(hex: "#d8dee9")
        )
    }
}
