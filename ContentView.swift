import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    @AppStorage("windowOpacity") private var windowOpacity: Double = 1.0
    @AppStorage("mirrorMode") private var mirrorMode: Bool = false
    @AppStorage("recentFiles") private var recentFilesData: String = ""
    @AppStorage("fontFamily") private var fontFamily: Int = 0 // 0=mono, 1=serif, 2=sans
    @AppStorage("textAlignment") private var textAlignment: Int = 0 // 0=left, 1=center, 2=right
    @AppStorage("highContrast") private var highContrast: Bool = false
    
    @State private var text: String = "Welcome to Echoly.\n\nDrop a file here, or tap the folder icon to open one.\n\nUse [PAUSE] markers in your script for auto-pause.\nUse [SLOW] to slow down, and [CUE] to highlight a cue point."
    @State private var fontSize: CGFloat = 28
    @State private var speed: CGFloat = 1.0
    @State private var baseSpeed: CGFloat = 1.0 // stored to restore after [SLOW]
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var timer: Timer?
    @State private var isEditing = false
    @State private var showCountdown = false
    @State private var countdownValue = 3
    @State private var countdownTimer: Timer?
    @State private var textHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    @State private var isTargeted = false
    @State private var currentSpeedPreset: String = ""
    @State private var cueFlash: Bool = false // for [CUE] highlight pulse
    
    var theme: AppTheme { AppTheme(rawValue: themePreference) ?? .system }
    
    var progress: Double {
        guard textHeight > 0 else { return 0 }
        let maxScroll = max(textHeight - containerHeight * 0.55, 1)
        return min(scrollPosition / maxScroll, 1.0)
    }
    
    var wordCount: Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
    
    var estimatedReadTime: String {
        let minutes = Double(wordCount) / 150.0 // avg speaking pace
        if minutes < 1 { return "<1 min" }
        return "\(Int(minutes)) min"
    }
    
    var fontDesign: Font.Design {
        switch fontFamily {
        case 1: return .serif
        case 2: return .default // sans-serif
        default: return .monospaced
        }
    }
    
    var alignment: TextAlignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    var frameAlignment: Alignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    // Parse text into segments for cue marker rendering
    var textSegments: [(text: String, isCue: Bool)] {
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

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 28)
            
            // Toolbar
            HStack(spacing: 14) {
                toolbarButton("folder", action: openFile, help: "Open")
                toolbarButton("arrow.counterclockwise", action: resetScroll, help: "Reset")
                
                Spacer()
                
                if scrollMode == 0 {
                    toolbarButton(
                        isPlaying ? "pause" : "play",
                        action: startWithCountdown,
                        help: "Play / Pause",
                        tint: isPlaying ? .red.opacity(0.8) : nil
                    )
                    Text("\(String(format: "%.1f", speed))×")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.6))
                } else {
                    toolbarButton("chevron.down", action: manualScroll, help: "Next")
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    toolbarButton("minus", action: { if fontSize > 12 { fontSize -= 2 } }, help: "Smaller")
                    Text("\(Int(fontSize))")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(width: 20)
                    toolbarButton("plus", action: { if fontSize < 120 { fontSize += 2 } }, help: "Larger")
                    
                    toolbarButton(
                        isEditing ? "pencil.slash" : "pencil",
                        action: { isEditing.toggle() },
                        help: isEditing ? "Done" : "Edit",
                        tint: isEditing ? .orange.opacity(0.7) : nil
                    )
                    
                    toolbarButton("gearshape", action: { SettingsWindowManager.show() }, help: "Settings")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            
            Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 1)

            // Main Prompter
            ZStack {
                GeometryReader { geo in
                    Group {
                        if isEditing {
                            TextEditor(text: $text)
                                .font(.system(size: fontSize, weight: .light, design: fontDesign))
                                .lineSpacing(lineSpace)
                                .padding(.horizontal, 20)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        } else {
                            cueRenderedText()
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: frameAlignment)
                                .background(GeometryReader { textGeo in
                                    Color.clear
                                        .onAppear { textHeight = textGeo.size.height }
                                        .onChange(of: text) { textHeight = textGeo.size.height }
                                        .onChange(of: textGeo.size) { textHeight = textGeo.size.height }
                                })
                                .offset(y: max(0, geo.size.height * 0.4) - scrollPosition)
                                .scaleEffect(x: mirrorMode ? -1 : 1, y: 1)
                                .overlay(
                                    cueFlash
                                        ? Color.orange.opacity(0.08).allowsHitTesting(false)
                                        : Color.clear.allowsHitTesting(false)
                                )
                        }
                    }
                    .onAppear { containerHeight = geo.size.height }
                }
                .clipped()
                
                if showCountdown {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    Text("\(countdownValue)")
                        .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if isTargeted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .background(Color.primary.opacity(0.03))
                        .padding(6)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.primary.opacity(0.04)).frame(height: 2)
                    Rectangle()
                        .fill(Color.primary.opacity(0.2))
                        .frame(width: geo.size.width * progress, height: 2)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 2)
            
            // Footer — word count & read time
            HStack {
                Text("\(wordCount) words · \(estimatedReadTime)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.4))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .opacity(windowOpacity)
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(highContrast ? .dark : theme.colorScheme)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onChange(of: hideFromScreenSharing) { _, newValue in
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Echoly" }) {
                window.sharingType = newValue ? .none : .readOnly
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ManualScroll"))) { _ in
            if scrollMode == 1 && !isEditing { manualScroll() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TogglePlay"))) { _ in
            if scrollMode == 0 && !isEditing { startWithCountdown() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedUp"))) { _ in
            if scrollMode == 0 { speed = min(5.0, speed + 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedDown"))) { _ in
            if scrollMode == 0 { speed = max(0.5, speed - 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenRecentFile"))) { notif in
            if let path = notif.object as? String { loadFile(from: URL(fileURLWithPath: path)) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplySpeedPreset"))) { notif in
            if let spd = notif.object as? Double {
                speed = CGFloat(spd)
                baseSpeed = CGFloat(spd)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ExportPDF"))) { _ in
            ContentView.exportPDF(text: text, fontSize: fontSize)
        }
        .onChange(of: scrollMode) { _, newMode in
            // If user switches to manual mode while auto-scroll is running, stop it
            if newMode == 1 && isPlaying {
                togglePlay()
            }
        }
    }
    
    // MARK: - Cue Rendered Text
    
    @ViewBuilder
    func cueRenderedText() -> some View {
        let segs = textSegments
        if segs.count <= 1 {
            Text(text)
                .font(.system(size: fontSize, weight: .light, design: fontDesign))
                .foregroundColor(highContrast ? .white : .primary.opacity(0.85))
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        } else {
            Text(buildAttributedString(from: segs))
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        }
    }
    
    func buildAttributedString(from segs: [(text: String, isCue: Bool)]) -> AttributedString {
        var result = AttributedString()
        for seg in segs {
            if seg.isCue {
                var part = AttributedString(seg.text)
                part.font = .system(size: fontSize * 0.75, weight: .bold, design: .rounded)
                part.foregroundColor = .orange
                result += part
            } else {
                var part = AttributedString(seg.text)
                part.font = .system(size: fontSize, weight: .light, design: fontDesign)
                part.foregroundColor = highContrast ? .white : Color.primary.opacity(0.85)
                result += part
            }
        }
        return result
    }
    
    // MARK: - Toolbar Button
    
    @ViewBuilder
    func toolbarButton(_ icon: String, action: @escaping () -> Void, help: String, tint: Color? = nil) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(tint ?? .primary.opacity(0.55))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
    
    // MARK: - Countdown
    
    func startWithCountdown() {
        if isPlaying { togglePlay(); return }
        showCountdown = true
        countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            countdownValue -= 1
            if countdownValue <= 0 {
                t.invalidate(); countdownTimer = nil; showCountdown = false; togglePlay()
            }
        }
    }
    
    // MARK: - Actions
    
    func resetScroll() {
        if isPlaying { togglePlay() }
        withAnimation(.easeOut(duration: 0.3)) { scrollPosition = 0 }
    }
    
    func manualScroll() {
        let jump = (fontSize * 1.25 + CGFloat(lineSpace)) * CGFloat(linesPerScroll)
        withAnimation(.easeInOut(duration: 0.25)) { scrollPosition += jump }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    let ext = url.pathExtension.lowercased()
                    if ext == "txt" || ext == "docx" { loadFile(from: url) }
                }
            }
        }
        return true
    }
    
    func loadFile(from url: URL) {
        if url.pathExtension.lowercased() == "docx" {
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.officeOpenXML
            ]
            if let a = try? NSAttributedString(url: url, options: opts, documentAttributes: nil) {
                self.text = a.string
            }
        } else {
            if let c = try? String(contentsOf: url, encoding: .utf8) { self.text = c }
        }
        scrollPosition = 0; isPlaying = false; timer?.invalidate(); timer = nil
        addRecentFile(url.path)
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "docx") ?? .data]
        if panel.runModal() == .OK, let url = panel.url { loadFile(from: url) }
    }
    
    func addRecentFile(_ path: String) {
        var files = recentFilesData.isEmpty ? [] : recentFilesData.components(separatedBy: "|||")
        files.removeAll { $0 == path }
        files.insert(path, at: 0)
        if files.count > 5 { files = Array(files.prefix(5)) }
        recentFilesData = files.joined(separator: "|||")
    }
    
    // MARK: - Auto-scroll with cue detection
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            baseSpeed = speed // snapshot current speed as base
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                scrollPosition += speed
                checkForCuePause()
            }
        } else {
            timer?.invalidate(); timer = nil
            speed = baseSpeed // restore base speed on pause
        }
    }
    
    func checkForCuePause() {
        // Approximate which character is at the current scroll position
        let approxCharPerPixel = Double(text.count) / max(textHeight, 1)
        let currentCharIndex = Int(scrollPosition * approxCharPerPixel)
        
        let searchRange = max(0, currentCharIndex - 3)...min(text.count, currentCharIndex + 10)
        let startIdx = text.index(text.startIndex, offsetBy: max(0, searchRange.lowerBound), limitedBy: text.endIndex) ?? text.startIndex
        let endIdx = text.index(text.startIndex, offsetBy: min(text.count, searchRange.upperBound), limitedBy: text.endIndex) ?? text.endIndex
        let window = String(text[startIdx..<endIdx])
        
        if window.localizedCaseInsensitiveContains("[PAUSE]") {
            togglePlay()
        } else if window.localizedCaseInsensitiveContains("[SLOW]") {
            // Halve the speed temporarily until [CUE] or end restores it
            if speed > baseSpeed * 0.6 {
                speed = max(0.3, baseSpeed * 0.5)
            }
        } else if window.localizedCaseInsensitiveContains("[CUE]") {
            // Restore speed and flash the overlay
            speed = baseSpeed
            withAnimation(.easeInOut(duration: 0.15)) { cueFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.4)) { cueFlash = false }
            }
        }
    }
    
    // MARK: - Export PDF
    
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
