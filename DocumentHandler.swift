import Foundation
import AppKit
import UniformTypeIdentifiers

struct DocumentHandler {
    static func handleDrop(providers: [NSItemProvider], completion: @escaping (URL?) -> Void) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    let ext = url.pathExtension.lowercased()
                    if ext == "txt" || ext == "docx" {
                        completion(url)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        return true
    }
    
    static func loadText(from url: URL) -> String? {
        if url.pathExtension.lowercased() == "docx" {
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.officeOpenXML
            ]
            if let a = try? NSAttributedString(url: url, options: opts, documentAttributes: nil) {
                return a.string
            }
        } else {
            if let c = try? String(contentsOf: url, encoding: .utf8) {
                return c
            }
        }
        return nil
    }
    
    static func openFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "docx") ?? .data]
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
