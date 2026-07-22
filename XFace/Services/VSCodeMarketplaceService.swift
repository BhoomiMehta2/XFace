import Foundation

// MARK: - Marketplace Models

public struct VSMarketplaceResponse: Codable {
    public let results: [VSMarketplaceResult]?
}

public struct VSMarketplaceResult: Codable {
    public let extensions: [VSMarketplaceExtension]?
}

public struct VSMarketplaceExtension: Codable, Identifiable {
    public var id: String { extensionId }
    public let extensionId: String
    public let extensionName: String
    public let displayName: String?
    public let shortDescription: String?
    public let publisher: VSMarketplacePublisher
    public let versions: [VSMarketplaceVersion]?
    
    public struct VSMarketplacePublisher: Codable {
        public let publisherName: String
        public let displayName: String?
    }
    
    public struct VSMarketplaceVersion: Codable {
        public let version: String
        public let files: [VSMarketplaceFile]?
    }
    
    public struct VSMarketplaceFile: Codable {
        public let assetType: String
        public let source: String
    }
}

// MARK: - VS Code Extension package.json Models

private struct VSPackageJSON: Codable {
    let contributes: VSPackageContributes?
    
    struct VSPackageContributes: Codable {
        let themes: [VSPackageTheme]?
    }
    
    struct VSPackageTheme: Codable {
        let label: String?
        let path: String
    }
}

// MARK: - Service Implementation

public final class VSCodeMarketplaceService {
    
    /// Queries the VS Code Extension Marketplace API for theme extensions matching the search string.
    public static func searchThemes(query: String) async throws -> [VSMarketplaceExtension] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        
        let url = URL(string: "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json;api-version=3.0-preview.1", forHTTPHeaderField: "Accept")
        
        let payload: [String: Any] = [
            "filters": [
                [
                    "criteria": [
                        ["filterType": 8, "value": "Microsoft.VisualStudio.Code"],
                        ["filterType": 10, "value": query],
                        ["filterType": 5, "value": "Themes"]
                    ],
                    "pageSize": 15,
                    "pageNumber": 1,
                    "sortBy": 0,
                    "sortOrder": 0
                ]
            ],
            "assetTypes": [] as [String],
            "flags": 914
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API response from Marketplace server."])
        }
        
        let decoder = JSONDecoder()
        let marketplaceResponse = try decoder.decode(VSMarketplaceResponse.self, from: data)
        
        let extensions = marketplaceResponse.results?.first?.extensions ?? []
        // Filter out extensions that don't have any versions or VSIX packages
        return extensions.filter { ext in
            guard let version = ext.versions?.first else { return false }
            return version.files?.contains { $0.assetType == "Microsoft.VisualStudio.Services.VSIXPackage" } ?? false
        }
    }
    
    /// Downloads the VSIX package to a temporary file path on disk.
    public static func downloadVSIX(from urlString: String) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid VSIX download URL."])
        }
        
        let (tempURL, response) = try await URLSession.shared.download(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to download extension package. HTTP error."])
        }
        
        // Save to a proper .zip extension file in temporary directory
        let fileManager = FileManager.default
        let newTempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        try fileManager.moveItem(at: tempURL, to: newTempURL)
        
        return newTempURL
    }
    
    /// Extracts theme JSON contents directly from the local VSIX file path.
    public static func extractThemes(fromVSIX vsixURL: URL) throws -> [(name: String, content: String)] {
        let vsixPath = vsixURL.path
        
        // 1. Extract and read 'extension/package.json'
        let packageData = try runUnzip(vsixPath: vsixPath, internalFilePath: "extension/package.json")
        let cleanPackageJSON = VSCodeThemeImporter.cleanJSONComments(String(decoding: packageData, as: UTF8.self))
        
        guard let cleanPackageData = cleanPackageJSON.data(using: .utf8) else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse package.json from extension package."])
        }
        
        let decoder = JSONDecoder()
        let package = try decoder.decode(VSPackageJSON.self, from: cleanPackageData)
        
        guard let themes = package.contributes?.themes, !themes.isEmpty else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 5, userInfo: [NSLocalizedDescriptionKey: "No theme contributions found inside this extension package."])
        }
        
        var extractedThemes: [(name: String, content: String)] = []
        
        for theme in themes {
            var relativePath = theme.path
            if relativePath.hasPrefix("./") {
                relativePath.removeFirst(2)
            } else if relativePath.hasPrefix("/") {
                relativePath.removeFirst()
            }
            
            let zipPath = "extension/\(relativePath)"
            
            do {
                let themeData = try runUnzip(vsixPath: vsixPath, internalFilePath: zipPath)
                if let themeString = String(data: themeData, encoding: .utf8) {
                    let label = theme.label ?? vsixURL.deletingPathExtension().lastPathComponent
                    extractedThemes.append((name: label, content: themeString))
                }
            } catch {
                // If a specific theme inside the pack fails to extract, log and skip
                print("Skipping theme \(theme.label ?? "") due to extraction failure: \(error.localizedDescription)")
            }
        }
        
        // Clean up vsix zip file
        try? FileManager.default.removeItem(at: vsixURL)
        
        guard !extractedThemes.isEmpty else {
            throw NSError(domain: "VSCodeMarketplaceService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to extract any valid theme JSONs from package."])
        }
        
        return extractedThemes
    }
    
    /// Runs '/usr/bin/unzip' shell tool to output file contents of a zip archive straight to standard output.
    private static func runUnzip(vsixPath: String, internalFilePath: String) throws -> Data {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-p", vsixPath, internalFilePath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw NSError(
                domain: "VSCodeMarketplaceService",
                code: 7,
                userInfo: [NSLocalizedDescriptionKey: "Unzip utility failed. Make sure the package contains '\(internalFilePath)'."]
            )
        }
        
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
}
