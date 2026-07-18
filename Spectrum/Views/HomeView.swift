import SwiftUI

/// Secondary component displaying theme colors.
public struct ColorPaletteBadge: View {
    public let name: String
    public let color: Color
    
    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.primary.opacity(0.15), lineWidth: 1))
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

/// The main dashboard view containing layout partitions, theme cards, toolbars, and alerts.
public struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var previewViewModel = PreviewViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
                .frame(minWidth: 220, idealWidth: 260)
        } detail: {
            VStack(spacing: 0) {
                // Header Panel
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedTheme.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Author: \(viewModel.selectedTheme.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.exportTheme()
                        }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        
                        if viewModel.activeThemeName == viewModel.selectedTheme.name {
                            Button(action: {}) {
                                Label("Applied", systemImage: "checkmark.circle.fill")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(NSColor.systemGray))
                            .controlSize(.large)
                            .disabled(true)
                        } else if viewModel.addedToXcodeThemes.contains(where: { $0.name == viewModel.selectedTheme.name }) {
                            Button(action: {
                                viewModel.applyTheme()
                            }) {
                                Label("Apply to Xcode", systemImage: "checkmark.seal.fill")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .controlSize(.large)
                        } else {
                            Button(action: {
                                viewModel.addTheme()
                            }) {
                                Label("Add to Xcode", systemImage: "plus.app.fill")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                
                Divider()
                
                // Content Body
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Theme Palette Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme Palette")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ColorPaletteBadge(name: "Background", color: viewModel.selectedTheme.background.color)
                                    ColorPaletteBadge(name: "Foreground", color: viewModel.selectedTheme.foreground.color)
                                    ColorPaletteBadge(name: "Keywords", color: viewModel.selectedTheme.keyword.color)
                                    ColorPaletteBadge(name: "Strings", color: viewModel.selectedTheme.string.color)
                                    ColorPaletteBadge(name: "Classes", color: viewModel.selectedTheme.class.color)
                                    ColorPaletteBadge(name: "Functions", color: viewModel.selectedTheme.function.color)
                                    ColorPaletteBadge(name: "Comments", color: viewModel.selectedTheme.comment.color)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        
                        // Swift Code syntax preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Syntax Highlights")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            PreviewEditor(theme: viewModel.selectedTheme, previewViewModel: previewViewModel)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .frame(minWidth: 540)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.isImporting = true
                }) {
                    Label("Import Theme", systemImage: "square.and.arrow.down")
                }
                .help("Import Custom VS Code Theme JSON")
            }
        }
        .sheet(isPresented: $viewModel.isImporting) {
            ImportView(viewModel: viewModel)
        }
        // Custom Success Toast Overlay
        .overlay(alignment: .bottom) {
            if viewModel.showSuccessMessage {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    Text(viewModel.successMessage)
                        .fontWeight(.medium)
                        .font(.body)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 24)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            viewModel.showSuccessMessage = false
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .alert("Restart Xcode Required", isPresented: $viewModel.showRestartAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Spectrum has installed your theme, but Xcode is currently open. Please quit Xcode completely (Cmd+Q) and reopen it to apply the theme automatically.")
        }
    }
}
