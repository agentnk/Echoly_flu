import AppKit

struct PDFExporter {
    static func exportPDF(text: String, fontSize: CGFloat) {
        guard !text.isEmpty else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "script.pdf"
        if panel.runModal() == .OK, let url = panel.url {
            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
            let textRect = pageRect.insetBy(dx: 50, dy: 50)
            
            let pdfData = NSMutableData()
            
            guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
                  let context = CGContext(consumer: consumer, mediaBox: nil, nil) else { return }
            
            let paragraphs = text.components(separatedBy: "\n")
            var currentY: CGFloat = textRect.maxY
            let font = NSFont.monospacedSystemFont(ofSize: max(fontSize * 0.4, 12), weight: .regular)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.black
            ]
            
            context.beginPDFPage(nil)
            
            for para in paragraphs {
                let attrStr = NSAttributedString(string: para.isEmpty ? " " : para, attributes: attrs)
                let framesetter = CTFramesetterCreateWithAttributedString(attrStr)
                let size = CTFramesetterSuggestFrameSizeWithConstraints(
                    framesetter,
                    CFRange(location: 0, length: attrStr.length),
                    nil,
                    CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
                    nil
                )
                
                currentY -= size.height + 6
                if currentY < textRect.minY {
                    context.endPDFPage()
                    context.beginPDFPage(nil)
                    currentY = textRect.maxY - size.height - 6
                }
                
                let path = CGPath(
                    rect: CGRect(x: textRect.minX, y: currentY, width: textRect.width, height: size.height),
                    transform: nil
                )
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: 0, length: attrStr.length),
                    path,
                    nil
                )
                CTFrameDraw(frame, context)
            }
            
            context.endPDFPage()
            context.closePDF()
            
            try? pdfData.write(to: url)
        }
    }
}
