import SwiftUI
import UniformTypeIdentifiers

/// Glassmorphic helper view for native macOS backdrop blur.
public struct VisualEffectView: NSViewRepresentable {
    public let material: NSVisualEffectView.Material
    public let blendingMode: NSVisualEffectView.BlendingMode
    
    public init(material: NSVisualEffectView.Material, blendingMode: NSVisualEffectView.BlendingMode) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

import AppKit

/// A beautiful drag-and-drop container for uploading VS Code theme JSON configurations.
public struct ImportView: View {
    public var viewModel: HomeViewModel
    @State private var isDraggingOver = false
    @State private var selectedTab = 0 // 0 = Search, 1 = Clipboard & Files
    
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Import VS Code Theme")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Configure your custom VS Code editor theme")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.isImporting = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            HStack(spacing: 0) {
                // Left Column: Drag & Drop Zone
                VStack(spacing: 20) {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isDraggingOver ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.02))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isDraggingOver ? Color.accentColor : Color.secondary.opacity(0.3),
                                        style: StrokeStyle(lineWidth: 2, dash: isDraggingOver ? [] : [6, 4])
                                    )
                            )
                            .frame(height: 220)
                        
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            VStack(spacing: 4) {
                                Text("Drag & Drop JSON File")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Drop your .json theme file here")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
                        guard let provider = providers.first else { return false }
                        _ = provider.loadObject(ofClass: URL.self) { url, _ in
                            if let url = url, url.pathExtension.lowercased() == "json" {
                                DispatchQueue.main.async {
                                    viewModel.importTheme(from: url)
                                    viewModel.isImporting = false
                                }
                            }
                        }
                        return true
                    }
                    
                    Button(action: {
                        openImportPanel()
                    }) {
                        Label("Browse Files...", systemImage: "doc.text.magnifyingglass")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(width: 360)
                
                Divider()
                
                // Right Column: Tab View
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Search Marketplace").tag(0)
                        Text("Clipboard & Files").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    Divider()
                    
                    if selectedTab == 0 {
                        // Search Marketplace Tab
                        VStack(spacing: 0) {
                            HStack {
                                TextField("Search themes (e.g. Tokyo Night, Dracula)...", text: Binding(
                                    get: { viewModel.marketplaceSearchQuery },
                                    set: { viewModel.marketplaceSearchQuery = $0 }
                                ))
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    viewModel.searchMarketplaceThemes()
                                }
                                
                                Button(action: {
                                    viewModel.searchMarketplaceThemes()
                                }) {
                                    Label("Search", systemImage: "magnifyingglass")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            
                            Divider()
                            
                            if viewModel.isSearchingMarketplace {
                                Spacer()
                                ProgressView("Searching VS Code Marketplace...")
                                    .padding()
                                Spacer()
                            } else if viewModel.isImportingFromMarketplace {
                                Spacer()
                                VStack(spacing: 16) {
                                    ProgressView()
                                    Text(viewModel.marketplaceImportStatus ?? "Downloading and extracting...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                Spacer()
                            } else if viewModel.marketplaceResults.isEmpty {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text(viewModel.marketplaceSearchQuery.isEmpty ? "Enter a search query to find themes" : "No themes found matching '\(viewModel.marketplaceSearchQuery)'")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(viewModel.marketplaceResults) { ext in
                                            let isInstalled = viewModel.importedThemes.contains(where: { $0.group == (ext.displayName ?? ext.extensionName) })
                                            MarketplaceResultRow(ext: ext, isInstalled: isInstalled) {
                                                viewModel.importMarketplaceTheme(ext)
                                            }
                                        }
                                    }
                                    .padding(24)
                                }
                            }
                        }
                    } else {
                        // Clipboard & Files Tab
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                // Action: Paste from Clipboard
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Quick Clipboard Import")
                                        .font(.headline)
                                    
                                    Text("Copy the raw JSON of any theme from VS Code, then paste it here directly.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Button(action: {
                                        importFromClipboard()
                                    }) {
                                        HStack {
                                            Image(systemName: "doc.on.clipboard")
                                            Text("Paste Theme from Clipboard")
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text("⌘V")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.primary.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.bottom, 8)
                                
                                // Action: Find installed themes
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Reveal Installed Extensions")
                                        .font(.headline)
                                    
                                    Text("Open your local VS Code extensions folder in Finder to easily drag-and-drop theme JSON files.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Button(action: {
                                        revealVSCodeExtensions()
                                    }) {
                                        Label("Open Extensions Folder", systemImage: "folder.fill")
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.bottom, 8)
                                
                                // Quick Walkthrough Checklist
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("How to get Theme JSONs:")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        StepView(
                                            stepNum: "1",
                                            title: "Generate from Settings",
                                            description: "In VS Code, run Command+Shift+P and select 'Developer: Generate Color Theme From Current Settings'. Copy the text and click 'Paste Theme from Clipboard'."
                                        )
                                        
                                        StepView(
                                            stepNum: "2",
                                            title: "Search Extensions Folder",
                                            description: "Use 'Open Extensions Folder' above. Find the folder for your theme (e.g. publisher.theme-name), look inside 'themes/', and drag the .json file into our import zone."
                                        )
                                        
                                        StepView(
                                            stepNum: "3",
                                            title: "Download from GitHub",
                                            description: "Search for the theme on GitHub (e.g., 'One Dark Pro VS Code theme'), navigate to the themes folder in the repo, download the raw JSON file, and import it here."
                                        )
                                    }
                                }
                            }
                            .padding(24)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 760, height: 460)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func openImportPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.json]
        panel.title = "Select a VS Code Theme JSON"
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.importTheme(from: url)
            viewModel.isImporting = false
        }
    }
    
    private func revealVSCodeExtensions() {
        let folderPath = (NSHomeDirectory() as NSString).appendingPathComponent(".vscode/extensions")
        let url = URL(fileURLWithPath: folderPath)
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: folderPath, isDirectory: &isDir), isDir.boolValue {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory()))
            viewModel.displayError("VS Code extensions directory not found at ~/.vscode/extensions")
        }
    }
    
    private func importFromClipboard() {
        if let clipboardString = NSPasteboard.general.string(forType: .string), !clipboardString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.importTheme(fromText: clipboardString)
            viewModel.isImporting = false
        } else {
            viewModel.displayError("Your clipboard is empty or does not contain text.")
        }
    }
}

/// Row helper for Marketplace search results
struct MarketplaceResultRow: View {
    let ext: VSMarketplaceExtension
    let isInstalled: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ext.displayName ?? ext.extensionName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("by \(ext.publisher.displayName ?? ext.publisher.publisherName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let desc = ext.shortDescription {
                    Text(desc)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                        .lineLimit(2)
                        .padding(.top, 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 12)
            
            Button(action: action) {
                Text(isInstalled ? "Installed" : "Get")
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(isInstalled ? .secondary : .accentColor)
            .disabled(isInstalled)
            .controlSize(.small)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.primary.opacity(0.04) : Color.primary.opacity(0.01))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(isHovered ? 0.1 : 0.04), lineWidth: 1)
        )
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hover
            }
        }
    }
}

/// Helper subview for steps
struct StepView: View {
    let stepNum: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(stepNum)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.accentColor))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
