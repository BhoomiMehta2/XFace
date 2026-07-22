import SwiftUI

@main
struct ThemeForgeApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            HomeView()
                .navigationTitle("XFace")
        }
        .windowStyle(.hiddenTitleBar)
    }
}
