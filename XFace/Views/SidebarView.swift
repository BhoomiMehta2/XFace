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
                    renderThemeGroup(themes: viewModel.addedToXcodeThemes)
                } header: {
                    Text("Added to Xcode").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
                }
            }
            
            if !viewModel.importedThemes.isEmpty {
                Section(isExpanded: $isImportedExpanded) {
                    renderThemeGroup(themes: viewModel.importedThemes)
                } header: {
                    Text("Imported").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .animation(.default, value: viewModel.importedThemes)
        .animation(.default, value: viewModel.addedToXcodeThemes)
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
    
    @State private var expandedGroups: Set<String> = []
    
    @ViewBuilder
    private func renderThemeGroup(themes: [Theme]) -> some View {
        let grouped = Dictionary(grouping: themes, by: { $0.group ?? "" })
        let sortedKeys = grouped.keys.sorted()
        
        ForEach(sortedKeys, id: \.self) { key in
            if key == "" {
                // Ungrouped themes
                ForEach(grouped[key] ?? []) { theme in
                    renderThemeRow(theme)
                }
            } else {
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedGroups.contains(key) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedGroups.insert(key)
                            } else {
                                expandedGroups.remove(key)
                            }
                        }
                    )
                ) {
                    ForEach(grouped[key] ?? []) { theme in
                        renderThemeRow(theme)
                    }
                } label: {
                    Label(key, systemImage: "folder.fill")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderThemeRow(_ theme: Theme) -> some View {
        ThemeCard(theme: theme, isSelected: viewModel.selectedTheme.name == theme.name)
            .onTapGesture {
                viewModel.selectTheme(theme)
            }
            .contextMenu {
                Button(role: .destructive) {
                    viewModel.deleteTheme(theme)
                } label: {
                    Label("Delete Theme", systemImage: "trash")
                }
            }
    }
}
