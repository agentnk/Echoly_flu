import Foundation
import AppKit
import UniformTypeIdentifiers

struct DocumentHandler {
    static var allowedContentTypes: [UTType] {
        [.plainText, .rtf, .rtfd, UTType(filenameExtension: "docx") ?? .data]
    }

    static func handleDrop(providers: [NSItemProvider], completion: @escaping (URL?) -> Void) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    let ext = url.pathExtension.lowercased()
                    let supported = ["txt", "docx", "rtf", "rtfd"]
                    if supported.contains(ext) {
                        completion(url)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        return true
    }
    
    static func loadAttributedText(from url: URL) -> NSAttributedString? {
        let ext = url.pathExtension.lowercased()
        
        do {
            if ext == "docx" {
                let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.officeOpenXML
                ]
                return try NSAttributedString(url: url, options: opts, documentAttributes: nil)
            } else if ext == "rtf" {
                return try NSAttributedString(url: url, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            } else if ext == "rtfd" {
                return try NSAttributedString(url: url, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            } else {
                let text = try String(contentsOf: url, encoding: .utf8)
                return NSAttributedString(string: text)
            }
        } catch {
            print("Error loading document: \(error)")
            return nil
        }
    }
    
    // Kept for backward compatibility if needed, but preferred to use loadAttributedText
    static func loadText(from url: URL) -> String? {
        return loadAttributedText(from: url)?.string
    }
    
    static func openFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = allowedContentTypes
        if panel.runModal() == .OK {
            completion(panel.url)
        } else {
            completion(nil)
        }
    }
    
    static func addRecentFile(_ path: String, to existingData: String) -> String {
        var files = existingData.isEmpty ? [] : existingData.components(separatedBy: "|||")
        files.removeAll { $0 == path }
        files.insert(path, at: 0)
        if files.count > 5 { files = Array(files.prefix(5)) }
        return files.joined(separator: "|||")
    }
}

