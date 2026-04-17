import AppKit

struct PDFExporter {
    static func exportPDF(attributedText: NSAttributedString, fontSize: CGFloat) {
        guard attributedText.length > 0 else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "script.pdf"
        if panel.runModal() == .OK, let url = panel.url {
            let pageWidth: CGFloat = 612
            let pageHeight: CGFloat = 792
            let pageMargin: CGFloat = 50
            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            let textRect = pageRect.insetBy(dx: pageMargin, dy: pageMargin)
            
            let pdfData = NSMutableData()
            
            guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
                  let context = CGContext(consumer: consumer, mediaBox: nil, nil) else { return }
            
            // For PDF black-on-white export, we might want to override the color if it's too light
            // but for true rich text export, we should probably keep as much as possible.
            let fullAttrStr = attributedText.mutableCopy() as! NSMutableAttributedString
            
            // Adjust base font if needed, but respect internal formatting
            fullAttrStr.enumerateAttribute(.font, in: NSRange(location: 0, length: fullAttrStr.length), options: []) { font, range, _ in
                if let oldFont = font as? NSFont {
                    let newFont = NSFont(descriptor: oldFont.fontDescriptor, size: max(oldFont.pointSize * 0.5, 12)) ?? oldFont
                    fullAttrStr.addAttribute(.font, value: newFont, range: range)
                }
            }
            
            context.beginPDFPage(nil)
            
            let framesetter = CTFramesetterCreateWithAttributedString(fullAttrStr)
            var currentRange = CFRangeMake(0, 0)
            var currentY: CGFloat = textRect.maxY
            
            while currentRange.location < fullAttrStr.length {
                let path = CGPath(rect: textRect, transform: nil)
                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)
                
                context.beginPDFPage(nil)
                CTFrameDraw(frame, context)
                context.endPDFPage()
                
                let visibleRange = CTFrameGetVisibleStringRange(frame)
                currentRange.location += visibleRange.length
            }
            
            context.closePDF()
            
            try? pdfData.write(to: url)
        }
    }
}

