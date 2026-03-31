import SwiftUI

struct ScriptParser {
    static func wordCount(for text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
    
    static func estimatedReadTime(wordCount: Int) -> String {
        let minutes = Double(wordCount) / 150.0 // avg speaking pace
        if minutes < 1 { return "<1 min" }
        return "\(Int(minutes)) min"
    }
    
    static func textSegments(from text: String) -> [(text: String, isCue: Bool)] {
        let pattern = "\\[(PAUSE|SLOW|CUE)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return [(text, false)]
        }
        var segments: [(String, Bool)] = []
        var lastEnd = text.startIndex
        let nsRange = NSRange(text.startIndex..., in: text)
        
        for match in regex.matches(in: text, range: nsRange) {
            if let range = Range(match.range, in: text) {
                let before = String(text[lastEnd..<range.lowerBound])
                if !before.isEmpty { segments.append((before, false)) }
                segments.append((String(text[range]), true))
                lastEnd = range.upperBound
            }
        }
        let remaining = String(text[lastEnd...])
        if !remaining.isEmpty { segments.append((remaining, false)) }
        return segments
    }
    
    static func buildAttributedString(from segs: [(text: String, isCue: Bool)], fontSize: CGFloat, fontDesign: Font.Design, highContrast: Bool) -> AttributedString {
        var result = AttributedString()
        for seg in segs {
            if seg.isCue {
                var part = AttributedString(seg.text)
                part.font = .system(size: fontSize * 0.75, weight: .bold, design: .rounded)
                part.foregroundColor = .orange
                result += part
            } else {
                var part = AttributedString(seg.text)
                part.font = .system(size: fontSize, weight: .bold, design: fontDesign)
                part.foregroundColor = highContrast ? .white : Color.primary.opacity(0.85)
                result += part
            }
        }
        return result
    }
}
