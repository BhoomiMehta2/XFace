import SwiftUI
import UniformTypeIdentifiers

/// Sidebar view listing built-in and imported themes, with an option to import new ones.
public struct SidebarView: View {
    public var viewModel: HomeViewModel
    
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var isBuiltInExpanded: Bool = true
    @State private var isImportedExpanded: Bool = true
    @State private var isAddedExpanded: Bool = true
    
    public var body: some View {
        List {
            Section(isExpanded: $isBuiltInExpanded) {
                ForEach(viewModel.builtInThemes) { theme in
                    ThemeCard(theme: theme, isSelected: viewModel.selectedTheme.name == theme.name)
                        .onTapGesture {
                            viewModel.selectTheme(theme)
                        }
                }
            } header: {
                Text("Built-in").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
            }
            
            if !viewModel.addedToXcodeThemes.isEmpty {
                Section(isExpanded: $isAddedExpanded) {
                    ForEach(viewModel.addedToXcodeThemes) { theme in
                        ThemeCard(theme: theme, isSelected: viewModel.selectedTheme.name == theme.name)
                            .onTapGesture {
                                viewModel.selectTheme(theme)
                            }
                    }
                } header: {
                    Text("Added to Xcode").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
                }
            }
            
            if !viewModel.importedThemes.isEmpty {
                Section(isExpanded: $isImportedExpanded) {
                    ForEach(viewModel.importedThemes) { theme in
                        ThemeCard(theme: theme, isSelected: viewModel.selectedTheme.name == theme.name)
                            .onTapGesture {
                                viewModel.selectTheme(theme)
                            }
                    }
                } header: {
                    Text("Imported").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                viewModel.isImporting = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import JSON")
                }
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(16)
        }
    }
}
