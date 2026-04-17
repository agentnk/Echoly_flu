import SwiftUI

struct ScriptParser {
    private static let avgWordsPerMinute: Double = 150

    static func wordCount(for text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
    
    static func estimatedReadTime(wordCount: Int) -> String {
        let minutes = Double(wordCount) / avgWordsPerMinute
        if minutes < 1 { return "<1 min" }
        return "\(Int(minutes)) min"
    }
    
    static func processRichTextCues(from attrText: NSAttributedString, fontSize: CGFloat, fontDesign: Font.Design, highContrast: Bool) -> AttributedString {
        var result = AttributedString(attrText)
        let plain = attrText.string
        
        let pattern = "\\[(PAUSE|SLOW|CUE)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return result
        }
        
        let nsRange = NSRange(plain.startIndex..., in: plain)
        let matches = regex.matches(in: plain, range: nsRange).reversed()
        
        for match in matches {
            if let range = Range(match.range, in: result) {
                result[range].foregroundColor = .orange
                result[range].font = .system(size: fontSize * 0.7, weight: .bold, design: .rounded)
            }
        }
        
        return result
    }
}

