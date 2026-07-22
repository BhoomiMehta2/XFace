import SwiftUI

/// Represents a single theme row in the sidebar list.
public struct ThemeCard: View {
    public let theme: Theme
    public let isSelected: Bool
    
    public init(theme: Theme, isSelected: Bool) {
        self.theme = theme
        self.isSelected = isSelected
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Theme background representation
            Circle()
                .fill(theme.background.color)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white.opacity(0.8) : Color.primary.opacity(0.15), lineWidth: 1.5)
                )
                .overlay(
                    HStack(spacing: 2) {
                        Circle().fill(theme.keyword.color).frame(width: 4, height: 4)
                        Circle().fill(theme.string.color).frame(width: 4, height: 4)
                        Circle().fill(theme.function.color).frame(width: 4, height: 4)
                    }
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(theme.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Text(theme.author)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
