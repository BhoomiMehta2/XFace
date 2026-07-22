import Foundation

/// Utility helper that formats dictionary values into standard Apple XML plist definitions.
public final class XMLWriter {
    
    /// Compiles a dictionary hierarchy into an XML plist file format.
    public static func makePlistString(from dict: [String: Any]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        """
        
        xml += "\n" + makePlistDictContent(dict, indentLevel: 1)
        xml += "</dict>\n</plist>\n"
        return xml
    }
    
    private static func makePlistDictContent(_ dict: [String: Any], indentLevel: Int) -> String {
        var content = ""
        let indent = String(repeating: "\t", count: indentLevel)
        
        // Maintain stable output ordering for plist key structures
        let sortedKeys = dict.keys.sorted()
        
        for key in sortedKeys {
            content += "\(indent)<key>\(escape(key))</key>\n"
            
            let val = dict[key]
            if let str = val as? String {
                content += "\(indent)<string>\(escape(str))</string>\n"
            } else if let num = val as? Int {
                content += "\(indent)<integer>\(num)</integer>\n"
            } else if let d = val as? [String: Any] {
                content += "\(indent)<dict>\n"
                content += makePlistDictContent(d, indentLevel: indentLevel + 1)
                content += "\(indent)</dict>\n"
            } else if let doubleVal = val as? Double {
                content += "\(indent)<real>\(doubleVal)</real>\n"
            } else {
                content += "\(indent)<string>\(escape(String(describing: val ?? "")))</string>\n"
            }
        }
        return content
    }
    
    private static func escape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
