import SwiftUI

/// A code editor preview component that displays Swift code highlighted according to the selected theme.
public struct PreviewEditor: View {
    public let theme: Theme
    public let previewViewModel: PreviewViewModel
    
    public init(theme: Theme, previewViewModel: PreviewViewModel) {
        self.theme = theme
        self.previewViewModel = previewViewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tab Header
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "swift")
                        .foregroundColor(.orange)
                        .font(.system(size: 11, weight: .semibold))
                    Text("User.swift")
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(theme.foreground.color)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(theme.background.color)
                .clipShape(
                    .rect(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 8
                    )
                )
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.15))
            
            // Editor Body
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(previewViewModel.codeLines.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            // Line gutter (numbers)
                            Text(String(format: "%2d", index + 1))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(theme.comment.color.opacity(0.5))
                                .frame(width: 24, alignment: .trailing)
                                .userActivity("ignore") { _ in } // prevent selection behavior on system symbols
                            
                            // Code Line text
                            HStack(spacing: 0) {
                                ForEach(line.tokens) { token in
                                    Text(token.text)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(theme[keyPath: token.type.themeKeyPath].color)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .frame(minWidth: 500, alignment: .leading)
            }
            .background(theme.background.color)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
