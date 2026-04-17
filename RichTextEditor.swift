import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var fontSize: CGFloat
    var fontDesign: Font.Design
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = NSTextView(frame: .zero)
        textView.isRichText = true
        textView.importsGraphics = true
        textView.allowsUndo = true
        textView.autoresizingMask = [.width, .height]
        textView.drawsBackground = false
        textView.insertionPointColor = .primaryStyle
        textView.delegate = context.coordinator
        
        textView.textStorage?.setAttributedString(attributedText)
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.attributedSubstring(forProposedRange: NSRange(location: 0, length: textView.string.count), actualRange: nil) != attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        }
        
        // Apply base styling if no attributes exist (fallback)
        if textView.string.isEmpty {
            textView.font = .systemFont(ofSize: fontSize)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.attributedText = textView.attributedSubstring(forProposedRange: NSRange(location: 0, length: textView.string.count), actualRange: nil)
        }
    }
}

extension NSColor {
    static var primaryStyle: NSColor {
        #if canImport(AppKit)
        return NSColor.labelColor
        #else
        return .white
        #endif
    }
}
